Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6A2EFC4360F
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 17:37:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 10D1820830
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 17:37:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="288vFbrP"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 10D1820830
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1F7196B0008; Wed,  3 Apr 2019 13:36:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0E8816B026A; Wed,  3 Apr 2019 13:36:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CF0686B0010; Wed,  3 Apr 2019 13:36:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id A37DA6B000E
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 13:36:58 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id p143so14465638iod.19
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 10:36:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:in-reply-to:references;
        bh=0+GGGOXBJNB8WE2w6yip3kAhBo1m6CU7TV5HSXQxFt4=;
        b=hTtgNJICRvmRJ3T1G/Q9UpwSCAq6zMpCANv3QXm1bAeWo/LV6e5BAfqX11tEw4epdt
         wjhQo6C7l2GNdy/BepADFM8dgODzpnj9KRimeK9Aj6FxfY61ChrVPb5gY5Ji6HtuFClj
         pcr6HM2ibrKj/wY4rcNXlv6edzApjTQe+z55CNpgQlUxdUAnTst5UZ/fefAxFfUXT2hn
         DiI+D0f+7GGG0CnHbl8aoZkjqpMJAPOb9MJLwIIyOXVHj8EuUm7bAb+4lpJ7yZyuF4QU
         rh0QLr6SinWk7Otvf1k8bYLyVMh9dx9EuyHtW5hG/+pqytFxjT/k1Agj+oi5io+QYEAH
         FVzg==
X-Gm-Message-State: APjAAAU3ZGC6sO+2+cNQzawGU3+gEGb+QuqSeYdpweJ74v9e721tnd8A
	/bwDbDfDR3hv658u4JZYnzQeWjdG3U61ULERZTEsWkoQTR23tsHX1TwiTGY5ZTAVO+Be10vbCdI
	OLKkHX4U/fSXFpgH3TLaje5BD2zUj3DuBEknETj0clRuyn46CD3gFo0oKy4/+W+RKeA==
X-Received: by 2002:a24:ac6e:: with SMTP id m46mr1284059iti.49.1554313018432;
        Wed, 03 Apr 2019 10:36:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwpJr3V42SGq+MiQ+0ziX8i1CLFb0Kg8Iatd4KxiZKnWuKhMggdp5NxmCYkZpg9dv2Wx9A8
X-Received: by 2002:a24:ac6e:: with SMTP id m46mr1284001iti.49.1554313017680;
        Wed, 03 Apr 2019 10:36:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554313017; cv=none;
        d=google.com; s=arc-20160816;
        b=t9OFCyhcrSMp5eQXuX0KgA+2SXoKCOkif+BiQd47NXX1OZissGEKIUpI48HYlJQADN
         OBDCw/26xmqxcvCfaDFygYnK+Kbi9q3n80psWmHjLsY20Bp23ivQ0tkx1qGvGpJUet1I
         /vfB0ZKcz53N6Gby4Vlnm6VKAm14Q7C56X3jCFKFZDmF2H0Y+IJEQVYUr5kwYMRrWnc1
         Tz03cjwCaWjtyfLFunj5XZlgifj0BBvsXoKLHG3nbgfzGfRoRWDdbqhr0ElS9b7iX4U3
         JIsdrbSqHJOj8g5UdOHhmsUHlSS3xqvocXthNI4DkKIGnb8B0Kt+lJyWFCCJbRs6wnJr
         qhgQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:references:in-reply-to:message-id:date
         :subject:cc:to:from:dkim-signature;
        bh=0+GGGOXBJNB8WE2w6yip3kAhBo1m6CU7TV5HSXQxFt4=;
        b=ivNnmKKfCGJa7K//ebbAlr6c1PZELDq4sHJ7bbP0ZgFrjJSX84e1d0yMNhHx0S/xY3
         uFY1hr9cKJSXxGbgGTHZ3/egqPv6Ws1JmcL88j3tkz2/qw71Y1+veuXZ3z4ftNycBMYg
         1weXTyrw/SLpadlqyyJbAWiwQJnIyI1vUEHBeDuKtdBk7w2gSmNCmqK7tjzTAAkAf7x6
         yxrKk9YhUjGEr4VCZLP+JBZw8GPm0TMcMHlMvkNY/ml3XtbYem3ltfL5fZruM78kxsVa
         5pEZUxYTRaTvenOYxiUNnWThr9QB5pjpBUufqEb8Ke2DljbbNtddiABpQQCECwhGdjjF
         kg8g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=288vFbrP;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id 191si8491665itu.68.2019.04.03.10.36.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Apr 2019 10:36:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=288vFbrP;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x33HNpk0175413;
	Wed, 3 Apr 2019 17:35:44 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references : in-reply-to :
 references; s=corp-2018-07-02;
 bh=0+GGGOXBJNB8WE2w6yip3kAhBo1m6CU7TV5HSXQxFt4=;
 b=288vFbrPKJZeEvZKUpB1q4+qhc8PIJAuLr1GF6exjMxG6eeOlw8STiY21uxJQnYUiFfC
 OwYQR0h3/QkWxocZ/8H1GT4YFL6aOSOKM1o6NldmVWMUGTB3px3AaAbWaib2Is7LzpkZ
 fEdhRb2MXC2PL+tWDOgJ2HW5Z08Q8JPH2kgnsjnPfPFgi1PzypJ4FD4KQOVbJS1wMNW1
 GEGTqgHmx/W3766VvWR+qoAxoK121Kq7kQUvA47y2mjISZW8QjPPcV+WYpD+bh9DhZab
 KJkq6r3l5zkILWnkKASronC7BCRtWM4HTV470c/1v4dRtPl1dtZSQxRr19DuxdTS9Qx+ bw== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
	by userp2120.oracle.com with ESMTP id 2rj13qae6y-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 03 Apr 2019 17:35:43 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
	by aserp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x33HZIQI110879;
	Wed, 3 Apr 2019 17:35:42 GMT
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by aserp3030.oracle.com with ESMTP id 2rm8f5fye7-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 03 Apr 2019 17:35:42 +0000
Received: from abhmp0005.oracle.com (abhmp0005.oracle.com [141.146.116.11])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x33HZMXB001176;
	Wed, 3 Apr 2019 17:35:22 GMT
Received: from concerto.internal (/10.65.181.37)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 03 Apr 2019 10:35:21 -0700
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
Subject: [RFC PATCH v9 01/13] mm: add MAP_HUGETLB support to vm_mmap
Date: Wed,  3 Apr 2019 11:34:02 -0600
Message-Id: <155f6a436aa38be6b31e37965187d161e1233a1c.1554248002.git.khalid.aziz@oracle.com>
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

From: Tycho Andersen <tycho@tycho.ws>

vm_mmap is exported, which means kernel modules can use it. In particular,
for testing XPFO support, we want to use it with the MAP_HUGETLB flag, so
let's support it via vm_mmap.

Signed-off-by: Tycho Andersen <tycho@tycho.ws>
Tested-by: Marco Benatto <marco.antonio.780@gmail.com>
Tested-by: Khalid Aziz <khalid.aziz@oracle.com>
Cc: Khalid Aziz <khalid@gonehiking.org>
---
 include/linux/mm.h |  2 ++
 mm/mmap.c          | 19 +------------------
 mm/util.c          | 32 ++++++++++++++++++++++++++++++++
 3 files changed, 35 insertions(+), 18 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 80bb6408fe73..3e4f6525d06b 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2412,6 +2412,8 @@ struct vm_unmapped_area_info {
 extern unsigned long unmapped_area(struct vm_unmapped_area_info *info);
 extern unsigned long unmapped_area_topdown(struct vm_unmapped_area_info *info);
 
+struct file *map_hugetlb_setup(unsigned long *len, unsigned long flags);
+
 /*
  * Search for an unmapped address range.
  *
diff --git a/mm/mmap.c b/mm/mmap.c
index fc1809b1bed6..65382d942598 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1582,24 +1582,7 @@ unsigned long ksys_mmap_pgoff(unsigned long addr, unsigned long len,
 		if (unlikely(flags & MAP_HUGETLB && !is_file_hugepages(file)))
 			goto out_fput;
 	} else if (flags & MAP_HUGETLB) {
-		struct user_struct *user = NULL;
-		struct hstate *hs;
-
-		hs = hstate_sizelog((flags >> MAP_HUGE_SHIFT) & MAP_HUGE_MASK);
-		if (!hs)
-			return -EINVAL;
-
-		len = ALIGN(len, huge_page_size(hs));
-		/*
-		 * VM_NORESERVE is used because the reservations will be
-		 * taken when vm_ops->mmap() is called
-		 * A dummy user value is used because we are not locking
-		 * memory so no accounting is necessary
-		 */
-		file = hugetlb_file_setup(HUGETLB_ANON_FILE, len,
-				VM_NORESERVE,
-				&user, HUGETLB_ANONHUGE_INODE,
-				(flags >> MAP_HUGE_SHIFT) & MAP_HUGE_MASK);
+		file = map_hugetlb_setup(&len, flags);
 		if (IS_ERR(file))
 			return PTR_ERR(file);
 	}
diff --git a/mm/util.c b/mm/util.c
index 379319b1bcfd..86b763861828 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -357,6 +357,29 @@ unsigned long vm_mmap_pgoff(struct file *file, unsigned long addr,
 	return ret;
 }
 
+struct file *map_hugetlb_setup(unsigned long *len, unsigned long flags)
+{
+	struct user_struct *user = NULL;
+	struct hstate *hs;
+
+	hs = hstate_sizelog((flags >> MAP_HUGE_SHIFT) & MAP_HUGE_MASK);
+	if (!hs)
+		return ERR_PTR(-EINVAL);
+
+	*len = ALIGN(*len, huge_page_size(hs));
+
+	/*
+	 * VM_NORESERVE is used because the reservations will be
+	 * taken when vm_ops->mmap() is called
+	 * A dummy user value is used because we are not locking
+	 * memory so no accounting is necessary
+	 */
+	return hugetlb_file_setup(HUGETLB_ANON_FILE, *len,
+			VM_NORESERVE,
+			&user, HUGETLB_ANONHUGE_INODE,
+			(flags >> MAP_HUGE_SHIFT) & MAP_HUGE_MASK);
+}
+
 unsigned long vm_mmap(struct file *file, unsigned long addr,
 	unsigned long len, unsigned long prot,
 	unsigned long flag, unsigned long offset)
@@ -366,6 +389,15 @@ unsigned long vm_mmap(struct file *file, unsigned long addr,
 	if (unlikely(offset_in_page(offset)))
 		return -EINVAL;
 
+	if (flag & MAP_HUGETLB) {
+		if (file)
+			return -EINVAL;
+
+		file = map_hugetlb_setup(&len, flag);
+		if (IS_ERR(file))
+			return PTR_ERR(file);
+	}
+
 	return vm_mmap_pgoff(file, addr, len, prot, flag, offset >> PAGE_SHIFT);
 }
 EXPORT_SYMBOL(vm_mmap);
-- 
2.17.1

