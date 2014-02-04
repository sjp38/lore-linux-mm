Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f43.google.com (mail-pb0-f43.google.com [209.85.160.43])
	by kanga.kvack.org (Postfix) with ESMTP id A3A2E6B0037
	for <linux-mm@kvack.org>; Tue,  4 Feb 2014 16:42:37 -0500 (EST)
Received: by mail-pb0-f43.google.com with SMTP id md12so9014361pbc.16
        for <linux-mm@kvack.org>; Tue, 04 Feb 2014 13:42:37 -0800 (PST)
Received: from mail-pb0-x231.google.com (mail-pb0-x231.google.com [2607:f8b0:400e:c01::231])
        by mx.google.com with ESMTPS id pk8si26212491pab.126.2014.02.04.13.34.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 04 Feb 2014 13:34:34 -0800 (PST)
Received: by mail-pb0-f49.google.com with SMTP id up15so8923425pbc.8
        for <linux-mm@kvack.org>; Tue, 04 Feb 2014 13:34:30 -0800 (PST)
Date: Tue, 4 Feb 2014 13:34:29 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] __set_page_dirty uses spin_lock_irqsave instead of
 spin_lock_irq
In-Reply-To: <1391533776-2425-1-git-send-email-kosaki.motohiro@gmail.com>
Message-ID: <alpine.DEB.2.02.1402041334110.26019@chino.kir.corp.google.com>
References: <1391533776-2425-1-git-send-email-kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kosaki.motohiro@gmail.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, stable@vger.kernel.org

On Tue, 4 Feb 2014, kosaki.motohiro@gmail.com wrote:

> From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> 
> To use spin_{un}lock_irq is dangerous if caller disabled interrupt.
> During aio buffer migration, we have a possibility to see the
> following call stack.
> 
> aio_migratepage  [disable interrupt]
>   migrate_page_copy
>     clear_page_dirty_for_io
>       set_page_dirty
>         __set_page_dirty_buffers
>           __set_page_dirty
>             spin_lock_irq
> 
> This mean, current aio migration is a deadlockable. spin_lock_irqsave
> is a safer alternative and we should use it.
> 
> Reported-by: David Rientjes rientjes@google.com>
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: stable@vger.kernel.org

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
