Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5DAC0C433FF
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 20:44:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 031FE20880
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 20:44:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=joelfernandes.org header.i=@joelfernandes.org header.b="cvR0USsq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 031FE20880
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=joelfernandes.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 917DD6B0003; Wed,  7 Aug 2019 16:44:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8EDDD6B0006; Wed,  7 Aug 2019 16:44:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7DDE06B0007; Wed,  7 Aug 2019 16:44:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4B7486B0003
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 16:44:54 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id j96so8206244plb.5
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 13:44:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=itaaHUuDhcUmWvWTJL4zW8mOnytMPij6pAOeeM3m1Hg=;
        b=t54spZuuK7Oufz+0ZjtUgu+MHexQ9pZRDolcE29IrJgfXXq4JyUaAgAfBDq4Z6O1Xs
         JFlKtogzi7Ham1zUjWwe/oaWK9Ci1kpWZdw5GHoq1jbTjPMf/Jv/WHD9Se+WazWC5CfF
         TGFr7+v5/HC95ftlQa6sCzr4vpSVl1cokOw7tuj/ynext/ymb94iOC+7y0FrnjSdIR0i
         0x5dLZogIflx2harNkxoNuHsvV5RCiIt+8tU5kgZV45AvTAUz45Byqm8pzKtBF7c1ahK
         9HhVmwWTiLY+GNPvBMxAqAnOdEUSTcrZeXc62Uqe6mo2p9DjYAFHPHZz/lLZCHEOcZhW
         PXlQ==
X-Gm-Message-State: APjAAAUEWCBC1n0EAynnXhKDLRAQdRpyNZpBFEAtmTU8t2RxGDwhrLRR
	u7+ebWa9TARnYC3cPpOPUbYJ0JUiWS773xj6xGveur63iRyM0TRjOYEKyegeWjDys97m5MUVYYS
	uUxtO3F8VJ3gPQgfg70iXMzzArsT0Mlj9z9h4AjB49mEobJAJwidY2iS9qz3FPW148Q==
X-Received: by 2002:aa7:84d1:: with SMTP id x17mr11361712pfn.188.1565210693896;
        Wed, 07 Aug 2019 13:44:53 -0700 (PDT)
X-Received: by 2002:aa7:84d1:: with SMTP id x17mr11361635pfn.188.1565210692715;
        Wed, 07 Aug 2019 13:44:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565210692; cv=none;
        d=google.com; s=arc-20160816;
        b=xXt6+cfdVG1shY1el8UvfrTSsUtXjxcltt/dOdSJQC3WwE9ieZp/4ywHG6DEanssRl
         D8ro7KeBnWWzQG/XUOi80k/ImoR3aNsEkQJ6yBtieEY4pUbNznnccYvRCofiMHrzqKiv
         vAeL9QZ0DkxtikLWbUrYD4lKthMEYTxzDVTcQyD0ME1AFMvidKQ07+xl2mRqHDvMjQnJ
         qwhMa+TjgZq09LVZIYhjSeOtKenuKYjzQD3zHkhoFp1YPFIoKaLY2kfvRBjMWdtWtNFQ
         Rq8KUGu7L+uefG5cmNAo/ErQFYzIdPT/zGK97ZnqbOtXYGJly+D2aptjbrh2d0Z88OjJ
         OTOg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=itaaHUuDhcUmWvWTJL4zW8mOnytMPij6pAOeeM3m1Hg=;
        b=AKa6MwNI4uqBEpvF4H8v9wY0pTjKVDZ6hMMyzPSLBGyUa2yxPb9Xe+CwB/If5/xqZv
         K1oDg8rSNwA9bQQKtLdytRro6bAfFHfLwIKglHkZqz5X6OU1IjLyCXyHxk2ifIpemayc
         dK2EyHmxSNsLcQ3AiITnmKJydzj/iDR2LMfngR9JtqZsj8op78IA7PzQ25tJCsPCDLve
         nvS1h3gl5TLG+Jnw+QlNASbCtgZupmRiCdIkNOo9K2tLIrNrT2aybg0aC8XcepYsBMnR
         jeoiB1pmcdMWEi41xNmF6k5tRelJrn2Vk6M9Rjh/tNSDFCvKSZK5smqShcFcQzqXdfxs
         dKDw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=cvR0USsq;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a1sor191258pjv.18.2019.08.07.13.44.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 07 Aug 2019 13:44:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=cvR0USsq;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=joelfernandes.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=itaaHUuDhcUmWvWTJL4zW8mOnytMPij6pAOeeM3m1Hg=;
        b=cvR0USsq4TrVGI/7AHhxTvBLliSSP311yfq2eMIv0HZPy5zvZSgUkA9hOQuqwUwOmK
         tW59Vs41S3Z4cN2lbD7CBiabk1kuZyNcNbwelUz8x6sT4Q/qw4los5KJ1TsmL/bCkQ6a
         NbDSeg5PosKj8KNSTPFRKtihsP13TwsNRRQSw=
X-Google-Smtp-Source: APXvYqzxGRsJN8tg0/I87Pfq2FlyH6V5p4w6lM9eq6TQXsCKYWlpRWdYAkMSEIlSnT6YRM40KG3l1w==
X-Received: by 2002:a17:90a:bb8a:: with SMTP id v10mr319911pjr.78.1565210692050;
        Wed, 07 Aug 2019 13:44:52 -0700 (PDT)
Received: from localhost ([2620:15c:6:12:9c46:e0da:efbf:69cc])
        by smtp.gmail.com with ESMTPSA id j1sm126143263pgl.12.2019.08.07.13.44.50
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 07 Aug 2019 13:44:51 -0700 (PDT)
Date: Wed, 7 Aug 2019 16:44:49 -0400
From: Joel Fernandes <joel@joelfernandes.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, Alexey Dobriyan <adobriyan@gmail.com>,
	Borislav Petkov <bp@alien8.de>, Brendan Gregg <bgregg@netflix.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Christian Hansen <chansen3@cisco.com>, dancol@google.com,
	fmayer@google.com, "H. Peter Anvin" <hpa@zytor.com>,
	Ingo Molnar <mingo@redhat.com>, Jonathan Corbet <corbet@lwn.net>,
	Kees Cook <keescook@chromium.org>, kernel-team@android.com,
	linux-api@vger.kernel.org, linux-doc@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-mm@kvack.org,
	Michal Hocko <mhocko@suse.com>, Mike Rapoport <rppt@linux.ibm.com>,
	minchan@kernel.org, namhyung@google.com, paulmck@linux.ibm.com,
	Robin Murphy <robin.murphy@arm.com>, Roman Gushchin <guro@fb.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>, surenb@google.com,
	Thomas Gleixner <tglx@linutronix.de>, tkjos@google.com,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	Vlastimil Babka <vbabka@suse.cz>, Will Deacon <will@kernel.org>,
	Brendan Gregg <brendan.d.gregg@gmail.com>
Subject: Re: [PATCH v4 1/5] mm/page_idle: Add per-pid idle page tracking
 using virtual indexing
Message-ID: <20190807204449.GA90900@google.com>
References: <20190805170451.26009-1-joel@joelfernandes.org>
 <20190806151921.edec128271caccb5214fc1bd@linux-foundation.org>
 <20190807100013.GC169551@google.com>
 <20190807130122.f148548c05ec07e7b716457e@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190807130122.f148548c05ec07e7b716457e@linux-foundation.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 07, 2019 at 01:01:22PM -0700, Andrew Morton wrote:
> On Wed, 7 Aug 2019 06:00:13 -0400 Joel Fernandes <joel@joelfernandes.org> wrote:
> 
> > > > 8 files changed, 376 insertions(+), 45 deletions(-)
> > > 
> > > Quite a lot of new code unconditionally added to major architectures. 
> > > Are we confident that everyone will want this feature?
> > 
> > I did not follow, could you clarify more? All of this diff stat is not to
> > architecture code:
> 
> 
> My point is that the patchset adds a lot of new code with no way in
> which users can opt out.  Almost everyone gets a fatter kernel - how
> many of those users will actually benefit from it?
> 
> If "not many" then shouldn't we be making it Kconfigurable?

Almost all of this code is already configurable with
CONFIG_IDLE_PAGE_TRACKING. If you disable it, then all of this code gets
disabled.

Or are you referring to something else that needs to be made configurable?

> Are there userspace tools which present this info to users or which
> provide monitoring of some form?  Do major distros ship those tools? 
> Do people use them?  etcetera.
> 

Android's heapprofd is what I was working on which is already using it (patch
is not yet upstreamed). There is working set tracking which Sandeep (also
from Android) said he wants to use. Minchan plans to use this in combination
with ZRAM-based idle tracking. Mike Rappoport also showed some interest, but
I am not sure where/how he is using it. These are just some of the usecases I
am aware off. I am pretty sure more will come as well.

thanks,

 - Joel

