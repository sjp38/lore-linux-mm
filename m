Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id A874A6B0343
	for <linux-mm@kvack.org>; Thu, 23 Mar 2017 10:49:10 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id n11so224946069pfg.7
        for <linux-mm@kvack.org>; Thu, 23 Mar 2017 07:49:10 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id l12si5920134plc.299.2017.03.23.07.49.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 23 Mar 2017 07:49:09 -0700 (PDT)
Received: from fsav402.sakura.ne.jp (fsav402.sakura.ne.jp [133.242.250.101])
	by www262.sakura.ne.jp (8.14.5/8.14.5) with ESMTP id v2NEn8c6064539
	for <linux-mm@kvack.org>; Thu, 23 Mar 2017 23:49:08 +0900 (JST)
	(envelope-from penguin-kernel@I-love.SAKURA.ne.jp)
Received: from AQUA (softbank126227147111.bbtec.net [126.227.147.111])
	(authenticated bits=0)
	by www262.sakura.ne.jp (8.14.5/8.14.5) with ESMTP id v2NEn7M4064535
	for <linux-mm@kvack.org>; Thu, 23 Mar 2017 23:49:08 +0900 (JST)
	(envelope-from penguin-kernel@I-love.SAKURA.ne.jp)
Subject: [4.11-rc3] BUG: sleeping function called from invalid context at mm/vmalloc.c:1480
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-Id: <201703232349.BGB95898.QHLVFFOMtFOOJS@I-love.SAKURA.ne.jp>
Date: Thu, 23 Mar 2017 23:49:06 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

Is this a known problem?

[    2.545698] scsi target2:0:0: Domain Validation skipping write tests
[    2.545701] scsi target2:0:0: Ending Domain Validation
[    2.545759] scsi target2:0:0: FAST-40 WIDE SCSI 80.0 MB/s ST (25 ns, offset 127)
[    2.560545] [drm] Fifo max 0x00040000 min 0x00001000 cap 0x0000077f
[    2.563036] [drm] Using command buffers with DMA pool.
[    2.563050] [drm] DX: no.
[    2.582553] fbcon: svgadrmfb (fb0) is primary device
[    2.593178] Console: switching to colour frame buffer device 160x48
[    2.609598] [drm] Initialized vmwgfx 2.12.0 20170221 for 0000:00:0f.0 on minor 0
[    2.616064] BUG: sleeping function called from invalid context at mm/vmalloc.c:1480
[    2.616125] in_atomic(): 1, irqs_disabled(): 0, pid: 341, name: plymouthd
[    2.616156] 2 locks held by plymouthd/341:
[    2.616158]  #0:  (drm_global_mutex){+.+.+.}, at: [<ffffffffc01c274b>] drm_release+0x3b/0x3b0 [drm]
[    2.616256]  #1:  (&(&tfile->lock)->rlock){+.+...}, at: [<ffffffffc0173038>] ttm_object_file_release+0x28/0x90 [ttm]
[    2.616270] CPU: 2 PID: 341 Comm: plymouthd Not tainted 4.11.0-0.rc3.git0.1.kmallocwd.fc25.x86_64+debug #1
[    2.616271] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[    2.616273] Call Trace:
[    2.616281]  dump_stack+0x86/0xc3
[    2.616285]  ___might_sleep+0x17d/0x250
[    2.616289]  __might_sleep+0x4a/0x80
[    2.616293]  remove_vm_area+0x22/0x90
[    2.616296]  __vunmap+0x2e/0x110
[    2.616299]  vfree+0x42/0x90
[    2.616304]  kvfree+0x2c/0x40
[    2.616312]  drm_ht_remove+0x1a/0x30 [drm]
[    2.616317]  ttm_object_file_release+0x50/0x90 [ttm]
[    2.616324]  vmw_postclose+0x47/0x60 [vmwgfx]
[    2.616331]  drm_release+0x290/0x3b0 [drm]
[    2.616338]  __fput+0xf8/0x210
[    2.616342]  ____fput+0xe/0x10
[    2.616345]  task_work_run+0x85/0xc0
[    2.616351]  exit_to_usermode_loop+0xb4/0xc0
[    2.616355]  do_syscall_64+0x185/0x1f0
[    2.616359]  entry_SYSCALL64_slow_path+0x25/0x25
[    2.616362] RIP: 0033:0x7f7bf114d260
[    2.616364] RSP: 002b:00007ffc984e3538 EFLAGS: 00000246 ORIG_RAX: 0000000000000003
[    2.616366] RAX: 0000000000000000 RBX: 00005605e7a90140 RCX: 00007f7bf114d260
[    2.616368] RDX: 00005605e7a900f0 RSI: 00007f7bf1415ae8 RDI: 0000000000000009
[    2.616369] RBP: 0000000000000009 R08: 00005605e7a90140 R09: 0000000000000000
[    2.616371] R10: 00005605e7a90100 R11: 0000000000000246 R12: 000000000000e280
[    2.616373] R13: 00007f7bf1b42970 R14: 00007f7bf1b428e0 R15: 000000000000000d
[    2.627007] sd 2:0:0:0: [sda] 83886080 512-byte logical blocks: (42.9 GB/40.0 GiB)
[    2.627132] sd 2:0:0:0: [sda] Write Protect is off
[    2.627135] sd 2:0:0:0: [sda] Mode Sense: 61 00 00 00
[    2.627214] sd 2:0:0:0: [sda] Cache data unavailable
[    2.627217] sd 2:0:0:0: [sda] Assuming drive cache: write through
[    2.630509] sd 2:0:0:0: Attached scsi generic sg1 type 0
[    2.630600]  sda: sda1
[    2.631414] sd 2:0:0:0: [sda] Attached SCSI disk

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
