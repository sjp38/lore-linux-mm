Message-Id: <200510270228.j9R2SWg27777@unix-os.sc.intel.com>
From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Subject: Weird schedule delay time for cache_reap()
Date: Wed, 26 Oct 2005 19:28:32 -0700
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

I can't convince myself that the 2nd argument in schedule_delayed_work
called from cache_reap() function make any sense:


static void cache_reap(void *unused)
{ ...

        check_irq_on();
        up(&cache_chain_sem);
        drain_remote_pages();
        /* Setup the next iteration */
        schedule_delayed_work(&__get_cpu_var(reap_work), REAPTIMEOUT_CPUC + smp_processor_id());
}


Suppose one have a lucky 1024-processor big iron numa box,
cpu0 will do cache_reap every 2 sec (REAPTIMEOUT_CPUC = 2*HZ).
cpu512 will do cache_reap every 4 sec,
cpu1023 will do cache_reap every 6 sec.

Is the skew intentional on different CPU?  Why different interval for
different cpu#?

- Ken

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
