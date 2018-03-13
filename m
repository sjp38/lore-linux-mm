Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f200.google.com (mail-ua0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id E30606B0007
	for <linux-mm@kvack.org>; Tue, 13 Mar 2018 15:46:11 -0400 (EDT)
Received: by mail-ua0-f200.google.com with SMTP id m4so541301uad.5
        for <linux-mm@kvack.org>; Tue, 13 Mar 2018 12:46:11 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id 133si367332vkf.177.2018.03.13.12.46.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Mar 2018 12:46:10 -0700 (PDT)
Date: Tue, 13 Mar 2018 15:45:46 -0400
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: Re: [v5 1/2] mm: disable interrupts while initializing deferred pages
Message-ID: <20180313194546.k62tni4g4gnds2nx@xakep.localdomain>
References: <20180309220807.24961-1-pasha.tatashin@oracle.com>
 <20180309220807.24961-2-pasha.tatashin@oracle.com>
 <20180312130410.e2fce8e5e38bc2086c7fd924@linux-foundation.org>
 <20180313160430.hbjnyiazadt3jwa6@xakep.localdomain>
 <20180313115549.7badec1c6b85eb5a1cf21eb6@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180313115549.7badec1c6b85eb5a1cf21eb6@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, m.mizuma@jp.fujitsu.com, mhocko@suse.com, catalin.marinas@arm.com, takahiro.akashi@linaro.org, gi-oh.kim@profitbricks.com, heiko.carstens@de.ibm.com, baiyaowei@cmss.chinamobile.com, richard.weiyang@gmail.com, paul.burton@mips.com, miles.chen@mediatek.com, vbabka@suse.cz, mgorman@suse.de, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

> > 
> > We must remove cond_resched() because we can't sleep anymore. They were
> > added to fight NMI timeouts, so I will replace them with
> > touch_nmi_watchdog() in a follow-up fix.
> 
> This makes no sense.  Any code section where we can add cond_resched()
> was never subject to NMI timeouts because that code cannot be running with
> disabled interrupts.
> 

Hi Andrew,

I was talking about this patch:

9b6e63cbf85b89b2dbffa4955dbf2df8250e5375
mm, page_alloc: add scheduling point to memmap_init_zone

Which adds cond_resched() to memmap_init_zone() to avoid NMI timeouts.

memmap_init_zone() is used both, early in boot, when non-deferred struct
pages are initialized, but also may be used later, during memory hotplug.

As I understand, the later case could cause the timeout on non-preemptible
kernels.

My understanding, is that the same logic was used here when cond_resched()s
were added.

Please correct me if I am wrong.

Thank you,
Pavel
