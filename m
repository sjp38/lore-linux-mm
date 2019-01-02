Return-Path: <SRS0=6aBQ=PK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 36219C43387
	for <linux-mm@archiver.kernel.org>; Wed,  2 Jan 2019 20:30:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E692321019
	for <linux-mm@archiver.kernel.org>; Wed,  2 Jan 2019 20:30:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E692321019
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6A3BC8E0044; Wed,  2 Jan 2019 15:30:08 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 653418E0002; Wed,  2 Jan 2019 15:30:08 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 51B1A8E0044; Wed,  2 Jan 2019 15:30:08 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 228EB8E0002
	for <linux-mm@kvack.org>; Wed,  2 Jan 2019 15:30:08 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id s70so38387484qks.4
        for <linux-mm@kvack.org>; Wed, 02 Jan 2019 12:30:08 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:message-id:in-reply-to:subject:mime-version
         :content-transfer-encoding:thread-topic:thread-index;
        bh=h/zV+g2bWFCu40Z13tP08ej+d0bHyLKCLQ65v8rvaCI=;
        b=lkv6IfY803dOmgNkNZ19J+SyiXli/5sbVCWTmqwx/SYI3dO1XTvf2Srne/Gp2xN2VE
         hKvywbTTDr055WLEWZyIhTCughiQE5HLVZ6jHyWDTOOYs0IV4g+sZsGel03gJAts5DY/
         pGMKyJ1lABKOxhK0Y0WslPxWSS+jWjACy1dbjbZP491+6PmJHHQU5pexB7p5r09MJLD1
         HFCdFnk49QDn8qlK/KcqyTq2u5YbwKCGreY2LqwIyIiuJkoY/8a+bbsRcMCEboI4cUTI
         zgxokiR5k0QJbBEw/VKMTLj4iqPkXv/IWrCD2KXgJG0oXznQf2Q185nRu/IUO/5SSV/3
         6V/g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jstancek@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jstancek@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AJcUukeevffqcIB2Z/3KJ83dDScdzy3+KzmZ6nqajKohLCLkFiYh4d+7
	qRoPKAJgRyoMJi2fs5Gj7JYyM+Eoji0et0+zs7wxpqViK03kkfWTMWfqVQsFjN+1jm2CB3mLjPC
	+Aj1tRdmtQ+8QQ4hCRDQySobBiAAqCOZE8dAvrPSSmmfcHjtqN7x+FnotAKa8rfm/NA==
X-Received: by 2002:aed:3e22:: with SMTP id l31mr44246889qtf.342.1546461007776;
        Wed, 02 Jan 2019 12:30:07 -0800 (PST)
X-Google-Smtp-Source: AFSGD/VcRiVy8GUh/8sWH/u60J6ZDTV3Rc9m/w39dxGyTuEHKi+Jg919R/aI8+E/EQ0VPbkL67U3
X-Received: by 2002:aed:3e22:: with SMTP id l31mr44246853qtf.342.1546461006966;
        Wed, 02 Jan 2019 12:30:06 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546461006; cv=none;
        d=google.com; s=arc-20160816;
        b=JXo+dCCiecqf4RAZzeze0sWPNaUJ2T1Exh7jowIX8YZ+tu0j/WfA2ClJ1mZDJfAzmW
         WFQYnLgN8ciugztwYTKvVE6r4H+SG4yzSyXmGnYuyiUTtkc0n39aWcSEQ9yo8Hwm4/Vc
         2Hs3PKudQpvHQnNcZXUJABE+n3vPBXf39HuU0D4VMihLj0OAt7++H5dKl2YLgQSePWMP
         9z0uR2T76TyHEFFC6nks7M3y5ACQriqYHZq7sWfoSdsUKRKPa5QNYTuGm08CfUg6U/G8
         xvoqV/QlBq/OCh5pjiukvkkRdp2oW3rt4YHq9WIoWKyXEvfpy+96MzrubD8uU/2GftGy
         6i/w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=thread-index:thread-topic:content-transfer-encoding:mime-version
         :subject:in-reply-to:message-id:cc:to:from:date;
        bh=h/zV+g2bWFCu40Z13tP08ej+d0bHyLKCLQ65v8rvaCI=;
        b=wtNpsKhuKgljR2KCNkElQA5+R0SO1ByLgMJstkUXpB91KXgBDngob2haUZQCI4/0I+
         Pvjnu91MitCBhCqUB3b0y6J8kSIGTx6y49zzEq7fvtATAz3Fza80RVxwfEW+dJy/D538
         9E6qeBJRg7CLiKLUuZ18HhGe4o0ybqCvboXV5mYKklvWejrmYDOygBgUGFKXgPRE2kO9
         oLG4/OimqvunLAWa+wV0huzNuCgZX0m5XwHNQqbo6K+n41V6OHIIkpbyQA2x68p6J5bg
         s0XUWypL1oGvhAPzbLqcUg9xfR/w8DM24igA2cAZLpANfl82nEKcJyI3EqFh/8DJZYU2
         igIg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jstancek@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jstancek@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y5si2056113qvk.5.2019.01.02.12.30.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Jan 2019 12:30:06 -0800 (PST)
Received-SPF: pass (google.com: domain of jstancek@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jstancek@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jstancek@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id A4A49C0C0564;
	Wed,  2 Jan 2019 20:30:05 +0000 (UTC)
Received: from colo-mx.corp.redhat.com (colo-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.21])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 5B26A608DA;
	Wed,  2 Jan 2019 20:30:05 +0000 (UTC)
Received: from zmail17.collab.prod.int.phx2.redhat.com (zmail17.collab.prod.int.phx2.redhat.com [10.5.83.19])
	by colo-mx.corp.redhat.com (Postfix) with ESMTP id F28C13F953;
	Wed,  2 Jan 2019 20:30:04 +0000 (UTC)
Date: Wed, 2 Jan 2019 15:30:04 -0500 (EST)
From: Jan Stancek <jstancek@redhat.com>
To: linux-mm@kvack.org, mike.kravetz@oracle.com, kirill.shutemov@linux.intel.com
Cc: "ltp@lists.linux.it" <ltp@lists.linux.it>, mhocko@kernel.org, 
	Rachel Sibley <rasibley@redhat.com>, hughd@google.com, 
	n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, 
	aneesh.kumar@linux.vnet.ibm.com, dave@stgolabs.net, 
	prakash.sangappa@oracle.com, colin.king@canonical.com
Message-ID: <1323128903.93005102.1546461004635.JavaMail.zimbra@redhat.com>
In-Reply-To: <1038135449.92986364.1546459244292.JavaMail.zimbra@redhat.com>
Subject: [bug] problems with migration of huge pages with
 v4.20-10214-ge1ef035d272e
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.43.17.9, 10.4.195.23]
Thread-Topic: problems with migration of huge pages with v4.20-10214-ge1ef035d272e
Thread-Index: XOLQ6M1mcFoW4k42yg3uKTqPWWqldw==
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.32]); Wed, 02 Jan 2019 20:30:06 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190102203004.p-xUnP2TgQD8KtXCi_ZjtgVMPpxVvDrXAbuOrennyVY@z>

Hi,

LTP move_pages12 [1] started failing recently.

The test maps/unmaps some anonymous private huge pages
and migrates them between 2 nodes. This now reliably
hits NULL ptr deref:

[  194.819357] BUG: unable to handle kernel NULL pointer dereference at 0000000000000030
[  194.864410] #PF error: [WRITE]
[  194.881502] PGD 22c758067 P4D 22c758067 PUD 235177067 PMD 0
[  194.913833] Oops: 0002 [#1] SMP NOPTI
[  194.935062] CPU: 0 PID: 865 Comm: move_pages12 Not tainted 4.20.0+ #1
[  194.972993] Hardware name: HP ProLiant SL335s G7/, BIOS A24 12/08/2012
[  195.005359] RIP: 0010:down_write+0x1b/0x40
[  195.028257] Code: 00 5c 01 00 48 83 c8 03 48 89 43 20 5b c3 90 0f 1f 44 00 00 53 48 89 fb e8 d2 d7 ff ff 48 89 d8 48 ba 01 00 00 00 ff ff
ff ff <f0> 48 0f c1 10 85 d2 74 05 e8 07 26 ff ff 65 48 8b 04 25 00 5c 01
[  195.121836] RSP: 0018:ffffb87e4224fd00 EFLAGS: 00010246
[  195.147097] RAX: 0000000000000030 RBX: 0000000000000030 RCX: 0000000000000000
[  195.185096] RDX: ffffffff00000001 RSI: ffffffffa69d30f0 RDI: 0000000000000030
[  195.219251] RBP: 0000000000000030 R08: ffffe7d4889d8008 R09: 0000000000000003
[  195.258291] R10: 000000000000000f R11: ffffe7d4889d8008 R12: ffffe7d4889d0008
[  195.294547] R13: ffffe7d490b78000 R14: ffffe7d4889d0000 R15: ffff8be9b2ba4580
[  195.332532] FS:  00007f1670112b80(0000) GS:ffff8be9b7a00000(0000) knlGS:0000000000000000
[  195.373888] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  195.405938] CR2: 0000000000000030 CR3: 000000023477e000 CR4: 00000000000006f0
[  195.443579] Call Trace:
[  195.456876]  migrate_pages+0x833/0xcb0
[  195.478070]  ? __ia32_compat_sys_migrate_pages+0x20/0x20
[  195.506027]  do_move_pages_to_node.isra.63.part.64+0x2a/0x50
[  195.536963]  kernel_move_pages+0x667/0x8c0
[  195.559616]  ? __handle_mm_fault+0xb95/0x1370
[  195.588765]  __x64_sys_move_pages+0x24/0x30
[  195.611439]  do_syscall_64+0x5b/0x160
[  195.631901]  entry_SYSCALL_64_after_hwframe+0x44/0xa9
[  195.657790] RIP: 0033:0x7f166f5ff959
[  195.676365] Code: 00 c3 66 2e 0f 1f 84 00 00 00 00 00 0f 1f 44 00 00 48 89 f8 48 89 f7 48 89 d6 48 89 ca 4d 89 c2 4d 89 c8 4c 8b 4c 24 08
0f 05 <48> 3d 01 f0 ff ff 73 01 c3 48 8b 0d 17 45 2c 00 f7 d8 64 89 01 48
[  195.772938] RSP: 002b:00007ffd8d77bb48 EFLAGS: 00000246 ORIG_RAX: 0000000000000117
[  195.810207] RAX: ffffffffffffffda RBX: 0000000000000400 RCX: 00007f166f5ff959
[  195.847522] RDX: 0000000002303400 RSI: 0000000000000400 RDI: 0000000000000360
[  195.882327] RBP: 0000000000000400 R08: 0000000002306420 R09: 0000000000000004
[  195.920017] R10: 0000000002305410 R11: 0000000000000246 R12: 0000000002303400
[  195.958053] R13: 0000000002305410 R14: 0000000002306420 R15: 0000000000000003
[  195.997028] Modules linked in: sunrpc amd64_edac_mod ipmi_ssif edac_mce_amd kvm_amd ipmi_si igb ipmi_devintf k10temp kvm pcspkr ipmi_msgha
ndler joydev irqbypass sp5100_tco dca hpwdt hpilo i2c_piix4 xfs libcrc32c radeon i2c_algo_bit drm_kms_helper ttm ata_generic pata_acpi drm se
rio_raw pata_atiixp
[  196.134162] CR2: 0000000000000030
[  196.152788] ---[ end trace 4420ea5061342d3e ]---

Suspected commit is:
  b43a99900559 ("hugetlbfs: use i_mmap_rwsem for more pmd sharing synchronization")
which adds to unmap_and_move_huge_page():
+               struct address_space *mapping = page_mapping(hpage);
+
+               /*
+                * try_to_unmap could potentially call huge_pmd_unshare.
+                * Because of this, take semaphore in write mode here and
+                * set TTU_RMAP_LOCKED to let lower levels know we have
+                * taken the lock.
+                */
+               i_mmap_lock_write(mapping);

If I'm reading this right, 'mapping' will be NULL for anon mappings.

Running same test with s/MAP_PRIVATE/MAP_SHARED/ leads to user-space
hanging at:

# cat /proc/23654/stack
[<0>] io_schedule+0x12/0x40
[<0>] __lock_page+0x13c/0x200
[<0>] remove_inode_hugepages+0x275/0x300
[<0>] hugetlbfs_evict_inode+0x2e/0x60
[<0>] evict+0xcb/0x190
[<0>] __dentry_kill+0xce/0x160
[<0>] dentry_kill+0x47/0x170
[<0>] dput.part.33+0xc6/0x100
[<0>] __fput+0x105/0x230
[<0>] task_work_run+0x84/0xa0
[<0>] exit_to_usermode_loop+0xd3/0xe0
[<0>] do_syscall_64+0x14d/0x160
[<0>] entry_SYSCALL_64_after_hwframe+0x44/0xa9
[<0>] 0xffffffffffffffff

# cat /proc/23655/stack
[<0>] call_rwsem_down_read_failed+0x14/0x30
[<0>] rmap_walk_file+0x1c1/0x2f0
[<0>] remove_migration_ptes+0x6d/0x80
[<0>] migrate_pages+0x86a/0xcb0
[<0>] do_move_pages_to_node.isra.63.part.64+0x2a/0x50
[<0>] kernel_move_pages+0x667/0x8c0
[<0>] __x64_sys_move_pages+0x24/0x30
[<0>] do_syscall_64+0x5b/0x160
[<0>] entry_SYSCALL_64_after_hwframe+0x44/0xa9
[<0>] 0xffffffffffffffff

Regards,
Jan

[1] https://github.com/linux-test-project/ltp/blob/master/testcases/kernel/syscalls/move_pages/move_pages12.c

