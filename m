Return-Path: <SRS0=pZwQ=TG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,T_DKIMWL_WL_MED,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C6925C04A6B
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 16:31:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7EDD52087F
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 16:31:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="Gh9uHUEw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7EDD52087F
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6F99A6B026F; Mon,  6 May 2019 12:31:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6D1976B0271; Mon,  6 May 2019 12:31:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 599D96B0270; Mon,  6 May 2019 12:31:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 395BF6B026D
	for <linux-mm@kvack.org>; Mon,  6 May 2019 12:31:33 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id t67so14998914qkd.15
        for <linux-mm@kvack.org>; Mon, 06 May 2019 09:31:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=9noxdAH/DJOJ2FYayyiyYQz8DnKHvszaUU/XpncZrgo=;
        b=b2f7ojp03t8yJZeN0d47BisPkT0zr5CWPzpb3L1/5tRQunhGQ/kWIHKW44UlMxT1T4
         qSMOVEFxdrCUg572ZGvGisc1K7qFd/K2ahc8YD8cIJTpi/3ZhRSvKPTFpyhRjwdqr+EB
         ehsQZuq5WLGXJhmzu8B1tNNl4sT8TeCyxXS0NhsUCDjnO1QAcaEfyiPQXktBuWaI5Bpv
         x9ZEPzp7LVRzjA3PCaP8U5ESklkdmCt0hLADGgbnqcPJyRxRK/eynRP+iJSRsaic9VgL
         fwVpMtLKLzwqxEQZPIV6Z2qF7dwR9uhXwt5DA+Eztl5ezpozBnIlMIvbLs6hopJTvLIJ
         A4Xg==
X-Gm-Message-State: APjAAAW8CSJDV9utfvVtXu9Khfrb+iC3qpfL6t9Ty7btNZ+N787XJSy4
	DDlMTUoAbDjjCHJ6Ta4EPK41u37p+5+CWJcDEG/2ske63p8mXH3Qww1E2Kg2O6hXhUpV1DDQBNj
	7z+EeZASsgAnuIJ1ZfxgedcZ9Mu8C6oKCTn8MpQs0arvNd9UxF5fc6OqC9PnlTVs+dQ==
X-Received: by 2002:a37:495:: with SMTP id 143mr8724456qke.106.1557160293001;
        Mon, 06 May 2019 09:31:33 -0700 (PDT)
X-Received: by 2002:a37:495:: with SMTP id 143mr8724376qke.106.1557160292000;
        Mon, 06 May 2019 09:31:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557160291; cv=none;
        d=google.com; s=arc-20160816;
        b=ZW/V8Bv6Wo6q4/zD+4Ie7GhIie+b9eYUOeMXcRU0zF7BFkb5dI/l93AMrVOAxnbyNY
         GdFHeC7pNz9+Muh/mqTnyABEahS2cKPMvI+MDZtTxncG+JSWCJvLXhI6RJJJ8FD1jdR4
         eR3Sv9jl+Bt4mSZ8HfnRlLrynDH6P2pFBYBRormOprDaU1/KhRlaj2MQWSEhNjm3+Ipm
         yWSrSDMZ1JGbiZk4M/jSiTOUCaJzWbJj1iNW37Ht2LM7tuAgioOZNPqAIoePCFZEBUkj
         B0WKhpxDJWwAKbGxv0AbDpTU7jhkMLxLxF3VSD+dSn1KD0inU6mU17PU+xjM71JtfMzC
         UtVg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=9noxdAH/DJOJ2FYayyiyYQz8DnKHvszaUU/XpncZrgo=;
        b=Ww9NGaqfnWI+88JqnZrmBD3W6a7Ty79pv31U9bKRnvZ7LVAC3eryq3+S0Me6o81GeQ
         RFPw4F0ZYb8871cDSzi+DwwmGqJV7LfjHdX/8KxsIsk1sqRf0ZHVZFPgSroXn4E5Rtdx
         8yKqYscyRsmXUo0J5eba9+JXJZoaOZaABQVOfaAGSN6N7ZBlKwve957ZDnJynvok4R56
         FkYdc9PV+qQMSOZhNqvJHakGk02JEKxrDPp5FjeWesbHTp9GdqSy4Ziq6+QQ5L1WC68x
         7M8pwpbVPWyeEmFh08FsAfgYDP3rFn9u09Ou1Ribn/uRrtKAdhc9ZyFoBSqthrYxRjdk
         ckZw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Gh9uHUEw;
       spf=pass (google.com: domain of 3y2hqxaokcfqw9zd0k69h72aa270.ya8749gj-886hwy6.ad2@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3Y2HQXAoKCFQw9zD0K69H72AA270.yA8749GJ-886Hwy6.AD2@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id z6sor8672887qve.15.2019.05.06.09.31.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 06 May 2019 09:31:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3y2hqxaokcfqw9zd0k69h72aa270.ya8749gj-886hwy6.ad2@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Gh9uHUEw;
       spf=pass (google.com: domain of 3y2hqxaokcfqw9zd0k69h72aa270.ya8749gj-886hwy6.ad2@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3Y2HQXAoKCFQw9zD0K69H72AA270.yA8749GJ-886Hwy6.AD2@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=9noxdAH/DJOJ2FYayyiyYQz8DnKHvszaUU/XpncZrgo=;
        b=Gh9uHUEwhI8X3KH3oum4TP3+K5YcLVeFgNxy28sxooe9hD0KxqO+/9bu9ASe+gwO9m
         +npnzk9MzBx/G95AnHz8npJA2JLqfUYczohkOpf1cDAEGWB/X7jH7ATuoeQyoUMeyaJE
         M+s2UJpwoXBo6kJQ8MvPZRd/OM9IAl3ZUMX+L/PvePvsqcjFIcb/KoU1n2dvqK/g4dyS
         WX9LAM4MfJzSphXX3HTjOHZ2WfucwXBSdBhXaGaeltxjREoqu7g25XXVhrt4uPYNQRup
         Pi925C63hraEJZZpZwP5S6UZPdegfoPkW1yuXxVcy9QEkU3hg9EUu8QmKcerWhcvmd7i
         pz0w==
X-Google-Smtp-Source: APXvYqxoF+XMyoqlEFPsaust8CXG+VIOr8CluDz21rRB5hrxS5C2Phu1lQB5er/vngGdw0Qf3GTM8MJuymHjvFcO
X-Received: by 2002:ad4:540b:: with SMTP id f11mr5876305qvt.42.1557160291702;
 Mon, 06 May 2019 09:31:31 -0700 (PDT)
Date: Mon,  6 May 2019 18:30:54 +0200
In-Reply-To: <cover.1557160186.git.andreyknvl@google.com>
Message-Id: <b658f78360e65a7045e4f071b29f921885e72048.1557160186.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1557160186.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.21.0.1020.gf2820cf01a-goog
Subject: [PATCH v15 08/17] mm, arm64: untag user pointers in get_vaddr_frames
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
	Leon Romanovsky <leon@kernel.org>, Dmitry Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>, 
	Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, 
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, 
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Robin Murphy <robin.murphy@arm.com>, 
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

get_vaddr_frames uses provided user pointers for vma lookups, which can
only by done with untagged pointers. Instead of locating and changing
all callers of this function, perform untagging in it.

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
2.21.0.1020.gf2820cf01a-goog

