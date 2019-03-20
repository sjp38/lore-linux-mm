Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2F793C10F05
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 14:52:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D6F32206BA
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 14:52:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="TRw7Yj5B"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D6F32206BA
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ED88D6B026E; Wed, 20 Mar 2019 10:52:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E64B36B026F; Wed, 20 Mar 2019 10:52:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C40EC6B0270; Wed, 20 Mar 2019 10:52:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f198.google.com (mail-vk1-f198.google.com [209.85.221.198])
	by kanga.kvack.org (Postfix) with ESMTP id 92AC06B026E
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 10:52:34 -0400 (EDT)
Received: by mail-vk1-f198.google.com with SMTP id x200so1065269vkd.0
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 07:52:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=75Sme861PZA/tNUQAzLBE6PJQCb9DBJI65KsoGIZxyY=;
        b=TmiB8MtqRBd3NKh/x4XoL9szu5PGReSwvyL5s5M7IIoj8s4wLe1JAu9rbmWPq+ufY/
         axk27VmP+3N6Ruxrzt9EbrLWLo8BD/lSpSitVIuX1mXRoSz6dZ1pIsDrmw75+fMf+cQv
         ExfAAjdqUWa60LhBmWtKWSp6/oPLFz+Cuu5FMZucCUL27g0XThIBGFUArvT6ZTutfO58
         kmI4mx+JOudYuLaSXhs/GpxXVzkpNCsVr5O3ltHyCLBeUbEspNKiO3rin1gTbq/rut7j
         WbTlGdHVf9UtRoQT0utZy0zyXm/8USDUyyK8+WjmffrwDMgN8hMAeHEcpIKTw5hrQMuR
         vyYg==
X-Gm-Message-State: APjAAAUwHaPkBNnW9H7QVHQzlt0BebObtop+XMwBn/3FY2Ku7k+TnSQZ
	RDCVhd2HLaiTfNXa3p1qppS0UlJKauxiEN6X0/bibmxM3JnrchJ6MNT1qhrfmgG+FD7jmtL+do3
	jH/1McxstLEk7j4WKOD6M1vvUZt2tB6Wb5w2sCZJvmLWZDfDA3j8cdIvmf4T+tWMCsQ==
X-Received: by 2002:a67:f41a:: with SMTP id p26mr5056497vsn.140.1553093554344;
        Wed, 20 Mar 2019 07:52:34 -0700 (PDT)
X-Received: by 2002:a67:f41a:: with SMTP id p26mr5056467vsn.140.1553093553598;
        Wed, 20 Mar 2019 07:52:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553093553; cv=none;
        d=google.com; s=arc-20160816;
        b=piD6WxnBB9MDxQqNUSeX7xNlb2UbPGuvolmZHpB7NxbTOhHMNP0az6gcfWYQe13jj5
         LLsy7hZmuW3V0/SQI8Srjzuhi5wZQqRFpEF8LHrpq68ek2YHTwgMt9vqt5mjfr7KAx9j
         QmQNYpksu1wg9Rgu6ZiIzDVXgcEP1rj7WheZ454RPHDDiszPqbufMw0WUKeZtoeDoCcv
         zjQvET6VDkdSQ3rCjhBnd7dXxKly5tgj6bN1hl3X2bluu/rnDVm1UVNlxEgCCWNf3bhT
         qg/kMK2TKuC/QdZjFSvWWvHElTBa0Mj2wCbc9LKr56KZ1MXqLImizM7SXTYsv2zgTDkB
         X+DA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=75Sme861PZA/tNUQAzLBE6PJQCb9DBJI65KsoGIZxyY=;
        b=ohaOz2C79+PyHlOCE3ts3kquXSgL3nWkNQD0LWq65skY12sQVudwL82KcPdbEGPcUR
         pKf8RyqyyiCeB0u59CLLKRK+McW2g/MvUIAchosm3IMLRkhhwGVmPeuHEUBZOFKfZ5OD
         v/SJ4tGB8egJH+vc6YHMeCSiEJm+EFSN0KDdauM9LLu7SxvjCnhBXRYWCSR046MVgEqv
         oK9KCMrhLmBa9xYDaeIpe9a79JfJAqbKn1WT4885TY4pBlxvAQ+qVJY1KqtDltYlUU9D
         zXhhP58GLRQKpQLvLpRjJeqhwGBqvyiY33FRxFU30G8pkonnIJXxnaDMIMqYqrnt70wu
         GjGw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=TRw7Yj5B;
       spf=pass (google.com: domain of 3svosxaokciwq3t7ue03b1w44w1u.s421y3ad-220bqs0.47w@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3sVOSXAoKCIwq3t7uE03B1w44w1u.s421y3AD-220Bqs0.47w@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id q136sor1195271vkf.33.2019.03.20.07.52.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Mar 2019 07:52:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3svosxaokciwq3t7ue03b1w44w1u.s421y3ad-220bqs0.47w@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=TRw7Yj5B;
       spf=pass (google.com: domain of 3svosxaokciwq3t7ue03b1w44w1u.s421y3ad-220bqs0.47w@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3sVOSXAoKCIwq3t7uE03B1w44w1u.s421y3AD-220Bqs0.47w@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=75Sme861PZA/tNUQAzLBE6PJQCb9DBJI65KsoGIZxyY=;
        b=TRw7Yj5BILFy1o0Gjs1P7PG7K0bXvmZQkYhNUVzGU7eBwuMllGXuOholy2EFVltyM4
         Eq2uq+97Zf6uwJS8d1ZdNFpiTnL8SNlpOD4sWLxmZFbN853Lcc52HrY3CkqYjTrkgvv3
         P6+/fIjezdNUVDfMCm7BsfzV0JBhv6f1w4D1u9PxEoZJ5VL6MOfN4r5Co6Q9TCpikOXk
         ufVXz2a0Bri+ZzG/0QUwT0FF9pQ83mZbCp5f+6lD7JfSPjUlslIphqktlFrt8/uqaCtx
         xvHcpr2f1Cv9vpNRpKRy3dnpc0Pr4AZKm48fkJGsVCh95A9tTuAmJvWLp4Ouo2pSZNMk
         pVyg==
X-Google-Smtp-Source: APXvYqzSD9kzbCxXB1NhkO2CDkCTaQO/WiJog4chzbyr47Ky/uMyCpQjT2x0YU1fYyYTJNw37CTZ8G4iAZNpW0Wl
X-Received: by 2002:a1f:c507:: with SMTP id v7mr16491493vkf.18.1553093553224;
 Wed, 20 Mar 2019 07:52:33 -0700 (PDT)
Date: Wed, 20 Mar 2019 15:51:29 +0100
In-Reply-To: <cover.1553093420.git.andreyknvl@google.com>
Message-Id: <038360a0a9dc0abaaaf3ad84a2d07fd544abce1a.1553093421.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1553093420.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.21.0.225.g810b269d1ac-goog
Subject: [PATCH v13 15/20] drm/radeon, arm64: untag user pointers in radeon_ttm_tt_pin_userptr
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

radeon_ttm_tt_pin_userptr() uses provided user pointers for vma
lookups, which can only by done with untagged pointers.

Untag user pointers in this function.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 drivers/gpu/drm/radeon/radeon_ttm.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/gpu/drm/radeon/radeon_ttm.c b/drivers/gpu/drm/radeon/radeon_ttm.c
index 9920a6fc11bf..872a98796117 100644
--- a/drivers/gpu/drm/radeon/radeon_ttm.c
+++ b/drivers/gpu/drm/radeon/radeon_ttm.c
@@ -497,9 +497,10 @@ static int radeon_ttm_tt_pin_userptr(struct ttm_tt *ttm)
 	if (gtt->userflags & RADEON_GEM_USERPTR_ANONONLY) {
 		/* check that we only pin down anonymous memory
 		   to prevent problems with writeback */
-		unsigned long end = gtt->userptr + ttm->num_pages * PAGE_SIZE;
+		unsigned long userptr = untagged_addr(gtt->userptr);
+		unsigned long end = userptr + ttm->num_pages * PAGE_SIZE;
 		struct vm_area_struct *vma;
-		vma = find_vma(gtt->usermm, gtt->userptr);
+		vma = find_vma(gtt->usermm, userptr);
 		if (!vma || vma->vm_file || vma->vm_end < end)
 			return -EPERM;
 	}
-- 
2.21.0.225.g810b269d1ac-goog

