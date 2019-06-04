Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_MED,URIBL_BLOCKED,
	USER_AGENT_GIT,USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DF167C28CC6
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 12:04:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 947D4249EA
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 12:04:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="GowLAStz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 947D4249EA
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 29A016B0008; Tue,  4 Jun 2019 08:04:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 24AEE6B026B; Tue,  4 Jun 2019 08:04:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 15FD06B0277; Tue,  4 Jun 2019 08:04:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f71.google.com (mail-vs1-f71.google.com [209.85.217.71])
	by kanga.kvack.org (Postfix) with ESMTP id EB67B6B0008
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 08:04:52 -0400 (EDT)
Received: by mail-vs1-f71.google.com with SMTP id i4so6242723vsi.23
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 05:04:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:message-id:mime-version
         :subject:from:to:cc;
        bh=jQ4jdowRSjR3urFOBjyFZklSNNoQ/ud0fhl6APbdVCA=;
        b=jtIANSLFldWL34/0GE/+rI5lJAeo1sZTDXjcfH2KuqVLIjIlxmDjPgMCT+vkRgzQ0b
         SXWYLV691JPI8Pl2hpocArxoqe3fDHPNtYxfp7W59KNIOgQcBcvcHpBlJFwqgyNoln27
         rGVkuyTh6SiX6yLaxZI+X3INKwBsHxO2b1pnychze0XMo2ZNYa/XvPbhQs8JTC4Bf0YI
         2UVb170dkCQruZqTwrElSlKiJmVUqoEQV01BA21hmhOELsMt6QVUjlLguYLgbxAED6+N
         DUEOn3vqdozyJHr+AHDteP4cB1vcF8xO3a4BhTWW8j1IOOZeR9uuqHxIbh74FpLimXlR
         DVNQ==
X-Gm-Message-State: APjAAAWNFjOBxVBNcBEDCUnUT1P78+3aHf3Td27BdUsiof/ZD+ZKY93t
	V4s2Gu11EpVRwVe9YOJyVBaylVGLrD/RmTkmGVdKmV2FMeVdzCQXICilRJzINdGi7pZRKDstDvv
	jklWeuJ6kix9zUSZV5HyGTcU66N7HMPGzeFO4tXQvPWl3hDxzDJUyWabrBFMS7QGGfA==
X-Received: by 2002:a67:f485:: with SMTP id o5mr15778285vsn.165.1559649892529;
        Tue, 04 Jun 2019 05:04:52 -0700 (PDT)
X-Received: by 2002:a67:f485:: with SMTP id o5mr15778245vsn.165.1559649891762;
        Tue, 04 Jun 2019 05:04:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559649891; cv=none;
        d=google.com; s=arc-20160816;
        b=Eo/TOKL40NCRAbBDoNe2QxNmYc4SJP+0GfQmlLFu1Eq6fLNO2lZkl2i/3sM5FL0DO1
         BKGu9+VdwhohR0myw5sVsycbC7HFcv07II4SQPkPfJTQDIlMYfPS8FF/iy7N0CUBfBey
         8iBL4ggXPpa7V4HjJYZW7LFpOXeQ4uEOXRFjRQrdjo/lYDmo7a/3lJ8LU1fdVy9ZqXVm
         9WvtNzZ4RPpcObCrTmqg6vpZ9DgSWREMijtEhYLQ+QajOcv8jXMpOFDgc52bFGmX+Pc7
         aJh+YMyJ3xVOYgXWv4mDI9vAXgRhVOzkeoBbnppVQvIuVy+Fu/ZqBL/7iby7q2KV1oPV
         RtxQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:mime-version:message-id:date:dkim-signature;
        bh=jQ4jdowRSjR3urFOBjyFZklSNNoQ/ud0fhl6APbdVCA=;
        b=ozlA6hK3BrsnICN0Kwpg9lEOjVzKN/1OAzCWRpi3WbDwPwOUfLGtje85mc1Dpiy58G
         K9CKV9EZ48n/+IAKoLcEnB6r46leR3DJzgaGpk+mzqnjX9/Oi16Plz2cv06YxoxyrI5q
         RkIM6DlVE9IT1+LziKVcM/8pyG0T8KJPTLKKIVk9Nu2DEFv6SMT1RG94vjCHeSpQ+0gi
         nczFMtFubtHrxnwG2th9/Z28XPbXQ+FcGEI+wUhOOT7tzUjGFBOjGwU0uhKDkuLnaP8Y
         JH3ofTfw9uG48rKZ8hjkmWT2MBZviuKdI/swdELEJd7KK/14cZOa1QfzeUC+aklInKt9
         yPoQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=GowLAStz;
       spf=pass (google.com: domain of 3y172xaokcoyivlzmgsvdtowwotm.kwutqvcf-uusdiks.wzo@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3Y172XAoKCOYIVLZMgSVdTOWWOTM.KWUTQVcf-UUSdIKS.WZO@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id c8sor2309547uaf.58.2019.06.04.05.04.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 04 Jun 2019 05:04:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3y172xaokcoyivlzmgsvdtowwotm.kwutqvcf-uusdiks.wzo@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=GowLAStz;
       spf=pass (google.com: domain of 3y172xaokcoyivlzmgsvdtowwotm.kwutqvcf-uusdiks.wzo@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3Y172XAoKCOYIVLZMgSVdTOWWOTM.KWUTQVcf-UUSdIKS.WZO@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:message-id:mime-version:subject:from:to:cc;
        bh=jQ4jdowRSjR3urFOBjyFZklSNNoQ/ud0fhl6APbdVCA=;
        b=GowLAStz/2F1T2+1l2LwgSfjTKRmMNBrNNCBZBil5igL4JQyaWlnxhbbmWCoX861Oi
         B/gqgNlu7CEqXMP2+z7kELt1QAkywzQ/4/CBIgoztk4jhPS0IDaW6f2xT62bZyvCkGPW
         ChaaC18egrJWcY5tXKS1tu+1ggnllHfRVAt4dSrOhgYxZTnaC50stPSrxwS8K7gbAyLN
         UjDTA5LQ+N55Gnmek72ZITAekTqyE/lF715JE4SsnddL1vL3d3tMoF9CBM84jFEXZ+Fi
         /tVHki2lXZ2QdEK7Q+gvSqDXWwBEJ/eJ981jOBPiAFjG2vVRecZEHKzlptA4WkyhnZzl
         0RUQ==
X-Google-Smtp-Source: APXvYqzbAGU8OQBoy9uHFFBvYRcfDQrSEKOseigLTkDo7YUO7FMQDDHLZj47ajW7+eNrCdw8uM2m21YgNxpjq+Kq
X-Received: by 2002:ab0:184e:: with SMTP id j14mr15665222uag.91.1559649891290;
 Tue, 04 Jun 2019 05:04:51 -0700 (PDT)
Date: Tue,  4 Jun 2019 14:04:47 +0200
Message-Id: <c8311f9b759e254308a8e57d9f6eb17728a686a7.1559649879.git.andreyknvl@google.com>
Mime-Version: 1.0
X-Mailer: git-send-email 2.22.0.rc1.311.g5d7573a151-goog
Subject: [PATCH v2] uaccess: add noop untagged_addr definition
From: Andrey Konovalov <andreyknvl@google.com>
To: Linus Torvalds <torvalds@linux-foundation.org>, linux-arm-kernel@lists.infradead.org, 
	sparclinux@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Catalin Marinas <catalin.marinas@arm.com>, Vincenzo Frascino <vincenzo.frascino@arm.com>, 
	Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, 
	Kees Cook <keescook@chromium.org>, Yishai Hadas <yishaih@mellanox.com>, 
	Felix Kuehling <Felix.Kuehling@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, 
	Christian Koenig <Christian.Koenig@amd.com>, Mauro Carvalho Chehab <mchehab@kernel.org>, 
	Jens Wiklander <jens.wiklander@linaro.org>, Alex Williamson <alex.williamson@redhat.com>, 
	Leon Romanovsky <leon@kernel.org>, Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, 
	Dave Martin <Dave.Martin@arm.com>, Khalid Aziz <khalid.aziz@oracle.com>, enh <enh@google.com>, 
	Jason Gunthorpe <jgg@ziepe.ca>, Christoph Hellwig <hch@infradead.org>, Dmitry Vyukov <dvyukov@google.com>, 
	Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, 
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, 
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Robin Murphy <robin.murphy@arm.com>, 
	Kevin Brodsky <kevin.brodsky@arm.com>, Szabolcs Nagy <Szabolcs.Nagy@arm.com>, 
	Andrey Konovalov <andreyknvl@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Architectures that support memory tagging have a need to perform untagging
(stripping the tag) in various parts of the kernel. This patch adds an
untagged_addr() macro, which is defined as noop for architectures that do
not support memory tagging. The oncoming patch series will define it at
least for sparc64 and arm64.

Acked-by: Catalin Marinas <catalin.marinas@arm.com>
Reviewed-by: Khalid Aziz <khalid.aziz@oracle.com>
Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 include/linux/mm.h | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 0e8834ac32b7..dd0b5f4e1e45 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -99,6 +99,17 @@ extern int mmap_rnd_compat_bits __read_mostly;
 #include <asm/pgtable.h>
 #include <asm/processor.h>
 
+/*
+ * Architectures that support memory tagging (assigning tags to memory regions,
+ * embedding these tags into addresses that point to these memory regions, and
+ * checking that the memory and the pointer tags match on memory accesses)
+ * redefine this macro to strip tags from pointers.
+ * It's defined as noop for arcitectures that don't support memory tagging.
+ */
+#ifndef untagged_addr
+#define untagged_addr(addr) (addr)
+#endif
+
 #ifndef __pa_symbol
 #define __pa_symbol(x)  __pa(RELOC_HIDE((unsigned long)(x), 0))
 #endif
-- 
2.22.0.rc1.311.g5d7573a151-goog

