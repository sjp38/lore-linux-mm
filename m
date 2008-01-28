Date: Mon, 28 Jan 2008 10:45:20 -0600
From: Paul Jackson <pj@sgi.com>
Subject: Re: [PATCH 4/5] x86: Add config variables for SMP_MAX
Message-Id: <20080128104520.e1e6c878.pj@sgi.com>
In-Reply-To: <479108C3.1010800@sgi.com>
References: <20080118183011.354965000@sgi.com>
	<20080118183011.917801000@sgi.com>
	<200801182104.22486.ioe-lkml@rameria.de>
	<479108C3.1010800@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Travis <travis@sgi.com>
Cc: ioe-lkml@rameria.de, akpm@linux-foundation.org, ak@suse.de, mingo@elte.hu, clameter@sgi.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Ten days ago, Mike wrote:
> The primary problem arises because of cpumask_t local variables.  Until I
> can deal with these, increasing NR_CPUS to a really large value increases
> stack size dramatically.
> 
> Here are the top stack consumers with NR_CPUS = 4k.
> 
>                          16392 isolated_cpu_setup
>                          10328 build_sched_domains

The problem in kernel/sched.c:isolated_cpu_setup() is an array of
NR_CPUS integers:

    static int __init isolated_cpu_setup(char *str)
    {
	    int ints[NR_CPUS], i;

	    str = get_options(str, ARRAY_SIZE(ints), ints);

Since isolated_cpu_setup() is an __init routine, perhaps we could
make that ints[] array static __initdata?

The build_sched_domains() may require more thought and code rework.
See also the lkml discussion of my patches that reworked the cpuset
code implementing 'sched_load_balance' calling into build_sched_domains
() via kernel/sched.c:partition_sched_domains().  This is not performance
critical code, fortunately.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.940.382.4214

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
