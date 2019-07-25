Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B636FC76191
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 21:42:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7DAD622BF5
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 21:42:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="e/Yzp6j8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7DAD622BF5
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2BB456B0008; Thu, 25 Jul 2019 17:42:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 26CBE8E0003; Thu, 25 Jul 2019 17:42:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 181DC8E0002; Thu, 25 Jul 2019 17:42:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id D60D56B0008
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 17:42:35 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id e25so31769599pfn.5
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 14:42:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=JNOo0Dhi9UDinqug0uYA1LHheZfDibP+WEcEG6xvIBA=;
        b=WWX8dSQUbCCfxmo6KVBG7o2BxcJVH1Kr1asZH1qE98T7sQzc+WnelvabHXR/6pHTDH
         k6onMR7DrTFs8TeGbm3qvh5FquGJxXjPG8e2PKlnhJZAZwHd0GoiaxsJXwjBdpp9YNKP
         TGXfV4rZ4oBMFGWEnXc2N854UTJt7m83C1YmKqvR1U2mhClMj7V7bJOR/nWiZvxuputN
         737LdzFGtwy8exW4HsQiEwO3a26gBMFrAAsqyHKwXUKpotP+V/GmAURICqK96NvogfA6
         a15YGbL8XFOCwefBWlFHO8enWSFSUzv8lqQt3MNfxraZNC1F5XiwoYv487sVOAsq3FJE
         x8Gg==
X-Gm-Message-State: APjAAAUo7coXG7HR3JLf6cAWniXx5YIhxNI3D2ovM0qeA8igNEnXdE3z
	kJs/sxVtdceuz8ZrVJvmQH5Sh2b5kgY7SJmOlFuUtcYb9fMEC3Ri6/VhDvJMLmQ5nnCsWZs6pRv
	TCQvXbmFg+X2UUqBxXFh8AJ1zHHajJgR0b2ULVafqA8mHzvddFSU09A5moOQQC9UdQw==
X-Received: by 2002:a17:902:aa03:: with SMTP id be3mr92566162plb.240.1564090955432;
        Thu, 25 Jul 2019 14:42:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx8BXqR94xcheEVvuXUMSCFyt27CVZq2NKa6F28SZUM96vz3dbUlcTDu/8oQARc3pNkG9FQ
X-Received: by 2002:a17:902:aa03:: with SMTP id be3mr92566124plb.240.1564090954846;
        Thu, 25 Jul 2019 14:42:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564090954; cv=none;
        d=google.com; s=arc-20160816;
        b=xWSCXK7HH+p9AdvW/6Vx5azC8r0nqFsmJQsB39Qp/07o2YaBD8sQRd/80h/2Xzae5J
         J8Y+2s6MqYBAi1C6TgFQ/ZJ6I/ik85gGxicXoO9lV394o2V5Ujbxpk/Pyo8BBRW/3616
         VVSGwAmrv109WqAsYrKf7HnetKj+jgB2dbniNM9kaL5/GsJMbLcrbhMMnGN+xerOp0ap
         wiwbqV8eTQMTkkVq1zSp1njmb0dL8cvPBYBpHA3nJ5zfexhsoz/v5b4jprCymQpHwLjV
         bM+KabWQlM7jaJdhfCHZUlxWUAz9PMImwQ4e7a4uGySwPrJWaCYCU49jr2zLiKU2Bh6W
         pRew==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=JNOo0Dhi9UDinqug0uYA1LHheZfDibP+WEcEG6xvIBA=;
        b=v9yctW4mtTs8gWBVwZoaH7v6hN+HFVWZA7ui6jTlARb83yh+m8lrskipSYKcaJr+6H
         gXThcoY5mbMCcVEd3UXU/PPNIdHROadI9y3MT7FXSIYHiJVbPb36I3BhGBeuJrz+7NsK
         Fg/77RcyH+NUrV6Z26BQ3aVZXv8Xpin584pdydawVds4VSmidg2knpYGWxlmUW8crnJW
         mGon79VzQyvd4Ye2rhOZvkFoGWfu+sWAV9Y2xWRue5URSPEN6oB0Piocj+2J7vFwa1pT
         IDrNvLVVDMaaKyIwEvRVGcvx5Yj779P4Vv+uw4yUaf56ZSZ3elhrMM6nX9iPJhkfcduN
         6Nsg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="e/Yzp6j8";
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id l4si17297908pjq.69.2019.07.25.14.42.34
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 25 Jul 2019 14:42:34 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="e/Yzp6j8";
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=JNOo0Dhi9UDinqug0uYA1LHheZfDibP+WEcEG6xvIBA=; b=e/Yzp6j8Alk5/730XXwU0FDWq
	rr3okQdzLCE/J4OLyeEPbCRO5XaSEEqvUQNRuRdDTG/W3OlD1FAjSaxvbulJP4bbEv2K/AQ2pdD7U
	C25B6yg420c7m5I/Iv0H7H3aTu60UCDWNz1VIrgdDL7SjaSToKp3xhjFnK0FAT+OdGd8tjn7T0BiL
	FVnp2v5FBeoStt238IAx1keeH1uoGWywMyOzwIoA2i0vmW6dd0U6Kfa62LYSOi7Vnd4DWO1YOgjNg
	0PLrZ06JDUhTYMwDhiWauSPYZcheWxkHZREuSCfc07MneufWREPlpo1Hg9S9UoGbIioPLs5HnL1tq
	WlAQZfXjQ==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hqlVG-0004iU-Tb; Thu, 25 Jul 2019 21:42:22 +0000
Date: Thu, 25 Jul 2019 14:42:22 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Russell King - ARM Linux admin <linux@armlinux.org.uk>
Cc: Anshuman Khandual <anshuman.khandual@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Kees Cook <keescook@chromium.org>,
	Sri Krishna chowdary <schowdary@nvidia.com>,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Masahiro Yamada <yamada.masahiro@socionext.com>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, x86@kernel.org,
	Dave Hansen <dave.hansen@intel.com>, linux-kernel@vger.kernel.org,
	Steven Price <Steven.Price@arm.com>, linux-mm@kvack.org,
	Mark Brown <Mark.Brown@arm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@kernel.org>,
	linux-arm-kernel@lists.infradead.org
Subject: Re: [RFC] mm/pgtable/debug: Add test validating architecture page
 table helpers
Message-ID: <20190725214222.GG30641@bombadil.infradead.org>
References: <1564037723-26676-1-git-send-email-anshuman.khandual@arm.com>
 <1564037723-26676-2-git-send-email-anshuman.khandual@arm.com>
 <20190725143920.GW363@bombadil.infradead.org>
 <20190725213858.GK1330@shell.armlinux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190725213858.GK1330@shell.armlinux.org.uk>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 25, 2019 at 10:38:58PM +0100, Russell King - ARM Linux admin wrote:
> On Thu, Jul 25, 2019 at 07:39:21AM -0700, Matthew Wilcox wrote:
> > But 'page' isn't necessarily PMD-aligned.  I don't think we can rely on
> > architectures doing the right thing if asked to make a PMD for a randomly
> > aligned page.
> > 
> > How about finding the physical address of something like kernel_init(),
> > and using the corresponding pte/pmd/pud/p4d/pgd that encompasses that
> > address?  It's also better to pass in the pfn/page rather than using global
> > variables to communicate to the test functions.
> 
> There are architectures (32-bit ARM) where the kernel is mapped using
> section mappings, and we don't expect the Linux page table walking to
> work for section mappings.

This test doesn't go so far as to insert the PTE/PMD/PUD/... into the
page tables.  It merely needs an appropriately aligned PFN to create a
PTE/PMD/PUD/... from.

