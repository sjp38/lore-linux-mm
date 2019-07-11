Return-Path: <SRS0=bABq=VI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 739FBC742A2
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 23:25:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 28ECF21530
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 23:25:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=os.amperecomputing.com header.i=@os.amperecomputing.com header.b="dn+tbk6F"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 28ECF21530
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=os.amperecomputing.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C0F1D8E0105; Thu, 11 Jul 2019 19:25:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BE7798E00DB; Thu, 11 Jul 2019 19:25:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A12988E0105; Thu, 11 Jul 2019 19:25:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 77AFD8E00DB
	for <linux-mm@kvack.org>; Thu, 11 Jul 2019 19:25:56 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id h198so5369394qke.1
        for <linux-mm@kvack.org>; Thu, 11 Jul 2019 16:25:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-transfer-encoding:mime-version;
        bh=luzPCoCoJwdLxcuGKQo5XegVYEzzGjOGacJDRS1Q7fg=;
        b=cOhg5+abwYIquzGYht7PI0u56wltAsqomYk5+huO2jbtYV3fBkrDweDmotMBS4FtWV
         jsrvWPSy/ckA8b0mYNxscFeZ4AO0iOJmPWorwwzXQoCjzM9MhSEOx/DICOgijRV32NEY
         LYiU8LQRJrRrIRyYBa+2NkteY0fJj54+ePAukwuqDsFGllOfb63T9GPtSzymZnk5p0lu
         kF7YN3ecWbkehTfGbKfJyZ321Dq6H7TK3YAl5myFD5431PObeM38UK8Hpj5bHP+BKIbw
         zrxZDeln3JgH/SuKWruo5LifKHJbsWPERkSgDE0VxkOdehUIQCwDodFh5rjRDyEp9Cdn
         tdyQ==
X-Gm-Message-State: APjAAAV2mXeTUzhqwsy5n+6uI7gqaceLHxpmTVVV8MvxQ3rf6NKrzRvd
	BqT0bKGdQypL3gQTdMIfB05cWLtefS1YX19qw4whwml9X4fTdZb+SgUnP1AHISLbOQWpglzCnlN
	pizMrqcJU0x46Mt5dnratK6Qsa5M7ldoxcxptTB8EhjxbTjUloV8n+08mEtWdziDsZg==
X-Received: by 2002:ad4:4985:: with SMTP id t5mr3894597qvx.193.1562887556286;
        Thu, 11 Jul 2019 16:25:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwJGTQuGmNyo3c5/ELMIBkhvfuMqDMtXUpfNfKwCJ778fmBwzNM2w1C3wS/Lf2MmVaUr19h
X-Received: by 2002:ad4:4985:: with SMTP id t5mr3894574qvx.193.1562887555593;
        Thu, 11 Jul 2019 16:25:55 -0700 (PDT)
ARC-Seal: i=2; a=rsa-sha256; t=1562887555; cv=pass;
        d=google.com; s=arc-20160816;
        b=L2eGjh6WeEKqaM8nC/fRSmVWy7wHZrOqtlEvj4+EkKf/fb0RHtJsHTV3wZ2h1XXAXb
         7NF/mjzuvHXAf+OofA27z62bWTk9m94jds9qZuCiha3rghcvDJxuFUJqVfnp1Ysh9/F1
         IT2NW2kQAgRHJ/IvCsKghW087TP0Hzr+jizSB+G+X2Z3uNM9OMoLeEWAd+D+e0zESARm
         DwxbaF2+n8JWPJtLqqJu5H8vem/znLXaGdFE4CeALAKVNoFW+HAlvDilhVXkp0n0D+kN
         dXdA+QNhAusH9fmmH3Z4JCbtcxyUv+TdQVvoNjl99t/u4DWlwazpB+XqYRTZzRuIwhlC
         KBSQ==
ARC-Message-Signature: i=2; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=luzPCoCoJwdLxcuGKQo5XegVYEzzGjOGacJDRS1Q7fg=;
        b=fOjPUz8Yl2qxznXqVEcZJQnt/5zu6L40D/op0G1NJslbK1NxWNANvxxRlCT2mx4GuS
         Zqi41vALIu8jitY3+h0Mu8KnVCcm6UneJIF/fkOsmmLVvSaOk7ycSMfc/5JemynYf8Eg
         oJQAS0gXockoCTYdfIq5e5+YlXwU5gLG5tIeZd+7qHqW4qt4QcxK/hNFX/hmKcMfnCej
         k9Uo5XuPv53nPPkZ8P1iAzH14hACMWDYp25pB9C3maay4ZmksL6BUgHEIzgLxEydjOXV
         EnDOEExwjwMJOAmc6h6eznpZpPSHpVnZfiXWt+zqI0hvyGlSef/0c2NcXRXm7qrGLuxe
         3PSA==
ARC-Authentication-Results: i=2; mx.google.com;
       dkim=pass header.i=@os.amperecomputing.com header.s=selector1 header.b=dn+tbk6F;
       arc=pass (i=1 spf=pass spfdomain=os.amperecomputing.com dkim=pass dkdomain=os.amperecomputing.com dmarc=pass fromdomain=os.amperecomputing.com);
       spf=pass (google.com: domain of hoan@os.amperecomputing.com designates 40.107.74.97 as permitted sender) smtp.mailfrom=hoan@os.amperecomputing.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=amperecomputing.com
Received: from NAM01-BN3-obe.outbound.protection.outlook.com (mail-eopbgr740097.outbound.protection.outlook.com. [40.107.74.97])
        by mx.google.com with ESMTPS id d26si4295900qvd.200.2019.07.11.16.25.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 11 Jul 2019 16:25:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of hoan@os.amperecomputing.com designates 40.107.74.97 as permitted sender) client-ip=40.107.74.97;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@os.amperecomputing.com header.s=selector1 header.b=dn+tbk6F;
       arc=pass (i=1 spf=pass spfdomain=os.amperecomputing.com dkim=pass dkdomain=os.amperecomputing.com dmarc=pass fromdomain=os.amperecomputing.com);
       spf=pass (google.com: domain of hoan@os.amperecomputing.com designates 40.107.74.97 as permitted sender) smtp.mailfrom=hoan@os.amperecomputing.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=amperecomputing.com
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=H72uxq60xQjxq2IdSa5bZbSJObgIQOUna8KyrK3a2PMGAZ1lJLmU32kEKLmRvjZ6BcCA4oK7BV949voioNbrWkvbb7TDmnFfeWV3y8QHqafn5x5rLSFwxenyayi55+s4Te+Ul7VhLeWvTt4CV79H99YDEJiCASYID8znWvw9MwUHhw5sxU0F8CjmNVLTBingo63tqf+3WWJ+38i0EXzjZMIEZEk9nouzGVGVzDTwH9F6nRRj4/8QM+fldBJZoNJ9bN+fGY5stdFreNgu5g4eXjHoCJ1OWQLTtwl+FMBIW/KViaigVPirxx5k54tXrtrDIaSW1pMpVQ4ARsSfQT7lJw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=luzPCoCoJwdLxcuGKQo5XegVYEzzGjOGacJDRS1Q7fg=;
 b=IsdKFaKC5ln+tGjwimrm2xPSfegyQBUmjFsQHuhSImRzU+HgpJBzsqAAc8AzK05yVtPKPQcTKkwvOCja3uX25sVUnrw4okt5TonONdPyC67P0Rh99vBfDvDVJkUKe2jtCAYinmlJxuCw0TWFBUckMSmLrQCKqErsc//1YDRhLo3E7X5+dWmfEHv1Ghp9YfPZrA/FvJr/9osjhhPhtiltv5/1sxoGDWILhMtidlMfqW8SYDiO0xfi9JKvMl5JpVasr2DfSeoxmKUBYNw3CSWc/ZvOK5j7zAAI/kh68m8+1HS2MkUpVjfYzd9MvrKDFngmXHWNcr31jnmEVUhk7yxwDg==
ARC-Authentication-Results: i=1; mx.microsoft.com 1;spf=pass
 smtp.mailfrom=os.amperecomputing.com;dmarc=pass action=none
 header.from=os.amperecomputing.com;dkim=pass
 header.d=os.amperecomputing.com;arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=os.amperecomputing.com; s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=luzPCoCoJwdLxcuGKQo5XegVYEzzGjOGacJDRS1Q7fg=;
 b=dn+tbk6FURLivSfjybA3IHPzwg3paVCzK+/WVoZI8ByeAWsuyNB5l/lO3aVA+VTxTpem8yUY/WaHp0DyUggUanfFd5WRz2Vxm3lXyjPXUlD/a6NECF/JJKpH8n/GgSo7CTdCLCxj5cVr+BKKtaOA4Q/iQVW30E3cB5voDv62JVE=
Received: from BYAPR01MB4085.prod.exchangelabs.com (52.135.237.22) by
 BYAPR01MB5557.prod.exchangelabs.com (20.179.88.205) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2073.10; Thu, 11 Jul 2019 23:25:54 +0000
Received: from BYAPR01MB4085.prod.exchangelabs.com
 ([fe80::9dbb:1b4c:bace:ef80]) by BYAPR01MB4085.prod.exchangelabs.com
 ([fe80::9dbb:1b4c:bace:ef80%7]) with mapi id 15.20.2052.020; Thu, 11 Jul 2019
 23:25:54 +0000
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
Subject: [PATCH v2 4/5] sparc: Kconfig: Remove CONFIG_NODES_SPAN_OTHER_NODES
Thread-Topic: [PATCH v2 4/5] sparc: Kconfig: Remove
 CONFIG_NODES_SPAN_OTHER_NODES
Thread-Index: AQHVOD/8WEih1KGuo0+kPmIjHrQcVQ==
Date: Thu, 11 Jul 2019 23:25:54 +0000
Message-ID: <1562887528-5896-5-git-send-email-Hoan@os.amperecomputing.com>
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
x-ms-office365-filtering-correlation-id: 77216daf-75a9-4c89-f972-08d706571e5e
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:BYAPR01MB5557;
x-ms-traffictypediagnostic: BYAPR01MB5557:
x-microsoft-antispam-prvs:
 <BYAPR01MB555745D520353EADC00AB9FEF1F30@BYAPR01MB5557.prod.exchangelabs.com>
x-ms-oob-tlc-oobclassifiers: OLM:6790;
x-forefront-prvs: 0095BCF226
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10019020)(4636009)(346002)(376002)(39840400004)(136003)(396003)(366004)(189003)(199004)(52116002)(66476007)(66556008)(66946007)(64756008)(66446008)(14454004)(5660300002)(1511001)(6506007)(386003)(71190400001)(71200400001)(6436002)(53936002)(66066001)(4744005)(102836004)(25786009)(68736007)(6512007)(86362001)(3846002)(11346002)(2616005)(186003)(81166006)(26005)(2906002)(446003)(478600001)(4326008)(76176011)(6486002)(7736002)(305945005)(54906003)(8936002)(110136005)(7416002)(6116002)(99286004)(476003)(316002)(8676002)(107886003)(81156014)(486006)(256004)(50226002)(921003)(1121003);DIR:OUT;SFP:1102;SCL:1;SRVR:BYAPR01MB5557;H:BYAPR01MB4085.prod.exchangelabs.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:0;
received-spf: None (protection.outlook.com: os.amperecomputing.com does not
 designate permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 0nwmbw+iMbUDY/4qjNSaddHS50JkaRduORIoyilAFYbU08UhPt0cW0WCLUK9BK3fRcrt+svD6MI5ooWlKMuuMtAc13hvSW8UGY7tVikY4IQNXtUFtWG0/HsV/ckhfo1pipvvd5s3pVUZbVq9uPZXT5R2hDyK3uqdB1+F2xwKKOO6xWP5xKhhiOLEwFeaTDVHF6MCtLR3jDzu0bVPC1vYzsecWDX68xTaFJtaDs5TCtQB0AVSCqI18bkaZGbEndNxBCs7dCu1QjqKmvIqPTYy3apuQyEbCjDQ5ZjiNXLHsR8qWS0sqTg+ZEh9ZTR2YyKFAjsRh5k+5xnVxBH96pI81XAUkJV0ZhuI6CGCfT8HtgEOyzj3Fzjew01+1PmcbO+KSn9DgLNSBfY7rJX41s4TXm7D93y3yO6lhVq1Gjuhdbs=
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: os.amperecomputing.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 77216daf-75a9-4c89-f972-08d706571e5e
X-MS-Exchange-CrossTenant-originalarrivaltime: 11 Jul 2019 23:25:54.1124
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
 arch/sparc/Kconfig | 9 ---------
 1 file changed, 9 deletions(-)

diff --git a/arch/sparc/Kconfig b/arch/sparc/Kconfig
index 26ab6f5..13449ea 100644
--- a/arch/sparc/Kconfig
+++ b/arch/sparc/Kconfig
@@ -291,15 +291,6 @@ config NODES_SHIFT
 	  Specify the maximum number of NUMA Nodes available on the target
 	  system.  Increases memory reserved to accommodate various tables.
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
 config ARCH_SELECT_MEMORY_MODEL
 	def_bool y if SPARC64
=20
--=20
2.7.4

