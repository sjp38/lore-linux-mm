Return-Path: <SRS0=MiGm=UA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B5010C28CC3
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 13:20:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7DC6B272E2
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 13:20:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="czmnKxGr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7DC6B272E2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2D3356B027A; Sat,  1 Jun 2019 09:20:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 284876B027C; Sat,  1 Jun 2019 09:20:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 173E86B027D; Sat,  1 Jun 2019 09:20:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id CF33C6B027A
	for <linux-mm@kvack.org>; Sat,  1 Jun 2019 09:20:17 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id b127so9608486pfb.8
        for <linux-mm@kvack.org>; Sat, 01 Jun 2019 06:20:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=aieyxn0mEzFmT/SVMyLfZDKWsbL/bT/xQcHnCZy3OlU=;
        b=TZd7ZzOfdJdA0siJoerb0kAOmk1wYOzR/NLpsuue+nWXed4wS/V3DDdpNGNUh1iqzl
         +cmmf/qOIO3SGDkhqOdUDiMuT+sHn5L2VMfPw7G/Vkf+AFpp3xLexlF0yaL3OoZzFdrd
         Gc3rLiJMITrzON3yWzqLTJg0Uv2aBYYB/802yvZUxqgSjTAO9TXtvk6NqXEt/b1gYeTu
         R3ZGR3kw4fsOWtbvzOEFKn76O0VD+1nv59SV9gwJdovTqYI9gub1qYyT3ZpB0y4fS8Dc
         uIEhA0kwIfnYH3uMx1PWveZ0D5SClokY18kM3Ta7c4KK59rMoE2QHEqvKMVmI2B0YNsA
         Ep8A==
X-Gm-Message-State: APjAAAVVc4XxtYzYmfDHu6t5nPFf2gAkY2rVr2uvMutHk/4x2umYxjOh
	46sJtySEuS55k2pJ2QF4YnLtGi9g9B+JZXvE12o3jDBR9sMoJdBXMhVAMqIv0sGL5fbT7haFtn0
	ItxA4iYgu/PC7qzK7a01K9T2PFuQQIER8ulkNqW+kXB8Lsm9RcF/ZwbCOFvc9gY0w9A==
X-Received: by 2002:a62:ae05:: with SMTP id q5mr16575521pff.13.1559395217503;
        Sat, 01 Jun 2019 06:20:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyS8wtgzBsrde5QjWFOxS5U3rPr9CAl5HTUWH+fGEf5e/fYV/0tNkXuv+Ws+fw7m3l9NHA2
X-Received: by 2002:a62:ae05:: with SMTP id q5mr16575479pff.13.1559395216916;
        Sat, 01 Jun 2019 06:20:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559395216; cv=none;
        d=google.com; s=arc-20160816;
        b=izL7L5JVV5Vp8xo7TttxY8pC7GxY1LLPgc0q+UgxOjcfktcZdT0CcEwh4BONy+kNGE
         e08x5yFUYhTCc3iXsoQGuAPnCaYRBNfO2DVM21mp+nwdJuhhZgWGVo8LG+7U4spryeCK
         ZSeGsX7wckjiC3BCIIven5OJ/RPsw+Caixbmq0RbBDgF7tL7+KPGy2NnNRsSdigswufi
         fNTdbdrTX/l3X3hiCQ84n/9FlrGerqa7U+gyLmBHufjnZGUoYHKffE3stKDYlEq4sEe7
         KeD7xCxHqQCAufsQ5yOWkZou/qEJF7SEXaNWsuHgiIDo11ozuHvsOpHcpCxg0X0TQoOi
         OL+g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=aieyxn0mEzFmT/SVMyLfZDKWsbL/bT/xQcHnCZy3OlU=;
        b=PmUYkz7X8X594PRFenr1kAyynr+nOyD3sStxY4d6eP0ADfZWq9/dhdFahhcfr9QCKd
         VwN4k4aKoiOr94gGA0fXbnERK9dXjtpN1n8xLb3Q4ttuM4rgIuGCKlpYaxRjC4AHeygo
         A04O/K5UPR3qZJXFRcjatxwEkzjqmNIo6s9iB6uY12o/+FOnQAtxoJgPhkvN/Hl3mjss
         k/jBsje3OHdwOoXFeYp6iBdIVvHoNY/kp0awZrWDPP30X3SkwoF55aWpxaZr37MG8sRy
         eamQ/OxAJNJ7KI/i8jY/deBrfCg+pUou2iiAi4f+VzyQqmAw97lT9arppXmBXGID8yO7
         jRPg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=czmnKxGr;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 31si10577517plf.195.2019.06.01.06.20.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 01 Jun 2019 06:20:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=czmnKxGr;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 064EB272C8;
	Sat,  1 Jun 2019 13:20:04 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1559395206;
	bh=bjdhm5Xwy5p6mlRyQ5ERQsdIxvgBVKfKEgwzZJc15mE=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=czmnKxGra7WO3SLKw3+CELvLifb0gRs2/dn17ZMvsu8iYgZEY9O0h33MKAASTi1qB
	 Tkhi624YqdZt0dCl+mWSEZv81Eue0OyfsgSp9R7nSpVDzbJTDqoMHEOY80KaxpbIQO
	 OPC7YUzBdhKx6iqJ78XhcH5ju0BXKeFJEK0/kb3w=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Balbir Singh <bsingharora@gmail.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Dan Carpenter <dan.carpenter@oracle.com>,
	Ira Weiny <ira.weiny@intel.com>,
	Matthew Wilcox <willy@infradead.org>,
	Souptick Joarder <jrdr.linux@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 5.0 010/173] mm/hmm: select mmu notifier when selecting HMM
Date: Sat,  1 Jun 2019 09:16:42 -0400
Message-Id: <20190601131934.25053-10-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190601131934.25053-1-sashal@kernel.org>
References: <20190601131934.25053-1-sashal@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jérôme Glisse <jglisse@redhat.com>

[ Upstream commit 734fb89968900b5c5f8edd5038bd4cdeab8c61d2 ]

To avoid random config build issue, select mmu notifier when HMM is
selected.  In any cases when HMM get selected it will be by users that
will also wants the mmu notifier.

Link: http://lkml.kernel.org/r/20190403193318.16478-2-jglisse@redhat.com
Signed-off-by: Jérôme Glisse <jglisse@redhat.com>
Acked-by: Balbir Singh <bsingharora@gmail.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>
Cc: John Hubbard <jhubbard@nvidia.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Arnd Bergmann <arnd@arndb.de>
Cc: Dan Carpenter <dan.carpenter@oracle.com>
Cc: Ira Weiny <ira.weiny@intel.com>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: Souptick Joarder <jrdr.linux@gmail.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/Kconfig b/mm/Kconfig
index 25c71eb8a7dbd..2e6d24d783f78 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -694,12 +694,12 @@ config DEV_PAGEMAP_OPS
 
 config HMM
 	bool
+	select MMU_NOTIFIER
 	select MIGRATE_VMA_HELPER
 
 config HMM_MIRROR
 	bool "HMM mirror CPU page table into a device page table"
 	depends on ARCH_HAS_HMM
-	select MMU_NOTIFIER
 	select HMM
 	help
 	  Select HMM_MIRROR if you want to mirror range of the CPU page table of a
-- 
2.20.1

