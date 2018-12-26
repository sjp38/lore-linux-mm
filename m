Return-Path: <SRS0=eTfr=PD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C9E1AC43387
	for <linux-mm@archiver.kernel.org>; Wed, 26 Dec 2018 13:37:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8AA34218AD
	for <linux-mm@archiver.kernel.org>; Wed, 26 Dec 2018 13:37:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8AA34218AD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0F3588E0002; Wed, 26 Dec 2018 08:37:10 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4C2AD8E0016; Wed, 26 Dec 2018 08:37:09 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E845B8E0006; Wed, 26 Dec 2018 08:37:08 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id A72FD8E0006
	for <linux-mm@kvack.org>; Wed, 26 Dec 2018 08:37:07 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id y8so15205734pgq.12
        for <linux-mm@kvack.org>; Wed, 26 Dec 2018 05:37:07 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :user-agent:date:from:to:cc:cc:cc:cc:cc:cc:cc:cc:cc:cc:cc:cc:subject
         :references:mime-version:content-disposition;
        bh=YZLzxQiwGlvXOZFkL97HKAur/8XWKtAC5MIphih9KC4=;
        b=cCEbp1weIE4hIiygOqaIWg/IfbKzzTJ/uqlEcvG3if4SX2waHIJ7hQHYBeLWwiYcf4
         M+KFDmwbtjX4nRtix5e5iTlJ2HeZHy1iK4k3a+k0KGsIKn9hLOR00pmUwbcdgLEt5FCL
         3vHWGYDqUJBLzQotvKigPsi1Z/Z86VvglQxZIRK464eH2OCKK4mSfi4M8y0XOD6yKKZ5
         3r+1zanrAa/w9hVe7LJozA9PU9JlfUZTqFdPKUG2O+aVURXkyjb1bOq4BPIhORLfqr0s
         E4fUYCRaFR98xLWyDBqrNbag1f6K+lMZbzvtw7oUQ7dOpiIN0gLZeINaJKZbvrgd9eev
         JEcw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of fengguang.wu@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=fengguang.wu@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AJcUukedibMPAX7ds6UQE0YVYZaXu5hOLnokD2m7H+kG+EnQsA1XL6lk
	2VNgfmKFg1J5LwfSBlEsCPdeCYvRZ08cZkkytmMf2wUzL37H81Pf6Z/jB1saXgmoV9gMozjCsqi
	2bDGgWXsxX4FWKrDQKtVfwBinmsV7qFYdvKd4sFUc3/qYXS/dtu4irN8eMtCvpelRsg==
X-Received: by 2002:a17:902:541:: with SMTP id 59mr20142456plf.88.1545831427377;
        Wed, 26 Dec 2018 05:37:07 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6onIXpHro1JDeoRiXbTIHg3VJhDU6CIMxy+ftIooY8o8n3BX6vFGBfvFoBQ21dWVNUBS7z
X-Received: by 2002:a17:902:541:: with SMTP id 59mr20142429plf.88.1545831426902;
        Wed, 26 Dec 2018 05:37:06 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1545831426; cv=none;
        d=google.com; s=arc-20160816;
        b=fjj+3MhZAw5gel/J7oiogSaoscHyaZGSqfJlSCO/oMFtluOjH35QwfpmH5plb5D0qa
         Uk9h9P4equlTSZpY9zcZ/MjdMrI0BKRVuy8f9tP8piOSmo80n45FfmBIKg7EikYqF8IT
         in6gUnNNoJMagijOfM6aKzuM8l/PtYrQZOzRgAKCzJtuhpFRbg8ssq2/99k+ZH1w6Nir
         xm2dwo1j2gz1rGd9c90qlHa1JJ2Vl13aPuQTdEKxMf+JTfrxfHsrMxNvOhcADkPoWylD
         NZRk3lQdNeDmoDpsPCvRElNS2nwHNgiJhrzgRYyc1OAor+WyHcOJHlTlucLsGslz+vSq
         IZag==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-disposition:mime-version:references:subject:cc:cc:cc:cc:cc
         :cc:cc:cc:cc:cc:cc:cc:to:from:date:user-agent:message-id;
        bh=YZLzxQiwGlvXOZFkL97HKAur/8XWKtAC5MIphih9KC4=;
        b=uLDReHjzfhXelifCaJhX/LmK7j5dkpHGnVFffZIIaGfIqpwkrfifXrLK8+R7ZPo8UA
         VWWBTVFnZD7/In54oWximfAou4o7t4E+rVFr83dK6sKidZWZPAWzv4veeNM6HscezoeA
         1zWetytZw8Xwq0GmUTi7g2WU/VcNSVWe4r0OZf4X2/6QbVG9Zz/CpSTzNHUOcZ13KLBp
         FouahY+ALU+1RYVONdJIzs6RIogJ/J+HRKBfsxNTxrMrL5Jrj+XNadOfI4OBdP66ZVDa
         fiBDFIcklJ7TKmrGL/0VBDulXy0tUf8i+m9O96puuS2cBoK/7H86MNxRKsWiUkMgzI9B
         2t9g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of fengguang.wu@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=fengguang.wu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id e68si15371744pfb.101.2018.12.26.05.37.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Dec 2018 05:37:06 -0800 (PST)
Received-SPF: pass (google.com: domain of fengguang.wu@intel.com designates 192.55.52.115 as permitted sender) client-ip=192.55.52.115;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of fengguang.wu@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=fengguang.wu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga003.fm.intel.com ([10.253.24.29])
  by fmsmga103.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 26 Dec 2018 05:37:05 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.56,400,1539673200"; 
   d="scan'208";a="121185473"
Received: from wangdan1-mobl1.ccr.corp.intel.com (HELO wfg-t570.sh.intel.com) ([10.254.210.154])
  by FMSMGA003.fm.intel.com with ESMTP; 26 Dec 2018 05:37:02 -0800
Received: from wfg by wfg-t570.sh.intel.com with local (Exim 4.89)
	(envelope-from <fengguang.wu@intel.com>)
	id 1gc9Mr-0005Oy-IC; Wed, 26 Dec 2018 21:37:01 +0800
Message-Id: <20181226133351.894160986@intel.com>
User-Agent: quilt/0.65
Date: Wed, 26 Dec 2018 21:15:00 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
To: Andrew Morton <akpm@linux-foundation.org>
cc: Linux Memory Management List <linux-mm@kvack.org>,
 Nikita Leshenko <nikita.leshchenko@oracle.com>,
 Christian Borntraeger <borntraeger@de.ibm.com>,
 Fengguang Wu <fengguang.wu@intel.com>
cc: kvm@vger.kernel.org
Cc: LKML <linux-kernel@vger.kernel.org>
cc: Fan Du <fan.du@intel.com>
cc: Yao Yuan <yuan.yao@intel.com>
cc: Peng Dong <dongx.peng@intel.com>
cc: Huang Ying <ying.huang@intel.com>
CC: Liu Jingqi <jingqi.liu@intel.com>
cc: Dong Eddie <eddie.dong@intel.com>
cc: Dave Hansen <dave.hansen@intel.com>
cc: Zhang Yi <yi.z.zhang@linux.intel.com>
cc: Dan Williams <dan.j.williams@intel.com>
Subject: [RFC][PATCH v2 14/21] kvm: register in mm_struct
References: <20181226131446.330864849@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Disposition: inline; filename=0009-kvm-register-in-mm_struct.patch
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20181226131500.g1HscWzNlAavpdnGpCR9ntl-GYXmmv6jE2HP4PubZHo@z>

VM is associated with an address space and not a specific thread.

>From Documentation/virtual/kvm/api.txt:
   Only run VM ioctls from the same process (address space) that was used
   to create the VM.

CC: Nikita Leshenko <nikita.leshchenko@oracle.com>
CC: Christian Borntraeger <borntraeger@de.ibm.com>
Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
---
 include/linux/mm_types.h |   11 +++++++++++
 virt/kvm/kvm_main.c      |    3 +++
 2 files changed, 14 insertions(+)

--- linux.orig/include/linux/mm_types.h	2018-12-23 19:58:06.993417137 +0800
+++ linux/include/linux/mm_types.h	2018-12-23 19:58:06.993417137 +0800
@@ -27,6 +27,7 @@ typedef int vm_fault_t;
 struct address_space;
 struct mem_cgroup;
 struct hmm;
+struct kvm;
 
 /*
  * Each physical page in the system has a struct page associated with
@@ -496,6 +497,10 @@ struct mm_struct {
 		/* HMM needs to track a few things per mm */
 		struct hmm *hmm;
 #endif
+
+#if IS_ENABLED(CONFIG_KVM)
+		struct kvm *kvm;
+#endif
 	} __randomize_layout;
 
 	/*
@@ -507,6 +512,12 @@ struct mm_struct {
 
 extern struct mm_struct init_mm;
 
+#if IS_ENABLED(CONFIG_KVM)
+static inline struct kvm *mm_kvm(struct mm_struct *mm) { return mm->kvm; }
+#else
+static inline struct kvm *mm_kvm(struct mm_struct *mm) { return NULL; }
+#endif
+
 /* Pointer magic because the dynamic array size confuses some compilers. */
 static inline void mm_init_cpumask(struct mm_struct *mm)
 {
--- linux.orig/virt/kvm/kvm_main.c	2018-12-23 19:58:06.993417137 +0800
+++ linux/virt/kvm/kvm_main.c	2018-12-23 19:58:06.993417137 +0800
@@ -727,6 +727,7 @@ static void kvm_destroy_vm(struct kvm *k
 	struct mm_struct *mm = kvm->mm;
 
 	kvm_uevent_notify_change(KVM_EVENT_DESTROY_VM, kvm);
+	mm->kvm = NULL;
 	kvm_destroy_vm_debugfs(kvm);
 	kvm_arch_sync_events(kvm);
 	spin_lock(&kvm_lock);
@@ -3224,6 +3225,8 @@ static int kvm_dev_ioctl_create_vm(unsig
 		fput(file);
 		return -ENOMEM;
 	}
+
+	kvm->mm->kvm = kvm;
 	kvm_uevent_notify_change(KVM_EVENT_CREATE_VM, kvm);
 
 	fd_install(r, file);


