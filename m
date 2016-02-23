Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 79EC882F69
	for <linux-mm@kvack.org>; Mon, 22 Feb 2016 19:54:38 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id fy10so99820658pac.1
        for <linux-mm@kvack.org>; Mon, 22 Feb 2016 16:54:38 -0800 (PST)
Received: from mail-pa0-x236.google.com (mail-pa0-x236.google.com. [2607:f8b0:400e:c03::236])
        by mx.google.com with ESMTPS id d83si43181986pfb.108.2016.02.22.16.54.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Feb 2016 16:54:37 -0800 (PST)
Received: by mail-pa0-x236.google.com with SMTP id ho8so102634422pac.2
        for <linux-mm@kvack.org>; Mon, 22 Feb 2016 16:54:37 -0800 (PST)
Date: Mon, 22 Feb 2016 16:54:35 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: add MM_SWAPENTS and page table when calculate tasksize
 in lowmem_scan()
In-Reply-To: <56C569EC.7070107@huawei.com>
Message-ID: <alpine.DEB.2.10.1602221650210.4688@chino.kir.corp.google.com>
References: <56C2EDC1.2090509@huawei.com> <20160216173849.GA10487@kroah.com> <alpine.DEB.2.10.1602161629560.19997@chino.kir.corp.google.com> <56C569EC.7070107@huawei.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, arve@android.com, riandrews@android.com, devel@driverdev.osuosl.org, zhong jiang <zhongjiang@huawei.com>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>

On Thu, 18 Feb 2016, Xishi Qiu wrote:

> Does somebody do the work of re-implementation of the lowmem killer entirely
> now? Could you give me some details? e.g. when and how?
> 

I don't know of any plans or anybody working on reimplementing it to be 
correct, I simply don't think we should pile more patches on top of an 
already broken design.

> Here are another two questions.
> 1) lmk has several lowmem thresholds, it's "lowmem_minfree[]", and the value is
> static definition, so is it reasonable for different memory size(e.g. 2G/3G/4G...)
> of smart phones?

It looks like it is configurable from userspace and actually defaults to 
6MB, 8MB, 16MB, and 64MB in the kernel.  Reimplementing the lmk would have 
to take this design decision into consideration and replace it with 
something that would not cause existing userspace to break.

A sane implementation would be to do what vmpressure does in the kernel, 
and that is to signal userspace when certain thresholds are met.  
Userspace could then issue a SIGKILL to processes based on priority 
(/proc/pid/oom_score_adj is world-readable by default) and the oom killer 
will grant these processes access to memory reserves immediately if they 
cannot allocate the memory needed to exit.

> 2) There are many adjustable arguments in /proc/sys/vm/, and the default value
> maybe not benefit for smart phones, so any suggestions?
> 

I would assume that vm sysctls, like any other sysctls, would be tuned 
with initscripts depending on the configuration, if necessary.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
