Return-Path: <SRS0=h8p8=S5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0483BC43219
	for <linux-mm@archiver.kernel.org>; Sat, 27 Apr 2019 10:32:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B6BA720693
	for <linux-mm@archiver.kernel.org>; Sat, 27 Apr 2019 10:32:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="d1C1qdVO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B6BA720693
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 25D926B0006; Sat, 27 Apr 2019 06:32:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 20E286B0008; Sat, 27 Apr 2019 06:32:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0FD736B000A; Sat, 27 Apr 2019 06:32:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id C72246B0006
	for <linux-mm@kvack.org>; Sat, 27 Apr 2019 06:32:35 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id f7so3819462pfd.7
        for <linux-mm@kvack.org>; Sat, 27 Apr 2019 03:32:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=/wfN9cbY70jLMmaBiwAoTgOUu22N+b34JaAv4aDSiiM=;
        b=Ai/9uZCsF9M5PAEzS+51MxGLEXAov7fKMueQH6/dEgGIHN72qwC/y4BClae4JrRHgQ
         uoWY4SqNPYzVpbF4xfW3MM/T0ZkKoBQ0HkrpKpZfsr/6rKysDweg+nEHGdI7HQG1Ge1H
         J8PYIw96rb23NPDhqWDVRbH/tVEFrC5KZHodRnxb36S7NYQBMnPFvvceKqN0wpaexGt+
         ROZHvBb/o8beL+yiM5wE25ZSQPcVcLeAfSj1TNR+UCZsE8qEQSvKVbE/t0+rkRePjuXu
         Z4oU2V7fKl4Ge418M6sCCqpf/l10LLOEu7yJzLj6rdieMDE5nBq6lnciV4UfcqNbvbsH
         rooA==
X-Gm-Message-State: APjAAAVVJEq0bEJwL1Yd8EhDyBezKu4TmwaySz7wDXpOdiwnJ6p8IUSH
	2KLs6Jdv3/qa9K9zYtghdnoT5ZAeSpLRCGSqltXEGhyRn0X3PEqhwGlb764ZMfhFQugidH20DzU
	59yM6Bt9G5W14sbH0mooQUvUf7Ee9q2GHStuxILH2sxpN43q7+Z/n2C196cRkn80TPg==
X-Received: by 2002:a62:6490:: with SMTP id y138mr52938757pfb.230.1556361155410;
        Sat, 27 Apr 2019 03:32:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzd8aTpzjmKNkDDJ5R9Gr1v4b/4iWZBq0wub08TOFQMRQ/QL2isNfIHmZtpCmPyagK7gsc0
X-Received: by 2002:a62:6490:: with SMTP id y138mr52938709pfb.230.1556361154749;
        Sat, 27 Apr 2019 03:32:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556361154; cv=none;
        d=google.com; s=arc-20160816;
        b=CQBzHb5mwRmFAJ3CIrLkhkozN0q1hJ/eySsxc2Yww9a29ZZBDjfmpeUzWLhDfFESEo
         3oeAZzGm0zF2Xucn+q0HNn182tug2X+B+Qk+6lyvkxOAxZ+4QUoA4LWZjJZdljSHs6sQ
         mUIVOIQ8VH4YOUSKlsE2Hu5NyKcvlf0Bw+2Ivj0t0QLe/Qo/umG3iYbS9yaQ+UxqW1iI
         uzI+ImsfRWTo9vC7wrJOaehLFd5A9q/3kokIgUZ4upyyj+piChiJuh6excxh5UJaYBYT
         9LywhZvNqvIwI7OTFCKt7KzFy/a9VKXFVmPVnqrRy/5vkjmTdtuRh8o6pw1NK0hN58xy
         xixw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=/wfN9cbY70jLMmaBiwAoTgOUu22N+b34JaAv4aDSiiM=;
        b=hB5e6j2X41sssBvTPYKlji2R5MB4nCJFA/7jKuYAp2FQ9MaEgGMchE/Z6/NzCPLGYd
         Ylpb8RQ2z8nYe2a0iBTm2iLKRpOwxFQsBL0k3z/PxFpizat8kB1BJP41deTevlqDnL8i
         TAsFTgq4S/UKSDOK1z9m+Q856VS1zXnvcdDuZGUX/S0rx0K77co+xQEHIQofOWi/neh1
         VRuXIk4cSLxehFPc6cAnBOVZuQ4uE58FcR+CZa5zsb/wEpza/4u74tb7CJtQCRxX8ZI2
         LpvDNx6bE0qggx2XKRQK6mIJEMuZEOAf39aAulPgkkjaxLLCpbnJ7Uv8cOjy/HaE5rEv
         ahzA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=d1C1qdVO;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id m79si28767404pfi.81.2019.04.27.03.32.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 27 Apr 2019 03:32:34 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=d1C1qdVO;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=/wfN9cbY70jLMmaBiwAoTgOUu22N+b34JaAv4aDSiiM=; b=d1C1qdVOjLCTuijW+/UiQ9tUY
	u2JXmjimTsgGi9pPouHXGSi+f0eSxX0HIH7HWyjHD2y24faIPOC4LiwlTeQlVCXXwbH52+wK2P9eq
	yywoc+V3Gs/cQiwL8dgcGe75sw2HjavlRB57PNztNaUYzClj6YzlZMrjM04q4hUgigqLhYxdSJbxb
	jeQuxl+5ANx0PaU2uwc7aLcQ72NXWvHAUBx2/u7X9KKyGjw7AJE3sQYMtfdJ/YUur1FQpoIwTn1Er
	TXQQB6JzS3+BxL+eHmI18UWhjqcfLspCmuQ+hJBQiE5jEtCdrDhzwhLyK56zyuxFS/xnc9IAWvgY+
	zs64p7GnA==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hKKd8-0001Xn-GL; Sat, 27 Apr 2019 10:32:26 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id 079E329D22409; Sat, 27 Apr 2019 12:32:25 +0200 (CEST)
Date: Sat, 27 Apr 2019 12:32:24 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: nadav.amit@gmail.com
Cc: Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>,
	Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org,
	x86@kernel.org, hpa@zytor.com, Thomas Gleixner <tglx@linutronix.de>,
	Dave Hansen <dave.hansen@linux.intel.com>, linux_dti@icloud.com,
	linux-integrity@vger.kernel.org,
	linux-security-module@vger.kernel.org, akpm@linux-foundation.org,
	kernel-hardening@lists.openwall.com, linux-mm@kvack.org,
	will.deacon@arm.com, ard.biesheuvel@linaro.org,
	kristen@linux.intel.com, deneen.t.dock@intel.com,
	Rick Edgecombe <rick.p.edgecombe@intel.com>,
	Nadav Amit <namit@vmware.com>
Subject: Re: [PATCH v6 00/24] x86: text_poke() fixes and executable lockdowns
Message-ID: <20190427103224.GG2623@hirez.programming.kicks-ass.net>
References: <20190426232303.28381-1-nadav.amit@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190426232303.28381-1-nadav.amit@gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 26, 2019 at 04:22:39PM -0700, nadav.amit@gmail.com wrote:
> From: Nadav Amit <namit@vmware.com>
> 
> *
> * This version fixes failed boots on 32-bit that were reported by 0day.
> * Patch 5 is added to initialize uprobes during fork initialization.
> * Patch 7 (which was 6 in the previous version) is updated - the code is
> * moved to common mm-init code with no further changes.
> *

I've added patch 5 and updated patch 7, I've left the rest of the
patches from the previous series (and kept my re-ordering of the
patches).

I pushed it all out to 0day again. Let's see if it's happy now.

