Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3924FC282C7
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 04:16:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EC77D20833
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 04:16:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EC77D20833
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 540068E0002; Wed, 30 Jan 2019 23:16:47 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4F01F8E0001; Wed, 30 Jan 2019 23:16:47 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3DFB18E0002; Wed, 30 Jan 2019 23:16:47 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 110378E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 23:16:47 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id n95so2198924qte.16
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 20:16:47 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=8T67Bx2wUUX5Uu6tbg94B6iAYeACM78K2mrjbz/stFc=;
        b=kUZ7ovwtyCw16MGAvLrtBtMnPOaR9fViApx6ndKSi7RnOTEpZu+yct7p5Ng0nlHAoI
         /Gmdmz/IF8S86IhrlXczO7VinxCPt36hLnaiexDYKkKek1h9bFNjwNXFzb6xT6GvFXvT
         5xbkI/gN2/8YSUQeEhNpc6Ok3W9W0JUeyNqEqltufYzs0rOV5ITBZVGYqBDyjrAE96Ha
         XXjAMbRPWsKamAUK7HYPjeoB3IT5jEzeRCz9RvVeUZF2x6dSHwwwJ6Npmj6p/dqSyWPP
         tJKS4iHq8WwQF15hxkanaVvtM5wmJwJDRVk5KaXXwLkPBg1qXkEUwmYBP3E+uhJRwntP
         TuLw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AJcUukdktfW4kLmwiCEUOqRy5nmEJPISpdZBGk4Vg+xFaYZkCGBNzmS/
	/LlnBEpTEghfEu1NfKaQOGMRAx0UD692YQOcFDCPvCyUxdtwgpuNBB5j7bGmWw3QqfX46/Wxfmv
	I4J37qa4YYYr7W46LeQVmSZpBk1fxn5dGZ9RBnYb9xSfvJ887TTvBihs3SjahoXOCJw==
X-Received: by 2002:ac8:44d4:: with SMTP id b20mr32265162qto.340.1548908206787;
        Wed, 30 Jan 2019 20:16:46 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5tmAiW3AdHrCrviOUgJ3xr1GmDA/Gam8LFpB/PqsMoF/vJbylLtM6f54SZ9DAYZi8Wvo3j
X-Received: by 2002:ac8:44d4:: with SMTP id b20mr32265124qto.340.1548908205773;
        Wed, 30 Jan 2019 20:16:45 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548908205; cv=none;
        d=google.com; s=arc-20160816;
        b=dWQfvhGc8YKB4I5twFKK0d0FPiP17jsJI6s0WAAdAn3m3Ah8AsEth3yut0nQeBf8k9
         DLBaNEPqILx9zUb5zQoJA/aU/aThKkeoG8SvlqmB2lVcSz3HyvHuj9xYpMAaRVVHUfhb
         MRzS59IdkvlogCZSgKZyzgGCOMyHiZaRzh4t3B0W/CPt5VRGBrZ8CecW1zcO65WalWO3
         /DlZlVG7kyG4+A/3XIHT3UgL6ZwtLbYsYomy0k/u8eT5Vc7MXTxOA/151jd4LEayRRHW
         E3ucCvsje9neujRzn3dKWkAxDnaumdyhug5uHFSIxaAJReix0KxzqmBoqTptdgfnHJ8S
         v1Nw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=8T67Bx2wUUX5Uu6tbg94B6iAYeACM78K2mrjbz/stFc=;
        b=cdP+EagUXQaFtoiswV8bTC8qgoRqB0AorL+pqckDT5WfAMNrsbL5nOhB6PACJa382N
         OL4S8IiQ+lyzvRDngGZHoZLstaGnM3mtiPmCfyAvFRfzzSfoXqlZdgUBTd8mJ5EoBhP6
         PAb+6Dq9oHXfxDqL53kDdibYcY+ohHyPeBGQDp/dnQgM9SCJB0RVbNZArfLZAm10hHDi
         lyOtIM9j0X2FUnFyJ2aoLpEM26rtXrXJV4yzVkEzyObp3rmyZpkkCQAdhrEmNFeL+uIS
         lWW5VQiahjzbXW8IC0AE3eFzlh6rkz95ZNuVBhsNRTNkys8HSpP8S9AxX14njTkH/It+
         OsQw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 52si2413034qvf.121.2019.01.30.20.16.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Jan 2019 20:16:45 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id B5F1B369CA;
	Thu, 31 Jan 2019 04:16:44 +0000 (UTC)
Received: from redhat.com (ovpn-126-0.rdu2.redhat.com [10.10.126.0])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id C5825194B6;
	Thu, 31 Jan 2019 04:16:43 +0000 (UTC)
Date: Wed, 30 Jan 2019 23:16:41 -0500
From: Jerome Glisse <jglisse@redhat.com>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Linux MM <linux-mm@kvack.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>
Subject: Re: [PATCH 09/10] mm/hmm: allow to mirror vma of a file on a DAX
 backed filesystem
Message-ID: <20190131041641.GK5061@redhat.com>
References: <20190129165428.3931-10-jglisse@redhat.com>
 <CAPcyv4gNtDQf0mHwhZ8g3nX6ShsjA1tx2KLU_ZzTH1Z1AeA_CA@mail.gmail.com>
 <20190129193123.GF3176@redhat.com>
 <CAPcyv4gkYTZ-_Et1ZriAcoHwhtPEftOt2LnR_kW+hQM5-0G4HA@mail.gmail.com>
 <20190129212150.GP3176@redhat.com>
 <CAPcyv4hZMcJ6r0Pw5aJsx37+YKx4qAY0rV4Ascc9LX6eFY8GJg@mail.gmail.com>
 <20190130030317.GC10462@redhat.com>
 <CAPcyv4jS7Y=DLOjRHbdRfwBEpxe_r7wpv0ixTGmL7kL_ThaQFA@mail.gmail.com>
 <20190130183616.GB5061@redhat.com>
 <CAPcyv4hB4p6po1+-hJ4Podxoan35w+T6uZJzqbw=zvj5XdeNVQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAPcyv4hB4p6po1+-hJ4Podxoan35w+T6uZJzqbw=zvj5XdeNVQ@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.30]); Thu, 31 Jan 2019 04:16:44 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jan 30, 2019 at 07:28:12PM -0800, Dan Williams wrote:
> On Wed, Jan 30, 2019 at 10:36 AM Jerome Glisse <jglisse@redhat.com> wrote:
> [..]
> > > > This
> > > > is one of the motivation behind HMM ie have it as an impedence layer
> > > > between mm and device drivers so that mm folks do not have to under-
> > > > stand every single device driver but only have to understand the
> > > > contract HMM has with all device driver that uses it.
> > >
> > > This gets to heart of my critique of the approach taken with HMM. The
> > > above statement is antithetical to
> > > Documentation/process/stable-api-nonsense.rst. If HMM is trying to set
> > > expectations that device-driver projects can write to a "stable" HMM
> > > api then HMM is setting those device-drivers up for failure.
> >
> > So i am not expressing myself correctly. If someone want to change mm
> > in anyway that would affect HMM user, it can and it is welcome too
> > (assuming that those change are wanted by the community and motivated
> > for good reasons). Here by understanding HMM contract and preserving it
> > what i mean is that all you have to do is update the HMM API in anyway
> > that deliver the same result to the device driver. So what i means is
> > that instead of having to understand each device driver. For instance
> > you have HMM provide X so that driver can do Y; then what can be Z a
> > replacement for X that allow driver to do Y. The point here is that
> > HMM define what Y is and provide X for current kernel mm code. If X
> > ever need to change so that core mm can evolve than you can and are
> > more than welcome to do it. With HMM Y is defined and you only need to
> > figure out how to achieve the same end result for the device driver.
> >
> > The point is that you do not have to go read each device driver to
> > figure out Y.driver_foo, Y.driver_bar, ... you only have HMM that
> > define what Y means and is ie this what device driver are trying to
> > do.
> >
> > Obviously here i assume that we do not want to regress features ie
> > we want to keep device driver features intact when we modify anything.
> 
> The specific concern is HMM attempting to expand the regression
> boundary beyond drivers that exist in the kernel. The regression
> contract that has priority is the one established for in-tree users.
> If an in-tree change to mm semantics is fine for in-tree mm users, but
> breaks out of tree users the question to those out of tree users is
> "why isn't your use case upstream?". HMM is not that use case in and
> of itself.

I do not worry about out of tree user and we should not worry about
them. I care only about upstream driver (AMD, Intel, NVidia) and i
will not do an HMM feature if i do not intend to use it in at least
one of those upstream driver. Yes i have work with NVidia on the
design simply because they are the market leader on GPU compute and
have talented engineers that know a little about what would work
well. Not working with them to get their input on design just because
their driver is closed source seems radical to me. I believe i
benefited from their valuable input. But in the end my aim is, and
have always been, to make the upstream kernel driver the best as
possible. I will talk with anyone that can help in achieving that
objective.

So do not worry about non upstream driver.


> [..]
> > Again HMM API can evolve, i am happy to help with any such change, given
> > it provides benefit to either mm or device driver (ie changing the HMM
> > just for the sake of changing the HMM API would not make much sense to
> > me).
> >
> > So if after converting driver A, B and C we see that it would be nicer
> > to change HMM in someway then i will definitly do that and this patchset
> > is a testimony of that. Converting ODP to use HMM is easier after this
> > patchset and this patchset changes the HMM API. I will be updating the
> > nouveau driver to the new API and use the new API for the other driver
> > patchset i am working on.
> >
> > If i bump again into something that would be better done any differently
> > i will definitly change the HMM API and update all upstream driver
> > accordingly.
> >
> > I am a strong believer in full freedom for internal kernel API changes
> > and my intention have always been to help and facilitate such process.
> > I am sorry this was unclear to any body :( and i am hopping that this
> > email make my intention clear.''
> 
> A simple way to ensure that out-of-tree consumers don't come beat us
> up over a backwards incompatible HMM change is to mark all the exports
> with _GPL. I'm not requiring that, the devm_memremap_pages() fight was
> hard enough, but the pace of new exports vs arrival of consumers for
> those exports has me worried that this arrangement will fall over at
> some point.

I was reluctant with the devm_memremap_pages() GPL changes because i
think we should not change symbol export after an initial choice have
been made on those.

I don't think GPL or non GPL export change one bit in respect to out
of tree user. They know they can not make any legitimate regression
claim, nor should we care. So i fail to see how GPL export would make
it any different.

> Another way to help allay these worries is commit to no new exports
> without in-tree users. In general, that should go without saying for
> any core changes for new or future hardware.

I always intend to have an upstream user the issue is that the device
driver tree and the mm tree move a different pace and there is always
a chicken and egg problem. I do not think Andrew wants to have to
merge driver patches through its tree, nor Linus want to have to merge
drivers and mm trees in specific order. So it is easier to introduce
mm change in one release and driver change in the next. This is what
i am doing with ODP. Adding things necessary in 5.1 and working with
Mellanox to have the ODP HMM patch fully tested and ready to go in
5.2 (the patch is available today and Mellanox have begin testing it
AFAIK). So this is the guideline i will be following. Post mm bits
with driver patches, push to merge mm bits one release and have the
driver bits in the next. I do hope this sound fine to everyone.

It is also easier for the driver folks as then they do not need to
have a special tree just to test my changes. They can integrate it
in their regular workflow ie merge the new kernel release in their
tree and then start pilling up changes to their driver for the next
kernel release.

Cheers,
Jérôme

