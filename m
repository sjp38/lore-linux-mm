Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 944F66B0044
	for <linux-mm@kvack.org>; Wed,  4 Nov 2009 17:03:48 -0500 (EST)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id AD56982C151
	for <linux-mm@kvack.org>; Wed,  4 Nov 2009 17:10:25 -0500 (EST)
Received: from smtp.ultrahosting.com ([74.213.174.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id KvlKzeodod4Y for <linux-mm@kvack.org>;
	Wed,  4 Nov 2009 17:10:25 -0500 (EST)
Received: from V090114053VZO-1 (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 6BCC182C3E8
	for <linux-mm@kvack.org>; Wed,  4 Nov 2009 17:10:10 -0500 (EST)
Date: Wed, 4 Nov 2009 17:02:12 -0500 (EST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [MM] Remove rss batching from copy_page_range()
In-Reply-To: <87my3280mb.fsf@basil.nowhere.org>
Message-ID: <alpine.DEB.1.10.0911041640340.17859@V090114053VZO-1>
References: <alpine.DEB.1.10.0911041409020.7409@V090114053VZO-1> <alpine.DEB.1.10.0911041415480.7409@V090114053VZO-1> <87my3280mb.fsf@basil.nowhere.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Tejun Heo <tj@kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, 4 Nov 2009, Andi Kleen wrote:

> > With per cpu counters in mm there is no need for batching
> > mm counter updates anymore. Update counters directly while
> > copying pages.
>
> Hmm, but with all the inlining with some luck the local
> counters will be in registers. That will never be the case
> with the per cpu counters.

The function is too big for that to occur and the counters have to be
preserved across function calls. The code is shorter with the patch
applied:

christoph@:~/n/linux-2.6$ size mm/memory.o
   text	   data	    bss	    dec	    hex	filename
  20140	     56	     40	  20236	   4f0c	mm/memory.o
christoph@:~/n/linux-2.6$ quilt push
Applying patch mmcounter
patching file include/linux/mm_types.h
patching file include/linux/sched.h
patching file kernel/fork.c
patching file fs/proc/task_mmu.c
patching file mm/filemap_xip.c
patching file mm/fremap.c
patching file mm/memory.c
patching file mm/rmap.c
patching file mm/swapfile.c
patching file mm/init-mm.c

Now at patch mmcounter
christoph@:~/n/linux-2.6$ make mm/memory.o
  CHK     include/linux/version.h
  CHK     include/linux/utsrelease.h
  UPD     include/linux/utsrelease.h
  SYMLINK include/asm -> include/asm-x86
  CC      arch/x86/kernel/asm-offsets.s
  GEN     include/asm/asm-offsets.h
  CALL    scripts/checksyscalls.sh
  CC      mm/memory.o
christoph@:~/n/linux-2.6$ size mm/memory.o
   text	   data	    bss	    dec	    hex	filename
  20028	     56	     40	  20124	   4e9c	mm/memory.o
christoph@:~/n/linux-2.6$ quilt push
Applying patch simplify
patching file mm/memory.c

Now at patch simplify
christoph@:~/n/linux-2.6$ make mm/memory.o
  CHK     include/linux/version.h
  CHK     include/linux/utsrelease.h
  SYMLINK include/asm -> include/asm-x86
  CALL    scripts/checksyscalls.sh
  CC      mm/memory.o
christoph@:~/n/linux-2.6$ size mm/memory.o
   text	   data	    bss	    dec	    hex	filename
  19888	     56	     40	  19984	   4e10	mm/memory.o


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
