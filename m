Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 94756C04AAF
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 04:54:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6322C21019
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 04:54:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6322C21019
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=stgolabs.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F2B3F6B0271; Tue, 21 May 2019 00:53:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EDA446B0273; Tue, 21 May 2019 00:53:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DC88E6B0274; Tue, 21 May 2019 00:53:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 89A706B0271
	for <linux-mm@kvack.org>; Tue, 21 May 2019 00:53:49 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id f41so28736700ede.1
        for <linux-mm@kvack.org>; Mon, 20 May 2019 21:53:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=AKmR5B5S0qq8tGuHHmSOEPObaYYJM0kSBVRLE/9QL+Q=;
        b=RSZh7jjIfh5PAOqt39Rd/TB9yJCMKvQjaHqx4d4ikCnEOc3aHGrLn1rtQaF+ieHTPE
         uRAK0755g46b8oqppLsZ7hJfRqg+KqbbfYG+IymMHUFFtN/WaniIb5UP0r6n71TwrFKM
         jOxiCKv92Xa4djmrY3K6zPiG452kcdtPYR1EhewRAYwh/p1CNYr0o4MFP4ThpLP8RgTe
         vZs00OlD7M9trUJyK52482VpkANGJAdJFhq3jl4+hwiaRnHJGySbMxRsj4L1wP+lmvzA
         sg2or2svnIPYDDlKCf50kztmTYHK/3dghAIotVBwX7LbB6EDFUhklEQ2t+YDsschdG9B
         T1dQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.221.5 as permitted sender) smtp.mailfrom=dave@stgolabs.net
X-Gm-Message-State: APjAAAV4qyx4eOjxCD8h3VsmbQFBxdmm5d69K/uf1YBl18J9YJTvbicf
	9vBYuNfBRWuKrwMSnVq/RxmkNkb4bRfoxLRc+MRL2pqb9/LZySZf3/IctgyegztFKHRNtQCzKFu
	vvE1TEldhS/ibaWF0gYP5qN2jXTdh2JmljMcE54NUdK10V9ynLtWS7t88Db9nL3Y=
X-Received: by 2002:aa7:d8d1:: with SMTP id k17mr80706727eds.250.1558414429089;
        Mon, 20 May 2019 21:53:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwQAD2mdFBeOT6B6PZZ93sfMnY50myQBKNe/UBDBMWHNUFflc9WGLeLpbl14CaFfQ5yumFm
X-Received: by 2002:aa7:d8d1:: with SMTP id k17mr80706671eds.250.1558414427935;
        Mon, 20 May 2019 21:53:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558414427; cv=none;
        d=google.com; s=arc-20160816;
        b=xYrqICNzn5PIS+PmgtYEPo042LSkqKbNHilGBMN8wq3TqPHp0gjHrDGewt9iWeygnT
         Y3Wxl9FScD8vLQ7NhSrEnkLWkfHmUjV+g/ppp+2umgXe91q4cYFx/I0Sd8GRmVeJQOWo
         7Z5Ff5UYo6MzyzwZy6GxhJt+myD1cUwQNIPLBGO6X9XKPf60+ZybM7gjqk3TwvGJ1Gxv
         v2OIer34fGXo208GhUd5C4wqtSb26VKynix1j9DRD1aJP/Bzn0Cv7o7tWhhRokfEofsm
         wNHU7MM+CEUwhoamp80SyOm6mvvmL8XmXU/w/VTQYvaQRF+RdFhJviJbvP6sdUGZBkWk
         q00w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=AKmR5B5S0qq8tGuHHmSOEPObaYYJM0kSBVRLE/9QL+Q=;
        b=pb22JqE0tX+OOv0vR3Mc7yIUPmStRUtw9Ri5MDbgstuaOHZTBS/uOy4g3ca5T3f7Ot
         u1SEgTv3IDU0sUzVYy5pITX5fhOxeeKV9t1HqPIQ21aAODcHQPqjPLHjuMc65q535yYv
         0lqmBBvRpWLdjvIHlm2KVkjaVMLH7oRKKib+axRyvD6OXfHIkHNdzua9chaQBp0BA2KS
         pnr0Z2J6i9P6/F64hNVgQG8Ic12b1igQPJYmPZlUm0Kz8+6r1U18aeLJevm2mpfikzw/
         keq7PXhq8V9Erjn/8IKBQit7jaM+0dvcQ/52/yABe9xWA76rquwRkZEfKLmwiKpPYoZh
         0b1w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.221.5 as permitted sender) smtp.mailfrom=dave@stgolabs.net
Received: from smtp.nue.novell.com (smtp.nue.novell.com. [195.135.221.5])
        by mx.google.com with ESMTPS id d13si7274559ejj.242.2019.05.20.21.53.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 May 2019 21:53:47 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.221.5 as permitted sender) client-ip=195.135.221.5;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.221.5 as permitted sender) smtp.mailfrom=dave@stgolabs.net
Received: from emea4-mta.ukb.novell.com ([10.120.13.87])
	by smtp.nue.novell.com with ESMTP (TLS encrypted); Tue, 21 May 2019 06:53:47 +0200
Received: from linux-r8p5.suse.de (nwb-a10-snat.microfocus.com [10.120.13.201])
	by emea4-mta.ukb.novell.com with ESMTP (TLS encrypted); Tue, 21 May 2019 05:53:19 +0100
From: Davidlohr Bueso <dave@stgolabs.net>
To: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org,
	willy@infradead.org,
	mhocko@kernel.org,
	mgorman@techsingularity.net,
	jglisse@redhat.com,
	ldufour@linux.vnet.ibm.com,
	dave@stgolabs.net,
	Davidlohr Bueso <dbueso@suse.de>
Subject: [PATCH 11/14] ipc: teach the mm about range locking
Date: Mon, 20 May 2019 21:52:39 -0700
Message-Id: <20190521045242.24378-12-dave@stgolabs.net>
X-Mailer: git-send-email 2.16.4
In-Reply-To: <20190521045242.24378-1-dave@stgolabs.net>
References: <20190521045242.24378-1-dave@stgolabs.net>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Conversion is straightforward, mmap_sem is used within the
the same function context most of the time. No change in
semantics.

Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
---
 ipc/shm.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/ipc/shm.c b/ipc/shm.c
index ce1ca9f7c6e9..3666fa71bfc2 100644
--- a/ipc/shm.c
+++ b/ipc/shm.c
@@ -1418,6 +1418,7 @@ COMPAT_SYSCALL_DEFINE3(old_shmctl, int, shmid, int, cmd, void __user *, uptr)
 long do_shmat(int shmid, char __user *shmaddr, int shmflg,
 	      ulong *raddr, unsigned long shmlba)
 {
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 	struct shmid_kernel *shp;
 	unsigned long addr = (unsigned long)shmaddr;
 	unsigned long size;
@@ -1544,7 +1545,7 @@ long do_shmat(int shmid, char __user *shmaddr, int shmflg,
 	if (err)
 		goto out_fput;
 
-	if (down_write_killable(&current->mm->mmap_sem)) {
+	if (mm_write_lock_killable(current->mm, &mmrange)) {
 		err = -EINTR;
 		goto out_fput;
 	}
@@ -1564,7 +1565,7 @@ long do_shmat(int shmid, char __user *shmaddr, int shmflg,
 	if (IS_ERR_VALUE(addr))
 		err = (long)addr;
 invalid:
-	up_write(&current->mm->mmap_sem);
+	mm_write_unlock(current->mm, &mmrange);
 	if (populate)
 		mm_populate(addr, populate);
 
@@ -1625,6 +1626,7 @@ COMPAT_SYSCALL_DEFINE3(shmat, int, shmid, compat_uptr_t, shmaddr, int, shmflg)
  */
 long ksys_shmdt(char __user *shmaddr)
 {
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma;
 	unsigned long addr = (unsigned long)shmaddr;
@@ -1638,7 +1640,7 @@ long ksys_shmdt(char __user *shmaddr)
 	if (addr & ~PAGE_MASK)
 		return retval;
 
-	if (down_write_killable(&mm->mmap_sem))
+	if (mm_write_lock_killable(mm, &mmrange))
 		return -EINTR;
 
 	/*
@@ -1726,7 +1728,7 @@ long ksys_shmdt(char __user *shmaddr)
 
 #endif
 
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &mmrange);
 	return retval;
 }
 
-- 
2.16.4

