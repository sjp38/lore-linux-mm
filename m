Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8ED7A6B0527
	for <linux-mm@kvack.org>; Wed,  6 Sep 2017 19:56:57 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id x78so15155568pff.7
        for <linux-mm@kvack.org>; Wed, 06 Sep 2017 16:56:57 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i8sor565668plk.123.2017.09.06.16.56.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 06 Sep 2017 16:56:56 -0700 (PDT)
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH] idr: remove WARN_ON_ONCE() when trying to replace negative ID
Date: Wed,  6 Sep 2017 16:53:06 -0700
Message-Id: <20170906235306.20534-1-ebiggers3@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Eric Biggers <ebiggers3@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Chris Wilson <chris@chris-wilson.co.uk>, Dmitry Vyukov <dvyukov@google.com>, Matthew Wilcox <mawilcox@microsoft.com>, Tejun Heo <tj@kernel.org>, dri-devel@lists.freedesktop.org, stable@vger.kernel.org

From: Eric Biggers <ebiggers@google.com>

IDR only supports non-negative IDs.  There used to be a
'WARN_ON_ONCE(id < 0)' in idr_replace(), but it was intentionally
removed by commit 2e1c9b286765 ("idr: remove WARN_ON_ONCE() on negative
IDs").  Then it was added back by commit 0a835c4f090a ("Reimplement IDR
and IDA using the radix tree").  However it seems that adding it back
was a mistake, given that some users such as drm_gem_handle_delete()
(DRM_IOCTL_GEM_CLOSE) pass in a value from userspace to idr_replace(),
allowing the WARN_ON_ONCE to be triggered.  drm_gem_handle_delete()
actually just wants idr_replace() to return an error code if the ID is
not allocated, including in the case where the ID is invalid (negative).

So once again remove the bogus WARN_ON_ONCE().

This bug was found by syzkaller, which encountered the following
warning:

    WARNING: CPU: 3 PID: 3008 at lib/idr.c:157 idr_replace+0x1d8/0x240 lib/idr.c:157
    Kernel panic - not syncing: panic_on_warn set ...

    CPU: 3 PID: 3008 Comm: syzkaller218828 Not tainted 4.13.0-rc4-next-20170811 #2
    Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
    Call Trace:
     __dump_stack lib/dump_stack.c:16 [inline]
     dump_stack+0x194/0x257 lib/dump_stack.c:52
     panic+0x1e4/0x417 kernel/panic.c:180
     __warn+0x1c4/0x1d9 kernel/panic.c:541
     report_bug+0x211/0x2d0 lib/bug.c:183
     fixup_bug+0x40/0x90 arch/x86/kernel/traps.c:190
     do_trap_no_signal arch/x86/kernel/traps.c:224 [inline]
     do_trap+0x260/0x390 arch/x86/kernel/traps.c:273
     do_error_trap+0x120/0x390 arch/x86/kernel/traps.c:310
     do_invalid_op+0x1b/0x20 arch/x86/kernel/traps.c:323
     invalid_op+0x1e/0x30 arch/x86/entry/entry_64.S:930
    RIP: 0010:idr_replace+0x1d8/0x240 lib/idr.c:157
    RSP: 0018:ffff8800394bf9f8 EFLAGS: 00010297
    RAX: ffff88003c6c60c0 RBX: 1ffff10007297f43 RCX: 0000000000000000
    RDX: 0000000000000000 RSI: 0000000000000000 RDI: ffff8800394bfa78
    RBP: ffff8800394bfae0 R08: ffffffff82856487 R09: 0000000000000000
    R10: ffff8800394bf9a8 R11: ffff88006c8bae28 R12: ffffffffffffffff
    R13: ffff8800394bfab8 R14: dffffc0000000000 R15: ffff8800394bfbc8
     drm_gem_handle_delete+0x33/0xa0 drivers/gpu/drm/drm_gem.c:297
     drm_gem_close_ioctl+0xa1/0xe0 drivers/gpu/drm/drm_gem.c:671
     drm_ioctl_kernel+0x1e7/0x2e0 drivers/gpu/drm/drm_ioctl.c:729
     drm_ioctl+0x72e/0xa50 drivers/gpu/drm/drm_ioctl.c:825
     vfs_ioctl fs/ioctl.c:45 [inline]
     do_vfs_ioctl+0x1b1/0x1520 fs/ioctl.c:685
     SYSC_ioctl fs/ioctl.c:700 [inline]
     SyS_ioctl+0x8f/0xc0 fs/ioctl.c:691
     entry_SYSCALL_64_fastpath+0x1f/0xbe

Here is a C reproducer:

    #include <fcntl.h>
    #include <stddef.h>
    #include <stdint.h>
    #include <sys/ioctl.h>
    #include <drm/drm.h>

    int main(void)
    {
            int cardfd = open("/dev/dri/card0", O_RDONLY);

            ioctl(cardfd, DRM_IOCTL_GEM_CLOSE,
                  &(struct drm_gem_close) { .handle = -1 } );
    }

Fixes: 0a835c4f090a ("Reimplement IDR and IDA using the radix tree")
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Chris Wilson <chris@chris-wilson.co.uk>
Cc: Dmitry Vyukov <dvyukov@google.com>
Cc: Matthew Wilcox <mawilcox@microsoft.com>
Cc: Tejun Heo <tj@kernel.org>
Cc: dri-devel@lists.freedesktop.org
Cc: <stable@vger.kernel.org> [v4.11+]
Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 lib/idr.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/idr.c b/lib/idr.c
index 082778cf883e..f9adf4805fd7 100644
--- a/lib/idr.c
+++ b/lib/idr.c
@@ -151,7 +151,7 @@ EXPORT_SYMBOL(idr_get_next_ext);
  */
 void *idr_replace(struct idr *idr, void *ptr, int id)
 {
-	if (WARN_ON_ONCE(id < 0))
+	if (id < 0)
 		return ERR_PTR(-EINVAL);
 
 	return idr_replace_ext(idr, ptr, id);
-- 
2.14.1.581.gf28d330327-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
