Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 165FF6B005A
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 17:24:36 -0400 (EDT)
Date: Wed, 24 Jun 2009 00:26:48 +0300
From: Sergey Senozhatsky <sergey.senozhatsky@mail.by>
Subject: kmemleak: Early log buffer exceeded
Message-ID: <20090623212648.GA9502@localdomain.by>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello.
I can see on my both machines

[    0.000135] kmemleak: Early log buffer exceeded
[    0.000140] Pid: 0, comm: swapper Not tainted 2.6.30-dbginfo-nv-git19 #7
[    0.000144] Call Trace:
[    0.000153]  [<c1418ecc>] ? printk+0x23/0x36
[    0.000160]  [<c10f7c12>] log_early+0xf2/0x110
[    0.000165]  [<c10f8788>] kmemleak_alloc+0x1f8/0x2c0
[    0.000171]  [<c10f28fb>] ? cache_alloc_debugcheck_after+0xeb/0x1e0
[    0.000176]  [<c10f496a>] ? __kmalloc+0xfa/0x240
[    0.000182]  [<c10761fc>] ? trace_hardirqs_on_caller+0x14c/0x1a0
[    0.000187]  [<c10f4a15>] __kmalloc+0x1a5/0x240
[    0.000192]  [<c10f4d8d>] ? alloc_arraycache+0x2d/0x80
[    0.000198]  [<c10f4d8d>] alloc_arraycache+0x2d/0x80
[    0.000203]  [<c10f4e7c>] do_tune_cpucache+0x9c/0x3a0
[    0.000208]  [<c10f5322>] enable_cpucache+0x42/0x110
[    0.000215]  [<c15ff7c4>] kmem_cache_init_late+0x32/0x82
[    0.000221]  [<c15e2995>] start_kernel+0x24c/0x366
[    0.000226]  [<c15e2517>] ? unknown_bootoption+0x0/0x1dd
[    0.000231]  [<c15e2088>] __init_begin+0x88/0xa1

mm/kmemleak.c
static struct early_log early_log[200];

static void log_early(int op_type, const void *ptr, size_t size,
		      int min_count, unsigned long offset, size_t length)
{
...
	if (crt_early_log >= ARRAY_SIZE(early_log)) {
		print  Early log buffer exceeded;
		call dump_stack, etc.

So, my questions are:
1. Is 200 really enough? Why 200 not 512, 1024 (for example)?
//If this has been already discussed - please point me.

2. When (crt_early_log >= ARRAY_SIZE(early_log)) == 1 we just can see stack.
Since we have "full" early_log maybe it'll be helpfull to see it? 
//For example like at void __init kmemleak_init(void)

	Sergey

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
