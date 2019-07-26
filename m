Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4385FC76194
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 00:55:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0A0FB22CB9
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 00:55:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="L5uUd3Gh"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0A0FB22CB9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9567F6B0005; Thu, 25 Jul 2019 20:55:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 906E66B0006; Thu, 25 Jul 2019 20:55:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 81DAD8E0002; Thu, 25 Jul 2019 20:55:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4EDA76B0005
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 20:55:37 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id q10so8651365pgi.9
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 17:55:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=lqUzAiwpe+982ZtFxY47KqhZ67cib6rgfM9SitBt2Vw=;
        b=dfDOpnkmOkB7dREUFaepyl+4ksVwPOy75Id/LI0SNW+yOa2yUzRfwWovbmprRPhpt2
         ah4Joi1zilTCXA0HgGptZSmOQON0+E5E6+5v68upWp4PWvE1zftPktjJr+0JcCJkOIYR
         3iGWjI3gNU8nTIBr0Kyb81ewx3ztntxxHu0aWn2FV4vqW1uKqjmTGSmWJbnGmUXGnnku
         Hl9KeR5HmiNf24rWKn8Kp62cIgdrSUyu9bMvL6Z2tavS3ZT4ZLKfS8Njmh2Ysn9SNnBn
         2ryryWvsJtxbFgxeyA28NumJzWrCgQyrh6ErZpPWyfqZQJwjmKstgcreBFlorQ5Er+Su
         mEhw==
X-Gm-Message-State: APjAAAVQABKBh+depY1W5zms2JMXop0OErxOScna5+HGodWfvHB1E7eF
	FsUCRg8U6/XombISpWWZuQQKE1YRsEhFTl9R1Rs4fRj3q19PsOpRcqrXpvAIUqt+9BFCf2oB9ab
	Kf/WiYCeuvXLgSyt6reMalJ8M27ECa2YsMTiYsapuDPYEMfSR/sLbp4AJyvMnL038Xw==
X-Received: by 2002:a63:b346:: with SMTP id x6mr89088501pgt.218.1564102536747;
        Thu, 25 Jul 2019 17:55:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxcmMUFhYQclBREA012KQP68urQPCeA8mXj3B9AD9vcfVqSjFLWAtkH7JZUNKwmf2S45ZWx
X-Received: by 2002:a63:b346:: with SMTP id x6mr89088475pgt.218.1564102536104;
        Thu, 25 Jul 2019 17:55:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564102536; cv=none;
        d=google.com; s=arc-20160816;
        b=DRCWlr/EuwnYYb9HNxDELetzxNz41B+GQioQWWGUiiV1xXiVy6d9LmbngLB57kjGSq
         kdeR/pHyGgYB3HazZGoQb2DYR4VfZ+wMjdAyAZWvxCHJUW9m+L6aKnnRgM8Dr/e9kzD8
         lIFwgskZV3pK9Kr7HwBTBRPfitjXyJUaaZV6+VqVITL6hkmEWVydMPoFBx/ocU0ykpSK
         QA3jFswXnffKY5Dj6NIQM8bmqH7qEoq48HkBbndIuNU3XUV5AuHkM/bOlUxG4ZPRWxje
         q7JuVQDuMVBxok9yrLXGFbmPuZPjK9+1y5B7BpWnyvo0yAQ+0D7kj7JsBlDG/n0wahy6
         TsaA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=lqUzAiwpe+982ZtFxY47KqhZ67cib6rgfM9SitBt2Vw=;
        b=DlqCObQKFfsHClD9UV/84hj5FmjjT21PQT2I/GivZxo3/sHFC3yXjcotHOK6lO5xud
         Dvrs8hAD3p+cn4238s0ZzvAsjJUYlMCB/ZQzRFG6IYODALzg6KYKT2E8D+StQXdGOBPK
         WgxYraw+bXJQ22pN4n3SW8Xg2TYb8bwUQgHDToyJw2Wuc7T4+h9J+6UITv8BGcA4Hlbg
         dgayo5Eds9neGWpknaOWX/Sxp1JTngBZcuj0nzl4QmeTHsWwsnXhOFfkqsmOkNSpjN1f
         i5y/BtUoZXVHrd5QDDkvrha0pBCxkb/QGn47PMimRD2aUpq101MqeVCZiLQIP++7CcPe
         s9cA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=L5uUd3Gh;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id h63si16198717pjb.106.2019.07.25.17.55.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jul 2019 17:55:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=L5uUd3Gh;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id DC8ED2238C;
	Fri, 26 Jul 2019 00:55:34 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1564102535;
	bh=o4hVED1DnXPhi52FO0wtBGwbvoqHLkWraSNdRFbEhmA=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=L5uUd3GhpWzXG8NZ5VAfPLAogGQnqmrSDtJ2WoGzo4kODsjexGjl2plEX8UF4CwuW
	 oU0gaoBumTXP+a5Fx+/RYg+bzmTeV7Qn9p0BT20Auw6fp70moUvLzgdHDbXgB4eoWy
	 x3mw2X6mVGMx2Db5jEYPWqqxyerg3w7sEzNMLtn4=
Date: Thu, 25 Jul 2019 17:55:33 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Kees Cook <keescook@chromium.org>
Cc: Alexandre Ghiti <alex@ghiti.fr>, Albert Ou <aou@eecs.berkeley.edu>,
 Catalin Marinas <catalin.marinas@arm.com>, Palmer Dabbelt
 <palmer@sifive.com>, Will Deacon <will.deacon@arm.com>, Russell King
 <linux@armlinux.org.uk>, Ralf Baechle <ralf@linux-mips.org>,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org, Paul Burton
 <paul.burton@mips.com>, Alexander Viro <viro@zeniv.linux.org.uk>, James
 Hogan <jhogan@kernel.org>, linux-fsdevel@vger.kernel.org,
 linux-riscv@lists.infradead.org, linux-mips@vger.kernel.org, Christoph
 Hellwig <hch@lst.de>, linux-arm-kernel@lists.infradead.org, Luis
 Chamberlain <mcgrof@kernel.org>
Subject: Re: [PATCH REBASE v4 11/14] mips: Adjust brk randomization offset
 to fit generic version
Message-Id: <20190725175533.f9fcc5139a9575560be7f679@linux-foundation.org>
In-Reply-To: <201907251259.09E0101@keescook>
References: <20190724055850.6232-1-alex@ghiti.fr>
	<20190724055850.6232-12-alex@ghiti.fr>
	<1ba4061a-c026-3b9e-cd91-3ed3a26fce1b@ghiti.fr>
	<201907251259.09E0101@keescook>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 25 Jul 2019 13:00:33 -0700 Kees Cook <keescook@chromium.org> wrote:

> > I have just noticed that this patch is wrong, do you want me to send
> > another version of the entire series or is the following diff enough ?
> > This mistake gets fixed anyway in patch 13/14 when it gets merged with the
> > generic version.
> 
> While I can't speak for Andrew, I'd say, since you've got Paul and
> Luis's Acks to add now, I'd say go ahead and respin with the fix and the
> Acks added.

Yes please.   After attending to Paul's questions on [14/14].

