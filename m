Return-Path: <SRS0=rp0W=VN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 075ADC76192
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 17:11:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B30BE206C2
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 17:11:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="knBTmABI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B30BE206C2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3CD118E0003; Tue, 16 Jul 2019 13:11:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 37DFA6B000C; Tue, 16 Jul 2019 13:11:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 293EE8E0003; Tue, 16 Jul 2019 13:11:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id E80726B0007
	for <linux-mm@kvack.org>; Tue, 16 Jul 2019 13:11:07 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id 91so10491630pla.7
        for <linux-mm@kvack.org>; Tue, 16 Jul 2019 10:11:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=kwpOpWT2eWiCeBhDjuSXvGXNhdNaH2c1UD5BkyTJoqs=;
        b=M2PuB5sksCyce85dM+vEkexlTf9YUpEOS6CLnsji+tSdzXDhJbHTOivgWDRw72qhoo
         QEBQhdGfOXKzsa+2KCGtIZ8UlFWCkrx9CxLlAZ/B9mb78nvMzAgk5wQNsaz3cN5IbaUq
         VB3UFjODkBgWvAdE6f9wXiiBZoEBLAAjNe1uz4smbGTwYrhRv4vPZUBPH8In6dN65lPc
         58fRPIleIZcYlAnCDqK92+kB6weHE8Tf6rdWG2XIaAY3s7RiOby7bOO6DSGms1f8Azhh
         qWY9RBf+4XZL1L+9eU4JvmVhKWdPh5ihRNdvTO+9+dPvuhJ940GsJEmxHK+P+YFemHH6
         x2kw==
X-Gm-Message-State: APjAAAWTHrGQMtLk2qQ9kSskp+k5xLT9otsCMYaY6XPF2jTUYi4P0BhC
	lSVfXqp5vHhRO7drw7IKzCra6NCteE02Bj/pYUf7eqvn5xuMe3fS1U4zIOSz0uhK3mAS8sDWKx4
	VoR03Trqh8yK5Dlhcg1UTxb0o6X2TtNHW/y4NGZzAOphlXR1xZlmO+yDu5P2WV9nRDA==
X-Received: by 2002:a65:6656:: with SMTP id z22mr33942695pgv.197.1563297067476;
        Tue, 16 Jul 2019 10:11:07 -0700 (PDT)
X-Received: by 2002:a65:6656:: with SMTP id z22mr33942595pgv.197.1563297066662;
        Tue, 16 Jul 2019 10:11:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563297066; cv=none;
        d=google.com; s=arc-20160816;
        b=kzlVaAl7dmG+UGvoxeSv7dLLnp7MfjjL7zaaVVPKIcBpPQu76/lsecoFUjsLz2FOSh
         Rd3dsMawgnOzYJqozZXn3SwKFjaSOt5JyzxuhnuBOk4Uyu8UONw6RvnaIIcw9Hqyvwd1
         lIK/2piK/fTAsyPuIxzDdsT46J5ARo3QGUNQ89lUfb6gsuwl473iXVTbaYepc6TRKZQl
         b1ZtLGrv7COINcvO4GoXgWZotQ5siLD73MSOJs5IjSKNRSS2gPhIe4i+h3jK8T+kN0QE
         FBGjkxB2kD6izd83Bw+7nPxfUBtC6Ti+8iO4b63UHRuxW/C1jJbBLEZRqXUjRjogeFML
         o1Aw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=kwpOpWT2eWiCeBhDjuSXvGXNhdNaH2c1UD5BkyTJoqs=;
        b=NqlYMFdWjlKna6ruYwLr7AEWUOZ6vmDvS/4rSJLLACgOtFzrzPjx9qAsql+/hgiVNY
         8MvdbyjdRx31XFSxERAkIeNB1i7NxtxrQIi9FDK4YdUHB/5lvJ0dK50oX6ZuL0qwUzev
         IIwNkCOCRBCgWmkgIdvDxjjivQBTfYtJ/m02fmf1K+gsZ61m7VooohWfPehfLB7voyiI
         Zoe294lojfgCKfBtVyNnfwIJvbTRGeqZ6kCH+q//CBBwC7WfIBGIToH8E00xVI7VfvPR
         RU5wX+b5p8B90/QYxquGKeY4FJdgD+UbTuyywyJc10zLgjqm0P1jyV1Gim/eRjv1gTT6
         uKlQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=knBTmABI;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m37sor25920320pla.6.2019.07.16.10.10.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 16 Jul 2019 10:10:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=knBTmABI;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=kwpOpWT2eWiCeBhDjuSXvGXNhdNaH2c1UD5BkyTJoqs=;
        b=knBTmABIgOoXo69WB++c8IiWB76RVPwIFTQLPCH60rHTf+UJ7FGF+ss1UJhIMPAq8x
         0EwUItQ8ZgDKhh+54f7rBkRV7MSkUDhNen+cxQRpDwq4odvt0AmVDnfhd5gDsDsim6Oc
         /NPzqJO1Ut/8JkDliDODiF4nieSIiOvRtiA2DDTkydoPrCpwaekiYCu4HxFCBNUMOdrv
         Kh+4kgtRPjClbTdLMdYDm8rTNtWJmYgbqv8d+6z8dyl0uMeRa9N2RZCdxwR9l/flo6FS
         TgIxRET8UFzLd1mskmgymFDDldbBvFBtSzi+kDwEtAaFdE8OH18mOJU1usfuTg9ZgWuu
         4sBQ==
X-Google-Smtp-Source: APXvYqzOUwUunYYbiDg94VvgRJzmfWkkNNf3nkG+b6uwrilA1j4IQ0R4BL7eXG7mU0JZW5y6MGQ9bg==
X-Received: by 2002:a17:902:381:: with SMTP id d1mr36353848pld.331.1563297059292;
        Tue, 16 Jul 2019 10:10:59 -0700 (PDT)
Received: from localhost ([2620:10d:c090:180::1:dd93])
        by smtp.gmail.com with ESMTPSA id j13sm20092099pfh.13.2019.07.16.10.10.58
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 16 Jul 2019 10:10:58 -0700 (PDT)
Date: Tue, 16 Jul 2019 13:10:56 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Chris Down <chris@chrisdown.name>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@kernel.org>, Tejun Heo <tj@kernel.org>,
	Roman Gushchin <guro@fb.com>, Dennis Zhou <dennis@kernel.org>,
	linux-kernel@vger.kernel.org, cgroups@vger.kernel.org,
	linux-mm@kvack.org, kernel-team@fb.com
Subject: Re: [PATCH REBASED] mm, memcg: Make scan aggression always exclude
 protection
Message-ID: <20190716171056.GA16575@cmpxchg.org>
References: <20190228213050.GA28211@chrisdown.name>
 <20190322160307.GA3316@chrisdown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190322160307.GA3316@chrisdown.name>
User-Agent: Mutt/1.12.0 (2019-05-25)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 22, 2019 at 04:03:07PM +0000, Chris Down wrote:
> This patch is an incremental improvement on the existing
> memory.{low,min} relative reclaim work to base its scan pressure
> calculations on how much protection is available compared to the current
> usage, rather than how much the current usage is over some protection
> threshold.
> 
> Previously the way that memory.low protection works is that if you are
> 50% over a certain baseline, you get 50% of your normal scan pressure.
> This is certainly better than the previous cliff-edge behaviour, but it
> can be improved even further by always considering memory under the
> currently enforced protection threshold to be out of bounds. This means
> that we can set relatively low memory.low thresholds for variable or
> bursty workloads while still getting a reasonable level of protection,
> whereas with the previous version we may still trivially hit the 100%
> clamp. The previous 100% clamp is also somewhat arbitrary, whereas this
> one is more concretely based on the currently enforced protection
> threshold, which is likely easier to reason about.
> 
> There is also a subtle issue with the way that proportional reclaim
> worked previously -- it promotes having no memory.low, since it makes
> pressure higher during low reclaim. This happens because we base our
> scan pressure modulation on how far memory.current is between memory.min
> and memory.low, but if memory.low is unset, we only use the overage
> method. In most cromulent configurations, this then means that we end up
> with *more* pressure than with no memory.low at all when we're in low
> reclaim, which is not really very usable or expected.
> 
> With this patch, memory.low and memory.min affect reclaim pressure in a
> more understandable and composable way. For example, from a user
> standpoint, "protected" memory now remains untouchable from a reclaim
> aggression standpoint, and users can also have more confidence that
> bursty workloads will still receive some amount of guaranteed
> protection.
> 
> Signed-off-by: Chris Down <chris@chrisdown.name>
> Reviewed-by: Roman Gushchin <guro@fb.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Tejun Heo <tj@kernel.org>
> Cc: Roman Gushchin <guro@fb.com>
> Cc: Dennis Zhou <dennis@kernel.org>
> Cc: linux-kernel@vger.kernel.org
> Cc: cgroups@vger.kernel.org
> Cc: linux-mm@kvack.org
> Cc: kernel-team@fb.com

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

