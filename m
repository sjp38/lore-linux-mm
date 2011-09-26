Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id AB1559000BD
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 11:23:45 -0400 (EDT)
Received: by fxh17 with SMTP id 17so7938260fxh.14
        for <linux-mm@kvack.org>; Mon, 26 Sep 2011 08:23:42 -0700 (PDT)
MIME-Version: 1.0
Date: Mon, 26 Sep 2011 23:17:24 +0800
Message-ID: <CA+v9cxadZzWr35Q9RFzVgk_NZsbZ8PkVLJNxjBAMpargW9Lm4Q@mail.gmail.com>
Subject: Question about memory leak detector giving false positive report for net/core/flow.c
From: Huajun Li <huajun.li.lee@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>, linux-mm@kvack.org
Cc: "\"Eric Dumaze\"t" <eric.dumazet@gmail.com>, netdev <netdev@vger.kernel.org>, Huajun Li <huajun.li.lee@gmail.com>

Memory leak detector gives following memory leak report, it seems the
report is triggered by net/core/flow.c, but actually, it should be a
false positive report.
So, is there any idea from kmemleak side to fix/disable this false
positive report like this?
Yes, kmemleak_not_leak(...) could disable it, but is it suitable for this case ?

BTW, I wrote a simple test code to emulate net/core/flow.c behavior at
this stage which triggers the report, and it could also make kmemleak
give similar report, please check below test code:

kernel version:
#uname -a
Linux 3.1.0-rc7 #22 SMP Tue Sep 26 05:43:01 CST 2011 x86_64 x86_64
x86_64 GNU/Linux

memory leak report:
-------------------------------------------------------------------------------------------
unreferenced object 0xffff880073a70000 (size 8192):
  comm "swapper", pid 1, jiffies 4294937832 (age 445.740s)
  hex dump (first 32 bytes):
    00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
    00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
  backtrace:
    [<ffffffff8124db64>] create_object+0x144/0x360
    [<ffffffff8191192e>] kmemleak_alloc+0x7e/0x110
    [<ffffffff81235b26>] __kmalloc_node+0x156/0x3a0
    [<ffffffff81935512>] flow_cache_cpu_prepare.clone.1+0x58/0xc0
    [<ffffffff8214c361>] flow_cache_init_global+0xb6/0x1af
    [<ffffffff8100225d>] do_one_initcall+0x4d/0x260
    [<ffffffff820ec2e9>] kernel_init+0x161/0x23a
    [<ffffffff8194ab04>] kernel_thread_helper+0x4/0x10
    [<ffffffffffffffff>] 0xffffffffffffffff
unreferenced object 0xffff880073a74290 (size 8192):
  comm "swapper", pid 1, jiffies 4294937832 (age 445.740s)
  hex dump (first 32 bytes):
    00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
    00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
  backtrace:
    [<ffffffff8124db64>] create_object+0x144/0x360
    [<ffffffff8191192e>] kmemleak_alloc+0x7e/0x110
    [<ffffffff81235b26>] __kmalloc_node+0x156/0x3a0
    [<ffffffff81935512>] flow_cache_cpu_prepare.clone.1+0x58/0xc0
    [<ffffffff8214c361>] flow_cache_init_global+0xb6/0x1af
    [<ffffffff8100225d>] do_one_initcall+0x4d/0x260
    [<ffffffff820ec2e9>] kernel_init+0x161/0x23a
    [<ffffffff8194ab04>] kernel_thread_helper+0x4/0x10
    [<ffffffffffffffff>] 0xffffffffffffffff



Simple test code to reproduce a similar report:
-----------------------------------------------------------------------------------------
MODULE_LICENSE("GPL");

struct test {
        int *pt;
};

static struct test __percpu *percpu;

static int __init test_init(void)
{
        int i;

        percpu = alloc_percpu(struct test);
        if (!percpu)
                return -ENOMEM;

        for_each_online_cpu(i) {
                struct test *p = per_cpu_ptr(percpu, i);
                p->pt = kmalloc(sizeof(int), GFP_KERNEL);
        }

        return 0;
}

static void __exit test_exit(void)
{
        int i;

        for_each_possible_cpu(i) {
                struct test *p = per_cpu_ptr(percpu, i);
                if (p->pt)
                        kfree(p->pt);
        }

        if (percpu)
                free_percpu(percpu);
}
module_init(test_init);
module_exit(test_exit);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
