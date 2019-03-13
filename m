Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3631BC10F00
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 01:01:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D54262063F
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 01:01:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D54262063F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 67A978E0003; Tue, 12 Mar 2019 21:01:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5FF488E0002; Tue, 12 Mar 2019 21:01:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4A1A98E0003; Tue, 12 Mar 2019 21:01:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1F82A8E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 21:01:02 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id 43so360963qtz.8
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 18:01:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=gx9txPnJRx4TXkHv4yzQP9yd5HmvftVuoapnIDpKu0Y=;
        b=MVCSlWdwfvWByUJuQzz3WogvJnt7dDhYtLbD92fzJEvlhwVmdDsFwXV2z0nps1nfCE
         zrZNpqvkul3xYdbE2gJAfrOS/t5kZ8sy6dAL0wzaIw9I3G1Pt0tNDouX1M2ktt744f4C
         90kMm/lKApn2gqpLuWB0oOPKrEF47jtGvPxq1efMU+7UsfWFIusrgRywui6WiUvybMFf
         jheVW1BmIyeJXaGWRif3b7YxQ24GqUHxNeGXB1VVflLu1yL13dCe0Lz1+21MdCHFDMm7
         2fi/N6+n+yEsp5QE7dfMWLZxT8ZpDs++tTPYIe/nQsyWZfjM66vwbocCCaol2UcuNzlj
         V/qw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXas4Q+YWEL35bUw9H3g98FgekTfJfzt/LdbdZzTy1loLa33m2l
	lfQz1jU6nwjEpPNPaRdyFDD6hzSJpTEMDRflYZxtcXVLAQP+w7CfB6wQl5ygH3FgAec2Cs+gw2V
	BCeBrXFNGiap1edI4h34hHFb5zeDtXC2Q9h4yi7N/mgFuJF836Z/ydGSxeCykluGrcw==
X-Received: by 2002:a37:5246:: with SMTP id g67mr29876260qkb.118.1552438861809;
        Tue, 12 Mar 2019 18:01:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzTE6hfe5EA5vS427MOobQf2PcskOlGg2jQOhQgwAXnT/Xx4YHZRqaez9yVsGQ0hmXs5P+E
X-Received: by 2002:a37:5246:: with SMTP id g67mr29876230qkb.118.1552438860946;
        Tue, 12 Mar 2019 18:01:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552438860; cv=none;
        d=google.com; s=arc-20160816;
        b=UUN+HM9SecdH2esu6TwqfBYwVxxrYnB8KAIQdeNLRSiLZAfVxYCjx7th4M38uah3iK
         NQ7GtotR2oL/FYrUMi+lR7enfQJ1kuiTA8LAzvZYHAkDFthAYZjiKYfSFbFO35rx/LFi
         2GYtFXp9GkUtPsj3kLXzNm24oTpCwswLy5zCvEJuGktJH/wKwoxjL1XwRDpx/8CUMhof
         aRkTZHCrRi1384bquRUJy0xxT1KYe2nxv1Wi6kqgumHX2HHrCjbykeiamrOlXZFiVsW3
         SzvDVr0aEw5vLt0TF/kiexbJURfYxiRWY518FJ0ET/x7EsiDK4NvB/MAmLSO0V1jvytW
         CZoQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=gx9txPnJRx4TXkHv4yzQP9yd5HmvftVuoapnIDpKu0Y=;
        b=lA7r4+086XVSXfi8fUFGy7L0pKtYo4V/Iapm6loC4D0DkF+yEbTY6j01E5Z6ds1sKb
         qiyI14isJZc7bhFnnRVfzhJ1eJ5enyX03xro9ookZZVcDhloryuK/80wTdSXN4m69v20
         caaAqT5afhmzLonI4JAAY4CkSVnwjZaN8FAn7JVEL8fG+YZjgZtlrnCS7HjiasqOGmPc
         IjOtFw+O8kLnw1hSmnsFNkPb8fd9+Gc6iraBaLOziEqpkNX/RuGXGyn1q2dketLtXBb5
         IPp39Ca/lfvKNe8ptn7kY+JJ4C/OQAq6VBm4SSrbW0DyEISpeCaGA8CkrsMPRJ1evH1z
         YPWw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z54si1526880qth.393.2019.03.12.18.01.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Mar 2019 18:01:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 0A9133082E71;
	Wed, 13 Mar 2019 01:01:00 +0000 (UTC)
Received: from redhat.com (ovpn-116-53.phx2.redhat.com [10.3.116.53])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 2447217184;
	Wed, 13 Mar 2019 01:00:59 +0000 (UTC)
Date: Tue, 12 Mar 2019 21:00:57 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Linux MM <linux-mm@kvack.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>
Subject: Re: [PATCH 09/10] mm/hmm: allow to mirror vma of a file on a DAX
 backed filesystem
Message-ID: <20190313010056.GA3402@redhat.com>
References: <20190307094654.35391e0066396b204d133927@linux-foundation.org>
 <20190307185623.GD3835@redhat.com>
 <CAPcyv4gkxmmkB0nofVOvkmV7HcuBDb+1VLR9CSsp+m-QLX_mxA@mail.gmail.com>
 <20190312152551.GA3233@redhat.com>
 <CAPcyv4iYzTVpP+4iezH1BekawwPwJYiMvk2GZDzfzFLUnO+RgA@mail.gmail.com>
 <20190312190606.GA15675@redhat.com>
 <CAPcyv4g-z8nkM1B65oR-3PT_RFQbmQMsM-J-P0-nzyvvJ8gVog@mail.gmail.com>
 <20190312145214.9c8f0381cf2ff2fc2904e2d8@linux-foundation.org>
 <20190313001018.GA3312@redhat.com>
 <CAPcyv4huAHnWoLQHhVRC_U6c-1DG2joOktA-ZWa-TQ1=KaTQLA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4huAHnWoLQHhVRC_U6c-1DG2joOktA-ZWa-TQ1=KaTQLA@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.46]); Wed, 13 Mar 2019 01:01:00 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 12, 2019 at 05:46:51PM -0700, Dan Williams wrote:
> On Tue, Mar 12, 2019 at 5:10 PM Jerome Glisse <jglisse@redhat.com> wrote:
> >
> > On Tue, Mar 12, 2019 at 02:52:14PM -0700, Andrew Morton wrote:
> > > On Tue, 12 Mar 2019 12:30:52 -0700 Dan Williams <dan.j.williams@intel.com> wrote:
> > >
> > > > On Tue, Mar 12, 2019 at 12:06 PM Jerome Glisse <jglisse@redhat.com> wrote:
> > > > > On Tue, Mar 12, 2019 at 09:06:12AM -0700, Dan Williams wrote:
> > > > > > On Tue, Mar 12, 2019 at 8:26 AM Jerome Glisse <jglisse@redhat.com> wrote:
> > > > [..]
> > > > > > > Spirit of the rule is better than blind application of rule.
> > > > > >
> > > > > > Again, I fail to see why HMM is suddenly unable to make forward
> > > > > > progress when the infrastructure that came before it was merged with
> > > > > > consumers in the same development cycle.
> > > > > >
> > > > > > A gate to upstream merge is about the only lever a reviewer has to
> > > > > > push for change, and these requests to uncouple the consumer only
> > > > > > serve to weaken that review tool in my mind.
> > > > >
> > > > > Well let just agree to disagree and leave it at that and stop
> > > > > wasting each other time
> > > >
> > > > I'm fine to continue this discussion if you are. Please be specific
> > > > about where we disagree and what aspect of the proposed rules about
> > > > merge staging are either acceptable, painful-but-doable, or
> > > > show-stoppers. Do you agree that HMM is doing something novel with
> > > > merge staging, am I off base there?
> > >
> > > You're correct.  We chose to go this way because the HMM code is so
> > > large and all-over-the-place that developing it in a standalone tree
> > > seemed impractical - better to feed it into mainline piecewise.
> > >
> > > This decision very much assumed that HMM users would definitely be
> > > merged, and that it would happen soon.  I was skeptical for a long time
> > > and was eventually persuaded by quite a few conversations with various
> > > architecture and driver maintainers indicating that these HMM users
> > > would be forthcoming.
> > >
> > > In retrospect, the arrival of HMM clients took quite a lot longer than
> > > was anticipated and I'm not sure that all of the anticipated usage
> > > sites will actually be using it.  I wish I'd kept records of
> > > who-said-what, but I didn't and the info is now all rather dissipated.
> > >
> > > So the plan didn't really work out as hoped.  Lesson learned, I would
> > > now very much prefer that new HMM feature work's changelogs include
> > > links to the driver patchsets which will be using those features and
> > > acks and review input from the developers of those driver patchsets.
> >
> > This is what i am doing now and this patchset falls into that. I did
> > post the ODP and nouveau bits to use the 2 new functions (dma map and
> > unmap). I expect to merge both ODP and nouveau bits for that during
> > the next merge window.
> >
> > Also with 5.1 everything that is upstream is use by nouveau at least.
> > They are posted patches to use HMM for AMD, Intel, Radeon, ODP, PPC.
> > Some are going through several revisions so i do not know exactly when
> > each will make it upstream but i keep working on all this.
> >
> > So the guideline we agree on:
> >     - no new infrastructure without user
> >     - device driver maintainer for which new infrastructure is done
> >       must either sign off or review of explicitly say that they want
> >       the feature I do not expect all driver maintainer will have
> >       the bandwidth to do proper review of the mm part of the infra-
> >       structure and it would not be fair to ask that from them. They
> >       can still provide feedback on the API expose to the device
> >       driver.
> >     - driver bits must be posted at the same time as the new infra-
> >       structure even if they target the next release cycle to avoid
> >       inter-tree dependency
> >     - driver bits must be merge as soon as possible
> 
> What about EXPORT_SYMBOL_GPL?

I explained why i do not see value in changing export, but i will not
oppose that change either.


> > Thing we do not agree on:
> >     - If driver bits miss for any reason the +1 target directly
> >       revert the new infra-structure. I think it should not be black
> >       and white and the reasons why the driver bit missed the merge
> >       window should be taken into account. If the feature is still
> >       wanted and the driver bits missed the window for simple reasons
> >       then it means that we push everything by 2 release ie the
> >       revert is done in +1 then we reupload the infra-structure in
> >       +2 and finaly repush the driver bit in +3 so we loose 1 cycle.
> 
> I think that pain is reasonable.
> 
> >       Hence why i would rather that the revert would only happen if
> >       it is clear that the infrastructure is not ready or can not
> >       be use in timely (over couple kernel release) fashion by any
> >       drivers.
> 
> This seems too generous to me, but in the interest of moving this
> discussion forward let's cross that bridge if/when it happens.
> Hopefully the threat of this debate recurring means consumers put in
> the due diligence to get things merged at infrastructure + 1 time.

