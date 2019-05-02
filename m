Return-Path: <SRS0=Mdb/=TC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E1923C43219
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 23:21:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A26DF2064A
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 23:21:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="sWawHLNM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A26DF2064A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2CF936B0005; Thu,  2 May 2019 19:21:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 280996B0007; Thu,  2 May 2019 19:21:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1480C6B0008; Thu,  2 May 2019 19:21:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id E0D0A6B0005
	for <linux-mm@kvack.org>; Thu,  2 May 2019 19:21:17 -0400 (EDT)
Received: by mail-oi1-f197.google.com with SMTP id e5so1918269oih.23
        for <linux-mm@kvack.org>; Thu, 02 May 2019 16:21:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=0i5+J/OZLL+JOOwALn6I5uwFawiDlG+N57qbnmaBmtk=;
        b=ohUSlR1DmbikchtijwDwnNPhfCrhUqVxKEcPAvTqQCs+xh/Q2TW9CEQMYe9MaTmpfV
         5fwkMNBZsrViTJED/VpUOZlW7mHhaSMZDNgkG1zxhWIYLK6f9ETCs5GcFuv/MKwkslHs
         L2uFWGfEPSYEG3VXv4CbogKUa0G5+qs2iGtqh7CrzBCcJVwAXRkD2M5FEqtemIdV9eVx
         hfn+hekwEyUhtpz79eJuCizk+T8fyAcPIEO2I3i5Pd7a6/4YECEOPrb/9D12k4Ik5aKs
         4iBTEtRqbnFfXgYLMLl4n7xZiPH146bTgSCT0+U9Z3tSBK4juOMU4ZHOGcUORd8Cl9xz
         4PGw==
X-Gm-Message-State: APjAAAXgKveTdtm3JpLiPulWO7kRuWAY0YEIfkFdIBEHC4H3uFjY2wOL
	NvKrv+unVHFZB+tn/4wKj2keV22A2UfLQsADBRy2HiquPkDw0s4wm8Xt0IxMPMHwFsBkpA/nbyf
	1xvyCZ5jOxfq0DgTFV5lcPKta5XgVpW3eChBrFnU77mZNRrDRFFTNqp22ILtyaZxJgw==
X-Received: by 2002:aca:d557:: with SMTP id m84mr3949302oig.50.1556839277334;
        Thu, 02 May 2019 16:21:17 -0700 (PDT)
X-Received: by 2002:aca:d557:: with SMTP id m84mr3949280oig.50.1556839276772;
        Thu, 02 May 2019 16:21:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556839276; cv=none;
        d=google.com; s=arc-20160816;
        b=WzIe+JGkrn4jFoN/G9HZqWU88EccxcGekvY4DYniiIHnmZq67588NW0bm/7kOsGxbE
         HPS3hFEIzn4opbq8iWdxpdLCAHZmcjV0/dMqm/S+nspvi2WSnSgfc2k8HA+s22d4LAqt
         kO/vOzeCs1/1C5AFrPUY9lLT4K2JQVCKJaIz3UtUtHww0Q2eg8S23OPDqJ4tvGNvEk5B
         FdeCEpaD+gmv+XrEKObiqNuX1DHQSReWz2JsXnkhjKEHAA+r+BUOwwEVHbX7pPqEE74B
         iYLGBVz02Mkip7wDHJc1Uxa4i0B6n8VGNytjzFymob6u1ZZ72bU1EekIouu1ODGgzffx
         aODA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=0i5+J/OZLL+JOOwALn6I5uwFawiDlG+N57qbnmaBmtk=;
        b=BbZdp7bLe7q+WcMsKJof+dRjeXVBvAtG8lraCoN0zyqOLANj78r3fRhhYceTyFSWqh
         c5VaEgO+Hj02GzdSXiOinJz3TBzCLOHavjRV7vdAMC0jV+/kaATwJpQ5lLqcz9nq70i0
         I5e2Nv315fe7VkzSbhfBoonYTmN0IwQJjPEWABFXWrnFVwQoSo2FXvtWqgwrcJW8px+y
         NsGjddryURirFMcpAdMN3PjhHCLLIVreABBDNRf9Q5wuhrGTnZg8qDxbEbaxNoYd8w2s
         sIgATIOPVO6DciPoz1R71BkZg8/mCHK3YFH2IvUh8plxparSYlhKkRXGDfBzHVhHpPU1
         T+Kw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=sWawHLNM;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n39sor252208ota.137.2019.05.02.16.21.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 02 May 2019 16:21:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=sWawHLNM;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=0i5+J/OZLL+JOOwALn6I5uwFawiDlG+N57qbnmaBmtk=;
        b=sWawHLNMKR0Z8Wcp0xOaPFpIrQ6QpmbbM6zigcIzNj1WJvbeh+Sjw9n6tIJoHgDaA6
         GgHltRLQSt1agn1TOVUOGI46HUvE24ww/7wBYRHYRdNKiWzKHHbf5etMXZ20pnRvnGIT
         QxTurydSSdEyMyi2Qabh03VR59K4+NgTK148H0EFCAUUYSf8o8pEDxzDGjdTWBY4TUca
         UWHAuYyxKgs+/C5mYh4EOm/HxHdIMEG82VoybqBmlv5jAXSswdNp6xkxYFfh4c5dXIip
         rrOFS4TWce+QrFAoelxpv3OXDps3RdQeyQdRCaSHgv7pxXJ8hfmeq4/ufkrHiwBWMeqm
         VKjw==
X-Google-Smtp-Source: APXvYqw0TgWpuTZRL+SCcmgsjTeKduMjL6fHbHh+v1JzAjaquiFt8e1uuHJEKU0m3H+lLNeHniLWZoNoGl8pEH0sriQ=
X-Received: by 2002:a9d:222c:: with SMTP id o41mr4495514ota.353.1556839275827;
 Thu, 02 May 2019 16:21:15 -0700 (PDT)
MIME-Version: 1.0
References: <155552633539.2015392.2477781120122237934.stgit@dwillia2-desk3.amr.corp.intel.com>
 <CA+CK2bBT=goxf5KWLhca7uQutUj9670aL9r02_+BsJ+bLkjj=g@mail.gmail.com> <CAPcyv4gWZxSepaACiyR43qytA1jR8fVaeLy1rv7dFJW-ZE63EA@mail.gmail.com>
In-Reply-To: <CAPcyv4gWZxSepaACiyR43qytA1jR8fVaeLy1rv7dFJW-ZE63EA@mail.gmail.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 2 May 2019 16:21:05 -0700
Message-ID: <CAPcyv4j1221GA6xQww741v-RdZame5D0q60qcxO5u=tv9MDoRw@mail.gmail.com>
Subject: Re: [PATCH v6 00/12] mm: Sub-section memory hotplug support
To: Pavel Tatashin <pasha.tatashin@soleen.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Hildenbrand <david@redhat.com>, 
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	Logan Gunthorpe <logang@deltatee.com>, Toshi Kani <toshi.kani@hpe.com>, Jeff Moyer <jmoyer@redhat.com>, 
	Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, stable <stable@vger.kernel.org>, 
	linux-mm <linux-mm@kvack.org>, linux-nvdimm <linux-nvdimm@lists.01.org>, 
	LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 2, 2019 at 4:20 PM Dan Williams <dan.j.williams@intel.com> wrote:
>
> On Thu, May 2, 2019 at 3:46 PM Pavel Tatashin <pasha.tatashin@soleen.com> wrote:
> >
> > Hi Dan,
> >
> > How do you test these patches? Do you have any instructions?
>
> Yes, I briefly mentioned this in the cover letter, but here is the
> test I am using:

Sorry, fumble fingered the 'send' button, here is that link:

https://github.com/pmem/ndctl/blob/subsection-pending/test/sub-section.sh

