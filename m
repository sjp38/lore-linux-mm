Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id C542A6B000C
	for <linux-mm@kvack.org>; Tue, 10 Apr 2018 15:42:19 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id 203so7408921pfz.19
        for <linux-mm@kvack.org>; Tue, 10 Apr 2018 12:42:19 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a6-v6si3333508pll.722.2018.04.10.12.42.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 10 Apr 2018 12:42:18 -0700 (PDT)
Subject: Re: [RFC] mm, slab: reschedule cache_reap() on the same CPU
References: <20180410081531.18053-1-vbabka@suse.cz>
 <alpine.DEB.2.20.1804100907160.27333@nuc-kabylake>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <983c61d1-1444-db1f-65c1-3b519ac4d57b@suse.cz>
Date: Tue, 10 Apr 2018 21:40:19 +0200
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1804100907160.27333@nuc-kabylake>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Tejun Heo <tj@kernel.org>, Lai Jiangshan <jiangshanlai@gmail.com>, John Stultz <john.stultz@linaro.org>, Thomas Gleixner <tglx@linutronix.de>, Stephen Boyd <sboyd@kernel.org>

On 04/10/2018 04:12 PM, Christopher Lameter wrote:
> On Tue, 10 Apr 2018, Vlastimil Babka wrote:
> 
>> cache_reap() is initially scheduled in start_cpu_timer() via
>> schedule_delayed_work_on(). But then the next iterations are scheduled via
>> schedule_delayed_work(), thus using WORK_CPU_UNBOUND.
> 
> That is a bug.. cache_reap must run on the same cpu since it deals with
> the per cpu queues of the current cpu. Scheduled_delayed_work() used to
> guarantee running on teh same cpu.

Did it? When did it stop? (which stable kernels should we backport to?)
So is my assumption correct that without specifying a CPU, the next work
might be processed on a different cpu than the current one, *and also*
be executed with a kthread/u* that can migrate to another cpu *in the
middle of the work*? Tejun?

>> This patch makes sure schedule_delayed_work_on() is used with the proper cpu
>> when scheduling the next iteration. The cpu is stored with delayed_work on a
>> new slab_reap_work_struct super-structure.
> 
> The current cpu is readily available via smp_processor_id(). Why a
> super structure?

Mostly for the WARN_ON_ONCE, and general paranoia.

>> @@ -4074,7 +4086,8 @@ static void cache_reap(struct work_struct *w)
>>  	next_reap_node();
>>  out:
>>  	/* Set up the next iteration */
>> -	schedule_delayed_work(work, round_jiffies_relative(REAPTIMEOUT_AC));
>> +	schedule_delayed_work_on(reap_work->cpu, work,
>> +					round_jiffies_relative(REAPTIMEOUT_AC));
> 
> schedule_delayed_work_on(smp_processor_id(), work, round_jiffies_relative(REAPTIMEOUT_AC));
> 
> instead all of the other changes?

If we can rely on that 100%, sure.
