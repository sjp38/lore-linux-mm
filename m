Return-Path: <SRS0=TqY8=VP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E91B1C76195
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 19:05:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8DF492184B
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 19:05:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="Bl2twEhm"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8DF492184B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 146056B0006; Thu, 18 Jul 2019 15:05:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0D0368E0003; Thu, 18 Jul 2019 15:05:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EB24A8E0001; Thu, 18 Jul 2019 15:05:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id B175C6B0006
	for <linux-mm@kvack.org>; Thu, 18 Jul 2019 15:05:04 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id e95so14402883plb.9
        for <linux-mm@kvack.org>; Thu, 18 Jul 2019 12:05:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=hJCHgwWJegp9gmuco2S0E0jhothiJS3DFgir7R78j+Q=;
        b=mKPPncQiW0ZVPoUregseJpEalD5viyzOAIDQNPBSCDmxBSw0U3MvcHhvAB440H4X5f
         WtXVS/xU2fqo2oEE+JSiRc0+X04IZJsvmQdmIJb+AQ8Ljov9fjrlQyg0rGTtkL14x8Zz
         D0PrWzATNfOXDfnxCJYwC77pbtZMB5d1gjFmrFW8rd2dveOVWL3fFWMoaih8EiazgZEo
         ltlezGPylHLRkP+QAIjZG5gguYXBGd4ZPDixM4HYPpp5z6yJY5NONCNipRRbpWbmK2LC
         o9VfUNaYDGa0qxiC18D4qA9UBm19gJtnfkS4OzObVTxscucw2hOj+CDEtuUze2x+BSlf
         HQyg==
X-Gm-Message-State: APjAAAUa6RgyDPV1wSWOL/sT2uQxCmarRDdcGIfR+oexL9BcCfN5tQA1
	YhwJwvZkGoQ10lVh82NzpL6Jnu1nVLHOcl6FAgh8hvwc6oGbpRHEu1HyTAD0MUUFKxfVDxtVJZm
	dIs6JsC65zcLvaGEidWw/sOMNERCHrLOzl6wUkT0A6v3q2kl09Ythnmw/NfJ6k4qf9w==
X-Received: by 2002:a17:90a:3724:: with SMTP id u33mr52155108pjb.19.1563476704289;
        Thu, 18 Jul 2019 12:05:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx7wbwS+EfKzYQeol8VhJFD8VYVj0iKoss4sLRH+MbiWbxr6F8Zrq88299mLMxRu5Zoiy9S
X-Received: by 2002:a17:90a:3724:: with SMTP id u33mr52155012pjb.19.1563476703117;
        Thu, 18 Jul 2019 12:05:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563476703; cv=none;
        d=google.com; s=arc-20160816;
        b=lVDYBkpONyvQ9/7FfxhrxnO/MZXzQr4nCDrvEaVCESrHSN98DThhFboJqS6f45pVTQ
         +E6MrrW7188KyAfcJkGkcmBAWjnmHCq30E+/LSH+qaHqcoOcR0Rbafwys6ZL+2uVtI70
         +/0mjSFO45QfJ+OJE1leF4pYMl0Y7A+mUxaGPmXO8NUKWIt7u99KbYKIntmRepX5+xaR
         bxUUU9F/Vt+ckowNv7nhyh7gFVta+9AxYRXs5S8XWTcq7teg/XuY+vobtixWtUNwkLpy
         R4LOUMUu12JDk9xSQsR1groHHNZTg/sAJ5hoxi1EoX9z5OO1HFnJdgjFj+Bslymzfwxr
         21SQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=hJCHgwWJegp9gmuco2S0E0jhothiJS3DFgir7R78j+Q=;
        b=0UfkXuRJFpHfS4LTH8Fe/+1eNdxwUjSqOFP46doZthpoltoce9Z6natmq/lZCzydJD
         lh4txBVh4hNuX64RxS8/F69w5To/50XDTSK1ZRP4OpXPVoYC2fCwrIXY+7ec6x0l2+9s
         IyNCvdWQvDTCQkgb88ClvK6RHSXs1DKnIMp/3Om1rtNZ1hr2rXi8zNmSwxVu4KMk/2gR
         sbqg6e0Jz6xHSOyc1c/EumKsvhmb6xYwbErixrkDeP8SSCSjSi/ajrjjIfwUHmCqxDPN
         fR1RJlTog5Wo9ZYZBJmhIni9B6D4C0UdJ/+tH1TqAlLFnr7PWKWKkGVjkggRRkT2kT4N
         L5pA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=Bl2twEhm;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id n9si206096pgq.240.2019.07.18.12.05.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jul 2019 12:05:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=Bl2twEhm;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-wr1-f41.google.com (mail-wr1-f41.google.com [209.85.221.41])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 232112184B
	for <linux-mm@kvack.org>; Thu, 18 Jul 2019 19:05:02 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1563476702;
	bh=JLV3apyWx90y3S5LriUELmBnKu3l40uTLHsTfgrKxVg=;
	h=References:In-Reply-To:From:Date:Subject:To:Cc:From;
	b=Bl2twEhm2US7P69bVm3HXVdMmwuJjpJpKdezxRcPxJPh5Aa9brJgyZfbKrxU70Ijf
	 qLmuD6/QjMGMU3y6dIpzimq1mxSiGSpCKiRxbrufLNl6ISnfP5buAod9rAQEW18Ikf
	 8QABJimF8B2leofR35RQCBn7S3se+I+JumTZIFQo=
Received: by mail-wr1-f41.google.com with SMTP id p17so29799703wrf.11
        for <linux-mm@kvack.org>; Thu, 18 Jul 2019 12:05:02 -0700 (PDT)
X-Received: by 2002:adf:f28a:: with SMTP id k10mr11064718wro.343.1563476700729;
 Thu, 18 Jul 2019 12:05:00 -0700 (PDT)
MIME-Version: 1.0
References: <20190717071439.14261-1-joro@8bytes.org> <20190717071439.14261-4-joro@8bytes.org>
 <CALCETrXfCbajLhUixKNaMfFw91gzoQzt__faYLwyBqA3eAbQVA@mail.gmail.com> <20190718091745.GG13091@suse.de>
In-Reply-To: <20190718091745.GG13091@suse.de>
From: Andy Lutomirski <luto@kernel.org>
Date: Thu, 18 Jul 2019 12:04:49 -0700
X-Gmail-Original-Message-ID: <CALCETrXJYuHN872F74kVTuw4dYOc5saKqoUFbgJ5X0EuGEhXcA@mail.gmail.com>
Message-ID: <CALCETrXJYuHN872F74kVTuw4dYOc5saKqoUFbgJ5X0EuGEhXcA@mail.gmail.com>
Subject: Re: [PATCH 3/3] mm/vmalloc: Sync unmappings in vunmap_page_range()
To: Joerg Roedel <jroedel@suse.de>
Cc: Andy Lutomirski <luto@kernel.org>, Joerg Roedel <joro@8bytes.org>, 
	Dave Hansen <dave.hansen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, 
	Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, 
	Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, 
	Linux-MM <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 18, 2019 at 2:17 AM Joerg Roedel <jroedel@suse.de> wrote:
>
> Hi Andy,
>
> On Wed, Jul 17, 2019 at 02:24:09PM -0700, Andy Lutomirski wrote:
> > On Wed, Jul 17, 2019 at 12:14 AM Joerg Roedel <joro@8bytes.org> wrote:
> > > diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> > > index 4fa8d84599b0..322b11a374fd 100644
> > > --- a/mm/vmalloc.c
> > > +++ b/mm/vmalloc.c
> > > @@ -132,6 +132,8 @@ static void vunmap_page_range(unsigned long addr, unsigned long end)
> > >                         continue;
> > >                 vunmap_p4d_range(pgd, addr, next);
> > >         } while (pgd++, addr = next, addr != end);
> > > +
> > > +       vmalloc_sync_all();
> > >  }
> >
> > I'm confused.  Shouldn't the code in _vm_unmap_aliases handle this?
> > As it stands, won't your patch hurt performance on x86_64?  If x86_32
> > is a special snowflake here, maybe flush_tlb_kernel_range() should
> > handle this?
>
> Imo this is the logical place to handle this. The code first unmaps the
> area from the init_mm page-table and then syncs that page-table to all
> other page-tables in the system, so one place to update the page-tables.


I find it problematic that there is no meaningful documentation as to
what vmalloc_sync_all() is supposed to do.  The closest I can find is
this comment by following the x86_64 code, which calls
sync_global_pgds(), which says:

/*
 * When memory was added make sure all the processes MM have
 * suitable PGD entries in the local PGD level page.
 */
void sync_global_pgds(unsigned long start, unsigned long end)
{

Which is obviously entirely inapplicable.  If I'm understanding
correctly, the underlying issue here is that the vmalloc fault
mechanism can propagate PGD entry *addition*, but nothing (not even
flush_tlb_kernel_range()) propagates PGD entry *removal*.

I find it suspicious that only x86 has this.  How do other
architectures handle this?

At the very least, I think this series needs a comment in
vmalloc_sync_all() explaining exactly what the function promises to
do.  But maybe a better fix is to add code to flush_tlb_kernel_range()
to sync the vmalloc area if the flushed range overlaps the vmalloc
area.  Or, even better, improve x86_32 the way we did x86_64: adjust
the memory mapping code such that top-level paging entries are never
deleted in the first place.

