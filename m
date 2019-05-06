Return-Path: <SRS0=pZwQ=TG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,T_DKIMWL_WL_MED,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F21DCC04AAD
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 16:31:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A88AC20B7C
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 16:31:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="MxkQGAhZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A88AC20B7C
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 39F7D6B026A; Mon,  6 May 2019 12:31:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 34F376B026B; Mon,  6 May 2019 12:31:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 240516B026C; Mon,  6 May 2019 12:31:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f200.google.com (mail-vk1-f200.google.com [209.85.221.200])
	by kanga.kvack.org (Postfix) with ESMTP id EB01E6B026A
	for <linux-mm@kvack.org>; Mon,  6 May 2019 12:31:26 -0400 (EDT)
Received: by mail-vk1-f200.google.com with SMTP id l85so6138352vke.15
        for <linux-mm@kvack.org>; Mon, 06 May 2019 09:31:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=ngD1QIqwofb3Y9K5MW1PYIryx3q7PiTEQfc6RhUnaA4=;
        b=EYJ03XKdLVChrt46zSe1zUXCvmeoxZquJm0XrZqT9MKa2x4kFjhWSrnYt1FP+D8lH1
         DaantwY7eWpepA4Dxn3NStGvxJcVUB3czUMzlZqK5XrG5dIHCleyipqTqsFgZcq+Zqxd
         i0Ko6uwb3Y2NSetAjQwyeMvOmV0hMb9i40VXmThg15WMpYAYpTC3ns0OOoBHrdSoahPH
         XLG9dUPMb9MnVz2hv51oh/Ap9A2YiZoGj0ONEilj84xLRW8pbLjgqXad5z5Y5HyDXRAp
         hTN+DbGQQxKTg9uaRRgh0Lpa5Tlg7YDMkv6YJ+lU2MVzFeSSH++iP7S6RlafdpTQO5XI
         BfBg==
X-Gm-Message-State: APjAAAWRzK98gO7840zX3APA9KfwRMwHe9gT4jkDQw32VfTPH4ElvU61
	cLs6KhCR3J6F3NIJ+eQAIffOhXM1Or5VyyE2bYLtG9SiBTFb6vZYA4E2d/okNfBoNw46UtANJRx
	9Vl/ZYM4p5uE0upOH2B0oQekqlz1LAjPoum4f+oeCjCYB6augCZDfLP3zX8ZhwI/LrQ==
X-Received: by 2002:a1f:aa81:: with SMTP id t123mr9008697vke.44.1557160286624;
        Mon, 06 May 2019 09:31:26 -0700 (PDT)
X-Received: by 2002:a1f:aa81:: with SMTP id t123mr9008639vke.44.1557160285952;
        Mon, 06 May 2019 09:31:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557160285; cv=none;
        d=google.com; s=arc-20160816;
        b=RgkEyqE5wTx1Scc1I5vmpuqaKoe2hge1SyAsezF7FX5xEhAxg+fQm8YefEd6BTUFu9
         3bAVjaTXoqkivGlNJ9jDvnfPiUN/yEqAkRyzNltGwaH3vXeFaI8yvneM3LS5em2a5TWA
         bTzYK0UY5CWgClHdn9xdL/XxAMqmDrgfyeUzT0nFzRIn1epHz6wguR99mm/4VkEWVJFr
         6thM19SAsM0/AzmHgZ22F+GDlNRaC3cOXJpeZmTz/JWZv0L4OvkCDAJw9TrIPsEmToOD
         aL9/IEvQ2VRqgkDNKKce2bY63S/sBZJjNkPS4G5EWqi7QDGwBmizEsvtUyezPr/i6RJu
         6Tlg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=ngD1QIqwofb3Y9K5MW1PYIryx3q7PiTEQfc6RhUnaA4=;
        b=kOW3+zLVecC6Whv1sZcNSebkro3iZpU1kjOrm/kqEoCMylDX7rKH/icep/Ud7Mk1tX
         YFGGuetUM7fykqiQh5kL+S+4AgtYDkQo4QIhBVkPHJclkcDWOKIB/7BVli2pRffQ2rFK
         guJJ56zbjVz/7eDmIBTwVTvQsRLY3Rm29CUbSTvqPNbx/LbjVR06EFG4AupOonXGElhs
         GMY2Fzo1m5gaALmtQYZvX2To6u388J3iNwq5X0gXJMXc+NsWOr2VW8WJhpRNIGdQusUc
         BhDeiPHGZx03A8t0f6nf3bAi/Yy0vbQWDTenoHVtcAqzmR5vOUts335m8UWf200yJyR4
         cpJg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=MxkQGAhZ;
       spf=pass (google.com: domain of 3xwhqxaokce4q3t7ue03b1w44w1u.s421y3ad-220bqs0.47w@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3XWHQXAoKCE4q3t7uE03B1w44w1u.s421y3AD-220Bqs0.47w@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id s12sor461211vkf.53.2019.05.06.09.31.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 06 May 2019 09:31:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3xwhqxaokce4q3t7ue03b1w44w1u.s421y3ad-220bqs0.47w@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=MxkQGAhZ;
       spf=pass (google.com: domain of 3xwhqxaokce4q3t7ue03b1w44w1u.s421y3ad-220bqs0.47w@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3XWHQXAoKCE4q3t7uE03B1w44w1u.s421y3AD-220Bqs0.47w@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=ngD1QIqwofb3Y9K5MW1PYIryx3q7PiTEQfc6RhUnaA4=;
        b=MxkQGAhZKcdMVO3IoBudATPab8TcsjZXX55HRiAN6IeYJiwC1j+iSqld+LLo8qyTyU
         J83cHqvwCOHlnCBK8LZqFG9H1aqF9NgW/OCa1+Ffyx8ZPU7n9taYd+4siYtOtJGSGqfL
         2bs1HGMZCs+84KfkjQ03uml4i8KyBdYF3wjbHGyt6HNd/mpMm+1Qp1No+KcUfeHVzCH2
         4161opexQWrAtxUlTCrivmQSMNxZ99d5aHCBZ5OmsHW7nAo6evlOzv9F19PFlipvMxI4
         C4R/T1FLs15dBoQSeJwhzGqmh+Swz0oYJVhSbKReuunpnwRMPL8ZC0ZS5QHAp3xWLkRd
         Hr1w==
X-Google-Smtp-Source: APXvYqwpCSWnm5qxXyuaWGAqRu95+6gB9zDmbHbxq+0Vb45FEs/ziN6+T3PbyTnxcvdIphfk21MnSe6Qp4R1y+WG
X-Received: by 2002:a1f:b45:: with SMTP id 66mr13881567vkl.38.1557160285529;
 Mon, 06 May 2019 09:31:25 -0700 (PDT)
Date: Mon,  6 May 2019 18:30:52 +0200
In-Reply-To: <cover.1557160186.git.andreyknvl@google.com>
Message-Id: <474b3c113edae1f2fa679dc7237ec070ff4efb70.1557160186.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1557160186.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.21.0.1020.gf2820cf01a-goog
Subject: [PATCH v15 06/17] mm: untag user pointers in do_pages_move
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

do_pages_move() is used in the implementation of the move_pages syscall.

Untag user pointers in this function.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 mm/migrate.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/migrate.c b/mm/migrate.c
index 663a5449367a..c014a07135f0 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1617,6 +1617,7 @@ static int do_pages_move(struct mm_struct *mm, nodemask_t task_nodes,
 		if (get_user(node, nodes + i))
 			goto out_flush;
 		addr = (unsigned long)p;
+		addr = untagged_addr(addr);
 
 		err = -ENODEV;
 		if (node < 0 || node >= MAX_NUMNODES)
-- 
2.21.0.1020.gf2820cf01a-goog

