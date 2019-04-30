Return-Path: <SRS0=8Dof=TA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DA098C43219
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 13:25:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8DB2B2075E
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 13:25:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="wBxzW9uz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8DB2B2075E
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BC65A6B0269; Tue, 30 Apr 2019 09:25:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B51796B026A; Tue, 30 Apr 2019 09:25:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9F3CB6B026B; Tue, 30 Apr 2019 09:25:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f199.google.com (mail-vk1-f199.google.com [209.85.221.199])
	by kanga.kvack.org (Postfix) with ESMTP id 78CF86B0269
	for <linux-mm@kvack.org>; Tue, 30 Apr 2019 09:25:43 -0400 (EDT)
Received: by mail-vk1-f199.google.com with SMTP id k78so6317880vkk.17
        for <linux-mm@kvack.org>; Tue, 30 Apr 2019 06:25:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=4c/fu3qC3Skvw+ZZk7UHJQzalE9hfnOxHloiMgOUfYw=;
        b=BN50UDNyGSow57AubNmN7CgRX0gMmWePXI14+P5n1b8LQwFiiHuDhqJTP7YeOkCVja
         srWOY3EvY8Q8ClIAAV2ZXuzGYEls6qlS9riTUUM0c6UWHeC+jZmZ37ygNFEOqROoUCXl
         GZ15iixr0q7EzoZVvnEBQhfJU/olmDROZNNu0+L+zGmmgsHHVcAOFN2e6lkI1Y0TQMFI
         Au2eJKRbWauTSHeKDLCgkmLmJdvtGglXzdUDfVPxq49MQjnS/L1K79dtmEV+0ojn+Jvk
         3PGV5JKyjz/4iuErN4Q7efFIWrRUcrxSJfK3a3fQM2jKqMpKpWRY6S7MxeW11ongecBa
         Aj6w==
X-Gm-Message-State: APjAAAUD1CrzDFXqMfvXRpUPYjerPIybTxNdbTpsOq9p6uMOj6I+YZxb
	4yCaE/9d9S0Hlt1UX10ictT4PogzRSwyO4uUPT8C0lvTILRIQ8XqWU1fQ0vegBrpnbgZyJHT6/p
	gzxiAcQ/ABrP9CMkP9TCWcqyq8pFDFYYbwmfZt6C4vhfJMbEF77VOeUcITtP4rMJFpQ==
X-Received: by 2002:a1f:3c83:: with SMTP id j125mr34801698vka.92.1556630743132;
        Tue, 30 Apr 2019 06:25:43 -0700 (PDT)
X-Received: by 2002:a1f:3c83:: with SMTP id j125mr34801656vka.92.1556630742507;
        Tue, 30 Apr 2019 06:25:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556630742; cv=none;
        d=google.com; s=arc-20160816;
        b=TZ0Pcb1MBGKIkXBkY28Gfx17qaO8j1hiPC5JSaw0MK37nhXkFB7+uCqGw5d7/rB7b8
         yNivgtwaiJHl26vBOOn0POBqY+Ao86IMkU+hRzNEAsn6C0Xzu0nvQX+DTRfI3BV4wei7
         o/JacAKwiwDOyka/cq/E7V60e8hN8sVdO+hfLFpDSyWTWu+JmvBwv2q7Dfok1DsuHKZP
         o6Wfw8cyJVyGyhgCPLXPa9/Fn0yIa+vL2tFZBcfezLNSrJNqUooRAxZGak6d+gFO1t2H
         39bCR+MY0Umx5cduluDICXvdL2t3lqQQHcszLiGCB7JLaSM9oR/8hJYpD5LZpgq6OdJS
         ar+Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=4c/fu3qC3Skvw+ZZk7UHJQzalE9hfnOxHloiMgOUfYw=;
        b=CfqPLDy2Zpj4Ee7sULqYO1G/oakQM9MYXjs7yQz10Zl56mr+EzTZy0bQrM1CJmRYbP
         K+rGs0OlbMk4lq84y9fWpXfd/DY8xXwFSWaM9H6QxWTr7gQ+LKCMajXi17VE6BgB+eYR
         T+knTLm6BMqlhK2fw3zqEdvjlgF6SJRySVSOBySnUIg5SFmfSxO6ByE4Jofd1v+BfCsP
         JpCvfMLUdDiKF0tX2Eu72qRlTZiA4i2tpsukqh7UMrnlGnrHfn+YLGYSBII76RiuflAl
         3adqkUjMCH7W4lHaD33U7MFprFU7PrPBzYCqmRohRDZMJtHIiHlQucNee83Q5G/Ap3of
         mtwQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=wBxzW9uz;
       spf=pass (google.com: domain of 31kzixaokch0boesfzlowmhpphmf.dpnmjovy-nnlwbdl.psh@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=31kzIXAoKCH0boesfzlowmhpphmf.dpnmjovy-nnlwbdl.psh@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id g188sor11769197vsg.121.2019.04.30.06.25.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 30 Apr 2019 06:25:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of 31kzixaokch0boesfzlowmhpphmf.dpnmjovy-nnlwbdl.psh@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=wBxzW9uz;
       spf=pass (google.com: domain of 31kzixaokch0boesfzlowmhpphmf.dpnmjovy-nnlwbdl.psh@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=31kzIXAoKCH0boesfzlowmhpphmf.dpnmjovy-nnlwbdl.psh@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=4c/fu3qC3Skvw+ZZk7UHJQzalE9hfnOxHloiMgOUfYw=;
        b=wBxzW9uz5sqQEs2k0kS4yhvkUsLQPUol5yYuscC/EhJQq88IJKN51oJN9Ma9N+F87j
         0yaXqLxOKrSBWEzg6TAlDuogkZNA4XMbprAL12kWJ8MdNH7JIvTO8ZRXCqw/W9rKaVTK
         0th2TjbWtiytISvyVjLE74X1hS0zo7K7eSu+m53APk0oWFg+5hHivN//aHp583NOkYkp
         q/Xzdqo7lpDQuozd8M9soPmozGOH2C019sBJyK9gvXzEw1QU7pl845OD9URqwv3Lf0aM
         RmLDFBkc4rSunB/Q4UnHBTaxv0r2wOX1jQXVnW4MBVL+0daNYML4EK5a4hKos8NfLzsy
         dlFw==
X-Google-Smtp-Source: APXvYqx4TL4lB6fuuHN3vQZgSBJDs10/R98gvbNQDm51wxIVMnZyNgUuaizbdtdyYw1MeWbTLc+s/luHbNJTgZgZ
X-Received: by 2002:a67:8155:: with SMTP id c82mr6290812vsd.200.1556630742131;
 Tue, 30 Apr 2019 06:25:42 -0700 (PDT)
Date: Tue, 30 Apr 2019 15:25:04 +0200
In-Reply-To: <cover.1556630205.git.andreyknvl@google.com>
Message-Id: <8e20df035de677029b3f970744ba2d35e2df1db3.1556630205.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1556630205.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.21.0.593.g511ec345e18-goog
Subject: [PATCH v14 08/17] mm, arm64: untag user pointers in get_vaddr_frames
From: Andrey Konovalov <andreyknvl@google.com>
To: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, 
	linux-kernel@vger.kernel.org, amd-gfx@lists.freedesktop.org, 
	dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org, 
	linux-media@vger.kernel.org, kvm@vger.kernel.org, 
	linux-kselftest@vger.kernel.org
Cc: Catalin Marinas <catalin.marinas@arm.com>, Vincenzo Frascino <vincenzo.frascino@arm.com>, 
	Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, 
	Kees Cook <keescook@chromium.org>, Yishai Hadas <yishaih@mellanox.com>, Kuehling@google.com, 
	Felix <Felix.Kuehling@amd.com>, Deucher@google.com, 
	Alexander <Alexander.Deucher@amd.com>, Koenig@google.com, 
	Christian <Christian.Koenig@amd.com>, Mauro Carvalho Chehab <mchehab@kernel.org>, 
	Jens Wiklander <jens.wiklander@linaro.org>, Alex Williamson <alex.williamson@redhat.com>, 
	Leon Romanovsky <leon@kernel.org>, Dmitry Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>, 
	Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, 
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, 
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Robin Murphy <robin.murphy@arm.com>, 
	Chintan Pandya <cpandya@codeaurora.org>, Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, 
	Dave Martin <Dave.Martin@arm.com>, Kevin Brodsky <kevin.brodsky@arm.com>, 
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>, Andrey Konovalov <andreyknvl@google.com>
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
2.21.0.593.g511ec345e18-goog

