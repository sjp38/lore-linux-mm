Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_MED,URIBL_BLOCKED,
	USER_AGENT_GIT,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 13832C28CC6
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 11:44:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C1924245BC
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 11:44:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="OQowASfC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C1924245BC
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 568BB6B026E; Tue,  4 Jun 2019 07:44:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 51A246B0270; Tue,  4 Jun 2019 07:44:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 407DE6B0271; Tue,  4 Jun 2019 07:44:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id 184FC6B026E
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 07:44:51 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id j19so10458372otq.12
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 04:44:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:message-id:mime-version
         :subject:from:to:cc;
        bh=XCrbwdAiEJS3sao46jIToUSxgqStqSIKmjosXIycN10=;
        b=NvQq7wpmFjIDFjO/RAqRhryieRVdnVVIH8cyzMWs53TUKbCruubdiGZN6zS6OUX6gf
         m6Fbb9Hy2cj2Y7amlpnpmilEAV8msRxVvBWb23/LBFUSo0sq7DzZD9bWG9ze1VWRGdBO
         SfoDCSmp2JvWn1evLWfZEDxvj283oKa938U2rfpvMrV5+XEOhzj0h16Nwv5qkdSA96Eo
         vQFwIQdaK5B6CvILNO8oTTUoi538r+pYZmZ2wU0RW1jUGxwalcEL8t+g+tSN6AvBOPcA
         667rperGj6JO1NfOHH4V14LtQ99hdd34JgxE4YPhf9M7soxQs6eggB9eR7wXDuBTZYly
         rctw==
X-Gm-Message-State: APjAAAX/yBM9L+rRYu0rnQU8tC6FlLvfcd/5ay/9VqSLRlpQ64+qv3ZX
	iOcy+4t2EKzbGsRzYWRzMS/0UC2CRvGXr0gDkj4DDsYekQsJxLnilqWc1syq3QX67O33zS0hDMY
	jAdSCsMMFvl14GscXjpnwkrlKxhFBNk3Nm8tvciIbIiadYuIX+Iv9YimXoPNZ6cg5rQ==
X-Received: by 2002:a05:6830:148c:: with SMTP id s12mr4864267otq.274.1559648690779;
        Tue, 04 Jun 2019 04:44:50 -0700 (PDT)
X-Received: by 2002:a05:6830:148c:: with SMTP id s12mr4864241otq.274.1559648690234;
        Tue, 04 Jun 2019 04:44:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559648690; cv=none;
        d=google.com; s=arc-20160816;
        b=NgaZOhV2dHSO4+ZZmmr45KDLEYnZlOGvQ/7mRZ9DfJrv5i+GYcMb+HqcD88u89LaU1
         1MlYFMIN85sMb+V48lYgdkLAiIHiBUQNVGMzLfA09uJyaIL2n36f290n9L6kv2fq8t+g
         03Hl9/PX25CpwPJuojtKPRGsR/xETu7bcdn3h8qadWGOrqRXNc8VmikwEmIuz2KsqTQY
         mWPwM8gB03vMEoP5UVtsQ8zQ3JZGeVS+0RPMDmtnhvnjnlujikd9bztq1iCjaIFuirEe
         LFrO45Y5B+at/rhq9bY2uzkbfBryNgaeNTvjgEIigQd5XEmTN10KPvqzqzdya+9d62cl
         tREA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:mime-version:message-id:date:dkim-signature;
        bh=XCrbwdAiEJS3sao46jIToUSxgqStqSIKmjosXIycN10=;
        b=yq8/JebtyMiPsfXtd1i524OO2FrIyz61NKT5+Hv6RiN4NEMoXJnMzDJqx05RJ0TQJw
         RIxTza8fgMyqyrFJwTJiMVODB3MBNTsVafiylrOqzhmUW+gABAcwos92L7L+VJ9U2G/2
         WNrh478wX6IwxZ+70Acf10/Xd1/F+VY4GwMBxnNDVQydMao4gSS3gZqiPksOHIjPxKOb
         /ITEoA8edKWmQF1U6U+fsTrSVPI4hMQnFpmc9rEmaNso2kVTwEpAQgWtGLEJSD6Qwc9P
         pYgyOA2uckgJ/bcyv7IyFh30QrU6hEyJzl/HYqkVNCydFGheaU4zCE4O7vAEALTmrWth
         04Bg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=OQowASfC;
       spf=pass (google.com: domain of 3svn2xaokccwivlzmgsvdtowwotm.kwutqvcf-uusdiks.wzo@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3sVn2XAoKCCwIVLZMgSVdTOWWOTM.KWUTQVcf-UUSdIKS.WZO@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id j4sor6367894oia.5.2019.06.04.04.44.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 04 Jun 2019 04:44:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3svn2xaokccwivlzmgsvdtowwotm.kwutqvcf-uusdiks.wzo@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=OQowASfC;
       spf=pass (google.com: domain of 3svn2xaokccwivlzmgsvdtowwotm.kwutqvcf-uusdiks.wzo@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3sVn2XAoKCCwIVLZMgSVdTOWWOTM.KWUTQVcf-UUSdIKS.WZO@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:message-id:mime-version:subject:from:to:cc;
        bh=XCrbwdAiEJS3sao46jIToUSxgqStqSIKmjosXIycN10=;
        b=OQowASfC1DkZBD6ZzOOewK6YqgU2ZfNgbzHcLMXLm94xATdoL7pRsYoq0Ca983wUlW
         1AzHjVsjPZzLOSw/EYwBC5zTDiT3rRisFVr0otD4kGjI5Q1J+eBrFP3oWQBc3R8o7rZS
         +nEENWNe0lpacPo8kwRr2Cz7TDEttnz9npQcNVZJmeIO9eL9YROdUfyY9G7dPjCT5G4S
         n3vggAvgZl5bnPFVyY5V8gpZBFjsU9LmOWcovr1/jb8oFePv4CCtwEGaE9uoVlfJANln
         MTN/BlGEha/hwcouVsL2ZU5SkLr7wvck5RykyLLoKj5+diBYr1ixXCNWeLnwmH0fmyZF
         THpA==
X-Google-Smtp-Source: APXvYqwXsyeZ/z4p68zy0w3OgwmszH6BSy/5gFuyx/JVk90VXHjFqwFwXGlvbDPhexYH3Gb/pFc8t/if0dU8diyp
X-Received: by 2002:aca:b108:: with SMTP id a8mr4013564oif.81.1559648689594;
 Tue, 04 Jun 2019 04:44:49 -0700 (PDT)
Date: Tue,  4 Jun 2019 13:44:45 +0200
Message-Id: <8ab5cd1813b0890f8780018e9784838456ace49e.1559648669.git.andreyknvl@google.com>
Mime-Version: 1.0
X-Mailer: git-send-email 2.22.0.rc1.311.g5d7573a151-goog
Subject: [PATCH] uaccess: add noop untagged_addr definition
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
 include/linux/mm.h | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 0e8834ac32b7..949d43e9c0b6 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -99,6 +99,10 @@ extern int mmap_rnd_compat_bits __read_mostly;
 #include <asm/pgtable.h>
 #include <asm/processor.h>
 
+#ifndef untagged_addr
+#define untagged_addr(addr) (addr)
+#endif
+
 #ifndef __pa_symbol
 #define __pa_symbol(x)  __pa(RELOC_HIDE((unsigned long)(x), 0))
 #endif
-- 
2.22.0.rc1.311.g5d7573a151-goog

