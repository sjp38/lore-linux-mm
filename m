Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 081B6C31E47
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 10:09:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B6EEE208C4
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 10:09:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="Tg/uhL+i"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B6EEE208C4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3D3A86B0006; Wed, 12 Jun 2019 06:09:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 383A26B0007; Wed, 12 Jun 2019 06:09:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 24C4A6B0008; Wed, 12 Jun 2019 06:09:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id CA7456B0006
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 06:09:07 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id b3so24140225edd.22
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 03:09:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=IFDigL4vy3b62qjT1WszXB3PDewotHj2dqglzXL17hc=;
        b=NsmoWLbr7TSv5FAwMcA8ZX25XsTyrG9BOxzI/f6cBFYXoAKUocuUTy9vSOhypyxzFq
         NMTYQ5xOKHVSz9hLq0pY3pEa95p2Xm5CwYzVhY8D8QnINtpAJz2MaXxo/FuqLQ41gzMn
         Gufy3HOVA1Dat1x1te4mbSl5ZR03jHfuEdnrynqIgVr8QEwvGWejHYE5wngmQME25NAO
         tm1mlm/nXsJz2G6Tv4EVpzDUwyow83f2GWvxffUwNQdiPTjBzZe6bDRrETUDPBOa9rij
         lb8bI3r+4Vk9XHuqkTuPa1B/VgF5hnUJCU0c6Nsqcit6q8kq33Kn4EF5v8l2q1E/RZch
         ILDw==
X-Gm-Message-State: APjAAAVgtGENJSffciR0WHZGcX7byHWA2FhFzBSnZlCj3YBYAyne7POH
	vpV0qkzmw0ucn3Ynp4SDC791+zfKbUVUfA402Xq95H9cNHLn12Cb/OCxspsIS3b2f9FuF8/yxfh
	RdMOuKbZNRZHmuuLYCPs6Ewu5eaAgaEg39VMJZ7E3FtT4Zo7jZBgyDNMKTk1drSowAg==
X-Received: by 2002:a17:906:4987:: with SMTP id p7mr9937627eju.141.1560334147275;
        Wed, 12 Jun 2019 03:09:07 -0700 (PDT)
X-Received: by 2002:a17:906:4987:: with SMTP id p7mr9937551eju.141.1560334146213;
        Wed, 12 Jun 2019 03:09:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560334146; cv=none;
        d=google.com; s=arc-20160816;
        b=gTqS0DXWLlzvYklopEga+cOglqn6kKLiZvJVdy4o58BKenPrJTb1lifpJ3A+2tebt/
         CcVHDOqmkahXPtySEpDkaCuHbLlxLaejoyYeFbT0R4usFBX5m+FhjhdrPEWTjpa/NqT4
         E53MGVsJyVVF7qdi5ssThfxnGV4LcUI1ADFdyZY+1L+b/s6gLiuQ8DfONty/EK5BewYB
         QxtOCm3REiJZyfzslQbCjv5Z0rK8Ic1d7iMH3mtax9rhacSMtnEESTAP9XWgaos/Ebtp
         mMlaQYViUgA9oj/R5rVS31RXdct57PWoq6isl+Pqme3l21BmODINlxFEmkHqrmUvHF8T
         ko2g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=IFDigL4vy3b62qjT1WszXB3PDewotHj2dqglzXL17hc=;
        b=t1D2jbQYLd7cgy7ITbH85PYG+gEVe2/eVOteuZPJR6YgApKwkPt7yjs1gvigXwlHEt
         kCueuFsbxRSpEoGRTEFIX36i7btbcM+8J/6u/Sh50EQ7Tgsmu9yFIQgaeey+coRAygny
         9XvqIg6/ABzczMao9k4z5CNQ35Kk2FxVM0pG8h+1BN8x/KfFPupJ18qASxJwCivBhtoN
         Htbo+FPwNaTLib8mHHeFOs1swJ2KtE/V8sSjlXuEHgsOWvPbQwfK18ya0U0O1geCx35t
         Cd2bugHXtSnqbSGQOS15fqdGOmDsENBe+SQvp/O8A1mXlnsQKFFuLKOQCf2jaO4DPlHT
         80Ng==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b="Tg/uhL+i";
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t10sor4827372ejt.34.2019.06.12.03.09.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 12 Jun 2019 03:09:06 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b="Tg/uhL+i";
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=IFDigL4vy3b62qjT1WszXB3PDewotHj2dqglzXL17hc=;
        b=Tg/uhL+iL9PuNKj7XqCbh3ZlwnLo3Bkb5j6KENo20u6kFaYzi532JwLfbpnW1eZKEn
         qg/O9uyq8wQk4gj/Lpi0h1MpOw3w9F5BoCTyMcJdkPEwqLRDn/s6v2Metm2m9kCUBo40
         xGWjB/G5W4hGI6GA+FOM2MkB8IrBmZciapsN0KRQaX3C/Vg3EdL8wOnroO77kkmOlL79
         mClDpnY4zoMtcRhJr0uE22Wdfo+yAkT8PNyQGB3TEaidmVa2qs5YWFnbdgSrcFEHmPyw
         yjNiLnvfO8k23ResCBgbXP/gSUZgTBmozNcdxSAYu3Ju0S0ckgmdJ1e9/fCZptLcwZkE
         WrWg==
X-Google-Smtp-Source: APXvYqxLR+/UiDQosNM49+jAIr4tIfd9cSPCVBqomYavVwUMuZ0jfVhYTiMeBZXpDB37wwwcRWjQrQ==
X-Received: by 2002:a17:906:6056:: with SMTP id p22mr7266053ejj.171.1560334145847;
        Wed, 12 Jun 2019 03:09:05 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id c8sm2674841ejm.55.2019.06.12.03.09.05
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Jun 2019 03:09:05 -0700 (PDT)
Received: by box.localdomain (Postfix, from userid 1000)
	id 1914A102306; Wed, 12 Jun 2019 13:09:06 +0300 (+03)
Date: Wed, 12 Jun 2019 13:09:06 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: ktkhai@virtuozzo.com, kirill.shutemov@linux.intel.com,
	hannes@cmpxchg.org, mhocko@suse.com, hughd@google.com,
	shakeelb@google.com, rientjes@google.com, akpm@linux-foundation.org,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 2/4] mm: thp: make deferred split shrinker memcg aware
Message-ID: <20190612100906.xllp2bfgmadvbh2q@box>
References: <1559887659-23121-1-git-send-email-yang.shi@linux.alibaba.com>
 <1559887659-23121-3-git-send-email-yang.shi@linux.alibaba.com>
 <20190612024747.f5nsol7ntvubjckq@box>
 <ace52062-e6be-a3f2-7ef1-d8612f3a76f9@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ace52062-e6be-a3f2-7ef1-d8612f3a76f9@linux.alibaba.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 11, 2019 at 10:06:36PM -0700, Yang Shi wrote:
> 
> 
> On 6/11/19 7:47 PM, Kirill A. Shutemov wrote:
> > On Fri, Jun 07, 2019 at 02:07:37PM +0800, Yang Shi wrote:
> > > +	/*
> > > +	 * The THP may be not on LRU at this point, e.g. the old page of
> > > +	 * NUMA migration.  And PageTransHuge is not enough to distinguish
> > > +	 * with other compound page, e.g. skb, THP destructor is not used
> > > +	 * anymore and will be removed, so the compound order sounds like
> > > +	 * the only choice here.
> > > +	 */
> > > +	if (PageTransHuge(page) && compound_order(page) == HPAGE_PMD_ORDER) {
> > What happens if the page is the same order as THP is not THP? Why removing
> 
> It may corrupt the deferred split queue since it is never added into the
> list, but deleted here.
> 
> > of destructor is required?
> 
> Due to the change to free_transhuge_page() (extracted deferred split queue
> manipulation and moved before memcg uncharge since page->mem_cgroup is
> needed), it just calls free_compound_page(). So, it sounds pointless to
> still keep THP specific destructor.
> 
> It looks there is not a good way to tell if the compound page is THP in
> free_page path or not, we may keep the destructor just for this?

Other option would be to move mem_cgroup_uncharge(page); from
__page_cache_release() to destructors. Destructors will be able to
call it as it fits.

-- 
 Kirill A. Shutemov

