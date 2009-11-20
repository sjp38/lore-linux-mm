Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id CE2696B007D
	for <linux-mm@kvack.org>; Fri, 20 Nov 2009 03:14:52 -0500 (EST)
Date: Fri, 20 Nov 2009 09:14:40 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [RFC][PATCH 1/2] perf: Add 'perf kmem' tool
Message-ID: <20091120081440.GA19778@elte.hu>
References: <4B064AF5.9060208@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4B064AF5.9060208@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: Li Zefan <lizf@cn.fujitsu.com>, Arnaldo Carvalho de Melo <acme@redhat.com>
Cc: Frederic Weisbecker <fweisbec@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, Peter Zijlstra <peterz@infradead.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


* Li Zefan <lizf@cn.fujitsu.com> wrote:

> This tool is mostly a perf version of kmemtrace-user.
> 
> The following information is provided by this tool:
> 
> - the total amount of memory allocated and fragmentation per call-site
> - the total amount of memory allocated and fragmentation per allocation
> - total memory allocated and fragmentation in the collected dataset
> - ...
> 
>  # ./perf kmem record
>  ^C
>  # ./perf kmem --stat caller --stat alloc -l 10
> 
>  ------------------------------------------------------------------------------
>  Callsite          | Total_alloc/Per |  Total_req/Per  |  Hit   | Fragmentation
>  ------------------------------------------------------------------------------
>  0xc052f37a        |   790528/4096   |   790528/4096   |    193 |    0.000%
>  0xc0541d70        |   524288/4096   |   524288/4096   |    128 |    0.000%
>  0xc051cc68        |   481600/200    |   481600/200    |   2408 |    0.000%
>  0xc0572623        |   297444/676    |   297440/676    |    440 |    0.001%
>  0xc05399f1        |    73476/164    |    73472/164    |    448 |    0.005%
>  0xc05243bf        |    51456/256    |    51456/256    |    201 |    0.000%
>  0xc0730d0e        |    31844/497    |    31808/497    |     64 |    0.113%
>  0xc0734c4e        |    17152/256    |    17152/256    |     67 |    0.000%
>  0xc0541a6d        |    16384/128    |    16384/128    |    128 |    0.000%
>  0xc059c217        |    13120/40     |    13120/40     |    328 |    0.000%
>  0xc0501ee6        |    11264/88     |    11264/88     |    128 |    0.000%
>  0xc04daef0        |     7504/682    |     7128/648    |     11 |    5.011%
>  0xc04e14a3        |     4216/191    |     4216/191    |     22 |    0.000%
>  0xc05041ca        |     3524/44     |     3520/44     |     80 |    0.114%
>  0xc0734fa3        |     2104/701    |     1620/540    |      3 |   23.004%
>  0xc05ec9f1        |     2024/289    |     2016/288    |      7 |    0.395%
>  0xc06a1999        |     1792/256    |     1792/256    |      7 |    0.000%
>  0xc0463b9a        |     1584/144    |     1584/144    |     11 |    0.000%
>  0xc0541eb0        |     1024/16     |     1024/16     |     64 |    0.000%
>  0xc06a19ac        |      896/128    |      896/128    |      7 |    0.000%
>  0xc05721c0        |      772/12     |      768/12     |     64 |    0.518%
>  0xc054d1e6        |      288/57     |      280/56     |      5 |    2.778%
>  0xc04b562e        |      157/31     |      154/30     |      5 |    1.911%
>  0xc04b536f        |       80/16     |       80/16     |      5 |    0.000%
>  0xc05855a0        |       64/64     |       36/36     |      1 |   43.750%
>  ------------------------------------------------------------------------------
> 
>  ------------------------------------------------------------------------------
>  Alloc Ptr         | Total_alloc/Per |  Total_req/Per  |  Hit   | Fragmentation
>  ------------------------------------------------------------------------------
>  0xda884000        |  1052672/4096   |  1052672/4096   |    257 |    0.000%
>  0xda886000        |   262144/4096   |   262144/4096   |     64 |    0.000%
>  0xf60c7c00        |    16512/128    |    16512/128    |    129 |    0.000%
>  0xf59a4118        |    13120/40     |    13120/40     |    328 |    0.000%
>  0xdfd4b2c0        |    11264/88     |    11264/88     |    128 |    0.000%
>  0xf5274600        |     7680/256    |     7680/256    |     30 |    0.000%
>  0xe8395000        |     5948/594    |     5464/546    |     10 |    8.137%
>  0xe59c3c00        |     5748/479    |     5712/476    |     12 |    0.626%
>  0xf4cd1a80        |     3524/44     |     3520/44     |     80 |    0.114%
>  0xe5bd1600        |     2892/482    |     2856/476    |      6 |    1.245%
>  ...               | ...             | ...             | ...    | ...
>  ------------------------------------------------------------------------------
> 
> SUMMARY
> =======
> Total bytes requested: 2333626
> Total bytes allocated: 2353712
> Total bytes wasted on internal fragmentation: 20086
> Internal fragmentation: 0.853375%

Very impressive!

> TODO:
> - show sym+offset in 'callsite' column

The way to print symbolic information for the 'callsite' column is to 
fill in and walk the thread->DSO->symbol trees that all perf tools 
maintain:

	/* simplified, without error handling */

	ip = event->ip.ip;

	thread = threads__findnew(event->ip.pid);

	map = thread__find_map(thread, ip);

	ip = map->map_ip(map, ip); /* map absolute RIP into DSO-relative one */

	sym = map__find_symbol(map, ip, symbol_filter);

then sym->name is the string that can be printed out. This works in a 
symmetric way for both kernel-space and user-space symbols. (Call-chain 
information can be captured and displayed too.)

( 'Alloc Ptr' symbolization is harder, but it would be useful too i 
  think, to map it back to the slab cache name. )

> - show cross node allocation stats

I checked and we appear to have all the right events for that - the node 
ID is being traced consistently AFAICS.

> - collect more useful stats?
> - ...

Pekka, Eduard and the other slab hackers might have ideas about what 
other stats they generally like to see to judge the health of a workload 
(or system).

If this iteration looks good to the slab folks then i can apply it as-is 
and we can do the other changes relative to that. It looks good to me as 
a first step, and it's functional already.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
