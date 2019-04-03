Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DDA4BC4360F
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 17:37:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 82741206DF
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 17:37:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="FCi26eH2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 82741206DF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5A6176B0276; Wed,  3 Apr 2019 13:37:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 505FA6B0277; Wed,  3 Apr 2019 13:37:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 309F96B0278; Wed,  3 Apr 2019 13:37:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0E9CA6B0276
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 13:37:16 -0400 (EDT)
Received: by mail-it1-f198.google.com with SMTP id l202so6883713ita.1
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 10:37:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:in-reply-to:references;
        bh=RQ6cfPE1oUdZhXOBb8lEKxLwdCK2MCPnapeo9zEXamM=;
        b=aJQsEpOfkVY+A/hdppfB0DGL7nh4JKqXbWWaToknOoEB4vKXD2FIvGZU5+A2aF+WKI
         lEOkb2D8jXaaNqgYDzCTRBeG4MAGqcHt3OoDb3CkzzdzB1bFb4ouZjw7/s+yT8kx22u0
         wZS7mXXOHj4ZoEnUo3S7/H5O3KkZuAFKbXXWlRMB5im1sFbhTQyIal3XZIEKJMo+dJew
         aI7XVVLmsUllrN042RziVNJaHzG3KEYQuwLFbubO13pI4k2jlgxTHLoiCtzx2PXyK+i7
         S2iUTAcWn4s6S2ayXzAe0QcKkZwLXYZV22QF/7beNIcxgc/nxNV6AiC/W3ELVcVtpghv
         s3ZA==
X-Gm-Message-State: APjAAAU0ysgVvD0C/3p0VLdyPH7eSv+PYrJi8/C9BN4UsiaZKIkMkXgH
	ycWY1QI+yt+I4ImvBwumLL8HXyvCwNEZChYNDbRjgCAjmp/mARMbGI6J9+4iMJNWTpbWuBgtZGb
	7NSLDezBsdyaBvR6WlF3waJSBoYiO5zKLsgq4NzS3hCWZB/ZAd+97fTeD65B8Qdd0Qw==
X-Received: by 2002:a24:1f44:: with SMTP id d65mr1192066itd.65.1554313035715;
        Wed, 03 Apr 2019 10:37:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw3whXah+n+2st+DgWOal1BDt2OlpI3DyaFa4P1Tz0pqfQZWivSTsrN4PwNb6su/Uvybvaf
X-Received: by 2002:a24:1f44:: with SMTP id d65mr1191992itd.65.1554313034778;
        Wed, 03 Apr 2019 10:37:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554313034; cv=none;
        d=google.com; s=arc-20160816;
        b=XT+IO/OCkZ6Y5YG5aqOsgaESNLtafQdahEDTLf99PHYGI6XCxI5qLKldFMulc50XQh
         Jow3NGKcnjhByCuc1IoAG1vRGVSnrthaBm7ToqGnou8ivjz16Iv0W/tkgbCeZhvCYPfh
         Hnwet+UQ5/GM6ZJWKTVh99idf+OL1EXTV/0FXDuaRl4nk4xhirp3ud2TuLNUFkeKTPKt
         eQHIygUPrynwgWj/NReLl6kQoxogUqqAWazRKWGKrPkgTWuXx5CO7w9eFe/6iFh/CkQw
         urOSNNXATAa+Qus5YQuHIrSstDF8saJrl1UWUUIxzcdZP3YrwRS9/P3k9U16JjAgibeX
         lJCg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:references:in-reply-to:message-id:date
         :subject:cc:to:from:dkim-signature;
        bh=RQ6cfPE1oUdZhXOBb8lEKxLwdCK2MCPnapeo9zEXamM=;
        b=WpzRp7q9F9wbdy5y0mum/sqsPx/rGk5abDl8gtdJzXlWAYgpLYaAxDHfNsuQZ2RW69
         hWq8A550F3fQpsVEUgbzpIMmEfrpdb4U7Z9PnSp/N4k7PjmdTuIuLRFiY07GrN5CXRn/
         2GpS8NeOjfJVxAcz2CGd3px1wVBIPY1CC6sAhZlE1fsjV/8py5ANd8rOrWEMoeAQDfAG
         W4CYUFHB6gbGtiXgPjWXcd/trPcoMPB//jpizqmmjJNhDYiKQZYr1Bo0CkhW3TJsBPiJ
         o+GXz5cG4zhqRWyFZFS6pO7BL+Onsos5pby6VLABf376O1DtWh/5XcJk1qu2psU133eA
         U3VQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=FCi26eH2;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id x30si3012408jap.57.2019.04.03.10.37.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Apr 2019 10:37:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=FCi26eH2;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x33HO4Be175776;
	Wed, 3 Apr 2019 17:36:15 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references : in-reply-to :
 references; s=corp-2018-07-02;
 bh=RQ6cfPE1oUdZhXOBb8lEKxLwdCK2MCPnapeo9zEXamM=;
 b=FCi26eH2yuIj/duNDQmSbddnHqKIgNwk5FitB/zF8l+pOrUfoRX+prFRbpqHu9Gr/3ss
 /IeG8UwqR1hfVmbLtEDQOcWMydXrIwj2ToNVug5qC2TokZppKngyobnDY6VBcytWlju/
 oghOni+CK13eoXN4LvOyT8p5rYzAopR3y2MzmG0ZokbUJRieoruWDXzmgm834RPzDZ0Z
 V6YURMu87c3OumnQbKDenDg00eEPn5Z2IV7lnjC3ZZb4z+7P5Ga4/1YizcEZKAsQL2Jq
 rlwWi8L/5Lw5w+WDr7wK1Pjj1zc6Lhid+jNfzqvpM10qAhdsz56CtubdeBhgq1tKGrJM Zg== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
	by userp2120.oracle.com with ESMTP id 2rj13qae9s-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 03 Apr 2019 17:36:14 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
	by aserp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x33HZIGU110875;
	Wed, 3 Apr 2019 17:36:13 GMT
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by aserp3030.oracle.com with ESMTP id 2rm8f5fynf-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 03 Apr 2019 17:36:13 +0000
Received: from abhmp0005.oracle.com (abhmp0005.oracle.com [141.146.116.11])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x33Ha78j001568;
	Wed, 3 Apr 2019 17:36:07 GMT
Received: from concerto.internal (/10.65.181.37)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 03 Apr 2019 10:36:06 -0700
From: Khalid Aziz <khalid.aziz@oracle.com>
To: juergh@gmail.com, tycho@tycho.ws, jsteckli@amazon.de, ak@linux.intel.com,
        liran.alon@oracle.com, keescook@google.com, konrad.wilk@oracle.com
Cc: deepa.srinivasan@oracle.com, chris.hyser@oracle.com, tyhicks@canonical.com,
        dwmw@amazon.co.uk, andrew.cooper3@citrix.com, jcm@redhat.com,
        boris.ostrovsky@oracle.com, kanth.ghatraju@oracle.com,
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
        Khalid Aziz <khalid@gonehiking.org>,
        kernel-hardening@lists.openwall.com,
        "Vasileios P . Kemerlis" <vpk@cs.columbia.edu>,
        Juerg Haefliger <juerg.haefliger@canonical.com>,
        David Woodhouse <dwmw2@infradead.org>
Subject: [RFC PATCH v9 11/13] xpfo, mm: optimize spinlock usage in xpfo_kunmap
Date: Wed,  3 Apr 2019 11:34:12 -0600
Message-Id: <5bab13e12d4215112ad2180106cc6bb9b513754a.1554248002.git.khalid.aziz@oracle.com>
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
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1904030118
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Julian Stecklina <jsteckli@amazon.de>

Only the xpfo_kunmap call that needs to actually unmap the page
needs to be serialized. We need to be careful to handle the case,
where after the atomic decrement of the mapcount, a xpfo_kmap
increased the mapcount again. In this case, we can safely skip
modifying the page table.

Model-checked with up to 4 concurrent callers with Spin.

Signed-off-by: Julian Stecklina <jsteckli@amazon.de>
Signed-off-by: Khalid Aziz <khalid.aziz@oracle.com>
Cc: Khalid Aziz <khalid@gonehiking.org>
Cc: x86@kernel.org
Cc: kernel-hardening@lists.openwall.com
Cc: Vasileios P. Kemerlis <vpk@cs.columbia.edu>
Cc: Juerg Haefliger <juerg.haefliger@canonical.com>
Cc: Tycho Andersen <tycho@tycho.ws>
Cc: Marco Benatto <marco.antonio.780@gmail.com>
Cc: David Woodhouse <dwmw2@infradead.org>
---
 include/linux/xpfo.h | 24 +++++++++++++++---------
 1 file changed, 15 insertions(+), 9 deletions(-)

diff --git a/include/linux/xpfo.h b/include/linux/xpfo.h
index 2318c7eb5fb7..37e7f52fa6ce 100644
--- a/include/linux/xpfo.h
+++ b/include/linux/xpfo.h
@@ -61,6 +61,7 @@ static inline void xpfo_kmap(void *kaddr, struct page *page)
 static inline void xpfo_kunmap(void *kaddr, struct page *page)
 {
 	unsigned long flags;
+	bool flush_tlb = false;
 
 	if (!static_branch_unlikely(&xpfo_inited))
 		return;
@@ -72,18 +73,23 @@ static inline void xpfo_kunmap(void *kaddr, struct page *page)
 	 * The page is to be allocated back to user space, so unmap it from
 	 * the kernel, flush the TLB and tag it as a user page.
 	 */
-	spin_lock_irqsave(&page->xpfo_lock, flags);
-
 	if (atomic_dec_return(&page->xpfo_mapcount) == 0) {
-#ifdef CONFIG_XPFO_DEBUG
-		WARN_ON(PageXpfoUnmapped(page));
-#endif
-		SetPageXpfoUnmapped(page);
-		set_kpte(kaddr, page, __pgprot(0));
-		xpfo_flush_kernel_tlb(page, 0);
+		spin_lock_irqsave(&page->xpfo_lock, flags);
+
+		/*
+		 * In the case, where we raced with kmap after the
+		 * atomic_dec_return, we must not nuke the mapping.
+		 */
+		if (atomic_read(&page->xpfo_mapcount) == 0) {
+			SetPageXpfoUnmapped(page);
+			set_kpte(kaddr, page, __pgprot(0));
+			flush_tlb = true;
+		}
+		spin_unlock_irqrestore(&page->xpfo_lock, flags);
 	}
 
-	spin_unlock_irqrestore(&page->xpfo_lock, flags);
+	if (flush_tlb)
+		xpfo_flush_kernel_tlb(page, 0);
 }
 
 void xpfo_alloc_pages(struct page *page, int order, gfp_t gfp, bool will_map);
-- 
2.17.1

