Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 11DDD6B0032
	for <linux-mm@kvack.org>; Fri, 10 May 2013 17:52:30 -0400 (EDT)
Received: from mailout-de.gmx.net ([10.1.76.4]) by mrigmx.server.lan
 (mrigmx001) with ESMTP (Nemesis) id 0MDjlo-1UlLMo32gY-00H6LP for
 <linux-mm@kvack.org>; Fri, 10 May 2013 23:52:28 +0200
Message-ID: <518D6C18.4070607@gmx.de>
Date: Fri, 10 May 2013 23:52:24 +0200
From: =?UTF-8?B?VG9yYWxmIEbDtnJzdGVy?= <toralf.foerster@gmx.de>
MIME-Version: 1.0
Subject: WARNING: at mm/slab_common.c:376 kmalloc_slab+0x33/0x80()
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: "user-mode-linux-user@lists.sourceforge.net" <user-mode-linux-user@lists.sourceforge.net>

The bisected commit introduced this WARNING: on a user mode linux guest
if the UML guest is fuzz tested with trinity :


2013-05-10T22:38:42.191+02:00 trinity kernel: ------------[ cut here ]------------
2013-05-10T22:38:42.191+02:00 trinity kernel: WARNING: at mm/slab_common.c:376 kmalloc_slab+0x33/0x80()
2013-05-10T22:38:42.191+02:00 trinity kernel: 40e2fda8:  [<08336928>] dump_stack+0x22/0x24
2013-05-10T22:38:42.191+02:00 trinity kernel: 40e2fdc0:  [<0807c2da>] warn_slowpath_common+0x5a/0x80
2013-05-10T22:38:42.191+02:00 trinity kernel: 40e2fde8:  [<0807c3a3>] warn_slowpath_null+0x23/0x30
2013-05-10T22:38:42.191+02:00 trinity kernel: 40e2fdf8:  [<080dfc93>] kmalloc_slab+0x33/0x80
2013-05-10T22:38:42.191+02:00 trinity kernel: 40e2fe0c:  [<080f8beb>] __kmalloc_track_caller+0x1b/0x110
2013-05-10T22:38:42.191+02:00 trinity kernel: 40e2fe30:  [<080dc866>] memdup_user+0x26/0x70
2013-05-10T22:38:42.191+02:00 trinity kernel: 40e2fe4c:  [<080dca6e>] strndup_user+0x3e/0x60
2013-05-10T22:38:42.191+02:00 trinity kernel: 40e2fe68:  [<0811ba60>] copy_mount_string+0x30/0x50
2013-05-10T22:38:42.195+02:00 trinity kernel: 40e2fe7c:  [<0811c46a>] sys_mount+0x1a/0xe0
2013-05-10T22:38:42.195+02:00 trinity kernel: 40e2feac:  [<08062b32>] handle_syscall+0x82/0xb0
2013-05-10T22:38:42.195+02:00 trinity kernel: 40e2fef4:  [<0807520d>] userspace+0x46d/0x590
2013-05-10T22:38:42.195+02:00 trinity kernel: 40e2ffec:  [<0805f7fc>] fork_handler+0x6c/0x70
2013-05-10T22:38:42.195+02:00 trinity kernel: 40e2fffc:  [<00000000>] 0x0
2013-05-10T22:38:42.195+02:00 trinity kernel:
2013-05-10T22:38:42.195+02:00 trinity kernel: ---[ end trace 17e5931469d0697d ]---


Tested with host kernel 3.9.1, host and client were 32bit stable Gentoo Linux.


6286ae97d10ea2b5cd90532163797ab217bfdbdf is the first bad commit
commit 6286ae97d10ea2b5cd90532163797ab217bfdbdf
Author: Christoph Lameter <cl@linux.com>
Date:   Fri May 3 15:43:18 2013 +0000

    slab: Return NULL for oversized allocations

    The inline path seems to have changed the SLAB behavior for very large
    kmalloc allocations with  commit e3366016 ("slab: Use common
    kmalloc_index/kmalloc_size functions"). This patch restores the old
    behavior but also adds diagnostics so that we can figure where in the
    code these large allocations occur.

    Reported-and-tested-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
    Signed-off-by: Christoph Lameter <cl@linux.com>
    Link: http://lkml.kernel.org/r/201305040348.CIF81716.OStQOHFJMFLOVF@I-love.SAKURA.ne.jp
    [ penberg@kernel.org: use WARN_ON_ONCE ]
    Signed-off-by: Pekka Enberg <penberg@kernel.org>



-- MfG/Sincerely
Toralf FA?rster
pgp finger print: 7B1A 07F4 EC82 0F90 D4C2 8936 872A E508 7DB6 9DA3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
