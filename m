Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 8CDA682F69
	for <linux-mm@kvack.org>; Mon, 22 Feb 2016 19:50:11 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id fl4so99993466pad.0
        for <linux-mm@kvack.org>; Mon, 22 Feb 2016 16:50:11 -0800 (PST)
Received: from mail-pf0-x230.google.com (mail-pf0-x230.google.com. [2607:f8b0:400e:c00::230])
        by mx.google.com with ESMTPS id a84si43157335pfj.109.2016.02.22.16.50.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Feb 2016 16:50:10 -0800 (PST)
Received: by mail-pf0-x230.google.com with SMTP id q63so101574126pfb.0
        for <linux-mm@kvack.org>; Mon, 22 Feb 2016 16:50:10 -0800 (PST)
Date: Mon, 22 Feb 2016 16:50:09 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: add MM_SWAPENTS and page table when calculate tasksize
 in lowmem_scan()
In-Reply-To: <56C59B39.30102@huawei.com>
Message-ID: <alpine.DEB.2.10.1602221647520.4688@chino.kir.corp.google.com>
References: <56C2EDC1.2090509@huawei.com> <20160216173849.GA10487@kroah.com> <alpine.DEB.2.10.1602161629560.19997@chino.kir.corp.google.com> <CAF7GXvqr2dmc7CUcs_OmfYnEA9jE_Db4kGGG1HJyYYLhC6Bgew@mail.gmail.com> <56C59B39.30102@huawei.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: "Figo.zhang" <figo1802@gmail.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, arve@android.com, riandrews@android.com, devel@driverdev.osuosl.org, zhong jiang <zhongjiang@huawei.com>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>

On Thu, 18 Feb 2016, Xishi Qiu wrote:

> How about kill more processes at one time?
> 
> Usually loading camera will alloc 300-500M memory immediately, so call lmk
> repeatedly is a waste of time.
> 
> And can we reclaim memory at one time instead of reclaim-alloc-reclaim-alloc...
> in this situation? e.g. use try_to_free_pages(), set nr_to_reclaim=300M
> 

I don't use the lmk myself and it's never been used on my phone, so I 
can't speak for the usecase.  However, killing more than one process at a 
time is generally a bad idea because it can allow processes to deplete 
memory reserves which may be small on these systems.  The lmk cannot be 
considered a hotpath, so waiting for a process to exit and free its memory 
for a small amount of time is generally not a bad trade-off when the 
alternative is to kill many processes (perhaps unnecessarily), open 
yourself up to livelock, and free memory that is potentially unneeded.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
