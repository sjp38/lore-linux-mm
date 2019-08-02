Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6A39BC32750
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 20:07:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 00304205F4
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 20:07:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="fNGtePxM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 00304205F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 963E46B0006; Fri,  2 Aug 2019 16:07:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9140C6B0008; Fri,  2 Aug 2019 16:07:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7DC156B000A; Fri,  2 Aug 2019 16:07:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2BFFA6B0006
	for <linux-mm@kvack.org>; Fri,  2 Aug 2019 16:07:14 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id f3so47592507edx.10
        for <linux-mm@kvack.org>; Fri, 02 Aug 2019 13:07:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:accept-language:content-language
         :content-id:content-transfer-encoding:mime-version;
        bh=B62krEMnULqaKcJvzNM9gnUzZfBmp8DvTgEeNrk/xNU=;
        b=ED260hRQlR2qZv+RVXve7UBcL9ctzwM3gcu4Z6Q62eVcPWUeIM125IgD79BXhDYmf4
         jhQdujV/j8PtpR7sdF/MuIGQUXnY2stsS7yofHe7B7+Pzn2rtSq2ffDKd+GJI9FctDnc
         YlgGrZMZ0cycRM9nQ1GITAjWACqYgUA0zQElFZqFBA/HwogO9TgU3OkuPgnfIQVm68GV
         r3kfNKa4LlKCmis+3bsaC/i4q+p7eJ6SAIZN8m2gP2cbVaoE0G/cftJeZcMXJA+3PGrP
         VGK8lRgOUy19vGQj0IJ8EUQpq1VHsBftO882PF34xW4nxrj7Yt3X3jCXqnesbMEu39/c
         EEMw==
X-Gm-Message-State: APjAAAWyUiBVTdH0zdHskeIPYmSwVJ61VnQm8Pk1yfqDu/3RE0MU9H1C
	iqmuWIptigS2quVWdPK6xP+iDw0GU/6Llp8jQW5f4/65SEgM2Q10sRi0+QqcBZg8yFQN/eBZ52o
	6iJvQFl1wPGlqvnRz6ybN29WtrkkogKQSoXG71q9VcNpOXSEO+vKPCeVX6D15MrXYew==
X-Received: by 2002:a50:aed6:: with SMTP id f22mr121880708edd.59.1564776433670;
        Fri, 02 Aug 2019 13:07:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzDrSB5BIciP4HI0Rcz9r3u28A0ToGOCCD2TQZpx6eSfyIIyA5K5Au7SBjXvdbiWlHWv5Ic
X-Received: by 2002:a50:aed6:: with SMTP id f22mr121880648edd.59.1564776432707;
        Fri, 02 Aug 2019 13:07:12 -0700 (PDT)
ARC-Seal: i=2; a=rsa-sha256; t=1564776432; cv=pass;
        d=google.com; s=arc-20160816;
        b=QNODRFTwHAKTX82cMDp/UyLdGhgNdZx1yLCrTzGuWxayG2aP0b+FLExwZpM08fzajt
         kJaN0NzSDEg4zSBB+v5eH6+SE6E/dI2VK4un2lEny7gXLSz3aj+T7YeKOl14MMcH6tFy
         SyPrO1377Z9iQeLD4kDdH3ubjnSwC0c+/FwSq0EPDe47fJYcFHH5DauElbi1FU88GJuh
         knc4/lureV0mwVZhNpOh3QQQH8407Scnoalr6k76wpOCHCfUFFeId1VRQNjqGOHoIBF6
         jOsLbs16wvB2QfhDEjnJVr30lpdLyH9AUlFQZqL8Zop2xAP9yvPQkUbfEtVXVteVN4//
         0fDQ==
ARC-Message-Signature: i=2; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:message-id:date:thread-index:thread-topic:subject
         :cc:to:from:dkim-signature;
        bh=B62krEMnULqaKcJvzNM9gnUzZfBmp8DvTgEeNrk/xNU=;
        b=jUn9FvkHLKxp+BPThFObV71nzvqrlRKYb5C/GSCNSQe+WLK18qHz0fLJLQi0E1FQbH
         6K8i4CKxM9h7YRu975BdzbIJ63ykmpAGwAWZIPvI1E7Jfqz+QH5xAAK5dSJxUnFwnTR8
         kQwisX2desxikUO9ZGCmPIpJRoddBWzcvoltZB+U5EcoGHHDrSSnJguRbo1kTytYguJp
         sSkQVPL8y9eZPQN55u5bd0XES4zw+jGWF4WBZmSiT1EsyKjh1skreVmmsTjilsEJRs2J
         OMaNl7tRdocpzkZG6+3ZQ2fRf8OXBtYM44ImnKgCZHw5JtBoZW3wSusAtDRT39m3RUGK
         T91w==
ARC-Authentication-Results: i=2; mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=fNGtePxM;
       arc=pass (i=1 spf=pass spfdomain=mellanox.com dkim=pass dkdomain=mellanox.com dmarc=pass fromdomain=mellanox.com);
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.1.76 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
Received: from EUR02-HE1-obe.outbound.protection.outlook.com (mail-eopbgr10076.outbound.protection.outlook.com. [40.107.1.76])
        by mx.google.com with ESMTPS id s41si24407231edd.252.2019.08.02.13.07.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 02 Aug 2019 13:07:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@mellanox.com designates 40.107.1.76 as permitted sender) client-ip=40.107.1.76;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=fNGtePxM;
       arc=pass (i=1 spf=pass spfdomain=mellanox.com dkim=pass dkdomain=mellanox.com dmarc=pass fromdomain=mellanox.com);
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.1.76 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=QSZNA9GSIWwXj6XX/DrO4X5PhBXdNLZiCIabdxsfHWv1u1kFzaBbMDNk7XxMcItDSe48McmDfogSpyRsiPHqzpv1NPddAi/MDrcXXJaw4FLTtOVlUTYCRo2svmOHO7V472sQiObvokj/Yc5joPHB+TBg67wAdtIo53ok0VC5J3jWqauzRG97RjaJhwB9pURsvqLgTwg3zs635wGs4F8ToCKEdOT5tHzs7IOj3QsqjwODoIG4Fr/P2NAae3OooV5JWig3RnV/ajwWvl6MSZdDRFxrJtuZ3k+8nRDxaZG2pK2y+vD6Jg3jTdzO9mt4362tBtD70yUp6I2sLnmMdtdCDQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=B62krEMnULqaKcJvzNM9gnUzZfBmp8DvTgEeNrk/xNU=;
 b=fyyIs7M+cs8lKzPwc/Pj2PfiMCDbMgrPpMZAG0P5VASnjnMwNYPTFZrvqu8sSq08BJQJ2lS/75qWNjNZ/IVfV82ex5W95Tm1l0D5gQuKXKdPauk66kOjfLNPTeCpIGf2IqW0RD0AytA5YFgljfFPBN93+zwMsh8vO/v7M+aPDR8tzebwPahPyt+uuSVIq/1Gb4Q1K7D64IYwV8iL8pEIWDYWZoTchdc6h61/6ZyQrlXmEFpIn6cV0yNDhQfcNYyr83oqC0zZq98G5/oms99Rmo+Oai5BfNliN3kbgLDW/SBeYVhQflqTUO+cIGWjyt2si/c3XgKaGDy2PLdwR0UNlw==
ARC-Authentication-Results: i=1; mx.microsoft.com 1;spf=pass
 smtp.mailfrom=mellanox.com;dmarc=pass action=none
 header.from=mellanox.com;dkim=pass header.d=mellanox.com;arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=B62krEMnULqaKcJvzNM9gnUzZfBmp8DvTgEeNrk/xNU=;
 b=fNGtePxMWyWR0fEHVCuWrsD1lw1UML2bKWKVC4ycf/qETUp15y2QayH6dfgfSFTJ5WZxGPPCRyZVFrOggvY71BNxGU8M50z2mLn66N57oGmWotylQlj3WVtYs2kX/fVsKaazXs2bck+E69hyDPAliBXOC5K2rFgg1OKfV6yC+T4=
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com (10.171.182.144) by
 VI1PR05MB6477.eurprd05.prod.outlook.com (20.179.26.150) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2136.17; Fri, 2 Aug 2019 20:07:11 +0000
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::5c6f:6120:45cd:2880]) by VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::5c6f:6120:45cd:2880%4]) with mapi id 15.20.2136.010; Fri, 2 Aug 2019
 20:07:11 +0000
From: Jason Gunthorpe <jgg@mellanox.com>
To: "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>, Ben
 Goz <ben.goz@amd.com>, Oded Gabbay <oded.gabbay@amd.com>
CC: Christoph Hellwig <hch@infradead.org>, "amd-gfx@lists.freedesktop.org"
	<amd-gfx@lists.freedesktop.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	"Kuehling, Felix" <Felix.Kuehling@amd.com>
Subject: [PATCH hmm] drm/amdkfd: fix a use after free race with mmu_notififer
 unregister
Thread-Topic: [PATCH hmm] drm/amdkfd: fix a use after free race with
 mmu_notififer unregister
Thread-Index: AQHVSW3eVhbq/l2AtU+wYY32iYZXvQ==
Date: Fri, 2 Aug 2019 20:07:10 +0000
Message-ID: <20190802200705.GA10110@ziepe.ca>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: YT1PR01CA0030.CANPRD01.PROD.OUTLOOK.COM (2603:10b6:b01::43)
 To VI1PR05MB4141.eurprd05.prod.outlook.com (2603:10a6:803:4d::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [156.34.55.100]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 635b10e8-0234-4922-9556-08d7178500d4
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:VI1PR05MB6477;
x-ms-traffictypediagnostic: VI1PR05MB6477:
x-ms-exchange-purlcount: 1
x-microsoft-antispam-prvs:
 <VI1PR05MB64775D6B9AF865A8D70EC94BCFD90@VI1PR05MB6477.eurprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:5236;
x-forefront-prvs: 011787B9DD
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(4636009)(376002)(396003)(39860400002)(366004)(346002)(136003)(199004)(189003)(66946007)(4326008)(102836004)(1076003)(66446008)(64756008)(66556008)(66476007)(86362001)(186003)(14454004)(6436002)(6116002)(966005)(2906002)(66066001)(68736007)(386003)(316002)(26005)(5660300002)(476003)(486006)(3846002)(33656002)(8936002)(36756003)(256004)(14444005)(71200400001)(81156014)(81166006)(71190400001)(110136005)(6506007)(52116002)(53936002)(25786009)(54906003)(6512007)(9686003)(6306002)(8676002)(7736002)(478600001)(305945005)(6486002)(99286004)(2501003);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR05MB6477;H:VI1PR05MB4141.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 Sx6FQxaCkoWS2vdDi4g2N3ZcMzBGGSgN5h5N9oOnvHml3UhJRjUSFejzuh/FlAaX0eUmw9+0+0K09o5u9fPmc+XRgeQ6utQVdwrlVzO8XhX9R3QT9Kc/HduzyGLok4Cc3JXaNMaGBYnm39IYyefUXlWVanKPebxjbyKTXiYDqAd/Pw2JHB/5yoLWcGlH0YPkXk+YKzx3SWCX6BzzZXN40KmeDVIF9pXzpMIOjixxLDa7QEqQELIvgo82KJsJTmrFQwWSfmrz6Uw+i59Q8j9iY02fC/dXj+HJ3HAUZl9Y3rULA5V1GTjDxcKQrjV1juPhzHOPH8ruNtlXe3SGTjmY4s5vH5cPhZXEccgc4JYc1ZuSaLl6pd7FsdnFFW+pZkeBHZHpsY/BdK6ZWTJo2ZZIytfyMZ1xoK72a4ZLGWQmB2U=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <DF401B70D0E89E45B2E3B3A0247EBB76@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 635b10e8-0234-4922-9556-08d7178500d4
X-MS-Exchange-CrossTenant-originalarrivaltime: 02 Aug 2019 20:07:10.9864
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: jgg@mellanox.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR05MB6477
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

When using mmu_notififer_unregister_no_release() the caller must ensure
there is a SRCU synchronize before the mn memory is freed, otherwise use
after free races are possible, for instance:

     CPU0                                      CPU1
                                      invalidate_range_start
                                         hlist_for_each_entry_rcu(..)
 mmu_notifier_unregister_no_release(&p->mn)
 kfree(mn)
                                      if (mn->ops->invalidate_range_end)

The error unwind in amdkfd misses the SRCU synchronization.

amdkfd keeps the kfd_process around until the mm is released, so split the
flow to fully initialize the kfd_process and register it for find_process,
and with the notifier. Past this point the kfd_process does not need to be
cleaned up as it is fully ready.

The final failable step does a vm_mmap() and does not seem to impact the
kfd_process global state. Since it also cannot be undone (and already has
problems with undo if it internally fails), it has to be last.

This way we don't have to try to unwind the mmu_notifier_register() and
avoid the problem with the SRCU.

Along the way this also fixes various other error unwind bugs in the flow.

Fixes: 45102048f77e ("amdkfd: Add process queue manager module")
Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
---
 drivers/gpu/drm/amd/amdkfd/kfd_process.c | 74 +++++++++++-------------
 1 file changed, 35 insertions(+), 39 deletions(-)

amdkfd folks, this little bug is blocking some rework I have for the
mmu notifiers (ie mm/mmu_notifiers: remove unregister_no_release)

Can I get your help to review and if needed polish this change? I'd
like to send this patch through the hmm tree along with the rework,
thanks

You can see the larger series here:

https://github.com/jgunthorpe/linux/commits/mmu_notifier

Jason

diff --git a/drivers/gpu/drm/amd/amdkfd/kfd_process.c b/drivers/gpu/drm/amd=
/amdkfd/kfd_process.c
index 8f1076c0c88a25..81e3ee3f1813bf 100644
--- a/drivers/gpu/drm/amd/amdkfd/kfd_process.c
+++ b/drivers/gpu/drm/amd/amdkfd/kfd_process.c
@@ -62,8 +62,8 @@ static struct workqueue_struct *kfd_restore_wq;
=20
 static struct kfd_process *find_process(const struct task_struct *thread);
 static void kfd_process_ref_release(struct kref *ref);
-static struct kfd_process *create_process(const struct task_struct *thread=
,
-					struct file *filep);
+static struct kfd_process *create_process(const struct task_struct *thread=
);
+static int kfd_process_init_cwsr_apu(struct kfd_process *p, struct file *f=
ilep);
=20
 static void evict_process_worker(struct work_struct *work);
 static void restore_process_worker(struct work_struct *work);
@@ -289,7 +289,15 @@ struct kfd_process *kfd_create_process(struct file *fi=
lep)
 	if (process) {
 		pr_debug("Process already found\n");
 	} else {
-		process =3D create_process(thread, filep);
+		process =3D create_process(thread);
+		if (IS_ERR(process))
+			goto out;
+
+		ret =3D kfd_process_init_cwsr_apu(process, filep);
+		if (ret) {
+			process =3D ERR_PTR(ret);
+			goto out;
+		}
=20
 		if (!procfs.kobj)
 			goto out;
@@ -609,64 +617,56 @@ static int kfd_process_device_init_cwsr_dgpu(struct k=
fd_process_device *pdd)
 	return 0;
 }
=20
-static struct kfd_process *create_process(const struct task_struct *thread=
,
-					struct file *filep)
+/*
+ * On return the kfd_process is fully operational and will be freed when t=
he
+ * mm is released
+ */
+static struct kfd_process *create_process(const struct task_struct *thread=
)
 {
 	struct kfd_process *process;
 	int err =3D -ENOMEM;
=20
 	process =3D kzalloc(sizeof(*process), GFP_KERNEL);
-
 	if (!process)
 		goto err_alloc_process;
=20
-	process->pasid =3D kfd_pasid_alloc();
-	if (process->pasid =3D=3D 0)
-		goto err_alloc_pasid;
-
-	if (kfd_alloc_process_doorbells(process) < 0)
-		goto err_alloc_doorbells;
-
 	kref_init(&process->ref);
-
 	mutex_init(&process->mutex);
-
 	process->mm =3D thread->mm;
-
-	/* register notifier */
-	process->mmu_notifier.ops =3D &kfd_process_mmu_notifier_ops;
-	err =3D mmu_notifier_register(&process->mmu_notifier, process->mm);
-	if (err)
-		goto err_mmu_notifier;
-
-	hash_add_rcu(kfd_processes_table, &process->kfd_processes,
-			(uintptr_t)process->mm);
-
 	process->lead_thread =3D thread->group_leader;
-	get_task_struct(process->lead_thread);
-
 	INIT_LIST_HEAD(&process->per_device_data);
-
+	INIT_DELAYED_WORK(&process->eviction_work, evict_process_worker);
+	INIT_DELAYED_WORK(&process->restore_work, restore_process_worker);
+	process->last_restore_timestamp =3D get_jiffies_64();
 	kfd_event_init_process(process);
+	process->is_32bit_user_mode =3D in_compat_syscall();
+
+	process->pasid =3D kfd_pasid_alloc();
+	if (process->pasid =3D=3D 0)
+		goto err_alloc_pasid;
+
+	if (kfd_alloc_process_doorbells(process) < 0)
+		goto err_alloc_doorbells;
=20
 	err =3D pqm_init(&process->pqm, process);
 	if (err !=3D 0)
 		goto err_process_pqm_init;
=20
 	/* init process apertures*/
-	process->is_32bit_user_mode =3D in_compat_syscall();
 	err =3D kfd_init_apertures(process);
 	if (err !=3D 0)
 		goto err_init_apertures;
=20
-	INIT_DELAYED_WORK(&process->eviction_work, evict_process_worker);
-	INIT_DELAYED_WORK(&process->restore_work, restore_process_worker);
-	process->last_restore_timestamp =3D get_jiffies_64();
-
-	err =3D kfd_process_init_cwsr_apu(process, filep);
+	/* Must be last, have to use release destruction after this */
+	process->mmu_notifier.ops =3D &kfd_process_mmu_notifier_ops;
+	err =3D mmu_notifier_register(&process->mmu_notifier, process->mm);
 	if (err)
 		goto err_init_cwsr;
=20
+	get_task_struct(process->lead_thread);
+	hash_add_rcu(kfd_processes_table, &process->kfd_processes,
+			(uintptr_t)process->mm);
+
 	return process;
=20
 err_init_cwsr:
@@ -675,15 +675,11 @@ static struct kfd_process *create_process(const struc=
t task_struct *thread,
 err_init_apertures:
 	pqm_uninit(&process->pqm);
 err_process_pqm_init:
-	hash_del_rcu(&process->kfd_processes);
-	synchronize_rcu();
-	mmu_notifier_unregister_no_release(&process->mmu_notifier, process->mm);
-err_mmu_notifier:
-	mutex_destroy(&process->mutex);
 	kfd_free_process_doorbells(process);
 err_alloc_doorbells:
 	kfd_pasid_free(process->pasid);
 err_alloc_pasid:
+	mutex_destroy(&process->mutex);
 	kfree(process);
 err_alloc_process:
 	return ERR_PTR(err);
--=20
2.22.0

