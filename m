Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id BA2E56B0044
	for <linux-mm@kvack.org>; Thu,  9 Aug 2012 14:46:19 -0400 (EDT)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <john.stultz@linaro.org>;
	Thu, 9 Aug 2012 14:46:18 -0400
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 7E309C9005A
	for <linux-mm@kvack.org>; Thu,  9 Aug 2012 14:46:16 -0400 (EDT)
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q79IkFBH113226
	for <linux-mm@kvack.org>; Thu, 9 Aug 2012 14:46:16 -0400
Received: from d03av05.boulder.ibm.com (loopback [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q79Ik26Y009383
	for <linux-mm@kvack.org>; Thu, 9 Aug 2012 12:46:08 -0600
Message-ID: <50240560.9060208@linaro.org>
Date: Thu, 09 Aug 2012 11:45:52 -0700
From: John Stultz <john.stultz@linaro.org>
MIME-Version: 1.0
Subject: Re: [PATCH 0/5][RFC] Fallocate Volatile Ranges v6
References: <1343447832-7182-1-git-send-email-john.stultz@linaro.org> <CANN689FzQSLAFw0tNmdiOQ0PwV1nN8FaL0LNkkDMEB10k0jmwA@mail.gmail.com>
In-Reply-To: <CANN689FzQSLAFw0tNmdiOQ0PwV1nN8FaL0LNkkDMEB10k0jmwA@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Andrea Righi <andrea@betterlinux.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mike Hommey <mh@glandium.org>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Minchan Kim <minchan@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 08/09/2012 02:28 AM, Michel Lespinasse wrote:
> Hi John,
>
> On Fri, Jul 27, 2012 at 8:57 PM, John Stultz <john.stultz@linaro.org> wrote:
>> So after not getting too much positive feedback on my last
>> attempt at trying to use a non-shrinker method for managing
>> & purging volatile ranges, I decided I'd go ahead and try
>> to implement something along Minchan's ERECLAIM LRU list
>> idea.
> Agree that there hasn't been much feedback from MM folks yet - sorry
> about that :/
>
> I think one issue might be that most people don't have a good
> background on how the feature is intended to be used, and it is very
> difficult to comment meaningfully without that.
>
> As for myself, I have been wondering:
>
> - Why the feature needs to be on a per-range basis, rather than
> per-file. Is this simply to make it easier to transition the android
> use case from whatever they are doing right now, or is it that the
> object boundaries within a file can't be known in advance, and thus
> one wouldn't know how to split objects accross different files ? Or
> could it be that some of the objects would be small (less than a page)
> so space use would be inefficient if they were placed in different
> files ? Or just that there would be too many files for efficient
> management ?
For me, keeping the feature per-range instead of something like per-file 
is in order to be able to support Android's existing use case.

As to why Android uses per-range instead of per file, Arve or someone 
from the Android team could  probably better answer,  but I can 
theorize.   In discussions with the Android guys, they've mentioned 
ashmem's primary goal was to basically provide atomically unlinked tmpfs 
fds for sharing memory, and memory unpinning was a follow on feature.  
So I suspect that ranges fit better into their existing model of using a 
mmapped fd to share data between two processes. Instead of creating a 
new tmpfs file and sharing the fd for each object, they're able to 
create a one shared mapping, which can be effectively resized w/ 
unpinning,  for multiple objects.

Another use case where ranges would be beneficial might be for where 
there's a large single object that might not all be in use at one time. 
For example, a very large web page,  where you have a limited view onto 
it. Having the rest of the page rendered so you can quickly scroll 
without re-rendering would be nice, but under memory pressure it could 
effectively throw out the non-visible portions.

Further, one additional reason I have for not having the volatile 
attribute be per-file, is that I have my eye on allowing volatile ranges 
to be set on anonymous heap memory via something like madvise() in the 
future, which would be an easier api to use if you're not sharing data 
via mmapped tmpfs files, but wouldn't be possible if this was a file 
attribute rather then a range of pages.


> - What are the desired semantics for the volatile objects. Can the
> objects be accessed while they are marked as volatile, or do they have
> to get unmarked first ?
So accessing a volatile page before marking it non-volatile can produce 
undefined behavior. You could get the data that was there, or you could 
get empty pages.  The expectation is that pages are unmarked before 
being accessed, so one can know if the data was lost or not.   I'm open 
to other suggestions here, if folks think we should SIGSEGV on accesses 
to volatile pages. However, I don't know how setting that up and tearing 
it down on each mark_volatile/unmark_volatile might affect performance.

> Is it really the case that we always want to
> reclaim from volatile objects first, before any other kind of caches
> we might have ? This sounds like a very strong hint, and I think I
> would be more comfortable with something more subtle if that's
> possible.
So the current Android ashmem implementation uses a shrinker, which 
isn't necessarily called before any other caches are freed.  So, I don't 
think its a strong hint, but it just seems somewhat intuitive to me that 
we should free effectively "user-donated" pages before freeing other 
system caches.  But that's not something the interface necessarily 
defines or requires.


> Also, if we have several volatile objects to reclaim from,
> is it desirable to reclaim from the one that's been marked volatile
> the longest or does it make no difference ?
While I don't think its strictly necessary, I do think LRU order purging 
is important from the least-surprise angle.   Since ranges marked 
volatile should not be touched until they are marked non-volatile, it 
follows normal expectations that recently touched data is likely to be 
faster then data that has not been accessed for some time.  Reasonable 
exceptions would be situations like NUMA systems where pressure on one 
node forces purging volatile pages in a non-global-lru order. So 
probably not critical, but I think useful to try to preserve.


> When an object is marked
> volatile, would it be sufficient to ensure it gets placed on the
> inactive list (maybe with the referenced bit cleared) and let the
> normal reclaim algorithm get to it, or is that an insufficiently
> strong hint somehow ?

The problem is that on machines without swap, there wouldn't be any 
reclaim for inactive anonymous pages.

An earlier iteration of this implementation (v4 I think?) used writepage 
to decide if to purge or writeout a page, and made it so in non-swap 
cases the anonymous inactive list was in effect the "volatile" list.  
However, folks didn't seem to like this approach.


> Basically, having some background information of how android would be
> using the feature would help us better understand the design decision
> here, I think.
Hopefully the details above help, and I'll try to get some more concrete 
examples from the Android code base.

thanks
-john

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
