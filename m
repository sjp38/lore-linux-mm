Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 630F96B0390
	for <linux-mm@kvack.org>; Tue, 28 Mar 2017 09:19:04 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id p50so56953757qtc.9
        for <linux-mm@kvack.org>; Tue, 28 Mar 2017 06:19:04 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c15si3434212qtb.14.2017.03.28.06.19.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Mar 2017 06:19:03 -0700 (PDT)
Date: Tue, 28 Mar 2017 15:18:54 +0200
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: Bisected softirq accounting issue in v4.11-rc1~170^2~28
Message-ID: <20170328151854.5c50dbd4@redhat.com>
In-Reply-To: <20170328130602.GA4216@lerouge>
References: <20170328101403.34a82fbf@redhat.com>
	<CANRm+Cwb3uAiZdufqDsyzQ1GZYh3nUr2uTyg1Hb2oVoxJZKMvg@mail.gmail.com>
	<20170328122642.dhw2zkjbghfw4fzn@hirez.programming.kicks-ass.net>
	<20170328130602.GA4216@lerouge>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Frederic Weisbecker <fweisbec@gmail.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Wanpeng Li <kernellwp@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>, Tariq Toukan <tariqt@mellanox.com>, Tariq Toukan <ttoukan.linux@gmail.com>, Rik van Riel <riel@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, brouer@redhat.com

On Tue, 28 Mar 2017 15:06:04 +0200
Frederic Weisbecker <fweisbec@gmail.com> wrote:

> On Tue, Mar 28, 2017 at 02:26:42PM +0200, Peter Zijlstra wrote:
> > On Tue, Mar 28, 2017 at 06:34:52PM +0800, Wanpeng Li wrote:  
> > > 
> > > sched_clock_cpu(cpu) should be converted from cputime to ns.  
> > 
> > Uhm, no. sched_clock_cpu() returns u64 in ns.  
> 
> Yes, and most of the cputime_t have been converted to u64 so there
> should be no such conversion issue between u64 and cputime_t anymore.
> 
> Perhaps my commit has another side effect on softirq time accounting,
> I'll see if I can reproduce.

(Disclaimer without knowing anything about the scheduler code)
my theory is that irqtime_account_irq() does not get invoked often
enough, as in my pktgen "overload" use-case keeps softirq always
running. And your change moved updating cpustat[CPUTIME_SOFTIRQ] here.
Before it got updated by account_other_time() which gets invoked from
irqtime_account_process_tick().

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
