Return-Path: <SRS0=bABq=VI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 83B61C742A2
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 23:25:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 309092084B
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 23:25:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=os.amperecomputing.com header.i=@os.amperecomputing.com header.b="J5IL3kXT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 309092084B
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=os.amperecomputing.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CD5F18E0102; Thu, 11 Jul 2019 19:25:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C0C628E00DB; Thu, 11 Jul 2019 19:25:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 99B7B8E0102; Thu, 11 Jul 2019 19:25:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6F26E8E00DB
	for <linux-mm@kvack.org>; Thu, 11 Jul 2019 19:25:49 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id c1so5333275qkl.7
        for <linux-mm@kvack.org>; Thu, 11 Jul 2019 16:25:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-transfer-encoding:mime-version;
        bh=aAkwAUXFcJwgbrCQk1P/5UfnEYvBvi1WIDIoJ7eF/sg=;
        b=fVU+Mp/cTD9KsEZK4vztMRVDE7a600FtIaZmKalnQ+G0tatlaM9V6d/9sCwGzZKZ2i
         1fzvHBRLYRqXGybSs49S2aBGTIaePzEHBv6+6QSDVDU6W2llODwfZ08qMR3yOs5gFVX6
         gj28higYr1+cJEqThfwtWbL/jaVCHj2esiCyE2uoLOxQL4rYjOneK/EdSeiA3Vn4ON3P
         mS/h0au4j5cRmzJEvf88bvI5T0GI8GMtGS4nXxnE4XfMv6uQcgakE5E7Bi9HeY2IWviV
         ywrzw2eFibx2UirTY2xmwKhRu4Nf3smsuuei/40vYYJRRoSs5MfrOB76CGZDGnXuzlfS
         fSzg==
X-Gm-Message-State: APjAAAUdV7LblTlJN02XQiADrXYApUBsP5ufhWqpn+BoDIO6zG+7WVF2
	XIRXm3l0T6Y40zBBwMIyiJT+FWnEIMmfHiNsrBpaIg21tHPDHaXszt1f3j83csMgKhIYE06vp/h
	Vp2eRsbu6U0yl2OFNOACkJTU3aFSQSVsiwDW8IFOwPzZeC5dD9lph2SM5cQmnry8K5g==
X-Received: by 2002:a05:620a:142e:: with SMTP id k14mr3999820qkj.336.1562887549190;
        Thu, 11 Jul 2019 16:25:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzWdmDU+4MoDOZgX29rDL0LMEW0afSKXLBDTWAl5ToijbMxLgegseoRDgy79Q4G4NrBX6vS
X-Received: by 2002:a05:620a:142e:: with SMTP id k14mr3999801qkj.336.1562887548663;
        Thu, 11 Jul 2019 16:25:48 -0700 (PDT)
ARC-Seal: i=2; a=rsa-sha256; t=1562887548; cv=pass;
        d=google.com; s=arc-20160816;
        b=A1KMpyVgSXVQYbiT0CwrlbAJldCsG5mO7nxwOdR3MFDcavse0zxfebWBSJhfrdqhhI
         tJsy+XGbAKE3QwJ6Cu5GWms/JRM9KtK6YntRwSn5W9MZxUUXIToFKy64f5m7qjuj5Oic
         Ti2iLh3fHCHLxO5YV5rypG4ajqQkSt5rELNhowgG1hqhfUAsTDSX7Vw43PzFmLP5IFxF
         DoGFcybpeTyNj8ED9z1yvcZ9fKzSNzNbTCrEAJv9+/pozElcnD+NxHo7jw955Bx1GWKh
         bZOUpYS6s6ZkKYQdv4GtWZ8F+ewOezwmsm8ZFlNFmMuovCxTVVPQ+FTJ+3pbpg3xY9G+
         Ebnw==
ARC-Message-Signature: i=2; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=aAkwAUXFcJwgbrCQk1P/5UfnEYvBvi1WIDIoJ7eF/sg=;
        b=gVPkRZaJXM4QANr8PrAS6oerrI7F6qdREi9CtmkdGfc3QgfWJ46NibS/yn7nLp2z1J
         jmaoe1DNgkUUy0eLiw6bdO9lvreVkhaUUMWclQ+xwe1BQCv7raS0a7SAzSX1OzjesFEJ
         /OWw3e7+krC6wGhTQ39o6cLrcN7Ywjp2VIvQi8J9ChMnYP+dSvEZeTlaKOgseeTt0WMR
         q3dk0nt8PxFoAB+U23kUnDoW/mJx88S3+a6sbgzOhL4xxUD5xtq1IrMi5bfoRH5gvz/j
         AEwwBKm0DMMpbNPFaUCyF5v7NAp9oZPSvmWWZgEVmJMc4lJUCgquseT5eGGczps48OW4
         a0nw==
ARC-Authentication-Results: i=2; mx.google.com;
       dkim=pass header.i=@os.amperecomputing.com header.s=selector1 header.b=J5IL3kXT;
       arc=pass (i=1 spf=pass spfdomain=os.amperecomputing.com dkim=pass dkdomain=os.amperecomputing.com dmarc=pass fromdomain=os.amperecomputing.com);
       spf=pass (google.com: domain of hoan@os.amperecomputing.com designates 2a01:111:f400:fe41::727 as permitted sender) smtp.mailfrom=hoan@os.amperecomputing.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=amperecomputing.com
Received: from NAM01-BN3-obe.outbound.protection.outlook.com (mail-bn3nam01on0727.outbound.protection.outlook.com. [2a01:111:f400:fe41::727])
        by mx.google.com with ESMTPS id k12si3929271qvt.38.2019.07.11.16.25.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 11 Jul 2019 16:25:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of hoan@os.amperecomputing.com designates 2a01:111:f400:fe41::727 as permitted sender) client-ip=2a01:111:f400:fe41::727;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@os.amperecomputing.com header.s=selector1 header.b=J5IL3kXT;
       arc=pass (i=1 spf=pass spfdomain=os.amperecomputing.com dkim=pass dkdomain=os.amperecomputing.com dmarc=pass fromdomain=os.amperecomputing.com);
       spf=pass (google.com: domain of hoan@os.amperecomputing.com designates 2a01:111:f400:fe41::727 as permitted sender) smtp.mailfrom=hoan@os.amperecomputing.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=amperecomputing.com
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=VVwuPvrojSRmAiT4oLyUVqHSTETqikuopjbwqP0KV+gG7Ze31El33noCMUbHCTkUp4CmMid0WKLWbYyDrWZaat7ZgG4eokZUIRG11lF4oaDke9JQ84gqG26X3enLrYSuZChsG0cZcNjZUfCxzbE4qnJCkkVNJ6o7A2ohBhoSxXCXNEL9VdxO26fCZ6bqd0ewg1NYAZxa8+R8hsoJTUKA0MartPLewiumiEcnHXjNl/3YJ9DRtNfmMwAEliBiAwxki7vPGS6KdCi8B54o8LmFUteG2tT+OUlpqddyOxOtScp8fH2g/uurXHefkq2XrOc9Ml7wwmrUB3VPQXrbLO/wcQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=aAkwAUXFcJwgbrCQk1P/5UfnEYvBvi1WIDIoJ7eF/sg=;
 b=iS6wPtkfnItopB3uWlkR/fuLKUB29lXBH6XZrWItLeRJreFnmyy9Ygtpt7QKvFwr0HHFub8NXHQgn/zeeZkY2R9z9MjSJnwKUe10E5VeIE3TQYyG9SI2wtUO89sC0VhhaxUQTgd4m6HR35ExwXH7HaICt6OxD36aHrO6mgkGr2sud2RDznKZwgbpr88PQhDPcix7U++zQj6XfULeSuicWyOrG+5dSANjapUEYiBRz0tn/MfBahPenrfs5ofoky6vkaS9MP98s0q6kqxa2PKD/k9p4drUXSydHiTWcI9OesAA/Go5HMYc9ifQFORPAzDgHfr2DorTnPx8wiohMa2/lA==
ARC-Authentication-Results: i=1; mx.microsoft.com 1;spf=pass
 smtp.mailfrom=os.amperecomputing.com;dmarc=pass action=none
 header.from=os.amperecomputing.com;dkim=pass
 header.d=os.amperecomputing.com;arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=os.amperecomputing.com; s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=aAkwAUXFcJwgbrCQk1P/5UfnEYvBvi1WIDIoJ7eF/sg=;
 b=J5IL3kXT5B/vWbnmJm5M/jH9Yk0XQ66ap3/Wtjqh3TCEQYVwn2PtWHoLfdVscRm+1lFVqQF6WzC/8bOI7rmbSkeZ1/53gsfIbzKG1DQ0xQgl8CcrqfCX5iH9ZXZJIrrCeHcUTdYsDh4aTkmeVakEEosmz1iO0oeD9B39+VJ169c=
Received: from BYAPR01MB4085.prod.exchangelabs.com (52.135.237.22) by
 BYAPR01MB5557.prod.exchangelabs.com (20.179.88.205) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2073.10; Thu, 11 Jul 2019 23:25:47 +0000
Received: from BYAPR01MB4085.prod.exchangelabs.com
 ([fe80::9dbb:1b4c:bace:ef80]) by BYAPR01MB4085.prod.exchangelabs.com
 ([fe80::9dbb:1b4c:bace:ef80%7]) with mapi id 15.20.2052.020; Thu, 11 Jul 2019
 23:25:47 +0000
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
Subject: [PATCH v2 1/5] mm: Enable CONFIG_NODES_SPAN_OTHER_NODES by default
 for NUMA
Thread-Topic: [PATCH v2 1/5] mm: Enable CONFIG_NODES_SPAN_OTHER_NODES by
 default for NUMA
Thread-Index: AQHVOD/336vwo048FEmmzwG+DxzWnQ==
Date: Thu, 11 Jul 2019 23:25:46 +0000
Message-ID: <1562887528-5896-2-git-send-email-Hoan@os.amperecomputing.com>
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
x-ms-office365-filtering-correlation-id: afb7b246-2fa9-41ed-0b23-08d7065719fd
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:BYAPR01MB5557;
x-ms-traffictypediagnostic: BYAPR01MB5557:
x-microsoft-antispam-prvs:
 <BYAPR01MB5557067FB5EFEF0F4FDE9887F1F30@BYAPR01MB5557.prod.exchangelabs.com>
x-ms-oob-tlc-oobclassifiers: OLM:9508;
x-forefront-prvs: 0095BCF226
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10019020)(4636009)(346002)(376002)(39840400004)(136003)(396003)(366004)(189003)(199004)(52116002)(66476007)(66556008)(66946007)(64756008)(66446008)(14454004)(5660300002)(1511001)(6506007)(386003)(71190400001)(71200400001)(6436002)(53936002)(66066001)(102836004)(25786009)(68736007)(6512007)(86362001)(3846002)(11346002)(14444005)(2616005)(186003)(81166006)(26005)(2906002)(446003)(478600001)(4326008)(76176011)(6486002)(7736002)(305945005)(54906003)(8936002)(110136005)(7416002)(6116002)(99286004)(476003)(316002)(8676002)(107886003)(81156014)(486006)(256004)(50226002)(921003)(1121003);DIR:OUT;SFP:1102;SCL:1;SRVR:BYAPR01MB5557;H:BYAPR01MB4085.prod.exchangelabs.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:0;
received-spf: None (protection.outlook.com: os.amperecomputing.com does not
 designate permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 L/8qjgkjroZ4Y9kYzJhXFihMxdIQJ2dAIy2Gdh3Ev8QQUx4j7mI+megk/B0mNCOeECpsTmH/FE4qvcPGr6D8LNSEJz3aA8SgHc2k7ChVUDIccI/VmWZ9iW/Px52xGajn0uss0BTbWRWnGL4ryxxpDtoHegY2B0F7xkkJp4/9ygiB4pBXeGdx7i+N55tKQodwy6XsQ2GIawBuOK3LVLKsYc53Qb0+zKsP44UyEvZKlL6JxiUZJlY/lFHGL2XY+ofA0iTz3NDs8lu7epwxwZ1L+yL/kPzr6FhqyDuyHIb7AmRcAl14KPRGEijQNpD59EFzYJP8AgCOVbVBzzg7wqDoR0uhg/eZqqzqx+HVRcSlq3JcIgd9UHS0vXO2pGkYMG379ONHcLrVA8RsY30ctrkASOdkY7OUzwzk06FBY+fJ1d0=
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: os.amperecomputing.com
X-MS-Exchange-CrossTenant-Network-Message-Id: afb7b246-2fa9-41ed-0b23-08d7065719fd
X-MS-Exchange-CrossTenant-originalarrivaltime: 11 Jul 2019 23:25:46.9016
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

In NUMA layout which nodes have memory ranges that span across other nodes,
the mm driver can detect the memory node id incorrectly.

For example, with layout below
Node 0 address: 0000 xxxx 0000 xxxx
Node 1 address: xxxx 1111 xxxx 1111

Note:
 - Memory from low to high
 - 0/1: Node id
 - x: Invalid memory of a node

When mm probes the memory map, without CONFIG_NODES_SPAN_OTHER_NODES
config, mm only checks the memory validity but not the node id.
Because of that, Node 1 also detects the memory from node 0 as below
when it scans from the start address to the end address of node 1.

Node 0 address: 0000 xxxx xxxx xxxx
Node 1 address: xxxx 1111 1111 1111

This layout could occur on any architecture. This patch enables
CONFIG_NODES_SPAN_OTHER_NODES by default for NUMA to fix this issue.

Signed-off-by: Hoan Tran <Hoan@os.amperecomputing.com>
---
 mm/page_alloc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d66bc8a..6335505 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1413,7 +1413,7 @@ int __meminit early_pfn_to_nid(unsigned long pfn)
 }
 #endif
=20
-#ifdef CONFIG_NODES_SPAN_OTHER_NODES
+#ifdef CONFIG_NUMA
 /* Only safe to use early in boot when initialisation is single-threaded *=
/
 static inline bool __meminit early_pfn_in_nid(unsigned long pfn, int node)
 {
--=20
2.7.4

