Received: from spaceape9.eur.corp.google.com (spaceape9.eur.corp.google.com [172.28.16.143])
	by smtp-out.google.com with ESMTP id kAN0Ygsb009890
	for <linux-mm@kvack.org>; Thu, 23 Nov 2006 00:34:42 GMT
Received: from nf-out-0910.google.com (nfby38.prod.google.com [10.48.101.38])
	by spaceape9.eur.corp.google.com with ESMTP id kAN0YfOF002921
	for <linux-mm@kvack.org>; Thu, 23 Nov 2006 00:34:42 GMT
Received: by nf-out-0910.google.com with SMTP id y38so702749nfb
        for <linux-mm@kvack.org>; Wed, 22 Nov 2006 16:34:41 -0800 (PST)
Message-ID: <6599ad830611221634w6a768c1ek816dda61a97b68c@mail.gmail.com>
Date: Wed, 22 Nov 2006 16:34:40 -0800
From: "Paul Menage" <menage@google.com>
Subject: Call to cpuset_zone_allowed() in slab.c:fallback_alloc() with irqs disabled
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>, Andrew Morton <akpm@osdl.org>
Cc: Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

I just saw this backtrace on 2.6.19-rc5:

BUG: sleeping function called from invalid context at kernel/cpuset.c:1520
in_atomic():0, irqs_disabled():1

Call Trace:
 [<ffffffff8024e523>] __cpuset_zone_allowed+0x4b/0xe0
 [<ffffffff80274209>] fallback_alloc+0x9c/0xd7
 [<ffffffff8027470e>] kmem_cache_alloc+0x91/0x9b
 [<ffffffff802899a4>] d_alloc+0x23/0x1c3
 [<ffffffff8028032f>] do_lookup+0x9d/0x1dc
 [<ffffffff80281f9d>] __link_path_walk+0x88d/0xd38
 [<ffffffff802824a5>] link_path_walk+0x5d/0xe8
 [<ffffffff802a2baa>] compat_filldir64+0x0/0xba
 [<ffffffff80230f60>] current_fs_time+0x3b/0x4b
 [<ffffffff80282831>] do_path_lookup+0x1b3/0x1d6
 [<ffffffff802814ed>] getname+0x159/0x1a2
 [<ffffffff802830fe>] __user_walk_fd+0x3b/0x59
 [<ffffffff8027c23d>] vfs_lstat_fd+0x18/0x47
 [<ffffffff802a2baa>] compat_filldir64+0x0/0xba
 [<ffffffff80230f60>] current_fs_time+0x3b/0x4b
 [<ffffffff8028c6a2>] touch_atime+0x67/0xb5
 [<ffffffff8021c7d0>] sys32_lstat64+0x11/0x29
 [<ffffffff8021c1f2>] ia32_sysret+0x0/0xa

kmem_cache_alloc_node() disables irqs, then calls __cache_alloc_node()
-> fallback_alloc() -> cpuset_zone_allowed(), with flags that appear
to be GFP_KERNEL.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
