Return-Path: <SRS0=58dN=SL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A8DF3C282CE
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 14:49:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 641A12064B
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 14:49:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="Jgo77ysd"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 641A12064B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F23D86B0010; Tue,  9 Apr 2019 10:49:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ED31A6B0269; Tue,  9 Apr 2019 10:49:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DE9716B026A; Tue,  9 Apr 2019 10:49:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id B6A2B6B0010
	for <linux-mm@kvack.org>; Tue,  9 Apr 2019 10:49:31 -0400 (EDT)
Received: by mail-oi1-f200.google.com with SMTP id d63so7615480oig.0
        for <linux-mm@kvack.org>; Tue, 09 Apr 2019 07:49:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=k18vVFTc+hq7WxyjyyY6YPjDwfffABYGdRiJn2pWXkA=;
        b=HWl4XntSc3fleEYUygwcIUp28w0o+6ggrrXaVakjDm2/WGduIKDcOEHgnSSjbCELCF
         zELz5zNzUDTHiuLvPfqoobwD4pKDqYN1PK6jncppu5Pi3bT1GMTheH2BASHPXNDWgPBj
         VV012MvNNYEmwopWoy036Yuc/7K3O3tmG+xoglik7926dI0eYROC5Q3cH7la4wDn3FG3
         XPJ3hyQjNKGTncWgpVCDx7FQkAlGaVswJtlULLxLlOqwqCR2oFLqR7xlAE+wzFC5VvXi
         rh4H6UZYr8FDl3xLVjiKXiexPtWp+qPu5er1wRxkrwR97Icz4CcVS6EbC6DiyRkJRV4k
         +BQA==
X-Gm-Message-State: APjAAAV3AUXvhKddhq88FWg0fo0Y368HfIcgVGzaDb8x8bL4VyLcskFP
	VnM63xWskrTVhqxGOb0eDe2P906wq+q11nXxV4EHHdkTKaQNNpuaAuB5hwWpahoyAXMTDAOYxiJ
	k/VUmS2IiN0yRcp2JzxNEJNg/AT1h4wSO8Cn23ShtFunmMovo7WCVPcBD4DSUGucynQ==
X-Received: by 2002:aca:5f46:: with SMTP id t67mr20963852oib.96.1554821371207;
        Tue, 09 Apr 2019 07:49:31 -0700 (PDT)
X-Received: by 2002:aca:5f46:: with SMTP id t67mr20963817oib.96.1554821370428;
        Tue, 09 Apr 2019 07:49:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554821370; cv=none;
        d=google.com; s=arc-20160816;
        b=oTQrfftS8wevmdup2KpbOwgcjPNHR7vF0eoLcWOrLsM7YZ4UgbaTjGw1CBn6NQMOBv
         65VpuIdmvfh/aNmXYU1v8RbbluVketBzhN8hVXgu9KySybrKLPI0YIXmv2doEHqYmUTl
         AwD2pH5C+QGo/cijIA78KxPGHv1RpjWDMZINpzsro4Y6NrJd3Nby9qa/w2rw2t9bZOti
         Ae2sUXTkfDptQH6KHYwF4OXSvoY9rHaIPSp0apul7J5QcZaEreivpWKLJ77dUyCyYXCa
         kd/yv6BKqLfhzTEuQayaNY8NhZFhUpVMO+JmbQjAgS0C/XLR0TUMHnUn2jF3mSH0KS0r
         6GKQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=k18vVFTc+hq7WxyjyyY6YPjDwfffABYGdRiJn2pWXkA=;
        b=PdFT0cUxA85oBp8dMgD/qv/vqNK/JSDh60fmkkDi8ebfLAv5qGBwrMjLpKuG0YF0d6
         HLdI6/TO12gfB/LetMTJeSrhVfOs3U8iawYFadwQgQDQyN0ERVlAnmkydNLAjQdOzNLd
         42v+phyF0Izt1CtKaDZdCrroVdOtj7lnFCHuaNLhKeu/CGgQzV5eJ+Vb8ok2nFS0czCe
         BTkJ7KcPsVfOK6jHe20PmxUCDu8nW5RUnEMSt7XrP/YGZLUE/dEkNjVzTCZwRDSTDiZ9
         ykGMsHDRGKpDy+DyfZwxoHq9FjMKpEu814apWdYG7TJHJl4SvA62cAWJX3JG+B18aCNo
         Rbcg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=Jgo77ysd;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 90sor18609022otl.123.2019.04.09.07.49.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 09 Apr 2019 07:49:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=Jgo77ysd;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=k18vVFTc+hq7WxyjyyY6YPjDwfffABYGdRiJn2pWXkA=;
        b=Jgo77ysdABrsaTRjIOT4m1WX7sd5vCQoSB0IvxSSxjkBx5SSkMCVcYRu31lVFo++J/
         qeN/swtfSsbbUtk6/Mfg65URcmgy6WN/PonezV4buI7RlC5k4UssuwFRoVGKkSBHr0NZ
         ZxKANLnCf4TmqK9je9dP3w7NyWJEp2CYvmvAipxPX7D8VtteU943JskqA6G7zNP4gtY4
         rktE27jcfl4IJ05xwRioHCOfRVfZ6CT+1UgIeiaWGjOehMrX/GPKcIfaMNA7ya89ptNk
         efIb3nMvbvj/6xWyrmqvWNYdhQlXl7i03tMBK6puOtBiHLNhruokv0aCYHV5baradbuA
         65Ng==
X-Google-Smtp-Source: APXvYqzg2IjJpUJv7Oc9XxacrOBeMKvYZMxzbtRcNRaccyHw1L7vBYcvCvlbRGK54j//hFmYexJmqA8Zwi+Vc4sFHeU=
X-Received: by 2002:a9d:6a88:: with SMTP id l8mr24365746otq.260.1554821370037;
 Tue, 09 Apr 2019 07:49:30 -0700 (PDT)
MIME-Version: 1.0
References: <155440490809.3190322.15060922240602775809.stgit@dwillia2-desk3.amr.corp.intel.com>
 <155440492988.3190322.4475460421334178449.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20190409121318.GA16955@infradead.org>
In-Reply-To: <20190409121318.GA16955@infradead.org>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 9 Apr 2019 07:49:18 -0700
Message-ID: <CAPcyv4h3M7fGtdWt_dUVGkp1A2VZjR98wg0xAzipVccYZuChqg@mail.gmail.com>
Subject: Re: [RFC PATCH 4/5] acpi/hmat: Register special purpose memory as a device
To: Christoph Hellwig <hch@infradead.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, 
	Len Brown <lenb@kernel.org>, Keith Busch <keith.busch@intel.com>, 
	Jonathan Cameron <Jonathan.Cameron@huawei.com>, Vishal L Verma <vishal.l.verma@intel.com>, 
	X86 ML <x86@kernel.org>, Linux MM <linux-mm@kvack.org>, 
	linux-nvdimm <linux-nvdimm@lists.01.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 9, 2019 at 5:13 AM Christoph Hellwig <hch@infradead.org> wrote:
>
> On Thu, Apr 04, 2019 at 12:08:49PM -0700, Dan Williams wrote:
> > Memory that has been tagged EFI_SPECIAL_PURPOSE, and has performance
> > properties described by the ACPI HMAT is expected to have an application
> > specific consumer.
> >
> > Those consumers may want 100% of the memory capacity to be reserved from
> > any usage by the kernel. By default, with this enabling, a platform
> > device is created to represent this differentiated resource.
>
> This sounds more than weird.  Since when did we let the firmware decide
> who can use the memory?

There's 2 related motivations for playing along with this "special
purpose" attribute. Before this bit we've seen gross hacks in platform
firmware trying to game OS behavior by lying about numa distances in
the ACPI SLIT. For example "near" high bandwidth memory being set at a
large distance to prevent the kernel from allocating from it by
default as much as possible. Secondly, allow niche applications
guarantees about being able to claim all of a given designated
resource.

The above comes with the option to override this default reservation
and just turn it back over to the page allocator i.e. ignore the
platform firmware hint.

The alternative is arranging for "special purpose" memory to be given
to the page allocator by default with the hope that it can be reserved
/ claimed early so the administrator can prevent unwanted allocations.
It just seemed overall easier to "default reserve with the option to
hot-add" instead of "default online with option / hope of hot-remove
or early allocation".

