Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id 94EDC6B0032
	for <linux-mm@kvack.org>; Wed, 14 Aug 2013 13:18:34 -0400 (EDT)
Message-ID: <520BBBE7.7020302@tilera.com>
Date: Wed, 14 Aug 2013 13:18:31 -0400
From: Chris Metcalf <cmetcalf@tilera.com>
MIME-Version: 1.0
Subject: Re: [PATCH v7 2/2] mm: make lru_add_drain_all() selective
References: <520AAF9C.1050702@tilera.com> <201308132307.r7DN74M5029053@farm-0021.internal.tilera.com> <20130813232904.GJ28996@mtj.dyndns.org> <520AC215.4050803@tilera.com> <20130813234629.4ce2ec70.akpm@linux-foundation.org> <520BAA5B.9070407@tilera.com> <20130814165723.GE28628@htj.dyndns.org>
In-Reply-To: <20130814165723.GE28628@htj.dyndns.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Frederic Weisbecker <fweisbec@gmail.com>, Cody P Schafer <cody@linux.vnet.ibm.com>

On 8/14/2013 12:57 PM, Tejun Heo wrote:
> Hello, Chris.
>
> On Wed, Aug 14, 2013 at 12:03:39PM -0400, Chris Metcalf wrote:
>> Tejun, I don't know if you have a better idea for how to mark a
>> work_struct as being "not used" so we can set and test it here.
>> Is setting entry.next to NULL good?  Should we offer it as an API
>> in the workqueue header?
> Maybe simply defining a static cpumask would be cleaner?

I think you're right, actually.  Andrew, Tejun, how does this look?


static DEFINE_PER_CPU(struct work_struct, lru_add_drain_work);

void lru_add_drain_all(void)
{
        static DEFINE_MUTEX(lock);
        static struct cpumask has_work;
        int cpu;

        mutex_lock(&lock);
        get_online_cpus();
        cpumask_clear(&has_work);

        for_each_online_cpu(cpu) {
                struct work_struct *work = &per_cpu(lru_add_drain_work, cpu);

                if (pagevec_count(&per_cpu(lru_add_pvec, cpu)) ||
                    pagevec_count(&per_cpu(lru_rotate_pvecs, cpu)) ||
                    pagevec_count(&per_cpu(lru_deactivate_pvecs, cpu)) ||
                    need_activate_page_drain(cpu)) {
                        INIT_WORK(work, lru_add_drain_per_cpu);
                        schedule_work_on(cpu, work);
                        cpumask_set_cpu(cpu, &has_work);
                }
        }

        for_each_cpu(cpu, &has_work)
                flush_work(&per_cpu(lru_add_drain_work, cpu));

        put_online_cpus();
        mutex_unlock(&lock);
}

-- 
Chris Metcalf, Tilera Corp.
http://www.tilera.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
