Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 86A5AC4360F
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 17:37:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2A447206DF
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 17:37:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="BaxcCITX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2A447206DF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 30A356B026D; Wed,  3 Apr 2019 13:37:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2BEC96B026F; Wed,  3 Apr 2019 13:37:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0E7036B0271; Wed,  3 Apr 2019 13:37:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id D94C86B026D
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 13:37:03 -0400 (EDT)
Received: by mail-yb1-f200.google.com with SMTP id h125so13149481ybh.4
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 10:37:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:in-reply-to:references;
        bh=ynty9flFqcPPDSeTkJifnT4Yutdn8/TkRysaHE6m4cE=;
        b=aqfAAr6Nx2l82KLyDdsXZjRxhnxK1j0wnB/GcR4v1hnYLanKXnPNwMg2It2h0Ey7L8
         LsPQgL31ivQeGpAUZeG2D6El9hnBsnBpaA+5a2RtxY7668K+SEzuvD/BkrTTAVTaJ5BZ
         EBMiURqpM03t0Trh2X/kVkR9SZZPVnNqJ1vivOUNJoEVuMAZanm4r0+Qh1XMXciWl24n
         ND+gVBREhtH/Lz/a9YJCCmvr3NlOqvo2erfzfKZm8t61msENT2C0cS7WbTMbs5OGCOwR
         IX0P1OWtw0zEyJVn4mDATS9uLILYeHxMrey9UUBh98sRhhOnGVEqK6sFturiVQa2+y/S
         coGg==
X-Gm-Message-State: APjAAAVoj0PZEgtPYS90GyWKZCqN0prAk5rk153LQDIEWrmhECSr2FYj
	TaHPwwSCwhMWVSxJOWDyLhpm5ZIlrMX8vscen9VGaCIWLj8KEP0iChuGpEjKFTjxbRDQb0ruWl0
	K6rZFRsjilIEkS6U3Kzndd9ZW4u0IbDZCuUnnjweEmfCmBHfjz/OkfDathA0feGchbQ==
X-Received: by 2002:a25:e744:: with SMTP id e65mr1161876ybh.432.1554313023616;
        Wed, 03 Apr 2019 10:37:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxlcHAHza+jE7BrK4+uol142k6ObzsQ/M+E0C5FO8+9RJbCd9G6hkhkBFZ0OQhQ/XERqSzq
X-Received: by 2002:a25:e744:: with SMTP id e65mr1161808ybh.432.1554313022846;
        Wed, 03 Apr 2019 10:37:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554313022; cv=none;
        d=google.com; s=arc-20160816;
        b=tV+kvJGLJ1m8mDV/iDuPvu5ugJBAjDDpfJO93Vb762buCMG5WixAzEA9jHFiNFoum2
         J+r3gREsHLEtQXhDJm+vL8zB0oSzDDn7JfKeKaQuuWKRxOei9hOdj0h+kITlliph8DU4
         k6+7QMFe4U3Dy6MJIuTY+eCsSdfZi/hzJuScHWNSOYCqZQus5gyUu8xOcqldogSdIlDV
         OlYQqzBJ0hLydGYCXZmo9xXUyJBZarqrQbneM4IBaV7ubSa28nlzOl7gT/OnRGbL0xX2
         0mtpKwQbY7ilZe5q46kOz+EYdMP9pwfFPcO11A8w6lKMQu4kpHIvGcNWaFED/VuDNpLY
         rIBQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:references:in-reply-to:message-id:date
         :subject:cc:to:from:dkim-signature;
        bh=ynty9flFqcPPDSeTkJifnT4Yutdn8/TkRysaHE6m4cE=;
        b=VlUz40cv9NP1r2xs7InagJhLFperQM+e3QYaBMnSeZ+svS4f5Zof7bv3PKPvb/I6Om
         WD0uPWo5/AlRzbUXwBf+3kBim2Dw8G8ajhnRb2vnusgND8sDEoADh1PltF5CUdgetkDz
         C2kn0Z95r1e1Aot11MkU+JOCk4r9TfZz1+rbcCFErPaBBs2BPtE12DG8s4h275Peu25S
         2PLmpBZySEjIQNtsewPpeyAoq5KRgD0LnFMTrOrvcEn/5wxK83/2qCvZ3KJr0Y/R0D01
         +w0FcTBSsEBOI/+HfWtKh9491xdWWeH47co+4C9PmfuUhMbZtCJCUj8osVIdxFHSDxTO
         NH/g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=BaxcCITX;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id b2si10346722ywh.384.2019.04.03.10.37.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Apr 2019 10:37:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=BaxcCITX;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x33HNdqq165965;
	Wed, 3 Apr 2019 17:36:04 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references : in-reply-to :
 references; s=corp-2018-07-02;
 bh=ynty9flFqcPPDSeTkJifnT4Yutdn8/TkRysaHE6m4cE=;
 b=BaxcCITX+BZ4+lS5aQJjRB3VCfd26NfZpmG7792Zbur5ODmmm50Sno8QeknDLKaCAir9
 Da0W1vB05l+2ASj/y+rE4hgV3tyBaxqqb91JOILD/MwVMrBRtVmhbFSrA9iMgDXoNJWS
 dRYrw4FjheDfi1giGH7j+C9Mh6xLGdSnbjK1Qg2rrxQNlCBwjMZjabA2o0bhjwvFsgvm
 ZGyPPSObB3PcM3+v3y/fDDKNwO6++dz2FVngxt1vH1XDVUGHsq570xDSyzQsC9TWwkKO
 1h+WkiWSGvDnqnffj7boaGX3CkOtpbIGYXFlvMpx+ygTyz3/w/5rP9ib47WXL8Nh+xu6 xA== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
	by userp2130.oracle.com with ESMTP id 2rhyvtahn9-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 03 Apr 2019 17:36:03 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
	by aserp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x33HZIEn110862;
	Wed, 3 Apr 2019 17:36:03 GMT
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by aserp3030.oracle.com with ESMTP id 2rm8f5fyjx-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 03 Apr 2019 17:36:02 +0000
Received: from abhmp0005.oracle.com (abhmp0005.oracle.com [141.146.116.11])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x33HZwKI001502;
	Wed, 3 Apr 2019 17:35:58 GMT
Received: from concerto.internal (/10.65.181.37)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 03 Apr 2019 10:35:57 -0700
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
        Khalid Aziz <khalid@gonehiking.org>
Subject: [RFC PATCH v9 09/13] xpfo: add primitives for mapping underlying memory
Date: Wed,  3 Apr 2019 11:34:10 -0600
Message-Id: <9f7930eca60750aaf5381efbbcb45f6da192874f.1554248002.git.khalid.aziz@oracle.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <cover.1554248001.git.khalid.aziz@oracle.com>
References: <cover.1554248001.git.khalid.aziz@oracle.com>
In-Reply-To: <cover.1554248001.git.khalid.aziz@oracle.com>
References: <cover.1554248001.git.khalid.aziz@oracle.com>
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9216 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=2 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1904030118
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9216 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1904030118
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Tycho Andersen <tycho@tycho.ws>

In some cases (on arm64 DMA and data cache flushes) we may have unmapped
the underlying pages needed for something via XPFO. Here are some
primitives useful for ensuring the underlying memory is mapped/unmapped in
the face of xpfo.

Signed-off-by: Tycho Andersen <tycho@tycho.ws>
Signed-off-by: Khalid Aziz <khalid.aziz@oracle.com>
Cc: Khalid Aziz <khalid@gonehiking.org>
---
 include/linux/xpfo.h | 21 +++++++++++++++++++++
 mm/xpfo.c            | 30 ++++++++++++++++++++++++++++++
 2 files changed, 51 insertions(+)

diff --git a/include/linux/xpfo.h b/include/linux/xpfo.h
index 5d8d06e4b796..2318c7eb5fb7 100644
--- a/include/linux/xpfo.h
+++ b/include/linux/xpfo.h
@@ -91,6 +91,15 @@ void xpfo_free_pages(struct page *page, int order);
 
 phys_addr_t user_virt_to_phys(unsigned long addr);
 
+#define XPFO_NUM_PAGES(addr, size) \
+	(PFN_UP((unsigned long) (addr) + (size)) - \
+		PFN_DOWN((unsigned long) (addr)))
+
+void xpfo_temp_map(const void *addr, size_t size, void **mapping,
+		   size_t mapping_len);
+void xpfo_temp_unmap(const void *addr, size_t size, void **mapping,
+		     size_t mapping_len);
+
 #else /* !CONFIG_XPFO */
 
 static inline void xpfo_init_single_page(struct page *page) { }
@@ -106,6 +115,18 @@ static inline void xpfo_flush_kernel_tlb(struct page *page, int order) { }
 
 static inline phys_addr_t user_virt_to_phys(unsigned long addr) { return 0; }
 
+#define XPFO_NUM_PAGES(addr, size) 0
+
+static inline void xpfo_temp_map(const void *addr, size_t size, void **mapping,
+				 size_t mapping_len)
+{
+}
+
+static inline void xpfo_temp_unmap(const void *addr, size_t size,
+				   void **mapping, size_t mapping_len)
+{
+}
+
 #endif /* CONFIG_XPFO */
 
 #if (!defined(CONFIG_HIGHMEM)) && (!defined(ARCH_HAS_KMAP))
diff --git a/mm/xpfo.c b/mm/xpfo.c
index b74fee0479e7..974f1b70ccd9 100644
--- a/mm/xpfo.c
+++ b/mm/xpfo.c
@@ -14,6 +14,7 @@
  * the Free Software Foundation.
  */
 
+#include <linux/highmem.h>
 #include <linux/mm.h>
 #include <linux/module.h>
 #include <linux/xpfo.h>
@@ -104,3 +105,32 @@ void xpfo_free_pages(struct page *page, int order)
 		}
 	}
 }
+
+void xpfo_temp_map(const void *addr, size_t size, void **mapping,
+		   size_t mapping_len)
+{
+	struct page *page = virt_to_page(addr);
+	int i, num_pages = mapping_len / sizeof(mapping[0]);
+
+	memset(mapping, 0, mapping_len);
+
+	for (i = 0; i < num_pages; i++) {
+		if (page_to_virt(page + i) >= addr + size)
+			break;
+
+		if (PageXpfoUnmapped(page + i))
+			mapping[i] = kmap_atomic(page + i);
+	}
+}
+EXPORT_SYMBOL(xpfo_temp_map);
+
+void xpfo_temp_unmap(const void *addr, size_t size, void **mapping,
+		     size_t mapping_len)
+{
+	int i, num_pages = mapping_len / sizeof(mapping[0]);
+
+	for (i = 0; i < num_pages; i++)
+		if (mapping[i])
+			kunmap_atomic(mapping[i]);
+}
+EXPORT_SYMBOL(xpfo_temp_unmap);
-- 
2.17.1

