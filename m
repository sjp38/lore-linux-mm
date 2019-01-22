Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id BF2088E0001
	for <linux-mm@kvack.org>; Tue, 22 Jan 2019 08:59:42 -0500 (EST)
Received: by mail-it1-f199.google.com with SMTP id g7so13172696itg.7
        for <linux-mm@kvack.org>; Tue, 22 Jan 2019 05:59:42 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f139sor24868914itf.5.2019.01.22.05.59.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 22 Jan 2019 05:59:41 -0800 (PST)
MIME-Version: 1.0
References: <0000000000004024240573137822@google.com> <20180810161848.GB16533@bombadil.infradead.org>
In-Reply-To: <20180810161848.GB16533@bombadil.infradead.org>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Tue, 22 Jan 2019 14:59:29 +0100
Message-ID: <CACT4Y+bEsav4r82z5rE1b0rH==VpU7FEK7DzuqTu3AV+w0Ve9g@mail.gmail.com>
Subject: Re: possible deadlock in shmem_fallocate (2)
Content-Type: multipart/mixed; boundary="00000000000084ecc605800c638f"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: syzbot <syzbot+4b8b031b89e6b96c4b2e@syzkaller.appspotmail.com>, Hugh Dickins <hughd@google.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, syzkaller-bugs <syzkaller-bugs@googlegroups.com>, Joel Fernandes <joelaf@google.com>, Yisheng Xie <xieyisheng1@huawei.com>, Todd Kjos <tkjos@google.com>, Arve Hjonnevag <arve@android.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>

--00000000000084ecc605800c638f
Content-Type: text/plain; charset="UTF-8"

On Fri, Aug 10, 2018 at 6:18 PM Matthew Wilcox <willy@infradead.org> wrote:
>
>
> This is another ashmem lockdep splat.  Forwarding to the appropriate ashmem
> people.


Let's test Tetsuo's patch

#syz test: git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git
master



> On Fri, Aug 10, 2018 at 04:59:02AM -0700, syzbot wrote:
> > Hello,
> >
> > syzbot found the following crash on:
> >
> > HEAD commit:    4110b42356f3 Add linux-next specific files for 20180810
> > git tree:       linux-next
> > console output: https://syzkaller.appspot.com/x/log.txt?x=1411d6e2400000
> > kernel config:  https://syzkaller.appspot.com/x/.config?x=1d80606e3795a4f5
> > dashboard link: https://syzkaller.appspot.com/bug?extid=4b8b031b89e6b96c4b2e
> > compiler:       gcc (GCC) 8.0.1 20180413 (experimental)
> > syzkaller repro:https://syzkaller.appspot.com/x/repro.syz?x=175052f8400000
> > C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=11873622400000
> >
> > IMPORTANT: if you fix the bug, please add the following tag to the commit:
> > Reported-by: syzbot+4b8b031b89e6b96c4b2e@syzkaller.appspotmail.com
> >
> > random: sshd: uninitialized urandom read (32 bytes read)
> > random: sshd: uninitialized urandom read (32 bytes read)
> > random: sshd: uninitialized urandom read (32 bytes read)
> >
> > ======================================================
> > WARNING: possible circular locking dependency detected
> > 4.18.0-rc8-next-20180810+ #36 Not tainted
> > ------------------------------------------------------
> > syz-executor900/4483 is trying to acquire lock:
> > 00000000d2bfc8fe (&sb->s_type->i_mutex_key#9){++++}, at: inode_lock
> > include/linux/fs.h:765 [inline]
> > 00000000d2bfc8fe (&sb->s_type->i_mutex_key#9){++++}, at:
> > shmem_fallocate+0x18b/0x12e0 mm/shmem.c:2602
> >
> > but task is already holding lock:
> > 0000000025208078 (ashmem_mutex){+.+.}, at: ashmem_shrink_scan+0xb4/0x630
> > drivers/staging/android/ashmem.c:448
> >
> > which lock already depends on the new lock.
> >
> >
> > the existing dependency chain (in reverse order) is:
> >
> > -> #2 (ashmem_mutex){+.+.}:
> >        __mutex_lock_common kernel/locking/mutex.c:925 [inline]
> >        __mutex_lock+0x171/0x1700 kernel/locking/mutex.c:1073
> >        mutex_lock_nested+0x16/0x20 kernel/locking/mutex.c:1088
> >        ashmem_mmap+0x55/0x520 drivers/staging/android/ashmem.c:361
> >        call_mmap include/linux/fs.h:1844 [inline]
> >        mmap_region+0xf27/0x1c50 mm/mmap.c:1762
> >        do_mmap+0xa10/0x1220 mm/mmap.c:1535
> >        do_mmap_pgoff include/linux/mm.h:2298 [inline]
> >        vm_mmap_pgoff+0x213/0x2c0 mm/util.c:357
> >        ksys_mmap_pgoff+0x4da/0x660 mm/mmap.c:1585
> >        __do_sys_mmap arch/x86/kernel/sys_x86_64.c:100 [inline]
> >        __se_sys_mmap arch/x86/kernel/sys_x86_64.c:91 [inline]
> >        __x64_sys_mmap+0xe9/0x1b0 arch/x86/kernel/sys_x86_64.c:91
> >        do_syscall_64+0x1b9/0x820 arch/x86/entry/common.c:290
> >        entry_SYSCALL_64_after_hwframe+0x49/0xbe
> >
> > -> #1 (&mm->mmap_sem){++++}:
> >        __might_fault+0x155/0x1e0 mm/memory.c:4568
> >        _copy_to_user+0x30/0x110 lib/usercopy.c:25
> >        copy_to_user include/linux/uaccess.h:155 [inline]
> >        filldir+0x1ea/0x3a0 fs/readdir.c:196
> >        dir_emit_dot include/linux/fs.h:3464 [inline]
> >        dir_emit_dots include/linux/fs.h:3475 [inline]
> >        dcache_readdir+0x13a/0x620 fs/libfs.c:193
> >        iterate_dir+0x48b/0x5d0 fs/readdir.c:51
> >        __do_sys_getdents fs/readdir.c:231 [inline]
> >        __se_sys_getdents fs/readdir.c:212 [inline]
> >        __x64_sys_getdents+0x29f/0x510 fs/readdir.c:212
> >        do_syscall_64+0x1b9/0x820 arch/x86/entry/common.c:290
> >        entry_SYSCALL_64_after_hwframe+0x49/0xbe
> >
> > -> #0 (&sb->s_type->i_mutex_key#9){++++}:
> >        lock_acquire+0x1e4/0x540 kernel/locking/lockdep.c:3924
> >        down_write+0x8f/0x130 kernel/locking/rwsem.c:70
> >        inode_lock include/linux/fs.h:765 [inline]
> >        shmem_fallocate+0x18b/0x12e0 mm/shmem.c:2602
> >        ashmem_shrink_scan+0x236/0x630 drivers/staging/android/ashmem.c:455
> >        ashmem_ioctl+0x3ae/0x13a0 drivers/staging/android/ashmem.c:797
> >        vfs_ioctl fs/ioctl.c:46 [inline]
> >        file_ioctl fs/ioctl.c:501 [inline]
> >        do_vfs_ioctl+0x1de/0x1720 fs/ioctl.c:685
> >        ksys_ioctl+0xa9/0xd0 fs/ioctl.c:702
> >        __do_sys_ioctl fs/ioctl.c:709 [inline]
> >        __se_sys_ioctl fs/ioctl.c:707 [inline]
> >        __x64_sys_ioctl+0x73/0xb0 fs/ioctl.c:707
> >        do_syscall_64+0x1b9/0x820 arch/x86/entry/common.c:290
> >        entry_SYSCALL_64_after_hwframe+0x49/0xbe
> >
> > other info that might help us debug this:
> >
> > Chain exists of:
> >   &sb->s_type->i_mutex_key#9 --> &mm->mmap_sem --> ashmem_mutex
> >
> >  Possible unsafe locking scenario:
> >
> >        CPU0                    CPU1
> >        ----                    ----
> >   lock(ashmem_mutex);
> >                                lock(&mm->mmap_sem);
> >                                lock(ashmem_mutex);
> >   lock(&sb->s_type->i_mutex_key#9);
> >
> >  *** DEADLOCK ***
> >
> > 1 lock held by syz-executor900/4483:
> >  #0: 0000000025208078 (ashmem_mutex){+.+.}, at:
> > ashmem_shrink_scan+0xb4/0x630 drivers/staging/android/ashmem.c:448
> >
> > stack backtrace:
> > CPU: 1 PID: 4483 Comm: syz-executor900 Not tainted 4.18.0-rc8-next-20180810+
> > #36
> > Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS
> > Google 01/01/2011
> > Call Trace:
> >  __dump_stack lib/dump_stack.c:77 [inline]
> >  dump_stack+0x1c9/0x2b4 lib/dump_stack.c:113
> >  print_circular_bug.isra.37.cold.58+0x1bd/0x27d
> > kernel/locking/lockdep.c:1227
> >  check_prev_add kernel/locking/lockdep.c:1867 [inline]
> >  check_prevs_add kernel/locking/lockdep.c:1980 [inline]
> >  validate_chain kernel/locking/lockdep.c:2421 [inline]
> >  __lock_acquire+0x3449/0x5020 kernel/locking/lockdep.c:3435
> >  lock_acquire+0x1e4/0x540 kernel/locking/lockdep.c:3924
> >  down_write+0x8f/0x130 kernel/locking/rwsem.c:70
> >  inode_lock include/linux/fs.h:765 [inline]
> >  shmem_fallocate+0x18b/0x12e0 mm/shmem.c:2602
> >  ashmem_shrink_scan+0x236/0x630 drivers/staging/android/ashmem.c:455
> >  ashmem_ioctl+0x3ae/0x13a0 drivers/staging/android/ashmem.c:797
> >  vfs_ioctl fs/ioctl.c:46 [inline]
> >  file_ioctl fs/ioctl.c:501 [inline]
> >  do_vfs_ioctl+0x1de/0x1720 fs/ioctl.c:685
> >  ksys_ioctl+0xa9/0xd0 fs/ioctl.c:702
> >  __do_sys_ioctl fs/ioctl.c:709 [inline]
> >  __se_sys_ioctl fs/ioctl.c:707 [inline]
> >  __x64_sys_ioctl+0x73/0xb0 fs/ioctl.c:707
> >  do_syscall_64+0x1b9/0x820 arch/x86/entry/common.c:290
> >  entry_SYSCALL_64_after_hwframe+0x49/0xbe
> > RIP: 0033:0x440099
> > Code: 18 89 d0 c3 66 2e 0f 1f 84 00 00 00 00 00 0f 1f 00 48 89 f8 48 89 f7
> > 48 89 d6 48 89 ca 4d 89 c2 4d 89 c8 4c 8b 4c 24 08 0f 05 <48> 3d 01 f0 ff ff
> > 0f 83 fb 13 fc ff c3 66 2e 0f 1f 84 00 00 00 00
> > RSP: 002b:00007fff3613dbf8 EFLAGS: 00000217 ORIG_RAX: 0000000000000010
> > RAX: ffffffffffffffda RBX: 00000000004002c8 RCX: 0000000000440099
> > RDX: 00000
> >
> >
> > ---
> > This bug is generated by a bot. It may contain errors.
> > See https://goo.gl/tpsmEJ for more information about syzbot.
> > syzbot engineers can be reached at syzkaller@googlegroups.com.
> >
> > syzbot will keep track of this bug report. See:
> > https://goo.gl/tpsmEJ#bug-status-tracking for how to communicate with
> > syzbot.
> > syzbot can test patches for this bug, for details see:
> > https://goo.gl/tpsmEJ#testing-patches
> >
>
> --
> You received this message because you are subscribed to the Google Groups "syzkaller-bugs" group.
> To unsubscribe from this group and stop receiving emails from it, send an email to syzkaller-bugs+unsubscribe@googlegroups.com.
> To view this discussion on the web visit https://groups.google.com/d/msgid/syzkaller-bugs/20180810161848.GB16533%40bombadil.infradead.org.
> For more options, visit https://groups.google.com/d/optout.

--00000000000084ecc605800c638f
Content-Type: text/x-patch; charset="US-ASCII"; name="ashmem.patch"
Content-Disposition: attachment; filename="ashmem.patch"
Content-Transfer-Encoding: base64
Content-ID: <f_jr7tt1qp0>
X-Attachment-Id: f_jr7tt1qp0

ZGlmZiAtLWdpdCBhL2RyaXZlcnMvc3RhZ2luZy9hbmRyb2lkL2FzaG1lbS5jIGIvZHJpdmVycy9z
dGFnaW5nL2FuZHJvaWQvYXNobWVtLmMKaW5kZXggOTBhOGE5ZjFhYzdkLi4xYTg5MGM0M2ExMGEg
MTAwNjQ0Ci0tLSBhL2RyaXZlcnMvc3RhZ2luZy9hbmRyb2lkL2FzaG1lbS5jCisrKyBiL2RyaXZl
cnMvc3RhZ2luZy9hbmRyb2lkL2FzaG1lbS5jCkBAIC03NSw2ICs3NSwxNyBAQCBzdHJ1Y3QgYXNo
bWVtX3JhbmdlIHsKIC8qIExSVSBsaXN0IG9mIHVucGlubmVkIHBhZ2VzLCBwcm90ZWN0ZWQgYnkg
YXNobWVtX211dGV4ICovCiBzdGF0aWMgTElTVF9IRUFEKGFzaG1lbV9scnVfbGlzdCk7CiAKK3N0
YXRpYyBzdHJ1Y3Qgd29ya3F1ZXVlX3N0cnVjdCAqYXNobWVtX3dxOworc3RhdGljIGF0b21pY190
IGFzaG1lbV9zaHJpbmtfaW5mbGlnaHQgPSBBVE9NSUNfSU5JVCgwKTsKK3N0YXRpYyBERUNMQVJF
X1dBSVRfUVVFVUVfSEVBRChhc2htZW1fc2hyaW5rX3dhaXQpOworCitzdHJ1Y3QgYXNobWVtX3No
cmlua193b3JrIHsKKwlzdHJ1Y3Qgd29ya19zdHJ1Y3Qgd29yazsKKwlzdHJ1Y3QgZmlsZSAqZmls
ZTsKKwlsb2ZmX3Qgc3RhcnQ7CisJbG9mZl90IGVuZDsKK307CisKIC8qCiAgKiBsb25nIGxydV9j
b3VudCAtIFRoZSBjb3VudCBvZiBwYWdlcyBvbiBvdXIgTFJVIGxpc3QuCiAgKgpAQCAtMjkyLDYg
KzMwMyw3IEBAIHN0YXRpYyBzc2l6ZV90IGFzaG1lbV9yZWFkX2l0ZXIoc3RydWN0IGtpb2NiICpp
b2NiLCBzdHJ1Y3QgaW92X2l0ZXIgKml0ZXIpCiAJaW50IHJldCA9IDA7CiAKIAltdXRleF9sb2Nr
KCZhc2htZW1fbXV0ZXgpOworCXdhaXRfZXZlbnQoYXNobWVtX3Nocmlua193YWl0LCAhYXRvbWlj
X3JlYWQoJmFzaG1lbV9zaHJpbmtfaW5mbGlnaHQpKTsKIAogCS8qIElmIHNpemUgaXMgbm90IHNl
dCwgb3Igc2V0IHRvIDAsIGFsd2F5cyByZXR1cm4gRU9GLiAqLwogCWlmIChhc21hLT5zaXplID09
IDApCkBAIC0zNTksNiArMzcxLDcgQEAgc3RhdGljIGludCBhc2htZW1fbW1hcChzdHJ1Y3QgZmls
ZSAqZmlsZSwgc3RydWN0IHZtX2FyZWFfc3RydWN0ICp2bWEpCiAJaW50IHJldCA9IDA7CiAKIAlt
dXRleF9sb2NrKCZhc2htZW1fbXV0ZXgpOworCXdhaXRfZXZlbnQoYXNobWVtX3Nocmlua193YWl0
LCAhYXRvbWljX3JlYWQoJmFzaG1lbV9zaHJpbmtfaW5mbGlnaHQpKTsKIAogCS8qIHVzZXIgbmVl
ZHMgdG8gU0VUX1NJWkUgYmVmb3JlIG1hcHBpbmcgKi8KIAlpZiAoIWFzbWEtPnNpemUpIHsKQEAg
LTQyMSw2ICs0MzQsMTkgQEAgc3RhdGljIGludCBhc2htZW1fbW1hcChzdHJ1Y3QgZmlsZSAqZmls
ZSwgc3RydWN0IHZtX2FyZWFfc3RydWN0ICp2bWEpCiAJcmV0dXJuIHJldDsKIH0KIAorc3RhdGlj
IHZvaWQgYXNobWVtX3Nocmlua193b3JrZXIoc3RydWN0IHdvcmtfc3RydWN0ICp3b3JrKQorewor
CXN0cnVjdCBhc2htZW1fc2hyaW5rX3dvcmsgKncgPSBjb250YWluZXJfb2Yod29yaywgdHlwZW9m
KCp3KSwgd29yayk7CisKKwl3LT5maWxlLT5mX29wLT5mYWxsb2NhdGUody0+ZmlsZSwKKwkJCQkg
RkFMTE9DX0ZMX1BVTkNIX0hPTEUgfCBGQUxMT0NfRkxfS0VFUF9TSVpFLAorCQkJCSB3LT5zdGFy
dCwgdy0+ZW5kIC0gdy0+c3RhcnQpOworCWZwdXQody0+ZmlsZSk7CisJa2ZyZWUodyk7CisJaWYg
KGF0b21pY19kZWNfYW5kX3Rlc3QoJmFzaG1lbV9zaHJpbmtfaW5mbGlnaHQpKQorCQl3YWtlX3Vw
X2FsbCgmYXNobWVtX3Nocmlua193YWl0KTsKK30KKwogLyoKICAqIGFzaG1lbV9zaHJpbmsgLSBv
dXIgY2FjaGUgc2hyaW5rZXIsIGNhbGxlZCBmcm9tIG1tL3Ztc2Nhbi5jCiAgKgpAQCAtNDQ5LDEy
ICs0NzUsMTggQEAgYXNobWVtX3Nocmlua19zY2FuKHN0cnVjdCBzaHJpbmtlciAqc2hyaW5rLCBz
dHJ1Y3Qgc2hyaW5rX2NvbnRyb2wgKnNjKQogCQlyZXR1cm4gLTE7CiAKIAlsaXN0X2Zvcl9lYWNo
X2VudHJ5X3NhZmUocmFuZ2UsIG5leHQsICZhc2htZW1fbHJ1X2xpc3QsIGxydSkgewotCQlsb2Zm
X3Qgc3RhcnQgPSByYW5nZS0+cGdzdGFydCAqIFBBR0VfU0laRTsKLQkJbG9mZl90IGVuZCA9IChy
YW5nZS0+cGdlbmQgKyAxKSAqIFBBR0VfU0laRTsKKwkJc3RydWN0IGFzaG1lbV9zaHJpbmtfd29y
ayAqdyA9IGt6YWxsb2Moc2l6ZW9mKCp3KSwgR0ZQX0FUT01JQyk7CisKKwkJaWYgKCF3KQorCQkJ
YnJlYWs7CisJCUlOSVRfV09SSygmdy0+d29yaywgYXNobWVtX3Nocmlua193b3JrZXIpOworCQl3
LT5maWxlID0gcmFuZ2UtPmFzbWEtPmZpbGU7CisJCWdldF9maWxlKHctPmZpbGUpOworCQl3LT5z
dGFydCA9IHJhbmdlLT5wZ3N0YXJ0ICogUEFHRV9TSVpFOworCQl3LT5lbmQgPSAocmFuZ2UtPnBn
ZW5kICsgMSkgKiBQQUdFX1NJWkU7CisJCWF0b21pY19pbmMoJmFzaG1lbV9zaHJpbmtfaW5mbGln
aHQpOworCQlxdWV1ZV93b3JrKGFzaG1lbV93cSwgJnctPndvcmspOwogCi0JCXJhbmdlLT5hc21h
LT5maWxlLT5mX29wLT5mYWxsb2NhdGUocmFuZ2UtPmFzbWEtPmZpbGUsCi0JCQkJRkFMTE9DX0ZM
X1BVTkNIX0hPTEUgfCBGQUxMT0NfRkxfS0VFUF9TSVpFLAotCQkJCXN0YXJ0LCBlbmQgLSBzdGFy
dCk7CiAJCXJhbmdlLT5wdXJnZWQgPSBBU0hNRU1fV0FTX1BVUkdFRDsKIAkJbHJ1X2RlbChyYW5n
ZSk7CiAKQEAgLTcxMyw2ICs3NDUsNyBAQCBzdGF0aWMgaW50IGFzaG1lbV9waW5fdW5waW4oc3Ry
dWN0IGFzaG1lbV9hcmVhICphc21hLCB1bnNpZ25lZCBsb25nIGNtZCwKIAkJcmV0dXJuIC1FRkFV
TFQ7CiAKIAltdXRleF9sb2NrKCZhc2htZW1fbXV0ZXgpOworCXdhaXRfZXZlbnQoYXNobWVtX3No
cmlua193YWl0LCAhYXRvbWljX3JlYWQoJmFzaG1lbV9zaHJpbmtfaW5mbGlnaHQpKTsKIAogCWlm
ICghYXNtYS0+ZmlsZSkKIAkJZ290byBvdXRfdW5sb2NrOwpAQCAtODgzLDggKzkxNiwxNSBAQCBz
dGF0aWMgaW50IF9faW5pdCBhc2htZW1faW5pdCh2b2lkKQogCQlnb3RvIG91dF9mcmVlMjsKIAl9
CiAKKwlhc2htZW1fd3EgPSBhbGxvY193b3JrcXVldWUoImFzaG1lbV93cSIsIFdRX01FTV9SRUNM
QUlNLCAwKTsKKwlpZiAoIWFzaG1lbV93cSkgeworCQlwcl9lcnIoImZhaWxlZCB0byBjcmVhdGUg
d29ya3F1ZXVlXG4iKTsKKwkJZ290byBvdXRfZGVtaXNjOworCX0KKwogCXJldCA9IHJlZ2lzdGVy
X3Nocmlua2VyKCZhc2htZW1fc2hyaW5rZXIpOwogCWlmIChyZXQpIHsKKwkJZGVzdHJveV93b3Jr
cXVldWUoYXNobWVtX3dxKTsKIAkJcHJfZXJyKCJmYWlsZWQgdG8gcmVnaXN0ZXIgc2hyaW5rZXIh
XG4iKTsKIAkJZ290byBvdXRfZGVtaXNjOwogCX0K
--00000000000084ecc605800c638f--
