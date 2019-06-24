Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 09C7AC48BE9
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 14:33:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B8A25208E4
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 14:33:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="XScBtinb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B8A25208E4
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D7A418E000E; Mon, 24 Jun 2019 10:33:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D27888E0002; Mon, 24 Jun 2019 10:33:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C19488E000E; Mon, 24 Jun 2019 10:33:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id A002C8E0002
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 10:33:27 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id v4so16313331qkj.10
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 07:33:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=hgUbj0aIma7FN/fDppNoJ1F9osla3F1YuX2112+Mp8s=;
        b=Aix0LgRLH4e2d/fa5JH/b6AnNiSTOx6Vr1SSSolwzR3BOV/5T/R6+QhZQRRtXeAZnv
         DIDcR0XVbuqZYo+u1/rd+Dt8BAJDLk1gpbEKQrbxMhoPxsXCqn2pbuK+4lEopl7Vd3Ou
         UaJsRR9PmSYEv9gg9o1PHnxzactUqpYmSCwQ3YU+/JfgTGMPfYB7kPBti8nNxJRSfnND
         eQ0JtX043Ec/N41IfaYVpvyezK1GsEbYUu2yDbz1U+DzsIByr2fcL7XC11Gop+MtEjkl
         B7BWn4mRticoVWgAW8ReZPhlEsv+FVzzsbQnoqBmRxTZqE/FppS9oA/KvDe8FVQ2vTrP
         Jhpw==
X-Gm-Message-State: APjAAAWuovCLcHH9kOI3ACjg17Hl2emZaJjsDidt/AglpTVCd9qijoEB
	/+o72zSV/zt4em0nWy37Z7p2rn7s2qwqWR26Cee/DqnoQmvhTLiVZmaTFpD/IVtm3Sz7KWrOKdP
	Cb3q9jCoj3VHN2XYlYcqfJ81lbeV4H7SETN2TGMqakF4xSH3+tajxsVjFuE07dCkyrA==
X-Received: by 2002:ac8:32e9:: with SMTP id a38mr133350779qtb.245.1561386807423;
        Mon, 24 Jun 2019 07:33:27 -0700 (PDT)
X-Received: by 2002:ac8:32e9:: with SMTP id a38mr133350738qtb.245.1561386806884;
        Mon, 24 Jun 2019 07:33:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561386806; cv=none;
        d=google.com; s=arc-20160816;
        b=SrIAkDAxztca1n6m4OaBBbav1/RkUQXYEkBB0yiXi2zCsDOH/UihbXNuCKkHU1DE6t
         58tvlSWJmmY0tijysZpNzHqnwVyD85G8MsIN/fKLRExqPruuhdeWVtFl3D/AbQRKUWrI
         Inje/NDieFvnCkG3wUDuBCGxNGUEHiZtF0HqW43BVMRWcZ6uo0iriGF+bHNqFQOKH+eH
         TUMoz3VpCE6P8bluVmT6SFVisc8PmWSs4/GBp2qzS7mImy9k3UTEU+V0r3gUkVaMsZ/z
         Z5SqpDu7zvCAwoSQ7jI+jiwlbrlyInKh5JSoatBMgVYGf9rTcb3chILiWWroPYbG9L/X
         16mA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=hgUbj0aIma7FN/fDppNoJ1F9osla3F1YuX2112+Mp8s=;
        b=mynXjsEP4gSSLzubEESvlJodxXgjb+uQzYw45xhJY31pFPTPZo24caHzdFqT1aUSfI
         HUKy6rk0OmwAF1IajLpM+WrWd1b/xILmSCDEHFWBTTVH4dbpGJGuF96g4EDu7zd6m53a
         nqy4wcQ3ELRD9QkQB9SGyuoMyS5Tjjzf3RkNj+g7Avc0x0xClymBkxF+IyCO5J4fcE69
         bAkCpn81yR8hSZywMeXfY+v0iJsn4lGjLZ5V2qbd4lw/E+pE8UfEGvFw0BSc6sdULisT
         Cr3vC2hM0e6ePKwx151Yg39qxAazbcBsJVshDcGI+3/immTa3ebbLMLhB6t1eJSEC4No
         7CwA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=XScBtinb;
       spf=pass (google.com: domain of 3nt8qxqokcccdqguhbnqyojrrjoh.frpolqxa-ppnydfn.ruj@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3Nt8QXQoKCCcDQGUHbNQYOJRRJOH.FRPOLQXa-PPNYDFN.RUJ@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id g28sor15558123qtb.3.2019.06.24.07.33.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 24 Jun 2019 07:33:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3nt8qxqokcccdqguhbnqyojrrjoh.frpolqxa-ppnydfn.ruj@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=XScBtinb;
       spf=pass (google.com: domain of 3nt8qxqokcccdqguhbnqyojrrjoh.frpolqxa-ppnydfn.ruj@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3Nt8QXQoKCCcDQGUHbNQYOJRRJOH.FRPOLQXa-PPNYDFN.RUJ@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=hgUbj0aIma7FN/fDppNoJ1F9osla3F1YuX2112+Mp8s=;
        b=XScBtinbiUGDniM5VWwPkGG4/4TOXpRMgLEipRA38wBRqrcXcDq9jBk/0BRZ6x9hlI
         V9LUyuozhqT/IxEnIqdvY3TfW2BBFmFPeZMV6/kHE3QjS3QjydQyEBZrtxP0iPkgc0Lq
         Fl63uCJcNPhGHDYzX4eXyVr2le0SZJjeeiUUJ6M7ZIcaEAu7j+hLiu/GnMRfjOmk9l2j
         73WehpBOM1MSylhUeiF0hVgN+PDN+5kZdcFg4wO/LJNJCaEb2km52xgKxYMc9FCtyBPh
         HEL+2jGVAoHMOTxdl5nV9rz2oXMXpuOjUoFsub2nzlRgfcoGoFmp1CkWMhgLIpXXStyF
         WB2w==
X-Google-Smtp-Source: APXvYqz02tw9mMb0OtKeZ2W98zeRoHwxKY7XE2woJy2A8vtl93nXys5C7sVpsVp2/N99zMzUyfh+KRmcoF+IJQVn
X-Received: by 2002:ac8:3811:: with SMTP id q17mr99190639qtb.315.1561386806511;
 Mon, 24 Jun 2019 07:33:26 -0700 (PDT)
Date: Mon, 24 Jun 2019 16:32:52 +0200
In-Reply-To: <cover.1561386715.git.andreyknvl@google.com>
Message-Id: <41e0a911e4e4d533486a1468114e6878e21f9f84.1561386715.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1561386715.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.22.0.410.gd8fdbe21b5-goog
Subject: [PATCH v18 07/15] fs/namespace: untag user pointers in copy_mount_options
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

This patch is a part of a series that extends kernel ABI to allow to pass
tagged user pointers (with the top byte set to something else other than
0x00) as syscall arguments.

In copy_mount_options a user address is being subtracted from TASK_SIZE.
If the address is lower than TASK_SIZE, the size is calculated to not
allow the exact_copy_from_user() call to cross TASK_SIZE boundary.
However if the address is tagged, then the size will be calculated
incorrectly.

Untag the address before subtracting.

Reviewed-by: Khalid Aziz <khalid.aziz@oracle.com>
Reviewed-by: Vincenzo Frascino <vincenzo.frascino@arm.com>
Reviewed-by: Kees Cook <keescook@chromium.org>
Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>
Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 fs/namespace.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/namespace.c b/fs/namespace.c
index 7660c2749c96..ec78f7223917 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -2994,7 +2994,7 @@ void *copy_mount_options(const void __user * data)
 	 * the remainder of the page.
 	 */
 	/* copy_from_user cannot cross TASK_SIZE ! */
-	size = TASK_SIZE - (unsigned long)data;
+	size = TASK_SIZE - (unsigned long)untagged_addr(data);
 	if (size > PAGE_SIZE)
 		size = PAGE_SIZE;
 
-- 
2.22.0.410.gd8fdbe21b5-goog

