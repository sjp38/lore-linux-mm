Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f181.google.com (mail-ig0-f181.google.com [209.85.213.181])
	by kanga.kvack.org (Postfix) with ESMTP id AFFAC6B0073
	for <linux-mm@kvack.org>; Wed, 26 Feb 2014 03:43:23 -0500 (EST)
Received: by mail-ig0-f181.google.com with SMTP id h18so214443igc.2
        for <linux-mm@kvack.org>; Wed, 26 Feb 2014 00:43:23 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id ms5si387746icc.133.2014.02.26.00.43.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Feb 2014 00:43:23 -0800 (PST)
Date: Wed, 26 Feb 2014 09:43:04 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: mm: OS boot failed when set command-line kmemcheck=1
Message-ID: <20140226084304.GD18404@twins.programming.kicks-ass.net>
References: <5304558F.9050605@huawei.com>
 <alpine.DEB.2.02.1402182344001.3551@chino.kir.corp.google.com>
 <53047AE6.4060403@huawei.com>
 <alpine.DEB.2.02.1402191422240.31921@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1402191422240.31921@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Xishi Qiu <qiuxishi@huawei.com>, Robert Richter <rric@kernel.org>, Stephane Eranian <eranian@google.com>, Pekka Enberg <penberg@kernel.org>, Vegard Nossum <vegard.nossum@gmail.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Feb 19, 2014 at 02:24:41PM -0800, David Rientjes wrote:
> On Wed, 19 Feb 2014, Xishi Qiu wrote:
> 
> > Here is a warning, I don't whether it is relative to my hardware.
> > If set "kmemcheck=1 nowatchdog", it can boot.
> > 
> > code:
> > 	...
> > 	pte = kmemcheck_pte_lookup(address);
> > 	if (!pte)
> > 		return false;
> > 
> > 	WARN_ON_ONCE(in_nmi());
> > 
> > 	if (error_code & 2)
> > 	...

That code seems to assume NMI context cannot fault; this is false since
a while back (v3.9 or thereabouts).

> > [   10.920757]  [<ffffffff810452c1>] kmemcheck_fault+0xb1/0xc0
> > [   10.920760]  [<ffffffff814d262b>] __do_page_fault+0x39b/0x4c0
> > [   10.920763]  [<ffffffff814d2829>] do_page_fault+0x9/0x10
> > [   10.920765]  [<ffffffff814cf222>] page_fault+0x22/0x30
> > [   10.920774]  [<ffffffff8101eb02>] intel_pmu_handle_irq+0x142/0x3a0
> > [   10.920777]  [<ffffffff814d0655>] perf_event_nmi_handler+0x35/0x60
> > [   10.920779]  [<ffffffff814cfe83>] nmi_handle+0x63/0x150
> > [   10.920782]  [<ffffffff814cffd3>] default_do_nmi+0x63/0x290
> > [   10.920784]  [<ffffffff814d02a8>] do_nmi+0xa8/0xe0
> > [   10.920786]  [<ffffffff814cf527>] end_repeat_nmi+0x1e/0x2e

And this does indeed show a fault from NMI context; which is totally
expected.

kmemcheck needs to be fixed; but I've no clue how any of that works.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
