Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 33C98C43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 14:52:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D0C992146E
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 14:52:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="UEIrebSo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D0C992146E
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 741716B0273; Wed, 20 Mar 2019 10:52:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6C0166B0276; Wed, 20 Mar 2019 10:52:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5605C6B0277; Wed, 20 Mar 2019 10:52:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0BFDC6B0273
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 10:52:45 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id e5so2900946pgc.16
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 07:52:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=f9ERttYki6e1riSpYQlVbWsSBMZZ5wUdNGpNySk9y5Q=;
        b=UYFdrapuIH3Vf2V9DKNiUzhJ+EJNizpIxDLjblQXwUO0kKM+vMwXjUoAze3WAqLihy
         VNztHmISYoY5yzSGfyJ30DdCxki071bSq5Gzk/LFl+eo+zce9+FtCzf1SUpE9asFlR5c
         sqfTrDQsrf32zDIQVwNV2KhMOcJMjvERI3wsBBysrLF7NYKz2pkEFM3kSO4wwpx5iM/X
         Pz4MZS+2NFXYe42chSKlI6ZCUi1xAxjmPr0/3sieYKEnnHgdkqQyJkzWisf/VS5Q6/X4
         YDQ3vFKCKh6JJlTs2A8pAQuY2yrBS76Rphy73OXyzMve5eP/4g6nmc8hEFXENxYqUJN7
         GefQ==
X-Gm-Message-State: APjAAAW9QSjXO8sw/vOMRdQ9tiZGlv6TyCAUZJzOglh30S+XpqDLNh4I
	hLSs4nVvGgosb4dP8i/CvJig39gd9O1ovJZYq1PFYtJcpucC+tl3Y5aCd3+2Jtj01gzi0WGhuLY
	s9WzX8fey0YkC+xir3xKomVLM8/QLt8tRAC19aiwXtHwYJYiSLKaDsVVboUPEd3P9cQ==
X-Received: by 2002:a63:b52:: with SMTP id a18mr7878045pgl.393.1553093564568;
        Wed, 20 Mar 2019 07:52:44 -0700 (PDT)
X-Received: by 2002:a63:b52:: with SMTP id a18mr7877978pgl.393.1553093563681;
        Wed, 20 Mar 2019 07:52:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553093563; cv=none;
        d=google.com; s=arc-20160816;
        b=PHQXGCLHFrU4sOvEuxZjpoC0V7BJ3ZuZa666U+htgKMGx66rFHFxHAhr9lmR9JfNjG
         iIvqapek0jX+tyDKRDwrdxtJGvIML/nBqYxIFY9mwNcHh4OWn4sY/JkoMm890cLPbEir
         1deXO4jDUlmytP1JIQHi/JjIdr3wckNld5fComUmVSn4BVKj19hrWneXLxUM0+FcHwhn
         bbQkyQxl+YMBhvB7JJ83kKEvJ3VYKVTZe6gyY53fMD1BdRY6ioKIYMTm3IoO46ovmq/L
         p6wo9pvRt6g7GBEIF0F5cE2nQ6YJ3zEiapv+wrMwCDaz6G1sZxHGpu2lwPfJPPiWHuNu
         AXmg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=f9ERttYki6e1riSpYQlVbWsSBMZZ5wUdNGpNySk9y5Q=;
        b=TPHLQndA8pvw6mzEghAF+xRcxWlha7c6+TdRQccDiApVPdVAA3Kd+2kr6FSXq1NgSV
         Nij+sWdubay1rHUS4l/U7Dw6XCrI3SmDDcm4Eie+UkDKVYwYB3MvKlzcyUAyaWTt6sog
         xqf19754O/S5S7I7VO5xsqx2lqZYErHax3eEXLXdNnnG0jIPggwcOFvXXiy499QISbBd
         zfhwwDyEmpC6fSAG96szGZcyVBnjsQLUX7kwi6KzwpB6to5KaL/sticR93yQ45l/0zjl
         ni1tpxhTSbf/2fcVe0mn6ZKM59Td6KyompY/l7W0kJOagCTCXxHPuWCXGIezm63KfDHP
         m0TQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=UEIrebSo;
       spf=pass (google.com: domain of 3u1osxaokcjy0d3h4oadlb6ee6b4.2ecb8dkn-ccal02a.eh6@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3u1OSXAoKCJY0D3H4OADLB6EE6B4.2ECB8DKN-CCAL02A.EH6@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id h128sor2526966pgc.33.2019.03.20.07.52.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Mar 2019 07:52:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3u1osxaokcjy0d3h4oadlb6ee6b4.2ecb8dkn-ccal02a.eh6@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=UEIrebSo;
       spf=pass (google.com: domain of 3u1osxaokcjy0d3h4oadlb6ee6b4.2ecb8dkn-ccal02a.eh6@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3u1OSXAoKCJY0D3H4OADLB6EE6B4.2ECB8DKN-CCAL02A.EH6@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=f9ERttYki6e1riSpYQlVbWsSBMZZ5wUdNGpNySk9y5Q=;
        b=UEIrebSocaYvFV95VdsGvR0rHtsKUFScYsCVqiArhFekiKhlWYwiMy63Q0mC7IZj9p
         3mqU7Dbhm6OqOVB4ThhETYV9ikDo0pqEW49iSRluDE7bkzQRnUB022yUHTxms2owX+51
         Hl02fMI+fjjQXXTnP9hJUKytXL22/eMlF/bW9F6Y2oo6WfEnYpRt49Ftd9iSm88pEvyR
         KMbIbd0h7q6Pew5AmmXiW7TnoUcvWa8wf/gj7ZnzJQoLjgL/IjA++G9JudTdsHLO21Cq
         CbofADar+N5IG2433ecku3GOiSdWNlbt2i7KcQfTHs/DmBtW8hG6MdXe8FPq3GsM/Hb6
         HDrw==
X-Google-Smtp-Source: APXvYqw7j6q1fx3m56nHOtW1Q2mzw9Sw141YoRGaaXVbYutXBT4BRu1TSW8d2p37GhTJbzzsOqgRxlx9WtXnbKVc
X-Received: by 2002:a63:2ac2:: with SMTP id q185mr3933319pgq.119.1553093563022;
 Wed, 20 Mar 2019 07:52:43 -0700 (PDT)
Date: Wed, 20 Mar 2019 15:51:32 +0100
In-Reply-To: <cover.1553093420.git.andreyknvl@google.com>
Message-Id: <665632a911273ab537ded9acb78f4bafd91cbc19.1553093421.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1553093420.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.21.0.225.g810b269d1ac-goog
Subject: [PATCH v13 18/20] tee/optee, arm64: untag user pointers in check_mem_type
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

check_mem_type() uses provided user pointers for vma lookups (via
__check_mem_type()), which can only by done with untagged pointers.

Untag user pointers in this function.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 drivers/tee/optee/call.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/tee/optee/call.c b/drivers/tee/optee/call.c
index a5afbe6dee68..e3be20264092 100644
--- a/drivers/tee/optee/call.c
+++ b/drivers/tee/optee/call.c
@@ -563,6 +563,7 @@ static int check_mem_type(unsigned long start, size_t num_pages)
 	int rc;
 
 	down_read(&mm->mmap_sem);
+	start = untagged_addr(start);
 	rc = __check_mem_type(find_vma(mm, start),
 			      start + num_pages * PAGE_SIZE);
 	up_read(&mm->mmap_sem);
-- 
2.21.0.225.g810b269d1ac-goog

