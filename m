Return-Path: <SRS0=KwX8=RE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 192B8C43381
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 03:55:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D59B32083D
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 03:55:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D59B32083D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ECFF98E0001; Thu, 28 Feb 2019 22:55:53 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E7F198E0003; Thu, 28 Feb 2019 22:55:53 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D23698E0001; Thu, 28 Feb 2019 22:55:53 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8D8E08E0003
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 22:55:53 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id b6so17895856qkg.4
        for <linux-mm@kvack.org>; Thu, 28 Feb 2019 19:55:53 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=EbsT11eA/DCivzghAonAtO5ch7UeNMFDg5iwkYq9Q4s=;
        b=n6f+clG90N0RRVaEaT12OdcwZd6hH3Hi3RuxbowF1ND7MVML5fVvKjaEq5T48ws844
         Hdcp5lFR/HCvtJ7uzEYpK6vmIOyhXZYr6J2v/miPIWGxdm7WbJiYaV3FZ7HysRkKYW2L
         Sens/WzjDJIhmylQQGLaU697AWLcUtNv43Xs3NaNEJoUkMikr5qA0HzkfHnNV72Jp5iG
         3LxjN4hhIsJkM8rbx0wtQIbNYslcXSHwCzhKw5hUYE+yObZiwP5PnQYL9EuSvZt826/G
         p+/gC+gmYntakkkS3EW/g9HRzjXLDMiAjmPzYsS5SIcNEkY4jZBpyMHiaHWJVA++ciJb
         WwDA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUyALgD5NgVlNkjqqgo0I5Qs1MF3nsSqFAky2Y0UaJvqYtGIEz2
	e93/MCR/J28cXV2ciCYWQwRhnEfN67pplB0qPxQb+2Ob4jIM4/b9MBav+uADTU6pqtt21U1SNXZ
	gBdfNv1JP4VsiX6nF4h8EDN5JZme6tYEE5ahFGXtTLw8pHhBML9X2BM4YnHTn2MG0RA==
X-Received: by 2002:a37:4a12:: with SMTP id x18mr2348911qka.169.1551412553336;
        Thu, 28 Feb 2019 19:55:53 -0800 (PST)
X-Google-Smtp-Source: APXvYqxxQYVGw4j/EAYWivdrkpQtCDLCr6gcNDci81chjdY942wJAC6RuGqqpnmmxlyyo3TiXUNy
X-Received: by 2002:a37:4a12:: with SMTP id x18mr2348881qka.169.1551412552377;
        Thu, 28 Feb 2019 19:55:52 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551412552; cv=none;
        d=google.com; s=arc-20160816;
        b=j6HtxBD/g1oGQyy/oEJy9/9mSAu/2G6lEBuXW8dJt8C+poRpEXxb7GQyKo5nvjp2kg
         8nQ8fBRYUiN9yyRvIHiTDRHx0klDhYflswYERLCy3o/lgj7ueb9Pd0pKqRrCWXCM+uwA
         wRkCIYIP76iZvsaYgNV6LPT/n7nc21E74+z7ZDQT+/5qM/T7ofNpuWIXhOMpbmG/voSd
         NRSw0G6QdqssaLAWq6gS7YRJ6WJnHfNXph3OQp8ylO4MdGqjQ8YPzVVh3JfsjWasFwMw
         TCN1/KSqX74Yoqd59KTRAbG5B5ShWqlzpT4l0E+7NQWlt2U8t1T7EHtkPMUZ4ZxwrCAC
         tgcA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=EbsT11eA/DCivzghAonAtO5ch7UeNMFDg5iwkYq9Q4s=;
        b=AxavHqLUu7VxLmkKBRkk7YsNqYzJ8+BSjljG7+2+ayI2WsSqFCMRqSZf12nHPn1Kxq
         V2o+qCnXsHZYllZIj8RD3rM2iWO1G77eQ5JfSyE7VoCtUpnucA66WpDFMHzjSeQN0CeW
         HHIGtiZEs+ZXrN0ae7RSUiacMDgl4u7n26CD7Qrj9sq6CZpMJUxkuUMKU0kNdJIM214w
         uRFmn0Rmc382rJQr//vq/z89mA1JNAy+agEmzn6d/g/bzNuDzmYNlPTyv727ABEiQ9CH
         LEO1B5zyckNvZHOR6cP2pQq52320lY5iC3PML2b9kRgDFTGToyd2DvZhlFyvL/A1pXZs
         6/uA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e49si2140856qte.158.2019.02.28.19.55.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Feb 2019 19:55:52 -0800 (PST)
Received-SPF: pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 9669C30AA39D;
	Fri,  1 Mar 2019 03:55:51 +0000 (UTC)
Received: from sky.random (ovpn-121-1.rdu2.redhat.com [10.10.121.1])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 52D4A19C5B;
	Fri,  1 Mar 2019 03:55:51 +0000 (UTC)
From: Andrea Arcangeli <aarcange@redhat.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org,
	Hugh Dickins <hughd@google.com>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Michal Hocko <mhocko@suse.com>
Subject: [PATCH 0/2] RFC: READ/WRITE_ONCE vma/mm cleanups
Date: Thu, 28 Feb 2019 22:55:48 -0500
Message-Id: <20190301035550.1124-1-aarcange@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.40]); Fri, 01 Mar 2019 03:55:51 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,

This was a well known issue for more than a decade, but until a few
months ago we relied on the compiler to stick to atomic accesses and
updates while walking and updating pagetables.

However now the 64bit native_set_pte finally uses WRITE_ONCE and
gup_pmd_range uses READ_ONCE as well.

This convert more racy VM places to avoid depending on the expected
compiler behavior to achieve kernel runtime correctness.

It mostly guarantees gcc to do atomic updates at 64bit granularity
(practically not needed) and it also prevents gcc to emit code that
risks getting confused if the memory unexpectedly changes under it
(unlikely to ever be needed).

The list of vm_start/end/pgoff to update isn't complete, I covered the
most obvious places, but before wasting too much time at doing a full
audit I thought it was safer to post it and get some comment. More
updates can be posted incrementally anyway.

Andrea Arcangeli (2):
  coredump: use READ_ONCE to read mm->flags
  mm: use READ/WRITE_ONCE to access anonymous vmas
    vm_start/vm_end/vm_pgoff

 fs/coredump.c |  2 +-
 mm/gup.c      | 23 +++++++++++++----------
 mm/internal.h |  3 ++-
 mm/memory.c   |  2 +-
 mm/mmap.c     | 16 ++++++++--------
 mm/rmap.c     |  3 ++-
 mm/vmacache.c |  3 ++-
 7 files changed, 29 insertions(+), 23 deletions(-)

