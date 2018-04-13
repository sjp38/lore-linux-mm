Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id E34026B0007
	for <linux-mm@kvack.org>; Fri, 13 Apr 2018 04:46:52 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id 203so4444220pfz.19
        for <linux-mm@kvack.org>; Fri, 13 Apr 2018 01:46:52 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 94-v6si5089815ple.56.2018.04.13.01.46.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 13 Apr 2018 01:46:51 -0700 (PDT)
Subject: Re: [PATCH] mm, slab: reschedule cache_reap() on the same CPU
References: <20180410081531.18053-1-vbabka@suse.cz>
 <20180411070007.32225-1-vbabka@suse.cz>
 <20180412004747.GA253442@rodete-desktop-imager.corp.google.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <41acaf67-cf4c-e5b2-97e4-2d7d5a383ffb@suse.cz>
Date: Fri, 13 Apr 2018 10:44:51 +0200
MIME-Version: 1.0
In-Reply-To: <20180412004747.GA253442@rodete-desktop-imager.corp.google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>, Tejun Heo <tj@kernel.org>, Lai Jiangshan <jiangshanlai@gmail.com>, John Stultz <john.stultz@linaro.org>, Thomas Gleixner <tglx@linutronix.de>, Stephen Boyd <sboyd@kernel.org>

On 04/12/2018 02:47 AM, Minchan Kim wrote:
> On Wed, Apr 11, 2018 at 09:00:07AM +0200, Vlastimil Babka wrote:
>> cache_reap() is initially scheduled in start_cpu_timer() via
>> schedule_delayed_work_on(). But then the next iterations are scheduled via
>> schedule_delayed_work(), i.e. using WORK_CPU_UNBOUND.
>>
>> Thus since commit ef557180447f ("workqueue: schedule WORK_CPU_UNBOUND work on
>> wq_unbound_cpumask CPUs") there is no guarantee the future iterations will run
>> on the originally intended cpu, although it's still preferred. I was able to
>> demonstrate this with /sys/module/workqueue/parameters/debug_force_rr_cpu.
>> IIUC, it may also happen due to migrating timers in nohz context. As a result,
>> some cpu's would be calling cache_reap() more frequently and others never.
>>
>> This patch uses schedule_delayed_work_on() with the current cpu when scheduling
>> the next iteration.
> 
> Could you write down part about "so what's the user effect on some condition?".
> It would really help to pick up the patch.

Ugh, so let's continue the last paragraph with something like:

After this patch, cache_reap() executions will always remain on the
expected cpu. This can save some memory that could otherwise remain
indefinitely in array caches of some cpus or nodes, and prevent waste of
cpu cycles by executing cache_reap() too often on other cpus.
