Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DD5D2C43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 00:30:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7E3F12087F
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 00:30:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="tjGdxu/b"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7E3F12087F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 159D58E0003; Mon, 11 Mar 2019 20:30:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 10B5C8E0002; Mon, 11 Mar 2019 20:30:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F3BF48E0003; Mon, 11 Mar 2019 20:30:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id C13FA8E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 20:30:14 -0400 (EDT)
Received: by mail-oi1-f200.google.com with SMTP id u132so301423oif.6
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 17:30:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=96Eychx0pVXg5tC/lmw3nK92/kMpZpAcq39GwifwZoI=;
        b=sLXU8o3L1YCICbPK1jfiRF+F/Hr3aljEOXnFuIJswTrptSZXrJvmxUzyWcvgCZfxPh
         EJoeCEP26uyJmd35SAg5gpNFesBft1rDB+uuKA4qyBcGLiba0wLCagBWmpOkneA9yelt
         a5ZAQH3MYWq8WxE6gnpxUx9eOJRZyaGSUA2SlSTKAp0nVNhZM2dR8j9ICXcYvcsS8iap
         rSJimtTGbPSnwaMzv8BFUq6pZf6LOV12c5hUlynjgmaoaJ0mPaQ5xzFZxZBEHvE2zV7B
         Fl0EtzHIUjUlNgqoSXJOBQptxCd5zF96AxuiduKBagMW62YDdOEZ+0p3ULVg3ijfsgbC
         S9tA==
X-Gm-Message-State: APjAAAXdd6hNCMF9bKjmkYjODIpG1NtVxo5VFiSpFktmLj26mqHD9l0C
	gYDwyDtrSH8B0vVTmQieURtvL6IUdKYq6qAcwHMEhTrXxWfkwW8lq3sT9Qd44GYxQB7wLCGrIw4
	8I8lJiUyxYQZogF2knrfx7+koMS41AHGw5Uesc8PFTgD79tFRTmp/H0rg2O9C88f0AjOXIRSusz
	Qx8STEzSMz0mgaP9b256qn6eAxX2xpIVc7nzY2q66Crrc5maqxd+44o3VybO3R/WaXZrh21dGde
	mCzb66L1hG6SC9oFLoNi7l0kzETBIBrMofWRpXdETbCwQKFgzArrhSocTomZ8H9BHEZ49a5eAqf
	PQVao4VAs6jxcCaeXqnDDJv3ulDPLVPHCAahsXo2vXdsbp6I04KBoP42S1PWS8uaavWh/rws3Tn
	J
X-Received: by 2002:a05:6830:1317:: with SMTP id p23mr23085278otq.55.1552350614348;
        Mon, 11 Mar 2019 17:30:14 -0700 (PDT)
X-Received: by 2002:a05:6830:1317:: with SMTP id p23mr23085244otq.55.1552350613536;
        Mon, 11 Mar 2019 17:30:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552350613; cv=none;
        d=google.com; s=arc-20160816;
        b=v9nM1W0IJBSJscehpj1z25u7UybLL2iDEAXmd5zvS7GvOcwDctC0zfGDM7Ht2/tjHI
         Cgikd5K/71AMzFwk1l1LQFkfxr+KVhmJS95EVI4XtoENmIF7+cxpf03nuwNgzPqVvbNZ
         wkpVZRUu6zXHynsh3eXKoVQ6jj7Oc2QIdFhuG/XSzSzM1+2SJg1Lx2LiwULegUymV6Pr
         /PzKupFte4wxKz30LmSXwS2SqOmlrH0TM2X3TlxfIgyGTyXa+oM2wnkuJKr1IHQOIm3r
         qDYjHnOu3ptF3Yv+YllKZIVJJXmypM/2gNZU3aeAn0B4jUnNyDiteqhSxZ5To+5vvbO1
         ICMw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=96Eychx0pVXg5tC/lmw3nK92/kMpZpAcq39GwifwZoI=;
        b=QIwl7Hly+dNUnPGV88kpASSnPXAhPwFokAkhcyFy1EHDwA9QIxvbgBzr3feCSRg7in
         10fKA7McbwJ9q+fpuYOaFgSJmpzaKzBHCdweOllmH/KqYFKlPpBxC4XaRnnuIvmDX/Ux
         Hr77gmaLIQoWJwJq2lcngtpBrxtdV70sgjoWitnclw9DSxheqQvKojJmr2jicCSTXVd0
         GQf5K8jPEed596RcidbOAzKnKmzupJj2mzZFtj2cR3RfwjbbjRpHyI7e8JkRjrJnNGju
         iLWemzksuL1vrTU9eHYkPxY1fAs09nwF5fMm7l5zDtHAcUN9WPLRVgYHFoh6mHO9PUqh
         fxfA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b="tjGdxu/b";
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o6sor3703620oig.18.2019.03.11.17.30.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Mar 2019 17:30:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b="tjGdxu/b";
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=96Eychx0pVXg5tC/lmw3nK92/kMpZpAcq39GwifwZoI=;
        b=tjGdxu/bVPVh9Ua5UQ8YtA22eqApz6aIzFPfYx/7CDlBMSMlZHU0eHNZdkYmi1qjsS
         OmHTQI2f2eb5YiKYmgKeN4CALQM8TaBXKfhHPZtA8LlA+Wl4IaWsIyyoHe4RKeXN7JyK
         2oqiCUcYuzjD19Oz1vcxDOEwP0keO3Js0AntCZkGr7o3wJubBd7j754AQ+BahUJ7weyW
         VnQqxBLf8Pc9NU6+/3PfC/AMuqlQ4wQ3rdM2pF8OGCN3nhQ1++j3cDp98NsucCoxQeyc
         omm/sgZP15MkyeSNXf1CWIYFvXT//dFW7uamAA9EMQFBEQuF8Kiv3pSRBCXxmG/SLHfO
         FDOg==
X-Google-Smtp-Source: APXvYqwlMK4Ji22rFS+MBGh9COVQcs3fw5qaMUPzkLdofXvv/AYErEbzrXXcIHwPq5L/VyLOpy4O8NJyIgC70phvAJ0=
X-Received: by 2002:aca:3906:: with SMTP id g6mr10168oia.149.1552350611637;
 Mon, 11 Mar 2019 17:30:11 -0700 (PDT)
MIME-Version: 1.0
References: <CAPcyv4he0q_FdqqiXarp0bXjcggs8QZX8Od560E2iFxzCU3Qag@mail.gmail.com>
 <CAHk-=wjvmwD_0=CRQtNs5RBh8oJwrriXDn+XNWOU=wk8OyQ5ew@mail.gmail.com>
 <CAPcyv4hafLUr2rKdLG+3SHXyWaa0d_2g8AKKZRf2mKPW+3DUSA@mail.gmail.com>
 <CAHk-=wiTM93XKaFqUOR7q7133wvzNS8Kj777EZ9E8S99NbZhAA@mail.gmail.com>
 <CAPcyv4hMZMuSEtUkKqL067f4cWPGivzn9mCtv3gZsJG2qUOYvg@mail.gmail.com> <CAHk-=wgnJd_qY1wGc0KcoGrNz3Mp9-8mQFMDLoTXvEMVtAxyZQ@mail.gmail.com>
In-Reply-To: <CAHk-=wgnJd_qY1wGc0KcoGrNz3Mp9-8mQFMDLoTXvEMVtAxyZQ@mail.gmail.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 11 Mar 2019 17:30:00 -0700
Message-ID: <CAPcyv4hjfOjLU8x366eDy57FV-=6Xb5sdCr7u-+r8OZe2RwMHA@mail.gmail.com>
Subject: Re: [GIT PULL] device-dax for 5.1: PMEM as RAM
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-nvdimm <linux-nvdimm@lists.01.org>, 
	Linux MM <linux-mm@kvack.org>, Dave Hansen <dave.hansen@intel.com>, 
	"Luck, Tony" <tony.luck@intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 11, 2019 at 5:08 PM Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> On Mon, Mar 11, 2019 at 8:37 AM Dan Williams <dan.j.williams@intel.com> wrote:
> >
> > Another feature the userspace tooling can support for the PMEM as RAM
> > case is the ability to complete an Address Range Scrub of the range
> > before it is added to the core-mm. I.e at least ensure that previously
> > encountered poison is eliminated.
>
> Ok, so this at least makes sense as an argument to me.
>
> In the "PMEM as filesystem" part, the errors have long-term history,
> while in "PMEM as RAM" the memory may be physically the same thing,
> but it doesn't have the history and as such may not be prone to
> long-term errors the same way.
>
> So that validly argues that yes, when used as RAM, the likelihood for
> errors is much lower because they don't accumulate the same way.
>
> > The driver can also publish an
> > attribute to indicate when rep; mov is recoverable, and gate the
> > hotplug policy on the result. In my opinion a positive indicator of
> > the cpu's ability to recover rep; mov exceptions is a gap that needs
> > addressing.
>
> Is there some way to say "don't raise MC for this region"? Or at least
> limit it to a nonfatal one?

I wish, but no. The poison consumption always raises the MC then it's
whether MCI_STATUS_PCC (processor context corrupt) is set as to
whether the cpu indicates it is safe to proceed. There's no way to
indicate, "never set MCI_STATUS_PCC", or silence the exception.

