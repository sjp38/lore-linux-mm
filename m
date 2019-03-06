Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E6349C4360F
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 16:06:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 912FB206DD
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 16:06:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="uD10yDwo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 912FB206DD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1A9788E0022; Wed,  6 Mar 2019 11:06:20 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 17F338E0015; Wed,  6 Mar 2019 11:06:20 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 047DB8E0022; Wed,  6 Mar 2019 11:06:20 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id C4C4B8E0015
	for <linux-mm@kvack.org>; Wed,  6 Mar 2019 11:06:19 -0500 (EST)
Received: by mail-ot1-f71.google.com with SMTP id k15so5388969otn.18
        for <linux-mm@kvack.org>; Wed, 06 Mar 2019 08:06:19 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=WG5FG4s0G29MK3NWb/ke+Ciqb1d4X6CIoH9BNgecVEo=;
        b=lwKCVqK7Ih3WeGDCAdWXHH6VOitU+rczFT+RAmT22lit/q6VHNXxs8HpFcN3sefOtM
         RY3StbykFeRAhGAQwSjvriyfdIdmD6wa7Jmwqdhi4EJmveohNU6ByUA75TvLBbco6Xiq
         M+OTy13/p3/6BZUySHpYAf+3NQgLrPBBRKB/SUUGnZ+ZcMftis6e3fgYaAxrKaWtwpis
         ScaxTVs77iWIZwM8q4ydqU76GXgM69dzmeGcTKS/Ksl4e8847VeMlx5xz8Imrsgpt0Le
         j8aublf1mxhvwIGTz/uV9RiBH6jRC/+B/RX5uqURFzZBnTDQiqJy5uPxdlzu9VQw49g5
         DEEw==
X-Gm-Message-State: APjAAAVqdQfeWV7C4CiqmiD9rJKCEPt80Y6fh2brJB0XBJC2OWs5BvXT
	iwAdAvzUr8R64vP22yo7P6K1tzlUZ5Duj+hVvs453plcJ1KNvIxilCuLqzgTfQTVEgaEIIY2PoV
	EqRs378s9zeR9zBZpJW9cs7pFW3k346WZu+q02/PO2/iMAMfq3VGQj/xe5K+Vxo3mIaOxP0wxj3
	4/0iKjSOt8QiUB52UQ1/6L7lnQCUmRLh2tjQIebZdFgeUACRw3f70CAeVV8w2ZtDmDowrxmbWnb
	F1Ug0PEBEDUGGTQuKCWU5DQzo1OF7tqHWQd/k4zJooynjl/vDxBIUO+t2ZEVfswvMLqMM1wHeHK
	9TvIYQSoJxYHJQ8P14HL1NhRCM+YW+1JU0G9bsx8HrsnIvX7j/Oh0LagGhAo8Y4KPODjgEFeqj3
	b
X-Received: by 2002:a05:6830:154b:: with SMTP id l11mr5003589otp.356.1551888379471;
        Wed, 06 Mar 2019 08:06:19 -0800 (PST)
X-Received: by 2002:a05:6830:154b:: with SMTP id l11mr5003511otp.356.1551888378350;
        Wed, 06 Mar 2019 08:06:18 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551888378; cv=none;
        d=google.com; s=arc-20160816;
        b=B4aS+KEOHAFfpypLjhdr3xhyxMJozJN+VF3F+tj8zKBjyPbVE/QAQPY5p0BlCfBHRg
         uSqR/3w7apA6ql8YqzCW8zsTO+zsDwtgpEy5KoX9cTmvjoC18M8imuQiwwjnm/oWoH05
         DWetwuklMAO2pxGCRi8DirbkuWjcti3UmrBUug9p8ITbJ74K4pF6LU5y3ivn2C2MxI4D
         yvcgLAf8eCkjv3R3YZTtZkR5txius6rgT+lX3n2Liak5pWg6diPUyTg6R/mwY8cEcWuP
         czKUXPcqF0fLffTY9kKM/MYPhkMrHY6rx9aZc2J+Df0PcSP6BPa/3TzkiNQ+U8d5ykmr
         Txww==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=WG5FG4s0G29MK3NWb/ke+Ciqb1d4X6CIoH9BNgecVEo=;
        b=Jk2JMDuRFju26gh12lJ190V+S7NMU6rTpV/ZX5BFFiG6OkuBME+EqdVjuMtfVdBc/y
         yqqkWU61GV8Y11DTgry1qojKGYv2bQIPOEY4wfKpQBNsmje+qL1P3+o8+TRetAH+CQuN
         hZKvpQWwGmjxXj1lQQiMMVGj0/XPHm6Pf8xySBXo2LQR8sCVT+0O/d3aNLEnbZXZXMc2
         k/DBFepd5PK74F8uwe5krn1yTgYnp+l7ccnDY8QIAv72oCHyq3sdM9L9dcamfZFgXaf+
         cmpvENXdFHaXBZnm9RlZR0mfAjiENp91WKKZSER6k9tVhnNQYRzVW1foA5nS4eKQb5Lg
         9j1w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=uD10yDwo;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t186sor954911oif.35.2019.03.06.08.06.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 06 Mar 2019 08:06:18 -0800 (PST)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=uD10yDwo;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=WG5FG4s0G29MK3NWb/ke+Ciqb1d4X6CIoH9BNgecVEo=;
        b=uD10yDwoqS+39AuF/q/8f2su76UGF+Ysjs+eUQCv4yAAzJ4AXAVFN7b788jut6Tv3c
         LF1oV6T4k19AZ3E3r3bsP/3NEvaK/nuhVhmi4hWADJ1127foZpuI5Rl7/DyaaVtSfyg2
         m+46swM8ng+Cnq0PUdMl9aRAsLdUOj0gERipDm/U7GlfeWAY2H73Vk/Gh9mcOJHQXEJ0
         nRgckaAjjHBCt7s8MyO4yf9rmDifHtegTjbRh19faCmeMVeMPZeAW8motKnnc8lSA5Dw
         LNCsnhSijSB7fvhl6DWi1m8CLb4w1ocuTQO/c7RYmLvTvYFa1Y/xIE+MczEYXG2m8gMf
         dKiA==
X-Google-Smtp-Source: APXvYqzFh+cTk/5CYyCQGJZDVzHSMsSxu7SkZ6Xp7zboFKl45gJPzZJrWEZ3qEe/sbhoN4sz8AeOrnOKYR9Z6fgF3Mw=
X-Received: by 2002:aca:fc06:: with SMTP id a6mr2167317oii.0.1551888377959;
 Wed, 06 Mar 2019 08:06:17 -0800 (PST)
MIME-Version: 1.0
References: <20190130030317.GC10462@redhat.com> <CAPcyv4jS7Y=DLOjRHbdRfwBEpxe_r7wpv0ixTGmL7kL_ThaQFA@mail.gmail.com>
 <20190130183616.GB5061@redhat.com> <CAPcyv4hB4p6po1+-hJ4Podxoan35w+T6uZJzqbw=zvj5XdeNVQ@mail.gmail.com>
 <20190131041641.GK5061@redhat.com> <CAPcyv4gb+r==riKFXkVZ7gGdnKe62yBmZ7xOa4uBBByhnK9Tzg@mail.gmail.com>
 <20190305141635.8134e310ba7187bc39532cd3@linux-foundation.org>
 <CAA9_cmd2Z62Z5CSXvne4rj3aPSpNhS0Gxt+kZytz0bVEuzvc=A@mail.gmail.com>
 <20190306155126.GB3230@redhat.com> <CAPcyv4iB+7LF-ZOF1VXE+g2hS7Gb=+RbGAmTiGWDsaikEuXGYw@mail.gmail.com>
 <20190306160323.GD3230@redhat.com>
In-Reply-To: <20190306160323.GD3230@redhat.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 6 Mar 2019 08:06:06 -0800
Message-ID: <CAPcyv4jxsbWUMmnsnQ07Cd4LdW47dqef-BBR=hS_DHS0UZ6N2g@mail.gmail.com>
Subject: Re: [PATCH 09/10] mm/hmm: allow to mirror vma of a file on a DAX
 backed filesystem
To: Jerome Glisse <jglisse@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Ralph Campbell <rcampbell@nvidia.com>, 
	John Hubbard <jhubbard@nvidia.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 6, 2019 at 8:03 AM Jerome Glisse <jglisse@redhat.com> wrote:
>
> On Wed, Mar 06, 2019 at 07:57:30AM -0800, Dan Williams wrote:
> > On Wed, Mar 6, 2019 at 7:51 AM Jerome Glisse <jglisse@redhat.com> wrote:
> > >
> > > On Tue, Mar 05, 2019 at 08:20:10PM -0800, Dan Williams wrote:
> > > > On Tue, Mar 5, 2019 at 2:16 PM Andrew Morton <akpm@linux-foundation.org> wrote:
> > > > >
> > > > > On Wed, 30 Jan 2019 21:44:46 -0800 Dan Williams <dan.j.williams@intel.com> wrote:
> > > > >
> > > > > > >
> > > > > > > > Another way to help allay these worries is commit to no new exports
> > > > > > > > without in-tree users. In general, that should go without saying for
> > > > > > > > any core changes for new or future hardware.
> > > > > > >
> > > > > > > I always intend to have an upstream user the issue is that the device
> > > > > > > driver tree and the mm tree move a different pace and there is always
> > > > > > > a chicken and egg problem. I do not think Andrew wants to have to
> > > > > > > merge driver patches through its tree, nor Linus want to have to merge
> > > > > > > drivers and mm trees in specific order. So it is easier to introduce
> > > > > > > mm change in one release and driver change in the next. This is what
> > > > > > > i am doing with ODP. Adding things necessary in 5.1 and working with
> > > > > > > Mellanox to have the ODP HMM patch fully tested and ready to go in
> > > > > > > 5.2 (the patch is available today and Mellanox have begin testing it
> > > > > > > AFAIK). So this is the guideline i will be following. Post mm bits
> > > > > > > with driver patches, push to merge mm bits one release and have the
> > > > > > > driver bits in the next. I do hope this sound fine to everyone.
> > > > > >
> > > > > > The track record to date has not been "merge HMM patch in one release
> > > > > > and merge the driver updates the next". If that is the plan going
> > > > > > forward that's great, and I do appreciate that this set came with
> > > > > > driver changes, and maintain hope the existing exports don't go
> > > > > > user-less for too much longer.
> > > > >
> > > > > Decision time.  Jerome, how are things looking for getting these driver
> > > > > changes merged in the next cycle?
> > > > >
> > > > > Dan, what's your overall take on this series for a 5.1-rc1 merge?
> > > >
> > > > My hesitation would be drastically reduced if there was a plan to
> > > > avoid dangling unconsumed symbols and functionality. Specifically one
> > > > or more of the following suggestions:
> > > >
> > > > * EXPORT_SYMBOL_GPL on all exports to avoid a growing liability
> > > > surface for out-of-tree consumers to come grumble at us when we
> > > > continue to refactor the kernel as we are wont to do.
> > > >
> > > > * A commitment to consume newly exported symbols in the same merge
> > > > window, or the following merge window. When that goal is missed revert
> > > > the functionality until such time that it can be consumed, or
> > > > otherwise abandoned.
> > > >
> > > > * No new symbol exports and functionality while existing symbols go unconsumed.
> > > >
> > > > These are the minimum requirements I would expect my work, or any
> > > > core-mm work for that matter, to be held to, I see no reason why HMM
> > > > could not meet the same.
> > >
> > > nouveau use all of this and other driver patchset have been posted to
> > > also use this API.
> > >
> > > > On this specific patch I would ask that the changelog incorporate the
> > > > motivation that was teased out of our follow-on discussion, not "There
> > > > is no reason not to support that case." which isn't a justification.
> > >
> > > mlx5 wants to use HMM without DAX support it would regress mlx5. Other
> > > driver like nouveau also want to access DAX filesystem. So yes there is
> > > no reason not to support DAX filesystem. Why do you not want DAX with
> > > mirroring ? You want to cripple HMM ? Why ?
> >
> > There is a misunderstanding... my request for this patch was to update
> > the changelog to describe the merits of DAX mirroring to replace the
> > "There is no reason not to support that case." Otherwise someone
> > reading this changelog in a year will wonder what the motivation was.
>
> So what about:
>
> HMM mirroring allow device to mirror process address onto device
> there is no reason for that mirroring to not work if the virtual
> address are the result of an mmap of a file on DAX enabled file-
> system.

Looks like an improvement to me.

