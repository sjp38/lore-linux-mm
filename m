Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D407FC31E40
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 08:56:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9640D20B1F
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 08:56:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9640D20B1F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E51616B026F; Tue,  6 Aug 2019 04:56:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E022C6B0270; Tue,  6 Aug 2019 04:56:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CF08E6B0271; Tue,  6 Aug 2019 04:56:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 82C2A6B026F
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 04:56:10 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id b12so53382749eds.14
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 01:56:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=BZlqMb+QyegauaZukyQF7oO5hMid9fvH6tiqPMt0jfc=;
        b=bWg36EviknIGguobrXKdIWenkYvF1Iqba+aWurAdbGDczj/CAU1kvxOnYlPd8L0rZX
         s9GkM57SF8in08lNFAez+LqoU6yXmHGqTvY97u0MBX26P9CDp4kizdKX1D/MUhYSsYXm
         iubZX3Zt9zFLpVfKpAiIpLuq2+gXWvcKj9YaQyBjh8t/u2bFlXbQPjfWheEfaLgKq1iz
         iV4vkyF8YowgTQede/FXLtrcVI+eQPkS3Qxump0Z6dSFBd2CytzpB+lu1gEiv4g4zLRN
         RzCimunUY9brtlrPJGVgZSCv7jy5FrODFsJpWu1ysYWlOea5v+fDR1PwhS2sEmTGMJol
         iRrA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAV/7QKfJINfUyoUDn3bjRTozgI4jTLIxBzuUj4/AI66nyJx8CEf
	algUFlkRCQsSEtuoEv92O7h/89S1veHQvytaJ2N1YWhGXlJ3F3CSHUa2DLVDYYJZeOWI5umCOjP
	jYbB0yvFTwGFSmGQgXKxZagevh0g1U16tcudtNOztZ6t0xKQf7Lx9cuX9QC1wFeA=
X-Received: by 2002:a17:906:8313:: with SMTP id j19mr2057175ejx.276.1565081770089;
        Tue, 06 Aug 2019 01:56:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyfKTfj/VR2XxpW2oh/RBk3SZ7fOn6XkDNmiyR4t2kvZs2HoCuMJi6+64gSlsgONjmxtIvx
X-Received: by 2002:a17:906:8313:: with SMTP id j19mr2057141ejx.276.1565081769368;
        Tue, 06 Aug 2019 01:56:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565081769; cv=none;
        d=google.com; s=arc-20160816;
        b=xSuvMT4ZAnnkSlkMqg54NpvrfqLvc5bJhx/egAluJAYi7qJfwwc1i9Nz8ulOBiatLp
         9mZ2UCd1BRA6XDqzqCVr+oJylK5jQ7DGAmOaIwmAX9ayAVFUf5fYUoTCikedaqztmdbp
         Wu8S5Aj0DFGQ0+9LrX5NDFB4TrXcgwlV9jcSP3qSwpDqa1QyrcLyjx+pvrgEde0ZnSq8
         oxeg6mLdchyyxTPtKLAV/XI+fi8JHfB1xxjmS0ZTLsfReNu0sY0bgmaPyxN+pHHt6mZh
         kQ0jyBNFIFKhq8DRtgWHvS11vTrAM28i582nFEQjFOKsFnP9iTnD7hwfASO57QFgLTNN
         wQOg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=BZlqMb+QyegauaZukyQF7oO5hMid9fvH6tiqPMt0jfc=;
        b=kCAZsJye+PIYYi9iRjQ1VBghEzGo/NJx4AdFPM1HbFCOR0fEzVazikhNLyUuBQghc0
         tfdkK0BdKP9LwXP3KLvTHm2zGZCetJIr1nvUSW1CW0QC6dx7CpNm2wR2ATHTqWL8XxA1
         A2SbDgg+JFcOjYKYPDWFFdBIdeSrfDqboEyzkmrfx68+bRHGmcAmS4v3dmuGI6Uhdqg4
         igkcONHwWfCsYY4GhZHuZ5x/fpsH7c1oQGlzJsj1BupHRDflB5OspmEv9xk5JK5Hup7g
         Gr5z7XtLOIf2XgdOmP5GGoR9KiaSoCv5ZyYKdGiegzKBia/lll/ICZir2BkmEKFmZ/PO
         bWSQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id mj3si26151130ejb.17.2019.08.06.01.56.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Aug 2019 01:56:09 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 86300ACA0;
	Tue,  6 Aug 2019 08:56:08 +0000 (UTC)
Date: Tue, 6 Aug 2019 10:56:05 +0200
From: Michal Hocko <mhocko@kernel.org>
To: "Joel Fernandes (Google)" <joel@joelfernandes.org>
Cc: linux-kernel@vger.kernel.org, Alexey Dobriyan <adobriyan@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Borislav Petkov <bp@alien8.de>, Brendan Gregg <bgregg@netflix.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Christian Hansen <chansen3@cisco.com>, dancol@google.com,
	fmayer@google.com, "H. Peter Anvin" <hpa@zytor.com>,
	Ingo Molnar <mingo@redhat.com>, joelaf@google.com,
	Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>,
	kernel-team@android.com, linux-api@vger.kernel.org,
	linux-doc@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org, Mike Rapoport <rppt@linux.ibm.com>,
	minchan@kernel.org, namhyung@google.com, paulmck@linux.ibm.com,
	Robin Murphy <robin.murphy@arm.com>, Roman Gushchin <guro@fb.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>, surenb@google.com,
	Thomas Gleixner <tglx@linutronix.de>, tkjos@google.com,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	Vlastimil Babka <vbabka@suse.cz>, Will Deacon <will@kernel.org>
Subject: Re: [PATCH v4 1/5] mm/page_idle: Add per-pid idle page tracking
 using virtual indexing
Message-ID: <20190806085605.GL11812@dhcp22.suse.cz>
References: <20190805170451.26009-1-joel@joelfernandes.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190805170451.26009-1-joel@joelfernandes.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 05-08-19 13:04:47, Joel Fernandes (Google) wrote:
> The page_idle tracking feature currently requires looking up the pagemap
> for a process followed by interacting with /sys/kernel/mm/page_idle.
> Looking up PFN from pagemap in Android devices is not supported by
> unprivileged process and requires SYS_ADMIN and gives 0 for the PFN.
> 
> This patch adds support to directly interact with page_idle tracking at
> the PID level by introducing a /proc/<pid>/page_idle file.  It follows
> the exact same semantics as the global /sys/kernel/mm/page_idle, but now
> looking up PFN through pagemap is not needed since the interface uses
> virtual frame numbers, and at the same time also does not require
> SYS_ADMIN.
> 
> In Android, we are using this for the heap profiler (heapprofd) which
> profiles and pin points code paths which allocates and leaves memory
> idle for long periods of time. This method solves the security issue
> with userspace learning the PFN, and while at it is also shown to yield
> better results than the pagemap lookup, the theory being that the window
> where the address space can change is reduced by eliminating the
> intermediate pagemap look up stage. In virtual address indexing, the
> process's mmap_sem is held for the duration of the access.

As already mentioned in one of the previous versions. The interface
seems sane and the usecase as well. So I do not really have high level
objections.

From a quick look at the patch I would just object to pulling swap idle
tracking into this patch because it makes the review harder and it is
essentially a dead code until a later patch. I am also not sure whether
that is really necessary and it really begs for an explicit
justification.

I will try to go through the patch more carefully later as time allows.

> Signed-off-by: Joel Fernandes (Google) <joel@joelfernandes.org>
-- 
Michal Hocko
SUSE Labs

