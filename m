Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5B5FAC10F06
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 17:37:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0CD50206DF
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 17:37:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="wc9JzFG9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0CD50206DF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A11856B0272; Wed,  3 Apr 2019 13:37:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8D39C6B0274; Wed,  3 Apr 2019 13:37:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 79AEE6B0275; Wed,  3 Apr 2019 13:37:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 549736B0272
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 13:37:08 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id v123so12740086ywf.16
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 10:37:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:in-reply-to:references;
        bh=yCxbmCAk84npxguylmi/HxVQRuHK/tYnw0TSzCvTIZY=;
        b=oTzkhXA4wIFoLOl0WAa854VZ2Ojl9JA/eXr4mH1CdmhmknE0TJWFBk36X4mHiaCywt
         w5Uxjrxuq2wYyfCgXMDxQS6lyGZbcsbzCyq4I4ogp89w3ytw5DoT+0Lah36hIYqkrWAt
         7FK7pM/e+0AveYtM3TjsdD2tD/9zzg0wZMzftynfmSYQx0fJuxa0uzcFgfH/dph30dpV
         4rimgKNFrCDqcrU2V9PdKwOWjXAnFb49yWtfzlSsscSyMh67gdfBh5d2fPWeBd57LA+3
         ns1UQIe00uJj/AqGRLuKw4wgP3hiIiMB+uIlSyU/JZkbkcw37TDV3g+Kq8eBpFzslpZw
         wohg==
X-Gm-Message-State: APjAAAUxthvfePhnplrYKc+un6Pu/1p+R6pbt6IzIYAJfA+L2kStJWt+
	UmgfrUDNrSYLPGaxnVkaehc9ZqS6L97AAy4sVSKN/q3M5NtaltTszI2Q8QYl2+5lN0mUzUiK/Dw
	5e/mE/3yBTygRx8HB8e9ell2pRyzL/ljMU+uJ7fVtEUamOUM07Svmh1rCEu1V8T9fkw==
X-Received: by 2002:a5b:749:: with SMTP id s9mr1096043ybq.447.1554313028106;
        Wed, 03 Apr 2019 10:37:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxNa/V9tIbvDxIHJJHY2r/ImVa526f11RJKEg9XJxHBp8tD42q9h2Y+Sm8SdTEVLy6fh0Z+
X-Received: by 2002:a5b:749:: with SMTP id s9mr1095986ybq.447.1554313027480;
        Wed, 03 Apr 2019 10:37:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554313027; cv=none;
        d=google.com; s=arc-20160816;
        b=A5ducJaG33101aAVBOVLXx5BAEUzgjAgsBTRnjglw92Xl+e/JErKLbe67LWF8Tc4iW
         ssk0GavHEngt6d1lgkIBdyyAKT5wb1qWkwKlKl804yFe4ZckwmooePxVmZ/i42wGRhcI
         LEJJ7m6CEIbWS5z3sBK3zZYhW1ZWiDmyRESgW1UydzekDRwB040T+w19nmDUd7k8i+hf
         PBwNwEWwBbEBmUuA3WNwAhIkASBmAAgtT8s0WRbeIwy0Ppcntp5jqjma46o8kAg1o6ct
         RImW/19IwXFwatgztKu1CIgI9Ox1kNxxsaWbY+Frq1l/m8wcU5q7o4mgz5Lkw6Z73B7x
         9H2w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:references:in-reply-to:message-id:date
         :subject:cc:to:from:dkim-signature;
        bh=yCxbmCAk84npxguylmi/HxVQRuHK/tYnw0TSzCvTIZY=;
        b=DG8DwhRhB4WEEjxPrxLRaKvGXO7l6grPjeyUFKBvvSz4dJ5B53hLfJqn8Chdx1l+bm
         /Hq6pqpGwjdySYsmms2JAYwKXF1h8Qla6/utYW9wKqQCj7+RnglWCQyRNYXp5xup3TC2
         i4R4Gu7xsIPhZhzSm1aVKxhFy5N+6PSTYzWJghqqi199jHPTs2RjMFUlWd5LeVjLM9gL
         +yQQb2ogFSFcMrvEMdLTw68rzKWPWg/EiZJLZzdl4SV0400p8WTVvPRMwCnO7mgmrOG3
         O5oNXxyQNvkheoZTKIsPavHcrH0GFHRfxCLgrJHFpoTIkIi9ReLYHsSvutZ0p+440WcH
         bXMg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=wc9JzFG9;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id x6si10251855ybh.421.2019.04.03.10.37.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Apr 2019 10:37:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=wc9JzFG9;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x33HNrjN175419;
	Wed, 3 Apr 2019 17:35:59 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references : in-reply-to :
 references; s=corp-2018-07-02;
 bh=yCxbmCAk84npxguylmi/HxVQRuHK/tYnw0TSzCvTIZY=;
 b=wc9JzFG90PcUo+AelC4KcKG0r3iYRO2KFvdJ4lxbZLAoAhrjwfOVTW4YISk+OFJrMJSn
 xCnuRpQAaoF5KYp30BDf3TJ1n5/4tQimwJRke+2FDLR3tzhS4CjfvjCJLu7BPeOV/jhE
 gKNTeenIeXXzPUxNFzKXOgdEHykEmIxny4FS+gcQOJFAjpb1MTF2x4bFF1KrE/GygqTZ
 4fgtCo38B5aZz2/GDLPcQJHkb3zcSavurvW/+llRfTh+QZcSVxzr8xTYj1kU5BwlfG4T
 UWQa1LTfAn7tqRYUaIijkpGNwDoo9gPVXXl8vdAt7TrPsE3s5+A9xrFm4V5/VPoVXVXo HA== 
Received: from userp3030.oracle.com (userp3030.oracle.com [156.151.31.80])
	by userp2120.oracle.com with ESMTP id 2rj13qae82-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 03 Apr 2019 17:35:58 +0000
Received: from pps.filterd (userp3030.oracle.com [127.0.0.1])
	by userp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x33HYDKs081810;
	Wed, 3 Apr 2019 17:35:58 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by userp3030.oracle.com with ESMTP id 2rm8f57ysj-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 03 Apr 2019 17:35:58 +0000
Received: from abhmp0005.oracle.com (abhmp0005.oracle.com [141.146.116.11])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x33HZru2001521;
	Wed, 3 Apr 2019 17:35:53 GMT
Received: from concerto.internal (/10.65.181.37)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 03 Apr 2019 10:35:53 -0700
From: Khalid Aziz <khalid.aziz@oracle.com>
To: juergh@gmail.com, tycho@tycho.ws, jsteckli@amazon.de, ak@linux.intel.com,
        liran.alon@oracle.com, keescook@google.com, konrad.wilk@oracle.com
Cc: Juerg Haefliger <juerg.haefliger@canonical.com>,
        deepa.srinivasan@oracle.com, chris.hyser@oracle.com,
        tyhicks@canonical.com, dwmw@amazon.co.uk, andrew.cooper3@citrix.com,
        jcm@redhat.com, boris.ostrovsky@oracle.com, kanth.ghatraju@oracle.com,
        joao.m.martins@oracle.com, jmattson@google.com,
        pradeep.vincent@oracle.com, john.haxby@oracle.com, tglx@linutronix.de,
        kirill.shutemov@linux.intel.com, hch@lst.de, steven.sistare@oracle.com,
        labbott@redhat.com, luto@kernel.org, dave.hansen@intel.com,
        peterz@infradead.org, aaron.lu@intel.com, akpm@linux-foundation.org,
        alexander.h.duyck@linux.intel.com, amir73il@gmail.com,
        andreyknvl@google.com, aneesh.kumar@linux.ibm.com,
        anthony.yznaga@oracle.com, ard.biesheuvel@linaro.org, arnd@arndb.de,
        arunks@codeaurora.org, ben@decadent.org.uk, bigeasy@linutronix.de,
        bp@alien8.de, brgl@bgdev.pl, catalin.marinas@arm.com, corbet@lwn.net,
        cpandya@codeaurora.org, daniel.vetter@ffwll.ch,
        dan.j.williams@intel.com, gregkh@linuxfoundation.org, guro@fb.com,
        hannes@cmpxchg.org, hpa@zytor.com, iamjoonsoo.kim@lge.com,
        james.morse@arm.com, jannh@google.com, jgross@suse.com,
        jkosina@suse.cz, jmorris@namei.org, joe@perches.com,
        jrdr.linux@gmail.com, jroedel@suse.de, keith.busch@intel.com,
        khalid.aziz@oracle.com, khlebnikov@yandex-team.ru, logang@deltatee.com,
        marco.antonio.780@gmail.com, mark.rutland@arm.com,
        mgorman@techsingularity.net, mhocko@suse.com, mhocko@suse.cz,
        mike.kravetz@oracle.com, mingo@redhat.com, mst@redhat.com,
        m.szyprowski@samsung.com, npiggin@gmail.com, osalvador@suse.de,
        paulmck@linux.vnet.ibm.com, pavel.tatashin@microsoft.com,
        rdunlap@infradead.org, richard.weiyang@gmail.com, riel@surriel.com,
        rientjes@google.com, robin.murphy@arm.com, rostedt@goodmis.org,
        rppt@linux.vnet.ibm.com, sai.praneeth.prakhya@intel.com,
        serge@hallyn.com, steve.capper@arm.com, thymovanbeers@gmail.com,
        vbabka@suse.cz, will.deacon@arm.com, willy@infradead.org,
        yang.shi@linux.alibaba.com, yaojun8558363@gmail.com,
        ying.huang@intel.com, zhangshaokun@hisilicon.com,
        iommu@lists.linux-foundation.org, x86@kernel.org,
        linux-arm-kernel@lists.infradead.org, linux-doc@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-mm@kvack.org,
        linux-security-module@vger.kernel.org,
        Khalid Aziz <khalid@gonehiking.org>
Subject: [RFC PATCH v9 08/13] swiotlb: Map the buffer if it was unmapped by XPFO
Date: Wed,  3 Apr 2019 11:34:09 -0600
Message-Id: <f535a9c158203395f1adae810d92afe0254ce253.1554248002.git.khalid.aziz@oracle.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <cover.1554248001.git.khalid.aziz@oracle.com>
References: <cover.1554248001.git.khalid.aziz@oracle.com>
In-Reply-To: <cover.1554248001.git.khalid.aziz@oracle.com>
References: <cover.1554248001.git.khalid.aziz@oracle.com>
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9216 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1904030118
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9216 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1904030118
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Juerg Haefliger <juerg.haefliger@canonical.com>

XPFO can unmap a bounce buffer. Check for this and map it back in if
needed.

Signed-off-by: Juerg Haefliger <juerg.haefliger@canonical.com>
Signed-off-by: Tycho Andersen <tycho@tycho.ws>
Signed-off-by: Khalid Aziz <khalid.aziz@oracle.com>
Cc: Khalid Aziz <khalid@gonehiking.org>
Reviewed-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
---
v9: * Added a generic check for whether a page is mapped or not (suggested
      by Chris Hellwig)

v6: * guard against lookup_xpfo() returning NULL

 include/linux/highmem.h | 7 +++++++
 kernel/dma/swiotlb.c    | 3 ++-
 2 files changed, 9 insertions(+), 1 deletion(-)

diff --git a/include/linux/highmem.h b/include/linux/highmem.h
index 59a1a5fa598d..cf21f023dff4 100644
--- a/include/linux/highmem.h
+++ b/include/linux/highmem.h
@@ -77,6 +77,13 @@ static inline struct page *kmap_to_page(void *addr)
 }
 
 static inline unsigned long totalhigh_pages(void) { return 0UL; }
+static inline bool page_is_unmapped(struct page *page)
+{
+	if (PageHighMem(page) || PageXpfoUnmapped(page))
+		return true;
+	else
+		return false;
+}
 
 #endif /* CONFIG_HIGHMEM */
 
diff --git a/kernel/dma/swiotlb.c b/kernel/dma/swiotlb.c
index 1fb6fd68b9c7..90a1a3709b55 100644
--- a/kernel/dma/swiotlb.c
+++ b/kernel/dma/swiotlb.c
@@ -392,8 +392,9 @@ static void swiotlb_bounce(phys_addr_t orig_addr, phys_addr_t tlb_addr,
 {
 	unsigned long pfn = PFN_DOWN(orig_addr);
 	unsigned char *vaddr = phys_to_virt(tlb_addr);
+	struct page *page = pfn_to_page(pfn);
 
-	if (PageHighMem(pfn_to_page(pfn))) {
+	if (page_is_unmapped(page)) {
 		/* The buffer does not have a mapping.  Map it in and copy */
 		unsigned int offset = orig_addr & ~PAGE_MASK;
 		char *buffer;
-- 
2.17.1

