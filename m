Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5ED6CC433FF
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:06:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 08AEB214C6
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:06:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 08AEB214C6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C2A966B02E9; Fri,  9 Aug 2019 12:03:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C03236B02EA; Fri,  9 Aug 2019 12:03:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AA2686B02EB; Fri,  9 Aug 2019 12:03:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5EAC26B02E9
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 12:03:12 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id a5so60560896edx.12
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 09:03:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=bKQctIR9RQ3N0yUOd7/19BsHR17UqL4s3TSC6lop2qE=;
        b=rJsNJQNAIddJQy5RxcHw+gZClLU25uVFKil7efSYao0d146pHM1suVOmYiOHg4iEIK
         jyZ5KtqtPWaexBiOPtfjZOHNfc7y9CPTTkUV/AWSRXh2NL2WMouxYZ2ISp0pekZgzSVN
         FDSTVAP3h58oCntv68qGKthjOSW/cV8pMIHRQyH8HywT5FIjakJOeTOQoebTFmb+6Cq+
         gZmJBNUhmS28N1aPZhJJxMD7ZwBv3jlGxZU7HdmOajxWpcoVTEPAGGD12BLNXbV1vF8E
         Hd1GCj01havbsv/ejmpCHqCC4wbqVnYgicdZiPlSn5fEaUus4hpF3lSJPb+ya/z2mE7D
         FQQA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAVPfifv2u/LKPjplebGFQI24uh8HOhyCEpe9d0JOp1OMLnZl2JR
	gtjZ6YcyaYW798fcKT++CbY4n4GW7dz0bOIug+RdnejbFpgWCv2wZcqoTrQG4vBv/JFgemaRLFp
	z7SbRtJ2TTdvvNisGAVD8foC8s8/gecYfk4Rrz8eTAQmqYAoOCVh76chjIvB//2EDGA==
X-Received: by 2002:a17:906:95d0:: with SMTP id n16mr19162944ejy.116.1565366591923;
        Fri, 09 Aug 2019 09:03:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwYsevigK/YjNw816mqr9nvOZLHMrK5EC97UFCZvt/yvZpbd0biW7GZDxYCGWaG96sTePWP
X-Received: by 2002:a17:906:95d0:: with SMTP id n16mr19162808ejy.116.1565366590497;
        Fri, 09 Aug 2019 09:03:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565366590; cv=none;
        d=google.com; s=arc-20160816;
        b=Ie583GBZGkc7UMILlWsbDKXtyisGjk/WmgBrMVRT8g5+8Cv7i5l/BNGq3PZgO84PNo
         MVjc7xlwyCgr+LV3d84Op8++Pl4TbeIYvH1BNVphxt50MPe3eStgMTy7Fnk4uJqBIomT
         it6kgEuGhKvzc+rZOt2VxrkZp7Ju6LmTGbTLVZzJqTlYB3x6sV1GRy3/rP3w1SEtS3dq
         2qhVKEzvcjVlMgujP6J625mvrs/XA+hRp4/88tfxf8oPOt4FNPeczU9HlLTsHlMgCkLB
         MeiKDR0C9EaRd6zy7kW551j8oK4Caqu5yxBSVPQ7R5Xz1TgYjJHp7gBMheQZlv5Pv5Ra
         SaUg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=bKQctIR9RQ3N0yUOd7/19BsHR17UqL4s3TSC6lop2qE=;
        b=Yik4d5Bp04USv5YIBuhEicc4NgIYvTCAJk9FUJ69IMA1IkSgL9u7rpcZhWy+OwD0cl
         vjiNEqKMnu3bA5RgxK4UYkPx3M2Hy6egVFluIZfqmfIjad7Lx2KKtFIFRydKOWzqozAG
         4VMO0mHOFqI0IE5T9cZwoxuBJueqX+Avc0phph30AfqVZSGTdl2uRkgJ+OIE2RhCIEi6
         58iBvXqsM3qvYHBjLrcv0i+1T4BL9JiqR6VQ5YmbcGVQa6yg02uUq7XLh2/vTDagWVpS
         BHoR/Tg2vyya3BIwNnfSqK3Qaho2mScxYmO/zE+7/RASBrGNjDpBwL1x0aj3hiHhdEyC
         iNlw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id gf12si32833772ejb.392.2019.08.09.09.03.09
        for <linux-mm@kvack.org>;
        Fri, 09 Aug 2019 09:03:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 979B315A2;
	Fri,  9 Aug 2019 09:03:08 -0700 (PDT)
Received: from arrakis.emea.arm.com (arrakis.cambridge.arm.com [10.1.196.78])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id C67723F575;
	Fri,  9 Aug 2019 09:03:03 -0700 (PDT)
Date: Fri, 9 Aug 2019 17:03:01 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
To: Andrey Konovalov <andreyknvl@google.com>,
	Andrew Morton <akpm@linux-foundation.org>
Cc: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, amd-gfx@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org,
	linux-media@vger.kernel.org, kvm@vger.kernel.org,
	linux-kselftest@vger.kernel.org,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Kees Cook <keescook@chromium.org>,
	Yishai Hadas <yishaih@mellanox.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Alexander Deucher <Alexander.Deucher@amd.com>,
	Christian Koenig <Christian.Koenig@amd.com>,
	Mauro Carvalho Chehab <mchehab@kernel.org>,
	Jens Wiklander <jens.wiklander@linaro.org>,
	Alex Williamson <alex.williamson@redhat.com>,
	Leon Romanovsky <leon@kernel.org>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
	Dave Martin <Dave.Martin@arm.com>,
	Khalid Aziz <khalid.aziz@oracle.com>, enh <enh@google.com>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Christoph Hellwig <hch@infradead.org>,
	Dmitry Vyukov <dvyukov@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Evgeniy Stepanov <eugenis@google.com>,
	Lee Smith <Lee.Smith@arm.com>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Jacob Bramley <Jacob.Bramley@arm.com>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>,
	Dave Hansen <dave.hansen@intel.com>
Subject: Re: [PATCH v19 04/15] mm: untag user pointers passed to memory
 syscalls
Message-ID: <20190809160301.GB23083@arrakis.emea.arm.com>
References: <cover.1563904656.git.andreyknvl@google.com>
 <aaf0c0969d46b2feb9017f3e1b3ef3970b633d91.1563904656.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <aaf0c0969d46b2feb9017f3e1b3ef3970b633d91.1563904656.git.andreyknvl@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 23, 2019 at 07:58:41PM +0200, Andrey Konovalov wrote:
> This patch is a part of a series that extends kernel ABI to allow to pass
> tagged user pointers (with the top byte set to something else other than
> 0x00) as syscall arguments.
> 
> This patch allows tagged pointers to be passed to the following memory
> syscalls: get_mempolicy, madvise, mbind, mincore, mlock, mlock2, mprotect,
> mremap, msync, munlock, move_pages.
> 
> The mmap and mremap syscalls do not currently accept tagged addresses.
> Architectures may interpret the tag as a background colour for the
> corresponding vma.
> 
> Reviewed-by: Khalid Aziz <khalid.aziz@oracle.com>
> Reviewed-by: Vincenzo Frascino <vincenzo.frascino@arm.com>
> Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>
> Reviewed-by: Kees Cook <keescook@chromium.org>
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> ---
>  mm/madvise.c   | 2 ++
>  mm/mempolicy.c | 3 +++
>  mm/migrate.c   | 2 +-
>  mm/mincore.c   | 2 ++
>  mm/mlock.c     | 4 ++++
>  mm/mprotect.c  | 2 ++
>  mm/mremap.c    | 7 +++++++
>  mm/msync.c     | 2 ++
>  8 files changed, 23 insertions(+), 1 deletion(-)

More back and forth discussions on how to specify the exceptions here.
I'm proposing just dropping the exceptions and folding in the diff
below.

Andrew, if you prefer a standalone patch instead, please let me know:

------------------8<----------------------------
From 9a5286acaa638c6a917d96986bf28dad35e24a0c Mon Sep 17 00:00:00 2001
From: Catalin Marinas <catalin.marinas@arm.com>
Date: Fri, 9 Aug 2019 14:21:33 +0100
Subject: [PATCH] fixup! mm: untag user pointers passed to memory syscalls

mmap, mremap, munmap, brk added to the list of syscalls that accept
tagged pointers.

Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>
---
 mm/mmap.c   | 5 +++++
 mm/mremap.c | 6 +-----
 2 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index 7e8c3e8ae75f..b766b633b7ae 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -201,6 +201,8 @@ SYSCALL_DEFINE1(brk, unsigned long, brk)
 	bool downgraded = false;
 	LIST_HEAD(uf);
 
+	brk = untagged_addr(brk);
+
 	if (down_write_killable(&mm->mmap_sem))
 		return -EINTR;
 
@@ -1573,6 +1575,8 @@ unsigned long ksys_mmap_pgoff(unsigned long addr, unsigned long len,
 	struct file *file = NULL;
 	unsigned long retval;
 
+	addr = untagged_addr(addr);
+
 	if (!(flags & MAP_ANONYMOUS)) {
 		audit_mmap_fd(fd, flags);
 		file = fget(fd);
@@ -2874,6 +2878,7 @@ EXPORT_SYMBOL(vm_munmap);
 
 SYSCALL_DEFINE2(munmap, unsigned long, addr, size_t, len)
 {
+	addr = untagged_addr(addr);
 	profile_munmap(addr);
 	return __vm_munmap(addr, len, true);
 }
diff --git a/mm/mremap.c b/mm/mremap.c
index 64c9a3b8be0a..1fc8a29fbe3f 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -606,12 +606,8 @@ SYSCALL_DEFINE5(mremap, unsigned long, addr, unsigned long, old_len,
 	LIST_HEAD(uf_unmap_early);
 	LIST_HEAD(uf_unmap);
 
-	/*
-	 * Architectures may interpret the tag passed to mmap as a background
-	 * colour for the corresponding vma. For mremap we don't allow tagged
-	 * new_addr to preserve similar behaviour to mmap.
-	 */
 	addr = untagged_addr(addr);
+	new_addr = untagged_addr(new_addr);
 
 	if (flags & ~(MREMAP_FIXED | MREMAP_MAYMOVE))
 		return ret;

