Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 866986B0007
	for <linux-mm@kvack.org>; Wed, 27 Jun 2018 08:37:02 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id e11-v6so907735pgt.19
        for <linux-mm@kvack.org>; Wed, 27 Jun 2018 05:37:02 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id v21-v6si3591401pgn.371.2018.06.27.05.37.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jun 2018 05:37:01 -0700 (PDT)
Date: Wed, 27 Jun 2018 08:36:57 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH] Revert mm/vmstat.c: fix vmstat_update() preemption BUG
Message-ID: <20180627123657.2hb7ow4szjyhg5aj@home.goodmis.org>
References: <20180411095757.28585-1-bigeasy@linutronix.de>
 <ef663b6d-9e9f-65c6-25ec-ffa88347c58d@suse.cz>
 <20180411140913.GE793541@devbig577.frc2.facebook.com>
 <20180411144221.o3v73v536tpnc6n3@linutronix.de>
 <20180411190729.7sbmbsxtkcng7ddx@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180411190729.7sbmbsxtkcng7ddx@linutronix.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Cc: Tejun Heo <htejun@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, tglx@linutronix.de, "Steven J . Hill" <steven.hill@cavium.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>

On Wed, Apr 11, 2018 at 09:07:30PM +0200, Sebastian Andrzej Siewior wrote:
> 
> This already happens:
> - vmstat_shepherd() does get_online_cpus() and within this block it does
>   queue_delayed_work_on(). So this has to wait until cpuhotplug
>   completed before it can schedule something and then it won't schedule
>   anything on the "off" CPU.

But can't we have something like this happen: ?

	CPU0			CPU1			CPU2
	----			----			----
 get_online_cpus()
 queue_work(vmstat_update, cpu1)
    wakeup(kworker/1)
			     High prio task running
 put_online_cpus()
 						     Shutdown CPU 1
			     migrate kworker/1
 schedule kworker/1
 (smp_processor_id() != 1)

-- Steve
