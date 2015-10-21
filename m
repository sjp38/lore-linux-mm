Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id EB8566B0038
	for <linux-mm@kvack.org>; Wed, 21 Oct 2015 18:39:07 -0400 (EDT)
Received: by pacfv9 with SMTP id fv9so69770754pac.3
        for <linux-mm@kvack.org>; Wed, 21 Oct 2015 15:39:07 -0700 (PDT)
Received: from mail-pa0-x22a.google.com (mail-pa0-x22a.google.com. [2607:f8b0:400e:c03::22a])
        by mx.google.com with ESMTPS id lu5si16326854pab.178.2015.10.21.15.39.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Oct 2015 15:39:07 -0700 (PDT)
Received: by padhk11 with SMTP id hk11so66959390pad.1
        for <linux-mm@kvack.org>; Wed, 21 Oct 2015 15:39:06 -0700 (PDT)
Date: Wed, 21 Oct 2015 15:38:49 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH v4 2/4] mm, proc: account for shmem swap in
 /proc/pid/smaps
In-Reply-To: <5627A397.6090305@suse.cz>
Message-ID: <alpine.LSU.2.11.1510211424010.3905@eggly.anvils>
References: <1443792951-13944-1-git-send-email-vbabka@suse.cz> <1443792951-13944-3-git-send-email-vbabka@suse.cz> <alpine.LSU.2.11.1510041806040.15067@eggly.anvils> <5627A397.6090305@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, Jerome Marchand <jmarchan@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Randy Dunlap <rdunlap@infradead.org>, linux-s390@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Peter Zijlstra <peterz@infradead.org>, Paul Mackerras <paulus@samba.org>, Arnaldo Carvalho de Melo <acme@kernel.org>, Oleg Nesterov <oleg@redhat.com>, Linux API <linux-api@vger.kernel.org>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>

On Wed, 21 Oct 2015, Vlastimil Babka wrote:
> On 10/05/2015 05:01 AM, Hugh Dickins wrote:
> > On Fri, 2 Oct 2015, Vlastimil Babka wrote:
> > 
> > > Currently, /proc/pid/smaps will always show "Swap: 0 kB" for shmem-backed
> > > mappings, even if the mapped portion does contain pages that were swapped
> > > out.
> > > This is because unlike private anonymous mappings, shmem does not change
> > > pte
> > > to swap entry, but pte_none when swapping the page out. In the smaps page
> > > walk, such page thus looks like it was never faulted in.
> > > 
> > > This patch changes smaps_pte_entry() to determine the swap status for
> > > such
> > > pte_none entries for shmem mappings, similarly to how mincore_page() does
> > > it.
> > > Swapped out pages are thus accounted for.
> > > 
> > > The accounting is arguably still not as precise as for private anonymous
> > > mappings, since now we will count also pages that the process in question
> > > never
> > > accessed, but only another process populated them and then let them
> > > become
> > > swapped out. I believe it is still less confusing and subtle than not
> > > showing
> > > any swap usage by shmem mappings at all. Also, swapped out pages only
> > > becomee a
> > > performance issue for future accesses, and we cannot predict those for
> > > neither
> > > kind of mapping.
> > > 
> > > Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> > > Acked-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
> > 
> > Neither Ack nor Nack from me.
> > 
> > I don't want to stand in the way of this patch, if you and others
> > believe that it will help to diagnose problems in the field better
> > than what's shown at present; but to me it looks dangerously like
> > replacing no information by wrong information.
> > 
> > As you acknowledge in the commit message, if a file of 100 pages
> > were copied to tmpfs, and 100 tasks map its full extent, but they
> > all mess around with the first 50 pages and take no interest in
> > the last 50, then it's quite likely that that last 50 will get
> > swapped out; then with your patch, 100 tasks are each shown as
> > using 50 pages of swap, when none of them are actually using any.
> 
> Yeah, but isn't it the same with private memory which was swapped out at some
> point and we don't know if it will be touched or not? The
> difference is in private case we know the process touched it at least
> once, but that can also mean nothing for the future (or maybe it just
> mmapped with MAP_POPULATE and didn't care about half of it).

I see that as quite different myself; but agree that neither way
predicts the future.  Now, if you can make a patch to predict the future...

FWIW, I do seem to be looking at it more from a point of view of how
much swap the process is using, whereas you're looking at it more
from a point of view of what delays would be incurred in accessing.

> 
> That's basically what I was trying to say in the changelog. I interpret
> the Swap: value as the amount of swap-in potential, if the process was
> going to access it, which is what the particular customer also expects (see
> below). In that case showing zero is IMHO wrong and inconsistent with the
> anonymous private mappings.

Yes, your changelog is honest about the difference, I don't dispute that.
As I said, neither Ack nor Nack from me: I just don't feel in a position
to judge whether changing the output of smaps to please this customer is
likely to displease another customer or not.

> 
> > It is rather as if we didn't bother to record Rss, and just put
> > Size in there instead: you are (for understandable reasons) treating
> > the virtual address space as if every page of it had been touched.
> > 
> > But I accept that there may well be a class of processes and problems
> > which would be better served by this fiction than the present: I expect
> > you have much more experience of helping out in such situations than I.
> 
> Well, the customers driving this change would in the best case want to
> see the shmem swap accounted continuously and e.g. see it immediately in the
> top output. Fixing (IMHO) the smaps output is the next best thing. The use
> case here is a application that really doesn't like page faults, and has
> background thread that checks and prefaults such areas when they are expected
> to be used soon. So they would like to identify these areas.

And I guess I won't be able to sell mlock(2) to you :)

Still neither Ack nor Nack from me: while your number is more information
(or misinformation) than always 0, it's still not clear to me that it will
give them what they need.

...
> > 
> > And for private mappings of tmpfs files?  I expected it to show an
> > inderminate mixture of the two, but it looks like you treat the private
> > mapping just like a shared one, and take no notice of the COWed pages
> > out on swap which would have been reported before.  Oh, no, I think
> > I misread, and you add the two together?  I agree that's the easiest
> > thing to do, and therefore perhaps the best; but it doesn't fill me
> > with conviction that it's the right thing to do.
> 
> Thanks for pointing this out, I totally missed this possibility! Well
> the current patch is certainly not the right thing to do, as it can
> over-account. The most correct solution would have to be implemented into the
> page walk and only check into shmem radix tree for individual pages that were
> not COWed. Michal Hocko suggested I try that, and although it does add some
> overhead (the complexity is n*log(n) AFAICT), it's not that bad from
> preliminary checks. Another advantage is that no new shmem code is needed, as
> we can use the generic find_get_entry(). Unless we want to really limit the
> extra complexity only to the special private mapping case with non-zero swap
> usage of the shmem object etc... I'll repost the series with that approach.
> 
> Other non-perfect solutions that come to mind:
> 
> 1) For private mappings, count only the swapents. "Swap:" is no longer
> showing full swap-in potential though.
> 2) For private mappings, do not count swapents. Ditto.
> 3) Provide two separate counters. The user won't know how much they
> overlap, though.
> 
> From these I would be inclined towards 3) as being more universal, although
> then it's no longer a simple "we're fixing a Swap: 0 value which is wrong",
> but closer to original Jerome's versions, which IIRC introduced several
> shmem-specific counters.
> 
> Well at least now I do understand why you don't particularly like this
> approach...

Have you considered extending mincore(2) for them?

It was always intended that more info could be added into its byte array
later - the man page I'm looking at says "The settings of the other bits
[than the least significant] in each byte are undefined; these bits are
reserved for possible later use."

That way your customers could get a precise picture of the status of
each page: without ambiguity as to whether it's anon, shmem, file, anon
swap, shmem swap, whatever; without ambiguity as to where 40kB of 80kB
lies in the region, the unused half or the vital half etc.

Or forget passing back the info: just offer an madvise(,, MADV_POPULATE)?

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
