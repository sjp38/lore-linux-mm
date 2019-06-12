Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.3 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 23821C31E47
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 11:44:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D66F421744
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 11:44:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="crJJXXAC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D66F421744
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 821016B000E; Wed, 12 Jun 2019 07:44:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7F7D26B0010; Wed, 12 Jun 2019 07:44:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 70E7F6B0266; Wed, 12 Jun 2019 07:44:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4A3276B000E
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 07:44:00 -0400 (EDT)
Received: by mail-oi1-f199.google.com with SMTP id t198so5310819oih.20
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 04:44:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=Q196Me2jAIDAnTBGiPK/Cxn0vMZ4fncAn8y7f8WRTyA=;
        b=hkoYYzgJwt6AqBO5wWrHPjszgKOZEmmAqm8H4oQeI1/xaRR5rJyO83s/N0xCC1y1ri
         JtaLE8rGw87I4w3Kz1P69WcxFDkfxXuIpIHz0VRfQL/zpir6hb0HN1eGPCtcO29fsS0U
         qYTSFMWvxW/S24Z03AwzWImGQ4G+tIGZeuWjaKAhrf7c7jxCXjOgcAvVAx2PZRTbnlvk
         qLJf+XD6S5noWrWBe5jh6i5bI3ZFR2Ta0Qw126sp4e2DBSchx90ZfTZMtW6DrK3fkp24
         mSYRKVwSGf59G2LCq/CsxoAKZn3gQt6MW4TusjM3E+EPlvsGF4Oke78uKtNWIvqMgGxc
         /2/A==
X-Gm-Message-State: APjAAAXDGAzW0KRX6X0GCyJ/Vjjj9M55ocxBsFLaOaNDVlsG52Dr2Z2G
	PXgFLBHiT9BNmh1vULmpUg/LK6IxPkbS6vXtY/oWd4VrEttbbXCA94S8ODUzQTL/hU8gpsrjX7Z
	nlp7z7IEvBKs9JFvTFIliGwNO66ylabipFJc63gJjN8ZngXhRMKVtJNaLEQLVjhClmw==
X-Received: by 2002:a05:6830:119:: with SMTP id i25mr175052otp.288.1560339839996;
        Wed, 12 Jun 2019 04:43:59 -0700 (PDT)
X-Received: by 2002:a05:6830:119:: with SMTP id i25mr175025otp.288.1560339839392;
        Wed, 12 Jun 2019 04:43:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560339839; cv=none;
        d=google.com; s=arc-20160816;
        b=w0+SaWLQjOjD39ULcwrxYbNvuz1Wuy0Zri6K3lWQoA4LwLhRzrpMBPSdKalMrvO8cG
         gpvyjhrn6Xp5uqi2/VLvRZN0mdfofPYdybBpsJNqwdqIa3dxKzsCRdfSiB2cYa9i4zWg
         G6jvtNmkU0a/RSiQOX17qvawFO08myqk1ge+Sya7LztXY7stYHOp+TJneq/l/tWjf/nq
         Ha0jq/rluv+Y9y23W6rORXNK+w9BNoRqBiKQNCE7m/GEQecTn1n1aey1gdoqkfUHhLcS
         k3Zb8bL55WlZWhXsWCcVpQRYlKZSaeEXxmwj3PhU/sQn0uY2bjbhBIudAxD6K8BKx/OT
         L60A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=Q196Me2jAIDAnTBGiPK/Cxn0vMZ4fncAn8y7f8WRTyA=;
        b=pl3Pr9EWd9Rwp69HByt+ihfEfXIrsR0F/EIb6MLDBiNYK+pDoNUksaRdCy7kdqQtdR
         4wqKXKe0m9cy7RZTRf2bjhdAKWG+RdzoK1VnMFNACGYM84Vcp0nSvVJJ2zpnYuA8p508
         0b7pa6zCfavS1KZhADS3xN+ld1qmrnT5eZygqi3Bce9j2djm7SfdMufaML1bpqJ1Tv8y
         zefqwq1IlkTRxxGRuGEqRsa3Sx93zSGf/hkOmlT7KWgTOoe2nFxDmu1MokNemCPnnrvk
         dUawVcf523dK26/QH/hujsL3kGrZYFhb9qyWlm2xoS1okQ0OsCnBSrQrsCnWvfXUCg+C
         yC3g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=crJJXXAC;
       spf=pass (google.com: domain of 3fuuaxqokcdsxkaobvhksidlldib.zljifkru-jjhsxzh.lod@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3fuUAXQoKCDsXkaobvhksidlldib.Zljifkru-jjhsXZh.lod@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id o64sor6180408oia.58.2019.06.12.04.43.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 12 Jun 2019 04:43:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3fuuaxqokcdsxkaobvhksidlldib.zljifkru-jjhsxzh.lod@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=crJJXXAC;
       spf=pass (google.com: domain of 3fuuaxqokcdsxkaobvhksidlldib.zljifkru-jjhsxzh.lod@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3fuUAXQoKCDsXkaobvhksidlldib.Zljifkru-jjhsXZh.lod@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=Q196Me2jAIDAnTBGiPK/Cxn0vMZ4fncAn8y7f8WRTyA=;
        b=crJJXXAC2Ku7R2O4W/i46T8MVMbfUT08MJ41XL5/hHP5V9FjHyo0Uen9LNxuGDN5Vy
         63AWsHkedb9O9JWDh7PX7+icF3+aQrjNm9LMqOxXKSXvWvA1aCADx8vQJIjHIcqFjNdS
         lYpx+uRnlnGYhTQ2lQa8QHdE77x+n4mpr2sUjGrEPZ8RUtGTjRZ6moY6dJvWWn+KRbsY
         dQnCJW3fkugzHDg7Z7YzCoAOi+mpWJRQPWYBzTyBpPkH9NOLOyHd9BCpw34BLqWhA4XL
         4AfxwDFDvKPDrbAnUzBzbdpr67Rfah4zZpcEFIF5+I68PhpwUQ4ynpp9B2e02i2b/LFy
         ttKg==
X-Google-Smtp-Source: APXvYqzBV++HnsJqGVA3TkWLFAlh+OLmBH/rJ20EXP8gbe+qklBNVVp+IuIonV1uuXEIF8K1ppBAgAEKJRpWB8lr
X-Received: by 2002:aca:6c6:: with SMTP id 189mr17818209oig.167.1560339838959;
 Wed, 12 Jun 2019 04:43:58 -0700 (PDT)
Date: Wed, 12 Jun 2019 13:43:24 +0200
In-Reply-To: <cover.1560339705.git.andreyknvl@google.com>
Message-Id: <4ed871e14cc265a519c6ba8660a1827844371791.1560339705.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1560339705.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.22.0.rc2.383.gf4fbbf30c2-goog
Subject: [PATCH v17 07/15] fs, arm64: untag user pointers in copy_mount_options
From: Andrey Konovalov <andreyknvl@google.com>
To: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, 
	linux-kernel@vger.kernel.org, amd-gfx@lists.freedesktop.org, 
	dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org, 
	linux-media@vger.kernel.org, kvm@vger.kernel.org, 
	linux-kselftest@vger.kernel.org
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

This patch is a part of a series that extends arm64 kernel ABI to allow to
pass tagged user pointers (with the top byte set to something else other
than 0x00) as syscall arguments.

In copy_mount_options a user address is being subtracted from TASK_SIZE.
If the address is lower than TASK_SIZE, the size is calculated to not
allow the exact_copy_from_user() call to cross TASK_SIZE boundary.
However if the address is tagged, then the size will be calculated
incorrectly.

Untag the address before subtracting.

Reviewed-by: Kees Cook <keescook@chromium.org>
Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>
Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 fs/namespace.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/namespace.c b/fs/namespace.c
index b26778bdc236..2e85712a19ed 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -2993,7 +2993,7 @@ void *copy_mount_options(const void __user * data)
 	 * the remainder of the page.
 	 */
 	/* copy_from_user cannot cross TASK_SIZE ! */
-	size = TASK_SIZE - (unsigned long)data;
+	size = TASK_SIZE - (unsigned long)untagged_addr(data);
 	if (size > PAGE_SIZE)
 		size = PAGE_SIZE;
 
-- 
2.22.0.rc2.383.gf4fbbf30c2-goog

