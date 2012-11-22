Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 8A2DE6B0062
	for <linux-mm@kvack.org>; Wed, 21 Nov 2012 19:45:38 -0500 (EST)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <john.stultz@linaro.org>;
	Wed, 21 Nov 2012 19:45:37 -0500
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 461426E807E
	for <linux-mm@kvack.org>; Wed, 21 Nov 2012 19:36:53 -0500 (EST)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id qAM0aof565142934
	for <linux-mm@kvack.org>; Wed, 21 Nov 2012 19:36:50 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id qAM0alEx000795
	for <linux-mm@kvack.org>; Wed, 21 Nov 2012 22:36:48 -0200
Message-ID: <50AD739A.30804@linaro.org>
Date: Wed, 21 Nov 2012 16:36:42 -0800
From: John Stultz <john.stultz@linaro.org>
MIME-Version: 1.0
Subject: Re: [RFC v2] Support volatile range for anon vma
References: <1351560594-18366-1-git-send-email-minchan@kernel.org>
In-Reply-To: <1351560594-18366-1-git-send-email-minchan@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Christoph Lameter <cl@linux.com>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On 10/29/2012 06:29 PM, Minchan Kim wrote:
> This patch introudces new madvise behavior MADV_VOLATILE and
> MADV_NOVOLATILE for anonymous pages. It's different with
> John Stultz's version which considers only tmpfs while this patch
> considers only anonymous pages so this cannot cover John's one.
> If below idea is proved as reasonable, I hope we can unify both
> concepts by madvise/fadvise.
>
> Rationale is following as.
> Many allocators call munmap(2) when user call free(3) if ptr is
> in mmaped area. But munmap isn't cheap because it have to clean up
> all pte entries and unlinking a vma so overhead would be increased
> linearly by mmaped area's size.
>
> Volatile conecept of Robert Love could be very useful for reducing
> free(3) overhead. Allocators can do madvise(MADV_VOLATILE) instead of
> munmap(2)(Of course, they need to manage volatile mmaped area to
> reduce shortage of address space and sometime ends up unmaping them).
> The madvise(MADV_VOLATILE|NOVOLATILE) is very cheap opeartion because
>
> 1) it just marks the flag in VMA and
> 2) if memory pressure happens, VM can discard pages of volatile VMA
>     instead of swapping out when volatile pages is selected as victim
>     by normal VM aging policy.
> 3) freed mmaped area doesn't include any meaningful data so there
>     is no point to swap them out.
>
> Allocator should call madvise(MADV_NOVOLATILE) before reusing for
> allocating that area to user. Otherwise, accessing of volatile range
> will meet SIGBUS error.
>
> The downside is that we have to age anon lru list although we don't
> have swap because I don't want to discard volatile pages by top priority
> when memory pressure happens as volatile in this patch means "We don't
> need to swap out because user can handle the situation which data are
> disappear suddenly", NOT "They are useless so hurry up to reclaim them".
> So I want to apply same aging rule of nomal pages to them.
>
> Anon background aging of non-swap system would be a trade-off for
> getting good feature. Even, we had done it two years ago until merge
> [1] and I believe free(3) performance gain will beat loss of anon lru
> aging's overead once all of allocator start to use madvise.
> (This patch doesn't include background aging in case of non-swap system
>   but it's trivial if we decide)

Hey Minchan!
     So I've been looking at your patch for a bit, and I'm still trying 
to fully grok it and the rmap code. Overall this approach looks pretty 
interesting,  and while your patch description focused on malloc/free 
behavior, I suspect your patch would satisfy what the mozilla folks are 
looking for, and while its not quite sufficient yet for Android, the 
interface semantics are very close to what I've been wanting (my test 
cases were easily mapped over).

The two major issues for me are:
1) As you noted, this approach currently doesn't work on non-swap 
systems, as we don't try to shrink the anonymous page lrus. This is a 
big problem, as it makes it unusable for most all Android systems. You 
suggest we may want to change aging the anonymous lru, and I had a patch 
earlier that tried to change some of the anonymous lru aging rules for 
volatile pages, but its not quite right for what you have here. So I'd 
be interested in hearing how you think the anonymous lru aging should 
happen with swapoff.

2) Being able to use this with tmpfs files. I'm currently trying to 
better understand the rmap code, looking to see if there's a way to have 
try_to_unmap_file() work similarly to try_to_unmap_anon(), to allow 
allow users to madvise() on mmapped tmpfs files. This would provide a 
very similar interface as to what I've been proposing with 
fadvise/fallocate, but just using process virtual addresses instead of 
(fd, offset) pairs.   The benefit with (fd,offset) pairs for Android is 
that its easier to manage shared volatile ranges between two processes 
that are sharing data via an mmapped tmpfs file (although this actual 
use case may be fairly rare).  I believe we should still be able to 
rework the ashmem internals to use madvise (which would provide legacy 
support for existing android apps), so then its just a question of if we 
could then eventually convince Android apps to use the madvise interface 
directly, rather then the ashmem unpin ioctl.

The other concern with the madvise on mmapped files approach is that 
there's no easy way I can see to limit it to tmpfs files. I know some 
have been interested in having fallocate(VOLATILE) interface for 
non-tmpfs files, but I'm not sure I see the benefit there yet. I have 
noted folks mixing the idea of volatile pages being purged under memory 
pressure with the idea of volatile files, which might be purged from 
disk under disk pressure. While I think the second idea is interesting, 
I do think its completely separate from the volatile memory concept.

Anyway, I'd be interested in your thoughts on these two issues. Thanks 
so much for sending out this patch, its given me quite a bit to chew on, 
and I too hope we can merge our different approaches together.

thanks
-john

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
