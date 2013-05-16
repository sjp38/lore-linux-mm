Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 6FAD96B0033
	for <linux-mm@kvack.org>; Thu, 16 May 2013 13:24:40 -0400 (EDT)
Date: Thu, 16 May 2013 19:24:00 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: Summary of LSF-MM Volatile Ranges Discussion
Message-ID: <20130516172400.GQ5181@redhat.com>
References: <516EE256.2070303@linaro.org>
 <5175FBEB.4020809@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5175FBEB.4020809@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Stultz <john.stultz@linaro.org>
Cc: lsf@lists.linux-foundation.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Dmitry Vyukov <dvyukov@google.com>, Paul Turner <pjt@google.com>, Robert Love <rlove@google.com>, Dave Hansen <dave@sr71.net>, Taras Glek <tglek@mozilla.com>, Mike Hommey <mh@glandium.org>, Kostya Serebryany <kcc@google.com>, Hugh Dickins <hughd@google.com>, Michel Lespinasse <walken@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, gthelen@google.com, Rik van Riel <riel@redhat.com>, glommer@parallels.com, mhocko@suse.de

Hi John,

On Mon, Apr 22, 2013 at 08:11:39PM -0700, John Stultz wrote:
> with that range mapped).  I re-iterated the example of a large circular 
> buffer in a shared file, which is initialized as entirely volatile. Then 
> a producer process would mark a region after the head as non-volatile, 
> then fill it with data. And a consumer process, then consumes data from 
> the tail, and mark those consumed ranges as volatile.

If the backing filesystem isn't tmpfs: what is the point of shrinking
the pagecache of the circular buffer before other pagecache? How can
you be sure the LRU isn't going to do a better job?

If the pagecache of the circular buffer is evicted, the next time the
circular buffer overflows and you restart from the head of the buffer,
you risk to hit a page-in from disk, instead of working in RAM without
page-ins.

Or do you trigger a sigbus for filebacked pages too, and somehow avoid
the suprious page-in caused by the volatile pagecache eviction?

And if this is tmpfs and you keep the semantics the same for all
filesystems: unmapping the page won't free memory and it won't provide
any relevant benefit. It might help a bit if you drop the dirty bit
but only during swapping.

It would be a whole lot different if you created an _hole_ in the
file.

It also would make more sense if you only worked at the
pagetable/process level (not at the inode/pagecache level) and you
didn't really control which pages are evicted, but you only unmapped
the pages and let the LRU decide later, just like if it was anonymous
memory.

If you only unmap the filebacked pages without worrying about their
freeing, then it behaves the same as MADV_DONTNEED, and it'd drop the
dirty bit, the mapping and that's it. After the pagecache is unmapped,
it is also freed much quicker than mapped pagecache, so it would make
sense for your objectives.

If you associate the volatility to the inode and not to the process
"mm", I think you need to create an hole when the pagecache is
evicted, so it becomes more useful with tmpfs and the above circular
buffer example.

If you don't create an hole in the file, and you alter the LRU order
in actually freeing the pagecache, this becomes an userland hint to
the VM, that overrides the LRU order of pagecache shrinking which may
backfire. I doubt userland knows better which pagecache should be
evicted first to avoid spurious page-ins on next fault. I mean you at
least need to be sure the next fault won't trigger a spurious swap-in.

> I noted that first of all, the shared volatility is needed to match the 
> Android ashmem semantics. So there's at least an existing user. And that 
> while this method pointed out could be used, I still felt it is fairly 

Could you get in more detail of how Android is using the file
volatility?

The MADV_USERFAULT feature to offload anonymous memory to remote nodes
in combination with remap_anon_pages (to insert/remove memory)
resembles somewhat the sigbus fault triggered by evicted volatile
pages. So ideally the sigbus entry points should be shared by both
missing volatile pages and MADV_USERFAULT, to have a single branch in
the fast paths.

You can see the MADV_USERFAULT page fault entry points here in 1/4:

    http://thread.gmane.org/gmane.comp.emulators.qemu/210231

(I actually intended to add linux-mm, I'll fix the CC list at the next
submit :)

Thanks!
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
