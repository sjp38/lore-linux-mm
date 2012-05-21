Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id D71736B0083
	for <linux-mm@kvack.org>; Mon, 21 May 2012 11:47:14 -0400 (EDT)
Date: Mon, 21 May 2012 11:47:09 -0400
From: Dave Jones <davej@redhat.com>
Subject: Re: 3.4-rc7 numa_policy slab poison.
Message-ID: <20120521154709.GA8697@redhat.com>
References: <20120517213120.GA12329@redhat.com>
 <20120518185851.GA5728@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120518185851.GA5728@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

On Fri, May 18, 2012 at 02:58:51PM -0400, Dave Jones wrote:
 > On Thu, May 17, 2012 at 05:31:20PM -0400, Dave Jones wrote:
 > 
 >  > =============================================================================
 >  > BUG numa_policy (Not tainted): Poison overwritten
 >  > -----------------------------------------------------------------------------
 >  > 
 >  > INFO: 0xffff880146498250-0xffff880146498250. First byte 0x6a instead of 0x6b
 >  > INFO: Allocated in mpol_new+0xa3/0x140 age=46310 cpu=6 pid=32154
 >  > 	__slab_alloc+0x3d3/0x445
 >  > 	kmem_cache_alloc+0x29d/0x2b0
 >  > 	mpol_new+0xa3/0x140
 >  > 	sys_mbind+0x142/0x620
 >  > 	system_call_fastpath+0x16/0x1b
 >  > INFO: Freed in __mpol_put+0x27/0x30 age=46268 cpu=6 pid=32154
 >  > 	__slab_free+0x2e/0x1de
 >  > 	kmem_cache_free+0x25a/0x260
 >  > 	__mpol_put+0x27/0x30
 >  > 	remove_vma+0x68/0x90
 >  > 	exit_mmap+0x118/0x140
 >  > 	mmput+0x73/0x110
 >  > 	exit_mm+0x108/0x130
 >  > 	do_exit+0x162/0xb90
 >  > 	do_group_exit+0x4f/0xc0
 >  > 	sys_exit_group+0x17/0x20
 >  > 	system_call_fastpath+0x16/0x1b
 >  > INFO: Slab 0xffffea0005192600 objects=27 used=27 fp=0x          (null) flags=0x20000000004080
 >  > INFO: Object 0xffff880146498250 @offset=592 fp=0xffff88014649b9d0
 > 
 > As I can reproduce this fairly easily, I enabled the dynamic debug prints for mempolicy.c,
 > and noticed something odd (but different to the above trace..)
 > 
 > INFO: 0xffff88014649abf0-0xffff88014649abf0. First byte 0x6a instead of 0x6b
 > INFO: Allocated in mpol_new+0xa3/0x140 age=196087 cpu=7 pid=11496
 >  __slab_alloc+0x3d3/0x445
 >  kmem_cache_alloc+0x29d/0x2b0
 >  mpol_new+0xa3/0x140
 >  sys_mbind+0x142/0x620
 >  system_call_fastpath+0x16/0x1b
 > INFO: Freed in __mpol_put+0x27/0x30 age=40838 cpu=7 pid=20824
 >  __slab_free+0x2e/0x1de
 >  kmem_cache_free+0x25a/0x260
 >  __mpol_put+0x27/0x30
 >  mpol_set_shared_policy+0xe6/0x280
 >  shmem_set_policy+0x2a/0x30
 >  shm_set_policy+0x28/0x30
 >  sys_mbind+0x4e7/0x620
 >  system_call_fastpath+0x16/0x1b
 > INFO: Slab 0xffffea0005192600 objects=27 used=27 fp=0x          (null) flags=0x20000000004080
 > INFO: Object 0xffff88014649abf0 @offset=11248 fp=0xffff880146498de0
 > 
 > In this case, it seems the policy was allocated by pid 11496, and freed by a different pid!
 > How is that possible ?  (Does kind of explain why it looks like a double-free though I guess).
 > 
 > debug printout for the relevant pids below, in case it yields further clues..

Anyone ?  This can be reproduced very quickly by doing..

$ git clone git://git.codemonkey.org.uk/trinity.git
$ make
$ ./trinity -q -c mbind

On my 8-core box, it happens within 30 seconds.

If I run this long enough, the box wedges completely, needing a power cycle to reboot.

	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
