Message-ID: <4703EBE0.7080106@sgi.com>
Date: Wed, 03 Oct 2007 12:22:08 -0700
From: Mike Travis <travis@sgi.com>
MIME-Version: 1.0
Subject: Re: [PATCH 08/10] ia64: Convert cpu_sibling_map to a per_cpu data
 array (v3)
References: <20070912015644.927677070@sgi.com>	<20070912015647.214306428@sgi.com> <20070928024901.24ab6c99.pj@sgi.com>
In-Reply-To: <20070928024901.24ab6c99.pj@sgi.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: akpm@linux-foundation.org, ak@suse.de, clameter@sgi.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org, sparclinux@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi Paul,

I just now found this.  I'll take a look immediately.  I tried it
on a couple of systems but not margin. 

Thanks,
Mike

Paul Jackson wrote:
> Mike,
> 
> I think there is a bug either in this ia64 patch, or in the related
> generic arch patch: Convert cpu_sibling_map to be a per cpu variable
> (v3).
> 
> It dies early in boot on me, on the SGI internal 8 processor IA64
> system that you and I know as 'margin'.  The death is a hard hang, due
> to a corrupt stack, due to a bogus cpu index.
> 
> I haven't tracked it down all the way, but have gotten this far.  If I add
> the following patch, I get a panic on the BUG_ON if I have these two patches
> in 2.6.23-rc8-mm1, but it boots just fine if I don't have these two patches.
> 
> It seems that the "cpu_sibling_map[cpu]" cpumask_t is empty (all zero
> bits) with your two patches applied, but has some non-zero bits
> otherwise, which leads to 'group' being NR_CPUS instead of a useful CPU
> number.  Unfortunately, I have no idea why the "cpu_sibling_map[cpu]"
> cpumask_t is empty -- good luck on that part.
> 
> The patch that catches this bug earlier is this:
> 
> --- 2.6.23-rc8-mm1.orig/kernel/sched.c	2007-09-28 01:42:20.144561024 -0700
> +++ 2.6.23-rc8-mm1/kernel/sched.c	2007-09-28 02:27:14.239075497 -0700
> @@ -5905,6 +5905,7 @@ static int cpu_to_phys_group(int cpu, co
>  #else
>  	group = cpu;
>  #endif
> +	BUG_ON(group == NR_CPUS);
>  	if (sg)
>  		*sg = &per_cpu(sched_group_phys, group);
>  	return group;
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
