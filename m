Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8F39EC43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 14:52:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 44FA5206BA
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 14:52:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="qURJbhCG"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 44FA5206BA
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2F0126B0276; Wed, 20 Mar 2019 10:52:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2C8166B0277; Wed, 20 Mar 2019 10:52:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 141E16B0278; Wed, 20 Mar 2019 10:52:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id D727E6B0276
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 10:52:47 -0400 (EDT)
Received: by mail-it1-f198.google.com with SMTP id q192so2449383itb.9
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 07:52:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=cu+3rmCpd9l5R/y3h5ye/p2bAO3sj0NL49uODSAFDdE=;
        b=pQ36lh5rsR7vYRANwlWWltHGxgakZma4DtkX0c3HQqlHrq1Xgc54EmAADaRPGmKr+f
         8ip5ZWg7Y8IN/9X/vYhyuix1NtFZ8QBcFQkowY8hDKU0qjYwajcl+jnjB+313H5v4d7r
         rJhYSbYC8Pi+VtNIZ4i0X9RXKcbufhQHdqnkfTfI9mbCrOhcY3W03aGKZgPQfgZPyo3S
         CaOyFzwIwwLX1FLazEBxkeDrt7D6ddx+kHLDi3LLdV9xmrE/6MEoUrJ8Ow0KSTF2HaMQ
         qdazpBmYE66D6ezEqh2iXvcPPZ9vrfUEV7tvIYYGPIQWXQqgI4pEmApdtoKnr9H884rF
         UX9w==
X-Gm-Message-State: APjAAAUTn7By5QjIkDLVXZMkCmeu5AJM+8nArdiMd5Fm9Ojvkf/fpM0b
	lHROIZXocAX7qXmojYT7EI5fPH6BFEyntZM1SdK9sV+MBnbDHZSuLOCqU+C3xxBhaWoIb1ecBSJ
	LkTWlEir3v+Alma4ikxfZYq1Wm7nQlsbmEWrBobZvvWF553973nDQPhL4fgkmmc4M2Q==
X-Received: by 2002:a6b:7517:: with SMTP id l23mr5715309ioh.74.1553093567606;
        Wed, 20 Mar 2019 07:52:47 -0700 (PDT)
X-Received: by 2002:a6b:7517:: with SMTP id l23mr5715259ioh.74.1553093566827;
        Wed, 20 Mar 2019 07:52:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553093566; cv=none;
        d=google.com; s=arc-20160816;
        b=hvealJLKJD9MkkPTPjdnoON03xtm+y5Shsz6G3rEwUlPbyJUE11l1vjq5YyvTRD/BO
         6JDPmIplkS5lY7STZJ/W/wxEwYTjGaEnBU4W6BUqXxAvYmpndkwaB7BhItFmndD7/vVG
         yfcRN07KbRjJ7IA0hPUSB0PmS0vb7wXn7ZLh/7dn7weOZvBfPK5HBA9VOBERKb/ZcxZc
         Q3WXOeYHKohQZWdRbSeknM7AMAznH5gmdlJlQFVBCB7Yoz2gpPVgYxG1pCt34813HC0O
         9fpx4s5WHuZ8epX6E7pQovNIP1Kgln1MpoKEoYS0WA9xsEtiUtCGRrMBFUTg/K/8jp6l
         rohA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=cu+3rmCpd9l5R/y3h5ye/p2bAO3sj0NL49uODSAFDdE=;
        b=ysvZw5W+o46LQiJbRXDhofATcsX+7WhgmyU2UnNzrjlirf8MKJrhXOeccF7EoxbFuH
         x1ifxgxjpTpIhztaD7kuk/aRr+NUC3RKTs/LE2gNr5xUXTZXJXkpSx2lb6sbQ+SNfcqH
         QuVAWrSaFMInOG9FnH8x5xnPvQ618ITRa/UzmN53Wa2w7y4p4AO+2txli4hJJCz7Kmlo
         zwyCFEPVJGUxn68qxh1OpDTxaHQf5aVKGnbVJ0TNvmrj1HjPAT2eniPX9+oFofNSs33x
         IfV/jlCdve/7JJLYCWyE8ah4vXlTeJyMypDg+gqdQVVyKuJJ0xp8SiUThtoioFKCNqoP
         JqrQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=qURJbhCG;
       spf=pass (google.com: domain of 3vlosxaokcjk3g6k7rdgoe9hh9e7.5hfebgnq-ffdo35d.hk9@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3vlOSXAoKCJk3G6K7RDGOE9HH9E7.5HFEBGNQ-FFDO35D.HK9@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id s5sor4472485itb.19.2019.03.20.07.52.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Mar 2019 07:52:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3vlosxaokcjk3g6k7rdgoe9hh9e7.5hfebgnq-ffdo35d.hk9@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=qURJbhCG;
       spf=pass (google.com: domain of 3vlosxaokcjk3g6k7rdgoe9hh9e7.5hfebgnq-ffdo35d.hk9@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3vlOSXAoKCJk3G6K7RDGOE9HH9E7.5HFEBGNQ-FFDO35D.HK9@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=cu+3rmCpd9l5R/y3h5ye/p2bAO3sj0NL49uODSAFDdE=;
        b=qURJbhCG7KHqBQdB9/tW98IIzZBOYUsNCATGgXe4awlobm2aNwlvzelxDOnoumvmrK
         b/mIN1JLFUKKEWmVODg3dQknY4u8cwFqoBa4ozFLzZZmudKVb83CGFLq+FRv9y/TTY/5
         rSAaXeLT2zCRImT4RVHFaAYM6bwxS8DucSU4cUJk/3I0DGhDXWwcI81c67HCNpygji6O
         BQV4zKGeru6kOZ2vSpeEayFmHj/NHgdIhgoL99CR9cRbaTnADs3WAujfChTy8IoPizRb
         Mdk25Ol5EHmWTCbmZlyFv2SlYAe5UuS3bv3kmLeOg32bRFdSdDmDonpBZBZt7FJH+Ous
         ilbA==
X-Google-Smtp-Source: APXvYqzqObcBEgYzlcxCxTM9fSSNzVasJ/zSQwN6PhFl+/lgxd7D8DoZLa9+GTthl0M6pkpwMktv8E+fN9uDrpLf
X-Received: by 2002:a05:660c:68d:: with SMTP id n13mr4682397itk.24.1553093566394;
 Wed, 20 Mar 2019 07:52:46 -0700 (PDT)
Date: Wed, 20 Mar 2019 15:51:33 +0100
In-Reply-To: <cover.1553093420.git.andreyknvl@google.com>
Message-Id: <a49ac1a8e6d033dafd3beab0818900bde3d55860.1553093421.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1553093420.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.21.0.225.g810b269d1ac-goog
Subject: [PATCH v13 19/20] vfio/type1, arm64: untag user pointers in vaddr_get_pfn
From: Andrey Konovalov <andreyknvl@google.com>
To: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, 
	Mark Rutland <mark.rutland@arm.com>, Robin Murphy <robin.murphy@arm.com>, 
	Kees Cook <keescook@chromium.org>, Kate Stewart <kstewart@linuxfoundation.org>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Ingo Molnar <mingo@kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, 
	Shuah Khan <shuah@kernel.org>, Vincenzo Frascino <vincenzo.frascino@arm.com>, 
	Eric Dumazet <edumazet@google.com>, "David S. Miller" <davem@davemloft.net>, 
	Alexei Starovoitov <ast@kernel.org>, Daniel Borkmann <daniel@iogearbox.net>, 
	Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@redhat.com>, 
	Peter Zijlstra <peterz@infradead.org>, Arnaldo Carvalho de Melo <acme@kernel.org>, 
	Alex Deucher <alexander.deucher@amd.com>, 
	"=?UTF-8?q?Christian=20K=C3=B6nig?=" <christian.koenig@amd.com>, "David (ChunMing) Zhou" <David1.Zhou@amd.com>, 
	Yishai Hadas <yishaih@mellanox.com>, Mauro Carvalho Chehab <mchehab@kernel.org>, 
	Jens Wiklander <jens.wiklander@linaro.org>, Alex Williamson <alex.williamson@redhat.com>, 
	linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, 
	linux-arch@vger.kernel.org, netdev@vger.kernel.org, bpf@vger.kernel.org, 
	amd-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org, 
	linux-rdma@vger.kernel.org, linux-media@vger.kernel.org, kvm@vger.kernel.org, 
	linux-kselftest@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Dmitry Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>, 
	Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, 
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, 
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Chintan Pandya <cpandya@codeaurora.org>, 
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, Dave Martin <Dave.Martin@arm.com>, 
	Kevin Brodsky <kevin.brodsky@arm.com>, Szabolcs Nagy <Szabolcs.Nagy@arm.com>, 
	Andrey Konovalov <andreyknvl@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patch is a part of a series that extends arm64 kernel ABI to allow to
pass tagged user pointers (with the top byte set to something else other
than 0x00) as syscall arguments.

vaddr_get_pfn() uses provided user pointers for vma lookups, which can
only by done with untagged pointers.

Untag user pointers in this function.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 drivers/vfio/vfio_iommu_type1.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/vfio/vfio_iommu_type1.c b/drivers/vfio/vfio_iommu_type1.c
index 73652e21efec..e556caa64f83 100644
--- a/drivers/vfio/vfio_iommu_type1.c
+++ b/drivers/vfio/vfio_iommu_type1.c
@@ -376,6 +376,8 @@ static int vaddr_get_pfn(struct mm_struct *mm, unsigned long vaddr,
 
 	down_read(&mm->mmap_sem);
 
+	vaddr = untagged_addr(vaddr);
+
 	vma = find_vma_intersection(mm, vaddr, vaddr + 1);
 
 	if (vma && vma->vm_flags & VM_PFNMAP) {
-- 
2.21.0.225.g810b269d1ac-goog

