Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 11F606B0032
	for <linux-mm@kvack.org>; Tue, 13 Aug 2013 19:44:57 -0400 (EDT)
Message-ID: <520AC4F7.9090604@tilera.com>
Date: Tue, 13 Aug 2013 19:44:55 -0400
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
> It won't nest and doing it simultaneously won't buy anything, right?
> Wouldn't it be better to protect it with a mutex and define all
> necessary resources statically (yeah, cpumask is pain in the ass and I
> think we should un-deprecate cpumask_t for static use cases)?  Then,
> there'd be no allocation to worry about on the path.

Here's what lru_add_drain_all() looks like with a guarding mutex.
Pretty much the same code complexity as when we have to allocate the
cpumask, and there really aren't any issues from locking, since we can assume
all is well and return immediately if we fail to get the lock.

int lru_add_drain_all(void)
{
        static struct cpumask mask;
        static DEFINE_MUTEX(lock);
        int cpu, rc;

        if (!mutex_trylock(&lock))
                return 0;  /* already ongoing elsewhere */

        cpumask_clear(&mask);
        get_online_cpus();

        /*
         * Figure out which cpus need flushing.  It's OK if we race
         * with changes to the per-cpu lru pvecs, since it's no worse
         * than if we flushed all cpus, since a cpu could still end
         * up putting pages back on its pvec before we returned.
         * And this avoids interrupting other cpus unnecessarily.
         */
        for_each_online_cpu(cpu) {
                if (pagevec_count(&per_cpu(lru_add_pvec, cpu)) ||
                    pagevec_count(&per_cpu(lru_rotate_pvecs, cpu)) ||
                    pagevec_count(&per_cpu(lru_deactivate_pvecs, cpu)) ||
                    need_activate_page_drain(cpu))
                        cpumask_set_cpu(cpu, &mask);
        }

        rc = schedule_on_cpu_mask(lru_add_drain_per_cpu, &mask);

        put_online_cpus();
        mutex_unlock(&lock);
        return rc;
}

-- 
Chris Metcalf, Tilera Corp.
http://www.tilera.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
