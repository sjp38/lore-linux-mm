Date: Fri, 6 Feb 2004 14:39:17 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: 2.6.2-mm1 problem with umounting reiserfs
Message-Id: <20040206143917.4e39b215.akpm@osdl.org>
In-Reply-To: <1076104945.1793.12.camel@spc.esa.lanl.gov>
References: <1076104945.1793.12.camel@spc.esa.lanl.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Steven Cole <elenstev@mesatop.com>
Cc: linux-mm@kvack.org, Rusty Russell <rusty@rustcorp.com.au>
List-ID: <linux-mm.kvack.org>

Steven Cole <elenstev@mesatop.com> wrote:
>
> With kernel 2.6.2-mm1, I got the following when umounting a reiserfs
> file system.

> Unable to handle kernel NULL pointer dereference at virtual address 00000000
>  printing eip:
> c012a7b2
> *pde = 00000000
> Oops: 0000 [#1]
> PREEMPT
> CPU:    0
> EIP:    0060:[<c012a7b2>]    Not tainted VLI
> EFLAGS: 00210202
> EIP is at destroy_workqueue+0x72/0xe0
> eax: 00000001   ebx: ca55e000   ecx: cfca3364   edx: 00000000
> esi: cfca3360   edi: cfca3320   ebp: cf926670   esp: ca55fe90
> ds: 007b   es: 007b   ss: 0068
> Process umount (pid: 1743, threadinfo=ca55e000 task=cd6e5940)
> Stack: cf926670 00000001 ca55feb8 cfca1200 c04573c0 ca55ff74 c01acc9d cfca3320
>        cfca1200 cf84d688 c040e963 00000001 00000001 00005c46 cfca1200 cf446d78
>        ca55fef0 cfca1200 00000000 cfca1200 c019a655 ca55fef0 cfca1200 cf84d688
> Call Trace:
>  [<c01acc9d>] do_journal_release+0x4d/0xe0
>  [<c019a655>] reiserfs_put_super+0x25/0x180
>  [<c0154447>] generic_shutdown_super+0x177/0x1e0
>  [<c01544cd>] kill_block_super+0x1d/0x50
>  [<c01545df>] deactivate_super+0x5f/0xc0
>  [<c016b2cb>] sys_umount+0x4b/0x2f0
>  [<c0141226>] do_munmap+0x296/0x3c0
>  [<c016b585>] sys_oldumount+0x15/0x19
>  [<c03f40d2>] sysenter_past_esp+0x43/0x65

Squish.  Thanks.


diff -puN kernel/workqueue.c~cpuhotplug-03-core-workqueue-fix kernel/workqueue.c
--- 25/kernel/workqueue.c~cpuhotplug-03-core-workqueue-fix	Fri Feb  6 14:36:04 2004
+++ 25-akpm/kernel/workqueue.c	Fri Feb  6 14:36:41 2004
@@ -335,7 +335,7 @@ void destroy_workqueue(struct workqueue_
 		if (cpu_online(cpu))
 			cleanup_workqueue_thread(wq, cpu);
 	}
-	list_del(&wq->list);
+	del_workqueue(wq);
 	unlock_cpu_hotplug();
 	kfree(wq);
 }

_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
