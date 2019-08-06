Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DCE9AC433FF
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 11:14:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 91FF320B1F
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 11:14:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 91FF320B1F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3FE006B000E; Tue,  6 Aug 2019 07:14:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3AE806B0010; Tue,  6 Aug 2019 07:14:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 29E3D6B0266; Tue,  6 Aug 2019 07:14:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id D39C66B000E
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 07:14:55 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id k22so53670499ede.0
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 04:14:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=fF6B+fYbNKgMWIBPlhl7Rzen/V/44uBW9q6jS5dRh60=;
        b=Aw7O+Jod79XX8WlyTYrXsWBxbskGx6fy4dqHGZ2JxisZKcL4J9P/lwiQu92XgPXMdu
         PC96tJPjIMaA/eCKNHdL34eWibg/yZVfPsdVt+26gxhpqhMaQODgsHiIWtUVEqTW6+GQ
         3XLO1nt/0igITyEbwyflRHLDOTgOkO1dMqr4G5falZssjn7WuME1ws+gQ3ib4aJnuyTc
         VcVxSqWLKN/5cBDNNLbQYNfRAbSTcI504D9Q6KuhaarS8Nqzd8ez6VPCIScwQ2YXFBE3
         xz6jJMicz1RLMXgOJBGLyQVBDBC6x54TSGdaVdJARGwewrFW05YGy9Je7IhXqmvD6bn7
         Y4eA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVE53PEPoa0muRZXmYCaiBzsqA9y7+FHIgP+kiuCwffi80c/syn
	DeGUyquYEAa7OeYRp5p/nFisUbPwIdEYM2qz07Q/g+z43nvHXL9QoqRtEJU4+CtOAgLl8KzsPZu
	q4rjNlP9H3Wbo1pBRwKlC3c5fJzakwW5nqsqWXKDEEubKsGO3p/M+HAxwHSxNehs=
X-Received: by 2002:a50:aa7c:: with SMTP id p57mr3151865edc.179.1565090095462;
        Tue, 06 Aug 2019 04:14:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyjpAx30pm8SRfYXhCNXM9Ijvk/k0g5+czJykLdIRBTkRoZvMGY6x51S2igoXulOl9LzuYl
X-Received: by 2002:a50:aa7c:: with SMTP id p57mr3151823edc.179.1565090094855;
        Tue, 06 Aug 2019 04:14:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565090094; cv=none;
        d=google.com; s=arc-20160816;
        b=g034q2qdvdZSTasXnTP0kG9htsAm4QvoyjZN1gKpca41+f3J4iUrRTXLdoX2MxB7SB
         4k/meIe0hF0RFI9yvgx4HF5sQHiezu6YB0WXvc7sqWLAYg7a8drO7x2Jiw4L1sliKW3t
         V9V4hS4qzP4CPCbL2fc+27YF83iONNdNGLkHPn2GL+iijPjWBb3UKWBrr2+6zFrisAmZ
         bHnfjeVV2fth01kRxWFZXoSvdrl30nt31wJMW5KFaM3scMR5y65iV64aRnZGLiNDjg3V
         DOKT6PPDO/88BG1g/64kbsgnD4uCQ/MN+IOr6EsV5W4pqtIAdL5WJ/pW+j8F5axguUVa
         mVtw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=fF6B+fYbNKgMWIBPlhl7Rzen/V/44uBW9q6jS5dRh60=;
        b=mzr1bLGohDSMKfh8hboYWRIlIcF2GN9+wXRQOLa2lmCXfsFZwUupSQvb1nNIxgXrKw
         xPkIEOTRb05phFskj9QhPgkhUeIWphAcBEGR+ThaZlMC6Ab9XmPFKEPsdDsy0g/MXKtU
         BRU0mxQZygOHuIs5jdREp2IHXYTGFURdPhi2f79Cx45luMRimjT0z/BdqyJUe54dyt3j
         aZE94dWaI5RnCX8cyRerzYLVVS3TXI24a5dcNSGv/sVQogXJo/a0tyBrr081mmUpuxsu
         602sUWCIOYQBu2y/ABWZX74IuMmi2x7GmpJcLI1XfJkEy4jZXQtTsqiDvgV0NeMn9ssG
         fhnQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f13si31953477eda.21.2019.08.06.04.14.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Aug 2019 04:14:54 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 41BA7ABE3;
	Tue,  6 Aug 2019 11:14:54 +0000 (UTC)
Date: Tue, 6 Aug 2019 13:14:52 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Joel Fernandes <joel@joelfernandes.org>, linux-kernel@vger.kernel.org,
	Robin Murphy <robin.murphy@arm.com>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Borislav Petkov <bp@alien8.de>, Brendan Gregg <bgregg@netflix.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Christian Hansen <chansen3@cisco.com>, dancol@google.com,
	fmayer@google.com, "H. Peter Anvin" <hpa@zytor.com>,
	Ingo Molnar <mingo@redhat.com>, Jonathan Corbet <corbet@lwn.net>,
	Kees Cook <keescook@chromium.org>, kernel-team@android.com,
	linux-api@vger.kernel.org, linux-doc@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-mm@kvack.org,
	Mike Rapoport <rppt@linux.ibm.com>, namhyung@google.com,
	paulmck@linux.ibm.com, Roman Gushchin <guro@fb.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>, surenb@google.com,
	Thomas Gleixner <tglx@linutronix.de>, tkjos@google.com,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	Vlastimil Babka <vbabka@suse.cz>, Will Deacon <will@kernel.org>
Subject: Re: [PATCH v4 3/5] [RFC] arm64: Add support for idle bit in swap PTE
Message-ID: <20190806111452.GW11812@dhcp22.suse.cz>
References: <20190805170451.26009-1-joel@joelfernandes.org>
 <20190805170451.26009-3-joel@joelfernandes.org>
 <20190806084203.GJ11812@dhcp22.suse.cz>
 <20190806103627.GA218260@google.com>
 <20190806104755.GR11812@dhcp22.suse.cz>
 <20190806110737.GB32615@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190806110737.GB32615@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 06-08-19 20:07:37, Minchan Kim wrote:
> On Tue, Aug 06, 2019 at 12:47:55PM +0200, Michal Hocko wrote:
> > On Tue 06-08-19 06:36:27, Joel Fernandes wrote:
> > > On Tue, Aug 06, 2019 at 10:42:03AM +0200, Michal Hocko wrote:
> > > > On Mon 05-08-19 13:04:49, Joel Fernandes (Google) wrote:
> > > > > This bit will be used by idle page tracking code to correctly identify
> > > > > if a page that was swapped out was idle before it got swapped out.
> > > > > Without this PTE bit, we lose information about if a page is idle or not
> > > > > since the page frame gets unmapped.
> > > > 
> > > > And why do we need that? Why cannot we simply assume all swapped out
> > > > pages to be idle? They were certainly idle enough to be reclaimed,
> > > > right? Or what does idle actualy mean here?
> > > 
> > > Yes, but other than swapping, in Android a page can be forced to be swapped
> > > out as well using the new hints that Minchan is adding?
> > 
> > Yes and that is effectivelly making them idle, no?
> 
> 1. mark page-A idle which was present at that time.
> 2. run workload
> 3. page-A is touched several times
> 4. *sudden* memory pressure happen so finally page A is finally swapped out
> 5. now see the page A idle - but it's incorrect.

Could you expand on what you mean by idle exactly? Why pageout doesn't
really qualify as "mark-idle and reclaim"? Also could you describe a
usecase where the swapout distinction really matters and it would lead
to incorrect behavior?

-- 
Michal Hocko
SUSE Labs

