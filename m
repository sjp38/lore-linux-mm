Return-Path: <SRS0=bABq=VI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F3BC3C742A2
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 23:26:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A03FB21019
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 23:26:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=os.amperecomputing.com header.i=@os.amperecomputing.com header.b="F1KsBtXV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A03FB21019
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=os.amperecomputing.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 29A1D8E0106; Thu, 11 Jul 2019 19:25:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 24B6B8E00DB; Thu, 11 Jul 2019 19:25:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 09D3A8E0106; Thu, 11 Jul 2019 19:25:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id D82178E00DB
	for <linux-mm@kvack.org>; Thu, 11 Jul 2019 19:25:58 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id r58so5387143qtb.5
        for <linux-mm@kvack.org>; Thu, 11 Jul 2019 16:25:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-transfer-encoding:mime-version;
        bh=yt5BUf8uBdI0zBKA0tmArK7CJjsxGHX3sXRCl8E7/Uo=;
        b=YDnfDCjoL5jPDRoR2BJaoBVGUB471lLceasb8iMLLRD3+2mhrp/7UwDHkJIR3RDydk
         b8qrEOJNCacfSozEoUtzXkUnojJEC1SW9yl2G6oR/U5xFNDVDXfcM5Ownb66A9US7a92
         9gM8TJJ2F4iOR6OT6sRdKo49xLwDjaxVh1YYyo5PHsU2Gcm61SxxmJZfmIAhl3xPzx5Q
         C+4Jv2zbSDcjEwCw9SVe5S9wP70B8NuRl78Jro3/NGE2g3YSMLvn4MoryiDz7Lz6PdSJ
         kWDDw5OWS2cVowXU7wUk1hHBHi7xIAu+yFXkIbZ3jycaF/15ZK+Ccki330Md6CGErE5s
         gKYw==
X-Gm-Message-State: APjAAAVTe6MzHptDn0kRj9/u5ApY4WeDOEejqGw4BlZEBpGLQ9eavP/w
	3iXuqNC7K9uTMphomF1yfbqJi/+zI7aTJ62Jb/B7qkS0TH0WTOnp/CZUs2dxgyUpeRZdbzJNTvY
	KGZjNqEYfKGUk3HsHqc23o+fUDjX/kn3JIfnlLs573wzlJNHE5VNGEt/OAVNixP3eiA==
X-Received: by 2002:ac8:525a:: with SMTP id y26mr3896250qtn.378.1562887558671;
        Thu, 11 Jul 2019 16:25:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzjvCBg8x3VgIxg1/mLuPAG1WZXsYMeUmY0Qg5vfBzjX+ZMUGp5YbGOiTyPfmNCWirE37lH
X-Received: by 2002:ac8:525a:: with SMTP id y26mr3896227qtn.378.1562887557915;
        Thu, 11 Jul 2019 16:25:57 -0700 (PDT)
ARC-Seal: i=2; a=rsa-sha256; t=1562887557; cv=pass;
        d=google.com; s=arc-20160816;
        b=NHBRwdumjw8DJqsQjI1P85cF9wn9KZgQRayuM2bP2bllb9gR3yk0kWlM6BKhZluAGY
         UL5uAIXl83LGJNQ1ln3vajts3EAfK6lOP+GN13PIPzkUN8IfBalxKt8R9Kzk89g+YSmN
         Q6eycV4sKv6Kgu1eBDNN++PIjKHhdjFM+mOm+Q9E387TmB6rqSRZVSOQkc8Vb4ltbPa1
         dNZlkxsYk5jQZr8ECfGCl3lJ7XTgE/1T2mMEYthXg8hYKdbvVwksYS+K9hcaEHLTkSU8
         CiEmeb/JSCZrhQ5OaujxhqHsBZbPiax6rGWbKy1r2sT1dOkZePsGFHT5USJEO/cVg0eZ
         ZEXg==
ARC-Message-Signature: i=2; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=yt5BUf8uBdI0zBKA0tmArK7CJjsxGHX3sXRCl8E7/Uo=;
        b=aHc9SbJcZ+ZhhYc1ktU3KfAkW+rDm8dDcj4e+T3neuNbir6Isssad1tcJdaotq8uma
         XxBf0/K3aokP0P+XKdUHAOJkNlP2FuhsMDe7/iMArtidceBibnqL2uFg95iG/Cki8KRp
         XYwJmxk9wuhvPgQ8CvSdcsKOEdhbmX6fVtieyUq647hxk2topT3Ynng1qqluYlo6Vpad
         3q+dPdwtSkNfDDKeo7HtmEBbrYwhflnSn2r92Cj7TWQ2JGormbzVPioecPFySoQ6w7oV
         ScK0Wd5RR1ewHQbn+TdS5kLTzgek66MhXZJRStyaJwmMx7pMZEfdhAS7/pjsuZeTxeWB
         H8zQ==
ARC-Authentication-Results: i=2; mx.google.com;
       dkim=pass header.i=@os.amperecomputing.com header.s=selector1 header.b=F1KsBtXV;
       arc=pass (i=1 spf=pass spfdomain=os.amperecomputing.com dkim=pass dkdomain=os.amperecomputing.com dmarc=pass fromdomain=os.amperecomputing.com);
       spf=pass (google.com: domain of hoan@os.amperecomputing.com designates 40.107.74.132 as permitted sender) smtp.mailfrom=hoan@os.amperecomputing.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=amperecomputing.com
Received: from NAM01-BN3-obe.outbound.protection.outlook.com (mail-eopbgr740132.outbound.protection.outlook.com. [40.107.74.132])
        by mx.google.com with ESMTPS id c6si4216866qta.22.2019.07.11.16.25.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 11 Jul 2019 16:25:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of hoan@os.amperecomputing.com designates 40.107.74.132 as permitted sender) client-ip=40.107.74.132;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@os.amperecomputing.com header.s=selector1 header.b=F1KsBtXV;
       arc=pass (i=1 spf=pass spfdomain=os.amperecomputing.com dkim=pass dkdomain=os.amperecomputing.com dmarc=pass fromdomain=os.amperecomputing.com);
       spf=pass (google.com: domain of hoan@os.amperecomputing.com designates 40.107.74.132 as permitted sender) smtp.mailfrom=hoan@os.amperecomputing.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=amperecomputing.com
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=IjzKzilVToEhzIAI5is0DdsC4vgYNMB0Wj5MmC6ubWwqo7xyuW5Yq1IBU4TdXHO48I/oIXa7RUmQuwZSZRIoZtyUJGjjNV9QWGMMu7diFbTxS5876h8lW26ICF4H+Dq0LjtOdyncx/YPxx6jDUBuSoAuHFrgPsA9wicUFi9DuloY8MPYWmF1fjCfFebn9FxV/Ktz/8yCIHWTYPody6Wpz8yCkn4If4awSoTRzHYEHPvIsSkNeihVd44tQP6GW6TLy2ylgmopskzim04OEneCR8dMCr/fiR86evyZsmfOhQQer+dR7M79RcrIlqvkjOsY3hdhmjgkKMOoHBZzO59L/Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=yt5BUf8uBdI0zBKA0tmArK7CJjsxGHX3sXRCl8E7/Uo=;
 b=R4tFND1NM4rop1hBP66km/bpX5akbjarYsmgHZneKxX+vekCLftwiR1u7GxZsrqitzGDC9J9nhJIKNifTddGLNmact7Yf6I5KguWUUD2GAaXJEZPs+hZZMZ6Uw1Oyq6iGMV2j9j2wNf7QY1bFE5GK9XbXKpB+CQlKrJ+qN+xrkJMdgwI4SeF4fVkCGs/DIFrGRSH4gIOSwWzF2Sdyp5YowSgO7mTspU76WXRyEMWrZRMfKC+Y+wECbAV+Sqow5Vslvna1WJ86Kn2CdacB2QJ9MF2AKv3ZKFXKkzm/K5Vf9bACPXo+/1CvwP9CT9ajpARyVokJUvL64jQr1cu/Lv6BA==
ARC-Authentication-Results: i=1; mx.microsoft.com 1;spf=pass
 smtp.mailfrom=os.amperecomputing.com;dmarc=pass action=none
 header.from=os.amperecomputing.com;dkim=pass
 header.d=os.amperecomputing.com;arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=os.amperecomputing.com; s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=yt5BUf8uBdI0zBKA0tmArK7CJjsxGHX3sXRCl8E7/Uo=;
 b=F1KsBtXVLMSi1zMKdRSaLfSyHDwqJkQi+wtKfH0kbEU4LixQ39NYs78lY2c+AEESNP9BZCu2DZ+/xSvKUH0dfd+TcTQ5cgSiT4L32E/XWJmfae6SxQYgav2CQhityuWQENyIoiJgtrpkoAPlTXcjdTu9zBHwZoylgbVgJTJWWXw=
Received: from BYAPR01MB4085.prod.exchangelabs.com (52.135.237.22) by
 BYAPR01MB5557.prod.exchangelabs.com (20.179.88.205) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2073.10; Thu, 11 Jul 2019 23:25:56 +0000
Received: from BYAPR01MB4085.prod.exchangelabs.com
 ([fe80::9dbb:1b4c:bace:ef80]) by BYAPR01MB4085.prod.exchangelabs.com
 ([fe80::9dbb:1b4c:bace:ef80%7]) with mapi id 15.20.2052.020; Thu, 11 Jul 2019
 23:25:56 +0000
From: Hoan Tran OS <hoan@os.amperecomputing.com>
To: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon
	<will.deacon@arm.com>, Andrew Morton <akpm@linux-foundation.org>, Michal
 Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Oscar Salvador
	<osalvador@suse.de>, Pavel Tatashin <pavel.tatashin@microsoft.com>, Mike
 Rapoport <rppt@linux.ibm.com>, Alexander Duyck
	<alexander.h.duyck@linux.intel.com>, Benjamin Herrenschmidt
	<benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael
 Ellerman <mpe@ellerman.id.au>, Thomas Gleixner <tglx@linutronix.de>, Ingo
 Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H . Peter Anvin"
	<hpa@zytor.com>, "David S . Miller" <davem@davemloft.net>, Heiko Carstens
	<heiko.carstens@de.ibm.com>, Vasily Gorbik <gor@linux.ibm.com>, Christian
 Borntraeger <borntraeger@de.ibm.com>
CC: "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>, "linux-s390@vger.kernel.org"
	<linux-s390@vger.kernel.org>, "sparclinux@vger.kernel.org"
	<sparclinux@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>,
	"linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Open Source
 Submission <patches@amperecomputing.com>, Hoan Tran OS
	<hoan@os.amperecomputing.com>
Subject: [PATCH v2 5/5] s390: Kconfig: Remove CONFIG_NODES_SPAN_OTHER_NODES
Thread-Topic: [PATCH v2 5/5] s390: Kconfig: Remove
 CONFIG_NODES_SPAN_OTHER_NODES
Thread-Index: AQHVOD/9mGRS/XlnZESkAFQmCjkqtw==
Date: Thu, 11 Jul 2019 23:25:56 +0000
Message-ID: <1562887528-5896-6-git-send-email-Hoan@os.amperecomputing.com>
References: <1562887528-5896-1-git-send-email-Hoan@os.amperecomputing.com>
In-Reply-To: <1562887528-5896-1-git-send-email-Hoan@os.amperecomputing.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: CY4PR19CA0045.namprd19.prod.outlook.com
 (2603:10b6:903:103::31) To BYAPR01MB4085.prod.exchangelabs.com
 (2603:10b6:a03:56::22)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=hoan@os.amperecomputing.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-mailer: git-send-email 2.7.4
x-originating-ip: [4.28.12.214]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: dd1a597e-2e44-4157-c4a8-08d706571fc9
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:BYAPR01MB5557;
x-ms-traffictypediagnostic: BYAPR01MB5557:
x-microsoft-antispam-prvs:
 <BYAPR01MB5557B45CBF88F8B331D5CFF2F1F30@BYAPR01MB5557.prod.exchangelabs.com>
x-ms-oob-tlc-oobclassifiers: OLM:5797;
x-forefront-prvs: 0095BCF226
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10019020)(4636009)(1496009)(346002)(376002)(136003)(39850400004)(396003)(366004)(189003)(199004)(52116002)(66476007)(66556008)(66946007)(64756008)(66446008)(14454004)(5660300002)(1511001)(6506007)(386003)(71190400001)(71200400001)(6436002)(53936002)(66066001)(4744005)(102836004)(25786009)(68736007)(6512007)(86362001)(3846002)(11346002)(2616005)(186003)(81166006)(26005)(2906002)(446003)(478600001)(4326008)(76176011)(6486002)(7736002)(305945005)(54906003)(8936002)(110136005)(7416002)(6116002)(99286004)(476003)(316002)(8676002)(107886003)(81156014)(486006)(256004)(50226002)(921003)(1121003);DIR:OUT;SFP:1102;SCL:1;SRVR:BYAPR01MB5557;H:BYAPR01MB4085.prod.exchangelabs.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:0;
received-spf: None (protection.outlook.com: os.amperecomputing.com does not
 designate permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 Ef+hznBXN4myNBzMO+crFklQrkxl3woJDcHEtEGbtkSTBtF+FhbMuzXn0YWK9JzlERYgQ1oWA5mukf+CM4Nf23+mMlM05cpBYrM2if/e1uE/ntUxwqQ/awrcr2FlshYZIQWDolmpLqBzoxDcFPEXiIeg0M3mlqlXaLPtGXn+IvqaLdvbg/iMyiPa2DZjkGRvcJ1ifKZHfiVTssO4oLIhNbK9CR9HJNEC3Rk3AtfWLRE+aMyUvol2NyVIVj1IQlXc27+vPavojbgNzWs5nshmirt3G3gOn2tZ0YfphazGi5INi0R9CJHu7Si7ZsXqNP3ur7XuskxxiDLSqNbJ0jd/2rMrC6iqCBhknF3Kye0rkkbarElU1uyWfMAg7Ah0QJX0YlAnhKetdJzg3bJRv+2WUHA22MFseloe345Oi/oAN00=
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: os.amperecomputing.com
X-MS-Exchange-CrossTenant-Network-Message-Id: dd1a597e-2e44-4157-c4a8-08d706571fc9
X-MS-Exchange-CrossTenant-originalarrivaltime: 11 Jul 2019 23:25:56.4780
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 3bc2b170-fd94-476d-b0ce-4229bdc904a7
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: Hoan@os.amperecomputing.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR01MB5557
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Remove CONFIG_NODES_SPAN_OTHER_NODES as it's enabled
by default with NUMA.

Signed-off-by: Hoan Tran <Hoan@os.amperecomputing.com>
---
 arch/s390/Kconfig | 8 --------
 1 file changed, 8 deletions(-)

diff --git a/arch/s390/Kconfig b/arch/s390/Kconfig
index 109243f..788a8e9 100644
--- a/arch/s390/Kconfig
+++ b/arch/s390/Kconfig
@@ -438,14 +438,6 @@ config HOTPLUG_CPU
 	  can be controlled through /sys/devices/system/cpu/cpu#.
 	  Say N if you want to disable CPU hotplug.
=20
-# Some NUMA nodes have memory ranges that span
-# other nodes.	Even though a pfn is valid and
-# between a node's start and end pfns, it may not
-# reside on that node.	See memmap_init_zone()
-# for details. <- They meant memory holes!
-config NODES_SPAN_OTHER_NODES
-	def_bool NUMA
-
 config NUMA
 	bool "NUMA support"
 	depends on SMP && SCHED_TOPOLOGY
--=20
2.7.4

