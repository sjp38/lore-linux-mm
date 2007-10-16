Date: Tue, 16 Oct 2007 08:02:21 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 0/1] x86: Convert cpuinfo_x86 array to a per_cpu array
 v3
In-Reply-To: <20071016011827.91350174.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0710160755200.25014@schroedinger.engr.sgi.com>
References: <20070924210853.256462000@sgi.com> <20071016011827.91350174.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: pj@sgi.com
Cc: travis@sgi.com, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org, "Siddha, Suresh B" <suresh.b.siddha@intel.com>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 16 Oct 2007, Andrew Morton wrote:

> On Mon, 24 Sep 2007 14:08:53 -0700 travis@sgi.com wrote:

> > cpu_sibling_map and cpu_core_map have been taken care of in
> > a prior patch.  This patch deals with the cpu_data array of
> > cpuinfo_x86 structs.  The model that was used in sparc64
> > architecture was adopted for x86.
> 
> This has mysteriously started to oops on me, only on x86_64.
> 
> http://userweb.kernel.org/~akpm/config-x.txt
> http://userweb.kernel.org/~akpm/dsc00001.jpg
> 
> which is a bit strange since this patch doesn't touch sched.c.  Maybe
> there's something somewhere else in the -mm lineup which when combined with
> this prevents it from oopsing, dunno.  I'll hold it back for now and will
> see what happens.

The config that you are using has

	CONFIG_SCHED_MC

and 

	CONFIG_SCHED_MT

set.

So we use cpu_corecroup_map() from arch/x86_64/kernel/smpboot.c in
cpu_to_phys_group that has these nice convoluted ifdefs:

static int cpu_to_phys_group(int cpu, const cpumask_t *cpu_map,
                             struct sched_group **sg)
{
        int group;
#ifdef CONFIG_SCHED_MC
        cpumask_t mask = cpu_coregroup_map(cpu);
        cpus_and(mask, mask, *cpu_map);
        group = first_cpu(mask);
#elif defined(CONFIG_SCHED_SMT)
        cpumask_t mask = per_cpu(cpu_sibling_map, cpu);
        cpus_and(mask, mask, *cpu_map);
        group = first_cpu(mask);
#else
        group = cpu;
#endif
        if (sg)
                *sg = &per_cpu(sched_group_phys, group);
        return group;
}

and I guess that some sched domain patches resulted in an empty
nodemask so that we end up with an invalid group number for the sched 
group?


/* maps the cpu to the sched domain representing multi-core */
cpumask_t cpu_coregroup_map(int cpu)
{
        struct cpuinfo_x86 *c = &cpu_data(cpu);
        /*
         * For perf, we return last level cache shared map.
         * And for power savings, we return cpu_core_map
         */
        if (sched_mc_power_savings || sched_smt_power_savings)
                return per_cpu(cpu_core_map, cpu);
        else
                return c->llc_shared_map;
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
