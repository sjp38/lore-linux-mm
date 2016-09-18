Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 93B2C6B0069
	for <linux-mm@kvack.org>; Sun, 18 Sep 2016 16:58:13 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id r126so220292625oib.2
        for <linux-mm@kvack.org>; Sun, 18 Sep 2016 13:58:13 -0700 (PDT)
Received: from mail-oi0-x22d.google.com (mail-oi0-x22d.google.com. [2607:f8b0:4003:c06::22d])
        by mx.google.com with ESMTPS id 81si17133052otd.234.2016.09.18.13.58.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 18 Sep 2016 13:58:12 -0700 (PDT)
Received: by mail-oi0-x22d.google.com with SMTP id a62so38585038oib.1
        for <linux-mm@kvack.org>; Sun, 18 Sep 2016 13:58:12 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160918202614.GB31286@lucifer>
References: <CA+55aFwu30Yz52yW+MRHt_JgpqZkq4DHdWR-pX4+gO_OK7agCQ@mail.gmail.com>
 <20160918202614.GB31286@lucifer>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sun, 18 Sep 2016 13:58:12 -0700
Message-ID: <CA+55aFy0o7B1eLMKaM37dK9PKfKCuyJKxsqK=G+Eno18dPW-CQ@mail.gmail.com>
Subject: Re: More OOM problems
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lorenzo Stoakes <lstoakes@gmail.com>
Cc: Michal Hocko <mhocko@kernel.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Oleg Nesterov <oleg@redhat.com>, Vladimir Davydov <vdavydov@parallels.com>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Markus Trippelsdorf <markus@trippelsdorf.de>, Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>, Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>, Jiri Slaby <jslaby@suse.com>, Olaf Hering <olaf@aepfle.de>, Joonsoo Kim <js1304@gmail.com>, linux-mm <linux-mm@kvack.org>

On Sun, Sep 18, 2016 at 1:26 PM, Lorenzo Stoakes <lstoakes@gmail.com> wrote:
>
> I encountered this even after applying the patch discussed in the
> original thread at https://lkml.org/lkml/2016/8/22/184.  It's not easily
> reproducible but it is happening enough that I could probably check some
> specific state when it next occurs or test out a patch to see if it
> stops it if that'd be useful.

Since you can at least try to recreate it, how about the series in -mm
by Vlastimil? The series was called "reintroduce compaction feedback
for OOM decisions", and is in -mm right now:

  Vlastimil Babka (4):
    Revert "mm, oom: prevent premature OOM killer invocation for high
order request"
    mm, compaction: more reliably increase direct compaction priority
    mm, compaction: restrict full priority to non-costly orders
    mm, compaction: make full priority ignore pageblock suitability

I'm not sure if Andrew has any other ones pending that are relevant to oom.

A lot of the oom discussion seemed to be about the task stack
allocation (order-2), but kmalloc() really can and does trigger those
order-3 allocations even for small allocations.

Just as an example, these are the slab entries for me that are order-3:

  bio-1, UDPv6, TCPv6, kcopyd_job, dm_uevent, mqueue_inode_cache,
  ext4_inode_cache, pid_namespace, PING, UDP, TCP, request_queue,
  net_namespace, bdev_cache, mm_struct, signal_cache, sighand_cache,
  task_struct, idr_layer_cache, dma-kmalloc-8192, dma-kmalloc-4096,
  dma-kmalloc-2048, dma-kmalloc-1024, kmalloc-8192, kmalloc-4096,
  kmalloc-2048, kmalloc-1024

and most of those are 1-2kB in size.

Of course, any slab allocation failure is harder to trigger just
because slab itself ends up often having empty cache entries, so only
a small percentage makes it to the page allocator itself. But the page
allocator failure case really needs to treat PAGE_ALLOC_COSTLY_ORDER
specially.

Which implies that if compaction is magical for page allocation
success, then compaction needs to do so too.

             Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
