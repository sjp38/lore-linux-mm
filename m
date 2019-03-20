Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7D1BDC43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 14:52:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 35A712146E
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 14:52:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="cS/GWV3n"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 35A712146E
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BA4926B026D; Wed, 20 Mar 2019 10:52:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B2D5D6B026E; Wed, 20 Mar 2019 10:52:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 97EE96B026F; Wed, 20 Mar 2019 10:52:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f197.google.com (mail-vk1-f197.google.com [209.85.221.197])
	by kanga.kvack.org (Postfix) with ESMTP id 627C56B026D
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 10:52:31 -0400 (EDT)
Received: by mail-vk1-f197.google.com with SMTP id 5so1031392vkg.20
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 07:52:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=m8A/eWnO1t/szRUY+Sf0prGvVhEq1OhdUwg16kciR9Y=;
        b=JaomkFo/Hv7dJ3Gn1FbMVAOFzuwR/U8kx3hUAisMdy5QvmKn9kxynz9FgCx7hWw3vg
         i4FkpiabaDWW7tB667vMpKLQ/6wofLaQH9hn16DbeTmB2BfzhOTPpo+RzL4cKew9lhtR
         NQmI0q8rnK1I2dQhCR+/ETR4aMZ+vCQRpqUnSumeYPbqTFJujpoHWEIqGUbsZK1DwM9k
         vxPIAgEO3fNX2K9khrRXtdBc8CJuS2rQpfrFFT0hB/uZ4TVBTP98uY9lRw6K04lcA55X
         WS3KaEtXgHWcYerLLwbqgd8X4FSJjmLBkgv1VwTKJN0SDyz6TrvLobJzip3YAzqeNbJa
         co/w==
X-Gm-Message-State: APjAAAUBi+fQXx2hgUVTg/GdBpqrRpK03VX9O3WpCKhtU5cQB8QxOyYK
	dzq1Behd3UQSgMVOaAtXk7avrTxNc3a0zxmUbLVmvip1iDDCfYQA2fwpCm6n5u0VC1+L/FVXR4F
	Nj/4Xq8NbpEYiGYd//55T2T27aqhU+eFhDoUXEV1Ar6+8Ew9N/ZJ0mDEtsBe5/xGCIQ==
X-Received: by 2002:ab0:2712:: with SMTP id s18mr4464166uao.114.1553093551117;
        Wed, 20 Mar 2019 07:52:31 -0700 (PDT)
X-Received: by 2002:ab0:2712:: with SMTP id s18mr4464137uao.114.1553093550398;
        Wed, 20 Mar 2019 07:52:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553093550; cv=none;
        d=google.com; s=arc-20160816;
        b=kiGZwk5mCEFVsA6uqWey9RzEXh6c3FrjOfoMcRVVagXVy3C7/wyknUvD2/qWhqtZqV
         XCmJFGOB+gmv8bonUisfqQaxxxYVICvY1je0Blcgg6FrU7xpbgkLAvtSUdbIRcrCid/m
         wT0PNLWVtVI5sAn8hJ3QnKEikNWKc5cVndolrKkd5KKkX24Yy5duOkwllP8HCzPxpDam
         01FMIDIUj+4/BWXf31RYHrUN0deYHegaD3g2leSV88rqmPevifO6vwiyenYYCffj4blw
         3dlbaJFjs3Vvdvnz4/nf9+4J3YXqnpS/V5FVz/Szyn8bLDR5tpbi9cXTteN/OzMEnHvN
         tiqA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=m8A/eWnO1t/szRUY+Sf0prGvVhEq1OhdUwg16kciR9Y=;
        b=WQA7mITZ6w8+5teToj/ZG6zRgEigthAeK/yGY126gX/lpRR5Bt5QaTiUM+iUzR1MCw
         pv4a0Grwu8GboBzCU6T6GVQhSWqRbXJ3A92gUTocSEHeM7NWE/1C10Xdb33d+D0x4WiI
         b/4OdF6yISC+ghRdLow2muJYEKyQAsFXoy78+MlTl5F+f57nZ9F11+ptslokwn4AtAin
         0L55fwlKwvTm26CXK412JFxv8yHfOmsQcXk31lJ3qOQqvkumTpwzn5ZLMgBGhY/8M6Ph
         WpQ8kbtUFwzwnpa0iMxmBOpR3kIMFQloCZ4Lq3y2eOD6HaJFTZXYa+f40ixWnm0JA9Sb
         y83Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="cS/GWV3n";
       spf=pass (google.com: domain of 3rvosxaokcigmzp3qawz7xs00sxq.o0yxuz69-yyw7mow.03s@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3rVOSXAoKCIgmzp3qAwz7xs00sxq.o0yxuz69-yyw7mow.03s@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id a11sor1321772vka.18.2019.03.20.07.52.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Mar 2019 07:52:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3rvosxaokcigmzp3qawz7xs00sxq.o0yxuz69-yyw7mow.03s@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="cS/GWV3n";
       spf=pass (google.com: domain of 3rvosxaokcigmzp3qawz7xs00sxq.o0yxuz69-yyw7mow.03s@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3rVOSXAoKCIgmzp3qAwz7xs00sxq.o0yxuz69-yyw7mow.03s@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=m8A/eWnO1t/szRUY+Sf0prGvVhEq1OhdUwg16kciR9Y=;
        b=cS/GWV3n1i5lKwRxDER3D1j30wbKLrIjlKCprX6vTMe8cTVCKT78AfLte355OG84/3
         9+SHdUMKMpHe6+iOH3VzHT8pjZaRW6z5pqFcAKCDTvZf0KT3SG8dydvzjoFsqtcRHpO+
         s7SFViAVxLm68wpAwuS47+5QK7VNwFMa5b5lxPhRs6N/VfdBIHBgFKkHSvd9I7PtKYIh
         RebKnvIoWsQx14IlpHTag2G1jk9EWaN7+3KeAj9wdOKQHYUJVkQSYeiCwVLs53b9gTS2
         jR0wtaevF8SL4RJoxbCrc5cwPvE9OCqov4p9AQcvaLAPdf8xImWPv+ch+hRrKoxeSje1
         7BOw==
X-Google-Smtp-Source: APXvYqw58aZo87dG3fwjMiai1M3z5FY5q/6ly8PoJSCWFGZ15x+DIhLzfcwRQ16QrQdSY5QNXUz25VoApSfh8lGu
X-Received: by 2002:a1f:c507:: with SMTP id v7mr16491398vkf.18.1553093549995;
 Wed, 20 Mar 2019 07:52:29 -0700 (PDT)
Date: Wed, 20 Mar 2019 15:51:28 +0100
In-Reply-To: <cover.1553093420.git.andreyknvl@google.com>
Message-Id: <017804b2198a906463d634f84777b6087c9b4a40.1553093421.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1553093420.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.21.0.225.g810b269d1ac-goog
Subject: [PATCH v13 14/20] drm/amdgpu, arm64: untag user pointers in amdgpu_ttm_tt_get_user_pages
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

amdgpu_ttm_tt_get_user_pages() uses provided user pointers for vma
lookups, which can only by done with untagged pointers.

Untag user pointers in this function.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c b/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c
index 73e71e61dc99..891b027fa33b 100644
--- a/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c
+++ b/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c
@@ -751,10 +751,11 @@ int amdgpu_ttm_tt_get_user_pages(struct ttm_tt *ttm, struct page **pages)
 		 * check that we only use anonymous memory to prevent problems
 		 * with writeback
 		 */
-		unsigned long end = gtt->userptr + ttm->num_pages * PAGE_SIZE;
+		unsigned long userptr = untagged_addr(gtt->userptr);
+		unsigned long end = userptr + ttm->num_pages * PAGE_SIZE;
 		struct vm_area_struct *vma;
 
-		vma = find_vma(mm, gtt->userptr);
+		vma = find_vma(mm, userptr);
 		if (!vma || vma->vm_file || vma->vm_end < end) {
 			up_read(&mm->mmap_sem);
 			return -EPERM;
-- 
2.21.0.225.g810b269d1ac-goog

