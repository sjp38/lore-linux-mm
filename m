Return-Path: <SRS0=iaDK=VA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AA7E6C5B57D
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 01:55:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 255D32064A
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 01:55:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amdcloud.onmicrosoft.com header.i=@amdcloud.onmicrosoft.com header.b="W2zQQN+X"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 255D32064A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=amd.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 889556B0003; Tue,  2 Jul 2019 21:55:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 839408E0003; Tue,  2 Jul 2019 21:55:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 701428E0001; Tue,  2 Jul 2019 21:55:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1E3506B0003
	for <linux-mm@kvack.org>; Tue,  2 Jul 2019 21:55:13 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id c31so66877ede.5
        for <linux-mm@kvack.org>; Tue, 02 Jul 2019 18:55:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:accept-language:content-language
         :content-transfer-encoding:mime-version;
        bh=7oplPm2wSJZV67v0BGtPZpmavHDLkNj5UUga/30yZM4=;
        b=evK2UZVxtpP7YWz9AI7br50BYqP7HhmWqZAgZfd1lW1pHb+t3/CpgaZAd9MBrpd6l5
         Z/IlAPiFWoG5KfBcQoDv4nc/z4eFmoicssRq2mik2tsep4+3tAxc6Y1ya/yoNRzGlJHF
         NgXyEtdAVKsfCgrGT82eZJXDbu1CfKTejjHLeeDYp32DcdC62daG8Z9F529WawvmtPSE
         wVuJ65+rgbCBHLQ1/TkKV7M1X5OH5vu/DA77GwYyMlWNSTLceq0/ksXN0qo4E2ShXQCt
         Lc5Byr6kZl66zMmQLklP6dP0xnQjV88ytj5TGQaSJINjR09HU8yHDEzsgccYZL5elkn+
         U5fQ==
X-Gm-Message-State: APjAAAVcw5j0vwPro9F9yfPMBCdZxbpYxMS/zK8Smc+jOSAOWlGP+aZj
	kc+tJCbfpGvwp9cPi9iC9KOtdgJfB/Ndh0lpi11WqV2BZsalG7boVLQzFrOKM25yOr+IuYNloSY
	FZ/p78g1QVzOIQu9inGKcffOh4Jys4f4AZLXNVTTaQHVddoLgo9EUeGZ0jJA0c9A=
X-Received: by 2002:a17:906:2191:: with SMTP id 17mr8428226eju.280.1562118912469;
        Tue, 02 Jul 2019 18:55:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqynyfqLNSHmVyT0Hg3p6SqE+/34wVyON9fXATGHZqjqdDencSmvMESg0Pqrdm650gom8xnE
X-Received: by 2002:a17:906:2191:: with SMTP id 17mr8428145eju.280.1562118910934;
        Tue, 02 Jul 2019 18:55:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562118910; cv=none;
        d=google.com; s=arc-20160816;
        b=GnEiXlZW979AKwppQzHdx1ByP1ORa69okXfmXOcqJ3hVB1WpjKMdL9Lias1WaYRjCw
         OfqLeEkWKIvljBmzn1Q3y4vXu484MTZb5jhl1WoAcUcDrTPGoeA5X4YDBaSd7Y9X3Clm
         lcuGdzFWg0ve3iwiA3ks4kIAp2FAINuqXRpULxAUuGzwkL/AVTzCMqhOe6XRdNrtrMnf
         y/Aw2I0x+7atB/GYOMEb7KQxPVwagkwIhD0RJGobYRCmq7Fcq5y2qn+U/3tmSfXxwgE7
         1ezJ+rOmerH8AsEeXCLzEwuFWKqyEFFW7Xxxu4Om/lezOHdB7ySooMBJ5zvtsXePlHxT
         EplQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-language
         :accept-language:message-id:date:thread-index:thread-topic:subject
         :cc:to:from:dkim-signature;
        bh=7oplPm2wSJZV67v0BGtPZpmavHDLkNj5UUga/30yZM4=;
        b=0s3/onNAEfsnxL3IzmkCom23Tx2ejHPDySDkSH7LKFAJozyUEpEsFP0h53Zrkhz7cw
         OlSrnvqe78qgR30Erz6Fg3z3+qIovIsZikPU01F9tQy8JVrmFClIb5HLvXPiIUdQ1LKl
         D0lCXeWU87w347cXHvu1eVnBNZubYz7TyaNq8y0W/s01O925QHmsfJtD9KmYsOsE1iYu
         KwxkRygnbGrswbNvXfpJM4Dlv5eYhZHU1o6gXRy7wTe9vf9VBXKVINYUXc+28a1aNNrX
         Mesw0m8BTj+zYTOAb6RAnAocleyvN2rV4i4YKeL3Ydvxf4maBx00iUx8tRK1gvhCZu2y
         cg1w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amdcloud.onmicrosoft.com header.s=selector1-amdcloud-onmicrosoft-com header.b=W2zQQN+X;
       spf=neutral (google.com: 40.107.82.41 is neither permitted nor denied by best guess record for domain of felix.kuehling@amd.com) smtp.mailfrom=Felix.Kuehling@amd.com
Received: from NAM01-SN1-obe.outbound.protection.outlook.com (mail-eopbgr820041.outbound.protection.outlook.com. [40.107.82.41])
        by mx.google.com with ESMTPS id n38si663880edd.125.2019.07.02.18.55.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 02 Jul 2019 18:55:10 -0700 (PDT)
Received-SPF: neutral (google.com: 40.107.82.41 is neither permitted nor denied by best guess record for domain of felix.kuehling@amd.com) client-ip=40.107.82.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amdcloud.onmicrosoft.com header.s=selector1-amdcloud-onmicrosoft-com header.b=W2zQQN+X;
       spf=neutral (google.com: 40.107.82.41 is neither permitted nor denied by best guess record for domain of felix.kuehling@amd.com) smtp.mailfrom=Felix.Kuehling@amd.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=amdcloud.onmicrosoft.com; s=selector1-amdcloud-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=7oplPm2wSJZV67v0BGtPZpmavHDLkNj5UUga/30yZM4=;
 b=W2zQQN+XKZ2GslCA62Ln5h9/aphtlznysT6jZ/7WZlKE0uyVJ96dU+9TZ5TaVHMy4KaELhu2kVMUtiLQTP9nZt2r2M/+RyB/0zYKZ5d13pU8u8h36RWLovtozMYKOwTYp4myPqHCPp0bwjVJikwDXHznneFtic8n5HHqOEnkfCw=
Received: from DM6PR12MB3947.namprd12.prod.outlook.com (10.255.174.156) by
 DM6PR12MB2652.namprd12.prod.outlook.com (20.176.116.25) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2032.20; Wed, 3 Jul 2019 01:55:08 +0000
Received: from DM6PR12MB3947.namprd12.prod.outlook.com
 ([fe80::91a2:f9e7:8c86:f927]) by DM6PR12MB3947.namprd12.prod.outlook.com
 ([fe80::91a2:f9e7:8c86:f927%7]) with mapi id 15.20.2032.019; Wed, 3 Jul 2019
 01:55:08 +0000
From: "Kuehling, Felix" <Felix.Kuehling@amd.com>
To: "linux-next@vger.kernel.org" <linux-next@vger.kernel.org>
CC: "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>, "Yang, Philip"
	<Philip.Yang@amd.com>, "Kuehling, Felix" <Felix.Kuehling@amd.com>, Stephen
 Rothwell <sfr@canb.auug.org.au>, Jason Gunthorpe <jgg@mellanox.com>, Dave
 Airlie <airlied@linux.ie>, "Deucher, Alexander" <Alexander.Deucher@amd.com>
Subject: [PATCH 1/1] drm/amdgpu: adopt to hmm_range_register API change
Thread-Topic: [PATCH 1/1] drm/amdgpu: adopt to hmm_range_register API change
Thread-Index: AQHVMUJXWs8sf5cAOUS0d/4NvIH/SQ==
Date: Wed, 3 Jul 2019 01:55:08 +0000
Message-ID: <20190703015442.11974-1-Felix.Kuehling@amd.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-originating-ip: [165.204.55.251]
x-mailer: git-send-email 2.17.1
x-clientproxiedby: YT1PR01CA0026.CANPRD01.PROD.OUTLOOK.COM (2603:10b6:b01::39)
 To DM6PR12MB3947.namprd12.prod.outlook.com (2603:10b6:5:1cb::28)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=Felix.Kuehling@amd.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 2173ad8a-291b-4189-3770-08d6ff5979eb
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:DM6PR12MB2652;
x-ms-traffictypediagnostic: DM6PR12MB2652:
x-microsoft-antispam-prvs:
 <DM6PR12MB2652144F39527B449C349A2E92FB0@DM6PR12MB2652.namprd12.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:18;
x-forefront-prvs: 00872B689F
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(4636009)(376002)(346002)(39860400002)(396003)(136003)(366004)(189003)(199004)(6116002)(476003)(3846002)(50226002)(68736007)(6486002)(2501003)(36756003)(486006)(1076003)(2616005)(72206003)(478600001)(8676002)(66946007)(66066001)(66476007)(66556008)(64756008)(14444005)(66446008)(256004)(2906002)(73956011)(71190400001)(7736002)(102836004)(86362001)(316002)(2351001)(53936002)(386003)(6506007)(6436002)(5660300002)(305945005)(186003)(54906003)(5640700003)(71200400001)(26005)(6916009)(6512007)(99286004)(14454004)(52116002)(25786009)(4326008)(81156014)(81166006)(8936002);DIR:OUT;SFP:1101;SCL:1;SRVR:DM6PR12MB2652;H:DM6PR12MB3947.namprd12.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: amd.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 D8pYFgBDw8vc2ySLePdFTTYU2PP6FSLlOzPGANy0eH5LNT7V1W1Sh2BpkJZwziaCLlvIQxCvrDMoBKPyNK66zszV2VNIkZFvGFmUEb6thUgi5+xppA6K8l4R1DoBviZqZpe1c2qOJA2Bm8UgUnP7xtXJDR8ylgmUx6W2AaiFmt8c5gjTx/bMQoozmUHm1bqiE5byCJtcRdnMaCxTf/f+6GjDPgDk1G0dZOxnXvhTMR7Fu2M9YmDUfQCfVmrY5vMG+b81DLeXqN66zRAJJGOZlinO5k+NDHuutDmHsvjRd8YU6F2MYeyuw2OwAkzU5AanSe/3o3uIuQf92E1znFAokbml/YvBYXE2Q6SOrlw3pMShwY4h52YTmVQITVeu9mvzgFsbK13KAdyLg9K9C/tW40CNzehyVGq9gIFlwXyN4dY=
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: amd.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 2173ad8a-291b-4189-3770-08d6ff5979eb
X-MS-Exchange-CrossTenant-originalarrivaltime: 03 Jul 2019 01:55:08.6921
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 3dd8961f-e488-4e60-8e11-a82d994e183d
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: fkuehlin@amd.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DM6PR12MB2652
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Philip Yang <Philip.Yang@amd.com>

In order to pass mirror instead of mm to hmm_range_register, we need
pass bo instead of ttm to amdgpu_ttm_tt_get_user_pages because mirror
is part of amdgpu_mn structure, which is accessible from bo.

Signed-off-by: Philip Yang <Philip.Yang@amd.com>
Reviewed-by: Felix Kuehling <Felix.Kuehling@amd.com>
Signed-off-by: Felix Kuehling <Felix.Kuehling@amd.com>
CC: Stephen Rothwell <sfr@canb.auug.org.au>
CC: Jason Gunthorpe <jgg@mellanox.com>
CC: Dave Airlie <airlied@linux.ie>
CC: Alex Deucher <alexander.deucher@amd.com>
---
 drivers/gpu/drm/Kconfig                          |  1 -
 drivers/gpu/drm/amd/amdgpu/amdgpu_amdkfd_gpuvm.c |  5 ++---
 drivers/gpu/drm/amd/amdgpu/amdgpu_cs.c           |  2 +-
 drivers/gpu/drm/amd/amdgpu/amdgpu_gem.c          |  3 +--
 drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c           |  8 ++++++++
 drivers/gpu/drm/amd/amdgpu/amdgpu_mn.h           |  5 +++++
 drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c          | 12 ++++++++++--
 drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.h          |  5 +++--
 8 files changed, 30 insertions(+), 11 deletions(-)

diff --git a/drivers/gpu/drm/Kconfig b/drivers/gpu/drm/Kconfig
index ee01afbbcd90..3313378c743b 100644
--- a/drivers/gpu/drm/Kconfig
+++ b/drivers/gpu/drm/Kconfig
@@ -220,7 +220,6 @@ source "drivers/gpu/drm/radeon/Kconfig"
=20
 config DRM_AMDGPU
 	tristate "AMD GPU"
-	depends on BROKEN
 	depends on DRM && PCI && MMU
 	select FW_LOADER
         select DRM_KMS_HELPER
diff --git a/drivers/gpu/drm/amd/amdgpu/amdgpu_amdkfd_gpuvm.c b/drivers/gpu=
/drm/amd/amdgpu/amdgpu_amdkfd_gpuvm.c
index 0aa81456ec32..146700a51373 100644
--- a/drivers/gpu/drm/amd/amdgpu/amdgpu_amdkfd_gpuvm.c
+++ b/drivers/gpu/drm/amd/amdgpu/amdgpu_amdkfd_gpuvm.c
@@ -504,7 +504,7 @@ static int init_user_pages(struct kgd_mem *mem, struct =
mm_struct *mm,
 		goto out;
 	}
=20
-	ret =3D amdgpu_ttm_tt_get_user_pages(bo->tbo.ttm, bo->tbo.ttm->pages);
+	ret =3D amdgpu_ttm_tt_get_user_pages(bo, bo->tbo.ttm->pages);
 	if (ret) {
 		pr_err("%s: Failed to get user pages: %d\n", __func__, ret);
 		goto unregister_out;
@@ -1729,8 +1729,7 @@ static int update_invalid_user_pages(struct amdkfd_pr=
ocess_info *process_info,
 		bo =3D mem->bo;
=20
 		/* Get updated user pages */
-		ret =3D amdgpu_ttm_tt_get_user_pages(bo->tbo.ttm,
-						   bo->tbo.ttm->pages);
+		ret =3D amdgpu_ttm_tt_get_user_pages(bo, bo->tbo.ttm->pages);
 		if (ret) {
 			pr_debug("%s: Failed to get user pages: %d\n",
 				__func__, ret);
diff --git a/drivers/gpu/drm/amd/amdgpu/amdgpu_cs.c b/drivers/gpu/drm/amd/a=
mdgpu/amdgpu_cs.c
index 37adce981fa3..e069de8b54e6 100644
--- a/drivers/gpu/drm/amd/amdgpu/amdgpu_cs.c
+++ b/drivers/gpu/drm/amd/amdgpu/amdgpu_cs.c
@@ -633,7 +633,7 @@ static int amdgpu_cs_parser_bos(struct amdgpu_cs_parser=
 *p,
 			return -ENOMEM;
 		}
=20
-		r =3D amdgpu_ttm_tt_get_user_pages(bo->tbo.ttm, e->user_pages);
+		r =3D amdgpu_ttm_tt_get_user_pages(bo, e->user_pages);
 		if (r) {
 			kvfree(e->user_pages);
 			e->user_pages =3D NULL;
diff --git a/drivers/gpu/drm/amd/amdgpu/amdgpu_gem.c b/drivers/gpu/drm/amd/=
amdgpu/amdgpu_gem.c
index 1f9f27061e2f..939f8305511b 100644
--- a/drivers/gpu/drm/amd/amdgpu/amdgpu_gem.c
+++ b/drivers/gpu/drm/amd/amdgpu/amdgpu_gem.c
@@ -327,8 +327,7 @@ int amdgpu_gem_userptr_ioctl(struct drm_device *dev, vo=
id *data,
 	}
=20
 	if (args->flags & AMDGPU_GEM_USERPTR_VALIDATE) {
-		r =3D amdgpu_ttm_tt_get_user_pages(bo->tbo.ttm,
-						 bo->tbo.ttm->pages);
+		r =3D amdgpu_ttm_tt_get_user_pages(bo, bo->tbo.ttm->pages);
 		if (r)
 			goto release_object;
=20
diff --git a/drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c b/drivers/gpu/drm/amd/a=
mdgpu/amdgpu_mn.c
index 623f56a1485f..80e40898a507 100644
--- a/drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c
+++ b/drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c
@@ -398,6 +398,14 @@ struct amdgpu_mn *amdgpu_mn_get(struct amdgpu_device *=
adev,
 	return ERR_PTR(r);
 }
=20
+struct hmm_mirror *amdgpu_mn_get_mirror(struct amdgpu_mn *amn)
+{
+	if (!amn)
+		return NULL;
+
+	return &amn->mirror;
+}
+
 /**
  * amdgpu_mn_register - register a BO for notifier updates
  *
diff --git a/drivers/gpu/drm/amd/amdgpu/amdgpu_mn.h b/drivers/gpu/drm/amd/a=
mdgpu/amdgpu_mn.h
index f5b67c63ed6b..cb1678925415 100644
--- a/drivers/gpu/drm/amd/amdgpu/amdgpu_mn.h
+++ b/drivers/gpu/drm/amd/amdgpu/amdgpu_mn.h
@@ -43,6 +43,7 @@ struct amdgpu_mn *amdgpu_mn_get(struct amdgpu_device *ade=
v,
 int amdgpu_mn_register(struct amdgpu_bo *bo, unsigned long addr);
 void amdgpu_mn_unregister(struct amdgpu_bo *bo);
 void amdgpu_hmm_init_range(struct hmm_range *range);
+struct hmm_mirror *amdgpu_mn_get_mirror(struct amdgpu_mn *amn);
 #else
 static inline void amdgpu_mn_lock(struct amdgpu_mn *mn) {}
 static inline void amdgpu_mn_unlock(struct amdgpu_mn *mn) {}
@@ -58,6 +59,10 @@ static inline int amdgpu_mn_register(struct amdgpu_bo *b=
o, unsigned long addr)
 	return -ENODEV;
 }
 static inline void amdgpu_mn_unregister(struct amdgpu_bo *bo) {}
+static inline struct hmm_mirror *amdgpu_mn_get_mirror(struct amdgpu_mn *am=
n)
+{
+	return NULL;
+}
 #endif
=20
 #endif
diff --git a/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c b/drivers/gpu/drm/amd/=
amdgpu/amdgpu_ttm.c
index c9faa69cd677..c602c994cb95 100644
--- a/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c
+++ b/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c
@@ -731,8 +731,10 @@ struct amdgpu_ttm_tt {
=20
 #define MAX_RETRY_HMM_RANGE_FAULT	16
=20
-int amdgpu_ttm_tt_get_user_pages(struct ttm_tt *ttm, struct page **pages)
+int amdgpu_ttm_tt_get_user_pages(struct amdgpu_bo *bo, struct page **pages=
)
 {
+	struct hmm_mirror *mirror =3D amdgpu_mn_get_mirror(bo->mn);
+	struct ttm_tt *ttm =3D bo->tbo.ttm;
 	struct amdgpu_ttm_tt *gtt =3D (void *)ttm;
 	struct mm_struct *mm =3D gtt->usertask->mm;
 	unsigned long start =3D gtt->userptr;
@@ -746,6 +748,12 @@ int amdgpu_ttm_tt_get_user_pages(struct ttm_tt *ttm, s=
truct page **pages)
 	if (!mm) /* Happens during process shutdown */
 		return -ESRCH;
=20
+	if (unlikely(!mirror)) {
+		DRM_DEBUG_DRIVER("Failed to get hmm_mirror\n");
+		r =3D -EFAULT;
+		goto out;
+	}
+
 	vma =3D find_vma(mm, start);
 	if (unlikely(!vma || start < vma->vm_start)) {
 		r =3D -EFAULT;
@@ -775,7 +783,7 @@ int amdgpu_ttm_tt_get_user_pages(struct ttm_tt *ttm, st=
ruct page **pages)
 				0 : range->flags[HMM_PFN_WRITE];
 	range->pfn_flags_mask =3D 0;
 	range->pfns =3D pfns;
-	hmm_range_register(range, mm, start,
+	hmm_range_register(range, mirror, start,
 			   start + ttm->num_pages * PAGE_SIZE, PAGE_SHIFT);
=20
 retry:
diff --git a/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.h b/drivers/gpu/drm/amd/=
amdgpu/amdgpu_ttm.h
index c2b7669004ba..caa76c693700 100644
--- a/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.h
+++ b/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.h
@@ -102,10 +102,11 @@ int amdgpu_ttm_alloc_gart(struct ttm_buffer_object *b=
o);
 int amdgpu_ttm_recover_gart(struct ttm_buffer_object *tbo);
=20
 #if IS_ENABLED(CONFIG_DRM_AMDGPU_USERPTR)
-int amdgpu_ttm_tt_get_user_pages(struct ttm_tt *ttm, struct page **pages);
+int amdgpu_ttm_tt_get_user_pages(struct amdgpu_bo *bo, struct page **pages=
);
 bool amdgpu_ttm_tt_get_user_pages_done(struct ttm_tt *ttm);
 #else
-static inline int amdgpu_ttm_tt_get_user_pages(struct ttm_tt *ttm, struct =
page **pages)
+static inline int amdgpu_ttm_tt_get_user_pages(struct amdgpu_bo *bo,
+					       struct page **pages)
 {
 	return -EPERM;
 }
--=20
2.17.1

