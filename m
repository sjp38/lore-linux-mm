Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 5FDFE6B0034
	for <linux-mm@kvack.org>; Mon, 20 May 2013 23:50:38 -0400 (EDT)
Received: by mail-pd0-f180.google.com with SMTP id 10so172679pdc.25
        for <linux-mm@kvack.org>; Mon, 20 May 2013 20:50:37 -0700 (PDT)
Message-ID: <519AEF09.4050302@linaro.org>
Date: Mon, 20 May 2013 20:50:33 -0700
From: John Stultz <john.stultz@linaro.org>
MIME-Version: 1.0
Subject: Re: Summary of LSF-MM Volatile Ranges Discussion
References: <516EE256.2070303@linaro.org> <5175FBEB.4020809@linaro.org> <20130516172400.GQ5181@redhat.com>
In-Reply-To: <20130516172400.GQ5181@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: lsf@lists.linux-foundation.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Dmitry Vyukov <dvyukov@google.com>, Paul Turner <pjt@google.com>, Robert Love <rlove@google.com>, Dave Hansen <dave@sr71.net>, Taras Glek <tglek@mozilla.com>, Mike Hommey <mh@glandium.org>, Kostya Serebryany <kcc@google.com>, Hugh Dickins <hughd@google.com>, Michel Lespinasse <walken@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, gthelen@google.com, Rik van Riel <riel@redhat.com>, glommer@parallels.com, mhocko@suse.deTaras Glek <tglek@mozilla.com>Mike Hommey <mh@glandium.org>

On 05/16/2013 10:24 AM, Andrea Arcangeli wrote:
> Hi John,
>
> On Mon, Apr 22, 2013 at 08:11:39PM -0700, John Stultz wrote:
>> with that range mapped).  I re-iterated the example of a large circular
>> buffer in a shared file, which is initialized as entirely volatile. Then
>> a producer process would mark a region after the head as non-volatile,
>> then fill it with data. And a consumer process, then consumes data from
>> the tail, and mark those consumed ranges as volatile.
> If the backing filesystem isn't tmpfs: what is the point of shrinking
> the pagecache of the circular buffer before other pagecache? How can
> you be sure the LRU isn't going to do a better job?
So, tmpfs is really the main target for shared volatile ranges in my 
mind. But if you were using non-tmpfs files, you could end up possibly 
saving disk writes by purging dirty data instead of writing it out. Now, 
we'd still need to punch a hole in the file in order to be consistent 
(don't want to old data to persist there if we purged it), but depending 
on the fs it may be cheaper to punch a hole then write out lots of dirty 
data.

But again, tmpfs is really the main target here.


> If the pagecache of the circular buffer is evicted, the next time the
> circular buffer overflows and you restart from the head of the buffer,
> you risk to hit a page-in from disk, instead of working in RAM without
> page-ins.
>
> Or do you trigger a sigbus for filebacked pages too, and somehow avoid
> the suprious page-in caused by the volatile pagecache eviction?

There would be a SIGBUS, but after the range is marked non-volatile, if 
a read is done immediately after, that could trigger a page-in. If it 
was written to immediately, I suspect we'd avoid it. But this example 
isn't one I've looked at in particular.


> And if this is tmpfs and you keep the semantics the same for all
> filesystems: unmapping the page won't free memory and it won't provide
> any relevant benefit. It might help a bit if you drop the dirty bit
> but only during swapping.
>
> It would be a whole lot different if you created an _hole_ in the
> file.
Right. When we purge pages it should be the same as punching a hole 
(we're using truncate_inode_pages_range).


> It also would make more sense if you only worked at the
> pagetable/process level (not at the inode/pagecache level) and you
> didn't really control which pages are evicted, but you only unmapped
> the pages and let the LRU decide later, just like if it was anonymous
> memory.
>
> If you only unmap the filebacked pages without worrying about their
> freeing, then it behaves the same as MADV_DONTNEED, and it'd drop the
> dirty bit, the mapping and that's it. After the pagecache is unmapped,
> it is also freed much quicker than mapped pagecache, so it would make
> sense for your objectives.

Hmmm. I'll have to consider this further. Ideally I think we'd like the 
purging to be done by the LRU (the one problem is that anonymous pages 
aren't normally aged off the lru when we don't have swap - thus 
Minchan's use of a shrinker to force anonymous page purging). But it 
sounds like you're suggesting we do it in two steps. One, purge via 
shrinker and unmap the pages, then allow the eviction to be done by the 
LRU.  I'm not sure how that would work with the hole-punching, but I'll 
have to look closer.


> If you associate the volatility to the inode and not to the process
> "mm", I think you need to create an hole when the pagecache is
> evicted, so it becomes more useful with tmpfs and the above circular
> buffer example.
So, for shared volatility, we do associate it with the address_space. 
For private volatility, its associated with the mm.


> If you don't create an hole in the file, and you alter the LRU order
> in actually freeing the pagecache, this becomes an userland hint to
> the VM, that overrides the LRU order of pagecache shrinking which may
> backfire. I doubt userland knows better which pagecache should be
> evicted first to avoid spurious page-ins on next fault. I mean you at
> least need to be sure the next fault won't trigger a spurious swap-in.
>
>> I noted that first of all, the shared volatility is needed to match the
>> Android ashmem semantics. So there's at least an existing user. And that
>> while this method pointed out could be used, I still felt it is fairly
> Could you get in more detail of how Android is using the file
> volatility?
>
> The MADV_USERFAULT feature to offload anonymous memory to remote nodes
> in combination with remap_anon_pages (to insert/remove memory)
> resembles somewhat the sigbus fault triggered by evicted volatile
> pages. So ideally the sigbus entry points should be shared by both
> missing volatile pages and MADV_USERFAULT, to have a single branch in
> the fast paths.
>
> You can see the MADV_USERFAULT page fault entry points here in 1/4:
>
>      http://thread.gmane.org/gmane.comp.emulators.qemu/210231

As far as the entry-points, I suspect you mean just the vma_flag check? 
I'm somewhat skeptical. Minchan's trick of checking a pte flag on fault 
to see if the page was purged seems pretty nice to me (though I haven't 
managed to work out the flag for file pages yet - currently using a 
stupid lookup on fault instead for now, as we work out the interface 
semantics). Though maybe Minchan's pte flag approach might work for your 
case?

But I'll have to look closer at this. Taras @ Mozilla pointed me to it 
earlier and I thought the notification was vaguely similar.

MikeH: Do you have any thoughts as to if the file polling done in the 
description below make sense instead of using SIGBUS?
http://lists.gnu.org/archive/html/qemu-devel/2012-10/msg05274.html

I worry the handling is somewhat cross-process w/ the poling method, it 
might make it too complex, esp with private volatility on anonymous 
pages (ie: what backs that isn't going to be known by a different process).

thanks
-john


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
