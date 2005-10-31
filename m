Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e31.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id j9VGZ6OR005230
	for <linux-mm@kvack.org>; Mon, 31 Oct 2005 11:35:06 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j9VGZ6fJ483744
	for <linux-mm@kvack.org>; Mon, 31 Oct 2005 09:35:06 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j9VGZ5wq015858
	for <linux-mm@kvack.org>; Mon, 31 Oct 2005 09:35:06 -0700
Subject: Re: [RFC] madvise(MADV_TRUNCATE)
From: Badari Pulavarty <pbadari@us.ibm.com>
In-Reply-To: <20051029025119.GA14998@ccure.user-mode-linux.org>
References: <1130366995.23729.38.camel@localhost.localdomain>
	 <20051028034616.GA14511@ccure.user-mode-linux.org>
	 <43624F82.6080003@us.ibm.com>
	 <20051028184235.GC8514@ccure.user-mode-linux.org>
	 <1130544201.23729.167.camel@localhost.localdomain>
	 <20051029025119.GA14998@ccure.user-mode-linux.org>
Content-Type: text/plain
Date: Mon, 31 Oct 2005 08:34:39 -0800
Message-Id: <1130776479.24503.3.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeff Dike <jdike@addtoit.com>
Cc: Hugh Dickins <hugh@veritas.com>, akpm@osdl.org, andrea@suse.de, dvhltc@us.ibm.com, linux-mm <linux-mm@kvack.org>, Blaisorblade <blaisorblade@yahoo.it>
List-ID: <linux-mm.kvack.org>

On Fri, 2005-10-28 at 22:51 -0400, Jeff Dike wrote:
> On Fri, Oct 28, 2005 at 05:03:21PM -0700, Badari Pulavarty wrote:
> > Here is the update on the patch.
> > 
> > I found few bugs in my shmem_truncate_range() (surprise!!)
> > 	- BUG_ON(subdir->nr_swapped > offset);
> > 	- freeing up the "subdir" while it has some more entries
> > 	swapped.
> > 
> > I wrote some tests to force swapping and working out the bugs.
> > I haven't tried your test yet, since its kind of intimidating :(
> 
> Well, then send me the patch since I don't find this the least bit 
> intimidating :-)

Jeff,

I tried your testcase again (tried to remove 8K). I see nothing
wrong from madvise() side - but after removing all commands
hang in UML. Few uml processes keep spinning. Does these mean
anything to you. I can't seem to find out what wrong with my
code.

(BTW, I wrote a testcase to release few pages and then go back
and touch those pages again - I don't see any problem).

Please let me know.

Thanks,
Badari


top - 03:36:09 up 8 min,  3 users,  load average: 1.26, 0.70, 0.33
Tasks:  70 total,   3 running,  57 sleeping,  10 stopped,   0 zombie
Cpu(s):  8.8% us, 41.2% sy,  0.0% ni, 49.9% id,  0.0% wa,  0.0% hi,
0.0% si
Mem:   4042308k total,   283296k used,  3759012k free,     9728k buffers
Swap:  1052648k total,        0k used,  1052648k free,   149052k cached

  PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  COMMAND
11826 root      16   0  193m  51m  51m R 62.6  1.3   1:01.44 linux
11834 root      15   0   504  456  440 R 37.3  0.0   0:35.70 linux
    1 root      16   0   720  260  216 S  0.0  0.0   0:00.57 init
    2 root      RT   0     0    0    0 S  0.0  0.0   0:00.00 migration/0

sysrq-t output:

linux         S 0000000000000001     0 11826  10995 11832
(NOTLB)
0000000000000001 0000000000000000 0000000000000001 0000000000000006
       ffffffff8062e480 ffffffffffffffef ffffffff80404544
0000000000000010
       0000000000000202 ffff810111e8dd48
Call Trace:<ffffffff80404544>{_write_lock_irqsave+132}
<ffffffff80404599>{_write_lock_irq+9}
       <ffffffff8013a522>{do_wait+610}
<ffffffff80132430>{default_wake_function+0}
       <ffffffff80132430>{default_wake_function+0}
<ffffffff8013241b>{try_to_wake_up+1083}
       <ffffffff8013b05a>{sys_wait4+42}
<ffffffff80159771>{compat_sys_wait4+49}
       <ffffffff80132460>{wake_up_process+16}
<ffffffff80111a05>{sys_ptrace+2261}
       <ffffffff8012ea5f>{sys32_ptrace+111}
<ffffffff80124efb>{sys32_waitpid+11}
       <ffffffff801235eb>{sysenter_do_call+27}

linux         t ffff810120ee0100     0 11834  11826               12082
(NOTLB)
ffff810109fdbdb8 0000000000000082 0000000000000001 0000000000000046
       ffff810109fdbd08 ffffffff801331e2 0000000000000000
ffff81011b01a600
       ffff81011b01ae08 ffff8101234a0ec0
Call Trace:<ffffffff801331e2>{__wake_up_sync+98}
<ffffffff801422f2>{recalc_sigpending+18}
<ffffffff801433a5>{__dequeue_signal+501} <ffffffff80144939>{ptrace_stop
+313}
       <ffffffff80145997>{get_signal_to_deliver+407}
<ffffffff8010d21d>{do_signal+125}
       <ffffffff80406480>{do_page_fault+2176}
<ffffffff8012e2eb>{restore_i387_ia32+75}
       <ffffffff80129ba1>{ia32_restore_sigcontext+129}
<ffffffff80129cd1>{ia32_restore_sigcontext+433}
       <ffffffff8010d890>{do_notify_resume+48}
<ffffffff8010e036>{int_signal+18}



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
