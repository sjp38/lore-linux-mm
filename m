Return-Path: <SRS0=cFM0=SE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_PASS,
	UPPERCASE_50_75,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DE3A0C4360F
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 14:55:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2D2882075E
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 14:55:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2D2882075E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B168F6B026C; Tue,  2 Apr 2019 10:55:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A9BCA6B0270; Tue,  2 Apr 2019 10:55:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7B5C86B0277; Tue,  2 Apr 2019 10:55:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 02A486B026C
	for <linux-mm@kvack.org>; Tue,  2 Apr 2019 10:55:24 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id f7so3692537pfd.7
        for <linux-mm@kvack.org>; Tue, 02 Apr 2019 07:55:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:user-agent:mime-version;
        bh=IzEzQZhvaX133+Ml1pIAbVL/QFLq2aLwfewiCs5QXPk=;
        b=B7FsF+S9QiGqI2QNN8h861zeVsAKk8cQ3f6J2gghK7Y/WjJ6e9CGLTI0J7UGffBUr/
         Dfp4FqnIRgfyXeMHbKTVfkB3BFo0I4EMgTr5qxBoqqehb4A7l+7fIq5YyHCeKcIbOAL7
         taulzxK5w8hS03CnLbuHBVWInXg1s+legJ0xlHG0DhOi479UtNwE1QYEbTCh4Mtr8qcG
         fyLYTSiN6wMZyyq3tY2/I/U5Fz0AncBWbnT+SAfDMiawb2TMj98o3wk/h5MEf2ONUraJ
         lk/ZS9V48zCAfIgxv9o7okC6FrxgzBvqb62EP/8z+g+k9yKkNnpDBzxZcGIz39g8/RpV
         IwGA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of lkp@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=lkp@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWmiE+27kSphKLMO8w6ZaXZttf+qgQsCv+3ZQOPXbGd0nPi8xr+
	JoADkCt24cdjA5vUFjN6x8mDK2q9Xq9mb0fdGI8kh8Haj1xenhXYPgF9juXebHiXM/l+jm9jckS
	Xj8UpswbiegPI2Uv93o1qDXRP7HEkL33dx+b/8aSM3M0IARtwT/8g7zR67CWhN9YyPg==
X-Received: by 2002:a63:3190:: with SMTP id x138mr59769368pgx.273.1554216923348;
        Tue, 02 Apr 2019 07:55:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx2XXYc5uZ3juP1r22H0ilAasfJk3BRdQYj2IeajOF3XewxuvU/fHMQFp50/0zucYDySq2I
X-Received: by 2002:a63:3190:: with SMTP id x138mr59769184pgx.273.1554216920508;
        Tue, 02 Apr 2019 07:55:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554216920; cv=none;
        d=google.com; s=arc-20160816;
        b=hH9CouwG7CUDHEtlOXL+saIdIkYOjiQzeJoMaWHjDkoJgydEVdi11NOapgzRHPbbh2
         FJwxS0wYOJLx8+tx/POKrpCd6xwZAoAPxwXRySWG9BXfK4vIvhpS0M7xI4xihkdOo6UB
         gibisPmT4MkOX8fGqS+ICda4ve0b2h5xjJczFS2GhKZ31aIcmBoGjh51P22jVhjQ3Gxf
         nB1JkwQow51cQnAi1UwUPbqIEOhHnQgaOmzL2ws7AX33s/0HOlmXP8xeRs0EgD+RP/8v
         dbivSBiXu0k/N25Mk7rrP1Wqsb7oGxraHdN/uPu/G0wNnpdDvPaQ16LnJNU5EZtapW98
         Z82A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:message-id:subject:cc:to:from:date;
        bh=IzEzQZhvaX133+Ml1pIAbVL/QFLq2aLwfewiCs5QXPk=;
        b=SaRK17xPWiYjFVhguB+lwniBgwtO6OybZCt9glTCaam4WJis3R6lpFkffruDtc3oZo
         hvdKnhmVCmvGT3uN66AYjrUERJYfLWHC7TO5L4o5bm5PMBvfaQOO7NNs4wfECmdvhxkU
         FSQw6x0BHrRMrCTHTbzWP3dhSMYBvazVk3DhvsCtxXm//I+xT0nYgELZT56IXgSQltbE
         zPg/5twJbaF3JbqJ9/Mo1wGqu8k3v0kQX6hNxV/lH4vRrp5tt/mgLbE895Q8CTFXNytG
         BgFVOG/9Vaf7z4Jmf81/90XxXsZRAT+Hc4iw2W4gZX0zw1pzglSALtC38Dux3EZbH03y
         x8uA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of lkp@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=lkp@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id h6si10855141pgv.302.2019.04.02.07.55.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Apr 2019 07:55:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of lkp@intel.com designates 134.134.136.126 as permitted sender) client-ip=134.134.136.126;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of lkp@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=lkp@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from orsmga003.jf.intel.com ([10.7.209.27])
  by orsmga106.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 02 Apr 2019 07:55:19 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,301,1549958400"; 
   d="gz'50?scan'50,208,50";a="139348379"
Received: from lkp-server01.sh.intel.com (HELO lkp-server01) ([10.239.97.150])
  by orsmga003.jf.intel.com with ESMTP; 02 Apr 2019 07:55:16 -0700
Received: from kbuild by lkp-server01 with local (Exim 4.89)
	(envelope-from <lkp@intel.com>)
	id 1hBKol-00029f-S8; Tue, 02 Apr 2019 22:55:15 +0800
Date: Tue, 02 Apr 2019 22:54:30 +0800
From: kernel test robot <lkp@intel.com>
To: Alexey Dobriyan <adobriyan@gmail.com>
Cc: LKP <lkp@01.org>, linux-kernel@vger.kernel.org,
 linux-fsdevel@vger.kernel.org,
 Linux Memory Management List <linux-mm@kvack.org>,
 Andrew Morton <akpm@linux-foundation.org>
Subject: b050de0f98 ("fs/binfmt_elf.c: free PT_INTERP filename ASAP"):
  BUG: KASAN: null-ptr-deref in allow_write_access
Message-ID: <5ca377a6.5zcN4o4WezY4tfcr%lkp@intel.com>
User-Agent: Heirloom mailx 12.5 6/20/10
MIME-Version: 1.0
Content-Type: multipart/mixed;
 boundary="=_5ca377a6.ZZqfGciG6/4JVKZEmeGRBorWklLUtD9K5yVHOEQoZUisX0pQ"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.

--=_5ca377a6.ZZqfGciG6/4JVKZEmeGRBorWklLUtD9K5yVHOEQoZUisX0pQ
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Greetings,

0day kernel testing robot got the below dmesg and the first bad commit is

https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master

commit b050de0f986606011986698de504c0dbc12c40dc
Author:     Alexey Dobriyan <adobriyan@gmail.com>
AuthorDate: Fri Mar 29 10:02:05 2019 +1100
Commit:     Stephen Rothwell <sfr@canb.auug.org.au>
CommitDate: Sat Mar 30 16:09:51 2019 +1100

    fs/binfmt_elf.c: free PT_INTERP filename ASAP
    
    There is no reason for PT_INTERP filename to linger till the end of
    the whole loading process.
    
    Link: http://lkml.kernel.org/r/20190314204953.GD18143@avx2
    Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
    Reviewed-by: Andrew Morton <akpm@linux-foundation.org>
    Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
    Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>

46238614d8  fs/binfmt_elf.c: make scope of "pos" variable smaller
b050de0f98  fs/binfmt_elf.c: free PT_INTERP filename ASAP
05d08e2995  Add linux-next specific files for 20190402
+---------------------------------------------------------------+------------+------------+---------------+
|                                                               | 46238614d8 | b050de0f98 | next-20190402 |
+---------------------------------------------------------------+------------+------------+---------------+
| boot_successes                                                | 7          | 0          | 0             |
| boot_failures                                                 | 10         | 12         | 13            |
| invoked_oom-killer:gfp_mask=0x                                | 2          |            |               |
| Mem-Info                                                      | 2          |            |               |
| BUG:KASAN:slab-out-of-bounds_in_d                             | 1          |            |               |
| PANIC:double_fault                                            | 1          |            |               |
| WARNING:stack_going_in_the_wrong_direction?ip=double_fault/0x | 1          |            |               |
| RIP:lockdep_hardirqs_off                                      | 1          |            |               |
| Kernel_panic-not_syncing:Machine_halted                       | 1          |            |               |
| RIP:perf_trace_x86_exceptions                                 | 1          |            |               |
| BUG:soft_lockup-CPU##stuck_for#s                              | 7          | 6          | 3             |
| RIP:__slab_alloc                                              | 3          | 0          | 1             |
| Kernel_panic-not_syncing:softlockup:hung_tasks                | 7          | 6          | 3             |
| RIP:_raw_spin_unlock_irqrestore                               | 3          | 1          |               |
| RIP:__asan_load8                                              | 1          | 3          |               |
| RIP:copy_user_generic_unrolled                                | 1          |            |               |
| Out_of_memory_and_no_killable_processes                       | 1          |            |               |
| Kernel_panic-not_syncing:System_is_deadlocked_on_memory       | 1          |            |               |
| BUG:KASAN:null-ptr-deref_in_a                                 | 0          | 6          | 10            |
| BUG:unable_to_handle_kernel                                   | 0          | 6          | 10            |
| Oops:#[##]                                                    | 0          | 6          | 10            |
| RIP:allow_write_access                                        | 0          | 6          | 10            |
| Kernel_panic-not_syncing:Fatal_exception                      | 0          | 6          | 10            |
| RIP:__orc_find                                                | 0          | 1          | 1             |
| RIP:arch_local_irq_save                                       | 0          | 1          |               |
| RIP:__asan_load1                                              | 0          | 0          | 1             |
+---------------------------------------------------------------+------------+------------+---------------+

/etc/rcS.d/S00fbsetup: line 3: /sbin/modprobe: not found
Starting udev
[   43.717047] gfs2: path_lookup on rootfs returned error -2
Kernel tests: Boot OK!
[   45.270185] ==================================================================
[   45.277229] BUG: KASAN: null-ptr-deref in allow_write_access+0x12/0x30
[   45.281161] Read of size 8 at addr 000000000000001e by task 90-trinity/625
[   45.284197] 
[   45.285252] CPU: 0 PID: 625 Comm: 90-trinity Not tainted 5.1.0-rc2-00406-gb050de0 #1
[   45.287960] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1 04/01/2014
[   45.288419] BUG: unable to handle kernel NULL pointer dereference at 000000000000001e
[   45.297363] Call Trace:
[   45.297376]  dump_stack+0x74/0xb0
[   45.300404] #PF error: [normal kernel read fault]
[   45.301648]  ? allow_write_access+0x12/0x30
[   45.303103] PGD 800000000af92067 P4D 800000000af92067 PUD 9870067 PMD 0 
[   45.303117] Oops: 0000 [#1] SMP KASAN PTI
[   45.303124] CPU: 1 PID: 626 Comm: 90-trinity Not tainted 5.1.0-rc2-00406-gb050de0 #1
[   45.303128] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1 04/01/2014
[   45.303137] RIP: 0010:allow_write_access+0x12/0x30
[   45.303145] Code: 01 c5 31 c0 48 89 ef f3 ab 48 83 c4 60 89 d0 5b 5d 41 5c 41 5d 41 5e c3 48 85 ff 74 2a 53 48 89 fb 48 8d 7f 20 e8 7d 89 f6 ff <48> 8b 5b 20 be 04 00 00 00 48 8d bb d0 01 00 00 e8 00 6e f6 ff f0
[   45.303149] RSP: 0000:ffff888009ad7c68 EFLAGS: 00010247
[   45.303155] RAX: 0000000000000001 RBX: fffffffffffffffe RCX: ffffffff81307b8f
[   45.303158] RDX: 0000000000000000 RSI: 0000000000000008 RDI: 000000000000001e
[   45.303162] RBP: ffff88800a1410a3 R08: 0000000000000007 R09: 0000000000000007
[   45.303167] R10: ffffed1001d656f7 R11: 0000000000000000 R12: 0000000000000000
[   45.303171] R13: ffff88800a141088 R14: ffff88800de7d140 R15: ffff88800b2352c8
[   45.303177] FS:  00007f4f532d6700(0000) GS:ffff88800eb00000(0000) knlGS:0000000000000000
[   45.303181] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   45.303185] CR2: 000000000000001e CR3: 000000000a030004 CR4: 00000000003606e0
[   45.303191] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[   45.303195] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
[   45.303198] Call Trace:
[   45.303208]  load_elf_binary+0x1548/0x15ae
[   45.303215]  ? load_misc_binary+0x2aa/0x68c
[   45.303223]  ? mark_held_locks+0x83/0x83
[   45.303230]  ? match_held_lock+0x18/0xf8
[   45.303237]  ? set_fs+0x29/0x29
[   45.303246]  ? cpumask_test_cpu+0x28/0x28
[   45.303255]  search_binary_handler+0xa2/0x20d
[   45.303263]  __do_execve_file+0xa3d/0xe66
[   45.303270]  ? open_exec+0x34/0x34
[   45.303277]  ? strncpy_from_user+0xd9/0x18c
[   45.303284]  do_execve+0x1c/0x1f
[   45.303291]  __x64_sys_execve+0x41/0x48
[   45.303299]  do_syscall_64+0x69/0x85
[   45.303308]  entry_SYSCALL_64_after_hwframe+0x49/0xbe
[   45.303314] RIP: 0033:0x7f4f52ddb807
[   45.303321] Code: 77 19 f4 48 89 d7 44 89 c0 0f 05 48 3d 00 f0 ff ff 76 e0 f7 d8 64 41 89 01 eb d8 f7 d8 64 41 89 01 eb df b8 3b 00 00 00 0f 05 <48> 3d 00 f0 ff ff 77 02 f3 c3 48 8b 15 00 a6 2d 00 f7 d8 64 89 02
[   45.303324] RSP: 002b:00007ffc2f1cae88 EFLAGS: 00000206 ORIG_RAX: 000000000000003b
[   45.303331] RAX: ffffffffffffffda RBX: 00000000006925d8 RCX: 00007f4f52ddb807
[   45.303335] RDX: 0000000000692620 RSI: 00000000006925d8 RDI: 00000000006914d8
[   45.303339] RBP: 0000000000691010 R08: 00000000006914d0 R09: 0101010101010101
[   45.303343] R10: 00007ffc2f1cac10 R11: 0000000000000206 R12: 00000000006914d8
[   45.303347] R13: 0000000000692620 R14: 0000000000692620 R15: 00007ffc2f1ccf60
[   45.303351] Modules linked in:
[   45.303357] CR2: 000000000000001e
[   45.303367] ---[ end trace bbce985a62ebde0d ]---
[   45.303373] RIP: 0010:allow_write_access+0x12/0x30

                                                          # HH:MM RESULT GOOD BAD GOOD_BUT_DIRTY DIRTY_NOT_BAD
git bisect start 05d08e2995cbe6efdb993482ee0d38a77040861a 79a3aaa7b82e3106be97842dedfd8429248896e6 --
git bisect good 2dbd2d8f2c2ccd640f9cb6462e23f0a5ac67e1a2  # 18:33  G     11     0   11  11  Merge remote-tracking branch 'net-next/master'
git bisect good d177ed11c13c43e0f5a289727c0237b9141ca458  # 18:45  G     12     0   11  11  Merge remote-tracking branch 'kvm-arm/next'
git bisect good a1a606c7831374d6ef20ed04c16a76b44f79bcab  # 18:58  G     12     0   11  11  Merge remote-tracking branch 'rpmsg/for-next'
git bisect good f2ea30d060707080d2d5f8532f0efebfa3a04302  # 19:21  G     12     0   11  11  Merge remote-tracking branch 'nvdimm/libnvdimm-for-next'
git bisect good e006c7613228cfa7abefd1c5175e171e6ae2c4b7  # 19:34  G     12     0   11  11  Merge remote-tracking branch 'xarray/xarray'
git bisect good 046b78627faba9a4b85c9f7a0bba764bbbbe76ff  # 19:49  G     12     0   12  12  Merge remote-tracking branch 'devfreq/for-next'
git bisect  bad 1999d633921bdbbf76c7f1065d15ec237a977c02  # 20:05  B      0     9   24   0  Merge branch 'akpm-current/current'
git bisect good 4aa445a97c1da9d169f63377262709254e496f65  # 20:18  G     11     0   10  10  mm: introduce put_user_page*(), placeholder versions
git bisect good f6e06951c4f5f330471530bd12a2b75ed5326005  # 20:37  G     11     0   11  11  lib/plist: rename DEBUG_PI_LIST to DEBUG_PLIST
git bisect  bad ffbb2d4bbda0f0e82531b4a839cee3e6db0eb09f  # 20:52  B      1     6    1   1  autofs: fix some word usage oddities in autofs.txt
git bisect good bc341e1f87c0f100165c5fd2a693d2c90477e322  # 21:21  G     11     0   10  10  lib/test_bitmap.c: switch test_bitmap_parselist to ktime_get()
git bisect good 11d2673e0f90086825df35385fc52d4cc9015c21  # 21:35  G     12     0   11  11  checkpatch: fix something
git bisect good 46238614d8a1a3cde66abc7fd8c4b75c9e4793f3  # 21:51  G     12     0   10  10  fs/binfmt_elf.c: make scope of "pos" variable smaller
git bisect  bad 42d4a144a5a5b05b981beb57b5f0891b2eb85b78  # 22:04  B      0    10   25   0  fs/binfmt_elf.c: delete trailing "return;" in functions returning "void"
git bisect  bad b050de0f986606011986698de504c0dbc12c40dc  # 22:21  B      0     1   16   0  fs/binfmt_elf.c: free PT_INTERP filename ASAP
# first bad commit: [b050de0f986606011986698de504c0dbc12c40dc] fs/binfmt_elf.c: free PT_INTERP filename ASAP
git bisect good 46238614d8a1a3cde66abc7fd8c4b75c9e4793f3  # 22:24  G     34     0   27  37  fs/binfmt_elf.c: make scope of "pos" variable smaller
# extra tests with debug options
git bisect  bad b050de0f986606011986698de504c0dbc12c40dc  # 22:34  B      4     8    4   4  fs/binfmt_elf.c: free PT_INTERP filename ASAP
# extra tests on HEAD of linux-next/master
git bisect  bad 05d08e2995cbe6efdb993482ee0d38a77040861a  # 22:34  B      0    10   31   3  Add linux-next specific files for 20190402
# extra tests on tree/branch linux-next/master
git bisect  bad 05d08e2995cbe6efdb993482ee0d38a77040861a  # 22:35  B      0    10   31   3  Add linux-next specific files for 20190402
# extra tests with first bad commit reverted
git bisect good 150238fdb7cd7234ce95fb083866dbf5f70082c9  # 22:53  G     13     0   11  11  Revert "fs/binfmt_elf.c: free PT_INTERP filename ASAP"

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/lkp                          Intel Corporation

--=_5ca377a6.ZZqfGciG6/4JVKZEmeGRBorWklLUtD9K5yVHOEQoZUisX0pQ
Content-Type: application/gzip
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="dmesg-yocto-vm-yocto-118:20190402222110:x86_64-randconfig-s1-04021633:5.1.0-rc2-00406-gb050de0:1.gz"

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

--=_5ca377a6.ZZqfGciG6/4JVKZEmeGRBorWklLUtD9K5yVHOEQoZUisX0pQ
Content-Type: application/gzip
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="dmesg-yocto-vm-yocto-103:20190402215010:x86_64-randconfig-s1-04021633:5.1.0-rc2-00405-g4623861:1.gz"

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

--=_5ca377a6.ZZqfGciG6/4JVKZEmeGRBorWklLUtD9K5yVHOEQoZUisX0pQ
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="reproduce-yocto-vm-yocto-118:20190402222110:x86_64-randconfig-s1-04021633:5.1.0-rc2-00406-gb050de0:1"

#!/bin/bash

kernel=$1
initrd=yocto-trinity-x86_64.cgz

wget --no-clobber https://download.01.org/0day-ci/lkp-qemu/osimage/yocto/$initrd

kvm=(
	qemu-system-x86_64
	-enable-kvm
	-cpu Haswell,+smep,+smap
	-kernel $kernel
	-initrd $initrd
	-m 512
	-smp 2
	-device e1000,netdev=net0
	-netdev user,id=net0
	-boot order=nc
	-no-reboot
	-watchdog i6300esb
	-watchdog-action debug
	-rtc base=localtime
	-serial stdio
	-display none
	-monitor null
)

append=(
	root=/dev/ram0
	hung_task_panic=1
	debug
	apic=debug
	sysrq_always_enabled
	rcupdate.rcu_cpu_stall_timeout=100
	net.ifnames=0
	printk.devkmsg=on
	panic=-1
	softlockup_panic=1
	nmi_watchdog=panic
	oops=panic
	load_ramdisk=2
	prompt_ramdisk=0
	drbd.minor_count=8
	systemd.log_level=err
	ignore_loglevel
	console=tty0
	earlyprintk=ttyS0,115200
	console=ttyS0,115200
	vga=normal
	rw
	drbd.minor_count=8
	rcuperf.shutdown=0
)

"${kvm[@]}" -append "${append[*]}"

--=_5ca377a6.ZZqfGciG6/4JVKZEmeGRBorWklLUtD9K5yVHOEQoZUisX0pQ
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="config-5.1.0-rc2-00406-gb050de0"

#
# Automatically generated file; DO NOT EDIT.
# Linux/x86_64 5.1.0-rc2 Kernel Configuration
#

#
# Compiler: gcc-6 (Debian 6.4.0-9) 6.4.0 20171026
#
CONFIG_CC_IS_GCC=y
CONFIG_GCC_VERSION=60400
CONFIG_CLANG_VERSION=0
CONFIG_CC_HAS_ASM_GOTO=y
CONFIG_CC_HAS_WARN_MAYBE_UNINITIALIZED=y
CONFIG_CC_DISABLE_WARN_MAYBE_UNINITIALIZED=y
CONFIG_CONSTRUCTORS=y
CONFIG_IRQ_WORK=y
CONFIG_BUILDTIME_EXTABLE_SORT=y
CONFIG_THREAD_INFO_IN_TASK=y

#
# General setup
#
CONFIG_INIT_ENV_ARG_LIMIT=32
# CONFIG_COMPILE_TEST is not set
CONFIG_LOCALVERSION=""
CONFIG_LOCALVERSION_AUTO=y
CONFIG_BUILD_SALT=""
CONFIG_HAVE_KERNEL_GZIP=y
CONFIG_HAVE_KERNEL_BZIP2=y
CONFIG_HAVE_KERNEL_LZMA=y
CONFIG_HAVE_KERNEL_XZ=y
CONFIG_HAVE_KERNEL_LZO=y
CONFIG_HAVE_KERNEL_LZ4=y
# CONFIG_KERNEL_GZIP is not set
# CONFIG_KERNEL_BZIP2 is not set
# CONFIG_KERNEL_LZMA is not set
# CONFIG_KERNEL_XZ is not set
# CONFIG_KERNEL_LZO is not set
CONFIG_KERNEL_LZ4=y
CONFIG_DEFAULT_HOSTNAME="(none)"
CONFIG_SWAP=y
# CONFIG_SYSVIPC is not set
# CONFIG_POSIX_MQUEUE is not set
# CONFIG_CROSS_MEMORY_ATTACH is not set
# CONFIG_USELIB is not set
# CONFIG_AUDIT is not set
CONFIG_HAVE_ARCH_AUDITSYSCALL=y

#
# IRQ subsystem
#
CONFIG_GENERIC_IRQ_PROBE=y
CONFIG_GENERIC_IRQ_SHOW=y
CONFIG_GENERIC_IRQ_EFFECTIVE_AFF_MASK=y
CONFIG_GENERIC_PENDING_IRQ=y
CONFIG_GENERIC_IRQ_MIGRATION=y
CONFIG_GENERIC_IRQ_CHIP=y
CONFIG_IRQ_DOMAIN=y
CONFIG_IRQ_DOMAIN_HIERARCHY=y
CONFIG_GENERIC_MSI_IRQ=y
CONFIG_GENERIC_MSI_IRQ_DOMAIN=y
CONFIG_GENERIC_IRQ_MATRIX_ALLOCATOR=y
CONFIG_GENERIC_IRQ_RESERVATION_MODE=y
CONFIG_IRQ_FORCED_THREADING=y
CONFIG_SPARSE_IRQ=y
CONFIG_GENERIC_IRQ_DEBUGFS=y
CONFIG_CLOCKSOURCE_WATCHDOG=y
CONFIG_ARCH_CLOCKSOURCE_DATA=y
CONFIG_ARCH_CLOCKSOURCE_INIT=y
CONFIG_CLOCKSOURCE_VALIDATE_LAST_CYCLE=y
CONFIG_GENERIC_TIME_VSYSCALL=y
CONFIG_GENERIC_CLOCKEVENTS=y
CONFIG_GENERIC_CLOCKEVENTS_BROADCAST=y
CONFIG_GENERIC_CLOCKEVENTS_MIN_ADJUST=y
CONFIG_GENERIC_CMOS_UPDATE=y

#
# Timers subsystem
#
CONFIG_TICK_ONESHOT=y
CONFIG_NO_HZ_COMMON=y
# CONFIG_HZ_PERIODIC is not set
# CONFIG_NO_HZ_IDLE is not set
CONFIG_NO_HZ_FULL=y
CONFIG_CONTEXT_TRACKING=y
CONFIG_CONTEXT_TRACKING_FORCE=y
# CONFIG_NO_HZ is not set
CONFIG_HIGH_RES_TIMERS=y
CONFIG_PREEMPT_NONE=y
# CONFIG_PREEMPT_VOLUNTARY is not set
# CONFIG_PREEMPT is not set
CONFIG_PREEMPT_COUNT=y

#
# CPU/Task time and stats accounting
#
CONFIG_VIRT_CPU_ACCOUNTING=y
CONFIG_VIRT_CPU_ACCOUNTING_GEN=y
CONFIG_IRQ_TIME_ACCOUNTING=y
CONFIG_HAVE_SCHED_AVG_IRQ=y
# CONFIG_BSD_PROCESS_ACCT is not set
# CONFIG_TASKSTATS is not set
CONFIG_PSI=y
CONFIG_PSI_DEFAULT_DISABLED=y
CONFIG_CPU_ISOLATION=y

#
# RCU Subsystem
#
CONFIG_TREE_RCU=y
# CONFIG_RCU_EXPERT is not set
CONFIG_SRCU=y
CONFIG_TREE_SRCU=y
CONFIG_TASKS_RCU=y
CONFIG_RCU_STALL_COMMON=y
CONFIG_RCU_NEED_SEGCBLIST=y
CONFIG_RCU_NOCB_CPU=y
CONFIG_BUILD_BIN2C=y
CONFIG_IKCONFIG=y
CONFIG_IKCONFIG_PROC=y
CONFIG_LOG_BUF_SHIFT=20
CONFIG_LOG_CPU_MAX_BUF_SHIFT=12
CONFIG_PRINTK_SAFE_LOG_BUF_SHIFT=13
CONFIG_HAVE_UNSTABLE_SCHED_CLOCK=y
CONFIG_ARCH_SUPPORTS_NUMA_BALANCING=y
CONFIG_ARCH_WANT_BATCHED_UNMAP_TLB_FLUSH=y
CONFIG_ARCH_SUPPORTS_INT128=y
CONFIG_CGROUPS=y
# CONFIG_MEMCG is not set
CONFIG_BLK_CGROUP=y
CONFIG_DEBUG_BLK_CGROUP=y
CONFIG_CGROUP_SCHED=y
CONFIG_FAIR_GROUP_SCHED=y
# CONFIG_CFS_BANDWIDTH is not set
# CONFIG_RT_GROUP_SCHED is not set
CONFIG_CGROUP_PIDS=y
# CONFIG_CGROUP_RDMA is not set
CONFIG_CGROUP_FREEZER=y
# CONFIG_CPUSETS is not set
# CONFIG_CGROUP_DEVICE is not set
# CONFIG_CGROUP_CPUACCT is not set
CONFIG_CGROUP_PERF=y
CONFIG_CGROUP_BPF=y
# CONFIG_CGROUP_DEBUG is not set
CONFIG_SOCK_CGROUP_DATA=y
CONFIG_NAMESPACES=y
# CONFIG_UTS_NS is not set
CONFIG_USER_NS=y
CONFIG_PID_NS=y
CONFIG_NET_NS=y
# CONFIG_CHECKPOINT_RESTORE is not set
CONFIG_SCHED_AUTOGROUP=y
# CONFIG_SYSFS_DEPRECATED is not set
CONFIG_RELAY=y
CONFIG_BLK_DEV_INITRD=y
CONFIG_INITRAMFS_SOURCE=""
CONFIG_RD_GZIP=y
CONFIG_RD_BZIP2=y
CONFIG_RD_LZMA=y
CONFIG_RD_XZ=y
CONFIG_RD_LZO=y
CONFIG_RD_LZ4=y
# CONFIG_CC_OPTIMIZE_FOR_PERFORMANCE is not set
CONFIG_CC_OPTIMIZE_FOR_SIZE=y
CONFIG_SYSCTL=y
CONFIG_ANON_INODES=y
CONFIG_HAVE_UID16=y
CONFIG_SYSCTL_EXCEPTION_TRACE=y
CONFIG_HAVE_PCSPKR_PLATFORM=y
CONFIG_BPF=y
# CONFIG_EXPERT is not set
CONFIG_UID16=y
CONFIG_MULTIUSER=y
CONFIG_SGETMASK_SYSCALL=y
CONFIG_SYSFS_SYSCALL=y
CONFIG_FHANDLE=y
CONFIG_POSIX_TIMERS=y
CONFIG_PRINTK=y
CONFIG_PRINTK_NMI=y
CONFIG_BUG=y
CONFIG_ELF_CORE=y
CONFIG_PCSPKR_PLATFORM=y
CONFIG_BASE_FULL=y
CONFIG_FUTEX=y
CONFIG_FUTEX_PI=y
CONFIG_EPOLL=y
CONFIG_SIGNALFD=y
CONFIG_TIMERFD=y
CONFIG_EVENTFD=y
CONFIG_SHMEM=y
CONFIG_AIO=y
CONFIG_IO_URING=y
CONFIG_ADVISE_SYSCALLS=y
CONFIG_MEMBARRIER=y
CONFIG_KALLSYMS=y
CONFIG_KALLSYMS_ALL=y
CONFIG_KALLSYMS_ABSOLUTE_PERCPU=y
CONFIG_KALLSYMS_BASE_RELATIVE=y
CONFIG_BPF_SYSCALL=y
# CONFIG_USERFAULTFD is not set
CONFIG_ARCH_HAS_MEMBARRIER_SYNC_CORE=y
CONFIG_RSEQ=y
# CONFIG_EMBEDDED is not set
CONFIG_HAVE_PERF_EVENTS=y

#
# Kernel Performance Events And Counters
#
CONFIG_PERF_EVENTS=y
# CONFIG_DEBUG_PERF_USE_VMALLOC is not set
CONFIG_VM_EVENT_COUNTERS=y
CONFIG_SLUB_DEBUG=y
CONFIG_COMPAT_BRK=y
# CONFIG_SLAB is not set
CONFIG_SLUB=y
# CONFIG_SLAB_MERGE_DEFAULT is not set
# CONFIG_SLAB_FREELIST_RANDOM is not set
CONFIG_SLAB_FREELIST_HARDENED=y
# CONFIG_SHUFFLE_PAGE_ALLOCATOR is not set
# CONFIG_SLUB_CPU_PARTIAL is not set
# CONFIG_PROFILING is not set
CONFIG_TRACEPOINTS=y
CONFIG_64BIT=y
CONFIG_X86_64=y
CONFIG_X86=y
CONFIG_INSTRUCTION_DECODER=y
CONFIG_OUTPUT_FORMAT="elf64-x86-64"
CONFIG_ARCH_DEFCONFIG="arch/x86/configs/x86_64_defconfig"
CONFIG_LOCKDEP_SUPPORT=y
CONFIG_STACKTRACE_SUPPORT=y
CONFIG_MMU=y
CONFIG_ARCH_MMAP_RND_BITS_MIN=28
CONFIG_ARCH_MMAP_RND_BITS_MAX=32
CONFIG_ARCH_MMAP_RND_COMPAT_BITS_MIN=8
CONFIG_ARCH_MMAP_RND_COMPAT_BITS_MAX=16
CONFIG_GENERIC_ISA_DMA=y
CONFIG_GENERIC_BUG=y
CONFIG_GENERIC_BUG_RELATIVE_POINTERS=y
CONFIG_GENERIC_HWEIGHT=y
CONFIG_ARCH_MAY_HAVE_PC_FDC=y
CONFIG_RWSEM_XCHGADD_ALGORITHM=y
CONFIG_GENERIC_CALIBRATE_DELAY=y
CONFIG_ARCH_HAS_CPU_RELAX=y
CONFIG_ARCH_HAS_CACHE_LINE_SIZE=y
CONFIG_ARCH_HAS_FILTER_PGPROT=y
CONFIG_HAVE_SETUP_PER_CPU_AREA=y
CONFIG_NEED_PER_CPU_EMBED_FIRST_CHUNK=y
CONFIG_NEED_PER_CPU_PAGE_FIRST_CHUNK=y
CONFIG_ARCH_HIBERNATION_POSSIBLE=y
CONFIG_ARCH_SUSPEND_POSSIBLE=y
CONFIG_ARCH_WANT_HUGE_PMD_SHARE=y
CONFIG_ARCH_WANT_GENERAL_HUGETLB=y
CONFIG_ZONE_DMA32=y
CONFIG_AUDIT_ARCH=y
CONFIG_ARCH_SUPPORTS_OPTIMIZED_INLINING=y
CONFIG_ARCH_SUPPORTS_DEBUG_PAGEALLOC=y
CONFIG_KASAN_SHADOW_OFFSET=0xdffffc0000000000
CONFIG_X86_64_SMP=y
CONFIG_ARCH_SUPPORTS_UPROBES=y
CONFIG_FIX_EARLYCON_MEM=y
CONFIG_PGTABLE_LEVELS=5
CONFIG_CC_HAS_SANE_STACKPROTECTOR=y

#
# Processor type and features
#
CONFIG_ZONE_DMA=y
CONFIG_SMP=y
CONFIG_X86_FEATURE_NAMES=y
# CONFIG_X86_X2APIC is not set
CONFIG_X86_MPPARSE=y
# CONFIG_GOLDFISH is not set
# CONFIG_RETPOLINE is not set
# CONFIG_X86_CPU_RESCTRL is not set
# CONFIG_X86_EXTENDED_PLATFORM is not set
# CONFIG_X86_INTEL_LPSS is not set
# CONFIG_X86_AMD_PLATFORM_DEVICE is not set
CONFIG_IOSF_MBI=y
CONFIG_IOSF_MBI_DEBUG=y
CONFIG_X86_SUPPORTS_MEMORY_FAILURE=y
# CONFIG_SCHED_OMIT_FRAME_POINTER is not set
CONFIG_HYPERVISOR_GUEST=y
CONFIG_PARAVIRT=y
# CONFIG_PARAVIRT_DEBUG is not set
# CONFIG_PARAVIRT_SPINLOCKS is not set
# CONFIG_XEN is not set
CONFIG_KVM_GUEST=y
# CONFIG_PVH is not set
# CONFIG_KVM_DEBUG_FS is not set
# CONFIG_PARAVIRT_TIME_ACCOUNTING is not set
CONFIG_PARAVIRT_CLOCK=y
# CONFIG_JAILHOUSE_GUEST is not set
# CONFIG_MK8 is not set
# CONFIG_MPSC is not set
# CONFIG_MCORE2 is not set
# CONFIG_MATOM is not set
CONFIG_GENERIC_CPU=y
CONFIG_X86_INTERNODE_CACHE_SHIFT=6
CONFIG_X86_L1_CACHE_SHIFT=6
CONFIG_X86_TSC=y
CONFIG_X86_CMPXCHG64=y
CONFIG_X86_CMOV=y
CONFIG_X86_MINIMUM_CPU_FAMILY=64
CONFIG_X86_DEBUGCTLMSR=y
CONFIG_CPU_SUP_INTEL=y
CONFIG_CPU_SUP_AMD=y
CONFIG_CPU_SUP_HYGON=y
CONFIG_CPU_SUP_CENTAUR=y
CONFIG_HPET_TIMER=y
CONFIG_DMI=y
CONFIG_GART_IOMMU=y
# CONFIG_CALGARY_IOMMU is not set
CONFIG_MAXSMP=y
CONFIG_NR_CPUS_RANGE_BEGIN=8192
CONFIG_NR_CPUS_RANGE_END=8192
CONFIG_NR_CPUS_DEFAULT=8192
CONFIG_NR_CPUS=8192
CONFIG_SCHED_SMT=y
# CONFIG_SCHED_MC is not set
CONFIG_X86_LOCAL_APIC=y
CONFIG_X86_IO_APIC=y
# CONFIG_X86_REROUTE_FOR_BROKEN_BOOT_IRQS is not set
CONFIG_X86_MCE=y
CONFIG_X86_MCELOG_LEGACY=y
CONFIG_X86_MCE_INTEL=y
# CONFIG_X86_MCE_AMD is not set
CONFIG_X86_MCE_THRESHOLD=y
# CONFIG_X86_MCE_INJECT is not set
CONFIG_X86_THERMAL_VECTOR=y

#
# Performance monitoring
#
CONFIG_PERF_EVENTS_INTEL_UNCORE=y
# CONFIG_PERF_EVENTS_INTEL_RAPL is not set
# CONFIG_PERF_EVENTS_INTEL_CSTATE is not set
CONFIG_PERF_EVENTS_AMD_POWER=y
CONFIG_X86_16BIT=y
CONFIG_X86_ESPFIX64=y
CONFIG_X86_VSYSCALL_EMULATION=y
CONFIG_I8K=y
# CONFIG_MICROCODE is not set
CONFIG_X86_MSR=m
CONFIG_X86_CPUID=y
CONFIG_X86_5LEVEL=y
CONFIG_X86_DIRECT_GBPAGES=y
# CONFIG_X86_CPA_STATISTICS is not set
CONFIG_ARCH_HAS_MEM_ENCRYPT=y
# CONFIG_AMD_MEM_ENCRYPT is not set
# CONFIG_NUMA is not set
CONFIG_ARCH_SPARSEMEM_ENABLE=y
CONFIG_ARCH_SPARSEMEM_DEFAULT=y
CONFIG_ARCH_SELECT_MEMORY_MODEL=y
CONFIG_ARCH_MEMORY_PROBE=y
CONFIG_ARCH_PROC_KCORE_TEXT=y
CONFIG_ILLEGAL_POINTER_VALUE=0xdead000000000000
# CONFIG_X86_PMEM_LEGACY is not set
CONFIG_X86_CHECK_BIOS_CORRUPTION=y
# CONFIG_X86_BOOTPARAM_MEMORY_CORRUPTION_CHECK is not set
CONFIG_X86_RESERVE_LOW=64
CONFIG_MTRR=y
CONFIG_MTRR_SANITIZER=y
CONFIG_MTRR_SANITIZER_ENABLE_DEFAULT=0
CONFIG_MTRR_SANITIZER_SPARE_REG_NR_DEFAULT=1
CONFIG_X86_PAT=y
CONFIG_ARCH_USES_PG_UNCACHED=y
CONFIG_ARCH_RANDOM=y
CONFIG_X86_SMAP=y
CONFIG_X86_INTEL_UMIP=y
# CONFIG_X86_INTEL_MPX is not set
# CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS is not set
# CONFIG_EFI is not set
CONFIG_SECCOMP=y
# CONFIG_HZ_100 is not set
CONFIG_HZ_250=y
# CONFIG_HZ_300 is not set
# CONFIG_HZ_1000 is not set
CONFIG_HZ=250
CONFIG_SCHED_HRTICK=y
CONFIG_KEXEC=y
CONFIG_KEXEC_FILE=y
CONFIG_ARCH_HAS_KEXEC_PURGATORY=y
# CONFIG_KEXEC_VERIFY_SIG is not set
CONFIG_CRASH_DUMP=y
CONFIG_PHYSICAL_START=0x1000000
# CONFIG_RELOCATABLE is not set
CONFIG_PHYSICAL_ALIGN=0x200000
CONFIG_DYNAMIC_MEMORY_LAYOUT=y
CONFIG_HOTPLUG_CPU=y
# CONFIG_BOOTPARAM_HOTPLUG_CPU0 is not set
CONFIG_DEBUG_HOTPLUG_CPU0=y
CONFIG_COMPAT_VDSO=y
CONFIG_LEGACY_VSYSCALL_EMULATE=y
# CONFIG_LEGACY_VSYSCALL_NONE is not set
# CONFIG_CMDLINE_BOOL is not set
CONFIG_MODIFY_LDT_SYSCALL=y
CONFIG_HAVE_LIVEPATCH=y
CONFIG_ARCH_HAS_ADD_PAGES=y
CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=y
CONFIG_ARCH_ENABLE_MEMORY_HOTREMOVE=y
CONFIG_ARCH_ENABLE_SPLIT_PMD_PTLOCK=y
CONFIG_ARCH_ENABLE_THP_MIGRATION=y

#
# Power management and ACPI options
#
# CONFIG_SUSPEND is not set
# CONFIG_HIBERNATION is not set
CONFIG_PM=y
# CONFIG_PM_DEBUG is not set
CONFIG_PM_CLK=y
CONFIG_WQ_POWER_EFFICIENT_DEFAULT=y
CONFIG_ENERGY_MODEL=y
CONFIG_ARCH_SUPPORTS_ACPI=y
CONFIG_ACPI=y
CONFIG_ACPI_LEGACY_TABLES_LOOKUP=y
CONFIG_ARCH_MIGHT_HAVE_ACPI_PDC=y
CONFIG_ACPI_SYSTEM_POWER_STATES_SUPPORT=y
# CONFIG_ACPI_DEBUGGER is not set
CONFIG_ACPI_SPCR_TABLE=y
CONFIG_ACPI_LPIT=y
# CONFIG_ACPI_PROCFS_POWER is not set
CONFIG_ACPI_REV_OVERRIDE_POSSIBLE=y
# CONFIG_ACPI_EC_DEBUGFS is not set
CONFIG_ACPI_AC=y
CONFIG_ACPI_BATTERY=y
CONFIG_ACPI_BUTTON=y
CONFIG_ACPI_VIDEO=m
CONFIG_ACPI_FAN=y
# CONFIG_ACPI_DOCK is not set
CONFIG_ACPI_CPU_FREQ_PSS=y
CONFIG_ACPI_PROCESSOR_CSTATE=y
CONFIG_ACPI_PROCESSOR_IDLE=y
CONFIG_ACPI_PROCESSOR=y
CONFIG_ACPI_HOTPLUG_CPU=y
# CONFIG_ACPI_PROCESSOR_AGGREGATOR is not set
CONFIG_ACPI_THERMAL=y
CONFIG_ACPI_CUSTOM_DSDT_FILE=""
CONFIG_ARCH_HAS_ACPI_TABLE_UPGRADE=y
CONFIG_ACPI_TABLE_UPGRADE=y
# CONFIG_ACPI_DEBUG is not set
# CONFIG_ACPI_PCI_SLOT is not set
CONFIG_ACPI_CONTAINER=y
# CONFIG_ACPI_HOTPLUG_MEMORY is not set
CONFIG_ACPI_HOTPLUG_IOAPIC=y
# CONFIG_ACPI_SBS is not set
# CONFIG_ACPI_HED is not set
# CONFIG_ACPI_CUSTOM_METHOD is not set
# CONFIG_ACPI_NFIT is not set
CONFIG_HAVE_ACPI_APEI=y
CONFIG_HAVE_ACPI_APEI_NMI=y
# CONFIG_ACPI_APEI is not set
# CONFIG_DPTF_POWER is not set
# CONFIG_PMIC_OPREGION is not set
# CONFIG_ACPI_CONFIGFS is not set
CONFIG_X86_PM_TIMER=y
# CONFIG_SFI is not set

#
# CPU Frequency scaling
#
CONFIG_CPU_FREQ=y
CONFIG_CPU_FREQ_GOV_ATTR_SET=y
CONFIG_CPU_FREQ_GOV_COMMON=y
# CONFIG_CPU_FREQ_STAT is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_PERFORMANCE is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_POWERSAVE is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_USERSPACE is not set
CONFIG_CPU_FREQ_DEFAULT_GOV_ONDEMAND=y
# CONFIG_CPU_FREQ_DEFAULT_GOV_CONSERVATIVE is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_SCHEDUTIL is not set
CONFIG_CPU_FREQ_GOV_PERFORMANCE=y
CONFIG_CPU_FREQ_GOV_POWERSAVE=y
CONFIG_CPU_FREQ_GOV_USERSPACE=y
CONFIG_CPU_FREQ_GOV_ONDEMAND=y
# CONFIG_CPU_FREQ_GOV_CONSERVATIVE is not set
# CONFIG_CPU_FREQ_GOV_SCHEDUTIL is not set

#
# CPU frequency scaling drivers
#
CONFIG_X86_INTEL_PSTATE=y
# CONFIG_X86_PCC_CPUFREQ is not set
# CONFIG_X86_ACPI_CPUFREQ is not set
# CONFIG_X86_SPEEDSTEP_CENTRINO is not set
CONFIG_X86_P4_CLOCKMOD=y

#
# shared options
#
CONFIG_X86_SPEEDSTEP_LIB=y

#
# CPU Idle
#
CONFIG_CPU_IDLE=y
CONFIG_CPU_IDLE_GOV_LADDER=y
CONFIG_CPU_IDLE_GOV_MENU=y
# CONFIG_CPU_IDLE_GOV_TEO is not set
# CONFIG_INTEL_IDLE is not set

#
# Bus options (PCI etc.)
#
CONFIG_PCI_DIRECT=y
CONFIG_PCI_MMCONFIG=y
CONFIG_MMCONF_FAM10H=y
CONFIG_ISA_DMA_API=y
CONFIG_AMD_NB=y
# CONFIG_X86_SYSFB is not set

#
# Binary Emulations
#
CONFIG_IA32_EMULATION=y
# CONFIG_X86_X32 is not set
CONFIG_COMPAT_32=y
CONFIG_COMPAT=y
CONFIG_COMPAT_FOR_U64_ALIGNMENT=y
CONFIG_X86_DEV_DMA_OPS=y
CONFIG_HAVE_GENERIC_GUP=y

#
# Firmware Drivers
#
# CONFIG_EDD is not set
CONFIG_FIRMWARE_MEMMAP=y
CONFIG_DMIID=y
CONFIG_DMI_SYSFS=m
CONFIG_DMI_SCAN_MACHINE_NON_EFI_FALLBACK=y
# CONFIG_ISCSI_IBFT_FIND is not set
CONFIG_FW_CFG_SYSFS=m
# CONFIG_FW_CFG_SYSFS_CMDLINE is not set
CONFIG_GOOGLE_FIRMWARE=y
# CONFIG_GOOGLE_SMI is not set
# CONFIG_GOOGLE_COREBOOT_TABLE is not set
# CONFIG_GOOGLE_MEMCONSOLE_X86_LEGACY is not set
CONFIG_EFI_EARLYCON=y

#
# Tegra firmware driver
#
CONFIG_HAVE_KVM=y
# CONFIG_VIRTUALIZATION is not set

#
# General architecture-dependent options
#
CONFIG_CRASH_CORE=y
CONFIG_KEXEC_CORE=y
CONFIG_HOTPLUG_SMT=y
CONFIG_HAVE_OPROFILE=y
CONFIG_OPROFILE_NMI_TIMER=y
# CONFIG_KPROBES is not set
# CONFIG_JUMP_LABEL is not set
CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS=y
CONFIG_ARCH_USE_BUILTIN_BSWAP=y
CONFIG_HAVE_IOREMAP_PROT=y
CONFIG_HAVE_KPROBES=y
CONFIG_HAVE_KRETPROBES=y
CONFIG_HAVE_OPTPROBES=y
CONFIG_HAVE_KPROBES_ON_FTRACE=y
CONFIG_HAVE_FUNCTION_ERROR_INJECTION=y
CONFIG_HAVE_NMI=y
CONFIG_HAVE_ARCH_TRACEHOOK=y
CONFIG_HAVE_DMA_CONTIGUOUS=y
CONFIG_GENERIC_SMP_IDLE_THREAD=y
CONFIG_ARCH_HAS_FORTIFY_SOURCE=y
CONFIG_ARCH_HAS_SET_MEMORY=y
CONFIG_HAVE_ARCH_THREAD_STRUCT_WHITELIST=y
CONFIG_ARCH_WANTS_DYNAMIC_TASK_STRUCT=y
CONFIG_HAVE_REGS_AND_STACK_ACCESS_API=y
CONFIG_HAVE_RSEQ=y
CONFIG_HAVE_FUNCTION_ARG_ACCESS_API=y
CONFIG_HAVE_CLK=y
CONFIG_HAVE_HW_BREAKPOINT=y
CONFIG_HAVE_MIXED_BREAKPOINTS_REGS=y
CONFIG_HAVE_USER_RETURN_NOTIFIER=y
CONFIG_HAVE_PERF_EVENTS_NMI=y
CONFIG_HAVE_HARDLOCKUP_DETECTOR_PERF=y
CONFIG_HAVE_PERF_REGS=y
CONFIG_HAVE_PERF_USER_STACK_DUMP=y
CONFIG_HAVE_ARCH_JUMP_LABEL=y
CONFIG_HAVE_ARCH_JUMP_LABEL_RELATIVE=y
CONFIG_HAVE_RCU_TABLE_FREE=y
CONFIG_HAVE_RCU_TABLE_INVALIDATE=y
CONFIG_ARCH_HAVE_NMI_SAFE_CMPXCHG=y
CONFIG_HAVE_ALIGNED_STRUCT_PAGE=y
CONFIG_HAVE_CMPXCHG_LOCAL=y
CONFIG_HAVE_CMPXCHG_DOUBLE=y
CONFIG_ARCH_WANT_COMPAT_IPC_PARSE_VERSION=y
CONFIG_ARCH_WANT_OLD_COMPAT_IPC=y
CONFIG_HAVE_ARCH_SECCOMP_FILTER=y
CONFIG_SECCOMP_FILTER=y
CONFIG_HAVE_ARCH_STACKLEAK=y
CONFIG_HAVE_STACKPROTECTOR=y
CONFIG_CC_HAS_STACKPROTECTOR_NONE=y
# CONFIG_STACKPROTECTOR is not set
CONFIG_HAVE_ARCH_WITHIN_STACK_FRAMES=y
CONFIG_HAVE_CONTEXT_TRACKING=y
CONFIG_HAVE_VIRT_CPU_ACCOUNTING_GEN=y
CONFIG_HAVE_IRQ_TIME_ACCOUNTING=y
CONFIG_HAVE_MOVE_PMD=y
CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE=y
CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD=y
CONFIG_HAVE_ARCH_HUGE_VMAP=y
CONFIG_HAVE_ARCH_SOFT_DIRTY=y
CONFIG_HAVE_MOD_ARCH_SPECIFIC=y
CONFIG_MODULES_USE_ELF_RELA=y
CONFIG_HAVE_IRQ_EXIT_ON_IRQ_STACK=y
CONFIG_ARCH_HAS_ELF_RANDOMIZE=y
CONFIG_HAVE_ARCH_MMAP_RND_BITS=y
CONFIG_HAVE_EXIT_THREAD=y
CONFIG_ARCH_MMAP_RND_BITS=28
CONFIG_HAVE_ARCH_MMAP_RND_COMPAT_BITS=y
CONFIG_ARCH_MMAP_RND_COMPAT_BITS=8
CONFIG_HAVE_ARCH_COMPAT_MMAP_BASES=y
CONFIG_HAVE_COPY_THREAD_TLS=y
CONFIG_HAVE_STACK_VALIDATION=y
CONFIG_HAVE_RELIABLE_STACKTRACE=y
CONFIG_ISA_BUS_API=y
CONFIG_OLD_SIGSUSPEND3=y
CONFIG_COMPAT_OLD_SIGACTION=y
CONFIG_COMPAT_32BIT_TIME=y
CONFIG_HAVE_ARCH_VMAP_STACK=y
CONFIG_ARCH_HAS_STRICT_KERNEL_RWX=y
CONFIG_STRICT_KERNEL_RWX=y
CONFIG_ARCH_HAS_STRICT_MODULE_RWX=y
CONFIG_STRICT_MODULE_RWX=y
CONFIG_ARCH_HAS_REFCOUNT=y
# CONFIG_REFCOUNT_FULL is not set
CONFIG_HAVE_ARCH_PREL32_RELOCATIONS=y
CONFIG_ARCH_USE_MEMREMAP_PROT=y

#
# GCOV-based kernel profiling
#
CONFIG_GCOV_KERNEL=y
CONFIG_ARCH_HAS_GCOV_PROFILE_ALL=y
# CONFIG_GCOV_PROFILE_ALL is not set
CONFIG_GCOV_FORMAT_4_7=y
CONFIG_PLUGIN_HOSTCC="g++"
CONFIG_HAVE_GCC_PLUGINS=y
# CONFIG_GCC_PLUGINS is not set
CONFIG_RT_MUTEXES=y
CONFIG_BASE_SMALL=0
CONFIG_MODULES=y
CONFIG_MODULE_FORCE_LOAD=y
CONFIG_MODULE_UNLOAD=y
# CONFIG_MODULE_FORCE_UNLOAD is not set
# CONFIG_MODVERSIONS is not set
# CONFIG_MODULE_SRCVERSION_ALL is not set
# CONFIG_MODULE_SIG is not set
# CONFIG_MODULE_COMPRESS is not set
# CONFIG_TRIM_UNUSED_KSYMS is not set
CONFIG_MODULES_TREE_LOOKUP=y
CONFIG_BLOCK=y
CONFIG_BLK_SCSI_REQUEST=y
CONFIG_BLK_DEV_BSG=y
CONFIG_BLK_DEV_BSGLIB=y
CONFIG_BLK_DEV_INTEGRITY=y
# CONFIG_BLK_DEV_ZONED is not set
CONFIG_BLK_DEV_THROTTLING=y
CONFIG_BLK_DEV_THROTTLING_LOW=y
CONFIG_BLK_CMDLINE_PARSER=y
# CONFIG_BLK_WBT is not set
CONFIG_BLK_CGROUP_IOLATENCY=y
CONFIG_BLK_DEBUG_FS=y
CONFIG_BLK_SED_OPAL=y

#
# Partition Types
#
# CONFIG_PARTITION_ADVANCED is not set
CONFIG_MSDOS_PARTITION=y
CONFIG_EFI_PARTITION=y
CONFIG_BLOCK_COMPAT=y
CONFIG_BLK_MQ_PCI=y
CONFIG_BLK_MQ_VIRTIO=y
CONFIG_BLK_PM=y

#
# IO Schedulers
#
# CONFIG_MQ_IOSCHED_DEADLINE is not set
CONFIG_MQ_IOSCHED_KYBER=y
CONFIG_IOSCHED_BFQ=m
CONFIG_BFQ_GROUP_IOSCHED=y
CONFIG_ASN1=y
CONFIG_UNINLINE_SPIN_UNLOCK=y
CONFIG_ARCH_SUPPORTS_ATOMIC_RMW=y
CONFIG_MUTEX_SPIN_ON_OWNER=y
CONFIG_RWSEM_SPIN_ON_OWNER=y
CONFIG_LOCK_SPIN_ON_OWNER=y
CONFIG_ARCH_USE_QUEUED_SPINLOCKS=y
CONFIG_QUEUED_SPINLOCKS=y
CONFIG_ARCH_USE_QUEUED_RWLOCKS=y
CONFIG_QUEUED_RWLOCKS=y
CONFIG_ARCH_HAS_SYNC_CORE_BEFORE_USERMODE=y
CONFIG_ARCH_HAS_SYSCALL_WRAPPER=y
CONFIG_FREEZER=y

#
# Executable file formats
#
CONFIG_BINFMT_ELF=y
CONFIG_COMPAT_BINFMT_ELF=y
CONFIG_ELFCORE=y
CONFIG_CORE_DUMP_DEFAULT_ELF_HEADERS=y
CONFIG_BINFMT_SCRIPT=y
CONFIG_BINFMT_MISC=y
CONFIG_COREDUMP=y

#
# Memory Management options
#
CONFIG_SELECT_MEMORY_MODEL=y
CONFIG_SPARSEMEM_MANUAL=y
CONFIG_SPARSEMEM=y
CONFIG_HAVE_MEMORY_PRESENT=y
CONFIG_SPARSEMEM_EXTREME=y
CONFIG_SPARSEMEM_VMEMMAP_ENABLE=y
CONFIG_SPARSEMEM_VMEMMAP=y
CONFIG_HAVE_MEMBLOCK_NODE_MAP=y
CONFIG_ARCH_DISCARD_MEMBLOCK=y
CONFIG_MEMORY_ISOLATION=y
CONFIG_MEMORY_HOTPLUG=y
CONFIG_MEMORY_HOTPLUG_SPARSE=y
# CONFIG_MEMORY_HOTPLUG_DEFAULT_ONLINE is not set
# CONFIG_MEMORY_HOTREMOVE is not set
CONFIG_SPLIT_PTLOCK_CPUS=4
CONFIG_COMPACTION=y
CONFIG_MIGRATION=y
CONFIG_CONTIG_ALLOC=y
CONFIG_PHYS_ADDR_T_64BIT=y
# CONFIG_BOUNCE is not set
CONFIG_VIRT_TO_BUS=y
CONFIG_KSM=y
CONFIG_DEFAULT_MMAP_MIN_ADDR=4096
CONFIG_ARCH_SUPPORTS_MEMORY_FAILURE=y
# CONFIG_MEMORY_FAILURE is not set
CONFIG_TRANSPARENT_HUGEPAGE=y
# CONFIG_TRANSPARENT_HUGEPAGE_ALWAYS is not set
CONFIG_TRANSPARENT_HUGEPAGE_MADVISE=y
CONFIG_ARCH_WANTS_THP_SWAP=y
CONFIG_THP_SWAP=y
CONFIG_TRANSPARENT_HUGE_PAGECACHE=y
CONFIG_CLEANCACHE=y
# CONFIG_FRONTSWAP is not set
CONFIG_CMA=y
CONFIG_CMA_DEBUG=y
CONFIG_CMA_DEBUGFS=y
CONFIG_CMA_AREAS=7
CONFIG_ZPOOL=y
CONFIG_ZBUD=y
# CONFIG_Z3FOLD is not set
CONFIG_ZSMALLOC=m
# CONFIG_PGTABLE_MAPPING is not set
CONFIG_ZSMALLOC_STAT=y
CONFIG_GENERIC_EARLY_IOREMAP=y
# CONFIG_DEFERRED_STRUCT_PAGE_INIT is not set
# CONFIG_IDLE_PAGE_TRACKING is not set
CONFIG_ARCH_HAS_ZONE_DEVICE=y
CONFIG_FRAME_VECTOR=y
# CONFIG_PERCPU_STATS is not set
CONFIG_GUP_BENCHMARK=y
CONFIG_ARCH_HAS_PTE_SPECIAL=y
CONFIG_NET=y
CONFIG_SKB_EXTENSIONS=y

#
# Networking options
#
# CONFIG_PACKET is not set
CONFIG_UNIX=y
CONFIG_UNIX_SCM=y
# CONFIG_UNIX_DIAG is not set
# CONFIG_TLS is not set
CONFIG_XFRM=y
# CONFIG_XFRM_USER is not set
# CONFIG_XFRM_INTERFACE is not set
# CONFIG_XFRM_SUB_POLICY is not set
# CONFIG_XFRM_MIGRATE is not set
# CONFIG_XFRM_STATISTICS is not set
# CONFIG_NET_KEY is not set
# CONFIG_XDP_SOCKETS is not set
CONFIG_INET=y
# CONFIG_IP_MULTICAST is not set
# CONFIG_IP_ADVANCED_ROUTER is not set
CONFIG_IP_PNP=y
CONFIG_IP_PNP_DHCP=y
# CONFIG_IP_PNP_BOOTP is not set
# CONFIG_IP_PNP_RARP is not set
# CONFIG_NET_IPIP is not set
# CONFIG_NET_IPGRE_DEMUX is not set
CONFIG_NET_IP_TUNNEL=y
# CONFIG_SYN_COOKIES is not set
# CONFIG_NET_IPVTI is not set
# CONFIG_NET_FOU is not set
# CONFIG_NET_FOU_IP_TUNNELS is not set
# CONFIG_INET_AH is not set
# CONFIG_INET_ESP is not set
# CONFIG_INET_IPCOMP is not set
CONFIG_INET_TUNNEL=y
CONFIG_INET_XFRM_MODE_TRANSPORT=y
CONFIG_INET_XFRM_MODE_TUNNEL=y
CONFIG_INET_XFRM_MODE_BEET=y
CONFIG_INET_DIAG=y
CONFIG_INET_TCP_DIAG=y
# CONFIG_INET_UDP_DIAG is not set
# CONFIG_INET_RAW_DIAG is not set
# CONFIG_INET_DIAG_DESTROY is not set
# CONFIG_TCP_CONG_ADVANCED is not set
CONFIG_TCP_CONG_CUBIC=y
CONFIG_DEFAULT_TCP_CONG="cubic"
# CONFIG_TCP_MD5SIG is not set
CONFIG_IPV6=y
# CONFIG_IPV6_ROUTER_PREF is not set
# CONFIG_IPV6_OPTIMISTIC_DAD is not set
# CONFIG_INET6_AH is not set
# CONFIG_INET6_ESP is not set
# CONFIG_INET6_IPCOMP is not set
# CONFIG_IPV6_MIP6 is not set
CONFIG_INET6_XFRM_MODE_TRANSPORT=y
CONFIG_INET6_XFRM_MODE_TUNNEL=y
CONFIG_INET6_XFRM_MODE_BEET=y
# CONFIG_INET6_XFRM_MODE_ROUTEOPTIMIZATION is not set
# CONFIG_IPV6_VTI is not set
CONFIG_IPV6_SIT=y
# CONFIG_IPV6_SIT_6RD is not set
CONFIG_IPV6_NDISC_NODETYPE=y
# CONFIG_IPV6_TUNNEL is not set
# CONFIG_IPV6_MULTIPLE_TABLES is not set
# CONFIG_IPV6_MROUTE is not set
# CONFIG_IPV6_SEG6_LWTUNNEL is not set
# CONFIG_IPV6_SEG6_HMAC is not set
# CONFIG_NETWORK_SECMARK is not set
# CONFIG_NETWORK_PHY_TIMESTAMPING is not set
# CONFIG_NETFILTER is not set
# CONFIG_BPFILTER is not set
# CONFIG_IP_DCCP is not set
# CONFIG_IP_SCTP is not set
# CONFIG_RDS is not set
# CONFIG_TIPC is not set
# CONFIG_ATM is not set
# CONFIG_L2TP is not set
# CONFIG_BRIDGE is not set
CONFIG_HAVE_NET_DSA=y
# CONFIG_NET_DSA is not set
# CONFIG_VLAN_8021Q is not set
# CONFIG_DECNET is not set
# CONFIG_LLC2 is not set
# CONFIG_ATALK is not set
# CONFIG_X25 is not set
# CONFIG_LAPB is not set
# CONFIG_PHONET is not set
# CONFIG_6LOWPAN is not set
# CONFIG_IEEE802154 is not set
# CONFIG_NET_SCHED is not set
# CONFIG_DCB is not set
CONFIG_DNS_RESOLVER=m
# CONFIG_BATMAN_ADV is not set
# CONFIG_OPENVSWITCH is not set
# CONFIG_VSOCKETS is not set
# CONFIG_NETLINK_DIAG is not set
# CONFIG_MPLS is not set
# CONFIG_NET_NSH is not set
# CONFIG_HSR is not set
# CONFIG_NET_SWITCHDEV is not set
# CONFIG_NET_L3_MASTER_DEV is not set
# CONFIG_NET_NCSI is not set
CONFIG_RPS=y
CONFIG_RFS_ACCEL=y
CONFIG_XPS=y
# CONFIG_CGROUP_NET_PRIO is not set
# CONFIG_CGROUP_NET_CLASSID is not set
CONFIG_NET_RX_BUSY_POLL=y
CONFIG_BQL=y
# CONFIG_BPF_JIT is not set
# CONFIG_BPF_STREAM_PARSER is not set
CONFIG_NET_FLOW_LIMIT=y

#
# Network testing
#
# CONFIG_NET_PKTGEN is not set
# CONFIG_NET_DROP_MONITOR is not set
# CONFIG_HAMRADIO is not set
# CONFIG_CAN is not set
# CONFIG_BT is not set
# CONFIG_AF_RXRPC is not set
# CONFIG_AF_KCM is not set
CONFIG_WIRELESS=y
# CONFIG_CFG80211 is not set

#
# CFG80211 needs to be enabled for MAC80211
#
CONFIG_MAC80211_STA_HASH_MAX_SIZE=0
# CONFIG_WIMAX is not set
# CONFIG_RFKILL is not set
CONFIG_NET_9P=y
CONFIG_NET_9P_VIRTIO=y
# CONFIG_NET_9P_DEBUG is not set
# CONFIG_CAIF is not set
# CONFIG_CEPH_LIB is not set
# CONFIG_NFC is not set
# CONFIG_PSAMPLE is not set
# CONFIG_NET_IFE is not set
# CONFIG_LWTUNNEL is not set
CONFIG_DST_CACHE=y
CONFIG_GRO_CELLS=y
# CONFIG_NET_DEVLINK is not set
# CONFIG_FAILOVER is not set
CONFIG_HAVE_EBPF_JIT=y

#
# Device Drivers
#
CONFIG_HAVE_EISA=y
CONFIG_EISA=y
CONFIG_EISA_VLB_PRIMING=y
CONFIG_EISA_PCI_EISA=y
CONFIG_EISA_VIRTUAL_ROOT=y
CONFIG_EISA_NAMES=y
CONFIG_HAVE_PCI=y
CONFIG_PCI=y
CONFIG_PCI_DOMAINS=y
CONFIG_PCIEPORTBUS=y
# CONFIG_HOTPLUG_PCI_PCIE is not set
# CONFIG_PCIEAER is not set
CONFIG_PCIEASPM=y
# CONFIG_PCIEASPM_DEBUG is not set
CONFIG_PCIEASPM_DEFAULT=y
# CONFIG_PCIEASPM_POWERSAVE is not set
# CONFIG_PCIEASPM_POWER_SUPERSAVE is not set
# CONFIG_PCIEASPM_PERFORMANCE is not set
CONFIG_PCIE_PME=y
# CONFIG_PCIE_PTM is not set
CONFIG_PCI_MSI=y
CONFIG_PCI_MSI_IRQ_DOMAIN=y
CONFIG_PCI_QUIRKS=y
# CONFIG_PCI_DEBUG is not set
# CONFIG_PCI_REALLOC_ENABLE_AUTO is not set
CONFIG_PCI_STUB=m
CONFIG_PCI_PF_STUB=y
CONFIG_PCI_ATS=y
CONFIG_PCI_LOCKLESS_CONFIG=y
CONFIG_PCI_IOV=y
# CONFIG_PCI_PRI is not set
CONFIG_PCI_PASID=y
CONFIG_PCI_LABEL=y
CONFIG_HOTPLUG_PCI=y
# CONFIG_HOTPLUG_PCI_ACPI is not set
# CONFIG_HOTPLUG_PCI_CPCI is not set
CONFIG_HOTPLUG_PCI_SHPC=y

#
# PCI controller drivers
#

#
# Cadence PCIe controllers support
#
CONFIG_VMD=m

#
# DesignWare PCI Core Support
#
# CONFIG_PCIE_DW_PLAT_HOST is not set
# CONFIG_PCI_MESON is not set

#
# PCI Endpoint
#
# CONFIG_PCI_ENDPOINT is not set

#
# PCI switch controller drivers
#
CONFIG_PCI_SW_SWITCHTEC=y
CONFIG_PCCARD=y
CONFIG_PCMCIA=m
CONFIG_PCMCIA_LOAD_CIS=y
CONFIG_CARDBUS=y

#
# PC-card bridges
#
CONFIG_YENTA=y
CONFIG_YENTA_O2=y
CONFIG_YENTA_RICOH=y
CONFIG_YENTA_TI=y
CONFIG_YENTA_ENE_TUNE=y
CONFIG_YENTA_TOSHIBA=y
# CONFIG_PD6729 is not set
CONFIG_I82092=m
CONFIG_PCCARD_NONSTATIC=y
# CONFIG_RAPIDIO is not set

#
# Generic Driver Options
#
CONFIG_UEVENT_HELPER=y
CONFIG_UEVENT_HELPER_PATH=""
CONFIG_DEVTMPFS=y
# CONFIG_DEVTMPFS_MOUNT is not set
# CONFIG_STANDALONE is not set
# CONFIG_PREVENT_FIRMWARE_BUILD is not set

#
# Firmware loader
#
CONFIG_FW_LOADER=y
CONFIG_EXTRA_FIRMWARE=""
CONFIG_FW_LOADER_USER_HELPER=y
# CONFIG_FW_LOADER_USER_HELPER_FALLBACK is not set
CONFIG_WANT_DEV_COREDUMP=y
CONFIG_ALLOW_DEV_COREDUMP=y
CONFIG_DEV_COREDUMP=y
# CONFIG_DEBUG_DRIVER is not set
CONFIG_DEBUG_DEVRES=y
CONFIG_DEBUG_TEST_DRIVER_REMOVE=y
CONFIG_TEST_ASYNC_DRIVER_PROBE=m
CONFIG_GENERIC_CPU_AUTOPROBE=y
CONFIG_GENERIC_CPU_VULNERABILITIES=y
CONFIG_REGMAP=y
CONFIG_REGMAP_I2C=y
CONFIG_REGMAP_W1=y
CONFIG_REGMAP_MMIO=y
CONFIG_REGMAP_IRQ=y
CONFIG_REGMAP_SCCB=m
CONFIG_DMA_SHARED_BUFFER=y
# CONFIG_DMA_FENCE_TRACE is not set

#
# Bus devices
#
# CONFIG_CONNECTOR is not set
# CONFIG_GNSS is not set
# CONFIG_MTD is not set
# CONFIG_OF is not set
CONFIG_ARCH_MIGHT_HAVE_PC_PARPORT=y
CONFIG_PARPORT=m
CONFIG_PARPORT_PC=m
# CONFIG_PARPORT_PC_FIFO is not set
CONFIG_PARPORT_PC_SUPERIO=y
CONFIG_PARPORT_PC_PCMCIA=m
CONFIG_PARPORT_AX88796=m
# CONFIG_PARPORT_1284 is not set
CONFIG_PARPORT_NOT_PC=y
CONFIG_PNP=y
CONFIG_PNP_DEBUG_MESSAGES=y

#
# Protocols
#
CONFIG_PNPACPI=y
CONFIG_BLK_DEV=y
# CONFIG_BLK_DEV_NULL_BLK is not set
# CONFIG_BLK_DEV_FD is not set
# CONFIG_PARIDE is not set
# CONFIG_BLK_DEV_PCIESSD_MTIP32XX is not set
# CONFIG_ZRAM is not set
# CONFIG_BLK_DEV_UMEM is not set
# CONFIG_BLK_DEV_LOOP is not set
# CONFIG_BLK_DEV_DRBD is not set
# CONFIG_BLK_DEV_NBD is not set
# CONFIG_BLK_DEV_SKD is not set
# CONFIG_BLK_DEV_SX8 is not set
# CONFIG_BLK_DEV_RAM is not set
# CONFIG_CDROM_PKTCDVD is not set
# CONFIG_ATA_OVER_ETH is not set
# CONFIG_VIRTIO_BLK is not set
# CONFIG_BLK_DEV_RBD is not set
# CONFIG_BLK_DEV_RSXX is not set

#
# NVME Support
#
CONFIG_NVME_CORE=y
CONFIG_BLK_DEV_NVME=y
CONFIG_NVME_MULTIPATH=y
CONFIG_NVME_FABRICS=y
CONFIG_NVME_FC=y
# CONFIG_NVME_TCP is not set
CONFIG_NVME_TARGET=y
CONFIG_NVME_TARGET_LOOP=y
CONFIG_NVME_TARGET_FC=m
# CONFIG_NVME_TARGET_FCLOOP is not set
# CONFIG_NVME_TARGET_TCP is not set

#
# Misc devices
#
CONFIG_SENSORS_LIS3LV02D=y
CONFIG_AD525X_DPOT=y
CONFIG_AD525X_DPOT_I2C=m
# CONFIG_DUMMY_IRQ is not set
CONFIG_IBM_ASM=y
CONFIG_PHANTOM=y
CONFIG_SGI_IOC4=m
CONFIG_TIFM_CORE=m
CONFIG_TIFM_7XX1=m
CONFIG_ICS932S401=y
CONFIG_ENCLOSURE_SERVICES=y
# CONFIG_HP_ILO is not set
CONFIG_APDS9802ALS=m
CONFIG_ISL29003=y
CONFIG_ISL29020=y
CONFIG_SENSORS_TSL2550=y
# CONFIG_SENSORS_BH1770 is not set
CONFIG_SENSORS_APDS990X=y
CONFIG_HMC6352=y
CONFIG_DS1682=m
# CONFIG_VMWARE_BALLOON is not set
# CONFIG_USB_SWITCH_FSA9480 is not set
CONFIG_SRAM=y
CONFIG_PCI_ENDPOINT_TEST=y
CONFIG_MISC_RTSX=y
# CONFIG_PVPANIC is not set
# CONFIG_C2PORT is not set

#
# EEPROM support
#
# CONFIG_EEPROM_AT24 is not set
# CONFIG_EEPROM_LEGACY is not set
# CONFIG_EEPROM_MAX6875 is not set
# CONFIG_EEPROM_93CX6 is not set
CONFIG_EEPROM_IDT_89HPESX=y
# CONFIG_EEPROM_EE1004 is not set
CONFIG_CB710_CORE=m
CONFIG_CB710_DEBUG=y
CONFIG_CB710_DEBUG_ASSUMPTIONS=y

#
# Texas Instruments shared transport line discipline
#
# CONFIG_TI_ST is not set
CONFIG_SENSORS_LIS3_I2C=y
CONFIG_ALTERA_STAPL=m
CONFIG_INTEL_MEI=y
CONFIG_INTEL_MEI_ME=m
# CONFIG_INTEL_MEI_TXE is not set
CONFIG_INTEL_MEI_HDCP=m
CONFIG_VMWARE_VMCI=m

#
# Intel MIC & related support
#

#
# Intel MIC Bus Driver
#
CONFIG_INTEL_MIC_BUS=m

#
# SCIF Bus Driver
#
CONFIG_SCIF_BUS=m

#
# VOP Bus Driver
#
CONFIG_VOP_BUS=m

#
# Intel MIC Host Driver
#
CONFIG_INTEL_MIC_HOST=m

#
# Intel MIC Card Driver
#
# CONFIG_INTEL_MIC_CARD is not set

#
# SCIF Driver
#
CONFIG_SCIF=m

#
# Intel MIC Coprocessor State Management (COSM) Drivers
#
CONFIG_MIC_COSM=m

#
# VOP Driver
#
CONFIG_VOP=m
CONFIG_VHOST_RING=m
CONFIG_GENWQE=y
CONFIG_GENWQE_PLATFORM_ERROR_RECOVERY=0
# CONFIG_ECHO is not set
CONFIG_MISC_ALCOR_PCI=m
CONFIG_MISC_RTSX_PCI=y
CONFIG_HABANA_AI=m
CONFIG_HAVE_IDE=y
# CONFIG_IDE is not set

#
# SCSI device support
#
CONFIG_SCSI_MOD=y
CONFIG_RAID_ATTRS=y
CONFIG_SCSI=y
CONFIG_SCSI_DMA=y
CONFIG_SCSI_PROC_FS=y

#
# SCSI support type (disk, tape, CD-ROM)
#
# CONFIG_BLK_DEV_SD is not set
CONFIG_CHR_DEV_ST=y
CONFIG_CHR_DEV_OSST=m
# CONFIG_BLK_DEV_SR is not set
CONFIG_CHR_DEV_SG=m
CONFIG_CHR_DEV_SCH=m
CONFIG_SCSI_ENCLOSURE=m
# CONFIG_SCSI_CONSTANTS is not set
# CONFIG_SCSI_LOGGING is not set
CONFIG_SCSI_SCAN_ASYNC=y

#
# SCSI Transports
#
CONFIG_SCSI_SPI_ATTRS=y
# CONFIG_SCSI_FC_ATTRS is not set
# CONFIG_SCSI_ISCSI_ATTRS is not set
CONFIG_SCSI_SAS_ATTRS=y
CONFIG_SCSI_SAS_LIBSAS=y
CONFIG_SCSI_SAS_HOST_SMP=y
CONFIG_SCSI_SRP_ATTRS=y
# CONFIG_SCSI_LOWLEVEL is not set
CONFIG_SCSI_LOWLEVEL_PCMCIA=y
CONFIG_PCMCIA_AHA152X=m
# CONFIG_PCMCIA_QLOGIC is not set
CONFIG_PCMCIA_SYM53C500=m
CONFIG_SCSI_DH=y
# CONFIG_SCSI_DH_RDAC is not set
# CONFIG_SCSI_DH_HP_SW is not set
# CONFIG_SCSI_DH_EMC is not set
CONFIG_SCSI_DH_ALUA=m
CONFIG_ATA=m
# CONFIG_ATA_VERBOSE_ERROR is not set
CONFIG_ATA_ACPI=y
# CONFIG_SATA_ZPODD is not set
CONFIG_SATA_PMP=y

#
# Controllers with non-SFF native interface
#
CONFIG_SATA_AHCI=m
CONFIG_SATA_MOBILE_LPM_POLICY=0
# CONFIG_SATA_AHCI_PLATFORM is not set
CONFIG_SATA_INIC162X=m
# CONFIG_SATA_ACARD_AHCI is not set
CONFIG_SATA_SIL24=m
# CONFIG_ATA_SFF is not set
# CONFIG_MD is not set
CONFIG_TARGET_CORE=y
# CONFIG_TCM_IBLOCK is not set
CONFIG_TCM_FILEIO=m
# CONFIG_TCM_PSCSI is not set
# CONFIG_TCM_USER2 is not set
# CONFIG_LOOPBACK_TARGET is not set
# CONFIG_ISCSI_TARGET is not set
CONFIG_FUSION=y
CONFIG_FUSION_SPI=m
# CONFIG_FUSION_SAS is not set
CONFIG_FUSION_MAX_SGE=128
CONFIG_FUSION_CTL=m
CONFIG_FUSION_LOGGING=y

#
# IEEE 1394 (FireWire) support
#
# CONFIG_FIREWIRE is not set
CONFIG_FIREWIRE_NOSY=y
# CONFIG_MACINTOSH_DRIVERS is not set
CONFIG_NETDEVICES=y
CONFIG_NET_CORE=y
# CONFIG_BONDING is not set
# CONFIG_DUMMY is not set
# CONFIG_EQUALIZER is not set
# CONFIG_NET_FC is not set
# CONFIG_NET_TEAM is not set
# CONFIG_MACVLAN is not set
# CONFIG_IPVLAN is not set
# CONFIG_VXLAN is not set
# CONFIG_GENEVE is not set
# CONFIG_GTP is not set
# CONFIG_MACSEC is not set
# CONFIG_NETCONSOLE is not set
# CONFIG_NTB_NETDEV is not set
# CONFIG_TUN is not set
# CONFIG_TUN_VNET_CROSS_LE is not set
# CONFIG_VETH is not set
# CONFIG_VIRTIO_NET is not set
# CONFIG_NLMON is not set
# CONFIG_ARCNET is not set

#
# CAIF transport drivers
#

#
# Distributed Switch Architecture drivers
#
CONFIG_ETHERNET=y
CONFIG_NET_VENDOR_3COM=y
# CONFIG_EL3 is not set
# CONFIG_PCMCIA_3C574 is not set
# CONFIG_PCMCIA_3C589 is not set
# CONFIG_VORTEX is not set
# CONFIG_TYPHOON is not set
CONFIG_NET_VENDOR_ADAPTEC=y
# CONFIG_ADAPTEC_STARFIRE is not set
CONFIG_NET_VENDOR_AGERE=y
# CONFIG_ET131X is not set
CONFIG_NET_VENDOR_ALACRITECH=y
# CONFIG_SLICOSS is not set
CONFIG_NET_VENDOR_ALTEON=y
# CONFIG_ACENIC is not set
# CONFIG_ALTERA_TSE is not set
CONFIG_NET_VENDOR_AMAZON=y
# CONFIG_ENA_ETHERNET is not set
CONFIG_NET_VENDOR_AMD=y
# CONFIG_AMD8111_ETH is not set
# CONFIG_PCNET32 is not set
# CONFIG_PCMCIA_NMCLAN is not set
# CONFIG_AMD_XGBE is not set
CONFIG_NET_VENDOR_AQUANTIA=y
# CONFIG_AQTION is not set
CONFIG_NET_VENDOR_ARC=y
CONFIG_NET_VENDOR_ATHEROS=y
# CONFIG_ATL2 is not set
# CONFIG_ATL1 is not set
# CONFIG_ATL1E is not set
# CONFIG_ATL1C is not set
# CONFIG_ALX is not set
CONFIG_NET_VENDOR_AURORA=y
# CONFIG_AURORA_NB8800 is not set
CONFIG_NET_VENDOR_BROADCOM=y
# CONFIG_B44 is not set
# CONFIG_BCMGENET is not set
# CONFIG_BNX2 is not set
# CONFIG_CNIC is not set
# CONFIG_TIGON3 is not set
# CONFIG_BNX2X is not set
# CONFIG_SYSTEMPORT is not set
# CONFIG_BNXT is not set
CONFIG_NET_VENDOR_BROCADE=y
# CONFIG_BNA is not set
CONFIG_NET_VENDOR_CADENCE=y
# CONFIG_MACB is not set
CONFIG_NET_VENDOR_CAVIUM=y
# CONFIG_THUNDER_NIC_PF is not set
# CONFIG_THUNDER_NIC_VF is not set
# CONFIG_THUNDER_NIC_BGX is not set
# CONFIG_THUNDER_NIC_RGX is not set
# CONFIG_CAVIUM_PTP is not set
# CONFIG_LIQUIDIO is not set
# CONFIG_LIQUIDIO_VF is not set
CONFIG_NET_VENDOR_CHELSIO=y
# CONFIG_CHELSIO_T1 is not set
# CONFIG_CHELSIO_T3 is not set
# CONFIG_CHELSIO_T4 is not set
# CONFIG_CHELSIO_T4VF is not set
CONFIG_NET_VENDOR_CIRRUS=y
# CONFIG_CS89x0 is not set
CONFIG_NET_VENDOR_CISCO=y
# CONFIG_ENIC is not set
CONFIG_NET_VENDOR_CORTINA=y
# CONFIG_CX_ECAT is not set
# CONFIG_DNET is not set
CONFIG_NET_VENDOR_DEC=y
# CONFIG_NET_TULIP is not set
CONFIG_NET_VENDOR_DLINK=y
# CONFIG_DL2K is not set
# CONFIG_SUNDANCE is not set
CONFIG_NET_VENDOR_EMULEX=y
# CONFIG_BE2NET is not set
CONFIG_NET_VENDOR_EZCHIP=y
CONFIG_NET_VENDOR_FUJITSU=y
# CONFIG_PCMCIA_FMVJ18X is not set
CONFIG_NET_VENDOR_HP=y
# CONFIG_HP100 is not set
CONFIG_NET_VENDOR_HUAWEI=y
# CONFIG_HINIC is not set
CONFIG_NET_VENDOR_I825XX=y
CONFIG_NET_VENDOR_INTEL=y
# CONFIG_E100 is not set
CONFIG_E1000=y
# CONFIG_E1000E is not set
# CONFIG_IGB is not set
# CONFIG_IGBVF is not set
# CONFIG_IXGB is not set
# CONFIG_IXGBE is not set
# CONFIG_IXGBEVF is not set
# CONFIG_I40E is not set
# CONFIG_I40EVF is not set
# CONFIG_ICE is not set
# CONFIG_FM10K is not set
# CONFIG_IGC is not set
# CONFIG_JME is not set
CONFIG_NET_VENDOR_MARVELL=y
# CONFIG_MVMDIO is not set
# CONFIG_SKGE is not set
# CONFIG_SKY2 is not set
CONFIG_NET_VENDOR_MELLANOX=y
# CONFIG_MLX4_EN is not set
# CONFIG_MLX5_CORE is not set
# CONFIG_MLXSW_CORE is not set
# CONFIG_MLXFW is not set
CONFIG_NET_VENDOR_MICREL=y
# CONFIG_KS8851_MLL is not set
# CONFIG_KSZ884X_PCI is not set
CONFIG_NET_VENDOR_MICROCHIP=y
# CONFIG_LAN743X is not set
CONFIG_NET_VENDOR_MICROSEMI=y
CONFIG_NET_VENDOR_MYRI=y
# CONFIG_MYRI10GE is not set
# CONFIG_FEALNX is not set
CONFIG_NET_VENDOR_NATSEMI=y
# CONFIG_NATSEMI is not set
# CONFIG_NS83820 is not set
CONFIG_NET_VENDOR_NETERION=y
# CONFIG_S2IO is not set
# CONFIG_VXGE is not set
CONFIG_NET_VENDOR_NETRONOME=y
# CONFIG_NFP is not set
CONFIG_NET_VENDOR_NI=y
# CONFIG_NI_XGE_MANAGEMENT_ENET is not set
CONFIG_NET_VENDOR_8390=y
# CONFIG_PCMCIA_AXNET is not set
# CONFIG_NE2K_PCI is not set
# CONFIG_PCMCIA_PCNET is not set
CONFIG_NET_VENDOR_NVIDIA=y
# CONFIG_FORCEDETH is not set
CONFIG_NET_VENDOR_OKI=y
# CONFIG_ETHOC is not set
CONFIG_NET_VENDOR_PACKET_ENGINES=y
# CONFIG_HAMACHI is not set
# CONFIG_YELLOWFIN is not set
CONFIG_NET_VENDOR_QLOGIC=y
# CONFIG_QLA3XXX is not set
# CONFIG_QLCNIC is not set
# CONFIG_QLGE is not set
# CONFIG_NETXEN_NIC is not set
# CONFIG_QED is not set
CONFIG_NET_VENDOR_QUALCOMM=y
# CONFIG_QCOM_EMAC is not set
# CONFIG_RMNET is not set
CONFIG_NET_VENDOR_RDC=y
# CONFIG_R6040 is not set
CONFIG_NET_VENDOR_REALTEK=y
# CONFIG_ATP is not set
# CONFIG_8139CP is not set
# CONFIG_8139TOO is not set
# CONFIG_R8169 is not set
CONFIG_NET_VENDOR_RENESAS=y
CONFIG_NET_VENDOR_ROCKER=y
CONFIG_NET_VENDOR_SAMSUNG=y
# CONFIG_SXGBE_ETH is not set
CONFIG_NET_VENDOR_SEEQ=y
CONFIG_NET_VENDOR_SOLARFLARE=y
# CONFIG_SFC is not set
# CONFIG_SFC_FALCON is not set
CONFIG_NET_VENDOR_SILAN=y
# CONFIG_SC92031 is not set
CONFIG_NET_VENDOR_SIS=y
# CONFIG_SIS900 is not set
# CONFIG_SIS190 is not set
CONFIG_NET_VENDOR_SMSC=y
# CONFIG_PCMCIA_SMC91C92 is not set
# CONFIG_EPIC100 is not set
# CONFIG_SMSC911X is not set
# CONFIG_SMSC9420 is not set
CONFIG_NET_VENDOR_SOCIONEXT=y
CONFIG_NET_VENDOR_STMICRO=y
# CONFIG_STMMAC_ETH is not set
CONFIG_NET_VENDOR_SUN=y
# CONFIG_HAPPYMEAL is not set
# CONFIG_SUNGEM is not set
# CONFIG_CASSINI is not set
# CONFIG_NIU is not set
CONFIG_NET_VENDOR_SYNOPSYS=y
# CONFIG_DWC_XLGMAC is not set
CONFIG_NET_VENDOR_TEHUTI=y
# CONFIG_TEHUTI is not set
CONFIG_NET_VENDOR_TI=y
# CONFIG_TI_CPSW_PHY_SEL is not set
# CONFIG_TI_CPSW_ALE is not set
# CONFIG_TLAN is not set
CONFIG_NET_VENDOR_VIA=y
# CONFIG_VIA_RHINE is not set
# CONFIG_VIA_VELOCITY is not set
CONFIG_NET_VENDOR_WIZNET=y
# CONFIG_WIZNET_W5100 is not set
# CONFIG_WIZNET_W5300 is not set
CONFIG_NET_VENDOR_XIRCOM=y
# CONFIG_PCMCIA_XIRC2PS is not set
# CONFIG_FDDI is not set
# CONFIG_HIPPI is not set
# CONFIG_NET_SB1000 is not set
# CONFIG_MDIO_DEVICE is not set
# CONFIG_PHYLIB is not set
# CONFIG_PLIP is not set
# CONFIG_PPP is not set
# CONFIG_SLIP is not set

#
# Host-side USB support is needed for USB Network Adapter support
#
CONFIG_WLAN=y
CONFIG_WLAN_VENDOR_ADMTEK=y
CONFIG_WLAN_VENDOR_ATH=y
# CONFIG_ATH_DEBUG is not set
# CONFIG_ATH5K_PCI is not set
CONFIG_WLAN_VENDOR_ATMEL=y
CONFIG_WLAN_VENDOR_BROADCOM=y
CONFIG_WLAN_VENDOR_CISCO=y
CONFIG_WLAN_VENDOR_INTEL=y
CONFIG_WLAN_VENDOR_INTERSIL=y
# CONFIG_HOSTAP is not set
# CONFIG_PRISM54 is not set
CONFIG_WLAN_VENDOR_MARVELL=y
CONFIG_WLAN_VENDOR_MEDIATEK=y
CONFIG_WLAN_VENDOR_RALINK=y
CONFIG_WLAN_VENDOR_REALTEK=y
CONFIG_WLAN_VENDOR_RSI=y
CONFIG_WLAN_VENDOR_ST=y
CONFIG_WLAN_VENDOR_TI=y
CONFIG_WLAN_VENDOR_ZYDAS=y
CONFIG_WLAN_VENDOR_QUANTENNA=y
# CONFIG_PCMCIA_RAYCS is not set

#
# Enable WiMAX (Networking options) to see the WiMAX drivers
#
# CONFIG_WAN is not set
# CONFIG_VMXNET3 is not set
# CONFIG_FUJITSU_ES is not set
# CONFIG_THUNDERBOLT_NET is not set
# CONFIG_NETDEVSIM is not set
# CONFIG_NET_FAILOVER is not set
# CONFIG_ISDN is not set
# CONFIG_NVM is not set

#
# Input device support
#
CONFIG_INPUT=y
# CONFIG_INPUT_LEDS is not set
CONFIG_INPUT_FF_MEMLESS=y
CONFIG_INPUT_POLLDEV=y
# CONFIG_INPUT_SPARSEKMAP is not set
CONFIG_INPUT_MATRIXKMAP=y

#
# Userland interfaces
#
# CONFIG_INPUT_MOUSEDEV is not set
CONFIG_INPUT_JOYDEV=y
CONFIG_INPUT_EVDEV=m
CONFIG_INPUT_EVBUG=y

#
# Input Device Drivers
#
CONFIG_INPUT_KEYBOARD=y
CONFIG_KEYBOARD_ADP5588=m
CONFIG_KEYBOARD_ADP5589=y
CONFIG_KEYBOARD_ATKBD=y
CONFIG_KEYBOARD_QT1070=m
# CONFIG_KEYBOARD_QT2160 is not set
CONFIG_KEYBOARD_DLINK_DIR685=y
# CONFIG_KEYBOARD_LKKBD is not set
# CONFIG_KEYBOARD_GPIO is not set
CONFIG_KEYBOARD_GPIO_POLLED=y
CONFIG_KEYBOARD_TCA6416=m
# CONFIG_KEYBOARD_TCA8418 is not set
CONFIG_KEYBOARD_MATRIX=y
# CONFIG_KEYBOARD_LM8323 is not set
CONFIG_KEYBOARD_LM8333=m
CONFIG_KEYBOARD_MAX7359=y
CONFIG_KEYBOARD_MCS=y
CONFIG_KEYBOARD_MPR121=y
# CONFIG_KEYBOARD_NEWTON is not set
CONFIG_KEYBOARD_OPENCORES=m
# CONFIG_KEYBOARD_SAMSUNG is not set
CONFIG_KEYBOARD_STOWAWAY=y
CONFIG_KEYBOARD_SUNKBD=y
CONFIG_KEYBOARD_TM2_TOUCHKEY=y
# CONFIG_KEYBOARD_TWL4030 is not set
CONFIG_KEYBOARD_XTKBD=y
# CONFIG_KEYBOARD_CROS_EC is not set
CONFIG_KEYBOARD_MTK_PMIC=y
CONFIG_INPUT_MOUSE=y
CONFIG_MOUSE_PS2=m
CONFIG_MOUSE_PS2_ALPS=y
CONFIG_MOUSE_PS2_BYD=y
CONFIG_MOUSE_PS2_LOGIPS2PP=y
CONFIG_MOUSE_PS2_SYNAPTICS=y
CONFIG_MOUSE_PS2_SYNAPTICS_SMBUS=y
CONFIG_MOUSE_PS2_CYPRESS=y
CONFIG_MOUSE_PS2_LIFEBOOK=y
CONFIG_MOUSE_PS2_TRACKPOINT=y
# CONFIG_MOUSE_PS2_ELANTECH is not set
# CONFIG_MOUSE_PS2_SENTELIC is not set
# CONFIG_MOUSE_PS2_TOUCHKIT is not set
CONFIG_MOUSE_PS2_FOCALTECH=y
# CONFIG_MOUSE_PS2_VMMOUSE is not set
CONFIG_MOUSE_PS2_SMBUS=y
# CONFIG_MOUSE_SERIAL is not set
# CONFIG_MOUSE_APPLETOUCH is not set
# CONFIG_MOUSE_BCM5974 is not set
# CONFIG_MOUSE_CYAPA is not set
CONFIG_MOUSE_ELAN_I2C=m
# CONFIG_MOUSE_ELAN_I2C_I2C is not set
CONFIG_MOUSE_ELAN_I2C_SMBUS=y
# CONFIG_MOUSE_VSXXXAA is not set
CONFIG_MOUSE_GPIO=y
# CONFIG_MOUSE_SYNAPTICS_I2C is not set
# CONFIG_MOUSE_SYNAPTICS_USB is not set
CONFIG_INPUT_JOYSTICK=y
# CONFIG_JOYSTICK_ANALOG is not set
CONFIG_JOYSTICK_A3D=m
# CONFIG_JOYSTICK_ADI is not set
# CONFIG_JOYSTICK_COBRA is not set
CONFIG_JOYSTICK_GF2K=y
# CONFIG_JOYSTICK_GRIP is not set
CONFIG_JOYSTICK_GRIP_MP=y
CONFIG_JOYSTICK_GUILLEMOT=y
# CONFIG_JOYSTICK_INTERACT is not set
CONFIG_JOYSTICK_SIDEWINDER=m
# CONFIG_JOYSTICK_TMDC is not set
# CONFIG_JOYSTICK_IFORCE is not set
CONFIG_JOYSTICK_WARRIOR=m
CONFIG_JOYSTICK_MAGELLAN=m
CONFIG_JOYSTICK_SPACEORB=m
CONFIG_JOYSTICK_SPACEBALL=m
# CONFIG_JOYSTICK_STINGER is not set
# CONFIG_JOYSTICK_TWIDJOY is not set
CONFIG_JOYSTICK_ZHENHUA=y
CONFIG_JOYSTICK_DB9=m
CONFIG_JOYSTICK_GAMECON=m
# CONFIG_JOYSTICK_TURBOGRAFX is not set
# CONFIG_JOYSTICK_AS5011 is not set
CONFIG_JOYSTICK_JOYDUMP=y
# CONFIG_JOYSTICK_XPAD is not set
# CONFIG_JOYSTICK_WALKERA0701 is not set
# CONFIG_JOYSTICK_PXRC is not set
CONFIG_INPUT_TABLET=y
# CONFIG_TABLET_USB_ACECAD is not set
# CONFIG_TABLET_USB_AIPTEK is not set
# CONFIG_TABLET_USB_HANWANG is not set
# CONFIG_TABLET_USB_KBTAB is not set
# CONFIG_TABLET_USB_PEGASUS is not set
CONFIG_TABLET_SERIAL_WACOM4=m
# CONFIG_INPUT_TOUCHSCREEN is not set
CONFIG_INPUT_MISC=y
CONFIG_INPUT_88PM80X_ONKEY=m
# CONFIG_INPUT_AD714X is not set
CONFIG_INPUT_BMA150=m
CONFIG_INPUT_E3X0_BUTTON=m
CONFIG_INPUT_MSM_VIBRATOR=y
# CONFIG_INPUT_PCSPKR is not set
CONFIG_INPUT_MC13783_PWRBUTTON=m
CONFIG_INPUT_MMA8450=m
CONFIG_INPUT_APANEL=m
CONFIG_INPUT_GP2A=m
CONFIG_INPUT_GPIO_BEEPER=m
CONFIG_INPUT_GPIO_DECODER=m
# CONFIG_INPUT_ATLAS_BTNS is not set
# CONFIG_INPUT_ATI_REMOTE2 is not set
# CONFIG_INPUT_KEYSPAN_REMOTE is not set
CONFIG_INPUT_KXTJ9=y
# CONFIG_INPUT_KXTJ9_POLLED_MODE is not set
# CONFIG_INPUT_POWERMATE is not set
# CONFIG_INPUT_YEALINK is not set
# CONFIG_INPUT_CM109 is not set
CONFIG_INPUT_REGULATOR_HAPTIC=m
# CONFIG_INPUT_RETU_PWRBUTTON is not set
CONFIG_INPUT_TWL4030_PWRBUTTON=m
CONFIG_INPUT_TWL4030_VIBRA=y
# CONFIG_INPUT_TWL6040_VIBRA is not set
# CONFIG_INPUT_UINPUT is not set
CONFIG_INPUT_PALMAS_PWRBUTTON=y
# CONFIG_INPUT_PCF50633_PMU is not set
# CONFIG_INPUT_PCF8574 is not set
CONFIG_INPUT_GPIO_ROTARY_ENCODER=m
# CONFIG_INPUT_ADXL34X is not set
CONFIG_INPUT_CMA3000=m
CONFIG_INPUT_CMA3000_I2C=m
# CONFIG_INPUT_IDEAPAD_SLIDEBAR is not set
CONFIG_INPUT_DRV260X_HAPTICS=m
CONFIG_INPUT_DRV2665_HAPTICS=y
CONFIG_INPUT_DRV2667_HAPTICS=m
# CONFIG_INPUT_RAVE_SP_PWRBUTTON is not set
CONFIG_RMI4_CORE=y
# CONFIG_RMI4_I2C is not set
CONFIG_RMI4_SMB=m
CONFIG_RMI4_F03=y
CONFIG_RMI4_F03_SERIO=y
CONFIG_RMI4_2D_SENSOR=y
CONFIG_RMI4_F11=y
CONFIG_RMI4_F12=y
CONFIG_RMI4_F30=y
CONFIG_RMI4_F34=y
# CONFIG_RMI4_F54 is not set
# CONFIG_RMI4_F55 is not set

#
# Hardware I/O ports
#
CONFIG_SERIO=y
CONFIG_ARCH_MIGHT_HAVE_PC_SERIO=y
CONFIG_SERIO_I8042=y
CONFIG_SERIO_SERPORT=y
# CONFIG_SERIO_CT82C710 is not set
CONFIG_SERIO_PARKBD=m
CONFIG_SERIO_PCIPS2=m
CONFIG_SERIO_LIBPS2=y
CONFIG_SERIO_RAW=y
# CONFIG_SERIO_ALTERA_PS2 is not set
CONFIG_SERIO_PS2MULT=y
CONFIG_SERIO_ARC_PS2=m
# CONFIG_SERIO_OLPC_APSP is not set
CONFIG_SERIO_GPIO_PS2=m
CONFIG_USERIO=m
CONFIG_GAMEPORT=y
CONFIG_GAMEPORT_NS558=m
# CONFIG_GAMEPORT_L4 is not set
CONFIG_GAMEPORT_EMU10K1=y
CONFIG_GAMEPORT_FM801=y

#
# Character devices
#
CONFIG_TTY=y
CONFIG_VT=y
CONFIG_CONSOLE_TRANSLATIONS=y
CONFIG_VT_CONSOLE=y
CONFIG_HW_CONSOLE=y
CONFIG_VT_HW_CONSOLE_BINDING=y
CONFIG_UNIX98_PTYS=y
CONFIG_LEGACY_PTYS=y
CONFIG_LEGACY_PTY_COUNT=256
# CONFIG_SERIAL_NONSTANDARD is not set
CONFIG_NOZOMI=y
# CONFIG_N_GSM is not set
CONFIG_TRACE_ROUTER=m
CONFIG_TRACE_SINK=m
CONFIG_LDISC_AUTOLOAD=y
# CONFIG_DEVMEM is not set
CONFIG_DEVKMEM=y

#
# Serial drivers
#
CONFIG_SERIAL_EARLYCON=y
CONFIG_SERIAL_8250=y
CONFIG_SERIAL_8250_DEPRECATED_OPTIONS=y
CONFIG_SERIAL_8250_PNP=y
CONFIG_SERIAL_8250_FINTEK=y
CONFIG_SERIAL_8250_CONSOLE=y
# CONFIG_SERIAL_8250_PCI is not set
CONFIG_SERIAL_8250_CS=m
# CONFIG_SERIAL_8250_MEN_MCB is not set
CONFIG_SERIAL_8250_NR_UARTS=4
CONFIG_SERIAL_8250_RUNTIME_UARTS=4
# CONFIG_SERIAL_8250_EXTENDED is not set
# CONFIG_SERIAL_8250_DW is not set
# CONFIG_SERIAL_8250_RT288X is not set
# CONFIG_SERIAL_8250_LPSS is not set
CONFIG_SERIAL_8250_MID=y
CONFIG_SERIAL_8250_MOXA=m

#
# Non-8250 serial port support
#
# CONFIG_SERIAL_UARTLITE is not set
CONFIG_SERIAL_CORE=y
CONFIG_SERIAL_CORE_CONSOLE=y
# CONFIG_SERIAL_JSM is not set
# CONFIG_SERIAL_SCCNXP is not set
CONFIG_SERIAL_SC16IS7XX_CORE=y
CONFIG_SERIAL_SC16IS7XX=y
CONFIG_SERIAL_SC16IS7XX_I2C=y
CONFIG_SERIAL_ALTERA_JTAGUART=y
CONFIG_SERIAL_ALTERA_JTAGUART_CONSOLE=y
# CONFIG_SERIAL_ALTERA_JTAGUART_CONSOLE_BYPASS is not set
CONFIG_SERIAL_ALTERA_UART=m
CONFIG_SERIAL_ALTERA_UART_MAXPORTS=4
CONFIG_SERIAL_ALTERA_UART_BAUDRATE=115200
CONFIG_SERIAL_ARC=m
CONFIG_SERIAL_ARC_NR_PORTS=1
# CONFIG_SERIAL_RP2 is not set
CONFIG_SERIAL_FSL_LPUART=y
CONFIG_SERIAL_FSL_LPUART_CONSOLE=y
CONFIG_SERIAL_MEN_Z135=y
CONFIG_SERIAL_DEV_BUS=m
# CONFIG_PRINTER is not set
CONFIG_PPDEV=m
CONFIG_HVC_DRIVER=y
CONFIG_VIRTIO_CONSOLE=y
# CONFIG_IPMI_HANDLER is not set
# CONFIG_HW_RANDOM is not set
# CONFIG_NVRAM is not set
# CONFIG_R3964 is not set
# CONFIG_APPLICOM is not set

#
# PCMCIA character devices
#
# CONFIG_SYNCLINK_CS is not set
CONFIG_CARDMAN_4000=m
CONFIG_CARDMAN_4040=m
# CONFIG_SCR24X is not set
# CONFIG_IPWIRELESS is not set
# CONFIG_MWAVE is not set
# CONFIG_RAW_DRIVER is not set
# CONFIG_HPET is not set
CONFIG_HANGCHECK_TIMER=m
CONFIG_TCG_TPM=m
CONFIG_TCG_TIS_CORE=m
CONFIG_TCG_TIS=m
CONFIG_TCG_TIS_I2C_ATMEL=m
# CONFIG_TCG_TIS_I2C_INFINEON is not set
# CONFIG_TCG_TIS_I2C_NUVOTON is not set
# CONFIG_TCG_NSC is not set
CONFIG_TCG_ATMEL=m
# CONFIG_TCG_INFINEON is not set
# CONFIG_TCG_CRB is not set
CONFIG_TCG_VTPM_PROXY=m
CONFIG_TCG_TIS_ST33ZP24=m
CONFIG_TCG_TIS_ST33ZP24_I2C=m
CONFIG_TELCLOCK=y
CONFIG_DEVPORT=y
# CONFIG_XILLYBUS is not set
# CONFIG_RANDOM_TRUST_CPU is not set

#
# I2C support
#
CONFIG_I2C=y
CONFIG_ACPI_I2C_OPREGION=y
CONFIG_I2C_BOARDINFO=y
# CONFIG_I2C_COMPAT is not set
CONFIG_I2C_CHARDEV=y
# CONFIG_I2C_MUX is not set
# CONFIG_I2C_HELPER_AUTO is not set
CONFIG_I2C_SMBUS=m

#
# I2C Algorithms
#
CONFIG_I2C_ALGOBIT=y
CONFIG_I2C_ALGOPCF=m
CONFIG_I2C_ALGOPCA=y

#
# I2C Hardware Bus support
#

#
# PC SMBus host controller drivers
#
CONFIG_I2C_ALI1535=y
# CONFIG_I2C_ALI1563 is not set
# CONFIG_I2C_ALI15X3 is not set
# CONFIG_I2C_AMD756 is not set
# CONFIG_I2C_AMD8111 is not set
# CONFIG_I2C_I801 is not set
# CONFIG_I2C_ISCH is not set
CONFIG_I2C_ISMT=y
CONFIG_I2C_PIIX4=y
CONFIG_I2C_NFORCE2=m
# CONFIG_I2C_NFORCE2_S4985 is not set
# CONFIG_I2C_NVIDIA_GPU is not set
CONFIG_I2C_SIS5595=m
CONFIG_I2C_SIS630=m
# CONFIG_I2C_SIS96X is not set
CONFIG_I2C_VIA=m
CONFIG_I2C_VIAPRO=y

#
# ACPI drivers
#
# CONFIG_I2C_SCMI is not set

#
# I2C system bus drivers (mostly embedded / system-on-chip)
#
CONFIG_I2C_CBUS_GPIO=m
CONFIG_I2C_DESIGNWARE_CORE=y
# CONFIG_I2C_DESIGNWARE_PLATFORM is not set
CONFIG_I2C_DESIGNWARE_PCI=y
# CONFIG_I2C_EMEV2 is not set
# CONFIG_I2C_GPIO is not set
CONFIG_I2C_KEMPLD=m
CONFIG_I2C_OCORES=y
CONFIG_I2C_PCA_PLATFORM=y
CONFIG_I2C_SIMTEC=y
CONFIG_I2C_XILINX=y

#
# External I2C/SMBus adapter drivers
#
CONFIG_I2C_PARPORT=m
# CONFIG_I2C_PARPORT_LIGHT is not set
CONFIG_I2C_TAOS_EVM=y

#
# Other I2C/SMBus bus drivers
#
# CONFIG_I2C_MLXCPLD is not set
# CONFIG_I2C_CROS_EC_TUNNEL is not set
CONFIG_I2C_STUB=m
CONFIG_I2C_SLAVE=y
# CONFIG_I2C_SLAVE_EEPROM is not set
# CONFIG_I2C_DEBUG_CORE is not set
# CONFIG_I2C_DEBUG_ALGO is not set
# CONFIG_I2C_DEBUG_BUS is not set
CONFIG_I3C=y
# CONFIG_CDNS_I3C_MASTER is not set
CONFIG_DW_I3C_MASTER=y
# CONFIG_SPI is not set
CONFIG_SPMI=m
# CONFIG_HSI is not set
CONFIG_PPS=m
# CONFIG_PPS_DEBUG is not set

#
# PPS clients support
#
CONFIG_PPS_CLIENT_KTIMER=m
CONFIG_PPS_CLIENT_LDISC=m
# CONFIG_PPS_CLIENT_PARPORT is not set
CONFIG_PPS_CLIENT_GPIO=m

#
# PPS generators support
#

#
# PTP clock support
#
# CONFIG_PTP_1588_CLOCK is not set

#
# Enable PHYLIB and NETWORK_PHY_TIMESTAMPING to see the additional clocks.
#
CONFIG_PINCTRL=y
CONFIG_PINMUX=y
CONFIG_PINCONF=y
CONFIG_GENERIC_PINCONF=y
CONFIG_DEBUG_PINCTRL=y
CONFIG_PINCTRL_AMD=y
CONFIG_PINCTRL_MCP23S08=y
# CONFIG_PINCTRL_SX150X is not set
# CONFIG_PINCTRL_BAYTRAIL is not set
# CONFIG_PINCTRL_CHERRYVIEW is not set
# CONFIG_PINCTRL_BROXTON is not set
# CONFIG_PINCTRL_CANNONLAKE is not set
# CONFIG_PINCTRL_CEDARFORK is not set
# CONFIG_PINCTRL_DENVERTON is not set
# CONFIG_PINCTRL_GEMINILAKE is not set
# CONFIG_PINCTRL_ICELAKE is not set
# CONFIG_PINCTRL_LEWISBURG is not set
# CONFIG_PINCTRL_SUNRISEPOINT is not set
CONFIG_PINCTRL_MADERA=y
CONFIG_PINCTRL_CS47L85=y
CONFIG_PINCTRL_CS47L90=y
CONFIG_GPIOLIB=y
CONFIG_GPIOLIB_FASTPATH_LIMIT=512
CONFIG_GPIO_ACPI=y
CONFIG_GPIOLIB_IRQCHIP=y
# CONFIG_DEBUG_GPIO is not set
# CONFIG_GPIO_SYSFS is not set
CONFIG_GPIO_GENERIC=y
CONFIG_GPIO_MAX730X=m

#
# Memory mapped GPIO drivers
#
# CONFIG_GPIO_AMDPT is not set
CONFIG_GPIO_DWAPB=y
CONFIG_GPIO_GENERIC_PLATFORM=y
# CONFIG_GPIO_ICH is not set
# CONFIG_GPIO_LYNXPOINT is not set
CONFIG_GPIO_MB86S7X=m
CONFIG_GPIO_MENZ127=m
# CONFIG_GPIO_MOCKUP is not set
# CONFIG_GPIO_SIOX is not set
# CONFIG_GPIO_VX855 is not set
CONFIG_GPIO_AMD_FCH=y

#
# Port-mapped I/O GPIO drivers
#
CONFIG_GPIO_F7188X=m
CONFIG_GPIO_IT87=y
CONFIG_GPIO_SCH=y
CONFIG_GPIO_SCH311X=y
# CONFIG_GPIO_WINBOND is not set
CONFIG_GPIO_WS16C48=m

#
# I2C GPIO expanders
#
CONFIG_GPIO_ADP5588=y
# CONFIG_GPIO_ADP5588_IRQ is not set
CONFIG_GPIO_MAX7300=m
# CONFIG_GPIO_MAX732X is not set
CONFIG_GPIO_PCA953X=y
# CONFIG_GPIO_PCA953X_IRQ is not set
CONFIG_GPIO_PCF857X=y
CONFIG_GPIO_TPIC2810=y

#
# MFD GPIO expanders
#
CONFIG_GPIO_ARIZONA=m
CONFIG_GPIO_JANZ_TTL=y
CONFIG_GPIO_KEMPLD=y
CONFIG_GPIO_LP3943=m
CONFIG_GPIO_MADERA=m
# CONFIG_GPIO_PALMAS is not set
CONFIG_GPIO_TQMX86=m
CONFIG_GPIO_TWL4030=y
# CONFIG_GPIO_TWL6040 is not set
CONFIG_GPIO_UCB1400=m
CONFIG_GPIO_WM8350=m
CONFIG_GPIO_WM8994=m

#
# PCI GPIO expanders
#
CONFIG_GPIO_AMD8111=m
CONFIG_GPIO_BT8XX=y
CONFIG_GPIO_ML_IOH=y
CONFIG_GPIO_PCI_IDIO_16=m
CONFIG_GPIO_PCIE_IDIO_24=y
CONFIG_GPIO_RDC321X=y
CONFIG_W1=y

#
# 1-wire Bus Masters
#
CONFIG_W1_MASTER_MATROX=y
CONFIG_W1_MASTER_DS2482=y
CONFIG_W1_MASTER_DS1WM=y
CONFIG_W1_MASTER_GPIO=y

#
# 1-wire Slaves
#
CONFIG_W1_SLAVE_THERM=y
CONFIG_W1_SLAVE_SMEM=y
CONFIG_W1_SLAVE_DS2405=m
# CONFIG_W1_SLAVE_DS2408 is not set
# CONFIG_W1_SLAVE_DS2413 is not set
CONFIG_W1_SLAVE_DS2406=m
# CONFIG_W1_SLAVE_DS2423 is not set
CONFIG_W1_SLAVE_DS2805=y
# CONFIG_W1_SLAVE_DS2431 is not set
CONFIG_W1_SLAVE_DS2433=m
# CONFIG_W1_SLAVE_DS2433_CRC is not set
# CONFIG_W1_SLAVE_DS2438 is not set
CONFIG_W1_SLAVE_DS2780=y
CONFIG_W1_SLAVE_DS2781=y
CONFIG_W1_SLAVE_DS28E04=y
# CONFIG_W1_SLAVE_DS28E17 is not set
CONFIG_POWER_AVS=y
# CONFIG_POWER_RESET is not set
CONFIG_POWER_SUPPLY=y
CONFIG_POWER_SUPPLY_DEBUG=y
# CONFIG_PDA_POWER is not set
CONFIG_WM8350_POWER=m
# CONFIG_TEST_POWER is not set
# CONFIG_CHARGER_ADP5061 is not set
# CONFIG_BATTERY_DS2760 is not set
CONFIG_BATTERY_DS2780=y
CONFIG_BATTERY_DS2781=y
# CONFIG_BATTERY_DS2782 is not set
CONFIG_BATTERY_SBS=y
CONFIG_CHARGER_SBS=m
# CONFIG_BATTERY_BQ27XXX is not set
CONFIG_BATTERY_MAX17040=m
CONFIG_BATTERY_MAX17042=y
CONFIG_BATTERY_MAX1721X=y
# CONFIG_CHARGER_PCF50633 is not set
CONFIG_CHARGER_MAX8903=m
CONFIG_CHARGER_LP8727=m
CONFIG_CHARGER_GPIO=y
# CONFIG_CHARGER_MANAGER is not set
CONFIG_CHARGER_LTC3651=y
# CONFIG_CHARGER_MAX14577 is not set
# CONFIG_CHARGER_MAX77693 is not set
# CONFIG_CHARGER_MAX8997 is not set
CONFIG_CHARGER_MAX8998=y
CONFIG_CHARGER_BQ2415X=y
# CONFIG_CHARGER_BQ24257 is not set
CONFIG_CHARGER_BQ24735=y
# CONFIG_CHARGER_BQ25890 is not set
CONFIG_CHARGER_SMB347=m
CONFIG_BATTERY_GAUGE_LTC2941=m
# CONFIG_BATTERY_RT5033 is not set
CONFIG_CHARGER_RT9455=y
# CONFIG_CHARGER_CROS_USBPD is not set
CONFIG_HWMON=y
CONFIG_HWMON_VID=y
CONFIG_HWMON_DEBUG_CHIP=y

#
# Native drivers
#
CONFIG_SENSORS_ABITUGURU=m
# CONFIG_SENSORS_ABITUGURU3 is not set
CONFIG_SENSORS_AD7414=m
# CONFIG_SENSORS_AD7418 is not set
# CONFIG_SENSORS_ADM1021 is not set
CONFIG_SENSORS_ADM1025=m
CONFIG_SENSORS_ADM1026=m
# CONFIG_SENSORS_ADM1029 is not set
CONFIG_SENSORS_ADM1031=y
CONFIG_SENSORS_ADM9240=m
CONFIG_SENSORS_ADT7X10=m
CONFIG_SENSORS_ADT7410=m
CONFIG_SENSORS_ADT7411=y
# CONFIG_SENSORS_ADT7462 is not set
CONFIG_SENSORS_ADT7470=m
CONFIG_SENSORS_ADT7475=m
CONFIG_SENSORS_ASC7621=y
# CONFIG_SENSORS_K8TEMP is not set
# CONFIG_SENSORS_K10TEMP is not set
# CONFIG_SENSORS_FAM15H_POWER is not set
CONFIG_SENSORS_APPLESMC=y
CONFIG_SENSORS_ASB100=m
# CONFIG_SENSORS_ASPEED is not set
# CONFIG_SENSORS_ATXP1 is not set
CONFIG_SENSORS_DS620=y
CONFIG_SENSORS_DS1621=m
CONFIG_SENSORS_DELL_SMM=y
# CONFIG_SENSORS_I5K_AMB is not set
CONFIG_SENSORS_F71805F=y
CONFIG_SENSORS_F71882FG=m
# CONFIG_SENSORS_F75375S is not set
CONFIG_SENSORS_MC13783_ADC=m
# CONFIG_SENSORS_FSCHMD is not set
CONFIG_SENSORS_GL518SM=y
# CONFIG_SENSORS_GL520SM is not set
CONFIG_SENSORS_G760A=m
# CONFIG_SENSORS_G762 is not set
CONFIG_SENSORS_HIH6130=m
CONFIG_SENSORS_I5500=y
CONFIG_SENSORS_CORETEMP=m
CONFIG_SENSORS_IT87=y
# CONFIG_SENSORS_JC42 is not set
CONFIG_SENSORS_POWR1220=y
CONFIG_SENSORS_LINEAGE=m
CONFIG_SENSORS_LTC2945=y
# CONFIG_SENSORS_LTC2990 is not set
# CONFIG_SENSORS_LTC4151 is not set
# CONFIG_SENSORS_LTC4215 is not set
CONFIG_SENSORS_LTC4222=y
CONFIG_SENSORS_LTC4245=y
CONFIG_SENSORS_LTC4260=y
CONFIG_SENSORS_LTC4261=y
CONFIG_SENSORS_MAX16065=m
CONFIG_SENSORS_MAX1619=m
CONFIG_SENSORS_MAX1668=y
CONFIG_SENSORS_MAX197=m
# CONFIG_SENSORS_MAX6621 is not set
CONFIG_SENSORS_MAX6639=m
# CONFIG_SENSORS_MAX6642 is not set
CONFIG_SENSORS_MAX6650=y
CONFIG_SENSORS_MAX6697=m
CONFIG_SENSORS_MAX31790=y
CONFIG_SENSORS_MCP3021=y
CONFIG_SENSORS_MLXREG_FAN=m
CONFIG_SENSORS_TC654=m
CONFIG_SENSORS_LM63=m
# CONFIG_SENSORS_LM73 is not set
CONFIG_SENSORS_LM75=m
# CONFIG_SENSORS_LM77 is not set
CONFIG_SENSORS_LM78=m
# CONFIG_SENSORS_LM80 is not set
# CONFIG_SENSORS_LM83 is not set
# CONFIG_SENSORS_LM85 is not set
# CONFIG_SENSORS_LM87 is not set
CONFIG_SENSORS_LM90=y
# CONFIG_SENSORS_LM92 is not set
CONFIG_SENSORS_LM93=m
CONFIG_SENSORS_LM95234=m
CONFIG_SENSORS_LM95241=y
# CONFIG_SENSORS_LM95245 is not set
CONFIG_SENSORS_PC87360=y
CONFIG_SENSORS_PC87427=m
# CONFIG_SENSORS_NTC_THERMISTOR is not set
# CONFIG_SENSORS_NCT6683 is not set
CONFIG_SENSORS_NCT6775=m
CONFIG_SENSORS_NCT7802=m
# CONFIG_SENSORS_NCT7904 is not set
# CONFIG_SENSORS_NPCM7XX is not set
CONFIG_SENSORS_OCC_P8_I2C=m
CONFIG_SENSORS_OCC=y
CONFIG_SENSORS_PCF8591=y
CONFIG_PMBUS=y
CONFIG_SENSORS_PMBUS=y
CONFIG_SENSORS_ADM1275=y
CONFIG_SENSORS_IBM_CFFPS=y
CONFIG_SENSORS_IR35221=y
CONFIG_SENSORS_LM25066=m
CONFIG_SENSORS_LTC2978=y
# CONFIG_SENSORS_LTC2978_REGULATOR is not set
# CONFIG_SENSORS_LTC3815 is not set
CONFIG_SENSORS_MAX16064=m
CONFIG_SENSORS_MAX20751=y
CONFIG_SENSORS_MAX31785=y
CONFIG_SENSORS_MAX34440=m
CONFIG_SENSORS_MAX8688=m
CONFIG_SENSORS_TPS40422=y
CONFIG_SENSORS_TPS53679=m
# CONFIG_SENSORS_UCD9000 is not set
CONFIG_SENSORS_UCD9200=m
CONFIG_SENSORS_ZL6100=m
# CONFIG_SENSORS_SHT15 is not set
# CONFIG_SENSORS_SHT21 is not set
# CONFIG_SENSORS_SHT3x is not set
# CONFIG_SENSORS_SHTC1 is not set
CONFIG_SENSORS_SIS5595=y
CONFIG_SENSORS_DME1737=m
CONFIG_SENSORS_EMC1403=m
CONFIG_SENSORS_EMC2103=y
# CONFIG_SENSORS_EMC6W201 is not set
# CONFIG_SENSORS_SMSC47M1 is not set
CONFIG_SENSORS_SMSC47M192=y
CONFIG_SENSORS_SMSC47B397=y
CONFIG_SENSORS_STTS751=y
CONFIG_SENSORS_SMM665=m
CONFIG_SENSORS_ADC128D818=y
CONFIG_SENSORS_ADS1015=m
CONFIG_SENSORS_ADS7828=y
CONFIG_SENSORS_AMC6821=m
# CONFIG_SENSORS_INA209 is not set
CONFIG_SENSORS_INA2XX=y
CONFIG_SENSORS_INA3221=m
CONFIG_SENSORS_TC74=m
# CONFIG_SENSORS_THMC50 is not set
# CONFIG_SENSORS_TMP102 is not set
# CONFIG_SENSORS_TMP103 is not set
CONFIG_SENSORS_TMP108=y
CONFIG_SENSORS_TMP401=m
CONFIG_SENSORS_TMP421=y
# CONFIG_SENSORS_VIA_CPUTEMP is not set
CONFIG_SENSORS_VIA686A=m
CONFIG_SENSORS_VT1211=m
CONFIG_SENSORS_VT8231=y
CONFIG_SENSORS_W83773G=m
CONFIG_SENSORS_W83781D=m
# CONFIG_SENSORS_W83791D is not set
# CONFIG_SENSORS_W83792D is not set
# CONFIG_SENSORS_W83793 is not set
# CONFIG_SENSORS_W83795 is not set
CONFIG_SENSORS_W83L785TS=m
# CONFIG_SENSORS_W83L786NG is not set
CONFIG_SENSORS_W83627HF=y
CONFIG_SENSORS_W83627EHF=y
CONFIG_SENSORS_WM8350=m

#
# ACPI drivers
#
# CONFIG_SENSORS_ACPI_POWER is not set
# CONFIG_SENSORS_ATK0110 is not set
CONFIG_THERMAL=y
CONFIG_THERMAL_STATISTICS=y
CONFIG_THERMAL_EMERGENCY_POWEROFF_DELAY_MS=0
CONFIG_THERMAL_HWMON=y
CONFIG_THERMAL_WRITABLE_TRIPS=y
# CONFIG_THERMAL_DEFAULT_GOV_STEP_WISE is not set
# CONFIG_THERMAL_DEFAULT_GOV_FAIR_SHARE is not set
# CONFIG_THERMAL_DEFAULT_GOV_USER_SPACE is not set
CONFIG_THERMAL_DEFAULT_GOV_POWER_ALLOCATOR=y
CONFIG_THERMAL_GOV_FAIR_SHARE=y
CONFIG_THERMAL_GOV_STEP_WISE=y
# CONFIG_THERMAL_GOV_BANG_BANG is not set
CONFIG_THERMAL_GOV_USER_SPACE=y
CONFIG_THERMAL_GOV_POWER_ALLOCATOR=y
CONFIG_CLOCK_THERMAL=y
# CONFIG_DEVFREQ_THERMAL is not set
CONFIG_THERMAL_EMULATION=y

#
# Intel thermal drivers
#
CONFIG_INTEL_POWERCLAMP=m
CONFIG_X86_PKG_TEMP_THERMAL=m
# CONFIG_INTEL_SOC_DTS_THERMAL is not set

#
# ACPI INT340X thermal drivers
#
# CONFIG_INT340X_THERMAL is not set
CONFIG_INTEL_PCH_THERMAL=m
# CONFIG_WATCHDOG is not set
CONFIG_SSB_POSSIBLE=y
CONFIG_SSB=m
CONFIG_SSB_PCIHOST_POSSIBLE=y
# CONFIG_SSB_PCIHOST is not set
CONFIG_SSB_PCMCIAHOST_POSSIBLE=y
# CONFIG_SSB_PCMCIAHOST is not set
CONFIG_SSB_SDIOHOST_POSSIBLE=y
# CONFIG_SSB_SDIOHOST is not set
CONFIG_SSB_DRIVER_GPIO=y
CONFIG_BCMA_POSSIBLE=y
# CONFIG_BCMA is not set

#
# Multifunction device drivers
#
CONFIG_MFD_CORE=y
CONFIG_MFD_AS3711=y
# CONFIG_PMIC_ADP5520 is not set
CONFIG_MFD_AAT2870_CORE=y
CONFIG_MFD_BCM590XX=y
# CONFIG_MFD_BD9571MWV is not set
# CONFIG_MFD_AXP20X_I2C is not set
CONFIG_MFD_CROS_EC=m
CONFIG_MFD_CROS_EC_CHARDEV=m
CONFIG_MFD_MADERA=y
CONFIG_MFD_MADERA_I2C=m
# CONFIG_MFD_CS47L35 is not set
CONFIG_MFD_CS47L85=y
CONFIG_MFD_CS47L90=y
# CONFIG_PMIC_DA903X is not set
# CONFIG_MFD_DA9052_I2C is not set
# CONFIG_MFD_DA9055 is not set
# CONFIG_MFD_DA9062 is not set
# CONFIG_MFD_DA9063 is not set
# CONFIG_MFD_DA9150 is not set
CONFIG_MFD_MC13XXX=m
CONFIG_MFD_MC13XXX_I2C=m
CONFIG_HTC_PASIC3=y
CONFIG_HTC_I2CPLD=y
CONFIG_MFD_INTEL_QUARK_I2C_GPIO=m
CONFIG_LPC_ICH=y
CONFIG_LPC_SCH=y
# CONFIG_INTEL_SOC_PMIC_CHTDC_TI is not set
CONFIG_MFD_INTEL_LPSS=y
# CONFIG_MFD_INTEL_LPSS_ACPI is not set
CONFIG_MFD_INTEL_LPSS_PCI=y
CONFIG_MFD_JANZ_CMODIO=y
CONFIG_MFD_KEMPLD=y
CONFIG_MFD_88PM800=y
CONFIG_MFD_88PM805=y
# CONFIG_MFD_88PM860X is not set
CONFIG_MFD_MAX14577=y
CONFIG_MFD_MAX77693=y
# CONFIG_MFD_MAX77843 is not set
CONFIG_MFD_MAX8907=y
# CONFIG_MFD_MAX8925 is not set
CONFIG_MFD_MAX8997=y
CONFIG_MFD_MAX8998=y
CONFIG_MFD_MT6397=y
# CONFIG_MFD_MENF21BMC is not set
CONFIG_MFD_RETU=m
CONFIG_MFD_PCF50633=y
# CONFIG_PCF50633_ADC is not set
CONFIG_PCF50633_GPIO=m
CONFIG_UCB1400_CORE=m
CONFIG_MFD_RDC321X=y
CONFIG_MFD_RT5033=m
# CONFIG_MFD_RC5T583 is not set
CONFIG_MFD_SEC_CORE=y
CONFIG_MFD_SI476X_CORE=y
CONFIG_MFD_SM501=m
CONFIG_MFD_SM501_GPIO=y
# CONFIG_MFD_SKY81452 is not set
# CONFIG_MFD_SMSC is not set
CONFIG_ABX500_CORE=y
# CONFIG_AB3100_CORE is not set
CONFIG_MFD_SYSCON=y
CONFIG_MFD_TI_AM335X_TSCADC=y
CONFIG_MFD_LP3943=m
CONFIG_MFD_LP8788=y
# CONFIG_MFD_TI_LMU is not set
CONFIG_MFD_PALMAS=y
CONFIG_TPS6105X=y
# CONFIG_TPS65010 is not set
# CONFIG_TPS6507X is not set
# CONFIG_MFD_TPS65086 is not set
# CONFIG_MFD_TPS65090 is not set
# CONFIG_MFD_TI_LP873X is not set
# CONFIG_MFD_TPS6586X is not set
# CONFIG_MFD_TPS65910 is not set
# CONFIG_MFD_TPS65912_I2C is not set
CONFIG_MFD_TPS80031=y
CONFIG_TWL4030_CORE=y
CONFIG_MFD_TWL4030_AUDIO=y
CONFIG_TWL6040_CORE=y
CONFIG_MFD_WL1273_CORE=y
CONFIG_MFD_LM3533=m
CONFIG_MFD_TQMX86=m
CONFIG_MFD_VX855=y
CONFIG_MFD_ARIZONA=y
CONFIG_MFD_ARIZONA_I2C=m
CONFIG_MFD_CS47L24=y
CONFIG_MFD_WM5102=y
CONFIG_MFD_WM5110=y
# CONFIG_MFD_WM8997 is not set
# CONFIG_MFD_WM8998 is not set
# CONFIG_MFD_WM8400 is not set
# CONFIG_MFD_WM831X_I2C is not set
CONFIG_MFD_WM8350=y
CONFIG_MFD_WM8350_I2C=y
CONFIG_MFD_WM8994=y
CONFIG_RAVE_SP_CORE=m
CONFIG_REGULATOR=y
# CONFIG_REGULATOR_DEBUG is not set
CONFIG_REGULATOR_FIXED_VOLTAGE=y
CONFIG_REGULATOR_VIRTUAL_CONSUMER=y
# CONFIG_REGULATOR_USERSPACE_CONSUMER is not set
CONFIG_REGULATOR_88PG86X=m
CONFIG_REGULATOR_88PM800=m
# CONFIG_REGULATOR_ACT8865 is not set
CONFIG_REGULATOR_AD5398=m
CONFIG_REGULATOR_ANATOP=m
# CONFIG_REGULATOR_AAT2870 is not set
CONFIG_REGULATOR_AS3711=m
# CONFIG_REGULATOR_BCM590XX is not set
# CONFIG_REGULATOR_DA9210 is not set
CONFIG_REGULATOR_DA9211=m
# CONFIG_REGULATOR_FAN53555 is not set
# CONFIG_REGULATOR_GPIO is not set
CONFIG_REGULATOR_ISL9305=m
CONFIG_REGULATOR_ISL6271A=y
CONFIG_REGULATOR_LP3971=m
CONFIG_REGULATOR_LP3972=y
CONFIG_REGULATOR_LP872X=y
# CONFIG_REGULATOR_LP8755 is not set
CONFIG_REGULATOR_LP8788=m
# CONFIG_REGULATOR_LTC3589 is not set
CONFIG_REGULATOR_LTC3676=m
CONFIG_REGULATOR_MAX14577=y
CONFIG_REGULATOR_MAX1586=y
# CONFIG_REGULATOR_MAX8649 is not set
CONFIG_REGULATOR_MAX8660=m
CONFIG_REGULATOR_MAX8907=y
CONFIG_REGULATOR_MAX8952=m
CONFIG_REGULATOR_MAX8997=m
CONFIG_REGULATOR_MAX8998=y
CONFIG_REGULATOR_MAX77693=m
CONFIG_REGULATOR_MC13XXX_CORE=m
CONFIG_REGULATOR_MC13783=m
CONFIG_REGULATOR_MC13892=m
CONFIG_REGULATOR_MT6311=m
CONFIG_REGULATOR_MT6323=y
# CONFIG_REGULATOR_MT6397 is not set
CONFIG_REGULATOR_PALMAS=y
CONFIG_REGULATOR_PCF50633=m
CONFIG_REGULATOR_PFUZE100=m
CONFIG_REGULATOR_PV88060=m
CONFIG_REGULATOR_PV88080=y
# CONFIG_REGULATOR_PV88090 is not set
CONFIG_REGULATOR_QCOM_SPMI=m
CONFIG_REGULATOR_RT5033=m
CONFIG_REGULATOR_S2MPA01=y
CONFIG_REGULATOR_S2MPS11=y
CONFIG_REGULATOR_S5M8767=m
CONFIG_REGULATOR_TPS51632=y
CONFIG_REGULATOR_TPS6105X=m
CONFIG_REGULATOR_TPS62360=y
# CONFIG_REGULATOR_TPS65023 is not set
# CONFIG_REGULATOR_TPS6507X is not set
# CONFIG_REGULATOR_TPS65132 is not set
CONFIG_REGULATOR_TPS80031=y
CONFIG_REGULATOR_TWL4030=m
CONFIG_REGULATOR_WM8350=y
# CONFIG_REGULATOR_WM8994 is not set
CONFIG_CEC_CORE=m
CONFIG_CEC_NOTIFIER=y
# CONFIG_RC_CORE is not set
CONFIG_MEDIA_SUPPORT=y

#
# Multimedia core support
#
CONFIG_MEDIA_CAMERA_SUPPORT=y
CONFIG_MEDIA_ANALOG_TV_SUPPORT=y
# CONFIG_MEDIA_DIGITAL_TV_SUPPORT is not set
CONFIG_MEDIA_RADIO_SUPPORT=y
CONFIG_MEDIA_SDR_SUPPORT=y
# CONFIG_MEDIA_CEC_SUPPORT is not set
CONFIG_MEDIA_CONTROLLER=y
CONFIG_VIDEO_DEV=y
# CONFIG_VIDEO_V4L2_SUBDEV_API is not set
CONFIG_VIDEO_V4L2=y
# CONFIG_VIDEO_ADV_DEBUG is not set
# CONFIG_VIDEO_FIXED_MINOR_RANGES is not set
CONFIG_V4L2_FWNODE=y

#
# Media drivers
#
# CONFIG_MEDIA_PCI_SUPPORT is not set
# CONFIG_V4L_PLATFORM_DRIVERS is not set
# CONFIG_V4L_MEM2MEM_DRIVERS is not set
# CONFIG_V4L_TEST_DRIVERS is not set
# CONFIG_SDR_PLATFORM_DRIVERS is not set

#
# Supported MMC/SDIO adapters
#
CONFIG_RADIO_ADAPTERS=y
CONFIG_RADIO_TEA575X=y
CONFIG_RADIO_SI470X=y
CONFIG_I2C_SI470X=y
CONFIG_RADIO_SI4713=m
CONFIG_PLATFORM_SI4713=m
CONFIG_I2C_SI4713=m
CONFIG_RADIO_MAXIRADIO=y
CONFIG_RADIO_TEA5764=m
CONFIG_RADIO_SAA7706H=y
CONFIG_RADIO_TEF6862=m
CONFIG_RADIO_WL1273=y

#
# Texas Instruments WL128x FM driver (ST based)
#
CONFIG_VIDEOBUF2_CORE=m
CONFIG_VIDEOBUF2_V4L2=m
CONFIG_VIDEOBUF2_MEMOPS=m
CONFIG_VIDEOBUF2_VMALLOC=m

#
# Media ancillary drivers (tuners, sensors, i2c, spi, frontends)
#
# CONFIG_MEDIA_SUBDRV_AUTOSELECT is not set
CONFIG_MEDIA_ATTACH=y

#
# I2C Encoders, decoders, sensors and other helper chips
#

#
# Audio decoders, processors and mixers
#
CONFIG_VIDEO_TVAUDIO=m
# CONFIG_VIDEO_TDA7432 is not set
CONFIG_VIDEO_TDA9840=m
CONFIG_VIDEO_TEA6415C=y
CONFIG_VIDEO_TEA6420=m
# CONFIG_VIDEO_MSP3400 is not set
# CONFIG_VIDEO_CS3308 is not set
CONFIG_VIDEO_CS5345=y
CONFIG_VIDEO_CS53L32A=y
CONFIG_VIDEO_TLV320AIC23B=y
# CONFIG_VIDEO_UDA1342 is not set
CONFIG_VIDEO_WM8775=m
# CONFIG_VIDEO_WM8739 is not set
CONFIG_VIDEO_VP27SMPX=m
# CONFIG_VIDEO_SONY_BTF_MPX is not set

#
# RDS decoders
#
# CONFIG_VIDEO_SAA6588 is not set

#
# Video decoders
#
# CONFIG_VIDEO_ADV7183 is not set
CONFIG_VIDEO_BT819=y
CONFIG_VIDEO_BT856=y
CONFIG_VIDEO_BT866=m
CONFIG_VIDEO_KS0127=m
CONFIG_VIDEO_ML86V7667=y
# CONFIG_VIDEO_AD5820 is not set
CONFIG_VIDEO_SAA7110=y
CONFIG_VIDEO_SAA711X=m
CONFIG_VIDEO_TVP514X=y
CONFIG_VIDEO_TVP5150=y
CONFIG_VIDEO_TVP7002=m
CONFIG_VIDEO_TW2804=y
CONFIG_VIDEO_TW9903=m
# CONFIG_VIDEO_TW9906 is not set
CONFIG_VIDEO_TW9910=y
CONFIG_VIDEO_VPX3220=y

#
# Video and audio decoders
#
CONFIG_VIDEO_SAA717X=y
# CONFIG_VIDEO_CX25840 is not set

#
# Video encoders
#
# CONFIG_VIDEO_SAA7127 is not set
CONFIG_VIDEO_SAA7185=m
# CONFIG_VIDEO_ADV7170 is not set
CONFIG_VIDEO_ADV7175=y
CONFIG_VIDEO_ADV7343=y
CONFIG_VIDEO_ADV7393=m
CONFIG_VIDEO_AK881X=m
# CONFIG_VIDEO_THS8200 is not set

#
# Camera sensor devices
#
# CONFIG_VIDEO_OV2640 is not set
CONFIG_VIDEO_OV2659=y
# CONFIG_VIDEO_OV2680 is not set
# CONFIG_VIDEO_OV2685 is not set
CONFIG_VIDEO_OV6650=m
# CONFIG_VIDEO_OV5695 is not set
CONFIG_VIDEO_OV772X=m
# CONFIG_VIDEO_OV7640 is not set
CONFIG_VIDEO_OV7670=y
CONFIG_VIDEO_OV7740=y
CONFIG_VIDEO_OV9640=m
CONFIG_VIDEO_VS6624=y
# CONFIG_VIDEO_MT9M111 is not set
CONFIG_VIDEO_MT9T112=m
CONFIG_VIDEO_MT9V011=y
# CONFIG_VIDEO_MT9V111 is not set
# CONFIG_VIDEO_SR030PC30 is not set
# CONFIG_VIDEO_RJ54N1 is not set

#
# Flash devices
#
CONFIG_VIDEO_ADP1653=m
CONFIG_VIDEO_LM3560=y
CONFIG_VIDEO_LM3646=y

#
# Video improvement chips
#
CONFIG_VIDEO_UPD64031A=y
CONFIG_VIDEO_UPD64083=y

#
# Audio/Video compression chips
#
# CONFIG_VIDEO_SAA6752HS is not set

#
# SDR tuner chips
#
CONFIG_SDR_MAX2175=m

#
# Miscellaneous helper chips
#
CONFIG_VIDEO_THS7303=m
CONFIG_VIDEO_M52790=y
CONFIG_VIDEO_I2C=m

#
# SPI helper chips
#
CONFIG_MEDIA_TUNER=y

#
# Customize TV tuners
#
CONFIG_MEDIA_TUNER_SIMPLE=m
# CONFIG_MEDIA_TUNER_TDA18250 is not set
CONFIG_MEDIA_TUNER_TDA8290=y
CONFIG_MEDIA_TUNER_TDA827X=y
CONFIG_MEDIA_TUNER_TDA18271=y
CONFIG_MEDIA_TUNER_TDA9887=y
CONFIG_MEDIA_TUNER_TEA5761=y
# CONFIG_MEDIA_TUNER_TEA5767 is not set
CONFIG_MEDIA_TUNER_MT20XX=m
CONFIG_MEDIA_TUNER_MT2060=m
# CONFIG_MEDIA_TUNER_MT2063 is not set
# CONFIG_MEDIA_TUNER_MT2266 is not set
CONFIG_MEDIA_TUNER_MT2131=y
CONFIG_MEDIA_TUNER_QT1010=m
CONFIG_MEDIA_TUNER_XC2028=m
# CONFIG_MEDIA_TUNER_XC5000 is not set
CONFIG_MEDIA_TUNER_XC4000=y
# CONFIG_MEDIA_TUNER_MXL5005S is not set
CONFIG_MEDIA_TUNER_MXL5007T=y
CONFIG_MEDIA_TUNER_MC44S803=y
# CONFIG_MEDIA_TUNER_MAX2165 is not set
CONFIG_MEDIA_TUNER_TDA18218=m
# CONFIG_MEDIA_TUNER_FC0011 is not set
CONFIG_MEDIA_TUNER_FC0012=y
CONFIG_MEDIA_TUNER_FC0013=m
CONFIG_MEDIA_TUNER_TDA18212=m
CONFIG_MEDIA_TUNER_E4000=m
# CONFIG_MEDIA_TUNER_FC2580 is not set
# CONFIG_MEDIA_TUNER_M88RS6000T is not set
CONFIG_MEDIA_TUNER_TUA9001=y
# CONFIG_MEDIA_TUNER_SI2157 is not set
CONFIG_MEDIA_TUNER_IT913X=y
CONFIG_MEDIA_TUNER_R820T=m
CONFIG_MEDIA_TUNER_MXL301RF=y
CONFIG_MEDIA_TUNER_QM1D1C0042=y
CONFIG_MEDIA_TUNER_QM1D1B0004=y

#
# Customise DVB Frontends
#

#
# Tools to develop new frontends
#

#
# Graphics support
#
# CONFIG_AGP is not set
CONFIG_INTEL_GTT=m
CONFIG_VGA_ARB=y
CONFIG_VGA_ARB_MAX_GPUS=16
# CONFIG_VGA_SWITCHEROO is not set
CONFIG_DRM=m
CONFIG_DRM_MIPI_DSI=y
CONFIG_DRM_DP_AUX_CHARDEV=y
CONFIG_DRM_DEBUG_SELFTEST=m
CONFIG_DRM_KMS_HELPER=m
# CONFIG_DRM_FBDEV_EMULATION is not set
# CONFIG_DRM_LOAD_EDID_FIRMWARE is not set
# CONFIG_DRM_DP_CEC is not set
CONFIG_DRM_TTM=m
CONFIG_DRM_GEM_CMA_HELPER=y
CONFIG_DRM_KMS_CMA_HELPER=y
CONFIG_DRM_VM=y

#
# I2C encoder or helper chips
#
CONFIG_DRM_I2C_CH7006=m
CONFIG_DRM_I2C_SIL164=m
# CONFIG_DRM_I2C_NXP_TDA998X is not set
CONFIG_DRM_I2C_NXP_TDA9950=m

#
# ARM devices
#
# CONFIG_DRM_RADEON is not set
# CONFIG_DRM_AMDGPU is not set

#
# ACP (Audio CoProcessor) Configuration
#

#
# AMD Library routines
#
CONFIG_DRM_NOUVEAU=m
CONFIG_NOUVEAU_DEBUG=5
CONFIG_NOUVEAU_DEBUG_DEFAULT=3
# CONFIG_NOUVEAU_DEBUG_MMU is not set
# CONFIG_DRM_NOUVEAU_BACKLIGHT is not set
CONFIG_DRM_I915=m
# CONFIG_DRM_I915_ALPHA_SUPPORT is not set
# CONFIG_DRM_I915_CAPTURE_ERROR is not set
# CONFIG_DRM_I915_USERPTR is not set
# CONFIG_DRM_I915_GVT is not set
CONFIG_DRM_VGEM=m
CONFIG_DRM_VKMS=m
CONFIG_DRM_VMWGFX=m
# CONFIG_DRM_VMWGFX_FBCON is not set
# CONFIG_DRM_GMA500 is not set
# CONFIG_DRM_UDL is not set
CONFIG_DRM_AST=m
CONFIG_DRM_MGAG200=m
CONFIG_DRM_CIRRUS_QEMU=m
# CONFIG_DRM_QXL is not set
CONFIG_DRM_BOCHS=m
CONFIG_DRM_VIRTIO_GPU=m
CONFIG_DRM_PANEL=y

#
# Display Panels
#
# CONFIG_DRM_PANEL_RASPBERRYPI_TOUCHSCREEN is not set
CONFIG_DRM_BRIDGE=y
CONFIG_DRM_PANEL_BRIDGE=y

#
# Display Interface Bridges
#
CONFIG_DRM_ANALOGIX_ANX78XX=m
# CONFIG_DRM_ETNAVIV is not set
CONFIG_DRM_HISI_HIBMC=m
CONFIG_DRM_TINYDRM=m
# CONFIG_DRM_LEGACY is not set
CONFIG_DRM_PANEL_ORIENTATION_QUIRKS=m
CONFIG_DRM_LIB_RANDOM=y

#
# Frame buffer Devices
#
CONFIG_FB_CMDLINE=y
CONFIG_FB_NOTIFY=y
CONFIG_FB=m
# CONFIG_FIRMWARE_EDID is not set
CONFIG_FB_DDC=m
CONFIG_FB_CFB_FILLRECT=m
CONFIG_FB_CFB_COPYAREA=m
CONFIG_FB_CFB_IMAGEBLIT=m
CONFIG_FB_SYS_FILLRECT=m
CONFIG_FB_SYS_COPYAREA=m
CONFIG_FB_SYS_IMAGEBLIT=m
CONFIG_FB_FOREIGN_ENDIAN=y
# CONFIG_FB_BOTH_ENDIAN is not set
CONFIG_FB_BIG_ENDIAN=y
# CONFIG_FB_LITTLE_ENDIAN is not set
CONFIG_FB_SYS_FOPS=m
CONFIG_FB_DEFERRED_IO=y
CONFIG_FB_HECUBA=m
CONFIG_FB_SVGALIB=m
CONFIG_FB_MODE_HELPERS=y
CONFIG_FB_TILEBLITTING=y

#
# Frame buffer hardware drivers
#
# CONFIG_FB_CIRRUS is not set
CONFIG_FB_PM2=m
# CONFIG_FB_PM2_FIFO_DISCONNECT is not set
# CONFIG_FB_CYBER2000 is not set
# CONFIG_FB_ARC is not set
# CONFIG_FB_VGA16 is not set
CONFIG_FB_N411=m
CONFIG_FB_HGA=m
CONFIG_FB_OPENCORES=m
CONFIG_FB_S1D13XXX=m
CONFIG_FB_NVIDIA=m
# CONFIG_FB_NVIDIA_I2C is not set
# CONFIG_FB_NVIDIA_DEBUG is not set
# CONFIG_FB_NVIDIA_BACKLIGHT is not set
# CONFIG_FB_RIVA is not set
CONFIG_FB_I740=m
CONFIG_FB_LE80578=m
CONFIG_FB_CARILLO_RANCH=m
CONFIG_FB_MATROX=m
# CONFIG_FB_MATROX_MILLENIUM is not set
CONFIG_FB_MATROX_MYSTIQUE=y
# CONFIG_FB_MATROX_G is not set
# CONFIG_FB_MATROX_I2C is not set
# CONFIG_FB_RADEON is not set
CONFIG_FB_ATY128=m
# CONFIG_FB_ATY128_BACKLIGHT is not set
# CONFIG_FB_ATY is not set
CONFIG_FB_S3=m
# CONFIG_FB_S3_DDC is not set
# CONFIG_FB_SAVAGE is not set
CONFIG_FB_SIS=m
CONFIG_FB_SIS_300=y
# CONFIG_FB_SIS_315 is not set
# CONFIG_FB_VIA is not set
CONFIG_FB_NEOMAGIC=m
CONFIG_FB_KYRO=m
CONFIG_FB_3DFX=m
# CONFIG_FB_3DFX_ACCEL is not set
CONFIG_FB_3DFX_I2C=y
CONFIG_FB_VOODOO1=m
CONFIG_FB_VT8623=m
# CONFIG_FB_TRIDENT is not set
CONFIG_FB_ARK=m
CONFIG_FB_PM3=m
# CONFIG_FB_CARMINE is not set
CONFIG_FB_SM501=m
# CONFIG_FB_IBM_GXT4500 is not set
CONFIG_FB_VIRTUAL=m
CONFIG_FB_METRONOME=m
CONFIG_FB_MB862XX=m
CONFIG_FB_MB862XX_PCI_GDC=y
CONFIG_FB_MB862XX_I2C=y
# CONFIG_FB_SM712 is not set
CONFIG_BACKLIGHT_LCD_SUPPORT=y
CONFIG_LCD_CLASS_DEVICE=m
# CONFIG_LCD_PLATFORM is not set
CONFIG_BACKLIGHT_CLASS_DEVICE=y
CONFIG_BACKLIGHT_GENERIC=m
CONFIG_BACKLIGHT_LM3533=m
CONFIG_BACKLIGHT_CARILLO_RANCH=m
# CONFIG_BACKLIGHT_APPLE is not set
# CONFIG_BACKLIGHT_PM8941_WLED is not set
CONFIG_BACKLIGHT_SAHARA=y
CONFIG_BACKLIGHT_ADP8860=m
# CONFIG_BACKLIGHT_ADP8870 is not set
# CONFIG_BACKLIGHT_PCF50633 is not set
CONFIG_BACKLIGHT_AAT2870=y
CONFIG_BACKLIGHT_LM3639=y
# CONFIG_BACKLIGHT_PANDORA is not set
# CONFIG_BACKLIGHT_AS3711 is not set
CONFIG_BACKLIGHT_GPIO=m
# CONFIG_BACKLIGHT_LV5207LP is not set
# CONFIG_BACKLIGHT_BD6107 is not set
CONFIG_BACKLIGHT_ARCXCNN=y
# CONFIG_BACKLIGHT_RAVE_SP is not set
CONFIG_VGASTATE=m
CONFIG_HDMI=y

#
# Console display driver support
#
CONFIG_VGA_CONSOLE=y
CONFIG_VGACON_SOFT_SCROLLBACK=y
CONFIG_VGACON_SOFT_SCROLLBACK_SIZE=64
# CONFIG_VGACON_SOFT_SCROLLBACK_PERSISTENT_ENABLE_BY_DEFAULT is not set
CONFIG_DUMMY_CONSOLE=y
CONFIG_DUMMY_CONSOLE_COLUMNS=80
CONFIG_DUMMY_CONSOLE_ROWS=25
CONFIG_FRAMEBUFFER_CONSOLE=y
# CONFIG_FRAMEBUFFER_CONSOLE_DETECT_PRIMARY is not set
CONFIG_FRAMEBUFFER_CONSOLE_ROTATION=y
# CONFIG_LOGO is not set
CONFIG_SOUND=m
CONFIG_SND=m
CONFIG_SND_TIMER=m
CONFIG_SND_PCM=m
CONFIG_SND_HWDEP=m
CONFIG_SND_RAWMIDI=m
CONFIG_SND_JACK=y
CONFIG_SND_JACK_INPUT_DEV=y
# CONFIG_SND_OSSEMUL is not set
CONFIG_SND_PCM_TIMER=y
CONFIG_SND_HRTIMER=m
# CONFIG_SND_DYNAMIC_MINORS is not set
# CONFIG_SND_SUPPORT_OLD_API is not set
CONFIG_SND_PROC_FS=y
CONFIG_SND_VERBOSE_PROCFS=y
# CONFIG_SND_VERBOSE_PRINTK is not set
CONFIG_SND_DEBUG=y
CONFIG_SND_DEBUG_VERBOSE=y
CONFIG_SND_PCM_XRUN_DEBUG=y
CONFIG_SND_VMASTER=y
CONFIG_SND_DMA_SGBUF=y
# CONFIG_SND_SEQUENCER is not set
CONFIG_SND_MPU401_UART=m
CONFIG_SND_OPL3_LIB=m
CONFIG_SND_VX_LIB=m
CONFIG_SND_AC97_CODEC=m
CONFIG_SND_DRIVERS=y
CONFIG_SND_PCSP=m
CONFIG_SND_DUMMY=m
# CONFIG_SND_ALOOP is not set
CONFIG_SND_MTPAV=m
# CONFIG_SND_MTS64 is not set
CONFIG_SND_SERIAL_U16550=m
CONFIG_SND_MPU401=m
# CONFIG_SND_PORTMAN2X4 is not set
# CONFIG_SND_AC97_POWER_SAVE is not set
CONFIG_SND_PCI=y
# CONFIG_SND_AD1889 is not set
# CONFIG_SND_ALS300 is not set
# CONFIG_SND_ALS4000 is not set
CONFIG_SND_ALI5451=m
CONFIG_SND_ASIHPI=m
CONFIG_SND_ATIIXP=m
# CONFIG_SND_ATIIXP_MODEM is not set
CONFIG_SND_AU8810=m
CONFIG_SND_AU8820=m
# CONFIG_SND_AU8830 is not set
CONFIG_SND_AW2=m
CONFIG_SND_AZT3328=m
# CONFIG_SND_BT87X is not set
CONFIG_SND_CA0106=m
CONFIG_SND_CMIPCI=m
CONFIG_SND_OXYGEN_LIB=m
CONFIG_SND_OXYGEN=m
CONFIG_SND_CS4281=m
CONFIG_SND_CS46XX=m
# CONFIG_SND_CS46XX_NEW_DSP is not set
CONFIG_SND_CTXFI=m
# CONFIG_SND_DARLA20 is not set
CONFIG_SND_GINA20=m
CONFIG_SND_LAYLA20=m
CONFIG_SND_DARLA24=m
CONFIG_SND_GINA24=m
CONFIG_SND_LAYLA24=m
CONFIG_SND_MONA=m
# CONFIG_SND_MIA is not set
# CONFIG_SND_ECHO3G is not set
CONFIG_SND_INDIGO=m
CONFIG_SND_INDIGOIO=m
CONFIG_SND_INDIGODJ=m
# CONFIG_SND_INDIGOIOX is not set
CONFIG_SND_INDIGODJX=m
CONFIG_SND_EMU10K1=m
# CONFIG_SND_EMU10K1X is not set
CONFIG_SND_ENS1370=m
CONFIG_SND_ENS1371=m
# CONFIG_SND_ES1938 is not set
CONFIG_SND_ES1968=m
# CONFIG_SND_ES1968_INPUT is not set
CONFIG_SND_ES1968_RADIO=y
CONFIG_SND_FM801=m
CONFIG_SND_FM801_TEA575X_BOOL=y
# CONFIG_SND_HDSP is not set
CONFIG_SND_HDSPM=m
CONFIG_SND_ICE1712=m
CONFIG_SND_ICE1724=m
CONFIG_SND_INTEL8X0=m
# CONFIG_SND_INTEL8X0M is not set
CONFIG_SND_KORG1212=m
CONFIG_SND_LOLA=m
CONFIG_SND_LX6464ES=m
# CONFIG_SND_MAESTRO3 is not set
CONFIG_SND_MIXART=m
CONFIG_SND_NM256=m
# CONFIG_SND_PCXHR is not set
CONFIG_SND_RIPTIDE=m
CONFIG_SND_RME32=m
CONFIG_SND_RME96=m
CONFIG_SND_RME9652=m
# CONFIG_SND_SONICVIBES is not set
CONFIG_SND_TRIDENT=m
CONFIG_SND_VIA82XX=m
CONFIG_SND_VIA82XX_MODEM=m
CONFIG_SND_VIRTUOSO=m
# CONFIG_SND_VX222 is not set
CONFIG_SND_YMFPCI=m

#
# HD-Audio
#
# CONFIG_SND_HDA_INTEL is not set
CONFIG_SND_HDA_PREALLOC_SIZE=64
CONFIG_SND_PCMCIA=y
CONFIG_SND_VXPOCKET=m
# CONFIG_SND_PDAUDIOCF is not set
# CONFIG_SND_SOC is not set
CONFIG_SND_X86=y
# CONFIG_HDMI_LPE_AUDIO is not set
CONFIG_AC97_BUS=m

#
# HID support
#
CONFIG_HID=m
CONFIG_HID_BATTERY_STRENGTH=y
# CONFIG_HIDRAW is not set
# CONFIG_UHID is not set
CONFIG_HID_GENERIC=m

#
# Special HID drivers
#
CONFIG_HID_A4TECH=m
CONFIG_HID_ACRUX=m
# CONFIG_HID_ACRUX_FF is not set
CONFIG_HID_APPLE=m
CONFIG_HID_ASUS=m
CONFIG_HID_AUREAL=m
CONFIG_HID_BELKIN=m
CONFIG_HID_CHERRY=m
CONFIG_HID_CHICONY=m
CONFIG_HID_COUGAR=m
CONFIG_HID_PRODIKEYS=m
# CONFIG_HID_CMEDIA is not set
CONFIG_HID_CYPRESS=m
# CONFIG_HID_DRAGONRISE is not set
# CONFIG_HID_EMS_FF is not set
CONFIG_HID_ELECOM=m
CONFIG_HID_EZKEY=m
CONFIG_HID_GEMBIRD=m
CONFIG_HID_GFRM=m
CONFIG_HID_KEYTOUCH=m
# CONFIG_HID_KYE is not set
CONFIG_HID_WALTOP=m
CONFIG_HID_VIEWSONIC=m
CONFIG_HID_GYRATION=m
# CONFIG_HID_ICADE is not set
CONFIG_HID_ITE=m
CONFIG_HID_JABRA=m
CONFIG_HID_TWINHAN=m
CONFIG_HID_KENSINGTON=m
# CONFIG_HID_LCPOWER is not set
CONFIG_HID_LED=m
CONFIG_HID_LENOVO=m
CONFIG_HID_LOGITECH=m
# CONFIG_HID_LOGITECH_HIDPP is not set
CONFIG_LOGITECH_FF=y
# CONFIG_LOGIRUMBLEPAD2_FF is not set
CONFIG_LOGIG940_FF=y
CONFIG_LOGIWHEELS_FF=y
CONFIG_HID_MAGICMOUSE=m
CONFIG_HID_MALTRON=m
CONFIG_HID_MAYFLASH=m
CONFIG_HID_REDRAGON=m
CONFIG_HID_MICROSOFT=m
CONFIG_HID_MONTEREY=m
# CONFIG_HID_MULTITOUCH is not set
CONFIG_HID_NTI=m
CONFIG_HID_ORTEK=m
CONFIG_HID_PANTHERLORD=m
CONFIG_PANTHERLORD_FF=y
CONFIG_HID_PETALYNX=m
CONFIG_HID_PICOLCD=m
CONFIG_HID_PICOLCD_FB=y
CONFIG_HID_PICOLCD_BACKLIGHT=y
CONFIG_HID_PICOLCD_LCD=y
CONFIG_HID_PICOLCD_LEDS=y
# CONFIG_HID_PLANTRONICS is not set
CONFIG_HID_PRIMAX=m
# CONFIG_HID_SAITEK is not set
CONFIG_HID_SAMSUNG=m
CONFIG_HID_SPEEDLINK=m
CONFIG_HID_STEAM=m
CONFIG_HID_STEELSERIES=m
CONFIG_HID_SUNPLUS=m
CONFIG_HID_RMI=m
CONFIG_HID_GREENASIA=m
CONFIG_GREENASIA_FF=y
CONFIG_HID_SMARTJOYPLUS=m
# CONFIG_SMARTJOYPLUS_FF is not set
# CONFIG_HID_TIVO is not set
CONFIG_HID_TOPSEED=m
CONFIG_HID_THINGM=m
CONFIG_HID_THRUSTMASTER=m
CONFIG_THRUSTMASTER_FF=y
CONFIG_HID_UDRAW_PS3=m
CONFIG_HID_WIIMOTE=m
CONFIG_HID_XINMO=m
CONFIG_HID_ZEROPLUS=m
CONFIG_ZEROPLUS_FF=y
CONFIG_HID_ZYDACRON=m
CONFIG_HID_SENSOR_HUB=m
# CONFIG_HID_SENSOR_CUSTOM_SENSOR is not set
CONFIG_HID_ALPS=m

#
# I2C HID support
#
CONFIG_I2C_HID=m

#
# Intel ISH HID support
#
CONFIG_INTEL_ISH_HID=m
CONFIG_USB_OHCI_LITTLE_ENDIAN=y
CONFIG_USB_SUPPORT=y
CONFIG_USB_ARCH_HAS_HCD=y
# CONFIG_USB is not set
CONFIG_USB_PCI=y

#
# USB port drivers
#

#
# USB Physical Layer drivers
#
# CONFIG_NOP_USB_XCEIV is not set
# CONFIG_USB_GPIO_VBUS is not set
# CONFIG_TAHVO_USB is not set
# CONFIG_USB_GADGET is not set
# CONFIG_TYPEC is not set
# CONFIG_USB_ROLE_SWITCH is not set
# CONFIG_USB_LED_TRIG is not set
# CONFIG_USB_ULPI_BUS is not set
CONFIG_UWB=m
# CONFIG_UWB_WHCI is not set
CONFIG_MMC=m
# CONFIG_MMC_BLOCK is not set
CONFIG_SDIO_UART=m
CONFIG_MMC_TEST=m

#
# MMC/SD/SDIO Host Controller Drivers
#
CONFIG_MMC_DEBUG=y
CONFIG_MMC_SDHCI=m
CONFIG_MMC_SDHCI_PCI=m
CONFIG_MMC_RICOH_MMC=y
# CONFIG_MMC_SDHCI_ACPI is not set
CONFIG_MMC_SDHCI_PLTFM=m
# CONFIG_MMC_SDHCI_F_SDH30 is not set
# CONFIG_MMC_WBSD is not set
# CONFIG_MMC_ALCOR is not set
CONFIG_MMC_TIFM_SD=m
CONFIG_MMC_SDRICOH_CS=m
CONFIG_MMC_CB710=m
CONFIG_MMC_VIA_SDMMC=m
CONFIG_MMC_USDHI6ROL0=m
# CONFIG_MMC_REALTEK_PCI is not set
CONFIG_MMC_CQHCI=m
CONFIG_MMC_TOSHIBA_PCI=m
# CONFIG_MMC_MTK is not set
# CONFIG_MMC_SDHCI_XENON is not set
CONFIG_MEMSTICK=m
# CONFIG_MEMSTICK_DEBUG is not set

#
# MemoryStick drivers
#
# CONFIG_MEMSTICK_UNSAFE_RESUME is not set
# CONFIG_MSPRO_BLOCK is not set
CONFIG_MS_BLOCK=m

#
# MemoryStick Host Controller Drivers
#
CONFIG_MEMSTICK_TIFM_MS=m
# CONFIG_MEMSTICK_JMICRON_38X is not set
CONFIG_MEMSTICK_R592=m
# CONFIG_MEMSTICK_REALTEK_PCI is not set
CONFIG_NEW_LEDS=y
CONFIG_LEDS_CLASS=y
CONFIG_LEDS_CLASS_FLASH=y
# CONFIG_LEDS_BRIGHTNESS_HW_CHANGED is not set

#
# LED drivers
#
# CONFIG_LEDS_APU is not set
CONFIG_LEDS_AS3645A=y
# CONFIG_LEDS_LM3530 is not set
# CONFIG_LEDS_LM3533 is not set
CONFIG_LEDS_LM3642=m
CONFIG_LEDS_LM3601X=m
# CONFIG_LEDS_MT6323 is not set
# CONFIG_LEDS_PCA9532 is not set
CONFIG_LEDS_GPIO=y
CONFIG_LEDS_LP3944=y
CONFIG_LEDS_LP3952=y
CONFIG_LEDS_LP55XX_COMMON=y
# CONFIG_LEDS_LP5521 is not set
CONFIG_LEDS_LP5523=m
CONFIG_LEDS_LP5562=y
CONFIG_LEDS_LP8501=m
# CONFIG_LEDS_LP8788 is not set
# CONFIG_LEDS_CLEVO_MAIL is not set
CONFIG_LEDS_PCA955X=y
# CONFIG_LEDS_PCA955X_GPIO is not set
# CONFIG_LEDS_PCA963X is not set
CONFIG_LEDS_WM8350=y
CONFIG_LEDS_REGULATOR=y
CONFIG_LEDS_BD2802=y
# CONFIG_LEDS_INTEL_SS4200 is not set
CONFIG_LEDS_LT3593=y
CONFIG_LEDS_MC13783=m
CONFIG_LEDS_TCA6507=y
CONFIG_LEDS_TLC591XX=m
CONFIG_LEDS_MAX8997=m
CONFIG_LEDS_LM355x=m

#
# LED driver for blink(1) USB RGB LED is under Special HID drivers (HID_THINGM)
#
CONFIG_LEDS_BLINKM=y
# CONFIG_LEDS_MLXCPLD is not set
# CONFIG_LEDS_MLXREG is not set
CONFIG_LEDS_USER=y
# CONFIG_LEDS_NIC78BX is not set

#
# LED Triggers
#
CONFIG_LEDS_TRIGGERS=y
CONFIG_LEDS_TRIGGER_TIMER=m
CONFIG_LEDS_TRIGGER_ONESHOT=y
CONFIG_LEDS_TRIGGER_DISK=y
CONFIG_LEDS_TRIGGER_HEARTBEAT=m
# CONFIG_LEDS_TRIGGER_BACKLIGHT is not set
# CONFIG_LEDS_TRIGGER_CPU is not set
CONFIG_LEDS_TRIGGER_ACTIVITY=m
CONFIG_LEDS_TRIGGER_GPIO=y
CONFIG_LEDS_TRIGGER_DEFAULT_ON=m

#
# iptables trigger is under Netfilter config (LED target)
#
# CONFIG_LEDS_TRIGGER_TRANSIENT is not set
# CONFIG_LEDS_TRIGGER_CAMERA is not set
# CONFIG_LEDS_TRIGGER_PANIC is not set
# CONFIG_LEDS_TRIGGER_NETDEV is not set
CONFIG_LEDS_TRIGGER_PATTERN=y
CONFIG_LEDS_TRIGGER_AUDIO=m
CONFIG_ACCESSIBILITY=y
# CONFIG_A11Y_BRAILLE_CONSOLE is not set
# CONFIG_INFINIBAND is not set
CONFIG_EDAC_ATOMIC_SCRUB=y
CONFIG_EDAC_SUPPORT=y
CONFIG_RTC_LIB=y
CONFIG_RTC_MC146818_LIB=y
# CONFIG_RTC_CLASS is not set
# CONFIG_DMADEVICES is not set

#
# DMABUF options
#
CONFIG_SYNC_FILE=y
CONFIG_SW_SYNC=y
CONFIG_UDMABUF=y
CONFIG_AUXDISPLAY=y
CONFIG_HD44780=y
CONFIG_KS0108=m
CONFIG_KS0108_PORT=0x378
CONFIG_KS0108_DELAY=2
# CONFIG_CFAG12864B is not set
CONFIG_IMG_ASCII_LCD=y
CONFIG_PARPORT_PANEL=m
CONFIG_PANEL_PARPORT=0
CONFIG_PANEL_PROFILE=5
# CONFIG_PANEL_CHANGE_MESSAGE is not set
# CONFIG_CHARLCD_BL_OFF is not set
# CONFIG_CHARLCD_BL_ON is not set
CONFIG_CHARLCD_BL_FLASH=y
CONFIG_PANEL=m
CONFIG_CHARLCD=y
CONFIG_UIO=m
# CONFIG_UIO_CIF is not set
CONFIG_UIO_PDRV_GENIRQ=m
CONFIG_UIO_DMEM_GENIRQ=m
CONFIG_UIO_AEC=m
# CONFIG_UIO_SERCOS3 is not set
# CONFIG_UIO_PCI_GENERIC is not set
CONFIG_UIO_NETX=m
CONFIG_UIO_PRUSS=m
CONFIG_UIO_MF624=m
CONFIG_VIRT_DRIVERS=y
CONFIG_VBOXGUEST=y
CONFIG_VIRTIO=y
# CONFIG_VIRTIO_MENU is not set

#
# Microsoft Hyper-V guest support
#
# CONFIG_HYPERV is not set
# CONFIG_STAGING is not set
CONFIG_X86_PLATFORM_DEVICES=y
# CONFIG_ACER_WMI is not set
# CONFIG_ACER_WIRELESS is not set
# CONFIG_ACERHDF is not set
# CONFIG_ALIENWARE_WMI is not set
# CONFIG_ASUS_LAPTOP is not set
CONFIG_DCDBAS=y
CONFIG_DELL_SMBIOS=m
CONFIG_DELL_SMBIOS_WMI=y
CONFIG_DELL_SMBIOS_SMM=y
CONFIG_DELL_LAPTOP=m
# CONFIG_DELL_WMI is not set
CONFIG_DELL_WMI_DESCRIPTOR=m
# CONFIG_DELL_WMI_AIO is not set
# CONFIG_DELL_WMI_LED is not set
# CONFIG_DELL_SMO8800 is not set
# CONFIG_DELL_RBU is not set
# CONFIG_FUJITSU_LAPTOP is not set
# CONFIG_FUJITSU_TABLET is not set
# CONFIG_GPD_POCKET_FAN is not set
# CONFIG_HP_ACCEL is not set
# CONFIG_HP_WIRELESS is not set
# CONFIG_HP_WMI is not set
# CONFIG_LG_LAPTOP is not set
# CONFIG_PANASONIC_LAPTOP is not set
# CONFIG_THINKPAD_ACPI is not set
CONFIG_SENSORS_HDAPS=y
# CONFIG_INTEL_MENLOW is not set
# CONFIG_EEEPC_LAPTOP is not set
# CONFIG_ASUS_WMI is not set
# CONFIG_ASUS_WIRELESS is not set
CONFIG_ACPI_WMI=m
CONFIG_WMI_BMOF=m
# CONFIG_INTEL_WMI_THUNDERBOLT is not set
# CONFIG_MSI_WMI is not set
# CONFIG_PEAQ_WMI is not set
# CONFIG_TOPSTAR_LAPTOP is not set
# CONFIG_TOSHIBA_BT_RFKILL is not set
# CONFIG_TOSHIBA_HAPS is not set
# CONFIG_TOSHIBA_WMI is not set
# CONFIG_ACPI_CMPC is not set
# CONFIG_INTEL_INT0002_VGPIO is not set
# CONFIG_INTEL_HID_EVENT is not set
# CONFIG_INTEL_VBTN is not set
# CONFIG_INTEL_IPS is not set
CONFIG_INTEL_PMC_CORE=m
CONFIG_IBM_RTL=m
CONFIG_SAMSUNG_LAPTOP=m
CONFIG_MXM_WMI=m
# CONFIG_SAMSUNG_Q10 is not set
# CONFIG_APPLE_GMUX is not set
# CONFIG_INTEL_RST is not set
# CONFIG_INTEL_SMARTCONNECT is not set
# CONFIG_INTEL_PMC_IPC is not set
# CONFIG_SURFACE_PRO3_BUTTON is not set
CONFIG_INTEL_PUNIT_IPC=m
# CONFIG_MLX_PLATFORM is not set
# CONFIG_I2C_MULTI_INSTANTIATE is not set
CONFIG_INTEL_ATOMISP2_PM=y
# CONFIG_HUAWEI_WMI is not set
CONFIG_PCENGINES_APU2=y
CONFIG_PMC_ATOM=y
CONFIG_CHROME_PLATFORMS=y
CONFIG_CHROMEOS_LAPTOP=m
# CONFIG_CHROMEOS_PSTORE is not set
# CONFIG_CHROMEOS_TBMC is not set
CONFIG_CROS_EC_I2C=m
# CONFIG_CROS_EC_LPC is not set
CONFIG_CROS_EC_PROTO=y
# CONFIG_CROS_KBD_LED_BACKLIGHT is not set
CONFIG_CROS_EC_LIGHTBAR=m
CONFIG_CROS_EC_DEBUGFS=m
# CONFIG_CROS_EC_SYSFS is not set
CONFIG_MELLANOX_PLATFORM=y
# CONFIG_MLXREG_HOTPLUG is not set
CONFIG_MLXREG_IO=y
CONFIG_CLKDEV_LOOKUP=y
CONFIG_HAVE_CLK_PREPARE=y
CONFIG_COMMON_CLK=y

#
# Common Clock Framework
#
# CONFIG_COMMON_CLK_MAX9485 is not set
# CONFIG_COMMON_CLK_SI5351 is not set
CONFIG_COMMON_CLK_SI544=m
# CONFIG_COMMON_CLK_CDCE706 is not set
# CONFIG_COMMON_CLK_CS2000_CP is not set
# CONFIG_COMMON_CLK_S2MPS11 is not set
CONFIG_CLK_TWL6040=y
# CONFIG_COMMON_CLK_PALMAS is not set
CONFIG_HWSPINLOCK=y

#
# Clock Source drivers
#
CONFIG_CLKEVT_I8253=y
CONFIG_I8253_LOCK=y
CONFIG_CLKBLD_I8253=y
CONFIG_MAILBOX=y
# CONFIG_PCC is not set
CONFIG_ALTERA_MBOX=y
CONFIG_IOMMU_IOVA=m
CONFIG_IOMMU_SUPPORT=y

#
# Generic IOMMU Pagetable Support
#
# CONFIG_IOMMU_DEBUGFS is not set
# CONFIG_AMD_IOMMU is not set
# CONFIG_INTEL_IOMMU is not set
# CONFIG_IRQ_REMAP is not set

#
# Remoteproc drivers
#
CONFIG_REMOTEPROC=y

#
# Rpmsg drivers
#
CONFIG_RPMSG=y
# CONFIG_RPMSG_CHAR is not set
CONFIG_RPMSG_QCOM_GLINK_NATIVE=y
CONFIG_RPMSG_QCOM_GLINK_RPM=y
CONFIG_RPMSG_VIRTIO=m
CONFIG_SOUNDWIRE=y

#
# SoundWire Devices
#

#
# SOC (System On Chip) specific Drivers
#

#
# Amlogic SoC drivers
#

#
# Broadcom SoC drivers
#

#
# NXP/Freescale QorIQ SoC drivers
#

#
# i.MX SoC drivers
#

#
# Qualcomm SoC drivers
#
CONFIG_SOC_TI=y

#
# Xilinx SoC drivers
#
CONFIG_XILINX_VCU=m
CONFIG_PM_DEVFREQ=y

#
# DEVFREQ Governors
#
CONFIG_DEVFREQ_GOV_SIMPLE_ONDEMAND=y
CONFIG_DEVFREQ_GOV_PERFORMANCE=m
# CONFIG_DEVFREQ_GOV_POWERSAVE is not set
CONFIG_DEVFREQ_GOV_USERSPACE=y
CONFIG_DEVFREQ_GOV_PASSIVE=y

#
# DEVFREQ Drivers
#
CONFIG_PM_DEVFREQ_EVENT=y
# CONFIG_EXTCON is not set
# CONFIG_MEMORY is not set
# CONFIG_IIO is not set
CONFIG_NTB=y
# CONFIG_NTB_AMD is not set
CONFIG_NTB_IDT=y
CONFIG_NTB_INTEL=m
# CONFIG_NTB_SWITCHTEC is not set
# CONFIG_NTB_PINGPONG is not set
CONFIG_NTB_TOOL=m
# CONFIG_NTB_PERF is not set
CONFIG_NTB_TRANSPORT=m
# CONFIG_VME_BUS is not set
# CONFIG_PWM is not set

#
# IRQ chip support
#
CONFIG_ARM_GIC_MAX_NR=1
CONFIG_MADERA_IRQ=y
CONFIG_IPACK_BUS=y
# CONFIG_BOARD_TPCI200 is not set
# CONFIG_SERIAL_IPOCTAL is not set
CONFIG_RESET_CONTROLLER=y
# CONFIG_RESET_TI_SYSCON is not set
CONFIG_FMC=y
# CONFIG_FMC_FAKEDEV is not set
CONFIG_FMC_TRIVIAL=m
# CONFIG_FMC_WRITE_EEPROM is not set
CONFIG_FMC_CHARDEV=y

#
# PHY Subsystem
#
CONFIG_GENERIC_PHY=y
CONFIG_BCM_KONA_USB2_PHY=y
CONFIG_PHY_PXA_28NM_HSIC=y
# CONFIG_PHY_PXA_28NM_USB2 is not set
# CONFIG_POWERCAP is not set
CONFIG_MCB=y
CONFIG_MCB_PCI=m
# CONFIG_MCB_LPC is not set

#
# Performance monitor support
#
# CONFIG_RAS is not set
CONFIG_THUNDERBOLT=m

#
# Android
#
# CONFIG_ANDROID is not set
# CONFIG_LIBNVDIMM is not set
CONFIG_DAX=m
CONFIG_DEV_DAX=m
CONFIG_DEV_DAX_KMEM=m
CONFIG_NVMEM=y
# CONFIG_RAVE_SP_EEPROM is not set

#
# HW tracing support
#
CONFIG_STM=m
CONFIG_STM_PROTO_BASIC=m
# CONFIG_STM_PROTO_SYS_T is not set
# CONFIG_STM_DUMMY is not set
CONFIG_STM_SOURCE_CONSOLE=m
CONFIG_STM_SOURCE_HEARTBEAT=m
# CONFIG_INTEL_TH is not set
CONFIG_FPGA=y
CONFIG_ALTERA_PR_IP_CORE=m
CONFIG_FPGA_MGR_ALTERA_CVP=y
CONFIG_FPGA_BRIDGE=y
CONFIG_ALTERA_FREEZE_BRIDGE=m
CONFIG_XILINX_PR_DECOUPLER=y
CONFIG_FPGA_REGION=m
CONFIG_FPGA_DFL=m
# CONFIG_FPGA_DFL_FME is not set
CONFIG_FPGA_DFL_AFU=m
# CONFIG_FPGA_DFL_PCI is not set
CONFIG_PM_OPP=y
# CONFIG_UNISYS_VISORBUS is not set
CONFIG_SIOX=m
# CONFIG_SIOX_BUS_GPIO is not set
CONFIG_SLIMBUS=m
# CONFIG_SLIM_QCOM_CTRL is not set
CONFIG_INTERCONNECT=m

#
# File systems
#
CONFIG_DCACHE_WORD_ACCESS=y
# CONFIG_VALIDATE_FS_PARSER is not set
CONFIG_FS_IOMAP=y
# CONFIG_EXT2_FS is not set
CONFIG_EXT3_FS=m
# CONFIG_EXT3_FS_POSIX_ACL is not set
# CONFIG_EXT3_FS_SECURITY is not set
CONFIG_EXT4_FS=m
# CONFIG_EXT4_USE_FOR_EXT2 is not set
CONFIG_EXT4_FS_POSIX_ACL=y
CONFIG_EXT4_FS_SECURITY=y
# CONFIG_EXT4_DEBUG is not set
CONFIG_JBD2=m
# CONFIG_JBD2_DEBUG is not set
CONFIG_FS_MBCACHE=m
CONFIG_REISERFS_FS=m
CONFIG_REISERFS_CHECK=y
CONFIG_REISERFS_PROC_INFO=y
CONFIG_REISERFS_FS_XATTR=y
CONFIG_REISERFS_FS_POSIX_ACL=y
CONFIG_REISERFS_FS_SECURITY=y
# CONFIG_JFS_FS is not set
# CONFIG_XFS_FS is not set
CONFIG_GFS2_FS=y
# CONFIG_OCFS2_FS is not set
# CONFIG_BTRFS_FS is not set
# CONFIG_NILFS2_FS is not set
CONFIG_F2FS_FS=m
# CONFIG_F2FS_STAT_FS is not set
CONFIG_F2FS_FS_XATTR=y
CONFIG_F2FS_FS_POSIX_ACL=y
CONFIG_F2FS_FS_SECURITY=y
CONFIG_F2FS_CHECK_FS=y
CONFIG_F2FS_FAULT_INJECTION=y
# CONFIG_FS_DAX is not set
CONFIG_FS_POSIX_ACL=y
CONFIG_EXPORTFS=y
CONFIG_EXPORTFS_BLOCK_OPS=y
CONFIG_FILE_LOCKING=y
# CONFIG_MANDATORY_FILE_LOCKING is not set
CONFIG_FS_ENCRYPTION=y
CONFIG_FSNOTIFY=y
# CONFIG_DNOTIFY is not set
CONFIG_INOTIFY_USER=y
CONFIG_FANOTIFY=y
CONFIG_QUOTA=y
# CONFIG_QUOTA_NETLINK_INTERFACE is not set
CONFIG_PRINT_QUOTA_WARNING=y
# CONFIG_QUOTA_DEBUG is not set
CONFIG_QUOTA_TREE=y
# CONFIG_QFMT_V1 is not set
CONFIG_QFMT_V2=y
CONFIG_QUOTACTL=y
CONFIG_QUOTACTL_COMPAT=y
CONFIG_AUTOFS4_FS=y
CONFIG_AUTOFS_FS=y
CONFIG_FUSE_FS=m
CONFIG_CUSE=m
CONFIG_OVERLAY_FS=m
CONFIG_OVERLAY_FS_REDIRECT_DIR=y
CONFIG_OVERLAY_FS_REDIRECT_ALWAYS_FOLLOW=y
# CONFIG_OVERLAY_FS_INDEX is not set
CONFIG_OVERLAY_FS_XINO_AUTO=y
# CONFIG_OVERLAY_FS_METACOPY is not set

#
# Caches
#
CONFIG_FSCACHE=m
CONFIG_FSCACHE_STATS=y
# CONFIG_FSCACHE_HISTOGRAM is not set
# CONFIG_FSCACHE_DEBUG is not set
# CONFIG_FSCACHE_OBJECT_LIST is not set
CONFIG_CACHEFILES=m
# CONFIG_CACHEFILES_DEBUG is not set
CONFIG_CACHEFILES_HISTOGRAM=y

#
# CD-ROM/DVD Filesystems
#
# CONFIG_ISO9660_FS is not set
CONFIG_UDF_FS=m

#
# DOS/FAT/NT Filesystems
#
CONFIG_FAT_FS=y
# CONFIG_MSDOS_FS is not set
CONFIG_VFAT_FS=y
CONFIG_FAT_DEFAULT_CODEPAGE=437
CONFIG_FAT_DEFAULT_IOCHARSET="iso8859-1"
# CONFIG_FAT_DEFAULT_UTF8 is not set
CONFIG_NTFS_FS=m
CONFIG_NTFS_DEBUG=y
CONFIG_NTFS_RW=y

#
# Pseudo filesystems
#
CONFIG_PROC_FS=y
CONFIG_PROC_KCORE=y
CONFIG_PROC_VMCORE=y
CONFIG_PROC_VMCORE_DEVICE_DUMP=y
CONFIG_PROC_SYSCTL=y
CONFIG_PROC_PAGE_MONITOR=y
CONFIG_PROC_CHILDREN=y
CONFIG_KERNFS=y
CONFIG_SYSFS=y
CONFIG_TMPFS=y
# CONFIG_TMPFS_POSIX_ACL is not set
# CONFIG_TMPFS_XATTR is not set
# CONFIG_HUGETLBFS is not set
CONFIG_MEMFD_CREATE=y
CONFIG_ARCH_HAS_GIGANTIC_PAGE=y
CONFIG_CONFIGFS_FS=y
# CONFIG_MISC_FILESYSTEMS is not set
CONFIG_NETWORK_FILESYSTEMS=y
CONFIG_NFS_FS=y
CONFIG_NFS_V2=y
CONFIG_NFS_V3=y
# CONFIG_NFS_V3_ACL is not set
CONFIG_NFS_V4=m
# CONFIG_NFS_SWAP is not set
# CONFIG_NFS_V4_1 is not set
# CONFIG_ROOT_NFS is not set
# CONFIG_NFS_USE_LEGACY_DNS is not set
CONFIG_NFS_USE_KERNEL_DNS=y
# CONFIG_NFSD is not set
CONFIG_GRACE_PERIOD=y
CONFIG_LOCKD=y
CONFIG_LOCKD_V4=y
CONFIG_NFS_COMMON=y
CONFIG_SUNRPC=y
CONFIG_SUNRPC_GSS=y
CONFIG_RPCSEC_GSS_KRB5=y
# CONFIG_CONFIG_SUNRPC_DISABLE_INSECURE_ENCTYPES is not set
# CONFIG_SUNRPC_DEBUG is not set
# CONFIG_CEPH_FS is not set
CONFIG_CIFS=m
# CONFIG_CIFS_STATS2 is not set
CONFIG_CIFS_ALLOW_INSECURE_LEGACY=y
# CONFIG_CIFS_WEAK_PW_HASH is not set
# CONFIG_CIFS_UPCALL is not set
# CONFIG_CIFS_XATTR is not set
CONFIG_CIFS_DEBUG=y
# CONFIG_CIFS_DEBUG2 is not set
# CONFIG_CIFS_DEBUG_DUMP_KEYS is not set
# CONFIG_CIFS_DFS_UPCALL is not set
# CONFIG_CIFS_FSCACHE is not set
# CONFIG_CODA_FS is not set
# CONFIG_AFS_FS is not set
# CONFIG_9P_FS is not set
CONFIG_NLS=y
CONFIG_NLS_DEFAULT="iso8859-1"
CONFIG_NLS_CODEPAGE_437=m
CONFIG_NLS_CODEPAGE_737=m
# CONFIG_NLS_CODEPAGE_775 is not set
# CONFIG_NLS_CODEPAGE_850 is not set
CONFIG_NLS_CODEPAGE_852=m
CONFIG_NLS_CODEPAGE_855=y
# CONFIG_NLS_CODEPAGE_857 is not set
CONFIG_NLS_CODEPAGE_860=m
CONFIG_NLS_CODEPAGE_861=m
# CONFIG_NLS_CODEPAGE_862 is not set
CONFIG_NLS_CODEPAGE_863=y
CONFIG_NLS_CODEPAGE_864=m
CONFIG_NLS_CODEPAGE_865=y
CONFIG_NLS_CODEPAGE_866=m
# CONFIG_NLS_CODEPAGE_869 is not set
CONFIG_NLS_CODEPAGE_936=y
# CONFIG_NLS_CODEPAGE_950 is not set
# CONFIG_NLS_CODEPAGE_932 is not set
CONFIG_NLS_CODEPAGE_949=y
CONFIG_NLS_CODEPAGE_874=m
CONFIG_NLS_ISO8859_8=y
# CONFIG_NLS_CODEPAGE_1250 is not set
# CONFIG_NLS_CODEPAGE_1251 is not set
CONFIG_NLS_ASCII=m
# CONFIG_NLS_ISO8859_1 is not set
# CONFIG_NLS_ISO8859_2 is not set
# CONFIG_NLS_ISO8859_3 is not set
CONFIG_NLS_ISO8859_4=y
# CONFIG_NLS_ISO8859_5 is not set
CONFIG_NLS_ISO8859_6=y
CONFIG_NLS_ISO8859_7=m
CONFIG_NLS_ISO8859_9=m
# CONFIG_NLS_ISO8859_13 is not set
# CONFIG_NLS_ISO8859_14 is not set
# CONFIG_NLS_ISO8859_15 is not set
CONFIG_NLS_KOI8_R=y
CONFIG_NLS_KOI8_U=m
CONFIG_NLS_MAC_ROMAN=m
CONFIG_NLS_MAC_CELTIC=y
CONFIG_NLS_MAC_CENTEURO=m
CONFIG_NLS_MAC_CROATIAN=m
CONFIG_NLS_MAC_CYRILLIC=y
# CONFIG_NLS_MAC_GAELIC is not set
CONFIG_NLS_MAC_GREEK=m
CONFIG_NLS_MAC_ICELAND=y
CONFIG_NLS_MAC_INUIT=m
CONFIG_NLS_MAC_ROMANIAN=y
# CONFIG_NLS_MAC_TURKISH is not set
CONFIG_NLS_UTF8=m
# CONFIG_DLM is not set

#
# Security options
#
CONFIG_KEYS=y
CONFIG_KEYS_COMPAT=y
CONFIG_PERSISTENT_KEYRINGS=y
# CONFIG_BIG_KEYS is not set
CONFIG_TRUSTED_KEYS=m
CONFIG_ENCRYPTED_KEYS=m
CONFIG_KEY_DH_OPERATIONS=y
CONFIG_SECURITY_DMESG_RESTRICT=y
# CONFIG_SECURITY is not set
CONFIG_SECURITYFS=y
CONFIG_PAGE_TABLE_ISOLATION=y
CONFIG_HAVE_HARDENED_USERCOPY_ALLOCATOR=y
CONFIG_HARDENED_USERCOPY=y
CONFIG_HARDENED_USERCOPY_FALLBACK=y
CONFIG_FORTIFY_SOURCE=y
# CONFIG_STATIC_USERMODEHELPER is not set
CONFIG_LSM="yama,loadpin,safesetid,integrity"
CONFIG_CRYPTO=y

#
# Crypto core or helper
#
CONFIG_CRYPTO_ALGAPI=y
CONFIG_CRYPTO_ALGAPI2=y
CONFIG_CRYPTO_AEAD=y
CONFIG_CRYPTO_AEAD2=y
CONFIG_CRYPTO_BLKCIPHER=y
CONFIG_CRYPTO_BLKCIPHER2=y
CONFIG_CRYPTO_HASH=y
CONFIG_CRYPTO_HASH2=y
CONFIG_CRYPTO_RNG=y
CONFIG_CRYPTO_RNG2=y
CONFIG_CRYPTO_RNG_DEFAULT=y
CONFIG_CRYPTO_AKCIPHER2=y
CONFIG_CRYPTO_AKCIPHER=y
CONFIG_CRYPTO_KPP2=y
CONFIG_CRYPTO_KPP=y
CONFIG_CRYPTO_ACOMP2=y
CONFIG_CRYPTO_RSA=y
CONFIG_CRYPTO_DH=y
CONFIG_CRYPTO_ECDH=y
CONFIG_CRYPTO_MANAGER=y
CONFIG_CRYPTO_MANAGER2=y
# CONFIG_CRYPTO_USER is not set
CONFIG_CRYPTO_MANAGER_DISABLE_TESTS=y
CONFIG_CRYPTO_GF128MUL=m
CONFIG_CRYPTO_NULL=y
CONFIG_CRYPTO_NULL2=y
# CONFIG_CRYPTO_PCRYPT is not set
CONFIG_CRYPTO_WORKQUEUE=y
CONFIG_CRYPTO_CRYPTD=y
CONFIG_CRYPTO_AUTHENC=y
# CONFIG_CRYPTO_TEST is not set
CONFIG_CRYPTO_SIMD=y
CONFIG_CRYPTO_GLUE_HELPER_X86=y

#
# Authenticated Encryption with Associated Data
#
CONFIG_CRYPTO_CCM=m
# CONFIG_CRYPTO_GCM is not set
# CONFIG_CRYPTO_CHACHA20POLY1305 is not set
CONFIG_CRYPTO_AEGIS128=m
CONFIG_CRYPTO_AEGIS128L=m
CONFIG_CRYPTO_AEGIS256=y
# CONFIG_CRYPTO_AEGIS128_AESNI_SSE2 is not set
# CONFIG_CRYPTO_AEGIS128L_AESNI_SSE2 is not set
CONFIG_CRYPTO_AEGIS256_AESNI_SSE2=y
CONFIG_CRYPTO_MORUS640=m
CONFIG_CRYPTO_MORUS640_GLUE=m
CONFIG_CRYPTO_MORUS640_SSE2=m
CONFIG_CRYPTO_MORUS1280=y
CONFIG_CRYPTO_MORUS1280_GLUE=m
CONFIG_CRYPTO_MORUS1280_SSE2=m
CONFIG_CRYPTO_MORUS1280_AVX2=m
CONFIG_CRYPTO_SEQIV=y
CONFIG_CRYPTO_ECHAINIV=m

#
# Block modes
#
CONFIG_CRYPTO_CBC=y
CONFIG_CRYPTO_CFB=y
CONFIG_CRYPTO_CTR=y
CONFIG_CRYPTO_CTS=y
CONFIG_CRYPTO_ECB=y
# CONFIG_CRYPTO_LRW is not set
CONFIG_CRYPTO_OFB=m
CONFIG_CRYPTO_PCBC=m
CONFIG_CRYPTO_XTS=y
# CONFIG_CRYPTO_KEYWRAP is not set
CONFIG_CRYPTO_NHPOLY1305=y
CONFIG_CRYPTO_NHPOLY1305_SSE2=y
CONFIG_CRYPTO_NHPOLY1305_AVX2=m
# CONFIG_CRYPTO_ADIANTUM is not set

#
# Hash modes
#
CONFIG_CRYPTO_CMAC=y
CONFIG_CRYPTO_HMAC=y
CONFIG_CRYPTO_XCBC=m
# CONFIG_CRYPTO_VMAC is not set

#
# Digest
#
CONFIG_CRYPTO_CRC32C=y
# CONFIG_CRYPTO_CRC32C_INTEL is not set
CONFIG_CRYPTO_CRC32=y
# CONFIG_CRYPTO_CRC32_PCLMUL is not set
CONFIG_CRYPTO_CRCT10DIF=y
# CONFIG_CRYPTO_CRCT10DIF_PCLMUL is not set
CONFIG_CRYPTO_GHASH=m
CONFIG_CRYPTO_POLY1305=y
CONFIG_CRYPTO_POLY1305_X86_64=y
CONFIG_CRYPTO_MD4=y
CONFIG_CRYPTO_MD5=y
# CONFIG_CRYPTO_MICHAEL_MIC is not set
# CONFIG_CRYPTO_RMD128 is not set
CONFIG_CRYPTO_RMD160=y
# CONFIG_CRYPTO_RMD256 is not set
CONFIG_CRYPTO_RMD320=y
CONFIG_CRYPTO_SHA1=y
CONFIG_CRYPTO_SHA1_SSSE3=m
# CONFIG_CRYPTO_SHA256_SSSE3 is not set
CONFIG_CRYPTO_SHA512_SSSE3=m
CONFIG_CRYPTO_SHA256=y
CONFIG_CRYPTO_SHA512=y
# CONFIG_CRYPTO_SHA3 is not set
# CONFIG_CRYPTO_SM3 is not set
CONFIG_CRYPTO_STREEBOG=m
CONFIG_CRYPTO_TGR192=m
# CONFIG_CRYPTO_WP512 is not set
# CONFIG_CRYPTO_GHASH_CLMUL_NI_INTEL is not set

#
# Ciphers
#
CONFIG_CRYPTO_AES=y
CONFIG_CRYPTO_AES_TI=m
CONFIG_CRYPTO_AES_X86_64=m
# CONFIG_CRYPTO_AES_NI_INTEL is not set
CONFIG_CRYPTO_ANUBIS=y
CONFIG_CRYPTO_ARC4=y
CONFIG_CRYPTO_BLOWFISH=m
CONFIG_CRYPTO_BLOWFISH_COMMON=y
CONFIG_CRYPTO_BLOWFISH_X86_64=y
CONFIG_CRYPTO_CAMELLIA=y
CONFIG_CRYPTO_CAMELLIA_X86_64=y
CONFIG_CRYPTO_CAMELLIA_AESNI_AVX_X86_64=y
CONFIG_CRYPTO_CAMELLIA_AESNI_AVX2_X86_64=m
CONFIG_CRYPTO_CAST_COMMON=m
CONFIG_CRYPTO_CAST5=m
CONFIG_CRYPTO_CAST5_AVX_X86_64=m
CONFIG_CRYPTO_CAST6=m
# CONFIG_CRYPTO_CAST6_AVX_X86_64 is not set
CONFIG_CRYPTO_DES=y
# CONFIG_CRYPTO_DES3_EDE_X86_64 is not set
CONFIG_CRYPTO_FCRYPT=m
CONFIG_CRYPTO_KHAZAD=m
CONFIG_CRYPTO_SALSA20=m
# CONFIG_CRYPTO_CHACHA20 is not set
# CONFIG_CRYPTO_CHACHA20_X86_64 is not set
CONFIG_CRYPTO_SEED=y
CONFIG_CRYPTO_SERPENT=y
CONFIG_CRYPTO_SERPENT_SSE2_X86_64=m
CONFIG_CRYPTO_SERPENT_AVX_X86_64=y
# CONFIG_CRYPTO_SERPENT_AVX2_X86_64 is not set
CONFIG_CRYPTO_SM4=m
CONFIG_CRYPTO_TEA=m
# CONFIG_CRYPTO_TWOFISH is not set
CONFIG_CRYPTO_TWOFISH_COMMON=y
CONFIG_CRYPTO_TWOFISH_X86_64=y
CONFIG_CRYPTO_TWOFISH_X86_64_3WAY=y
CONFIG_CRYPTO_TWOFISH_AVX_X86_64=y

#
# Compression
#
# CONFIG_CRYPTO_DEFLATE is not set
CONFIG_CRYPTO_LZO=m
CONFIG_CRYPTO_842=m
CONFIG_CRYPTO_LZ4=y
CONFIG_CRYPTO_LZ4HC=m
CONFIG_CRYPTO_ZSTD=y

#
# Random Number Generation
#
CONFIG_CRYPTO_ANSI_CPRNG=y
CONFIG_CRYPTO_DRBG_MENU=y
CONFIG_CRYPTO_DRBG_HMAC=y
# CONFIG_CRYPTO_DRBG_HASH is not set
CONFIG_CRYPTO_DRBG_CTR=y
CONFIG_CRYPTO_DRBG=y
CONFIG_CRYPTO_JITTERENTROPY=y
# CONFIG_CRYPTO_USER_API_HASH is not set
# CONFIG_CRYPTO_USER_API_SKCIPHER is not set
# CONFIG_CRYPTO_USER_API_RNG is not set
# CONFIG_CRYPTO_USER_API_AEAD is not set
CONFIG_CRYPTO_HASH_INFO=y
CONFIG_CRYPTO_HW=y
# CONFIG_CRYPTO_DEV_PADLOCK is not set
# CONFIG_CRYPTO_DEV_CCP is not set
CONFIG_CRYPTO_DEV_QAT=y
# CONFIG_CRYPTO_DEV_QAT_DH895xCC is not set
CONFIG_CRYPTO_DEV_QAT_C3XXX=m
CONFIG_CRYPTO_DEV_QAT_C62X=y
CONFIG_CRYPTO_DEV_QAT_DH895xCCVF=m
CONFIG_CRYPTO_DEV_QAT_C3XXXVF=y
# CONFIG_CRYPTO_DEV_QAT_C62XVF is not set
CONFIG_CRYPTO_DEV_NITROX=y
CONFIG_CRYPTO_DEV_NITROX_CNN55XX=y
# CONFIG_CRYPTO_DEV_VIRTIO is not set
CONFIG_ASYMMETRIC_KEY_TYPE=y
# CONFIG_ASYMMETRIC_PUBLIC_KEY_SUBTYPE is not set
CONFIG_ASYMMETRIC_TPM_KEY_SUBTYPE=m
# CONFIG_TPM_KEY_PARSER is not set

#
# Certificates for signature checking
#
CONFIG_SYSTEM_TRUSTED_KEYRING=y
CONFIG_SYSTEM_TRUSTED_KEYS=""
# CONFIG_SYSTEM_EXTRA_CERTIFICATE is not set
# CONFIG_SECONDARY_TRUSTED_KEYRING is not set
CONFIG_SYSTEM_BLACKLIST_KEYRING=y
CONFIG_SYSTEM_BLACKLIST_HASH_LIST=""
CONFIG_BINARY_PRINTF=y

#
# Library routines
#
CONFIG_BITREVERSE=y
CONFIG_GENERIC_STRNCPY_FROM_USER=y
CONFIG_GENERIC_STRNLEN_USER=y
CONFIG_GENERIC_NET_UTILS=y
CONFIG_GENERIC_FIND_FIRST_BIT=y
CONFIG_CORDIC=m
CONFIG_PRIME_NUMBERS=m
CONFIG_RATIONAL=y
CONFIG_GENERIC_PCI_IOMAP=y
CONFIG_GENERIC_IOMAP=y
CONFIG_ARCH_USE_CMPXCHG_LOCKREF=y
CONFIG_ARCH_HAS_FAST_MULTIPLIER=y
CONFIG_CRC_CCITT=m
CONFIG_CRC16=y
CONFIG_CRC_T10DIF=y
CONFIG_CRC_ITU_T=y
CONFIG_CRC32=y
CONFIG_CRC32_SELFTEST=m
# CONFIG_CRC32_SLICEBY8 is not set
# CONFIG_CRC32_SLICEBY4 is not set
CONFIG_CRC32_SARWATE=y
# CONFIG_CRC32_BIT is not set
CONFIG_CRC64=y
CONFIG_CRC4=y
CONFIG_CRC7=m
CONFIG_LIBCRC32C=y
CONFIG_CRC8=m
CONFIG_XXHASH=y
# CONFIG_RANDOM32_SELFTEST is not set
CONFIG_842_COMPRESS=m
CONFIG_842_DECOMPRESS=m
CONFIG_ZLIB_INFLATE=y
CONFIG_LZO_COMPRESS=m
CONFIG_LZO_DECOMPRESS=y
CONFIG_LZ4_COMPRESS=y
CONFIG_LZ4HC_COMPRESS=m
CONFIG_LZ4_DECOMPRESS=y
CONFIG_ZSTD_COMPRESS=y
CONFIG_ZSTD_DECOMPRESS=y
CONFIG_XZ_DEC=y
CONFIG_XZ_DEC_X86=y
CONFIG_XZ_DEC_POWERPC=y
CONFIG_XZ_DEC_IA64=y
CONFIG_XZ_DEC_ARM=y
CONFIG_XZ_DEC_ARMTHUMB=y
CONFIG_XZ_DEC_SPARC=y
CONFIG_XZ_DEC_BCJ=y
# CONFIG_XZ_DEC_TEST is not set
CONFIG_DECOMPRESS_GZIP=y
CONFIG_DECOMPRESS_BZIP2=y
CONFIG_DECOMPRESS_LZMA=y
CONFIG_DECOMPRESS_XZ=y
CONFIG_DECOMPRESS_LZO=y
CONFIG_DECOMPRESS_LZ4=y
CONFIG_GENERIC_ALLOCATOR=y
CONFIG_INTERVAL_TREE=y
CONFIG_XARRAY_MULTI=y
CONFIG_ASSOCIATIVE_ARRAY=y
CONFIG_HAS_IOMEM=y
CONFIG_HAS_IOPORT_MAP=y
CONFIG_HAS_DMA=y
CONFIG_NEED_SG_DMA_LENGTH=y
CONFIG_NEED_DMA_MAP_STATE=y
CONFIG_ARCH_DMA_ADDR_T_64BIT=y
CONFIG_DMA_DECLARE_COHERENT=y
CONFIG_SWIOTLB=y
CONFIG_DMA_CMA=y

#
# Default contiguous memory area size:
#
CONFIG_CMA_SIZE_PERCENTAGE=0
# CONFIG_CMA_SIZE_SEL_MBYTES is not set
CONFIG_CMA_SIZE_SEL_PERCENTAGE=y
# CONFIG_CMA_SIZE_SEL_MIN is not set
# CONFIG_CMA_SIZE_SEL_MAX is not set
CONFIG_CMA_ALIGNMENT=8
# CONFIG_DMA_API_DEBUG is not set
CONFIG_SGL_ALLOC=y
CONFIG_IOMMU_HELPER=y
CONFIG_CHECK_SIGNATURE=y
CONFIG_CPUMASK_OFFSTACK=y
CONFIG_CPU_RMAP=y
CONFIG_DQL=y
CONFIG_GLOB=y
CONFIG_GLOB_SELFTEST=m
CONFIG_NLATTR=y
CONFIG_CLZ_TAB=y
CONFIG_DDR=y
# CONFIG_IRQ_POLL is not set
CONFIG_MPILIB=y
CONFIG_OID_REGISTRY=y
CONFIG_FONT_SUPPORT=y
CONFIG_FONTS=y
# CONFIG_FONT_8x8 is not set
CONFIG_FONT_8x16=y
CONFIG_FONT_6x11=y
CONFIG_FONT_7x14=y
# CONFIG_FONT_PEARL_8x8 is not set
CONFIG_FONT_ACORN_8x8=y
# CONFIG_FONT_MINI_4x6 is not set
# CONFIG_FONT_6x10 is not set
# CONFIG_FONT_10x18 is not set
CONFIG_FONT_SUN8x16=y
# CONFIG_FONT_SUN12x22 is not set
CONFIG_FONT_TER16x32=y
CONFIG_SG_POOL=y
CONFIG_ARCH_HAS_PMEM_API=y
CONFIG_ARCH_HAS_UACCESS_FLUSHCACHE=y
CONFIG_ARCH_HAS_UACCESS_MCSAFE=y
CONFIG_STACKDEPOT=y
CONFIG_SBITMAP=y
CONFIG_STRING_SELFTEST=y

#
# Kernel hacking
#

#
# printk and dmesg options
#
CONFIG_PRINTK_TIME=y
# CONFIG_PRINTK_CALLER is not set
CONFIG_CONSOLE_LOGLEVEL_DEFAULT=7
CONFIG_CONSOLE_LOGLEVEL_QUIET=4
CONFIG_MESSAGE_LOGLEVEL_DEFAULT=4
# CONFIG_BOOT_PRINTK_DELAY is not set
CONFIG_DYNAMIC_DEBUG=y

#
# Compile-time checks and compiler options
#
CONFIG_DEBUG_INFO=y
CONFIG_DEBUG_INFO_REDUCED=y
# CONFIG_DEBUG_INFO_SPLIT is not set
# CONFIG_DEBUG_INFO_DWARF4 is not set
# CONFIG_GDB_SCRIPTS is not set
CONFIG_ENABLE_MUST_CHECK=y
CONFIG_FRAME_WARN=8192
# CONFIG_STRIP_ASM_SYMS is not set
CONFIG_READABLE_ASM=y
# CONFIG_UNUSED_SYMBOLS is not set
CONFIG_DEBUG_FS=y
CONFIG_HEADERS_CHECK=y
CONFIG_DEBUG_SECTION_MISMATCH=y
CONFIG_SECTION_MISMATCH_WARN_ONLY=y
CONFIG_STACK_VALIDATION=y
# CONFIG_DEBUG_FORCE_WEAK_PER_CPU is not set
CONFIG_MAGIC_SYSRQ=y
CONFIG_MAGIC_SYSRQ_DEFAULT_ENABLE=0x1
CONFIG_MAGIC_SYSRQ_SERIAL=y
CONFIG_DEBUG_KERNEL=y

#
# Memory Debugging
#
CONFIG_PAGE_EXTENSION=y
# CONFIG_DEBUG_PAGEALLOC is not set
# CONFIG_PAGE_OWNER is not set
# CONFIG_PAGE_POISONING is not set
# CONFIG_DEBUG_PAGE_REF is not set
CONFIG_DEBUG_RODATA_TEST=y
# CONFIG_DEBUG_OBJECTS is not set
CONFIG_SLUB_DEBUG_ON=y
# CONFIG_SLUB_STATS is not set
CONFIG_HAVE_DEBUG_KMEMLEAK=y
# CONFIG_DEBUG_KMEMLEAK is not set
# CONFIG_DEBUG_STACK_USAGE is not set
# CONFIG_DEBUG_VM is not set
CONFIG_ARCH_HAS_DEBUG_VIRTUAL=y
CONFIG_DEBUG_VIRTUAL=y
CONFIG_DEBUG_MEMORY_INIT=y
CONFIG_DEBUG_PER_CPU_MAPS=y
CONFIG_HAVE_DEBUG_STACKOVERFLOW=y
# CONFIG_DEBUG_STACKOVERFLOW is not set
CONFIG_HAVE_ARCH_KASAN=y
CONFIG_CC_HAS_KASAN_GENERIC=y
CONFIG_KASAN=y
CONFIG_KASAN_GENERIC=y
CONFIG_KASAN_OUTLINE=y
# CONFIG_KASAN_INLINE is not set
CONFIG_KASAN_STACK=1
CONFIG_TEST_KASAN=m
CONFIG_ARCH_HAS_KCOV=y
CONFIG_CC_HAS_SANCOV_TRACE_PC=y
CONFIG_KCOV=y
# CONFIG_KCOV_INSTRUMENT_ALL is not set
# CONFIG_DEBUG_SHIRQ is not set

#
# Debug Lockups and Hangs
#
CONFIG_LOCKUP_DETECTOR=y
CONFIG_SOFTLOCKUP_DETECTOR=y
CONFIG_BOOTPARAM_SOFTLOCKUP_PANIC=y
CONFIG_BOOTPARAM_SOFTLOCKUP_PANIC_VALUE=1
CONFIG_HARDLOCKUP_DETECTOR_PERF=y
CONFIG_HARDLOCKUP_CHECK_TIMESTAMP=y
CONFIG_HARDLOCKUP_DETECTOR=y
# CONFIG_BOOTPARAM_HARDLOCKUP_PANIC is not set
CONFIG_BOOTPARAM_HARDLOCKUP_PANIC_VALUE=0
# CONFIG_DETECT_HUNG_TASK is not set
CONFIG_WQ_WATCHDOG=y
CONFIG_PANIC_ON_OOPS=y
CONFIG_PANIC_ON_OOPS_VALUE=1
CONFIG_PANIC_TIMEOUT=0
CONFIG_SCHED_DEBUG=y
CONFIG_SCHED_INFO=y
CONFIG_SCHEDSTATS=y
# CONFIG_SCHED_STACK_END_CHECK is not set
CONFIG_DEBUG_TIMEKEEPING=y

#
# Lock Debugging (spinlocks, mutexes, etc...)
#
CONFIG_LOCK_DEBUGGING_SUPPORT=y
CONFIG_PROVE_LOCKING=y
# CONFIG_LOCK_STAT is not set
CONFIG_DEBUG_RT_MUTEXES=y
CONFIG_DEBUG_SPINLOCK=y
CONFIG_DEBUG_MUTEXES=y
CONFIG_DEBUG_WW_MUTEX_SLOWPATH=y
CONFIG_DEBUG_RWSEMS=y
CONFIG_DEBUG_LOCK_ALLOC=y
CONFIG_LOCKDEP=y
# CONFIG_DEBUG_LOCKDEP is not set
CONFIG_DEBUG_ATOMIC_SLEEP=y
CONFIG_DEBUG_LOCKING_API_SELFTESTS=y
CONFIG_LOCK_TORTURE_TEST=m
CONFIG_WW_MUTEX_SELFTEST=y
CONFIG_TRACE_IRQFLAGS=y
CONFIG_STACKTRACE=y
# CONFIG_WARN_ALL_UNSEEDED_RANDOM is not set
# CONFIG_DEBUG_KOBJECT is not set
CONFIG_DEBUG_BUGVERBOSE=y
CONFIG_DEBUG_LIST=y
# CONFIG_DEBUG_PLIST is not set
# CONFIG_DEBUG_SG is not set
CONFIG_DEBUG_NOTIFIERS=y
CONFIG_DEBUG_CREDENTIALS=y

#
# RCU Debugging
#
CONFIG_PROVE_RCU=y
CONFIG_TORTURE_TEST=m
CONFIG_RCU_PERF_TEST=m
CONFIG_RCU_TORTURE_TEST=m
CONFIG_RCU_CPU_STALL_TIMEOUT=21
# CONFIG_RCU_TRACE is not set
# CONFIG_RCU_EQS_DEBUG is not set
# CONFIG_DEBUG_WQ_FORCE_RR_CPU is not set
# CONFIG_DEBUG_BLOCK_EXT_DEVT is not set
CONFIG_CPU_HOTPLUG_STATE_CONTROL=y
# CONFIG_NOTIFIER_ERROR_INJECTION is not set
CONFIG_FAULT_INJECTION=y
# CONFIG_FAILSLAB is not set
CONFIG_FAIL_PAGE_ALLOC=y
# CONFIG_FAIL_MAKE_REQUEST is not set
CONFIG_FAIL_IO_TIMEOUT=y
# CONFIG_FAIL_FUTEX is not set
CONFIG_FAULT_INJECTION_DEBUG_FS=y
CONFIG_FAIL_MMC_REQUEST=y
CONFIG_LATENCYTOP=y
CONFIG_USER_STACKTRACE_SUPPORT=y
CONFIG_NOP_TRACER=y
CONFIG_HAVE_FUNCTION_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_TRACER=y
CONFIG_HAVE_DYNAMIC_FTRACE=y
CONFIG_HAVE_DYNAMIC_FTRACE_WITH_REGS=y
CONFIG_HAVE_FTRACE_MCOUNT_RECORD=y
CONFIG_HAVE_SYSCALL_TRACEPOINTS=y
CONFIG_HAVE_FENTRY=y
CONFIG_HAVE_C_RECORDMCOUNT=y
CONFIG_TRACE_CLOCK=y
CONFIG_RING_BUFFER=y
CONFIG_EVENT_TRACING=y
CONFIG_CONTEXT_SWITCH_TRACER=y
CONFIG_PREEMPTIRQ_TRACEPOINTS=y
CONFIG_TRACING=y
CONFIG_TRACING_SUPPORT=y
# CONFIG_FTRACE is not set
CONFIG_PROVIDE_OHCI1394_DMA_INIT=y
CONFIG_RUNTIME_TESTING_MENU=y
# CONFIG_LKDTM is not set
# CONFIG_TEST_LIST_SORT is not set
# CONFIG_TEST_SORT is not set
# CONFIG_BACKTRACE_SELF_TEST is not set
# CONFIG_RBTREE_TEST is not set
# CONFIG_INTERVAL_TREE_TEST is not set
# CONFIG_PERCPU_TEST is not set
# CONFIG_ATOMIC64_SELFTEST is not set
# CONFIG_TEST_HEXDUMP is not set
# CONFIG_TEST_STRING_HELPERS is not set
# CONFIG_TEST_KSTRTOX is not set
CONFIG_TEST_PRINTF=y
# CONFIG_TEST_BITMAP is not set
# CONFIG_TEST_BITFIELD is not set
# CONFIG_TEST_UUID is not set
# CONFIG_TEST_XARRAY is not set
# CONFIG_TEST_OVERFLOW is not set
# CONFIG_TEST_RHASHTABLE is not set
# CONFIG_TEST_HASH is not set
# CONFIG_TEST_IDA is not set
CONFIG_TEST_LKM=m
# CONFIG_TEST_VMALLOC is not set
# CONFIG_TEST_USER_COPY is not set
# CONFIG_TEST_BPF is not set
# CONFIG_FIND_BIT_BENCHMARK is not set
# CONFIG_TEST_FIRMWARE is not set
CONFIG_TEST_SYSCTL=y
# CONFIG_TEST_UDELAY is not set
# CONFIG_TEST_STATIC_KEYS is not set
# CONFIG_TEST_KMOD is not set
# CONFIG_TEST_DEBUG_VIRTUAL is not set
# CONFIG_TEST_MEMCAT_P is not set
CONFIG_TEST_STACKINIT=y
# CONFIG_MEMTEST is not set
CONFIG_BUG_ON_DATA_CORRUPTION=y
# CONFIG_SAMPLES is not set
CONFIG_HAVE_ARCH_KGDB=y
# CONFIG_KGDB is not set
CONFIG_ARCH_HAS_UBSAN_SANITIZE_ALL=y
CONFIG_UBSAN=y
# CONFIG_UBSAN_SANITIZE_ALL is not set
CONFIG_UBSAN_NO_ALIGNMENT=y
CONFIG_TEST_UBSAN=m
CONFIG_ARCH_HAS_DEVMEM_IS_ALLOWED=y
# CONFIG_DEBUG_AID_FOR_SYZBOT is not set
CONFIG_TRACE_IRQFLAGS_SUPPORT=y
CONFIG_EARLY_PRINTK_USB=y
CONFIG_X86_VERBOSE_BOOTUP=y
CONFIG_EARLY_PRINTK=y
CONFIG_EARLY_PRINTK_DBGP=y
# CONFIG_EARLY_PRINTK_USB_XDBC is not set
CONFIG_X86_PTDUMP_CORE=y
CONFIG_X86_PTDUMP=m
CONFIG_DEBUG_WX=y
CONFIG_DOUBLEFAULT=y
CONFIG_DEBUG_TLBFLUSH=y
CONFIG_IOMMU_DEBUG=y
CONFIG_HAVE_MMIOTRACE_SUPPORT=y
CONFIG_IO_DELAY_TYPE_0X80=0
CONFIG_IO_DELAY_TYPE_0XED=1
CONFIG_IO_DELAY_TYPE_UDELAY=2
CONFIG_IO_DELAY_TYPE_NONE=3
# CONFIG_IO_DELAY_0X80 is not set
# CONFIG_IO_DELAY_0XED is not set
# CONFIG_IO_DELAY_UDELAY is not set
CONFIG_IO_DELAY_NONE=y
CONFIG_DEFAULT_IO_DELAY_TYPE=3
# CONFIG_DEBUG_BOOT_PARAMS is not set
# CONFIG_CPA_DEBUG is not set
CONFIG_OPTIMIZE_INLINING=y
# CONFIG_DEBUG_ENTRY is not set
CONFIG_DEBUG_NMI_SELFTEST=y
CONFIG_X86_DEBUG_FPU=y
CONFIG_PUNIT_ATOM_DEBUG=y
CONFIG_UNWINDER_ORC=y
# CONFIG_UNWINDER_FRAME_POINTER is not set

--=_5ca377a6.ZZqfGciG6/4JVKZEmeGRBorWklLUtD9K5yVHOEQoZUisX0pQ--

