Return-Path: <SRS0=9Pd6=UE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=FROM_LOCAL_HEX,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7BC01C46460
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 18:42:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 39F9820B7C
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 18:42:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 39F9820B7C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CC7306B026A; Wed,  5 Jun 2019 14:42:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C78BF6B026B; Wed,  5 Jun 2019 14:42:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B679A6B026C; Wed,  5 Jun 2019 14:42:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id 970806B026A
	for <linux-mm@kvack.org>; Wed,  5 Jun 2019 14:42:09 -0400 (EDT)
Received: by mail-it1-f197.google.com with SMTP id g142so2541490ita.6
        for <linux-mm@kvack.org>; Wed, 05 Jun 2019 11:42:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :date:message-id:subject:from:to;
        bh=5KA20MEac/BauzP5Z3rFMyap7DfHakSuH0HNa8THrMI=;
        b=QcOiWt99+b1wdKElDE2HIrqf4IoNtxg+N1vZM7oZUUCxJJ2ODIKhaJWitQyrPf69X1
         CmTSHc7P/buPXonT6zLP6wkQ6elpN9fOgep8rKLqxrL5iA+2057AOuZfFx3Mwl/7A6pz
         w/St4LxrzdKsYTeeSYr17v+eg5zL9XxwyCQc+v0z+n/NWKRqxu6z+tOL/Sjlx8QlPk1p
         xb66UgQQJ1Y5P7UgOigDc0NtFJd2p74SHtp5b0DDc/APrwZCIUbCxmEqNNyDx1baJK0A
         OEyuh06O8kbkt3AA8Aq2AR+qRKUtP8NdpxpEbLelasys7+pNRIWNcnT6XWOBfQ6FIclO
         fITg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of 3_wz4xakbaoyaghsittmzixxql.owwotmcamzkwvbmvb.kwu@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3_wz4XAkbAOYaghSITTMZIXXQL.OWWOTMcaMZKWVbMVb.KWU@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Gm-Message-State: APjAAAUFRSjUhOaPbWjsC83sjYr9qxJyv4rHZlwZX3ioMwkQXJ5xuYx9
	esghuuwIs611jqrVcjYOU4yvvO4CsrzHYi2ksWGrCDUjiwzGRY+VAZG+wLgYHO4qDsB8NUZ449T
	6a/lq4LIRP0Cvo6v/VW0HLuD1i4L16r2HG8FEveeKaxIV4Sl7DiTiv0vbeUkSfS4=
X-Received: by 2002:a24:5cce:: with SMTP id q197mr27995418itb.127.1559760129334;
        Wed, 05 Jun 2019 11:42:09 -0700 (PDT)
X-Received: by 2002:a24:5cce:: with SMTP id q197mr27995346itb.127.1559760128186;
        Wed, 05 Jun 2019 11:42:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559760128; cv=none;
        d=google.com; s=arc-20160816;
        b=aAlTF1CHCGbVrYYX9hhJcf276fXEjokYkZFfoAzkhL3N1GPFpnm9ro61sucllTR3mX
         MLqDPCycgt14MzYkcFBBBuUu6cmEKuNoyYZQXtX0azY8pBksyK9iOQS9zU8wDsIdeSqb
         PM3ItpCRYai/yYS35YsHMEqdDiyu2zb+ij5HS4QluGWVDhU0Ph7iKDRAzMqKBaeLHiH5
         JiBup7opuEQ6cLu+XHS3un73OAvlzeY+GDsukyCDh8CMAazfSH5BSf0whv9ZjlxhuTcG
         Qrw+NfGNklhh2QFDptDgQeLImghQ0pOg+6GSWB+oX8rphOHtM4HHU9TmPjIE57rVWkXJ
         WQcA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:from:subject:message-id:date:mime-version;
        bh=5KA20MEac/BauzP5Z3rFMyap7DfHakSuH0HNa8THrMI=;
        b=mGhurNem1OL2bouLUC5ThqjJSxkNEmFwxfPJIkpa/MKdnEC2oWrDOy+JhS3m4qe+nH
         xPeKzPLFn07+/T3YLFqnNZQzvHGqD+hhFC4ADdcht89Avxv7hYKrKc8JXuojhbwRWn9z
         xvuM8y8yHM1IUiVUZebt6oTRj/wVh2yKI2Ldq2yMpZC1EGvncnstwS/CQOWGwEep54TN
         4R4nv53fN9qztpYjOdkDkfl5c1UbU4TTvZ5M4wssSX5KkhwL3MwQn+UdNdLArrvPRcfA
         FzCl0bXXmktJEEcNzOX6v9fljNSPXSqniGiz8lL0uIzIrQ+92Q/UBwMABNfLLmNCzjTH
         GZAQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of 3_wz4xakbaoyaghsittmzixxql.owwotmcamzkwvbmvb.kwu@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3_wz4XAkbAOYaghSITTMZIXXQL.OWWOTMcaMZKWVbMVb.KWU@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
Received: from mail-sor-f69.google.com (mail-sor-f69.google.com. [209.85.220.69])
        by mx.google.com with SMTPS id s2sor4671689ios.38.2019.06.05.11.42.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 05 Jun 2019 11:42:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3_wz4xakbaoyaghsittmzixxql.owwotmcamzkwvbmvb.kwu@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) client-ip=209.85.220.69;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of 3_wz4xakbaoyaghsittmzixxql.owwotmcamzkwvbmvb.kwu@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3_wz4XAkbAOYaghSITTMZIXXQL.OWWOTMcaMZKWVbMVb.KWU@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Google-Smtp-Source: APXvYqyQSToVWrtyBHNgFhFwGOm5JXoKFHnoYyxvEB9G9+8LsxYuPtrQVn8OefRIrXAsQWOuxHoYjg0+w1iLcvYseLENP3looVku
MIME-Version: 1.0
X-Received: by 2002:a5d:958d:: with SMTP id a13mr17604654ioo.288.1559760127802;
 Wed, 05 Jun 2019 11:42:07 -0700 (PDT)
Date: Wed, 05 Jun 2019 11:42:07 -0700
X-Google-Appengine-App-Id: s~syzkaller
X-Google-Appengine-App-Id-Alias: syzkaller
Message-ID: <0000000000005a4b99058a97f42e@google.com>
Subject: KASAN: use-after-free Read in unregister_shrinker
From: syzbot <syzbot+83a43746cebef3508b49@syzkaller.appspotmail.com>
To: akpm@linux-foundation.org, bfields@fieldses.org, bfields@redhat.com, 
	chris@chrisdown.name, daniel.m.jordan@oracle.com, guro@fb.com, 
	hannes@cmpxchg.org, jlayton@kernel.org, ktkhai@virtuozzo.com, 
	laoar.shao@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, 
	linux-nfs@vger.kernel.org, mgorman@techsingularity.net, mhocko@suse.com, 
	sfr@canb.auug.org.au, syzkaller-bugs@googlegroups.com, 
	yang.shi@linux.alibaba.com
Content-Type: text/plain; charset="UTF-8"; format=flowed; delsp=yes
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,

syzbot found the following crash on:

HEAD commit:    b2924447 Add linux-next specific files for 20190605
git tree:       linux-next
console output: https://syzkaller.appspot.com/x/log.txt?x=17e867eea00000
kernel config:  https://syzkaller.appspot.com/x/.config?x=4248d6bc70076f7d
dashboard link: https://syzkaller.appspot.com/bug?extid=83a43746cebef3508b49
compiler:       gcc (GCC) 9.0.0 20181231 (experimental)
syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=1122965aa00000

The bug was bisected to:

commit db17b61765c2c63b9552d316551550557ff0fcfd
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Fri May 17 13:03:38 2019 +0000

     nfsd4: drc containerization

bisection log:  https://syzkaller.appspot.com/x/bisect.txt?x=110cd22ea00000
final crash:    https://syzkaller.appspot.com/x/report.txt?x=130cd22ea00000
console output: https://syzkaller.appspot.com/x/log.txt?x=150cd22ea00000

IMPORTANT: if you fix the bug, please add the following tag to the commit:
Reported-by: syzbot+83a43746cebef3508b49@syzkaller.appspotmail.com
Fixes: db17b61765c2 ("nfsd4: drc containerization")

==================================================================
BUG: KASAN: use-after-free in __list_del_entry_valid+0xe6/0xf5  
lib/list_debug.c:51
Read of size 8 at addr ffff88808a5bd128 by task syz-executor.2/12471

CPU: 0 PID: 12471 Comm: syz-executor.2 Not tainted 5.2.0-rc3-next-20190605  
#9
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
Call Trace:
  __dump_stack lib/dump_stack.c:77 [inline]
  dump_stack+0x172/0x1f0 lib/dump_stack.c:113
  print_address_description.cold+0xd4/0x306 mm/kasan/report.c:351
  __kasan_report.cold+0x1b/0x36 mm/kasan/report.c:482
  kasan_report+0x12/0x20 mm/kasan/common.c:614
  __asan_report_load8_noabort+0x14/0x20 mm/kasan/generic_report.c:132
  __list_del_entry_valid+0xe6/0xf5 lib/list_debug.c:51
  __list_del_entry include/linux/list.h:117 [inline]
  list_del include/linux/list.h:125 [inline]
  unregister_shrinker+0xb2/0x2e0 mm/vmscan.c:443
  nfsd_reply_cache_shutdown+0x26/0x360 fs/nfsd/nfscache.c:194
  nfsd_exit_net+0x170/0x4b0 fs/nfsd/nfsctl.c:1272
  ops_exit_list.isra.0+0xaa/0x150 net/core/net_namespace.c:154
  setup_net+0x400/0x740 net/core/net_namespace.c:333
  copy_net_ns+0x1df/0x340 net/core/net_namespace.c:439
  create_new_namespaces+0x400/0x7b0 kernel/nsproxy.c:107
  unshare_nsproxy_namespaces+0xc2/0x200 kernel/nsproxy.c:206
  ksys_unshare+0x444/0x980 kernel/fork.c:2718
  __do_sys_unshare kernel/fork.c:2786 [inline]
  __se_sys_unshare kernel/fork.c:2784 [inline]
  __x64_sys_unshare+0x31/0x40 kernel/fork.c:2784
  do_syscall_64+0xfd/0x680 arch/x86/entry/common.c:301
  entry_SYSCALL_64_after_hwframe+0x49/0xbe
RIP: 0033:0x459279
Code: fd b7 fb ff c3 66 2e 0f 1f 84 00 00 00 00 00 66 90 48 89 f8 48 89 f7  
48 89 d6 48 89 ca 4d 89 c2 4d 89 c8 4c 8b 4c 24 08 0f 05 <48> 3d 01 f0 ff  
ff 0f 83 cb b7 fb ff c3 66 2e 0f 1f 84 00 00 00 00
RSP: 002b:00007f7ae73e1c78 EFLAGS: 00000246 ORIG_RAX: 0000000000000110
RAX: ffffffffffffffda RBX: 0000000000000001 RCX: 0000000000459279
RDX: 0000000000000000 RSI: 0000000000000000 RDI: 0000000040000000
RBP: 000000000075bfc0 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000246 R12: 00007f7ae73e26d4
R13: 00000000004c84ef R14: 00000000004decb0 R15: 00000000ffffffff

Allocated by task 12460:
  save_stack+0x23/0x90 mm/kasan/common.c:71
  set_track mm/kasan/common.c:79 [inline]
  __kasan_kmalloc mm/kasan/common.c:489 [inline]
  __kasan_kmalloc.constprop.0+0xcf/0xe0 mm/kasan/common.c:462
  kasan_kmalloc+0x9/0x10 mm/kasan/common.c:503
  __do_kmalloc mm/slab.c:3654 [inline]
  __kmalloc+0x15c/0x740 mm/slab.c:3663
  kmalloc include/linux/slab.h:552 [inline]
  kzalloc include/linux/slab.h:742 [inline]
  ops_init+0xff/0x410 net/core/net_namespace.c:120
  setup_net+0x2d3/0x740 net/core/net_namespace.c:316
  copy_net_ns+0x1df/0x340 net/core/net_namespace.c:439
  create_new_namespaces+0x400/0x7b0 kernel/nsproxy.c:107
  unshare_nsproxy_namespaces+0xc2/0x200 kernel/nsproxy.c:206
  ksys_unshare+0x444/0x980 kernel/fork.c:2718
  __do_sys_unshare kernel/fork.c:2786 [inline]
  __se_sys_unshare kernel/fork.c:2784 [inline]
  __x64_sys_unshare+0x31/0x40 kernel/fork.c:2784
  do_syscall_64+0xfd/0x680 arch/x86/entry/common.c:301
  entry_SYSCALL_64_after_hwframe+0x49/0xbe

Freed by task 12460:
  save_stack+0x23/0x90 mm/kasan/common.c:71
  set_track mm/kasan/common.c:79 [inline]
  __kasan_slab_free+0x102/0x150 mm/kasan/common.c:451
  kasan_slab_free+0xe/0x10 mm/kasan/common.c:459
  __cache_free mm/slab.c:3426 [inline]
  kfree+0x106/0x2a0 mm/slab.c:3753
  ops_init+0xd1/0x410 net/core/net_namespace.c:135
  setup_net+0x2d3/0x740 net/core/net_namespace.c:316
  copy_net_ns+0x1df/0x340 net/core/net_namespace.c:439
  create_new_namespaces+0x400/0x7b0 kernel/nsproxy.c:107
  unshare_nsproxy_namespaces+0xc2/0x200 kernel/nsproxy.c:206
  ksys_unshare+0x444/0x980 kernel/fork.c:2718
  __do_sys_unshare kernel/fork.c:2786 [inline]
  __se_sys_unshare kernel/fork.c:2784 [inline]
  __x64_sys_unshare+0x31/0x40 kernel/fork.c:2784
  do_syscall_64+0xfd/0x680 arch/x86/entry/common.c:301
  entry_SYSCALL_64_after_hwframe+0x49/0xbe

The buggy address belongs to the object at ffff88808a5bcdc0
  which belongs to the cache kmalloc-1k of size 1024
The buggy address is located 872 bytes inside of
  1024-byte region [ffff88808a5bcdc0, ffff88808a5bd1c0)
The buggy address belongs to the page:
page:ffffea0002296f00 refcount:1 mapcount:0 mapping:ffff8880aa400ac0  
index:0x0 compound_mapcount: 0
flags: 0x1fffc0000010200(slab|head)
raw: 01fffc0000010200 ffffea000249ea08 ffffea000235a588 ffff8880aa400ac0
raw: 0000000000000000 ffff88808a5bc040 0000000100000007 0000000000000000
page dumped because: kasan: bad access detected

Memory state around the buggy address:
  ffff88808a5bd000: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
  ffff88808a5bd080: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
> ffff88808a5bd100: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
                                   ^
  ffff88808a5bd180: fb fb fb fb fb fb fb fb fc fc fc fc fc fc fc fc
  ffff88808a5bd200: fc fc fc fc fc fc fc fc 00 00 00 00 00 00 00 00
==================================================================


---
This bug is generated by a bot. It may contain errors.
See https://goo.gl/tpsmEJ for more information about syzbot.
syzbot engineers can be reached at syzkaller@googlegroups.com.

syzbot will keep track of this bug report. See:
https://goo.gl/tpsmEJ#status for how to communicate with syzbot.
For information about bisection process see: https://goo.gl/tpsmEJ#bisection
syzbot can test patches for this bug, for details see:
https://goo.gl/tpsmEJ#testing-patches

