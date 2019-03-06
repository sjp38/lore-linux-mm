Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F04A2C43381
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 15:51:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AADFC20663
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 15:51:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AADFC20663
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 38AE78E0014; Wed,  6 Mar 2019 10:51:32 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 311938E0002; Wed,  6 Mar 2019 10:51:32 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 18A698E0014; Wed,  6 Mar 2019 10:51:32 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id DFDAC8E0002
	for <linux-mm@kvack.org>; Wed,  6 Mar 2019 10:51:31 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id j1so10118446qkl.23
        for <linux-mm@kvack.org>; Wed, 06 Mar 2019 07:51:31 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=/oP1BbNtOmu2KGv0IayPNxOTHlp+ekLa7VROEmsXBio=;
        b=t1FwpXUKk3yWWMvgEy5EWwjSG3VrcB7PhE/52tQ6wLVbtb/vLPWtjwPdZl0xnkotSc
         mwopIy/Z3YXGLOalZawhWQ8mVZY6zpIcgL2u66lAd31MWSkedXXYYr8hPteiyU6X1kfD
         5CNr854Z9O+ZP1UVmzA0/us/jx39kgmflyBxabCY6Zc8tYTzv/6tgo+jDpYs8AZMEUK2
         a46nsn/w+IlDN9TuvjNC7F1y58udzx6WeQyT/mLYBuw8Sc6TITbTaMu/dcDEaMo2gwNE
         ESdQ4eePtJqJmFTxbMZWXmxheSikD9s5Uct/DTA8vSlfw0yj7yBZnJ8AOzDMhbsR9OQ9
         iMuw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVuVkEw6SqOVOFYvy8gg+cFMLmnCueCkHJXP+xQcluuMh7L0BVw
	poFp28yGXXvFP21sSwyKQNMaOAvSzBvhB7zunU8G4+J8hov5Q87zviO/x/IlT3TbvTAkjxyKYqE
	piUTDGnibznUFgQyfNAvsVmKs/5+q6pCq1O0DEKX23GjYYWtpwBYw/UUJyYD84lY7TA==
X-Received: by 2002:a37:9cd1:: with SMTP id f200mr6111786qke.176.1551887491631;
        Wed, 06 Mar 2019 07:51:31 -0800 (PST)
X-Google-Smtp-Source: APXvYqwWYvUfAUDkAU2ckiS5S1w1Si59u13eyYm7poZjBoA0JMBwKpGE0TcDtXbXKVahsD7bRLQ6
X-Received: by 2002:a37:9cd1:: with SMTP id f200mr6111744qke.176.1551887490914;
        Wed, 06 Mar 2019 07:51:30 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551887490; cv=none;
        d=google.com; s=arc-20160816;
        b=vdNxmXqHl92IJ3Z2NPpg1czz5jq/NcDxoaP4zqEW8NfjhLIZRCb7IDxILzqF6b4vRR
         SR134FQ5/uZxGafnZXKl1MsniF1w8G8An59G8HTgqKNvexhukS+Mqk+vOMKokzxI+Jg/
         pFXP79FbSVi0n6pe0oqMAgP0h688OecqKnCj1b9/b6Dh8L2H7pqvzvt4GwYuKcb2sKU/
         LKxySifTsHESUs3JnMbyJxNChd5QBGPr7+tAhnmGMTkHM/asLygf2K0jhR9LoGpBFTja
         xys71kFUHFYOLPnkKsXZv5VioLofbI82S9G6mzrladf1t+ZbMFVD9Rqsg1UM2KmHa6uh
         uN7w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=/oP1BbNtOmu2KGv0IayPNxOTHlp+ekLa7VROEmsXBio=;
        b=dGY78cb9l3Clu5YiXNVxPoU/AfDU81BwaHNj4MPo2hMZaS4V7z1+PxgxnhbMBKNItH
         NtgZCY2Z6fBs0GfVELcSr7/ZV1gwvoSfH8ZTupRDIdGn87S5Q20KaUsIWw/HnXUvc+OB
         hWtQIR+KoX6jpgqkJNhGXmdYAsnHtLTGSwh9m2aRW0UuBRNREpP9Yl0Ru6160KO7AfSz
         bjSotKazNUNuoCfSvih1gVsp1yQHY5Kw1OGlGnEhANEBjSFzPNcwG06lHeugXfNKqDES
         OjoWiryyIroFDfmC567cSqrqdbzHA7+3s8lqiSxwVl3c9Wsmao3QWg1hEcD5wbNbZgdB
         u2mw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q58si763470qtb.228.2019.03.06.07.51.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Mar 2019 07:51:30 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 16FC2307E042;
	Wed,  6 Mar 2019 15:51:30 +0000 (UTC)
Received: from redhat.com (ovpn-125-142.rdu2.redhat.com [10.10.125.142])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 170B1600D7;
	Wed,  6 Mar 2019 15:51:28 +0000 (UTC)
Date: Wed, 6 Mar 2019 10:51:27 -0500
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
Message-ID: <20190306155126.GB3230@redhat.com>
References: <20190129212150.GP3176@redhat.com>
 <CAPcyv4hZMcJ6r0Pw5aJsx37+YKx4qAY0rV4Ascc9LX6eFY8GJg@mail.gmail.com>
 <20190130030317.GC10462@redhat.com>
 <CAPcyv4jS7Y=DLOjRHbdRfwBEpxe_r7wpv0ixTGmL7kL_ThaQFA@mail.gmail.com>
 <20190130183616.GB5061@redhat.com>
 <CAPcyv4hB4p6po1+-hJ4Podxoan35w+T6uZJzqbw=zvj5XdeNVQ@mail.gmail.com>
 <20190131041641.GK5061@redhat.com>
 <CAPcyv4gb+r==riKFXkVZ7gGdnKe62yBmZ7xOa4uBBByhnK9Tzg@mail.gmail.com>
 <20190305141635.8134e310ba7187bc39532cd3@linux-foundation.org>
 <CAA9_cmd2Z62Z5CSXvne4rj3aPSpNhS0Gxt+kZytz0bVEuzvc=A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAA9_cmd2Z62Z5CSXvne4rj3aPSpNhS0Gxt+kZytz0bVEuzvc=A@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.42]); Wed, 06 Mar 2019 15:51:30 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 05, 2019 at 08:20:10PM -0800, Dan Williams wrote:
> On Tue, Mar 5, 2019 at 2:16 PM Andrew Morton <akpm@linux-foundation.org> wrote:
> >
> > On Wed, 30 Jan 2019 21:44:46 -0800 Dan Williams <dan.j.williams@intel.com> wrote:
> >
> > > >
> > > > > Another way to help allay these worries is commit to no new exports
> > > > > without in-tree users. In general, that should go without saying for
> > > > > any core changes for new or future hardware.
> > > >
> > > > I always intend to have an upstream user the issue is that the device
> > > > driver tree and the mm tree move a different pace and there is always
> > > > a chicken and egg problem. I do not think Andrew wants to have to
> > > > merge driver patches through its tree, nor Linus want to have to merge
> > > > drivers and mm trees in specific order. So it is easier to introduce
> > > > mm change in one release and driver change in the next. This is what
> > > > i am doing with ODP. Adding things necessary in 5.1 and working with
> > > > Mellanox to have the ODP HMM patch fully tested and ready to go in
> > > > 5.2 (the patch is available today and Mellanox have begin testing it
> > > > AFAIK). So this is the guideline i will be following. Post mm bits
> > > > with driver patches, push to merge mm bits one release and have the
> > > > driver bits in the next. I do hope this sound fine to everyone.
> > >
> > > The track record to date has not been "merge HMM patch in one release
> > > and merge the driver updates the next". If that is the plan going
> > > forward that's great, and I do appreciate that this set came with
> > > driver changes, and maintain hope the existing exports don't go
> > > user-less for too much longer.
> >
> > Decision time.  Jerome, how are things looking for getting these driver
> > changes merged in the next cycle?
> >
> > Dan, what's your overall take on this series for a 5.1-rc1 merge?
> 
> My hesitation would be drastically reduced if there was a plan to
> avoid dangling unconsumed symbols and functionality. Specifically one
> or more of the following suggestions:
> 
> * EXPORT_SYMBOL_GPL on all exports to avoid a growing liability
> surface for out-of-tree consumers to come grumble at us when we
> continue to refactor the kernel as we are wont to do.
> 
> * A commitment to consume newly exported symbols in the same merge
> window, or the following merge window. When that goal is missed revert
> the functionality until such time that it can be consumed, or
> otherwise abandoned.
> 
> * No new symbol exports and functionality while existing symbols go unconsumed.
> 
> These are the minimum requirements I would expect my work, or any
> core-mm work for that matter, to be held to, I see no reason why HMM
> could not meet the same.

nouveau use all of this and other driver patchset have been posted to
also use this API.

> On this specific patch I would ask that the changelog incorporate the
> motivation that was teased out of our follow-on discussion, not "There
> is no reason not to support that case." which isn't a justification.

mlx5 wants to use HMM without DAX support it would regress mlx5. Other
driver like nouveau also want to access DAX filesystem. So yes there is
no reason not to support DAX filesystem. Why do you not want DAX with
mirroring ? You want to cripple HMM ? Why ?

Cheers,
Jérôme

