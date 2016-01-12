From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [RFC][4.1.15-rt17 PATCH] mm: swap: lru drain don't use workqueue
 with PREEMPT_RT_FULL
Date: Tue, 12 Jan 2016 13:01:09 +0100 (CET)
Message-ID: <alpine.DEB.2.11.1601121255240.3575@nanos>
References: <1452473001-10518-1-git-send-email-l@dorileo.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452473001-10518-1-git-send-email-l@dorileo.org>
Sender: linux-kernel-owner@vger.kernel.org
To: l@dorileo.org
Cc: Sebastian Andrzej Siewior <bigeasy@linutronix.de>, LKML <linux-kernel@vger.kernel.org>, rostedt@goodmis.org, John Kacur <jkacur@redhat.com>, linux-mm@kvack.org, Leandro Dorileo <leandro.maciel.dorileo@intel.com>
List-Id: linux-mm.kvack.org

On Sun, 10 Jan 2016, l@dorileo.org wrote:
> +#ifdef CONFIG_PREEMPT_RT_FULL
> +void lru_add_drain_all(void)
> +{
> +	static DEFINE_MUTEX(lock);
> +	int cpu;
> +
> +	mutex_lock(&lock);
> +	get_online_cpus();
> +
> +	for_each_online_cpu(cpu) {
> +		smp_call_function_single(cpu, lru_add_drain, NULL, 1);

How is that supposed to work on RT? Not at all, because lru_add_drain() takes
'sleeping' spinlocks and you cannot do that from hard interrupt context.

Enable lockdep (what you should have done before posting) and watch the
fireworks.

Thanks,

	tglx
