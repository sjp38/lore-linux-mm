Date: Wed, 26 Mar 2008 07:50:23 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 06/10] x86: reduce memory and stack usage in
	intel_cacheinfo
Message-ID: <20080326065023.GG18301@elte.hu>
References: <20080325220650.835342000@polaris-admin.engr.sgi.com> <20080325220651.683748000@polaris-admin.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080325220651.683748000@polaris-admin.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Travis <travis@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

* Mike Travis <travis@sgi.com> wrote:

> * Change the following static arrays sized by NR_CPUS to
>   per_cpu data variables:
> 
> 	_cpuid4_info *cpuid4_info[NR_CPUS];
> 	_index_kobject *index_kobject[NR_CPUS];
> 	kobject * cache_kobject[NR_CPUS];
> 
> * Remove the local NR_CPUS array with a kmalloc'd region in
>   show_shared_cpu_map().

thanks Travis, i've applied this to x86.git.

one observation:

>  static ssize_t show_shared_cpu_map(struct _cpuid4_info *this_leaf, char *buf)
>  {
> -	char mask_str[NR_CPUS];
> -	cpumask_scnprintf(mask_str, NR_CPUS, this_leaf->shared_cpu_map);
> -	return sprintf(buf, "%s\n", mask_str);
> +	int n = 0;
> +	int len = cpumask_scnprintf_len(nr_cpu_ids);
> +	char *mask_str = kmalloc(len, GFP_KERNEL);
> +
> +	if (mask_str) {
> +		cpumask_scnprintf(mask_str, len, this_leaf->shared_cpu_map);
> +		n = sprintf(buf, "%s\n", mask_str);
> +		kfree(mask_str);
> +	}
> +	return n;

the other changes look good, but this one looks a bit ugly and complex. 
We basically want to sprintf shared_cpu_map into 'buf', but we do that 
by first allocating a temporary buffer, print a string into it, then 
print that string into another buffer ...

this very much smells like an API bug in cpumask_scnprintf() - why dont 
you create a cpumask_scnprintf_ptr() API that takes a pointer to a 
cpumask? Then this change would become a trivial and much more readable:

 -	char mask_str[NR_CPUS];
 -	cpumask_scnprintf(mask_str, NR_CPUS, this_leaf->shared_cpu_map);
 -	return sprintf(buf, "%s\n", mask_str);
 +	return cpumask_scnprintf_ptr(buf, NR_CPUS, &this_leaf->shared_cpu_map);

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
