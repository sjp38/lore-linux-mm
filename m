Return-Path: <SRS0=ikTF=QP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 31012C169C4
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 21:25:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ECF15218DA
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 21:25:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ECF15218DA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 854078E00A0; Fri,  8 Feb 2019 16:25:35 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 82A038E009B; Fri,  8 Feb 2019 16:25:35 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 719448E00A0; Fri,  8 Feb 2019 16:25:35 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2FF998E009B
	for <linux-mm@kvack.org>; Fri,  8 Feb 2019 16:25:35 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id h26so3694686pfn.20
        for <linux-mm@kvack.org>; Fri, 08 Feb 2019 13:25:35 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=w+26vZ9HLQSVanmE+t5OokxAUlh4Ochsyd/PUxyeTfM=;
        b=hmlhI2LZUB9OY/u0WI8MLclm9sF73LFf/B3p9F1GGV0j/NCkWPiT3JOK2YUOJJjd9+
         SE26ZhGhM1zHXr4jEg6WRaeWIdC1z47k/K5lfPvAYZ9yUxebCFHFV1CxpTDX1DvPJeqe
         hD+znLRemU06f59d46W8V2HTS9qpC1VW/fnDjTAu6QaOWLsf427eHikRlBjRZb5en42a
         bTPwuUKAPhzoQNOCDRDbyIicBhvs3uajVGVoJcu1Wt/n9kiyo97am9/0SyywTC+tRz+F
         KRZ/r3xFrKCYiztMFsWpQRgkwZonELd/CiMNZEzBeSN+7SZZ4xWrj+mCGlIe2GSBimEF
         hzFQ==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 150.101.137.131 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
X-Gm-Message-State: AHQUAuYORQyljAfXHXDshXmElAHnAZ2sQm4uW/5KPS+RZct8FLHkXiq8
	nsYOVp4lN4tF8lkedezowBqf4+BJjBHTwGAdlwVXF0v28G/ijGpBpQvMRnShrerR425yzFvzigz
	0cJ9mZR53ZsHvH/weDBglMbZNO/VlqHS7ljRl8EW1eCBHnFW3wqDnogaobx+WSro=
X-Received: by 2002:a17:902:31a4:: with SMTP id x33mr24277241plb.198.1549661134796;
        Fri, 08 Feb 2019 13:25:34 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZm/VYeoyjv3GrOZcWYCEgIDJdc9ffHZbEepgyhx1s/kROjB0OFeopAGzKNTgiy+CZdQDNU
X-Received: by 2002:a17:902:31a4:: with SMTP id x33mr24277194plb.198.1549661134066;
        Fri, 08 Feb 2019 13:25:34 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549661134; cv=none;
        d=google.com; s=arc-20160816;
        b=P0B9Wbu3GrwtLqSBrTJzrsihHyWSluYPLOaqqe6BI5TwLP1MzpCZsABPJvNDopfjW6
         TelMTQkEsmbD+gvZe3gvKMavLdQXw60+Q08B3IEMfaKQqSQ8A4sEoAEE91E1R5z33/lK
         yj+9CPFqKtVyJsHw3KWOU5l3K/B2bBRLSGMBdTzG9Km0s2Z9laqqvhHmdZXWEWGSbwPv
         o9bO8SwTnKprwmywZ9aRTEJ09LpUvKpD90p24rcjndvtZGQlDWtBq++1+6oVBS+PXq/X
         fTTWVa50xkXGHh9btmJZwi9iTUC1rSgSpvVWniNbCowoLh9K5bzIj3aVdpDiR9IxwCgR
         VqDQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=w+26vZ9HLQSVanmE+t5OokxAUlh4Ochsyd/PUxyeTfM=;
        b=i+uUNyfxO/zpHyjHuelByyccttYSzjGuaNHwXVKHIOX78a9DNAn9/jv/v2FcqUFevl
         s/oneus2fs+/eJBfyf9pvKrOB9bYRr7SElNE9c/rAaIz+wCdcf3kNWYKSd9XERr0Rg5w
         +EpC9Qycp7JdLuMUyke7BZ+AqlM/66+F7a7kn8OVKuqVZoQrBi6uBeglKVKhr1ikL3J+
         Gadm1FhXBNEtA4NpS/9uebaueNTtAPQ0zCpdgfuvGN01cuIUhfTB1SGB4bDAp0Fz9Lnh
         eDC691RR4PdU/POMj3HCUjZNWQQWUq38P/YIyibF2ld1E3OmvmAYUBThZbraw4p/8hSz
         /goQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 150.101.137.131 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [150.101.137.131])
        by mx.google.com with ESMTP id 32si3352185plg.29.2019.02.08.13.25.33
        for <linux-mm@kvack.org>;
        Fri, 08 Feb 2019 13:25:34 -0800 (PST)
Received-SPF: neutral (google.com: 150.101.137.131 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) client-ip=150.101.137.131;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 150.101.137.131 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from ppp59-167-129-252.static.internode.on.net (HELO dastard) ([59.167.129.252])
  by ipmail07.adl2.internode.on.net with ESMTP; 09 Feb 2019 07:55:31 +1030
Received: from dave by dastard with local (Exim 4.80)
	(envelope-from <david@fromorbit.com>)
	id 1gsDeN-0006PR-2l; Sat, 09 Feb 2019 08:25:31 +1100
Date: Sat, 9 Feb 2019 08:25:31 +1100
From: Dave Chinner <david@fromorbit.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Roman Gushchin <guro@fb.com>,
	Michal Hocko <mhocko@kernel.org>, Chris Mason <clm@fb.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
	"linux-xfs@vger.kernel.org" <linux-xfs@vger.kernel.org>,
	"vdavydov.dev@gmail.com" <vdavydov.dev@gmail.com>
Subject: Re: [PATCH 1/2] Revert "mm: don't reclaim inodes with many attached
 pages"
Message-ID: <20190208212531.GN14116@dastard>
References: <20190130041707.27750-1-david@fromorbit.com>
 <20190130041707.27750-2-david@fromorbit.com>
 <25EAF93D-BC63-4409-AF21-F45B2DDF5D66@fb.com>
 <20190131013403.GI4205@dastard>
 <20190131091011.GP18811@dhcp22.suse.cz>
 <20190131185704.GA8755@castle.DHCP.thefacebook.com>
 <20190131221904.GL4205@dastard>
 <20190207102750.GA4570@quack2.suse.cz>
 <20190207213727.a791db810341cec2c013ba93@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190207213727.a791db810341cec2c013ba93@linux-foundation.org>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 07, 2019 at 09:37:27PM -0800, Andrew Morton wrote:
> On Thu, 7 Feb 2019 11:27:50 +0100 Jan Kara <jack@suse.cz> wrote:
> 
> > On Fri 01-02-19 09:19:04, Dave Chinner wrote:
> > > Maybe for memcgs, but that's exactly the oppose of what we want to
> > > do for global caches (e.g. filesystem metadata caches). We need to
> > > make sure that a single, heavily pressured cache doesn't evict small
> > > caches that lower pressure but are equally important for
> > > performance.
> > > 
> > > e.g. I've noticed recently a significant increase in RMW cycles in
> > > XFS inode cache writeback during various benchmarks. It hasn't
> > > affected performance because the machine has IO and CPU to burn, but
> > > on slower machines and storage, it will have a major impact.
> > 
> > Just as a data point, our performance testing infrastructure has bisected
> > down to the commits discussed in this thread as the cause of about 40%
> > regression in XFS file delete performance in bonnie++ benchmark.
> > 
> 
> Has anyone done significant testing with Rik's maybe-fix?

Apart from pointing out all the bugs and incorrect algorithmic
assumptions it makes, no.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

