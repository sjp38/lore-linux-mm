Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 041F1C31E5B
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 15:17:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A5A0A208C4
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 15:17:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="RXkc/Niz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A5A0A208C4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 469146B0007; Mon, 17 Jun 2019 11:17:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 41AEA8E0003; Mon, 17 Jun 2019 11:17:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2E28D8E0001; Mon, 17 Jun 2019 11:17:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id D0C296B0007
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 11:17:20 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id i9so16840133edr.13
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 08:17:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=793wO/lpxosyL8Lo8JzZhwJr+Npn0SNzRpqHl7DL5pk=;
        b=uEiA0iKjrdxL7DwTCQ/4EQ3a3QQskEwQWtafqJkBfvReerE9YLaZjtmFzRwfkOltQc
         5wHDIQlHkAXrSZ60J4wT+lml2FsFP/BBkF7lCGSl4XJsYO6q4DNRsf8q7OCUm0w7D62q
         mg09ZW9GIaD0HN0P6l+arodnHgwd/6JDtM0jdUB/JCE5bwTo55UaXynyUqOrwRd7+kB2
         Io+TNKpcbDB0q9B+AzlOGrLJCyPklE+B7fOXwocyGGtCh1uy9yYS7gIUO1Uw7T6JUzJJ
         EaZ/8yG49Zj0Xc1e4fgpr2wGUQbFRf59Vog1+sz/RkCriA9k53cff8gpD41j9DfpLfFs
         kcvw==
X-Gm-Message-State: APjAAAVUl8Qk2ivIM3FnUXLCb9NE0zj9tl5SjeQMmUsmblW0HPUv4U8r
	fqRX2vEn4S7fB/qOE/OfqXiw1dBcAOyLuLJfXrSXsu7vi0BjNxbSPkZGIuU6GusD8vJ91CqmfSk
	BcckK+0+9WSacNsd94/V20f2Pu5aU41zT/07p7r+UQdgS5FpROEq5CG9rny1erkaDsg==
X-Received: by 2002:a50:d1c6:: with SMTP id i6mr2255197edg.110.1560784640405;
        Mon, 17 Jun 2019 08:17:20 -0700 (PDT)
X-Received: by 2002:a50:d1c6:: with SMTP id i6mr2255121edg.110.1560784639741;
        Mon, 17 Jun 2019 08:17:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560784639; cv=none;
        d=google.com; s=arc-20160816;
        b=spNqrLKbPh6wg8VpxJaHsgZOccWIh1H+gCEb54gzn003ofcO+ZS9lJ2f0qvHyu0K+6
         oAfrVTaSi0zdG2v3dDQwYwd0axUTSloaQyxMy2C99BKjU4fQDkwE+fU4TvRyPIFDqjT+
         gzrwuX5fTGoYoTPSNd5JDCaKYKuaThUQA1ZGgtwsA/DdLxEBTP4tR1FV1lp8Usqvd/tj
         FdPX8Dq1hpZ6w+sVFNo337o90kIbip5YEqDtBRk43rnGRkCuijEN2JuOP9pyCy8dqIsu
         onbofvUtkpFANzjamoNuY3yEQNXtoFZH+kX4HrtFaGt5MUqHyNP5u5oBWqdSLBRF5Lcx
         rAoA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=793wO/lpxosyL8Lo8JzZhwJr+Npn0SNzRpqHl7DL5pk=;
        b=DSpn8r1wCrwb+HlDXbRuXTZgswizHtLCfrxTt/0DSYBGQuh/dM4AjoPnNRBq+tbb4G
         zYO6y5XcrieLQwRPQ1rMBuL9NwTgepNkszB8ZVALz0JxkR+RhOnbbkSZRTIqepmVsMwh
         q5YID7OsdRKl/XEYhDGoixTpd2aIN+i2pDqEtEqJzK+gH1UcQRtGhM+ZFES8ktt4ub/W
         yuy72d1rd6x2oo8TzOhyqG1AFDdFaVscr1n5OB/PMcyp8+H9YymEm04TGiOGcWoB72qB
         SNJJ/ObZVnPyZVY0vTjYMoXRHpG+NVjtknAKxXiuTgO4EWoZOS7YiwSsSnX0TEe+p08B
         dk0g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b="RXkc/Niz";
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x47sor9269577edd.22.2019.06.17.08.17.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 17 Jun 2019 08:17:19 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b="RXkc/Niz";
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=793wO/lpxosyL8Lo8JzZhwJr+Npn0SNzRpqHl7DL5pk=;
        b=RXkc/NizyisWqRuCLogAjrsGOcBd68f10ywsjcm7brS6yJ+d35dfd+cuxSbAdQkx7z
         wKq6dhyTSmZ8s4JbZA59Rkjj72jmNHBxRcmOYEgxuj6UaAQzP3CjhQs8yOYAaNNeQtYZ
         oQiaPvp4+5m58VPDDZEqv915qKyTqDyud0y//YquxhBsN1QiXiGgrRgpGbRFSbY2lMhp
         16SEa3RJWjVMHgeXA/9dyN9Ap1U+ZDrdKgvOStfNibxXjwuR3roK7mBx8fRE2X27RuH9
         2I09MIggqYS5t3kBHlA8AG3pKMkbKtW5EIxg5zvJJHx3o698XrY/7sue3H+NA82wDJmc
         Y3PQ==
X-Google-Smtp-Source: APXvYqx/2PG0WVKQ0QCNSQz1um97AoXbarsKCLVMsvp/9S7L7EsBQNFc5qFB/PVQai5MQ0iioIgvfg==
X-Received: by 2002:a50:addc:: with SMTP id b28mr23146217edd.174.1560784639396;
        Mon, 17 Jun 2019 08:17:19 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id j17sm4004322ede.60.2019.06.17.08.17.18
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jun 2019 08:17:18 -0700 (PDT)
Received: by box.localdomain (Postfix, from userid 1000)
	id E2A72100F6D; Mon, 17 Jun 2019 18:17:17 +0300 (+03)
Date: Mon, 17 Jun 2019 18:17:17 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Peter Zijlstra <peterz@infradead.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>,
	Borislav Petkov <bp@alien8.de>,
	Andy Lutomirski <luto@amacapital.net>,
	David Howells <dhowells@redhat.com>,
	Kees Cook <keescook@chromium.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Kai Huang <kai.huang@linux.intel.com>,
	Jacob Pan <jacob.jun.pan@linux.intel.com>,
	Alison Schofield <alison.schofield@intel.com>, linux-mm@kvack.org,
	kvm@vger.kernel.org, keyrings@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH, RFC 18/62] x86/mm: Implement syncing per-KeyID direct
 mappings
Message-ID: <20190617151717.ofjfbpsgv6hkj2jk@box>
References: <20190508144422.13171-1-kirill.shutemov@linux.intel.com>
 <20190508144422.13171-19-kirill.shutemov@linux.intel.com>
 <20190614095131.GY3436@hirez.programming.kicks-ass.net>
 <20190614224309.t4ce7lpx577qh2gu@box>
 <20190617092755.GA3419@hirez.programming.kicks-ass.net>
 <20190617144328.oqwx5rb5yfm2ziws@box>
 <20190617145158.GF3436@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190617145158.GF3436@hirez.programming.kicks-ass.net>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 17, 2019 at 04:51:58PM +0200, Peter Zijlstra wrote:
> On Mon, Jun 17, 2019 at 05:43:28PM +0300, Kirill A. Shutemov wrote:
> > On Mon, Jun 17, 2019 at 11:27:55AM +0200, Peter Zijlstra wrote:
> 
> > > > > And yet I don't see anything in pageattr.c.
> > > > 
> > > > You're right. I've hooked up the sync in the wrong place.
> 
> > I think something like this should do (I'll fold it in after testing):
> 
> > @@ -643,7 +641,7 @@ static int sync_direct_mapping_keyid(unsigned long keyid)
> >   *
> >   * The function is nop until MKTME is enabled.
> >   */
> > -int sync_direct_mapping(void)
> > +int sync_direct_mapping(unsigned long start, unsigned long end)
> >  {
> >  	int i, ret = 0;
> >  
> > @@ -651,7 +649,7 @@ int sync_direct_mapping(void)
> >  		return 0;
> >  
> >  	for (i = 1; !ret && i <= mktme_nr_keyids; i++)
> > -		ret = sync_direct_mapping_keyid(i);
> > +		ret = sync_direct_mapping_keyid(i, start, end);
> >  
> >  	flush_tlb_all();
> >  
> > diff --git a/arch/x86/mm/pageattr.c b/arch/x86/mm/pageattr.c
> > index 6a9a77a403c9..eafbe0d8c44f 100644
> > --- a/arch/x86/mm/pageattr.c
> > +++ b/arch/x86/mm/pageattr.c
> > @@ -347,6 +347,28 @@ static void cpa_flush(struct cpa_data *data, int cache)
> >  
> >  	BUG_ON(irqs_disabled() && !early_boot_irqs_disabled);
> >  
> > +	if (mktme_enabled()) {
> > +		unsigned long start, end;
> > +
> > +		start = *cpa->vaddr;
> > +		end = *cpa->vaddr + cpa->numpages * PAGE_SIZE;
> > +
> > +		/* Sync all direct mapping for an array */
> > +		if (cpa->flags & CPA_ARRAY) {
> > +			start = PAGE_OFFSET;
> > +			end = PAGE_OFFSET + direct_mapping_size;
> > +		}
> 
> Understandable but sad, IIRC that's the most used interface (at least,
> its the one the graphics people use).
> 
> > +
> > +		/*
> > +		 * Sync per-KeyID direct mappings with the canonical one
> > +		 * (KeyID-0).
> > +		 *
> > +		 * sync_direct_mapping() does full TLB flush.
> > +		 */
> > +		sync_direct_mapping(start, end);
> > +		return;
> 
> But it doesn't flush cache. So you can't return here.

Thanks for catching this.

	if (!cache)
		return;

should be fine.

-- 
 Kirill A. Shutemov

