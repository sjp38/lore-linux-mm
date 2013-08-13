Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id 745376B0032
	for <linux-mm@kvack.org>; Tue, 13 Aug 2013 19:32:40 -0400 (EDT)
Message-ID: <520AC215.4050803@tilera.com>
Date: Tue, 13 Aug 2013 19:32:37 -0400
From: Chris Metcalf <cmetcalf@tilera.com>
MIME-Version: 1.0
Subject: Re: [PATCH v7 2/2] mm: make lru_add_drain_all() selective
References: <520AAF9C.1050702@tilera.com> <201308132307.r7DN74M5029053@farm-0021.internal.tilera.com> <20130813232904.GJ28996@mtj.dyndns.org>
In-Reply-To: <20130813232904.GJ28996@mtj.dyndns.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Frederic Weisbecker <fweisbec@gmail.com>, Cody P Schafer <cody@linux.vnet.ibm.com>

On 8/13/2013 7:29 PM, Tejun Heo wrote:
> Hello,
>
> On Tue, Aug 13, 2013 at 06:53:32PM -0400, Chris Metcalf wrote:
>>  int lru_add_drain_all(void)
>>  {
>> -	return schedule_on_each_cpu(lru_add_drain_per_cpu);
>> +	return schedule_on_each_cpu_cond(lru_add_drain_per_cpu,
>> +					 lru_add_drain_cond, NULL);
> It won't nest and doing it simultaneously won't buy anything, right?

Correct on both counts, I think.

> Wouldn't it be better to protect it with a mutex and define all
> necessary resources statically (yeah, cpumask is pain in the ass and I
> think we should un-deprecate cpumask_t for static use cases)?  Then,
> there'd be no allocation to worry about on the path.

If allocation is a real problem on this path, I think this is probably
OK, though I don't want to speak for Andrew.  You could just guard it
with a trylock and any caller that tried to start it while it was
locked could just return happy that it was going on.

I'll put out a version that does that and see how that looks
for comparison's sake.

-- 
Chris Metcalf, Tilera Corp.
http://www.tilera.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
