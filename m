Return-Path: <SRS0=02Vf=PI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=FROM_LOCAL_HEX,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A8D02C43387
	for <linux-mm@archiver.kernel.org>; Mon, 31 Dec 2018 07:23:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5E7CB21019
	for <linux-mm@archiver.kernel.org>; Mon, 31 Dec 2018 07:23:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5E7CB21019
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0E8648E007F; Mon, 31 Dec 2018 02:23:05 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 071EC8E005B; Mon, 31 Dec 2018 02:23:05 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EA2B78E007F; Mon, 31 Dec 2018 02:23:04 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id BFD3F8E005B
	for <linux-mm@kvack.org>; Mon, 31 Dec 2018 02:23:04 -0500 (EST)
Received: by mail-it1-f198.google.com with SMTP id k133so31294269ite.4
        for <linux-mm@kvack.org>; Sun, 30 Dec 2018 23:23:04 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :date:message-id:subject:from:to;
        bh=L6mp+WKNRhAQX8dYCw36L9QxSIEkYA82nJ8yheZJJ7w=;
        b=MpctY36i8vwK4bn7/SaeYJOeXkJ4YWNbwMj+dsYMSAkCj7FjU9MuwzcyG1eJbQT96T
         vd0t6esXAzUVHUW4WxkbwIEkQKl+UQ3a2M72IczgPS0Ynv4SFD7hj5RI7Cj7ac/z/mTI
         BSGYFA/PwIMbUSxpWjG+2gXVIrATWg0n92HmTZ50yWJCnXE76ZUKIy6SMzkW6RIXmOSJ
         jEgletf1ijAXqDggHPY7Nozo64mXYl2hOdxv5dYLVnBtdUIU8eTZp0ugAMj0gOQZYugJ
         79obDIu2sXLybr4SjR95p+sBQ49Sn+SQ+mgZVJMFRlAmS6/T/6OX45rWNONdwBHo5r8F
         ha2Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of 318mpxakbaowgmnyozzsfoddwr.uccuzsigsfqcbhsbh.qca@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=318MpXAkbAOwgmnYOZZSfOddWR.UccUZSigSfQcbhSbh.Qca@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Gm-Message-State: AA+aEWbJyK1ltKJeMUYbrIpwQ/jzBAMikJheJs0xL1r+rbRGVHo8o0gm
	Wzd+VLX9GJ4W968aw2lhkHnrhkZLduxrf1EtoRmaXWSDjbNhxpMKryVsLGnQtr8+Ep3WnJgT07S
	0rkbAnyuUxlCfs0cE6QeaTySQtZK93dbSgAmn5mYmKKKI5aDN2hbdTGad630qg85OlBWAIfylFX
	sMnkyVbEPb2UwhnhNCaoZ7Kodd7Rx1EpyDRQoSk/KuN1Xm7CZUkOlHhjQR88iww31Fdz5UoS+eR
	VfvtBgSlYD/oH8gzWxxWruw+7fbosjwQZrrP6FjzV4OsYZQHhbRFgQoG9mueEzKNw7p/LAbXr3u
	rtT4bZUrapd6V4lIs/3m85u6Se9z2rMaMzf0duUwUV4SymAeApqeWtbp5suD+pKELPP506QJ7g=
	=
X-Received: by 2002:a02:88cf:: with SMTP id b15mr24696787jak.10.1546240984467;
        Sun, 30 Dec 2018 23:23:04 -0800 (PST)
X-Received: by 2002:a02:88cf:: with SMTP id b15mr24696771jak.10.1546240983577;
        Sun, 30 Dec 2018 23:23:03 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546240983; cv=none;
        d=google.com; s=arc-20160816;
        b=wQlZrmDuLdWL2ivY3pno8YM0gphWaVHIIDyLxc+meQeWAJ4ZpEOH2QNc1HHfdi6jdY
         HWAw+Fo/PfdXJeuaM/gC1weyFqqmJAmNqKRqmRpxD57DtbVvpEEqkE6foMaTFEjQB2iK
         W2uPwKycV9Sd5Ys4YANrnXPU7iX5pRUH524dth4+Sho28FeNUAOyRxUgkYAMWVsz48LX
         0Y4rvzZOeKnPEJH+iT/JogIHDKtuZpwvTsudVCoUzhqug6B2hQclJ4dV0gYO8i3C71xg
         F0t8JxH7skNgCN8o6zk9C1OUcaXE5OtTiYHI+IpZd7kGyn7ILvy4HuVjeouURNZyOw7U
         DTtw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:from:subject:message-id:date:mime-version;
        bh=L6mp+WKNRhAQX8dYCw36L9QxSIEkYA82nJ8yheZJJ7w=;
        b=SJ6sgQfVaAt/rANg3xKuyTi0uriftZyv6/UXViI6Tn4i9nBMXTmVuS8xu49TazJPef
         MN/+PoZ4Wxiy3/m6KJd6/WrJAcbBvfg+qN2EfdRDCNvjSCQg6y+4ZjdhEpfX309G2GC1
         GT+xl3BQwPSURiZKm29URYMi6GL8OmRsSOhFfzpKqUD/62Vaor/IbqtvFNW5zBmB7xMY
         dLip6x8eagFY+hlRqA0tS/h+9yZZECBqtjnsS4fAwLCCB/+nTB09OF6QIkCiwfvdc2yE
         Ei8wT2mpGRh1ajLeK7hH3tpSGPSrQHNW2F7R4rUL04It8ryxU3xmHOmXR7wAh5Xu+QH0
         OKVw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of 318mpxakbaowgmnyozzsfoddwr.uccuzsigsfqcbhsbh.qca@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=318MpXAkbAOwgmnYOZZSfOddWR.UccUZSigSfQcbhSbh.Qca@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
Received: from mail-sor-f69.google.com (mail-sor-f69.google.com. [209.85.220.69])
        by mx.google.com with SMTPS id e14sor11235605ioh.3.2018.12.30.23.23.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 30 Dec 2018 23:23:03 -0800 (PST)
Received-SPF: pass (google.com: domain of 318mpxakbaowgmnyozzsfoddwr.uccuzsigsfqcbhsbh.qca@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) client-ip=209.85.220.69;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of 318mpxakbaowgmnyozzsfoddwr.uccuzsigsfqcbhsbh.qca@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=318MpXAkbAOwgmnYOZZSfOddWR.UccUZSigSfQcbhSbh.Qca@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Google-Smtp-Source: ALg8bN6pmQIyJBpa5H5cg/snSRE4oDO2IHo0R3/TSUsFH/kRsClqtD6Fs2CySE92p/7VphCiC0rsaEOmuXt/jnYEh2mQTzTN5YjA
MIME-Version: 1.0
X-Received: by 2002:a6b:794b:: with SMTP id j11mr13843727iop.0.1546240983283;
 Sun, 30 Dec 2018 23:23:03 -0800 (PST)
Date: Sun, 30 Dec 2018 23:23:03 -0800
X-Google-Appengine-App-Id: s~syzkaller
X-Google-Appengine-App-Id-Alias: syzkaller
Message-ID: <0000000000008bc346057e4c4873@google.com>
Subject: BUG: unable to handle kernel NULL pointer dereference in
 kmem_cache_free (2)
From: syzbot <syzbot+463e2f5d13fc785dd322@syzkaller.appspotmail.com>
To: akpm@linux-foundation.org, borntraeger@de.ibm.com, 
	colin.king@canonical.com, jglisse@redhat.com, khalid.aziz@oracle.com, 
	kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, 
	linux-mm@kvack.org, mawilcox@microsoft.com, mgorman@techsingularity.net, 
	mike.kravetz@oracle.com, n-horiguchi@ah.jp.nec.com, rppt@linux.vnet.ibm.com, 
	syzkaller-bugs@googlegroups.com
Content-Type: text/plain; charset="UTF-8"; delsp="yes"; format="flowed"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20181231072303.VbC191Gu6lpA2tiTyOTMkUSCDiB63iknp3OmsZfx_JQ@z>

Hello,

syzbot found the following crash on:

HEAD commit:    345671ea0f92 Merge branch 'akpm' (patches from Andrew)
git tree:       upstream
console output: https://syzkaller.appspot.com/x/log.txt?x=10442713400000
kernel config:  https://syzkaller.appspot.com/x/.config?x=5c0a49d2b5210087
dashboard link: https://syzkaller.appspot.com/bug?extid=463e2f5d13fc785dd322
compiler:       gcc (GCC) 8.0.1 20180413 (experimental)

Unfortunately, I don't have any reproducer for this crash yet.

IMPORTANT: if you fix the bug, please add the following tag to the commit:
Reported-by: syzbot+463e2f5d13fc785dd322@syzkaller.appspotmail.com

FAT-fs (loop1): Directory bread(block 72) failed
EXT4-fs (loop3): Can't read superblock on 2nd try
FAT-fs (loop1): Directory bread(block 73) failed
audit: type=1400 audit(1540684862.923:177): avc:  denied  { mmap_zero }  
for  pid=17455 comm="udevd" scontext=system_u:system_r:kernel_t:s0  
tcontext=system_u:system_r:kernel_t:s0 tclass=memprotect permissive=1
BUG: unable to handle kernel NULL pointer dereference at 0000000000000080
PGD 0 P4D 0
Oops: 0000 [#1] PREEMPT SMP KASAN
CPU: 1 PID: 17455 Comm: udevd Not tainted 4.19.0+ #85
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
RIP: 0010:slab_equal_or_root mm/slab.h:228 [inline]
RIP: 0010:cache_from_obj mm/slab.h:374 [inline]
RIP: 0010:kmem_cache_free+0x120/0x290 mm/slab.c:3752
Code: ea ff ff 48 c1 e8 0c 48 c1 e0 06 48 01 d0 48 8b 50 08 48 8d 4a ff 83  
e2 01 48 0f 45 c1 48 8b 40 18 48 39 c3 0f 84 00 ff ff ff <48> 3b 98 80 00  
00 00 0f 84 11 01 00 00 48 8b 48 58 48 c7 c6 20 0c
RSP: 0018:ffff88018eb271d8 EFLAGS: 00010282
RAX: 0000000000000000 RBX: ffff8801da979480 RCX: ffffea0007658e87
RDX: 0000000000000000 RSI: ffffffff8139ec96 RDI: 0000000000000007
RBP: ffff88018eb271f8 R08: ffff88018e3f03c0 R09: ffffed003914bb50
R10: ffffed003914bb50 R11: ffff8801c8a5da83 R12: ffff8801d963ab10
R13: ffff8801b37755a0 R14: ffff8801b37755a0 R15: ffff8801b3775590
FS:  0000000000000000(0000) GS:ffff8801daf00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000000000080 CR3: 00000001c0bd1000 CR4: 00000000001426e0
Call Trace:
  anon_vma_chain_free mm/rmap.c:134 [inline]
  unlink_anon_vmas+0x5f0/0xa60 mm/rmap.c:419
  free_pgtables+0x271/0x380 mm/memory.c:393
  exit_mmap+0x2cd/0x590 mm/mmap.c:3146
  __mmput kernel/fork.c:1044 [inline]
  mmput+0x247/0x610 kernel/fork.c:1065
  exec_mmap fs/exec.c:1043 [inline]
  flush_old_exec+0xb91/0x21b0 fs/exec.c:1276
  load_elf_binary+0xa39/0x5620 fs/binfmt_elf.c:869
  search_binary_handler+0x17d/0x570 fs/exec.c:1653
  exec_binprm fs/exec.c:1695 [inline]
  __do_execve_file.isra.33+0x1661/0x25d0 fs/exec.c:1819
  do_execveat_common fs/exec.c:1866 [inline]
  do_execve fs/exec.c:1883 [inline]
  __do_sys_execve fs/exec.c:1964 [inline]
  __se_sys_execve fs/exec.c:1959 [inline]
  __x64_sys_execve+0x8f/0xc0 fs/exec.c:1959
  do_syscall_64+0x1b9/0x820 arch/x86/entry/common.c:290
  entry_SYSCALL_64_after_hwframe+0x49/0xbe
RIP: 0033:0x7ffa0b953207
Code: Bad RIP value.
RSP: 002b:00007ffefdbbcde8 EFLAGS: 00000206 ORIG_RAX: 000000000000003b
RAX: ffffffffffffffda RBX: 00000000ffffffff RCX: 00007ffa0b953207
RDX: 0000000000e42b70 RSI: 00007ffefdbbcee0 RDI: 00007ffefdbbdef0
RBP: 0000000000625500 R08: 000000000000405a R09: 000000000000405a
R10: 0000000000000000 R11: 0000000000000206 R12: 0000000000e42b70
R13: 0000000000000007 R14: 0000000000d40030 R15: 0000000000000005
Modules linked in:
CR2: 0000000000000080
kobject: 'loop5' (00000000598b220f): kobject_uevent_env
---[ end trace fc838222524811c3 ]---
RIP: 0010:slab_equal_or_root mm/slab.h:228 [inline]
RIP: 0010:cache_from_obj mm/slab.h:374 [inline]
RIP: 0010:kmem_cache_free+0x120/0x290 mm/slab.c:3752
kobject: 'loop5' (00000000598b220f): fill_kobj_path: path  
= '/devices/virtual/block/loop5'
Code: ea ff ff 48 c1 e8 0c 48 c1 e0 06 48 01 d0 48 8b 50 08 48 8d 4a ff 83  
e2 01 48 0f 45 c1 48 8b 40 18 48 39 c3 0f 84 00 ff ff ff <48> 3b 98 80 00  
00 00 0f 84 11 01 00 00 48 8b 48 58 48 c7 c6 20 0c
RSP: 0018:ffff88018eb271d8 EFLAGS: 00010282
RAX: 0000000000000000 RBX: ffff8801da979480 RCX: ffffea0007658e87
kobject: 'loop1' (00000000606593e3): kobject_uevent_env
kobject: 'loop2' (00000000a62421b8): kobject_uevent_env
kobject: 'loop1' (00000000606593e3): fill_kobj_path: path  
= '/devices/virtual/block/loop1'
kobject: 'loop2' (00000000a62421b8): fill_kobj_path: path  
= '/devices/virtual/block/loop2'
RDX: 0000000000000000 RSI: ffffffff8139ec96 RDI: 0000000000000007
RBP: ffff88018eb271f8 R08: ffff88018e3f03c0 R09: ffffed003914bb50
R10: ffffed003914bb50 R11: ffff8801c8a5da83 R12: ffff8801d963ab10
R13: ffff8801b37755a0 R14: ffff8801b37755a0 R15: ffff8801b3775590
kasan: CONFIG_KASAN_INLINE enabled
kobject: 'loop5' (00000000598b220f): kobject_uevent_env
FS:  00007ffa0c26f7a0(0000) GS:ffff8801daf00000(0000) knlGS:0000000000000000
kasan: GPF could be caused by NULL-ptr deref or user memory access
kobject: 'loop5' (00000000598b220f): fill_kobj_path: path  
= '/devices/virtual/block/loop5'
kobject: 'loop2' (00000000a62421b8): kobject_uevent_env
general protection fault: 0000 [#2] PREEMPT SMP KASAN
CPU: 1 PID: 16046 Comm: udevd Tainted: G      D           4.19.0+ #85
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
RIP: 0010:__anon_vma_interval_tree_insert mm/interval_tree.c:72 [inline]
RIP: 0010:anon_vma_interval_tree_insert+0x179/0x370 mm/interval_tree.c:83
Code: 03 42 80 3c 3a 00 0f 85 7d 01 00 00 4d 8b 65 00 4d 85 e4 0f 84 a5 00  
00 00 e8 b3 fc cf ff 49 8d 7c 24 18 48 89 f8 48 c1 e8 03 <42> 80 3c 38 00  
0f 85 75 01 00 00 4d 8b 6c 24 18 4c 89 f7 4c 89 ee
RSP: 0018:ffff8801c3396c90 EFLAGS: 00010206
RAX: 000000000836b159 RBX: ffff8801d8a8eee0 RCX: ffffffff81af3d90
RDX: 0000000000000000 RSI: ffffffff81af3d0d RDI: 0000000041b58acb
RBP: ffff8801c3396cd8 R08: ffff880183b76340 R09: 0000000000000000
R10: 00000000224b4293 R11: ffff880183b76340 R12: 0000000041b58ab3
R13: ffff8801d963dfc0 R14: 000000000000001f R15: dffffc0000000000
FS:  00007ffa0c26f7a0(0000) GS:ffff8801daf00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000000930004 CR3: 000000018800a000 CR4: 00000000001426e0
Call Trace:
  anon_vma_chain_link mm/rmap.c:144 [inline]
  anon_vma_clone+0x2f5/0x710 mm/rmap.c:279
  anon_vma_fork+0xf4/0x820 mm/rmap.c:332
  dup_mmap kernel/fork.c:539 [inline]
  dup_mm kernel/fork.c:1317 [inline]
  copy_mm kernel/fork.c:1372 [inline]
  copy_process+0x47cc/0x8770 kernel/fork.c:1916
  _do_fork+0x1cb/0x11d0 kernel/fork.c:2213
  __do_sys_clone kernel/fork.c:2320 [inline]
  __se_sys_clone kernel/fork.c:2314 [inline]
  __x64_sys_clone+0xbf/0x150 kernel/fork.c:2314
  do_syscall_64+0x1b9/0x820 arch/x86/entry/common.c:290
  entry_SYSCALL_64_after_hwframe+0x49/0xbe
RIP: 0033:0x7ffa0b952f46
Code: f7 d8 64 89 04 25 d4 02 00 00 64 4c 8b 14 25 10 00 00 00 31 d2 49 81  
c2 d0 02 00 00 31 f6 bf 11 00 20 01 b8 38 00 00 00 0f 05 <48> 3d 00 f0 ff  
ff 0f 87 31 01 00 00 85 c0 41 89 c4 0f 85 3b 01 00
RSP: 002b:00007ffefdbbcd80 EFLAGS: 00000246 ORIG_RAX: 0000000000000038
RAX: ffffffffffffffda RBX: 00007ffefdbbcd80 RCX: 00007ffa0b952f46
RDX: 0000000000000000 RSI: 0000000000000000 RDI: 0000000001200011
RBP: 00007ffefdbbcde0 R08: 0000000000003eae R09: 0000000000003eae
R10: 00007ffa0c26fa70 R11: 0000000000000246 R12: 0000000000000000
R13: 00007ffefdbbcda0 R14: 0000000000000005 R15: 0000000000000005
Modules linked in:
kobject: 'loop1' (00000000606593e3): kobject_uevent_env
kobject: 'loop2' (00000000a62421b8): fill_kobj_path: path  
= '/devices/virtual/block/loop2'
kobject: 'loop1' (00000000606593e3): fill_kobj_path: path  
= '/devices/virtual/block/loop1'
EXT4-fs (loop5): Can't read superblock on 2nd try
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
kobject: 'loop4' (000000001ebc1bae): kobject_uevent_env
kobject: 'loop4' (000000001ebc1bae): fill_kobj_path: path  
= '/devices/virtual/block/loop4'
CR2: 00000000004ede98 CR3: 00000001c0bd1000 CR4: 00000000001426e0
FAT-fs (loop1): Directory bread(block 64) failed
kobject: 'loop5' (00000000598b220f): kobject_uevent_env
DR0: 0000000020000000 DR1: 0000000000000000 DR2: 0000000000000000
EXT4-fs (loop2): Invalid log block size: 2949122
kobject: 'loop5' (00000000598b220f): kobject_uevent_env
FAT-fs (loop1): Directory bread(block 65) failed
kobject: 'loop5' (00000000598b220f): fill_kobj_path: path  
= '/devices/virtual/block/loop5'
kobject: 'loop5' (00000000598b220f): fill_kobj_path: path  
= '/devices/virtual/block/loop5'
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000600
FAT-fs (loop1): Directory bread(block 66) failed
kobject: 'loop2' (00000000a62421b8): kobject_uevent_env


---
This bug is generated by a bot. It may contain errors.
See https://goo.gl/tpsmEJ for more information about syzbot.
syzbot engineers can be reached at syzkaller@googlegroups.com.

syzbot will keep track of this bug report. See:
https://goo.gl/tpsmEJ#bug-status-tracking for how to communicate with  
syzbot.

