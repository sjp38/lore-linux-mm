Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f71.google.com (mail-vk0-f71.google.com [209.85.213.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7A7986B0253
	for <linux-mm@kvack.org>; Mon, 20 Jun 2016 06:37:55 -0400 (EDT)
Received: by mail-vk0-f71.google.com with SMTP id k2so191109461vkb.3
        for <linux-mm@kvack.org>; Mon, 20 Jun 2016 03:37:55 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id p140si2078280wme.3.2016.06.20.03.37.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Jun 2016 03:37:54 -0700 (PDT)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u5KAY8q1001868
	for <linux-mm@kvack.org>; Mon, 20 Jun 2016 06:37:53 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0b-001b2d01.pphosted.com with ESMTP id 23my7wyj9q-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 20 Jun 2016 06:37:53 -0400
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <borntraeger@de.ibm.com>;
	Mon, 20 Jun 2016 11:37:52 +0100
Received: from b06cxnps3074.portsmouth.uk.ibm.com (d06relay09.portsmouth.uk.ibm.com [9.149.109.194])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id D2C25219005F
	for <linux-mm@kvack.org>; Mon, 20 Jun 2016 11:37:20 +0100 (BST)
Received: from d06av07.portsmouth.uk.ibm.com (d06av07.portsmouth.uk.ibm.com [9.149.37.248])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u5KAbnP14981200
	for <linux-mm@kvack.org>; Mon, 20 Jun 2016 10:37:49 GMT
Received: from d06av07.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av07.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u5KAbnTs021664
	for <linux-mm@kvack.org>; Mon, 20 Jun 2016 06:37:49 -0400
From: Christian Borntraeger <borntraeger@de.ibm.com>
Subject: [PATCH 1/1] mm/page_ref: introduce page_ref_inc_return
Date: Mon, 20 Jun 2016 12:38:13 +0200
In-Reply-To: <1466419093-114348-1-git-send-email-borntraeger@de.ibm.com>
References: <1466419093-114348-1-git-send-email-borntraeger@de.ibm.com>
Message-Id: <1466419093-114348-2-git-send-email-borntraeger@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: Paolo Bonzini <pbonzini@redhat.com>, =?UTF-8?q?Radim=20Kr=C4=8Dm=C3=A1=C5=99?= <rkrcmar@redhat.com>, KVM <kvm@vger.kernel.org>, Cornelia Huck <cornelia.huck@de.ibm.com>, linux-s390 <linux-s390@vger.kernel.org>, Christian Borntraeger <borntraeger@de.ibm.com>, David Hildenbrand <dahi@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: David Hildenbrand <dahi@linux.vnet.ibm.com>

Let's introduce that helper.

Signed-off-by: David Hildenbrand <dahi@linux.vnet.ibm.com>
Signed-off-by: Christian Borntraeger <borntraeger@de.ibm.com>
---
 include/linux/page_ref.h | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/include/linux/page_ref.h b/include/linux/page_ref.h
index 8b5e0a9..610e132 100644
--- a/include/linux/page_ref.h
+++ b/include/linux/page_ref.h
@@ -124,6 +124,15 @@ static inline int page_ref_sub_and_test(struct page *page, int nr)
 	return ret;
 }
 
+static inline int page_ref_inc_return(struct page *page)
+{
+	int ret = atomic_inc_return(&page->_refcount);
+
+	if (page_ref_tracepoint_active(__tracepoint_page_ref_mod_and_return))
+		__page_ref_mod_and_return(page, 1, ret);
+	return ret;
+}
+
 static inline int page_ref_dec_and_test(struct page *page)
 {
 	int ret = atomic_dec_and_test(&page->_refcount);
-- 
2.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
