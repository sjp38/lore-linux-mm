Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 975AB9000BD
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 12:32:47 -0400 (EDT)
Received: by yia25 with SMTP id 25so5956869yia.14
        for <linux-mm@kvack.org>; Mon, 26 Sep 2011 09:32:45 -0700 (PDT)
Subject: Re: Question about memory leak detector giving false positive
 report for net/core/flow.c
From: Eric Dumazet <eric.dumazet@gmail.com>
In-Reply-To: <CA+v9cxadZzWr35Q9RFzVgk_NZsbZ8PkVLJNxjBAMpargW9Lm4Q@mail.gmail.com>
References: 
	 <CA+v9cxadZzWr35Q9RFzVgk_NZsbZ8PkVLJNxjBAMpargW9Lm4Q@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 26 Sep 2011 18:32:54 +0200
Message-ID: <1317054774.6363.9.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Huajun Li <huajun.li.lee@gmail.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>, linux-mm@kvack.org, netdev <netdev@vger.kernel.org>, linux-kernel <linux-kernel@vger.kernel.org>, Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux-foundation.org>

Le lundi 26 septembre 2011 A  23:17 +0800, Huajun Li a A(C)crit :
> Memory leak detector gives following memory leak report, it seems the
> report is triggered by net/core/flow.c, but actually, it should be a
> false positive report.
> So, is there any idea from kmemleak side to fix/disable this false
> positive report like this?
> Yes, kmemleak_not_leak(...) could disable it, but is it suitable for this case ?
> 
> BTW, I wrote a simple test code to emulate net/core/flow.c behavior at
> this stage which triggers the report, and it could also make kmemleak
> give similar report, please check below test code:
> 
> kernel version:
> #uname -a
> Linux 3.1.0-rc7 #22 SMP Tue Sep 26 05:43:01 CST 2011 x86_64 x86_64
> x86_64 GNU/Linux
> 
> memory leak report:
> -------------------------------------------------------------------------------------------
> unreferenced object 0xffff880073a70000 (size 8192):
>   comm "swapper", pid 1, jiffies 4294937832 (age 445.740s)
>   hex dump (first 32 bytes):
>     00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
>     00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
>   backtrace:
>     [<ffffffff8124db64>] create_object+0x144/0x360
>     [<ffffffff8191192e>] kmemleak_alloc+0x7e/0x110
>     [<ffffffff81235b26>] __kmalloc_node+0x156/0x3a0
>     [<ffffffff81935512>] flow_cache_cpu_prepare.clone.1+0x58/0xc0
>     [<ffffffff8214c361>] flow_cache_init_global+0xb6/0x1af
>     [<ffffffff8100225d>] do_one_initcall+0x4d/0x260
>     [<ffffffff820ec2e9>] kernel_init+0x161/0x23a
>     [<ffffffff8194ab04>] kernel_thread_helper+0x4/0x10
>     [<ffffffffffffffff>] 0xffffffffffffffff
> unreferenced object 0xffff880073a74290 (size 8192):
>   comm "swapper", pid 1, jiffies 4294937832 (age 445.740s)
>   hex dump (first 32 bytes):
>     00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
>     00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
>   backtrace:
>     [<ffffffff8124db64>] create_object+0x144/0x360
>     [<ffffffff8191192e>] kmemleak_alloc+0x7e/0x110
>     [<ffffffff81235b26>] __kmalloc_node+0x156/0x3a0
>     [<ffffffff81935512>] flow_cache_cpu_prepare.clone.1+0x58/0xc0
>     [<ffffffff8214c361>] flow_cache_init_global+0xb6/0x1af
>     [<ffffffff8100225d>] do_one_initcall+0x4d/0x260
>     [<ffffffff820ec2e9>] kernel_init+0x161/0x23a
>     [<ffffffff8194ab04>] kernel_thread_helper+0x4/0x10
>     [<ffffffffffffffff>] 0xffffffffffffffff
> 
> 
> 
> Simple test code to reproduce a similar report:
> -----------------------------------------------------------------------------------------
> MODULE_LICENSE("GPL");
> 
> struct test {
>         int *pt;


	char spaceholder[30000];

> };
> 
> static struct test __percpu *percpu;
> 
> static int __init test_init(void)
> {
>         int i;
> 
>         percpu = alloc_percpu(struct test);
>         if (!percpu)
>                 return -ENOMEM;
> 
>         for_each_online_cpu(i) {
>                 struct test *p = per_cpu_ptr(percpu, i);
>                 p->pt = kmalloc(sizeof(int), GFP_KERNEL);
>         }
> 
>         return 0;
> }
> 
> static void __exit test_exit(void)
> {
>         int i;
> 
>         for_each_possible_cpu(i) {
>                 struct test *p = per_cpu_ptr(percpu, i);
>                 if (p->pt)
>                         kfree(p->pt);
>         }
> 
>         if (percpu)
>                 free_percpu(percpu);
> }
> module_init(test_init);
> module_exit(test_exit);


CC lkml and percpu maintainers (Tejun Heo & Christoph Lameter ) as well

AFAIK this false positive only occurs if percpu data is allocated
outside of embedded pcu space. 

 (grep pcpu_get_vm_areas /proc/vmallocinfo)

I suspect this is a percpu/kmemleak cooperation problem (a missing
kmemleak_alloc() ?)

I am pretty sure kmemleak_not_leak() is not the right answer to this
problem.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
