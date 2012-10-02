Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 716D26B006C
	for <linux-mm@kvack.org>; Tue,  2 Oct 2012 13:31:15 -0400 (EDT)
Message-ID: <506B24E1.2000300@mozilla.com>
Date: Tue, 02 Oct 2012 10:31:13 -0700
From: Taras Glek <tglek@mozilla.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/3] Volatile Ranges (v7) & Lots of words
References: <1348888593-23047-1-git-send-email-john.stultz@linaro.org>
In-Reply-To: <1348888593-23047-1-git-send-email-john.stultz@linaro.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Stultz <john.stultz@linaro.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Andrea Righi <andrea@betterlinux.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mike Hommey <mh@glandium.org>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 9/28/2012 8:16 PM, John Stultz wrote:
> <snip>
> There is two rough approaches that I have tried so far
>
> 1) Managing volatile range objects, in a tree or list, which are then
> purged using a shrinker
>
> 2) Page based management, where pages marked volatile are moved to
> a new LRU list and are purged from there.
>
>
>
> 1) This patchset is of the the shrinker-based approach. In many ways it
> is simpler, but it does have a few drawbacks.  Basically when marking a
> range as volatile, we create a range object, and add it to an rbtree.
> This allows us to be able to quickly find ranges, given an address in
> the file.  We also add each range object to the tail of a  filesystem
> global linked list, which acts as an LRU allowing us to quickly find
> the least recently created volatile range. We then use a shrinker
> callback to trigger purging, where we'll select the range on the head
> of the LRU list, purge the data, mark the range object as purged,
> and remove it from the lru list.
>
> This allows fairly efficient behavior, as marking and unmarking
> a range are both O(logn) operation with respect to the number of
> ranges, to insert and remove from the tree.  Purging the range is
> also O(1) to select the range, and we purge the entire range in
> least-recently-marked-volatile order.
>
> The drawbacks with this approach is that it uses a shrinker, thus it is
> numa un-aware. We track the virtual address of the pages in the file,
> so we don't have a sense of what physical pages we're using, nor on
> which node those pages may be on. So its possible on a multi-node
> system that when one node was under pressure, we'd purge volatile
> ranges that are all on a different node, in effect throwing data away
> without helping anything. This is clearly non-ideal for numa systems.
>
> One idea I discussed with Michel Lespinasse is that this might be
> something we could improve by providing the shrinker some node context,
> then keep track in the range  what node their first page is on. That
> way we would be sure to at least free up one page on the node under
> pressure when purging that range.
>
>
> 2) The second approach, which was more page based, was also tried. In
> this case when we marked a range as volatile, the pages in that range
> were moved to a new  lru list LRU _VOLATILE in vmscan.c.  This provided
> a page lru list that could be used to free pages before looking at
> the LRU_INACTIVE_FILE/ANONYMOUS lists.
>
> This integrates the feature deeper in the mm code, which is nice,
> especially as we have an LRU_VOLATILE list for each numa node. Thus
> under pressure we won't purge ranges that are entirely on a different
> node, as is possible with the other approach.
>
> However, this approach is more costly.	When marking a range
> as volatile, we have to migrate every page in that range to the
> LRU_VOLATILE list, and similarly on unmarking we have to move each
> page back. This ends up being O(n) with respect to the number of
> pages in the range we're marking or unmarking. Similarly when purging,
> we let the scanning code select a page off the lru, then we have to
> map it back to the volatile range so we can purge the entire range,
> making it a more expensive O(logn),  with respect to the number of
> ranges, operation.
>
> This is a particular concern as applications that want to mark and
> unmark data as volatile with fine granularity will likely be calling
> these operations frequently, adding quite a bit of overhead. This
> makes it less likely that applications will choose to volunteer data
> as volatile to the system.
>
> However, with the new lazy SIGBUS notification, applications using
> the SIGBUS method would avoid having to mark and unmark data when
> accessing it, so this overhead may be less of a concern. However, for
> cases where applications don't want to deal with the SIGBUS and would
> rather have the more deterministic behavior of the unmark/access/mark
> pattern, the performance is a concern.
Unfortunately, approach 1 is not useful for our use-case. It'll mean 
that we are continuously re-decompressing frequently used parts of 
libxul.so under memory pressure(which is pretty often on limited ram 
devices).


Taras

ps. John, I really appreciate movement on this. We really need this to 
improve Firefox memory usage + startup speed on low memory devices. Will 
be great to have Firefox start faster+ respond to memory pressure better 
on desktop Linux too.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
