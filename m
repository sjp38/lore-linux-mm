Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AB3F1C10F05
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 14:52:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5C70D2146E
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 14:52:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="aEInHw6B"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5C70D2146E
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CB96E6B000C; Wed, 20 Mar 2019 10:52:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C1B166B000D; Wed, 20 Mar 2019 10:52:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A9B096B000E; Wed, 20 Mar 2019 10:52:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 760936B000C
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 10:52:01 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id o66so3438275ywc.3
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 07:52:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=LfpjTjIWpAUqgBuBr+ROlRDq3TWjVWHbA3wqyLv7Gqg=;
        b=mf8CnxGYHZ6rxIzNGeTHG/JEO++S0NJ3L9M0xhlIyWHITkh2k/zKwW1/jHzjD/ckKg
         IKE0f7F24574XOxaiHt4gplmGtyUdsa7GFdGMbct0X2KqWE3ESa05u2vV5Wz0cKRg+T/
         9Lu4eZCQwegI/lmuAok+KdJIldrpB8N5p1G7xtPYYxDsTlKemsYpr6dM1nhkM6M0ow2Z
         QMqFFXkhra8MqPC8IV8mUS51uctyV3UKoAs2P0C0JKF+U8Upz2pXpimdTd57Ht01pyRq
         KRRF8UmgDmy68AQFCHxnTBCfYza/Ze2L7gncd2n0o93uSAn5TF5VhHEXXgyS8th+Y8zP
         Wf8A==
X-Gm-Message-State: APjAAAWYf29khlLwVnJgnf8xICv1YDOJE4lRY80Bjj6GFOWOtkUBtKkp
	oOI70w84/FCN9wwZWXLfD1Zo4lUqe8sX1w0pxPHt/SKXN01FxJ71q0iL2IfEJXyEa6DK62IKkRK
	RK4zM91ZERHr47zXzdljQ/Fxjqn5xG0rfNhgH4AjCneXzG96KCrR7dK5dCRqbvNDwQw==
X-Received: by 2002:a25:e6c7:: with SMTP id d190mr7249589ybh.296.1553093520716;
        Wed, 20 Mar 2019 07:52:00 -0700 (PDT)
X-Received: by 2002:a25:e6c7:: with SMTP id d190mr7249531ybh.296.1553093519944;
        Wed, 20 Mar 2019 07:51:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553093519; cv=none;
        d=google.com; s=arc-20160816;
        b=TlWAHAzxPjEYYB2ris03LAN6sRb0sNKZzHcamWZB2ORY1LusfFFV2OcncpB8fUMGi6
         Eit+7+v4jfsrhxsQXRJV5lPOcGtvcxq9FfxXvMx33/kcZdCrIjtrxMdWz6wtTwGcuODe
         thN7+vjr1H8JtaID1HgtVQoy13fqyMHTZ2RIisf9aVLhWsfC8+HtRc1/iwZYpBIzGqfW
         6BikNWqLE+sXm1aMyTM+4AAsm3LUGwIEb138xg52DUpfYPM6yiCyNYAf56erTBf42J00
         R+q4eiiZNeTz2+ziSlh+tB4LvoRU+jcFzh5DzKtaiAjdl/ZM8zTtdV5SUxmSmDZIc69w
         w8Kw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=LfpjTjIWpAUqgBuBr+ROlRDq3TWjVWHbA3wqyLv7Gqg=;
        b=uU0RMtSSp8pwIj3/JuamGLuqCH5pVeKlBUgVIR9XgRSd0kwxOlQPiOo2ZCGUGleCda
         c6Fmv+97R+Z3ZV1Ol4bVirPDMGDKYpKr53KPmflQFEaNNLgSXUCpF6N64ZhSp5tIwySJ
         EZkW1pADgR5j2NgXqILfMWU+yww+m61xSchn/2tBdQCv0qVcggVnEHNzqeIbPifr7goC
         vCCoakqEBQO4vF9z2PUYobqya4XteoCkzdIvLAn1n3pwKKKpalSkMknSDDjtUtjM4d9m
         GMeI5P01eP2gE0FISaiR1rpM9Hpeujj3vuZ/qK/OfKAF5aYpHjq3w+OgqwUk9BA2KYIY
         2CMw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=aEInHw6B;
       spf=pass (google.com: domain of 3j1osxaokcgoivlzmgsvdtowwotm.kwutqvcf-uusdiks.wzo@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3j1OSXAoKCGoIVLZMgSVdTOWWOTM.KWUTQVcf-UUSdIKS.WZO@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id g6sor716849ywa.26.2019.03.20.07.51.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Mar 2019 07:51:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3j1osxaokcgoivlzmgsvdtowwotm.kwutqvcf-uusdiks.wzo@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=aEInHw6B;
       spf=pass (google.com: domain of 3j1osxaokcgoivlzmgsvdtowwotm.kwutqvcf-uusdiks.wzo@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3j1OSXAoKCGoIVLZMgSVdTOWWOTM.KWUTQVcf-UUSdIKS.WZO@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=LfpjTjIWpAUqgBuBr+ROlRDq3TWjVWHbA3wqyLv7Gqg=;
        b=aEInHw6BmCYYrnLC9PZfamaP8mF0QEG6bCjPXX9eR1nz2FAxuz8AakcoBGofdWpDDO
         ecVj+WVvAcyIM/4jHbYKbWN9FEhIYhxx/aKOkZgY6J++xI42I0q0BxFc8HG1MgmsuX4p
         FgBukYgteSls5KRVIf9LdhyXrtbiuThjGHXpsr95ebbSY1J3++E89dF2htIPvvI1/DzR
         SYS+4UXKzfCBY88MgyuqrkPh/UK28DK8ANz0pzTScNriptvjxadnhKInYAl8KyI7hS2W
         ag76Sj+PtN/agIm/Cl1LRWjUtui4zCqqh5CFVGbEGTMZA2YuLM4VLbRUKwjvD9UBYhzt
         x9aQ==
X-Google-Smtp-Source: APXvYqxWvfeu7/LSMKKYKhkYxK38R+2YVgnBYPzEJZ3bjv+W/V6SCf9AmAnMy/L0N0KnMLwcoOG80tlOQ6HUd2Ol
X-Received: by 2002:a81:994d:: with SMTP id q74mr2209556ywg.18.1553093519515;
 Wed, 20 Mar 2019 07:51:59 -0700 (PDT)
Date: Wed, 20 Mar 2019 15:51:19 +0100
In-Reply-To: <cover.1553093420.git.andreyknvl@google.com>
Message-Id: <a8766f523b5b46b7fa55a87ef55cd3fe6ab2d345.1553093421.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1553093420.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.21.0.225.g810b269d1ac-goog
Subject: [PATCH v13 05/20] mm, arm64: untag user pointers in mm/gup.c
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

mm/gup.c provides a kernel interface that accepts user addresses and
manipulates user pages directly (for example get_user_pages, that is used
by the futex syscall). Since a user can provided tagged addresses, we need
to handle this case.

Add untagging to gup.c functions that use user addresses for vma lookups.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 mm/gup.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/mm/gup.c b/mm/gup.c
index f84e22685aaa..3192741e0b3a 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -686,6 +686,8 @@ static long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 	if (!nr_pages)
 		return 0;
 
+	start = untagged_addr(start);
+
 	VM_BUG_ON(!!pages != !!(gup_flags & FOLL_GET));
 
 	/*
@@ -848,6 +850,8 @@ int fixup_user_fault(struct task_struct *tsk, struct mm_struct *mm,
 	struct vm_area_struct *vma;
 	vm_fault_t ret, major = 0;
 
+	address = untagged_addr(address);
+
 	if (unlocked)
 		fault_flags |= FAULT_FLAG_ALLOW_RETRY;
 
-- 
2.21.0.225.g810b269d1ac-goog

