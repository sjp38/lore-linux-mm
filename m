Return-Path: <SRS0=bABq=VI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B3DB2C742A2
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 23:25:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6082C21530
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 23:25:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=os.amperecomputing.com header.i=@os.amperecomputing.com header.b="RCSyljDi"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6082C21530
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=os.amperecomputing.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C869D8E0104; Thu, 11 Jul 2019 19:25:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BE7288E00DB; Thu, 11 Jul 2019 19:25:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AB0AC8E0104; Thu, 11 Jul 2019 19:25:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 869808E00DB
	for <linux-mm@kvack.org>; Thu, 11 Jul 2019 19:25:54 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id v11so8473637iop.7
        for <linux-mm@kvack.org>; Thu, 11 Jul 2019 16:25:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-transfer-encoding:mime-version;
        bh=qWV1MOUNxiDDw+u8HgB9VwvU/aKqnCn2F/F6C9LIbhY=;
        b=FdZ4f6yyx6iyvu4fSpeIGdFdGu0p+V6P9u+iceQX/ia8h+TdEcf6TJ2IRLQ7Rq9zFd
         vEBATMI7DFcWS1kJqzXZ+qiZmAk8s8NF1vIKt9dwG3+mstc3Tc57WQeCiFpDy8CyhpV1
         w2jxh6ddYq1akkiPY2UIS1sTFpvAVU0kzvHrbv3zlT4Yk52x04mh/4LmONh87s0oXCgw
         tAvK0oaizLuJW2/Ik3TxuFKATOa1ZbR3hxmfnuVG1tWW4TQ2awrkrNRYvXBKjMhl8iKS
         +C7szeleImABi403CVirQpPNAvgU/gUqmwVtWGRJ+qDX26q0HSzMFEIjq8utqrpmZ5Ze
         5p0Q==
X-Gm-Message-State: APjAAAUIQ0149IMfEkRkAbROabQA9sGkuxL4HFU6BLgL51uZh4ZLkfs7
	1FUPA/vzrvMXdvt/gq8lakGh2MnpJBhjAYZoLw1/qqyK2b/6Vr9NsiKDEg8WJu19NWd+qUUyThW
	yI5kdVamI695xSZUPMGEfnMHdH0mqD+PaQe7byFhiFz6NDMtF2/WueuFNZ0njaUIlTA==
X-Received: by 2002:a05:6638:81:: with SMTP id v1mr7345879jao.72.1562887554327;
        Thu, 11 Jul 2019 16:25:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwBqtqtgoDdV2OBCuqY0i/hkQeOYauNP+PDUyQpTpYkxBIXqDb247S54XWCYRMhxM5YEZsy
X-Received: by 2002:a05:6638:81:: with SMTP id v1mr7345819jao.72.1562887553482;
        Thu, 11 Jul 2019 16:25:53 -0700 (PDT)
ARC-Seal: i=2; a=rsa-sha256; t=1562887553; cv=pass;
        d=google.com; s=arc-20160816;
        b=swTkE+j/5qtizIKMJ/stg8pbcXJe5/C5H0Wtmkr7zTgYCxFMP7oyt8Umh5qCrhgZBm
         v5qQH+GzmzrquHYMU2m/3dYlg5yDRyhkcKFdfUwrTuQDTGGk7udAbl+g7TOgc9bl0D4M
         vyqwf2gS3IrpOrs46l/m27HJs7xEGQrCImaYd9f+SmjO6i+ppuhUdArU6FXoQA9Zr3js
         1QGh5RhV5p0A/YlisTJJ/cj/JyGty3YetHBKssEs3nlyaxy8cYFotbGLatv07TPOLxYc
         VkMKe5v4g9x4Hxha0ykJnHM3mpdB+IovsRAGoglqcMa/kwgtolzOzkEvb9c0ANQ52bhR
         lunA==
ARC-Message-Signature: i=2; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=qWV1MOUNxiDDw+u8HgB9VwvU/aKqnCn2F/F6C9LIbhY=;
        b=MEnLdMBtbcET4A9S7NlJntggfi3Vk0FY4i6Krnvw44tVsbcTvgKP8vfoz7e8X7hfKs
         LQu8BHpbZFmbWRFwXksCPL8W0g8XnCa/dHJK8aaezZqXXMkA4W231F65paUr6P4dhqzc
         9hWgKifFkPVLavuP1Nb8vGISyb3GX7pJrKMyLLBYUTyx/3LAy2SbihfEvvkQuVXrpq8j
         hwV6OWutOyhonsGDUZWYV5qYIqFRrZi6R8zDJdfMavnseKHoB21lpUerpwY4n1FLZwmG
         aZUo1jz/o5boS3wO8E2UHB1EF7Tt5rOdJbJ0jN/Z9lpOcINLyE9qU26TsAWaQ5GpDaBc
         NMAw==
ARC-Authentication-Results: i=2; mx.google.com;
       dkim=pass header.i=@os.amperecomputing.com header.s=selector1 header.b=RCSyljDi;
       arc=pass (i=1 spf=pass spfdomain=os.amperecomputing.com dkim=pass dkdomain=os.amperecomputing.com dmarc=pass fromdomain=os.amperecomputing.com);
       spf=pass (google.com: domain of hoan@os.amperecomputing.com designates 40.107.75.131 as permitted sender) smtp.mailfrom=hoan@os.amperecomputing.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=amperecomputing.com
Received: from NAM02-BL2-obe.outbound.protection.outlook.com (mail-eopbgr750131.outbound.protection.outlook.com. [40.107.75.131])
        by mx.google.com with ESMTPS id d28si10958049jaa.64.2019.07.11.16.25.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 11 Jul 2019 16:25:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of hoan@os.amperecomputing.com designates 40.107.75.131 as permitted sender) client-ip=40.107.75.131;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@os.amperecomputing.com header.s=selector1 header.b=RCSyljDi;
       arc=pass (i=1 spf=pass spfdomain=os.amperecomputing.com dkim=pass dkdomain=os.amperecomputing.com dmarc=pass fromdomain=os.amperecomputing.com);
       spf=pass (google.com: domain of hoan@os.amperecomputing.com designates 40.107.75.131 as permitted sender) smtp.mailfrom=hoan@os.amperecomputing.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=amperecomputing.com
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=nR5+TqydjcMHq22Z3jsKQcuLdcIdCmw84S6kSj9pXnL/xsCuR3PwCHPywFGkEFnYpehSaSUbw/rmX+JQFDgIW195hafOs8SoVaDfC5ieZC1XQs+hcB9MI+hLE1gN24k6LlngXzMbjSOABDqNOEdMhOr6gjCDmV4CLYMAyuG/6pls3GQ2KmBIFgAtj3s7v7hQqZOLbTBuaj17eYACF4ySIc66HYie1+W6KRP9XYcq9BalHXJY4uqzk9kGhpi1Z02O3ZOKF391HHHGBNhTF5lN1hPC7Anc2IPoGSUcLSBqqTFV0GhxaXHN/7rrODwzA3VrmLr+QLnBv7+FFqmNYvvwoQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=qWV1MOUNxiDDw+u8HgB9VwvU/aKqnCn2F/F6C9LIbhY=;
 b=Wvxz9J5qCCU9HqOY8DrUx/SN7DYqL9g3g4kdo0e/uIgqQjl9KviDQD90ZlykgjXlpd7tkSA9AQzZCEECyxIQkgsB0q96SSgmnnWfd098auHShkalM4OWxCRtYVoE+0Sn4K99/1SAdwF2fXgTniW+Vt75tqxFHCy8k/VItT9A/4ToA5/4x9qopeYUbSn/NHYwiVD/niCtLa00gGQNG6T6C0ZKuv+qruETD3CJSC8JrAVW7Pb/Pz5fjagQvPgTkaOrLHdvK6P+pWM6tPt+3XUlswxx5Cg4CbLRpFQqmPBf59tImOLyAJ81OEX1b53CxogmFoMdgLpvREdGuB2MWAP7jw==
ARC-Authentication-Results: i=1; mx.microsoft.com 1;spf=pass
 smtp.mailfrom=os.amperecomputing.com;dmarc=pass action=none
 header.from=os.amperecomputing.com;dkim=pass
 header.d=os.amperecomputing.com;arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=os.amperecomputing.com; s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=qWV1MOUNxiDDw+u8HgB9VwvU/aKqnCn2F/F6C9LIbhY=;
 b=RCSyljDiR/TMyiVIyYNiUkKu406+E574hzvAZMQ7e2IDGkIn5xe6bFqNC6GXeBc1/R2bhrqt8ySEVkgzwm3cJ7S6ndKzHR6FOHiNRmRQ/lNY912cKV5Tjvv5yaaXDHJ4GU30QhLUWcoCBJu9+EMAmwROIpMWCQNzQQVweqgmtCU=
Received: from BYAPR01MB4085.prod.exchangelabs.com (52.135.237.22) by
 BYAPR01MB5557.prod.exchangelabs.com (20.179.88.205) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2073.10; Thu, 11 Jul 2019 23:25:52 +0000
Received: from BYAPR01MB4085.prod.exchangelabs.com
 ([fe80::9dbb:1b4c:bace:ef80]) by BYAPR01MB4085.prod.exchangelabs.com
 ([fe80::9dbb:1b4c:bace:ef80%7]) with mapi id 15.20.2052.020; Thu, 11 Jul 2019
 23:25:51 +0000
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
Subject: [PATCH v2 3/5] x86: Kconfig: Remove CONFIG_NODES_SPAN_OTHER_NODES
Thread-Topic: [PATCH v2 3/5] x86: Kconfig: Remove
 CONFIG_NODES_SPAN_OTHER_NODES
Thread-Index: AQHVOD/6mMbG4b3xtkKwY5B+a64Pmg==
Date: Thu, 11 Jul 2019 23:25:51 +0000
Message-ID: <1562887528-5896-4-git-send-email-Hoan@os.amperecomputing.com>
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
x-ms-office365-filtering-correlation-id: 60e6bd66-cb09-4bd8-7c4e-08d706571cf4
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:BYAPR01MB5557;
x-ms-traffictypediagnostic: BYAPR01MB5557:
x-microsoft-antispam-prvs:
 <BYAPR01MB5557239AD4D7113B3B7ADD13F1F30@BYAPR01MB5557.prod.exchangelabs.com>
x-ms-oob-tlc-oobclassifiers: OLM:3383;
x-forefront-prvs: 0095BCF226
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10019020)(4636009)(346002)(376002)(39840400004)(136003)(396003)(366004)(189003)(199004)(52116002)(66476007)(66556008)(66946007)(64756008)(66446008)(14454004)(5660300002)(1511001)(6506007)(386003)(71190400001)(71200400001)(6436002)(53936002)(66066001)(4744005)(102836004)(25786009)(68736007)(6512007)(86362001)(3846002)(11346002)(2616005)(186003)(81166006)(26005)(2906002)(446003)(478600001)(4326008)(76176011)(6486002)(7736002)(305945005)(54906003)(8936002)(110136005)(7416002)(6116002)(99286004)(476003)(316002)(8676002)(107886003)(81156014)(486006)(256004)(50226002)(921003)(1121003);DIR:OUT;SFP:1102;SCL:1;SRVR:BYAPR01MB5557;H:BYAPR01MB4085.prod.exchangelabs.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:0;
received-spf: None (protection.outlook.com: os.amperecomputing.com does not
 designate permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 +yD719DBgEH8rntLj0mGEtqpmWqARyiJM3JmReTrowtXLYcEkce3BJ+Tbd8hXmVF8TIDhHZ80KU1sC4uoLl7ZNHxc+Pqdw+J88LRaDtq0nHrmLM0Cn1nKNiS3589Xvar6n6GbAvvJLxPKKQ8pKcrK3Si6Lv7VhB+GUJTE1NyokRYTutBsj7Hv6kqhv7u1jtY3cvwJ0PPV05AikvwNjhsladmz394WfVMPSpnPaKrIujOgi0/ERXzvu53KywSzCJlQlkwtY3cs+oyb/xonwlfFLGtj6ki8sBbJvmdoYus+98UewK4fmG79RHNYRxaDKh2giGUarUOwVWbuGUuSWnIBE6W44Myl9zRNHbg4Moun1fzPdpOl94U3xF5L49W56OEtJUajSMJue12CuCucmItSAnK9UXqNdg5VvPjksaaiLc=
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: os.amperecomputing.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 60e6bd66-cb09-4bd8-7c4e-08d706571cf4
X-MS-Exchange-CrossTenant-originalarrivaltime: 11 Jul 2019 23:25:51.7318
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
 arch/x86/Kconfig | 9 ---------
 1 file changed, 9 deletions(-)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 2bbbd4d..fa9318c 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -1567,15 +1567,6 @@ config X86_64_ACPI_NUMA
 	---help---
 	  Enable ACPI SRAT based node topology detection.
=20
-# Some NUMA nodes have memory ranges that span
-# other nodes.  Even though a pfn is valid and
-# between a node's start and end pfns, it may not
-# reside on that node.  See memmap_init_zone()
-# for details.
-config NODES_SPAN_OTHER_NODES
-	def_bool y
-	depends on X86_64_ACPI_NUMA
-
 config NUMA_EMU
 	bool "NUMA emulation"
 	depends on NUMA
--=20
2.7.4

