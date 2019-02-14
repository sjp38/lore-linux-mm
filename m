Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1D03AC43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 00:02:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CE90F218FF
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 00:02:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="clQp5FLl"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CE90F218FF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8F4298E0004; Wed, 13 Feb 2019 19:02:40 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 62A088E0006; Wed, 13 Feb 2019 19:02:40 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3DEFC8E0004; Wed, 13 Feb 2019 19:02:40 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id E7C778E0005
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 19:02:39 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id k14so2928416pls.2
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 16:02:39 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:in-reply-to:references;
        bh=fEQ1MfpMn+jTbXDbToNZqpIPh0CEmp2s2jsy7mZAXXk=;
        b=G8vjkcFSKjmJjQOn96/hUgsiT2Xayw0kgpTEPJp6bneqIWlqhzt5tJnmSV3KnWj9+n
         EjPCjFf2nd1/qKiIzQhVeuqf0crF3bBk2+5hMQdqNwMQhSi18VzEDlWzNskqKsXG/Cvv
         fs43rFWow80mH13aGjsXKtEGROjcgzD2EGaOt4ygXUIIQs7ByjrlYOCNn6Irm0RCchCJ
         NMEf3OdJM334i7C8/hJSOInJxYgGkxXQmcFJwMflUcmUgSbeFwV+ICtmUguPWqkaYqUb
         8Za3pZat+4ZEEFTwj0b0ENDwD40Cb9hMfVF82znXuLPlzeYfd2jKwEpU7r2vHRl2SzwL
         OuvQ==
X-Gm-Message-State: AHQUAubOxE+6bJIKKWuzn2Hr4RcxYokVE9+h9vgiM0mCdwiMut7tOpRC
	kX+5d6PS397IS6PkYVMW0Hpl1udg7gU9e41Zp22bzOuCllaNx5xikViMcAe0mdR3FiPVR2izC9d
	qEKf5GaxSfSwsnxq2a6/mOZnqCT/EZy+o5xKIdlnVbs++jnHjn0FH8+5sGQHSE2KjCA==
X-Received: by 2002:a17:902:b681:: with SMTP id c1mr918263pls.103.1550102559612;
        Wed, 13 Feb 2019 16:02:39 -0800 (PST)
X-Google-Smtp-Source: AHgI3Iaf9gP2BsDXa7ks5ZEdGW5tGInj9eV41nTlhgFUlHdAkT5Opm6wv2MtP2uT2CI+CUWdiCrl
X-Received: by 2002:a17:902:b681:: with SMTP id c1mr918169pls.103.1550102558692;
        Wed, 13 Feb 2019 16:02:38 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550102558; cv=none;
        d=google.com; s=arc-20160816;
        b=XIvDZ2NKhD5vFLUeBTKQfMSWDu70eHEhDVxNv+/+IduDovcHgVkU+U83ltNPI/ZxEr
         kFsJ5uRdkRLIlpJE1bXt/fXXJBa0Q9bdX+G4GKxBKdMhX8S7EADz7x6moKX8k//dfWSB
         XbXORRbugiqdYMX64Q3Fvvc69ETDtUSdZMx/NCsnd9mEmKvhC0Y2u8sEzyk4hTADRkjI
         Ug0+RvtjUCxYDp8PNqwEzYK61xq61I2UCDHfzFI0VXYE5mjj0F/UqYWu2iR0J3Vli23i
         GDQYuiSaN+qiZ19aAozkTeoeJzpugzr0N30Qc/KmRCZAuSSsBQB9UAHW39JJ5xxwY7CR
         GYYQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:references:in-reply-to:message-id:date
         :subject:cc:to:from:dkim-signature;
        bh=fEQ1MfpMn+jTbXDbToNZqpIPh0CEmp2s2jsy7mZAXXk=;
        b=DcQb/bVcsLuwZvX0wkUetTTRYI1/9eg6w+npanppYUcdpy8icCgrHHw6OZ2H8TmksY
         wILUqvEPXshhluQ3h1regS+dkfB5WGuZ4d9NNR7NJdSOxk0vFC0jtK+n7R1dmtuDxhS8
         V3OkudAjUaclGjKDI/SzPcWIV3OYcXTlLax+S6r8jFn/4CT+yi5PofIs5c9kQS1brb3Z
         YMroR51pvZydPK4VuJQjP1oFuICTOLFpmvdiSZVJE5WlsVxQC5RitEF4mKCg57FAMfa5
         bnRdTllN8s6E3h2M1Ic4njGBXEx34vr33GrUJN0PpyEVcOCOz4cZddiXiqw7x+yPLVdY
         wnEA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=clQp5FLl;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id l123si737718pfc.187.2019.02.13.16.02.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Feb 2019 16:02:38 -0800 (PST)
Received-SPF: pass (google.com: domain of khalid.aziz@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=clQp5FLl;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x1DNxBx3100713;
	Thu, 14 Feb 2019 00:02:18 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references : in-reply-to :
 references; s=corp-2018-07-02;
 bh=fEQ1MfpMn+jTbXDbToNZqpIPh0CEmp2s2jsy7mZAXXk=;
 b=clQp5FLlv6dBK7nLgBvO7z0XrNUeRlDkeSjrUlTYTSJbuNRLfOKl0R1BT5sDq21QFYX8
 pSz8w5lOqXzP3bUCNpXzkHLjNtdbGgLEsSSt8Eua3YWbfcZEEcQkzBiGSUl4yar1bvHp
 q8fCHDNP/V5TBUNkjrEFGj4gq1sOoXWLJD0C9kdSdRCeEl+8pLBspnYCQCdJcqUzk5J3
 M9AXZQEMVtI8t9Hvrz9GDsGdYXEpQKo1Pp1JwtMth2sBZOvx6EWbBElqk6cR1/ggkzPa
 cINSZoMWJK2sX83UednZi/f2IJhDrqSJBRYcN3DKtOMSwLUXe+sR+ATtY0MHyLaEGXWX Aw== 
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
	by aserp2130.oracle.com with ESMTP id 2qhre5n3v6-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 14 Feb 2019 00:02:17 +0000
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x1E02CAr025949
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 14 Feb 2019 00:02:12 GMT
Received: from abhmp0003.oracle.com (abhmp0003.oracle.com [141.146.116.9])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x1E02C7V001627;
	Thu, 14 Feb 2019 00:02:12 GMT
Received: from concerto.internal (/24.9.64.241)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 13 Feb 2019 16:02:11 -0800
From: Khalid Aziz <khalid.aziz@oracle.com>
To: juergh@gmail.com, tycho@tycho.ws, jsteckli@amazon.de, ak@linux.intel.com,
        torvalds@linux-foundation.org, liran.alon@oracle.com,
        keescook@google.com, akpm@linux-foundation.org, mhocko@suse.com,
        catalin.marinas@arm.com, will.deacon@arm.com, jmorris@namei.org,
        konrad.wilk@oracle.com
Cc: Juerg Haefliger <juerg.haefliger@canonical.com>,
        deepa.srinivasan@oracle.com, chris.hyser@oracle.com,
        tyhicks@canonical.com, dwmw@amazon.co.uk, andrew.cooper3@citrix.com,
        jcm@redhat.com, boris.ostrovsky@oracle.com, kanth.ghatraju@oracle.com,
        oao.m.martins@oracle.com, jmattson@google.com,
        pradeep.vincent@oracle.com, john.haxby@oracle.com, tglx@linutronix.de,
        kirill.shutemov@linux.intel.com, hch@lst.de, steven.sistare@oracle.com,
        labbott@redhat.com, luto@kernel.org, dave.hansen@intel.com,
        peterz@infradead.org, kernel-hardening@lists.openwall.com,
        linux-mm@kvack.org, x86@kernel.org,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
        Tycho Andersen <tycho@docker.com>
Subject: [RFC PATCH v8 07/14] arm64/mm, xpfo: temporarily map dcache regions
Date: Wed, 13 Feb 2019 17:01:30 -0700
Message-Id: <ea50404604bdbe1547601b6ea0af89e3da8886b0.1550088114.git.khalid.aziz@oracle.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <cover.1550088114.git.khalid.aziz@oracle.com>
References: <cover.1550088114.git.khalid.aziz@oracle.com>
In-Reply-To: <cover.1550088114.git.khalid.aziz@oracle.com>
References: <cover.1550088114.git.khalid.aziz@oracle.com>
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9166 signatures=668683
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=559 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1902130157
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Juerg Haefliger <juerg.haefliger@canonical.com>

If the page is unmapped by XPFO, a data cache flush results in a fatal
page fault, so let's temporarily map the region, flush the cache, and then
unmap it.

v6: actually flush in the face of xpfo, and temporarily map the underlying
    memory so it can be flushed correctly

CC: linux-arm-kernel@lists.infradead.org
Signed-off-by: Juerg Haefliger <juerg.haefliger@canonical.com>
Signed-off-by: Tycho Andersen <tycho@docker.com>
---
 arch/arm64/mm/flush.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/arch/arm64/mm/flush.c b/arch/arm64/mm/flush.c
index 30695a868107..fad09aafd9d5 100644
--- a/arch/arm64/mm/flush.c
+++ b/arch/arm64/mm/flush.c
@@ -20,6 +20,7 @@
 #include <linux/export.h>
 #include <linux/mm.h>
 #include <linux/pagemap.h>
+#include <linux/xpfo.h>
 
 #include <asm/cacheflush.h>
 #include <asm/cache.h>
@@ -28,9 +29,15 @@
 void sync_icache_aliases(void *kaddr, unsigned long len)
 {
 	unsigned long addr = (unsigned long)kaddr;
+	unsigned long num_pages = XPFO_NUM_PAGES(addr, len);
+	void *mapping[num_pages];
 
 	if (icache_is_aliasing()) {
+		xpfo_temp_map(kaddr, len, mapping,
+			      sizeof(mapping[0]) * num_pages);
 		__clean_dcache_area_pou(kaddr, len);
+		xpfo_temp_unmap(kaddr, len, mapping,
+				sizeof(mapping[0]) * num_pages);
 		__flush_icache_all();
 	} else {
 		flush_icache_range(addr, addr + len);
-- 
2.17.1

