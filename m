Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id DA7E76B0069
	for <linux-mm@kvack.org>; Wed, 19 Oct 2016 07:15:48 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id m193so1041983lfm.7
        for <linux-mm@kvack.org>; Wed, 19 Oct 2016 04:15:48 -0700 (PDT)
Received: from fireflyinternet.com (mail.fireflyinternet.com. [109.228.58.192])
        by mx.google.com with ESMTPS id ev6si12230172wjd.116.2016.10.19.04.15.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Oct 2016 04:15:47 -0700 (PDT)
Date: Wed, 19 Oct 2016 12:15:41 +0100
From: Chris Wilson <chris@chris-wilson.co.uk>
Subject: Re: [PATCH 2/6] mm: mark all calls into the vmalloc subsystem as
 potentially sleeping
Message-ID: <20161019111541.GQ29358@nuc-i3427.alporthouse.com>
References: <1476773771-11470-1-git-send-email-hch@lst.de>
 <1476773771-11470-3-git-send-email-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1476773771-11470-3-git-send-email-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: akpm@linux-foundation.org, joelaf@google.com, jszhang@marvell.com, joaodias@google.com, linux-mm@kvack.org, linux-rt-users@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Oct 18, 2016 at 08:56:07AM +0200, Christoph Hellwig wrote:
> This is how everyone seems to already use them, but let's make that
> explicit.

Ah, found an exception, vmapped stacks:

[  696.928541] BUG: sleeping function called from invalid context at mm/vmalloc.c:615
[  696.928576] in_atomic(): 1, irqs_disabled(): 0, pid: 30521, name: bash
[  696.928590] 1 lock held by bash/30521:
[  696.928600]  #0: [  696.928606]  (vmap_area_lock[  696.928619] ){+.+...}, at: [  696.928640] [<ffffffff8115f0cf>] __purge_vmap_area_lazy+0x30f/0x370
[  696.928656] CPU: 0 PID: 30521 Comm: bash Tainted: G        W       4.9.0-rc1+ #124
[  696.928672] Hardware name:                  /        , BIOS PYBSWCEL.86A.0027.2015.0507.1758 05/07/2015
[  696.928690]  ffffc900070f7c70 ffffffff812be1f5 ffff8802750b6680 ffffffff819650a6
[  696.928717]  ffffc900070f7c98 ffffffff810a3216 0000000000004001 ffff8802726e16c0
[  696.928743]  ffff8802726e19a0 ffffc900070f7d08 ffffffff8115f0f3 ffff8802750b6680
[  696.928768] Call Trace:
[  696.928782]  [<ffffffff812be1f5>] dump_stack+0x68/0x93
[  696.928796]  [<ffffffff810a3216>] ___might_sleep+0x166/0x220
[  696.928809]  [<ffffffff8115f0f3>] __purge_vmap_area_lazy+0x333/0x370
[  696.928823]  [<ffffffff8115ea68>] ? vunmap_page_range+0x1e8/0x350
[  696.928837]  [<ffffffff8115f1b3>] free_vmap_area_noflush+0x83/0x90
[  696.928850]  [<ffffffff81160931>] remove_vm_area+0x71/0xb0
[  696.928863]  [<ffffffff81160999>] __vunmap+0x29/0xf0
[  696.928875]  [<ffffffff81160ab9>] vfree+0x29/0x70
[  696.928888]  [<ffffffff81071746>] put_task_stack+0x76/0x120
[  696.928901]  [<ffffffff8109a943>] finish_task_switch+0x163/0x1e0
[  696.928914]  [<ffffffff8109a845>] ? finish_task_switch+0x65/0x1e0
[  696.928928]  [<ffffffff816125f5>] __schedule+0x1f5/0x7c0
[  696.928940]  [<ffffffff81612c28>] schedule+0x38/0x90
[  696.928953]  [<ffffffff810787b1>] do_wait+0x1d1/0x200
[  696.928966]  [<ffffffff810799b1>] SyS_wait4+0x61/0xc0
[  696.928979]  [<ffffffff81076e50>] ? task_stopped_code+0x50/0x50
[  696.928992]  [<ffffffff81618e6e>] entry_SYSCALL_64_fastpath+0x1c/0xb1

[This was triggered by earlier patch to remove the serialisation and add
cond_resched_lock(&vmap_area_lock)]
-Chris

-- 
Chris Wilson, Intel Open Source Technology Centre

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
