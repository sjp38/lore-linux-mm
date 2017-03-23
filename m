Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id B98C56B0344
	for <linux-mm@kvack.org>; Thu, 23 Mar 2017 11:29:51 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id r89so77419295pfi.1
        for <linux-mm@kvack.org>; Thu, 23 Mar 2017 08:29:51 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id z66si4275864pfb.389.2017.03.23.08.29.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Mar 2017 08:29:50 -0700 (PDT)
Date: Thu, 23 Mar 2017 08:29:49 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [4.11-rc3] BUG: sleeping function called from invalid context at
 mm/vmalloc.c:1480
Message-ID: <20170323152949.GA29134@bombadil.infradead.org>
References: <201703232349.BGB95898.QHLVFFOMtFOOJS@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201703232349.BGB95898.QHLVFFOMtFOOJS@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org

On Thu, Mar 23, 2017 at 11:49:06PM +0900, Tetsuo Handa wrote:
> [    2.609598] [drm] Initialized vmwgfx 2.12.0 20170221 for 0000:00:0f.0 on minor 0
> [    2.616064] BUG: sleeping function called from invalid context at mm/vmalloc.c:1480
[...]
> [    2.616289]  __might_sleep+0x4a/0x80
> [    2.616293]  remove_vm_area+0x22/0x90
> [    2.616296]  __vunmap+0x2e/0x110
> [    2.616299]  vfree+0x42/0x90
> [    2.616304]  kvfree+0x2c/0x40
> [    2.616312]  drm_ht_remove+0x1a/0x30 [drm]
> [    2.616317]  ttm_object_file_release+0x50/0x90 [ttm]

ttm_object_file_release() takes a spinlock, calls drm_ht_remove() which
calls kvfree().

Can somebody remind me what exactly might sleep in remove_vm_area()?
Is it the cache flush on some architectures?  It'd be really nice for
vfree() to be callable from atomic context.

Assuming we can't get rid of the thing which might sleep in
remove_vm_area(), I think we should add a might_sleep() in kvfree().
We need that big warning there so we don't get hard to debug problems
when kvmalloc had to fall back to vmalloc().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
