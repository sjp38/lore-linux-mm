Return-Path: <SRS0=AzIT=P5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9D293C2F3A0
	for <linux-mm@archiver.kernel.org>; Mon, 21 Jan 2019 12:35:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 632752085A
	for <linux-mm@archiver.kernel.org>; Mon, 21 Jan 2019 12:35:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 632752085A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0AA2A8E0005; Mon, 21 Jan 2019 07:35:47 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 05CFC8E0001; Mon, 21 Jan 2019 07:35:47 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E8E408E0005; Mon, 21 Jan 2019 07:35:46 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id A90D58E0001
	for <linux-mm@kvack.org>; Mon, 21 Jan 2019 07:35:46 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id a2so14042595pgt.11
        for <linux-mm@kvack.org>; Mon, 21 Jan 2019 04:35:46 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:in-reply-to:references:date:mime-version:message-id;
        bh=1VJUVK14Krc3G40HC1daUt+/htEC9Aq5ztMnb7k49sg=;
        b=GCan3qVUCcgOuQOJY8gjYcEFtYe71NFpSYJMpcReVTV/cUMxpQarurX88a+erd+do9
         q1ecKf9eRyZP03UL2i0K+eC5X/3b7brwRMdBM21zaagsXq2PzwSMkgnpCKRSBdSQnCTT
         jRwG7/7cudTYNkFJxpX1PdCN0CF6uij805+ih0BFvCuKdktJT4u7UGw1n4DL1A0LNm8G
         9dh7dA0yJpXGYpZW/sv64cJoisPITos4bmU04wJ5Ho1bVYLx5fsUX82Ra6i7PBi49COw
         RO5kFBgTulaLrk3HzYc9ub1JBc5tbOuoWk0fITZKjbjM2OVxAorsjkIzkiCNIbTmKSbw
         0BcQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AJcUukd2i9LkdclKeMoZZEy0IxfbiylrKrDahSjUCt8k/hAXG3mt6dm7
	dQq+wnwhJqSNQzoNJ3sorNVlgKwFnsF6T49wgUkMSbADKiqL3/hLxmJXHCR+IHapFT7RN1HCGt4
	nFntNF3h5kjxrOlMt5bIUqg3ADy1YkNh8yoYEvENEE9Mv/P04TdtH77PinDsNWRmjuA==
X-Received: by 2002:a17:902:48:: with SMTP id 66mr29263086pla.68.1548074146152;
        Mon, 21 Jan 2019 04:35:46 -0800 (PST)
X-Google-Smtp-Source: ALg8bN52K2hVGfXltTzLEF6vM8jUiMiGDi/9JXo2k+N4YQYjVZtcnyuixbGKcTyEwee6C+L8lM21
X-Received: by 2002:a17:902:48:: with SMTP id 66mr29263043pla.68.1548074145472;
        Mon, 21 Jan 2019 04:35:45 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548074145; cv=none;
        d=google.com; s=arc-20160816;
        b=NQMqcNQC4xdcUbouz3cJ7zX3O9hT3l55NPbbJt+Cgxh/8xCmx/9OrMPf40e3CQN2l1
         pg1DZtQoo15VkyJ8RvsA/y5f4gAxDvllR7ZM9BlUsh9xp2j41OpLpCV76583FSasbw/o
         1xI7959CcVj5XXdqvmhtcyisqj2eY6ouzuWF0ELz5dRM529OqJ5LiysfQ0mhFbJ6Nsu/
         RgdB96WKOWyS9Op0H+9tpbWH2qVZiNZzBrUimUh/dyNvQ8XNGPOupgh1qufryXAfpRRq
         SAmbRVEbWsOEtkML8PYbE16BwEcGyqyoobqrE02OFxuBmxU4CRW9ofWxbSEyZQPMjVaw
         DOlA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:mime-version:date:references:in-reply-to:subject:cc:to
         :from;
        bh=1VJUVK14Krc3G40HC1daUt+/htEC9Aq5ztMnb7k49sg=;
        b=VHbbu7QPvR54rQe4F363VtUbtQ2MrPatURSrTtdDkWHC4CTlItW09LTC+yE7sRIEx4
         At+S7MVyv+JuMtpit5TW1nva9AL9dsxjLvP5ztiybXj3jVnKg3b+BTZqIDIKZPFSuiSR
         c8ctz/KQUqRYrO1X036f5Nzmqd7yqZnjiuB9HtAgj5ujSTP/WQd99bMvaTJCeKcDJUHh
         GM7uaro4pQAIoVi0TR7ji5aDCYafiEv8HQVvvuTdjkliu9xcbHmAjKheiBeaQtBxbBHy
         Kw/9dGmoCkg6Rb9O+SH/MqbTOs+Zd41UAK4ScpQl9lj/NWIi38gJuxOEUexaAOzkGnDX
         qQug==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id h188si12109130pfg.44.2019.01.21.04.35.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Jan 2019 04:35:45 -0800 (PST)
Received-SPF: pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x0LCTQ6C060936
	for <linux-mm@kvack.org>; Mon, 21 Jan 2019 07:35:44 -0500
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2q5c3we2kp-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 21 Jan 2019 07:35:44 -0500
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Mon, 21 Jan 2019 12:35:42 -0000
Received: from b06cxnps4074.portsmouth.uk.ibm.com (9.149.109.196)
	by e06smtp03.uk.ibm.com (192.168.101.133) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Mon, 21 Jan 2019 12:35:38 -0000
Received: from d06av25.portsmouth.uk.ibm.com (d06av25.portsmouth.uk.ibm.com [9.149.105.61])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x0LCZbfZ1966472
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Mon, 21 Jan 2019 12:35:37 GMT
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id B560811C058;
	Mon, 21 Jan 2019 12:35:37 +0000 (GMT)
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 62F7F11C050;
	Mon, 21 Jan 2019 12:35:36 +0000 (GMT)
Received: from skywalker.linux.ibm.com (unknown [9.85.74.157])
	by d06av25.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Mon, 21 Jan 2019 12:35:36 +0000 (GMT)
X-Mailer: emacs 26.1 (via feedmail 11-beta-1 I)
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
To: Matt Corallo <kernel@bluematt.me>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
        linuxppc-dev@lists.ozlabs.org, bugzilla-daemon@bugzilla.kernel.org
Subject: Re: [Bug 202149] New: NULL Pointer Dereference in __split_huge_pmd on PPC64LE
In-Reply-To: <A61367CF-277E-4E74-8A9D-C94C5E53817B@bluematt.me>
References: <bug-202149-27@https.bugzilla.kernel.org/> <20190104170459.c8c7fa57ba9bc8a69dee5666@linux-foundation.org> <87ef9nk4cj.fsf@linux.ibm.com> <ed4bea40-cf9e-89a1-f99a-3dbd6249847f@bluematt.me> <8736q2jbhr.fsf@linux.ibm.com> <A61367CF-277E-4E74-8A9D-C94C5E53817B@bluematt.me>
Date: Mon, 21 Jan 2019 18:05:33 +0530
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
X-TM-AS-GCONF: 00
x-cbid: 19012112-0012-0000-0000-000002EAD832
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19012112-0013-0000-0000-00002121FEF7
Message-Id: <87bm4achnu.fsf@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-01-21_07:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1901210099
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190121123533.ORBt0-U_2hXdGoXhycC2T4f61G8vqEkcmWg_1lsj-8Y@z>


Can you test this patch?

From e511e79af9a314854848ea8fda9dfa6d7e07c5e4 Mon Sep 17 00:00:00 2001
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Date: Mon, 21 Jan 2019 16:43:17 +0530
Subject: [PATCH] arch/powerpc/radix: Fix kernel crash with mremap

With support for split pmd lock, we use pmd page pmd_huge_pte pointer to store
the deposited page table. In those config when we move page tables we need to
make sure we move the depoisted page table to the right pmd page. Otherwise this
can result in crash when we withdraw of deposited page table because we can find
the pmd_huge_pte NULL.

c0000000004a1230 __split_huge_pmd+0x1070/0x1940
c0000000004a0ff4 __split_huge_pmd+0xe34/0x1940 (unreliable)
c0000000004a4000 vma_adjust_trans_huge+0x110/0x1c0
c00000000042fe04 __vma_adjust+0x2b4/0x9b0
c0000000004316e8 __split_vma+0x1b8/0x280
c00000000043192c __do_munmap+0x13c/0x550
c000000000439390 sys_mremap+0x220/0x7e0
c00000000000b488 system_call+0x5c/0x70

Fixes: 675d995297d4 ("powerpc/book3s64: Enable split pmd ptlock.")
Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
---
 arch/powerpc/include/asm/book3s/64/pgtable.h | 2 --
 1 file changed, 2 deletions(-)

diff --git a/arch/powerpc/include/asm/book3s/64/pgtable.h b/arch/powerpc/include/asm/book3s/64/pgtable.h
index 92eaea164700..86e62384256d 100644
--- a/arch/powerpc/include/asm/book3s/64/pgtable.h
+++ b/arch/powerpc/include/asm/book3s/64/pgtable.h
@@ -1262,8 +1262,6 @@ static inline int pmd_move_must_withdraw(struct spinlock *new_pmd_ptl,
 					 struct spinlock *old_pmd_ptl,
 					 struct vm_area_struct *vma)
 {
-	if (radix_enabled())
-		return false;
 	/*
 	 * Archs like ppc64 use pgtable to store per pmd
 	 * specific information. So when we switch the pmd,
-- 
2.20.1

