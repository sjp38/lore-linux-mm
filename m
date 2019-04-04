Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 30F17C4360F
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 21:02:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CF3D82082E
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 21:02:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="T4WqQqKY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CF3D82082E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6BDDA6B000C; Thu,  4 Apr 2019 17:02:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 66E196B000D; Thu,  4 Apr 2019 17:02:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 511CF6B000E; Thu,  4 Apr 2019 17:02:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id 24ECE6B000C
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 17:02:43 -0400 (EDT)
Received: by mail-oi1-f200.google.com with SMTP id w10so1812827oie.1
        for <linux-mm@kvack.org>; Thu, 04 Apr 2019 14:02:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=+DrsGVUC4CyXvDtjSn1pg35i8ssXhg0MFwCOyyl15ho=;
        b=c0xrJ6+CEyKqdu4sLwQJ1jYbAsMTB0u78VtTCEO2XQcAKtXfRyDB24vxncKdHcv3Zr
         7/VVdObBxEfwaRZPsxWYe+hQd32HDENnCRGUAnaUr5TjI/NoaDZTXO0O2Nk8eDuv2b/c
         gGPjfrjVvd+i+ykRdk0Pj+U/+Z8HXU9BxHKBzONKaYfXcKUY5tJqZ0nHCIBonNZSL7GE
         eKlaZ1TvP80+to8csyLy5xjZjMjmJfjLRRWCCSxnNDu62MvjIWOITITZ6Q6fMw8yz6iJ
         4T50jmU9OD8dT1OkWXitXtpCf//ORfZhXtrCE7/ATEwmY4joo9zYT1BvSpyHeUdtmynC
         75pQ==
X-Gm-Message-State: APjAAAUz4Y8lIJKn+g+9HqSTM5TDcc2GMBv22oPVTRsxuMgBDGjsvdTY
	LPMUVHD4PbA8U1tUykw/ZHrH5dlAnlAkmSRvN+bTd9j3ZKIIcNr/n2wGPpbU07eBgTz2a86aN9o
	MiS/4VMTlH1bfZem0GpAItiYYbOFtWRCz1VBXmBiuIr8QzRCVcuV/fdDBO1Q48BlAxA==
X-Received: by 2002:aca:6289:: with SMTP id w131mr4870621oib.84.1554411762772;
        Thu, 04 Apr 2019 14:02:42 -0700 (PDT)
X-Received: by 2002:aca:6289:: with SMTP id w131mr4870586oib.84.1554411762028;
        Thu, 04 Apr 2019 14:02:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554411762; cv=none;
        d=google.com; s=arc-20160816;
        b=qwWikzP6AxIk6mcBJn/DDoaNvrGfgvRQcC41r8jLs0kluzwFKWxjbuqaSNMapGdPn+
         iZFRxz9ywoAgNx/BD1CqLZ3EhHjCjk+RPwL+lhLrcT0hh67KTzg1NAqFhxVzlkiOxWox
         pBk4Z5l4MIklu3pEcVGyaBe+wtxc8uxh8lG386+HNqGA9+9WkuC1zuh9mJqYoqIPLRxE
         ctmTNcXYjQ06HTxbvLm9CJXFMaOS0zlpIBwS5guZg1u7Dbhb2QSOE6w3FGtHRkY944Jd
         vOvJKtPbEJqMzeKtgXmrNef+s9+zXdDPLrRl5JgzGb3wLAwBZSYvNbTUNZ4foMSMmWLO
         aU6g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=+DrsGVUC4CyXvDtjSn1pg35i8ssXhg0MFwCOyyl15ho=;
        b=mrXarAan338WT3eTON3mWgOVNQr82QwcnYpxSkfjTskMA903AxHtF5IJNyhhGvY2d3
         /iEPzTMw6ilJpOUCPo3sk2Sk9KVumBa9FTY/3YCMYc+98H4wSbg4ycRqSRHcI+2jKosz
         DSe24XeRlyzMdmHR7dWIwommc0SuPSd7KxcV3DlH5H2nAeR8aGuon/qtXDdF7MsTNzXo
         hDGm5t0UGWflfh+XroTCtqDyiVudp4QM4GqHWgv3WRSm7cvxfzI/+rcFnSCJQxfBuvaa
         KpWqBhOBej7iU+/TvzxGyHDI5Syb9LYwrt5DTBto9Kz7yx6kLVeffE+MyF2TeYw6fVkT
         8DnQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=T4WqQqKY;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q7sor12531233otk.79.2019.04.04.14.02.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 04 Apr 2019 14:02:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=T4WqQqKY;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=+DrsGVUC4CyXvDtjSn1pg35i8ssXhg0MFwCOyyl15ho=;
        b=T4WqQqKYK6FMJ1y32LoSrxeA+KO0QpDj1ISaVQLh2tPAsPni+zmP0inWEuDw/xB3kI
         Dul6rR8vQ9Jja1D10S8Et2qKWkkRBsq3vpXJXWkhuhy7kmVr26AK5iOptICGkOJU4Ha1
         zH8tiyg15L76OrapwbxB9PcC+9PUAb9VtdUH8vz2PrwJnic3YlK+UJZKaSSEeIGG13yN
         OcMDzJPWEXqNJMaKjR3w1PsDXR07bPoic71WK+9UU6vnrEgpICixDNZdk5CeoxrPssK6
         Kl6St+YQJ1fKHQT8fi2KkJgdpGqfqCynTKB6y+WgNW2Q/iQKwoefucD8SjYzHt91iACR
         tkUg==
X-Google-Smtp-Source: APXvYqxIBXEFW2Oy96NM35Uo/yMBoE4dKe5/MW9hq8vfTI0GX74IQg8bFAmtM8KkdIDrIdLtElSUadW0IP3KmaaUMDI=
X-Received: by 2002:a9d:5c86:: with SMTP id a6mr5763686oti.118.1554411761776;
 Thu, 04 Apr 2019 14:02:41 -0700 (PDT)
MIME-Version: 1.0
References: <155440490809.3190322.15060922240602775809.stgit@dwillia2-desk3.amr.corp.intel.com>
 <155440491849.3190322.17551464505265122881.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20190404193211.GK22763@bombadil.infradead.org>
In-Reply-To: <20190404193211.GK22763@bombadil.infradead.org>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 4 Apr 2019 14:02:30 -0700
Message-ID: <CAPcyv4hruLHWpEq_fT=_uFeO8X6KLjLsR2=s577iXey+NUFz4Q@mail.gmail.com>
Subject: Re: [RFC PATCH 2/5] lib/memregion: Uplevel the pmem "region" ida to a
 global allocator
To: Matthew Wilcox <willy@infradead.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Keith Busch <keith.busch@intel.com>, 
	Vishal L Verma <vishal.l.verma@intel.com>, X86 ML <x86@kernel.org>, Linux MM <linux-mm@kvack.org>, 
	linux-nvdimm <linux-nvdimm@lists.01.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 4, 2019 at 12:32 PM Matthew Wilcox <willy@infradead.org> wrote:
>
> On Thu, Apr 04, 2019 at 12:08:38PM -0700, Dan Williams wrote:
> > +++ b/lib/Kconfig
> > @@ -318,6 +318,12 @@ config DECOMPRESS_LZ4
> >  config GENERIC_ALLOCATOR
> >       bool
> >
> > +#
> > +# Generic IDA for memory regions
> > +#
>
> Leaky abstraction -- nobody needs know that it's implemented as an IDA.
> Suggest:
>
> # Memory region ID allocation
>

Looks good to me.

> ...
>
> > +++ b/lib/memregion.c
> > @@ -0,0 +1,22 @@
> > +#include <linux/idr.h>
> > +#include <linux/module.h>
> > +
> > +static DEFINE_IDA(region_ida);
> > +
> > +int memregion_alloc(void)
> > +{
> > +     return ida_simple_get(&region_ida, 0, 0, GFP_KERNEL);
> > +}
> > +EXPORT_SYMBOL(memregion_alloc);
> > +
> > +void memregion_free(int id)
> > +{
> > +     ida_simple_remove(&region_ida, id);
> > +}
> > +EXPORT_SYMBOL(memregion_free);
> > +
> > +static void __exit memregion_exit(void)
> > +{
> > +     ida_destroy(&region_ida);
> > +}
> > +module_exit(memregion_exit);
>
>  - Should these be EXPORT_SYMBOL_GPL?

I don't see the need. These are simple wrappers around existing
EXPORT_SYMBOL() exports, and there's little concern that these
interfaces might disappear in the future causing us pain with out of
tree modules as these don't touch anything in the core.

>  - Can we use the new interface, ida_alloc() and ida_free()?

Sure.

>  - Do we really want memregion_exit() to happen while there are still IDs
>    allocated in the IDA?  I think this might well be better as:
>
>         BUG_ON(!ida_empty(&region_ida));

True, or just delete the module_exit because this functionality can't
be built as a module, so the exit path is already dead code.

> Also, do we really want to call the structure the region_ida?  Why not
> region_ids?

Sure, sounds good.

