Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-17.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BECE6C41514
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 17:59:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 71337218A0
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 17:59:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="Y7zAf+Eq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 71337218A0
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 20E698E000D; Tue, 23 Jul 2019 13:59:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1BFE88E0002; Tue, 23 Jul 2019 13:59:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 011188E000D; Tue, 23 Jul 2019 13:59:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f199.google.com (mail-vk1-f199.google.com [209.85.221.199])
	by kanga.kvack.org (Postfix) with ESMTP id D4BDF8E0002
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 13:59:26 -0400 (EDT)
Received: by mail-vk1-f199.google.com with SMTP id n185so19554950vkf.14
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 10:59:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=/huzVrn6iDinNK3gESNF6fMWuVj1J0a8E8YliY+JUMI=;
        b=KiTmb/ruzm+9gbt6yGtdwjnHRvOCphLd5zPlyl0Z//C203juD3WPN4xfuFTle5lnP9
         kJvZ2zeG5WdIItpCpSem6wI3bWCTK86jUG/K4SsZX1bWFglwxagMkryw/fT75YsPmawo
         Ut47ULPyIV9O1mVShsmGitPRP4iP3QmKbfdpuPPBcquLc3fO3eh3rukzhtHU6+HtvGC0
         LqBNlNbmiCk5pQmlY3lvIU7pxjO1iRwBhO649o0vcgN62T9auqcqYW4BpsYldHrph/4w
         ohqjtv/TK3L95aA0ef3XsG7D8AleaobUZwS5POzrKz7O191tVVmllXxBnyfZSfJYVkRg
         kkZQ==
X-Gm-Message-State: APjAAAWhdYqkNBgofsnAIZDOYnbFpVxQ0NhujLctjo3qiGLit3Cn0hk6
	Rycmx4/EnCQGDY8nT6G37Ana+GkapDfWKHmGm+9o9GR52em2uhxqMs2HpnlnWaNIAGk0nfdEnmJ
	9jcB7JKZzhJ++Vr4nQV+q+SVXAF9j4fppwOq30dQOu8q+IDnROa/Oav85vXa649X9Jw==
X-Received: by 2002:a67:e3da:: with SMTP id k26mr49810864vsm.131.1563904766620;
        Tue, 23 Jul 2019 10:59:26 -0700 (PDT)
X-Received: by 2002:a67:e3da:: with SMTP id k26mr49810823vsm.131.1563904766127;
        Tue, 23 Jul 2019 10:59:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563904766; cv=none;
        d=google.com; s=arc-20160816;
        b=Rh6NUfWhsVWn3ce04ub40MDfGehrtwkFIcW2B5bfB0byktCtsI5e1CCrAz7C/mWVeA
         6FGU87drdCYcpj5B1/d70nG6tgsVaJvPmwyiKNCNVEh+7NBV6X2qk78qIDKTBlIh+jCZ
         x7fpGN85SIg/nmxaPk5NDHtUHQxc7AckGHBpSuGAfQpf8azFfCHDE+5Q9QJgNaBgx0Tg
         e1Cu32f2kMAawiMRk5FBRQsCyD7AWKW7Zyv4GoIh3BTyKA2zheZgUTbhW2DvqNU+eNz+
         Z/ne/0pSOQ3phSMNrZ/IfwaVZH1ghY6un86hPhPkUOAChzZ92A6zWzksEcA97a/yVVxZ
         L7jg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=/huzVrn6iDinNK3gESNF6fMWuVj1J0a8E8YliY+JUMI=;
        b=kLgWvhFzFT94Gfa2GCvxnoshvhHaHd6qGuXHr3f4oxIw1d6vRBpadJQmbK1kW7N0JA
         QOwnXH3BsGxq/CSUgFdSQIRTYnG2zvWBx1QTSoaBfC6AN3g6N2kxAZ6PAw5Q+8v1VXR3
         NHk8MGQY4nmEg7KegEaIgCvLi1N2LjeU6tKVFZawWdEV8rfw+/D6SlSna15315Uak53Q
         5vJJJ1hV0Mkztuz8Niy8WxRIlC4ARSFSr7b8F3aYVf4Yk118UNw+7HEovujXx4dst+xe
         q/v3hsMhH70oOzThUoDoE/kWBQ1bJGjIOu5XRZYwvUh6/JVRPAl0NRcjdfD/6gIJy+9j
         I/pg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Y7zAf+Eq;
       spf=pass (google.com: domain of 3_uo3xqokcga8lbpcwiltjemmejc.amkjglsv-kkit8ai.mpe@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3_Uo3XQoKCGA8LBPCWILTJEMMEJC.AMKJGLSV-KKIT8AI.MPE@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id 111sor21746543uar.30.2019.07.23.10.59.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 Jul 2019 10:59:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3_uo3xqokcga8lbpcwiltjemmejc.amkjglsv-kkit8ai.mpe@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Y7zAf+Eq;
       spf=pass (google.com: domain of 3_uo3xqokcga8lbpcwiltjemmejc.amkjglsv-kkit8ai.mpe@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3_Uo3XQoKCGA8LBPCWILTJEMMEJC.AMKJGLSV-KKIT8AI.MPE@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=/huzVrn6iDinNK3gESNF6fMWuVj1J0a8E8YliY+JUMI=;
        b=Y7zAf+EqSsPzgFlPRtHiU2eaf3uvF3mBfxNqtK2dkyuo3VTBYXjjpviaGnsQe0yYUQ
         RZjdFooS3ZC7uUt58aVI/4cdpsAs60vswb3AsNKQ+PFZtVBvzHw5kY0TqkqeCmyj7riF
         mtQh5FnaNVG9iaAtW+G98/NdplTTfZ9IkSgAzb8usp7NHgKVNq41drkIZNhCHbFrZwbP
         oh8Z0GVIBTZb34XQapQJ/Cc8NMSc6thxgEsgQUYNQcR1lgRqwCY4KcosdJFpWo+DlmgQ
         eRBAMO05IGodFWFysR4D+7FGT50746wIbh4QySN2wsOGOenRi1KIej0OqRFaxZbG5kzF
         UnOg==
X-Google-Smtp-Source: APXvYqza4RkKEiX9RSMJ4O0WeYRSe7jZPKwJC2E9aqA1oTke3kgtphbjO4en0GBzP/IdlZCHDhS+pYVnwN9x8xEl
X-Received: by 2002:ab0:1c2:: with SMTP id 60mr34283049ual.78.1563904765450;
 Tue, 23 Jul 2019 10:59:25 -0700 (PDT)
Date: Tue, 23 Jul 2019 19:58:43 +0200
In-Reply-To: <cover.1563904656.git.andreyknvl@google.com>
Message-Id: <28f05e49c92b2a69c4703323d6c12208f3d881fe.1563904656.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1563904656.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.22.0.709.g102302147b-goog
Subject: [PATCH v19 06/15] mm: untag user pointers in get_vaddr_frames
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

get_vaddr_frames uses provided user pointers for vma lookups, which can
only by done with untagged pointers. Instead of locating and changing
all callers of this function, perform untagging in it.

Reviewed-by: Khalid Aziz <khalid.aziz@oracle.com>
Reviewed-by: Vincenzo Frascino <vincenzo.frascino@arm.com>
Acked-by: Catalin Marinas <catalin.marinas@arm.com>
Reviewed-by: Kees Cook <keescook@chromium.org>
Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 mm/frame_vector.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/frame_vector.c b/mm/frame_vector.c
index c64dca6e27c2..c431ca81dad5 100644
--- a/mm/frame_vector.c
+++ b/mm/frame_vector.c
@@ -46,6 +46,8 @@ int get_vaddr_frames(unsigned long start, unsigned int nr_frames,
 	if (WARN_ON_ONCE(nr_frames > vec->nr_allocated))
 		nr_frames = vec->nr_allocated;
 
+	start = untagged_addr(start);
+
 	down_read(&mm->mmap_sem);
 	locked = 1;
 	vma = find_vma_intersection(mm, start, start + 1);
-- 
2.22.0.709.g102302147b-goog

