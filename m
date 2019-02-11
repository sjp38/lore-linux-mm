Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 25C5AC282CE
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 13:47:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D17D1222AA
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 13:47:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="WEPt/Rhg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D17D1222AA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 590D58E00E5; Mon, 11 Feb 2019 08:47:54 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 53F818E00C3; Mon, 11 Feb 2019 08:47:54 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 407698E00E5; Mon, 11 Feb 2019 08:47:54 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id F2FA98E00C3
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 08:47:53 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id p20so9359593plr.22
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 05:47:53 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=Ws/C2hqYk0iRt2PTm35SBSRz42ARtcD8YeknfLTSmcQ=;
        b=FBEal4i1CyGea5pw3+++YZUmHT48Lwy85cG00Ert90i3JqOujZny8K6W+fZlndKwjy
         KPfgF6nanVbU1IKPaHTetEwtAmncKfw2WiiriVpCNr9gNVPxTD3XFBHaRoQgEVBmMVlA
         Mmap+yF2OX0srTzQbbEHVon0tBIVC8P6vmyQglD0YPAYoN9fh1kdrWEIJzg8dPqwnlDW
         HN8sjbCOlTOSYU7szNLM/I9LaipJ43u8wZ6Um5Feq/CspxcOtfxX7dcnzfL4oWcA0v0a
         Di9ePOoC4s9hYslQBdD8+cdTOtU9oQbC/7ZRh7wsRh57ESlDrWuzIcNEOc/lWxoml+nF
         OxoQ==
X-Gm-Message-State: AHQUAuamyLL8/m9ZeNluwFBpr6EtjpuyO9x+8/XXUGr4quHs7qp3cuIG
	VPdwhqHe0Iw8LmfnMBVk3rGCFlLutyaNQ8vAvbWeNXNXNQmgOw4eXkqDfECYp9qLelHfD/6E2H5
	0vOd4tvvOnNj7dQ4DqZBY9ozRdiOwQsSNZHlMT5hGII40x0ClINA5PLWwrDm1zU8GqA==
X-Received: by 2002:a17:902:3283:: with SMTP id z3mr37955971plb.76.1549892873676;
        Mon, 11 Feb 2019 05:47:53 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ib4nQ7Hllp2CqBsNvLtCiZ5nx1KVbZlMGOlmLN0bcecSyQVoMF2cfapmbqvFGiW1RnxLnu/
X-Received: by 2002:a17:902:3283:: with SMTP id z3mr37955932plb.76.1549892873069;
        Mon, 11 Feb 2019 05:47:53 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549892873; cv=none;
        d=google.com; s=arc-20160816;
        b=pTQ4KE7ZMoBXwRA4YnAUaQOMRxB2ECP0McpMCKRYAQvBmGHVPg5avQJ9Rt5mLatN5E
         6kb2xXemRPlQmYrwMNjJkqU46mHsowE0a9KE/MugTn2ZKbh6EDfX1bPgZS5K6M2lNzBT
         OA/Mphh1jh8wXnBIYEXvlo96TfCS+qZ9FswvqUTw4OnBOB9V1XeHNFZHaGyFPV8qjOXT
         JUzLPZVdBty4LHVsaLtABPReBRCkMS4TEaqYsbHleCdLjDUOfFr8teDnpStwkbJ6idxg
         dh3cBERPZgEl7LJpChcWHncewmyPn2tEEqu0tkMSWLiipAo9CLqLG6kHwCEr1FXekmlg
         ov+Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=Ws/C2hqYk0iRt2PTm35SBSRz42ARtcD8YeknfLTSmcQ=;
        b=LqkMMMyeA5FBH7uQzQGqD6B4s1WqqDGQ+Xb+TXQpAj5x28ldyA5xukM+EtnHEl+6TA
         f3FWIpxSHFzka4V/nkLjkLvwH06HlGUtR3hkkVflSFlvs3+QNIdwJ9WqHRSMPFIONibm
         5VTz8ufUP8bu9t+ozqdB25PM1oV7xFlzaS84UiXjW4FRPoEev+WGfZJ8HC1Lv0XlbOCq
         /vwxm1QS9MvlYVGkHTOT98Ux6jxJ2V1KBJYEDa9hwHiXAWvCiJNzpOs1GwFvVLubtYOr
         r1ucuv3eHKQ4PkFeoQsqtybd4QeFdsxLxUx7AOcsmANnZ0X0Q5svChAI80ODzlkSP6G7
         witw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="WEPt/Rhg";
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id l81si3691829pfj.230.2019.02.11.05.47.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 11 Feb 2019 05:47:53 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="WEPt/Rhg";
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=Ws/C2hqYk0iRt2PTm35SBSRz42ARtcD8YeknfLTSmcQ=; b=WEPt/RhgKU3FIaV5Ev/81DgzH
	UQoVtvtDN3m4/VyfHhpBG2fRmCOwkZLeYoyw6v98loraNonK4JcGe8wWuF0qkSPAkT72fS4ZqiPeJ
	+wxYpM/CM9YxU//P662NsBKqqEjBhuPwyEibVYEa2mV79kYs1HVGfCrCd1vXAW8jbNmIIzbyslflj
	/mZLMXBW1UexkZPloEUQZdIRzyjsrduPjuqHHiJHTpHQ1zP8DnVdEz7gn1zx56D9x15jpVdEBA4ZI
	NecWKaQUmolv3P1O+wI6Pz0sTnApZNBgJ8QZlYt4HLbgpQ6vmKNa6R0RWE25A0LpoTpGjFHA8U9aY
	GCuYa06JQ==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1gtBw8-0007aU-5p; Mon, 11 Feb 2019 13:47:52 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id B38F420D0E3CE; Mon, 11 Feb 2019 14:47:50 +0100 (CET)
Date: Mon, 11 Feb 2019 14:47:50 +0100
From: Peter Zijlstra <peterz@infradead.org>
To: Chintan Pandya <chintan.pandya@oneplus.com>
Cc: Linux Upstream <linux.upstream@oneplus.com>,
	"hughd@google.com" <hughd@google.com>,
	"jack@suse.cz" <jack@suse.cz>,
	"mawilcox@microsoft.com" <mawilcox@microsoft.com>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>
Subject: Re: [RFC 2/2] page-flags: Catch the double setter of page flags
Message-ID: <20190211134750.GB32511@hirez.programming.kicks-ass.net>
References: <20190211125337.16099-1-chintan.pandya@oneplus.com>
 <20190211125337.16099-3-chintan.pandya@oneplus.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190211125337.16099-3-chintan.pandya@oneplus.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 11, 2019 at 12:53:55PM +0000, Chintan Pandya wrote:
> Some of the page flags, like PG_locked is not supposed to
> be set twice. Currently, there is no protection around this
> and many callers directly tries to set this bit. Others
> follow trylock_page() which is much safer version of the
> same. But, for performance issues, we may not want to
> implement wait-until-set. So, at least, find out who is
> doing double setting and fix them.
> 
> Change-Id: I1295fcb8527ce4b54d5d11c11287fc7516006cf0
> Signed-off-by: Chintan Pandya <chintan.pandya@oneplus.com>
> ---
>  include/linux/page-flags.h | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
> index a56a9bd4bc6b..e307775c2b4a 100644
> --- a/include/linux/page-flags.h
> +++ b/include/linux/page-flags.h
> @@ -208,7 +208,7 @@ static __always_inline int Page##uname(struct page *page)		\
>  
>  #define SETPAGEFLAG(uname, lname, policy)				\
>  static __always_inline void SetPage##uname(struct page *page)		\
> -	{ set_bit(PG_##lname, &policy(page, 1)->flags); }
> +	{ WARN_ON(test_and_set_bit(PG_##lname, &policy(page, 1)->flags)); }

You forgot to make this depend on CONFIG_DEBUG_VM. Also, I'm not
convinced this is always wrong, inefficient sure, but not wrong in
general.

