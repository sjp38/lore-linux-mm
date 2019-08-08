Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 601FBC433FF
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 08:13:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1BC8F21881
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 08:13:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1BC8F21881
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A6E166B0006; Thu,  8 Aug 2019 04:13:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A45D46B0007; Thu,  8 Aug 2019 04:13:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 90ECF6B0008; Thu,  8 Aug 2019 04:13:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 457AC6B0006
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 04:13:52 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id x40so688009edm.4
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 01:13:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=SfndbGFqkr74wmwGmSuGytivPeXiUPVqQkuWWMBeH30=;
        b=HiIdtd35ut2Cn7RSQHwjkBOc7KnPdiJdA6FUQVKL0TsTeUpwGOaZD2WV1kpBvJrL7o
         q4YmfsuEKi7gBwYgrL9P9vxH/yER/rHcu3y8iiMyh7U6Funfr/gW4agfc++IAXBxGG+p
         WZejYNjc3DgOOL/csYCbguKj2rxb0nyOsLPCP4IuduxGN9oYJber/eG81uFxlBRPAyz/
         En98BofGYXUhrePzT8c6c8p3rDZRzhotLF6m8FRTtQ4+T4ZlzsZACko6ycykNtQ5hmI9
         uzxpPbEJJRK3aQcIqy7lspKGXk/2Ao9XnaAoQ9vYFH89QuP1R5jvt1GTrYwZcf6lXvmx
         Uluw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAV2Q057wH27gATpN22Yc7AgcY0aWiwoEDz+A1AmsDXhMajL7+Mx
	v49tnIKRHPrJ4ziMpqUa3EADIs965ywgJzeRy7f7+4PPKJsf1x6cp6IXAQkMaL0F9jnKgNhACwk
	vyHqlfltLT3fgckVvxvV/TaR7Y/n/rL13I/7Rv5nLOtck67xkUnQpYXb7iOAT7fI=
X-Received: by 2002:a50:f49a:: with SMTP id s26mr14459901edm.191.1565252031813;
        Thu, 08 Aug 2019 01:13:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxh2xXo2awkIAtLy0tu4DaToKc/o6K9vfqACyNuOaAvnBExT2KnQZBYc7HevkwXf/uxGq6Z
X-Received: by 2002:a50:f49a:: with SMTP id s26mr14459865edm.191.1565252031143;
        Thu, 08 Aug 2019 01:13:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565252031; cv=none;
        d=google.com; s=arc-20160816;
        b=mhP0I13JdX3MCnhW2RRsmDKM9lUfzQx6zxUytH20TZS9cRVO2Oc21hnzgA3OvZZji2
         9dNnBpeLtCdXPruEq1QzPkh+SAQKvoS4uoiIBX6G7oZfHr+8uz6Sl2adknUL1y2auj/5
         5A7I89FkdsPIRLHIGTpyxHhyn2INZShPNq/B9u5WmNOmVvrxKfUxKaWFNwtJHL/hL8Xa
         1yfM2L9q4vooFKpHGtM/SyhAci4puXZndXWdRLgaREOLE/nVMxhz+7aIcFvxDe7haSwO
         oyzqw89/ewJLSeVVdRhEwnDR++Cs7v8+83efuQEZniuDdtw6vE4uZrcMTl/hOoSnB8+i
         kt+A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=SfndbGFqkr74wmwGmSuGytivPeXiUPVqQkuWWMBeH30=;
        b=tQdKcUXnoGUR/AO2OUMj/09dmSnRSzXBOvuuqMfaoHJ0DIcc/f0qdD4TXgKGhzVvCx
         ZsZkCxQNWHzQRMN5YBBFOQU3WEq3sYKAgpK3IPxJ8gxrNe5Dzzs8B0Kire+vxGHHqVtP
         R33TqUaq/HZqOPKJF3RLfBQr8br7ew3LdPxnkWYNbOy98db8zttioIWkg5y+dHNqCEvD
         fnn6oDqPEJRQjfiqrmR5s5wg4LngF+sd69UX5upJQ45seIuLnzfXLZPZthgNSYVlsh18
         uNc0cUtFNUQK3bI7ofW7PUdzgUz4Uz9wlk0j8VuQGZYNyYkDE26ksV2oDoOBqGGcHeHf
         oW7g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f1si33500290ede.62.2019.08.08.01.13.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Aug 2019 01:13:51 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 68840AFFE;
	Thu,  8 Aug 2019 08:13:49 +0000 (UTC)
Date: Thu, 8 Aug 2019 10:00:44 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Joel Fernandes <joel@joelfernandes.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Borislav Petkov <bp@alien8.de>, Brendan Gregg <bgregg@netflix.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Christian Hansen <chansen3@cisco.com>, dancol@google.com,
	fmayer@google.com, "H. Peter Anvin" <hpa@zytor.com>,
	Ingo Molnar <mingo@redhat.com>, Jonathan Corbet <corbet@lwn.net>,
	Kees Cook <keescook@chromium.org>, kernel-team@android.com,
	linux-api@vger.kernel.org, linux-doc@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-mm@kvack.org,
	Mike Rapoport <rppt@linux.ibm.com>, minchan@kernel.org,
	namhyung@google.com, paulmck@linux.ibm.com,
	Robin Murphy <robin.murphy@arm.com>, Roman Gushchin <guro@fb.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>, surenb@google.com,
	Thomas Gleixner <tglx@linutronix.de>, tkjos@google.com,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	Vlastimil Babka <vbabka@suse.cz>, Will Deacon <will@kernel.org>
Subject: Re: [PATCH v5 1/6] mm/page_idle: Add per-pid idle page tracking
 using virtual index
Message-ID: <20190808080044.GA18351@dhcp22.suse.cz>
References: <20190807171559.182301-1-joel@joelfernandes.org>
 <20190807130402.49c9ea8bf144d2f83bfeb353@linux-foundation.org>
 <20190807204530.GB90900@google.com>
 <20190807135840.92b852e980a9593fe91fbf59@linux-foundation.org>
 <20190807213105.GA14622@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190807213105.GA14622@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 07-08-19 17:31:05, Joel Fernandes wrote:
> On Wed, Aug 07, 2019 at 01:58:40PM -0700, Andrew Morton wrote:
> > On Wed, 7 Aug 2019 16:45:30 -0400 Joel Fernandes <joel@joelfernandes.org> wrote:
> > 
> > > On Wed, Aug 07, 2019 at 01:04:02PM -0700, Andrew Morton wrote:
> > > > On Wed,  7 Aug 2019 13:15:54 -0400 "Joel Fernandes (Google)" <joel@joelfernandes.org> wrote:
> > > > 
> > > > > In Android, we are using this for the heap profiler (heapprofd) which
> > > > > profiles and pin points code paths which allocates and leaves memory
> > > > > idle for long periods of time. This method solves the security issue
> > > > > with userspace learning the PFN, and while at it is also shown to yield
> > > > > better results than the pagemap lookup, the theory being that the window
> > > > > where the address space can change is reduced by eliminating the
> > > > > intermediate pagemap look up stage. In virtual address indexing, the
> > > > > process's mmap_sem is held for the duration of the access.
> > > > 
> > > > So is heapprofd a developer-only thing?  Is heapprofd included in
> > > > end-user android loads?  If not then, again, wouldn't it be better to
> > > > make the feature Kconfigurable so that Android developers can enable it
> > > > during development then disable it for production kernels?
> > > 
> > > Almost all of this code is already configurable with
> > > CONFIG_IDLE_PAGE_TRACKING. If you disable it, then all of this code gets
> > > disabled.
> > > 
> > > Or are you referring to something else that needs to be made configurable?
> > 
> > Yes - the 300+ lines of code which this patchset adds!
> > 
> > The impacted people will be those who use the existing
> > idle-page-tracking feature but who will not use the new feature.  I
> > guess we can assume this set is small...
> 
> Yes, I think this set should be small. The code size increase of page_idle.o
> is from ~1KB to ~2KB. Most of the extra space is consumed by
> page_idle_proc_generic() function which this patch adds. I don't think adding
> another CONFIG option to disable this while keeping existing
> CONFIG_IDLE_PAGE_TRACKING enabled, is worthwhile but I am open to the
> addition of such an option if anyone feels strongly about it. I believe that
> once this patch is merged, most like this new interface being added is what
> will be used more than the old interface (for some of the usecases) so it
> makes sense to keep it alive with CONFIG_IDLE_PAGE_TRACKING.

I would tend to agree with Joel here. The functionality falls into an
existing IDLE_PAGE_TRACKING config option quite nicely. If there really
are users who want to save some space and this is standing in the way
then they can easily add a new config option with some justification so
the savings are clear. Without that an additional config simply adds to
the already existing configurability complexity and balkanization.
-- 
Michal Hocko
SUSE Labs

