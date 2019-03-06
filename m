Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 32E81C43381
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 04:20:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A385920675
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 04:20:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="FVhuva3L"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A385920675
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0D6EF8E0003; Tue,  5 Mar 2019 23:20:24 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 087088E0001; Tue,  5 Mar 2019 23:20:24 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EDF518E0003; Tue,  5 Mar 2019 23:20:23 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id C666F8E0001
	for <linux-mm@kvack.org>; Tue,  5 Mar 2019 23:20:23 -0500 (EST)
Received: by mail-io1-f71.google.com with SMTP id m15so8606731ioc.16
        for <linux-mm@kvack.org>; Tue, 05 Mar 2019 20:20:23 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=2qnMFe0wuLDgOjKuovV5S00fz/lOz7tP0yCLPiPSWvw=;
        b=TxNP8jmysDF8yL9RKKe1Jau5GueUXQ9WgdKWoSR3Ekqw2oH+NBqrwOKuuzYGGPgLQe
         Bgr2PoKPETSeIVc9AM1Gw7fyhsbpg+MqGYHAvHtQ0smfkuB9L953HGLDa0JQVFJNV4fZ
         q80NNsoldh72169qyQIViggHmcFAO2SkWLvapDqTL3MwGF982siJMvFPFNOSRArb/5Tg
         ot5X+Gaih/ukv3F9Ewo5nkEgoo/gWCL0H5nnGFwPfw3GYbt8PdhDkTI3dTUvmnWYife8
         i1uuOl4+7GqQiBFan7AUmMhMwvpouuowp8pwclCsOfEDQEar+NnbdN242gK3QgHIK1Ag
         54wg==
X-Gm-Message-State: APjAAAVC6+yVs+zKr5+wAN6JIpwCWG2NwXbbzLndhLlOBeqQR5pW94BJ
	LfFP2Z50fz6keB5VzeclNj57yhOptzkWeaM8OhDtvZFcF5ZpF12GKuhSvX95TmXETOmyhUE28bl
	LSxs/SXEdqcOxwmijQBuequqmpzXFQ57v+Lf+Vw4dVflN3Iketd4YMga96/tz5trgsfqtakgFZD
	Ww9TaZChQKsLkxos2S7mXtm3BCthEuswjJDDcmm0JKH43Oo7DOt0KfOKHRIf6/LCd2dHfEH397z
	AFL1C/MN33dJm6LO9JFD+KMC2b+KVlR7fNrfkntRkYBS8dGZbZ3UnjU8wV1UiYPSpMPzei4i/qu
	zyk6mKyKukZQOIVbzFiGOb29GwOds6MPub2wHpKLb7i6IuPRzZumw1d1SId8ZgB9ldpQMCo6uw=
	=
X-Received: by 2002:a24:3554:: with SMTP id k81mr840522ita.41.1551846023410;
        Tue, 05 Mar 2019 20:20:23 -0800 (PST)
X-Received: by 2002:a24:3554:: with SMTP id k81mr840503ita.41.1551846022440;
        Tue, 05 Mar 2019 20:20:22 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551846022; cv=none;
        d=google.com; s=arc-20160816;
        b=hk/cXvMWWj9JT0gTYnXQw6PUrwn74U8YQpxvgSuSlZ3fM9qqwLHDxwGf4j8L+nB+fw
         99bptClohkLTWWKAfBg8LEBfsN5oyUYaK2CfGbflFgCCD8y3usRU3hxc1MkQZHb3MJn2
         hDLGBBmDgkRex8qopdAPJAHVLkqPxdjtyJM/+s6aFIwtDTU0/jonOgYMdVVhqnaEabm5
         ZjcPVEqpK1OtI34pdx7Rv36wgMz+ra32XXhmeVY/EO/H3kGDwVcVX9TS9tZENYl5oRdr
         73LrV1LUfh48TA5o2WC4xlPdUo5rKPfghk8Vwl3y2T451BXVrLl5FCzdCKmcLbHd4VkL
         rKDQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=2qnMFe0wuLDgOjKuovV5S00fz/lOz7tP0yCLPiPSWvw=;
        b=rjzjEiniVVwkFqEhs6Vw66uSIOr24nyyVCVjuYX70fv8TQIXK05WK5PlxMFx9ETUDT
         I3qDZtktPFqdjOY+agz5UG9U53iljGKQfO/NNE388yntRZYiygeIMbgY1FUdfOSimV0o
         WNphs7I31JTFP3iLaKv1jaJPHXYsbtrz7vZKm3yAtDf6KHhdjRb6nR7e34goUjNKRN2P
         uC8aNvlrKl5V9HODBBFnO9cXB0YFwlkMvodAjZAQrOQJLzKt/bGIJqMmzb9CmLAELyGE
         Gb5BnDtqAao0YOSIoP2/6g+RJ66edM9gZfl3FdssgfvJYKaW+2YHqerlwkxVUPVsKzoO
         aKrA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=FVhuva3L;
       spf=pass (google.com: domain of dan.j.williams@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u24sor153900ior.35.2019.03.05.20.20.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 05 Mar 2019 20:20:22 -0800 (PST)
Received-SPF: pass (google.com: domain of dan.j.williams@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=FVhuva3L;
       spf=pass (google.com: domain of dan.j.williams@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=2qnMFe0wuLDgOjKuovV5S00fz/lOz7tP0yCLPiPSWvw=;
        b=FVhuva3LR+eI5EQoGp/b1J0Y/1VduXhXMmLkQWmgBRGb3wzb/nznQsH5QDaYwrFNqU
         XpALPw3aoz8G7E/++gAa8RwgQWWfSIKFkwygEpv2VYwy4AIJbTX8XqzU4+9kBAdQMihO
         FmcymTtsWkD6lPfXvGsCAkogeRb2Ezrtrhf6VaT6CTXwcsKJVrFRbzte/HSiR1VTdE0k
         y2/KO67jB3zH6CkWLkESr3+SeEMdK4MKsM8VFCGYigyKo3/lyhNDHGp43ZR99+F4yuU/
         PIb/gjDSn9f954HmoXUAPXtvY5C05HwrXVyylVd5+UHAxU5zIJ3pmdIxPmtCgLOKcF2j
         seKg==
X-Google-Smtp-Source: APXvYqy9WV0LVfT30OKYZl0pK/MHwl75fdnv+KrH09p6raUNnxK4enro2DZo7xURTs9/VKXES2hWUk+EaCNh151GppU=
X-Received: by 2002:a5e:8347:: with SMTP id y7mr1970069iom.136.1551846021790;
 Tue, 05 Mar 2019 20:20:21 -0800 (PST)
MIME-Version: 1.0
References: <20190129165428.3931-10-jglisse@redhat.com> <CAPcyv4gNtDQf0mHwhZ8g3nX6ShsjA1tx2KLU_ZzTH1Z1AeA_CA@mail.gmail.com>
 <20190129193123.GF3176@redhat.com> <CAPcyv4gkYTZ-_Et1ZriAcoHwhtPEftOt2LnR_kW+hQM5-0G4HA@mail.gmail.com>
 <20190129212150.GP3176@redhat.com> <CAPcyv4hZMcJ6r0Pw5aJsx37+YKx4qAY0rV4Ascc9LX6eFY8GJg@mail.gmail.com>
 <20190130030317.GC10462@redhat.com> <CAPcyv4jS7Y=DLOjRHbdRfwBEpxe_r7wpv0ixTGmL7kL_ThaQFA@mail.gmail.com>
 <20190130183616.GB5061@redhat.com> <CAPcyv4hB4p6po1+-hJ4Podxoan35w+T6uZJzqbw=zvj5XdeNVQ@mail.gmail.com>
 <20190131041641.GK5061@redhat.com> <CAPcyv4gb+r==riKFXkVZ7gGdnKe62yBmZ7xOa4uBBByhnK9Tzg@mail.gmail.com>
 <20190305141635.8134e310ba7187bc39532cd3@linux-foundation.org>
In-Reply-To: <20190305141635.8134e310ba7187bc39532cd3@linux-foundation.org>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 5 Mar 2019 20:20:10 -0800
Message-ID: <CAA9_cmd2Z62Z5CSXvne4rj3aPSpNhS0Gxt+kZytz0bVEuzvc=A@mail.gmail.com>
Subject: Re: [PATCH 09/10] mm/hmm: allow to mirror vma of a file on a DAX
 backed filesystem
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jerome Glisse <jglisse@redhat.com>, Linux MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Ralph Campbell <rcampbell@nvidia.com>, 
	John Hubbard <jhubbard@nvidia.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 5, 2019 at 2:16 PM Andrew Morton <akpm@linux-foundation.org> wrote:
>
> On Wed, 30 Jan 2019 21:44:46 -0800 Dan Williams <dan.j.williams@intel.com> wrote:
>
> > >
> > > > Another way to help allay these worries is commit to no new exports
> > > > without in-tree users. In general, that should go without saying for
> > > > any core changes for new or future hardware.
> > >
> > > I always intend to have an upstream user the issue is that the device
> > > driver tree and the mm tree move a different pace and there is always
> > > a chicken and egg problem. I do not think Andrew wants to have to
> > > merge driver patches through its tree, nor Linus want to have to merge
> > > drivers and mm trees in specific order. So it is easier to introduce
> > > mm change in one release and driver change in the next. This is what
> > > i am doing with ODP. Adding things necessary in 5.1 and working with
> > > Mellanox to have the ODP HMM patch fully tested and ready to go in
> > > 5.2 (the patch is available today and Mellanox have begin testing it
> > > AFAIK). So this is the guideline i will be following. Post mm bits
> > > with driver patches, push to merge mm bits one release and have the
> > > driver bits in the next. I do hope this sound fine to everyone.
> >
> > The track record to date has not been "merge HMM patch in one release
> > and merge the driver updates the next". If that is the plan going
> > forward that's great, and I do appreciate that this set came with
> > driver changes, and maintain hope the existing exports don't go
> > user-less for too much longer.
>
> Decision time.  Jerome, how are things looking for getting these driver
> changes merged in the next cycle?
>
> Dan, what's your overall take on this series for a 5.1-rc1 merge?

My hesitation would be drastically reduced if there was a plan to
avoid dangling unconsumed symbols and functionality. Specifically one
or more of the following suggestions:

* EXPORT_SYMBOL_GPL on all exports to avoid a growing liability
surface for out-of-tree consumers to come grumble at us when we
continue to refactor the kernel as we are wont to do.

* A commitment to consume newly exported symbols in the same merge
window, or the following merge window. When that goal is missed revert
the functionality until such time that it can be consumed, or
otherwise abandoned.

* No new symbol exports and functionality while existing symbols go unconsumed.

These are the minimum requirements I would expect my work, or any
core-mm work for that matter, to be held to, I see no reason why HMM
could not meet the same.

On this specific patch I would ask that the changelog incorporate the
motivation that was teased out of our follow-on discussion, not "There
is no reason not to support that case." which isn't a justification.

