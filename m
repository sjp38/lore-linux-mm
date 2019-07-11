Return-Path: <SRS0=bABq=VI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F2C77C742A1
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 23:25:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AC9572084B
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 23:25:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=os.amperecomputing.com header.i=@os.amperecomputing.com header.b="ReMtk1NS"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AC9572084B
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=os.amperecomputing.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EF6288E0103; Thu, 11 Jul 2019 19:25:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EA5138E00DB; Thu, 11 Jul 2019 19:25:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D4A148E0103; Thu, 11 Jul 2019 19:25:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id A4CF28E00DB
	for <linux-mm@kvack.org>; Thu, 11 Jul 2019 19:25:51 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id f13so222466qtq.16
        for <linux-mm@kvack.org>; Thu, 11 Jul 2019 16:25:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-transfer-encoding:mime-version;
        bh=nv9Pvxp/gDaeRKsmwNevq52lzFBVsYZWQfbDDaOzjpI=;
        b=VwOn6NgLzTM8QLAZozKejHyRih/a64Y3gApGql70LaTZeZi3xLDKQc9xoOUBIeLCjh
         ZAOLKCJJj/JkzUvjBkEp1KGt08gCXuzDnyjWHVXQgSBTcCKRHX72de4fNAf4JlnDMT24
         JY6xE3ETHcvp1iM5F6wjvkxIbaO4DnA9tNZazKYDACr2oZCVCfZkgOAGWFZtJ2jZ8AUw
         6MXPn7cBv1M2oqZG1/0rgzYQ34cfeet/5ojKIWjVfEwRIygD4VenYp1ax9yliZagIl/C
         eCz3ubUO+eeaZBwYWemetG9CZAJXfMIad2XzWrM9OSzTZLe4WiNOluHL6ZBmnTcvk9KA
         ti5w==
X-Gm-Message-State: APjAAAUMyqz3Xs06QPpa67zRRJ67oaTCOO7fKCcg7F3TxoIlS3xHPj0D
	3xZoeZf2VtqqcJyYKDGww9ecAKNICI4TprarhDJImJK2nqlD8PzayRZ4YRULLo7opMla4wOirSO
	AyE5Sh2bzvJCBl2gEk9BcjDQlC/g2c6yLo9sGaD1eRwa8bnj9Ei67JfVDg72Cdei/xA==
X-Received: by 2002:a05:620a:1097:: with SMTP id g23mr3869780qkk.185.1562887551461;
        Thu, 11 Jul 2019 16:25:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx162JL2XbupnC+da3+MGOClZ0HeOgR6OzhVFm4enmlzV72AKqdkk9CJav2XdzUemRWA7kJ
X-Received: by 2002:a05:620a:1097:: with SMTP id g23mr3869764qkk.185.1562887550740;
        Thu, 11 Jul 2019 16:25:50 -0700 (PDT)
ARC-Seal: i=2; a=rsa-sha256; t=1562887550; cv=pass;
        d=google.com; s=arc-20160816;
        b=op+KxHm4BWKW2WsBa8yRt2v3JkvMriep7L6/1yDxwzxCGwTTvOyOos+fgF6n+R0bsd
         ucJ1ztNgDWA1HRbCrLt1+4+m3XeJ+Pn4BN/1HVCf8syqaRLYeokjasLzE5V8vWKl0NTo
         WNfYIvzJJaCjt3l3DSiIvEB948+6UT0d0ePy9dF9HjAOjV0wqsePd+HSS7Unt40wFplW
         YpjVuJKw4IGxvVK0zqNEAcImAZ7eH+eeeQQv3j0J/GsCFlT6O5LUU49S7NH0s+X4TrZZ
         JIZZHMinTEyepEE9x42vyI3EDtI25zDfqo2v6G+uWAr90MKcQB8DujSKn1BptRj+eekR
         D16g==
ARC-Message-Signature: i=2; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=nv9Pvxp/gDaeRKsmwNevq52lzFBVsYZWQfbDDaOzjpI=;
        b=XHhBwdKnS0pfJ+NKGlMDcs0qKpzDzAxOq5+qnmgB+zD72o2s92c3bvlwh9glyVA//5
         YSOrMCMNV82FhxEhxq8qp+ifYoTCodvQcRTdxrXyNvmt0DK/80jVx3hddQsRRZapoer+
         VJUzdndLozjsy0bqpTQ0aCKCryG3TyQqKd8IBUtWhE5aZMh70lnJBXGnH4mOzFR3Aq6F
         StlKKtrbB+F+WSXsZ5xhWUOAyUiDeUOBhBVvfqoZXfzcNPkHU9ohIf5BYe94/+Guzxtr
         KrzDH8T6DGPHhfH/Cw1rCjGYqIcIYZ4Lxh1CThofF2HK5oXLHxS49PJ08IAujDGJuTID
         gMGg==
ARC-Authentication-Results: i=2; mx.google.com;
       dkim=pass header.i=@os.amperecomputing.com header.s=selector1 header.b=ReMtk1NS;
       arc=pass (i=1 spf=pass spfdomain=os.amperecomputing.com dkim=pass dkdomain=os.amperecomputing.com dmarc=pass fromdomain=os.amperecomputing.com);
       spf=pass (google.com: domain of hoan@os.amperecomputing.com designates 40.107.75.91 as permitted sender) smtp.mailfrom=hoan@os.amperecomputing.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=amperecomputing.com
Received: from NAM02-BL2-obe.outbound.protection.outlook.com (mail-eopbgr750091.outbound.protection.outlook.com. [40.107.75.91])
        by mx.google.com with ESMTPS id 36si4367361qvx.32.2019.07.11.16.25.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 11 Jul 2019 16:25:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of hoan@os.amperecomputing.com designates 40.107.75.91 as permitted sender) client-ip=40.107.75.91;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@os.amperecomputing.com header.s=selector1 header.b=ReMtk1NS;
       arc=pass (i=1 spf=pass spfdomain=os.amperecomputing.com dkim=pass dkdomain=os.amperecomputing.com dmarc=pass fromdomain=os.amperecomputing.com);
       spf=pass (google.com: domain of hoan@os.amperecomputing.com designates 40.107.75.91 as permitted sender) smtp.mailfrom=hoan@os.amperecomputing.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=amperecomputing.com
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=X4vXsban/ZKB+8ROlk9ZJVQf010WgWSTIcMznQStaiLD6SK7boxTUQnZxashxZ+Ba3SC+AGLWALrBXlBrlUj3FsobSoe7byYBPqk5JkXZvv9T/mnyeJGgfY0ZymtWt95ohuieZNyZVElf9jwpFAEnwzeoDeRh0E641K0KljLm6YjCHWlbuTmKSz4CH15D71eM5i+6cX0xbbNs5aFVty+Hk0vCHgX0iPEbjFRrw2c5+jMTAYTeQJP4i6aircSknSObn28qL2NdaToJwUg2LbYPVZW/PzsgMJJGuHp298Q/R96qy18/ZSGUC55V3eoS8nBFs+ezPottZcDlOEtApAUyw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=nv9Pvxp/gDaeRKsmwNevq52lzFBVsYZWQfbDDaOzjpI=;
 b=I/H/AS8orDud9iDIzKy/EZrnn33RmZMJcBW+KvjPhWeozEk6OyvYRKnucB3zHSYBSptEoQ9CueSanl5aYr8POdnSCID0DKjikfYu31Xb7T5uZJ0bBM0OV9kFL5H64ZMQK5skP17R89ZOqOMEQzIMHxoOOURuuGQqu+kAbfcVv/M6XutXvG78gz/nVVuYpuGA2qtf2JYplIbf4+WjpSJQFOprE42Dw5udQUsMnppebnIJg8Pvqlo6HQBueuocae5FCG5EROlNq5SCmhenJE4cs/ITNwGNX7AYpENW5xKwVln5kjqL8iTyyDn2U1Y3aDJ7QqUR+Tuap5UBetL4Ff/1Yw==
ARC-Authentication-Results: i=1; mx.microsoft.com 1;spf=pass
 smtp.mailfrom=os.amperecomputing.com;dmarc=pass action=none
 header.from=os.amperecomputing.com;dkim=pass
 header.d=os.amperecomputing.com;arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=os.amperecomputing.com; s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=nv9Pvxp/gDaeRKsmwNevq52lzFBVsYZWQfbDDaOzjpI=;
 b=ReMtk1NSKkckNw209I1pj6PpDd206QLAoZuUccoQ+U9xLEuTKf2c2lNtPoIJa7bbNMibSCca/DVQvHIYZr39u5AUNsWGjVVAsqKiEtWh4Fydz4R7TEKMh2zMIzyWBSdGyIL6J43K+1dnXo0A9ttoD4OINMN9vib9lnQYX99KjUs=
Received: from BYAPR01MB4085.prod.exchangelabs.com (52.135.237.22) by
 BYAPR01MB5557.prod.exchangelabs.com (20.179.88.205) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2073.10; Thu, 11 Jul 2019 23:25:49 +0000
Received: from BYAPR01MB4085.prod.exchangelabs.com
 ([fe80::9dbb:1b4c:bace:ef80]) by BYAPR01MB4085.prod.exchangelabs.com
 ([fe80::9dbb:1b4c:bace:ef80%7]) with mapi id 15.20.2052.020; Thu, 11 Jul 2019
 23:25:49 +0000
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
Subject: [PATCH v2 2/5] powerpc: Kconfig: Remove CONFIG_NODES_SPAN_OTHER_NODES
Thread-Topic: [PATCH v2 2/5] powerpc: Kconfig: Remove
 CONFIG_NODES_SPAN_OTHER_NODES
Thread-Index: AQHVOD/57/uJcWsU4EKBP/fxzyJHWw==
Date: Thu, 11 Jul 2019 23:25:49 +0000
Message-ID: <1562887528-5896-3-git-send-email-Hoan@os.amperecomputing.com>
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
x-ms-office365-filtering-correlation-id: dc67312c-bd1d-4ac6-2268-08d706571b83
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:BYAPR01MB5557;
x-ms-traffictypediagnostic: BYAPR01MB5557:
x-microsoft-antispam-prvs:
 <BYAPR01MB55570D96BF58823729B3BA1FF1F30@BYAPR01MB5557.prod.exchangelabs.com>
x-ms-oob-tlc-oobclassifiers: OLM:3383;
x-forefront-prvs: 0095BCF226
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10019020)(4636009)(346002)(376002)(39840400004)(136003)(396003)(366004)(189003)(199004)(52116002)(66476007)(66556008)(66946007)(64756008)(66446008)(14454004)(5660300002)(1511001)(6506007)(386003)(71190400001)(71200400001)(6436002)(53936002)(66066001)(4744005)(102836004)(25786009)(68736007)(6512007)(86362001)(3846002)(11346002)(2616005)(186003)(81166006)(26005)(2906002)(446003)(478600001)(4326008)(76176011)(6486002)(7736002)(305945005)(54906003)(8936002)(110136005)(7416002)(6116002)(99286004)(476003)(316002)(8676002)(107886003)(81156014)(486006)(256004)(50226002)(921003)(1121003);DIR:OUT;SFP:1102;SCL:1;SRVR:BYAPR01MB5557;H:BYAPR01MB4085.prod.exchangelabs.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:0;
received-spf: None (protection.outlook.com: os.amperecomputing.com does not
 designate permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 izT+63HRnUuAKD5eGQE8YKlxJrqgWZx0flLjKl/QWe6GzX9REGSnQmtmPQEHM+Nb7SoECE7IHtcSR/0MAmMRDwAqNOJomwkyv8FLL1J2BX2KQSmTEoXofPO43EwIMPbl2dEGPQJ2bdnlbA/u/D+U0iZAVdoIDLDMP2a93+1SIMSSeVKLE5AFoI8dKv5oIkRhidLD3R0KGJX2ZslNvRF5ULYgNZxwyQxPuatZw+KuS2J24LSK6WbmSwfnPvnfQ2oEI8RHlikLOL2wkTPFlmdjjzXsZ7sBC1I6get/tead9+DbSFP8sRhTXA6sUCv9LJs6Z0vPUqxS8bJiDfwxpivxFm38e/ZR5AjUUI512L3kodi4FaZHfbUzHHYn+zB0kLMs2okuu/Iyn/MQ/fXHY+vUlaH1tjB+IWfRuA6MeCfCx/U=
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: os.amperecomputing.com
X-MS-Exchange-CrossTenant-Network-Message-Id: dc67312c-bd1d-4ac6-2268-08d706571b83
X-MS-Exchange-CrossTenant-originalarrivaltime: 11 Jul 2019 23:25:49.3382
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

Remove CONFIG_NODES_SPAN_OTHER_NODES as it's enabled by
default with NUMA.

Signed-off-by: Hoan Tran <Hoan@os.amperecomputing.com>
---
 arch/powerpc/Kconfig | 9 ---------
 1 file changed, 9 deletions(-)

diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
index 8c1c636..bdde8bc 100644
--- a/arch/powerpc/Kconfig
+++ b/arch/powerpc/Kconfig
@@ -629,15 +629,6 @@ config ARCH_MEMORY_PROBE
 	def_bool y
 	depends on MEMORY_HOTPLUG
=20
-# Some NUMA nodes have memory ranges that span
-# other nodes.  Even though a pfn is valid and
-# between a node's start and end pfns, it may not
-# reside on that node.  See memmap_init_zone()
-# for details.
-config NODES_SPAN_OTHER_NODES
-	def_bool y
-	depends on NEED_MULTIPLE_NODES
-
 config STDBINUTILS
 	bool "Using standard binutils settings"
 	depends on 44x
--=20
2.7.4

