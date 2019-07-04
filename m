Return-Path: <SRS0=d6aY=VB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0554DC46497
	for <linux-mm@archiver.kernel.org>; Thu,  4 Jul 2019 20:53:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B2E6E218A3
	for <linux-mm@archiver.kernel.org>; Thu,  4 Jul 2019 20:53:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="OQmQWxaH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B2E6E218A3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 346316B0003; Thu,  4 Jul 2019 16:53:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2D1448E0003; Thu,  4 Jul 2019 16:53:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 171198E0001; Thu,  4 Jul 2019 16:53:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id D6C156B0003
	for <linux-mm@kvack.org>; Thu,  4 Jul 2019 16:53:35 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id i26so4236793pfo.22
        for <linux-mm@kvack.org>; Thu, 04 Jul 2019 13:53:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=13xHhNUSiKr79DSrollfTiIXVy0vzGDio58nizvtrnc=;
        b=U/loPPWpSfXc9KEeyz67nce+8G+qaJEFUi7XQKo9QkrAmqH1lNVqIiYf1bbx0W9B5u
         IisNauThCwolIvnKXGDkZYW1DiStaSIy2E2TdLTeVl0u+q7/PkzYWkj3iDbv0mNs+xcx
         rdg0QuNz7G3zabt5lAfO1dmElU4wM640wDxuLgpWx4m1ZKVARh5EkVFRFWg93d8lnuFV
         4y1J2sv+PWD05JG1SqyUL+0ZJ8yFZJx7KXTHNDCkEfylDwKlxSYZX4E4bmLZbEW+IbV2
         xK/8csGUPBWxTradHxnA7MzUCh42X2Rwq7P71kKNOPBX00dsjOcXXHf9PMsoNbESvxHt
         X9UA==
X-Gm-Message-State: APjAAAWQp8ex8Des6Lc3WUYI8VEBXCsieJuCnVoWYzBbh/vMqlz0gPbP
	JKMGx7uyitALZnZT4Kg8/QnG/dGp1I+R9Uv4JoCll0s8G6z0NoPSR2G2jEbvQQAKT0rWD2psJgp
	p2JZCqwFy+bJ+TLe20WlVNTz5eQDVlvjYCZzVd3NjvGA138pO9gFX9TWO58K/MWYrBQ==
X-Received: by 2002:a63:4d50:: with SMTP id n16mr456799pgl.146.1562273615336;
        Thu, 04 Jul 2019 13:53:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzMiRUWNlSFLYQuo0TrS2rz3iCyTF+R9dj+zITo1cjDUkOL37/kqoxHXmoXBMDMgvh1aMhf
X-Received: by 2002:a63:4d50:: with SMTP id n16mr456753pgl.146.1562273614414;
        Thu, 04 Jul 2019 13:53:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562273614; cv=none;
        d=google.com; s=arc-20160816;
        b=ByVNYt8KIVNqtUegIZdGzHfEZgum0lMXqVI7hbyCClsFsOgU1ImTpTEWp+x14mEht7
         ykAcEpW6IM4RaGYwmxU9EGJq2sicTRws0dPP/VJkW26h8AYgEtnAvfYoZArxChSYj1uU
         WWVtP4LF8CGNsWMlbzobwxzKNdRZ3Ru7wxllKKBPKciLMbEcRZxOdabukTr9Nxmjf0Mf
         lIBTGQwSju+iP7UekwMHGo8gGKTK+eSCPCeM1x/coWUIKsfbmzSdUmSxtigAhtS6nEDS
         QGkx/VYuiPSMcewzp/Qq5DlcK9YYelhjdFZKYGi/gMSDTSbKKIuSYe0SclAK9XZIaE2M
         LTQQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=13xHhNUSiKr79DSrollfTiIXVy0vzGDio58nizvtrnc=;
        b=Q9ABwe9ep45SDjC11dyYgAd580t9LlVb+XJSqu3kRSmJ7hOBSRwGvZeKuitoQQajt9
         EmZK7Qf6euNW1pE7YjCzTfxd16Z6VIE3ee7umfa7NRE+xIbEcQ8yiE3Um3gEanxl3w6W
         Jgy1UBSS4Inhzp+nH8MY837cwodrJK0g/f15B6kMzHBDurmkVuHEzCvoW8A06B7xTmr1
         dqAI7Emy1UoPl36NypPOcECVCb0qg17do6brR7i8GH/Iy7H4a/ssLWoh1lMqCMLf2iDt
         UO1cUaljrsVlC4Y/Cz/0fCXCt2E5pJ4qodBEBUwKIPPfQYRo1HVdjg2nneSmFV/vhcky
         kfWA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=OQmQWxaH;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id l70si5544798pje.68.2019.07.04.13.53.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Jul 2019 13:53:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=OQmQWxaH;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 6D2C02083B;
	Thu,  4 Jul 2019 20:53:33 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1562273613;
	bh=fHB5OlE7wI5HD4vTrIqKCfUtCNsXUfIwuF85zxThTaM=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=OQmQWxaH1tJEFpi4jbH2I0D8Oz0s8ym/oz7j+tkYDL6g7uXejsiAtUfU38+BcV/zG
	 WtCh68hjwLBB9taaYo4e3bDMPmWrR9i+UT4qpOtAdX2eFfSmQP9IMd9eq3skgpik5y
	 k6rJVQlxs70evg6Q6C0OlifqVvpdw/5LksGoBaQQ=
Date: Thu, 4 Jul 2019 13:53:32 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Jason Gunthorpe <jgg@mellanox.com>
Cc: Christoph Hellwig <hch@infradead.org>, Mark Rutland
 <mark.rutland@arm.com>, Robin Murphy <robin.murphy@arm.com>,
 "linux-mm@kvack.org" <linux-mm@kvack.org>, "will.deacon@arm.com"
 <will.deacon@arm.com>, "catalin.marinas@arm.com" <catalin.marinas@arm.com>,
 "anshuman.khandual@arm.com" <anshuman.khandual@arm.com>,
 "linux-arm-kernel@lists.infradead.org"
 <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org"
 <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Dan
 Williams <dan.j.williams@intel.com>
Subject: Re: [PATCH v3 0/4] Devmap cleanups + arm64 support
Message-Id: <20190704135332.234891ac6ce641bf29913d06@linux-foundation.org>
In-Reply-To: <20190704195934.GA23542@mellanox.com>
References: <cover.1558547956.git.robin.murphy@arm.com>
	<20190626073533.GA24199@infradead.org>
	<20190626123139.GB20635@lakrids.cambridge.arm.com>
	<20190626153829.GA22138@infradead.org>
	<20190626154532.GA3088@mellanox.com>
	<20190626203551.4612e12be27be3458801703b@linux-foundation.org>
	<20190704115324.c9780d01ef6938ab41403bf9@linux-foundation.org>
	<20190704195934.GA23542@mellanox.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 4 Jul 2019 19:59:38 +0000 Jason Gunthorpe <jgg@mellanox.com> wrote:

> On Thu, Jul 04, 2019 at 11:53:24AM -0700, Andrew Morton wrote:
> > On Wed, 26 Jun 2019 20:35:51 -0700 Andrew Morton <akpm@linux-foundation.org> wrote:
> > 
> > > > Let me know and I can help orchestate this.
> > > 
> > > Well.  Whatever works.  In this situation I'd stage the patches after
> > > linux-next and would merge them up after the prereq patches have been
> > > merged into mainline.  Easy.
> > 
> > All right, what the hell just happened? 
> 
> Christoph's patch series for the devmap & hmm rework finally made it
> into linux-next

We're talking about "dev_pagemap related cleanups v4", yes?

I note that linux-next contains "mm: remove the HMM config option"
which was present in Christoph's v3 series but wasn't present in v4. 
Perhaps something has gone wrong here.

> sorry, it took quite a few iterations on the list to
> get all the reviews and tests, and figure out how to resolve some
> other conflicting things. So it just made it this week.
> 
> Recall, this is the patch series I asked you about routing a few weeks
> ago, as it really exceeded the small area that hmm.git was supposed to
> cover. I think we are both caught off guard how big the conflict is!

I guess I was distracted - I should have taken a look to see how
mergable it all was.

It's a large patchset and it appears to be mainly (entirely?) code
cleanups.  I don't think such material would be appropriate for a late
-rc7 merge even if it didn't conflict with lots of other higher
priority pending functional changes and fixes!

