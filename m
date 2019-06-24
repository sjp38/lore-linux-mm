Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 59247C48BE9
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 18:25:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1F7B820645
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 18:25:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="ISIKS+Ql"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1F7B820645
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 96D796B0007; Mon, 24 Jun 2019 14:25:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 91CEF8E0003; Mon, 24 Jun 2019 14:25:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 770858E0002; Mon, 24 Jun 2019 14:25:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4A1FA6B0007
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 14:25:01 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id r2so7819729oti.10
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 11:25:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=NsFsqmCeB4cJxbUvEFO6xcZSO/kARHjBGNTe6zm2OGk=;
        b=IdpRaLpKJz0ICDx2BC3aRXxe7hp/eE34Iz4mjzSK7ijB/C3le7QDpFpnJTAQqlXvRL
         kalqA+O6xLZHMaSMvam53xCAMRN4D22V4aAKlytjQWnUoljP6zWCEOhy0NI5T5xtAcWn
         NaJ7uNrcBY9X2Zkfa6WHDuxvx04byy0RKlAR96azuOXNEtCD3v7S+DLACgH2eTSrRmeo
         rt5epKkkuxJrjvIVJ4kLjuZ9SP0O7NC+o4lXx6tugxa7auxRapDHLjPLx0bMnJAljgZX
         btMXJg0LCF38r/xt2b/fJK+AmNkqXIs7DJZayHxUcKlbAJgfzU67p4MGc/cs4u5n5/YG
         mBew==
X-Gm-Message-State: APjAAAUMiC4W5z9U55ZJkoZvjsbwDbO+4/k8BLkd9w/36plDVc2vEBGG
	jCcCg9NYfs9YLgIvmSyorz118V3Bo/6UMlBBCpUAg9YTFTTI2yZ7jLlJWuq7lwhLXtBRjE7QD4l
	C8eSNgC/OwKt1ZjscEW0yBdGjHLQKnD3VDcN0jwdIwggxNfb1dJV57hOSbEiNhEJbOg==
X-Received: by 2002:a9d:6f91:: with SMTP id h17mr42247652otq.67.1561400700858;
        Mon, 24 Jun 2019 11:25:00 -0700 (PDT)
X-Received: by 2002:a9d:6f91:: with SMTP id h17mr42247621otq.67.1561400700051;
        Mon, 24 Jun 2019 11:25:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561400700; cv=none;
        d=google.com; s=arc-20160816;
        b=QinLz4rdosHS5FAkaZ4L1PNNu9VjvjoJDAaMXmzacIYSU1u+qRfJK0wOpRik5bdnLY
         D4jjdUaq+QlTdVodJYsdG4yWUGzsdmVVdC99qfE8mReGM1pTHkL3MFnEQhvoIqmKYz0n
         d3+od7bg+69oAF3loocPw3lnE0DCFtZgzcxtzu3SfbjxX79fCVpkkJ9Kt1a7TaLoQp4C
         A7T1hXS+fDmEVMZ+LzWlH90izHHZnRPLrlpHnkLW7PUFEcgD/EIorGYkSHQkBxyHPgTz
         nHb5yYnPHCHhxj7U0PFkcQRYTLxvBdkDZtdbsWhIfaUR5HACJeD6Zatah+UfJNsSWGpZ
         F3Mg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=NsFsqmCeB4cJxbUvEFO6xcZSO/kARHjBGNTe6zm2OGk=;
        b=AFeQfw7kS4Lak3E6zpdYSUbFagc/U2N+7CFY9qeJR44S+D/F1XgWDu0uSdDlUWLA7s
         H4P6eKbLFnsM71ul5tRHJcSzZb2qD9SaWZtYDAzYUEjWu+iVOpN5U5hlmNOGjJmq2PGY
         9l5UUCJ0KyyXJFOEci26yO0H93/XA0d627CtUg+zL/b6thuwbAt0p9gIlR4flSvCSd9D
         FLVUS3XJyXm9Qd8vTDIhWRIH6GjwECwLr6EefARlE6NbSR30Pt0pTg58Maj32ARH58xc
         BDpSysrjtGvSTwYX86BlMfsitSYrnXnhDysgvPZ6VCgtJYc/8zePrywC+vlgML5A0UPB
         r8Gg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=ISIKS+Ql;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h194sor4962917oib.133.2019.06.24.11.24.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 24 Jun 2019 11:24:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=ISIKS+Ql;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=NsFsqmCeB4cJxbUvEFO6xcZSO/kARHjBGNTe6zm2OGk=;
        b=ISIKS+QlpEyn1hNfgdDi5hMHKw8iit0945EcE3yN7j+0wsgacWlTs5VS/2eHyNPn4P
         zFzHaSyW66Yiy2RhkTwuJ3InCkBlGpTPkGdBxkYOWHXgUlVbX7KrnXrnxhmbl79B80YX
         fCQYLMQ6T4q3GxjWwuuuag5EPhpGhA+skRXUiofVA4jxcOoybEtzKs47HHrVewo4aeOH
         xEgr2mAYq4kDK9twlyulxuXtH8x20UgS6h2b36rjnfm3Zpe3kyRxJhg0wXN2sl5N3Gx9
         a1ANzgYTbnIct0aX4IAsj7uocTALXH4slbfh3ZtWL5Y9qp3yWn0Ovu6E52I1ME72busN
         XZfQ==
X-Google-Smtp-Source: APXvYqxMfIu+2D2MtYcv2E7EXzI2zB57kKNYjO9p4H9g9zR42W2XzhT13YcbI1eS8VOBT1jN50QqXbLB+mAAmyIYdBg=
X-Received: by 2002:aca:fc50:: with SMTP id a77mr11696883oii.0.1561400699583;
 Mon, 24 Jun 2019 11:24:59 -0700 (PDT)
MIME-Version: 1.0
References: <20190613094326.24093-1-hch@lst.de> <20190613094326.24093-6-hch@lst.de>
 <20190620191733.GH12083@dhcp22.suse.cz>
In-Reply-To: <20190620191733.GH12083@dhcp22.suse.cz>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 24 Jun 2019 11:24:48 -0700
Message-ID: <CAPcyv4h9+Ha4FVrvDAe-YAr1wBOjc4yi7CAzVuASv=JCxPcFaw@mail.gmail.com>
Subject: Re: [PATCH 05/22] mm: export alloc_pages_vma
To: Michal Hocko <mhocko@kernel.org>
Cc: Christoph Hellwig <hch@lst.de>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	Jason Gunthorpe <jgg@mellanox.com>, Ben Skeggs <bskeggs@redhat.com>, Linux MM <linux-mm@kvack.org>, 
	nouveau@lists.freedesktop.org, 
	Maling list - DRI developers <dri-devel@lists.freedesktop.org>, linux-nvdimm <linux-nvdimm@lists.01.org>, 
	linux-pci@vger.kernel.org, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 20, 2019 at 12:17 PM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Thu 13-06-19 11:43:08, Christoph Hellwig wrote:
> > noveau is currently using this through an odd hmm wrapper, and I plan
> > to switch it to the real thing later in this series.
> >
> > Signed-off-by: Christoph Hellwig <hch@lst.de>
> > ---
> >  mm/mempolicy.c | 1 +
> >  1 file changed, 1 insertion(+)
> >
> > diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> > index 01600d80ae01..f9023b5fba37 100644
> > --- a/mm/mempolicy.c
> > +++ b/mm/mempolicy.c
> > @@ -2098,6 +2098,7 @@ alloc_pages_vma(gfp_t gfp, int order, struct vm_area_struct *vma,
> >  out:
> >       return page;
> >  }
> > +EXPORT_SYMBOL_GPL(alloc_pages_vma);
>
> All allocator exported symbols are EXPORT_SYMBOL, what is a reason to
> have this one special?

I asked for this simply because it was not exported historically. In
general I want to establish explicit export-type criteria so the
community can spend less time debating when to use EXPORT_SYMBOL_GPL
[1].

The thought in this instance is that it is not historically exported
to modules and it is safer from a maintenance perspective to start
with GPL-only for new symbols in case we don't want to maintain that
interface long-term for out-of-tree modules.

Yes, we always reserve the right to remove / change interfaces
regardless of the export type, but history has shown that external
pressure to keep an interface stable (contrary to
Documentation/process/stable-api-nonsense.rst) tends to be less for
GPL-only exports.

[1]: https://lists.linuxfoundation.org/pipermail/ksummit-discuss/2018-September/005688.html

