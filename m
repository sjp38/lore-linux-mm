Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6B077C43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 14:52:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2009F2146E
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 14:52:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="A+JYGhZ3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2009F2146E
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C68096B000D; Wed, 20 Mar 2019 10:52:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C15E96B000E; Wed, 20 Mar 2019 10:52:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ABECB6B0010; Wed, 20 Mar 2019 10:52:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f71.google.com (mail-vs1-f71.google.com [209.85.217.71])
	by kanga.kvack.org (Postfix) with ESMTP id 74B046B000D
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 10:52:04 -0400 (EDT)
Received: by mail-vs1-f71.google.com with SMTP id 2so502839vsf.15
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 07:52:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=o/tjHBN+YdVOHlZBhUHSY9iDnhLS0V50uWJeHP43be4=;
        b=VULh+uA/b73eqFRvvUdIOLfHzfGTLZPgpNrMEooT9u9DkfZHxszhkIaFGFVwfGfSpy
         yYCLcjYK393YfA9dP0C9Cps1a4rp+vk/o1CXmZMMdvIwLBJg3xCX78SQwEnDpuf/xn5/
         hNszVgaz53FF/ar9ukTKCEHXtQqWiii93Oi1/0n7pl6XfIpCwtgbzWAYus6tLvlPilk1
         ph+S0C9OV7lA+I6q4Z8/0EKnALqpWG4cO3o7y/qw80XXpk1wBwhn1yXulZhL1CZ4D+1c
         xP/PGqgLR3PcmfJU9TzcbsIIC2hZ/i220x4D1+afX9DqZg419M0Y8ewqjiGz0dw4rTWY
         TZKA==
X-Gm-Message-State: APjAAAWaBHqmVZrWd7siI/A+K98fB/efazseWtdZiaJzN7qSLpdyykEm
	MdQzldG7SXsyjPvF15s2ldyBHD+SUYtkzA87LHBHdqMSmsT9Nn7MtNEPKsVpTxX56ehng424USU
	sdqbHbyRKN6li0lu3QAbMnW7+b4GWlpYbOFHk8PUMKUBDYcoNfb9XrXC4rK3abcg22g==
X-Received: by 2002:ab0:698c:: with SMTP id t12mr4591101uaq.52.1553093524130;
        Wed, 20 Mar 2019 07:52:04 -0700 (PDT)
X-Received: by 2002:ab0:698c:: with SMTP id t12mr4591047uaq.52.1553093523053;
        Wed, 20 Mar 2019 07:52:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553093523; cv=none;
        d=google.com; s=arc-20160816;
        b=UtnuMIx5xV71dCbLAxZU2d8QBV6rRdGHzHJ1km9hpAjGxGHP8Ukxu0KLQ3b6xPZud7
         p/eHz+CuPyzkhpvQCw3+0cPg12ttgqL/3UAVOCaGTCq4v0jm8Cy9wwr+OzwvMGgWJDSz
         NtD0ombXLUSbSQv88B1XmSgsNQ9227v2X0w0WmW7qPKQ/vymsU06yEPO/6h6QPV9U9Th
         LpjOlgkiScECEI86+dhAlyBW+WsL9K1nrA5y8fTepngB2lLU1gwnWmZgkXu0d9pPeehX
         qP2EHdxzPkn1+XIzTTWMFBgWq9R9zs0wYKE7rRz/nK+N2WEm5hHIru0qMJmCop16lsb2
         ewTQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=o/tjHBN+YdVOHlZBhUHSY9iDnhLS0V50uWJeHP43be4=;
        b=zP0anV90NSfICeprfN0Enf0BMilKQXX1fH5P5zVOny3/OT3s9WvbAL4pdSrlh4Rll3
         4IyNoj7ZljZPpwaLgCSs9krMjmKrq0wsoNbF4Z3HS4vUmPTRfs6X1KGzO3Bap6c2VV45
         plbNeFC8gm2viMUZgf4kWlYCxyJXeYwBCKo+UEgqz4kECtcOHyZiXmf52Gns70awgryJ
         CLu6fGvFn19FQewBWJMbL3mrYMz/BQG9lMXp8fKQ5khcLg58UzxUBC8VuPiykiYE5uIV
         HkaIDxLJOp98WETwK8kPcUoW+7YY1+PPr6AV63z96j4WkXlrTQMNmHRZkej8ApzmUL0n
         QaXw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=A+JYGhZ3;
       spf=pass (google.com: domain of 3klosxaokcg0lyocpjvygwrzzrwp.nzxwtyfi-xxvglnv.zcr@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3klOSXAoKCG0LYOcPjVYgWRZZRWP.NZXWTYfi-XXVgLNV.ZcR@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id i14sor1775039vsp.122.2019.03.20.07.52.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Mar 2019 07:52:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3klosxaokcg0lyocpjvygwrzzrwp.nzxwtyfi-xxvglnv.zcr@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=A+JYGhZ3;
       spf=pass (google.com: domain of 3klosxaokcg0lyocpjvygwrzzrwp.nzxwtyfi-xxvglnv.zcr@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3klOSXAoKCG0LYOcPjVYgWRZZRWP.NZXWTYfi-XXVgLNV.ZcR@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=o/tjHBN+YdVOHlZBhUHSY9iDnhLS0V50uWJeHP43be4=;
        b=A+JYGhZ3fQkhscb6lUBmQ1muz6oemHopDmPki/B278rzjZ0dk/UjohSsOxEu8keiCi
         W5/VXLZ67gUh0RZN3rq5skpPYsUC7oWDq+tl+3khHwdNxCrmhkhxq7w99dcsLgc3Elx7
         dmeBy427vSPfFNaJS7DfUhAb/Fwd/EACn2TYRVMksoGnObzxZTWUPnBuSuAiS/JRvPZA
         f0EsOCj85jPSuENzq/Bg7zakYTOA4bo6fX1BKjPllZeRcF3GtXBJjjiVIF4U6HkOW9id
         X49/giQrlJvYsmuoQtVxMGCVLZT2pR3apmEVULZaKks3LsI2Ip7Pr6oRl+H4swKOnmZR
         D5tA==
X-Google-Smtp-Source: APXvYqyHOngs34In5uhQcXPzOfQqpf0ARHPrNyLHXpzz5ogONfScZvSMOj1YE9ihREsOQQ2kQeo8TqNX7xzilecW
X-Received: by 2002:a67:7651:: with SMTP id r78mr6363022vsc.39.1553093522664;
 Wed, 20 Mar 2019 07:52:02 -0700 (PDT)
Date: Wed, 20 Mar 2019 15:51:20 +0100
In-Reply-To: <cover.1553093420.git.andreyknvl@google.com>
Message-Id: <e1430838d7393896ade87ffbcf109c7127881137.1553093421.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1553093420.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.21.0.225.g810b269d1ac-goog
Subject: [PATCH v13 06/20] mm, arm64: untag user pointers in get_vaddr_frames
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
2.21.0.225.g810b269d1ac-goog

