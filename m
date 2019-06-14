Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EDCD4C46477
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 20:20:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9755821841
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 20:20:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="kJwjrBly"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9755821841
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E30FD6B0006; Fri, 14 Jun 2019 16:20:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DE27F6B0007; Fri, 14 Jun 2019 16:20:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CA9EC6B0008; Fri, 14 Jun 2019 16:20:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id AC5B36B0006
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 16:20:31 -0400 (EDT)
Received: by mail-yb1-f198.google.com with SMTP id z6so2884268ybm.19
        for <linux-mm@kvack.org>; Fri, 14 Jun 2019 13:20:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding:dkim-signature;
        bh=TyMsiSXJXvB4f8OYfcJYvENBphf76n8t9aZCHzDZ8O8=;
        b=saMgQsylAPUz2ewzufoM49Ibe3SddRY3mvH8/tXr00HjzJD2tRm5fzjxx2C4WA9m0+
         ealkZyitbDOcBfuRyy9NBqvKSQBLyzTDylr5fXrKxsvKL1gTKqujWwnJwHSOJdPKwssB
         SPxyVDsbgot+dMKNtXL4I6BgGNrbiGlKY7KbNPN+dYElQVc8v4P7HESwVKQVzUieBAAV
         mFt9UN0j0gaKQewlQzP3Y47AncqsBMpDXdzXxfXI6RIUXYYhhhRwLXvZv7tx1mNl3l37
         HcNGZfqA79roCLYyvBYQsf6eeDeIakjpJrPo3aN89cZ0o42eRMhdFD8pS9LwlUGMB2Xe
         NCIA==
X-Gm-Message-State: APjAAAWLV5dJRb3likPOtMASw/lKSUcaDGOnzkappJJZKgTkA6aPo4Og
	Il82b+s0eM8bDEftuYxjiel1xu0rYRJTIxgLEdqAizl/8dAAtALU6P+DhGExdavFXQto/Ft2m/E
	GCO4D/DYBKMiF5E1TuXxgl3f/ULwDrd6NrTcl404OFS/XevU7BsGo1NiR1uGozrXJNA==
X-Received: by 2002:a81:3256:: with SMTP id y83mr33752960ywy.325.1560543631172;
        Fri, 14 Jun 2019 13:20:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwktB0TZedDJxIrBQodvxgMabv1zOU1qPsCcoNkuDiRypJqndiEmU/feXAOtNta3bpF7oFp
X-Received: by 2002:a81:3256:: with SMTP id y83mr33752901ywy.325.1560543629920;
        Fri, 14 Jun 2019 13:20:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560543629; cv=none;
        d=google.com; s=arc-20160816;
        b=K1tGRozmYPu39UkOwSiR6kdWyaaoPOONCDlG2d3OVvmKs8p5vGONUuQZQOmLmfXTmJ
         6o7WoC8j751/Ij7xIf9/YSbQJDzZaSxeqzEx2kgYrNtU7GgMCCrdu7F547g12d3ohwiL
         aUtpD4ZyTwiVqeBbg4vMsuCVEumXIHN+++lLXmUMGNz/wHMk6c0lQGEMak6rkGOMCK4D
         MlGnIMUQHNNbLKBb5QKngp/ZkcmZZflWVTF51SoEGIpOgW+ANqsy4ArAhAFsKpA/AOe8
         FYhmxB/zsU/pNbRc7DxfIgs6d3vZNzVtqxHRhUUeCh20Cvo+EXuOLpB8UChW03zEXNsi
         yJAw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:mime-version:message-id
         :date:subject:cc:to:from;
        bh=TyMsiSXJXvB4f8OYfcJYvENBphf76n8t9aZCHzDZ8O8=;
        b=HNSWsJuArWBaZpdlAQyPLQlutPXXfD4iMVt5HxyUIjUl8cRQXqL29Se+CJBDVoX062
         TpItmEgoqD1b3A85tWcdFTnXcdAxxscZZzHLvZqwWulvYyt9r1Gp47LoD5Grf5E/8v4N
         W2sQAAXvTGO09h5TsOURHvpu5W7xXvgw0ico1uCN0eOXimBjOMHtQx9NU81YaUHurPVt
         n1ZkgBdoDUn9samHD3vlVCEUCHowSbE3m/wS7h+mk+EUKj2hIgwA+k9MDdsB4i/ZC9R7
         wdrkZWFIPaN7Jk3praj5t77DaOcLgGC6URPItC+g61HT3aFEbDvqwa0AEpI+WnpbvRVU
         6rmQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=kJwjrBly;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id x65si1358249ywf.419.2019.06.14.13.20.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Jun 2019 13:20:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.143 as permitted sender) client-ip=216.228.121.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=kJwjrBly;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate102.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d04018d0000>; Fri, 14 Jun 2019 13:20:29 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate102.nvidia.com (PGP Universal service);
  Fri, 14 Jun 2019 13:20:28 -0700
X-PGP-Universal: processed;
	by hqpgpgate102.nvidia.com on Fri, 14 Jun 2019 13:20:28 -0700
Received: from HQMAIL102.nvidia.com (172.18.146.10) by HQMAIL104.nvidia.com
 (172.18.146.11) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Fri, 14 Jun
 2019 20:20:28 +0000
Received: from HQMAIL105.nvidia.com (172.20.187.12) by HQMAIL102.nvidia.com
 (172.18.146.10) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Fri, 14 Jun
 2019 20:20:24 +0000
Received: from hqnvemgw01.nvidia.com (172.20.150.20) by HQMAIL105.nvidia.com
 (172.20.187.12) with Microsoft SMTP Server (TLS) id 15.0.1473.3 via Frontend
 Transport; Fri, 14 Jun 2019 20:20:24 +0000
Received: from rcampbell-dev.nvidia.com (Not Verified[10.110.48.66]) by hqnvemgw01.nvidia.com with Trustwave SEG (v7,5,8,10121)
	id <B5d0401880001>; Fri, 14 Jun 2019 13:20:24 -0700
From: Ralph Campbell <rcampbell@nvidia.com>
To: Jerome Glisse <jglisse@redhat.com>, David Airlie <airlied@linux.ie>, "Ben
 Skeggs" <bskeggs@redhat.com>, Jason Gunthorpe <jgg@mellanox.com>
CC: <nouveau@lists.freedesktop.org>, <linux-mm@kvack.org>,
	<dri-devel@lists.freedesktop.org>, <linux-kernel@vger.kernel.org>, "Ralph
 Campbell" <rcampbell@nvidia.com>
Subject: [PATCH v2] drm/nouveau/dmem: missing mutex_lock in error path
Date: Fri, 14 Jun 2019 13:20:03 -0700
Message-ID: <20190614202003.1642-1-rcampbell@nvidia.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
X-NVConfidentiality: public
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1560543629; bh=TyMsiSXJXvB4f8OYfcJYvENBphf76n8t9aZCHzDZ8O8=;
	h=X-PGP-Universal:From:To:CC:Subject:Date:Message-ID:X-Mailer:
	 MIME-Version:X-NVConfidentiality:Content-Transfer-Encoding:
	 Content-Type;
	b=kJwjrBlydBpBJgo8hyIrwjIOnGphjs3oV7L8YuZTh4U/469wv6xcrNip4TU0R3X2s
	 92NQlgKpdKxKuA2jzbM+RkQtwdDwmpYZuPS6wx5ihP7u+1aTgnKmateplMqV0GFumV
	 4jJgqIGUx3q+7dqFTe9fyPuGSOLyr6MzJML+zIfBOkw2FGHZW4Qs3G5ZUKMiAcaLKF
	 znT9Quq8WVsrLGhD7krNmRsrAJwwdMCtaPulpyDIn0VuK/zDdGwdU8QM8U+cD9bTKs
	 uo6keHXl2cU0fpn4HGBjMg6sl1044/79SayQHsMnN/dYp1I3HSSMNEv8uEj4zTHrX6
	 RINHVn03sQ9QA==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

In nouveau_dmem_pages_alloc(), the drm->dmem->mutex is unlocked before
calling nouveau_dmem_chunk_alloc() as shown when CONFIG_PROVE_LOCKING
is enabled:

[ 1294.871933] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[ 1294.876656] WARNING: bad unlock balance detected!
[ 1294.881375] 5.2.0-rc3+ #5 Not tainted
[ 1294.885048] -------------------------------------
[ 1294.889773] test-malloc-vra/6299 is trying to release lock (&drm->dmem->=
mutex) at:
[ 1294.897482] [<ffffffffa01a220f>] nouveau_dmem_migrate_alloc_and_copy+0x7=
9f/0xbf0 [nouveau]
[ 1294.905782] but there are no more locks to release!
[ 1294.910690]=20
[ 1294.910690] other info that might help us debug this:
[ 1294.917249] 1 lock held by test-malloc-vra/6299:
[ 1294.921881]  #0: 0000000016e10454 (&mm->mmap_sem#2){++++}, at: nouveau_s=
vmm_bind+0x142/0x210 [nouveau]
[ 1294.931313]=20
[ 1294.931313] stack backtrace:
[ 1294.935702] CPU: 4 PID: 6299 Comm: test-malloc-vra Not tainted 5.2.0-rc3=
+ #5
[ 1294.942786] Hardware name: ASUS X299-A/PRIME X299-A, BIOS 1401 05/21/201=
8
[ 1294.949590] Call Trace:
[ 1294.952059]  dump_stack+0x7c/0xc0
[ 1294.955469]  ? nouveau_dmem_migrate_alloc_and_copy+0x79f/0xbf0 [nouveau]
[ 1294.962213]  print_unlock_imbalance_bug.cold.52+0xca/0xcf
[ 1294.967641]  lock_release+0x306/0x380
[ 1294.971383]  ? nouveau_dmem_migrate_alloc_and_copy+0x79f/0xbf0 [nouveau]
[ 1294.978089]  ? lock_downgrade+0x2d0/0x2d0
[ 1294.982121]  ? find_held_lock+0xac/0xd0
[ 1294.985979]  __mutex_unlock_slowpath+0x8f/0x3f0
[ 1294.990540]  ? wait_for_completion+0x230/0x230
[ 1294.995002]  ? rwlock_bug.part.2+0x60/0x60
[ 1294.999197]  nouveau_dmem_migrate_alloc_and_copy+0x79f/0xbf0 [nouveau]
[ 1295.005751]  ? page_mapping+0x98/0x110
[ 1295.009511]  migrate_vma+0xa74/0x1090
[ 1295.013186]  ? move_to_new_page+0x480/0x480
[ 1295.017400]  ? __kmalloc+0x153/0x300
[ 1295.021052]  ? nouveau_dmem_migrate_vma+0xd8/0x1e0 [nouveau]
[ 1295.026796]  nouveau_dmem_migrate_vma+0x157/0x1e0 [nouveau]
[ 1295.032466]  ? nouveau_dmem_init+0x490/0x490 [nouveau]
[ 1295.037612]  ? vmacache_find+0xc2/0x110
[ 1295.041537]  nouveau_svmm_bind+0x1b4/0x210 [nouveau]
[ 1295.046583]  ? nouveau_svm_fault+0x13e0/0x13e0 [nouveau]
[ 1295.051912]  drm_ioctl_kernel+0x14d/0x1a0
[ 1295.055930]  ? drm_setversion+0x330/0x330
[ 1295.059971]  drm_ioctl+0x308/0x530
[ 1295.063384]  ? drm_version+0x150/0x150
[ 1295.067153]  ? find_held_lock+0xac/0xd0
[ 1295.070996]  ? __pm_runtime_resume+0x3f/0xa0
[ 1295.075285]  ? mark_held_locks+0x29/0xa0
[ 1295.079230]  ? _raw_spin_unlock_irqrestore+0x3c/0x50
[ 1295.084232]  ? lockdep_hardirqs_on+0x17d/0x250
[ 1295.088768]  nouveau_drm_ioctl+0x9a/0x100 [nouveau]
[ 1295.093661]  do_vfs_ioctl+0x137/0x9a0
[ 1295.097341]  ? ioctl_preallocate+0x140/0x140
[ 1295.101623]  ? match_held_lock+0x1b/0x230
[ 1295.105646]  ? match_held_lock+0x1b/0x230
[ 1295.109660]  ? find_held_lock+0xac/0xd0
[ 1295.113512]  ? __do_page_fault+0x324/0x630
[ 1295.117617]  ? lock_downgrade+0x2d0/0x2d0
[ 1295.121648]  ? mark_held_locks+0x79/0xa0
[ 1295.125583]  ? handle_mm_fault+0x352/0x430
[ 1295.129687]  ksys_ioctl+0x60/0x90
[ 1295.133020]  ? mark_held_locks+0x29/0xa0
[ 1295.136964]  __x64_sys_ioctl+0x3d/0x50
[ 1295.140726]  do_syscall_64+0x68/0x250
[ 1295.144400]  entry_SYSCALL_64_after_hwframe+0x49/0xbe
[ 1295.149465] RIP: 0033:0x7f1a3495809b
[ 1295.153053] Code: 0f 1e fa 48 8b 05 ed bd 0c 00 64 c7 00 26 00 00 00 48 =
c7 c0 ff ff ff ff c3 66 0f 1f 44 00 00 f3 0f 1e fa b8 10 00 00 00 0f 05 <48=
> 3d 01 f0 ff ff 73 01 c3 48 8b 0d bd bd 0c 00 f7 d8 64 89 01 48
[ 1295.171850] RSP: 002b:00007ffef7ed1358 EFLAGS: 00000246 ORIG_RAX: 000000=
0000000010
[ 1295.179451] RAX: ffffffffffffffda RBX: 00007ffef7ed1628 RCX: 00007f1a349=
5809b
[ 1295.186601] RDX: 00007ffef7ed13b0 RSI: 0000000040406449 RDI: 00000000000=
00004
[ 1295.193759] RBP: 00007ffef7ed13b0 R08: 0000000000000000 R09: 00000000015=
7e770
[ 1295.200917] R10: 000000000151c010 R11: 0000000000000246 R12: 00000000404=
06449
[ 1295.208083] R13: 0000000000000004 R14: 0000000000000000 R15: 00000000000=
00000

Reacquire the lock before continuing to the next page.

Signed-off-by: Ralph Campbell <rcampbell@nvidia.com>
---

I found this while testing Jason Gunthorpe's hmm tree but this is
independent of those changes. Jason thinks it is best to go through
David Airlie's nouveau tree.

Changes for v2:
Updated change log to include console output.

 drivers/gpu/drm/nouveau/nouveau_dmem.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/gpu/drm/nouveau/nouveau_dmem.c b/drivers/gpu/drm/nouve=
au/nouveau_dmem.c
index 27aa4e72abe9..00f7236af1b9 100644
--- a/drivers/gpu/drm/nouveau/nouveau_dmem.c
+++ b/drivers/gpu/drm/nouveau/nouveau_dmem.c
@@ -379,9 +379,10 @@ nouveau_dmem_pages_alloc(struct nouveau_drm *drm,
 			ret =3D nouveau_dmem_chunk_alloc(drm);
 			if (ret) {
 				if (c)
-					break;
+					return 0;
 				return ret;
 			}
+			mutex_lock(&drm->dmem->mutex);
 			continue;
 		}
=20
--=20
2.20.1

