Return-Path: <SRS0=On+J=TX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F2990C282DD
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 21:44:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AF848217D9
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 21:44:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="cdxTmVIm"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AF848217D9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4D5966B0006; Thu, 23 May 2019 17:44:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 45EB76B0007; Thu, 23 May 2019 17:44:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2FFC46B0266; Thu, 23 May 2019 17:44:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id E89656B0006
	for <linux-mm@kvack.org>; Thu, 23 May 2019 17:44:04 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id c7so5150969pfp.14
        for <linux-mm@kvack.org>; Thu, 23 May 2019 14:44:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=LWF1ZSU5v2KUo/wbBrAOUpnVrOtjAGamVdAm8iRVjtg=;
        b=Y1gkvfQIN5JXeMIdnLX5DpRKMtH4LiqxXMcipTSX78tYYEn0ZMpmcgtp7/ELUBRtIp
         J0Ce9H0GtzLtrasukpSfmlzagWL2M+gTP7im9oRTY9SzITO6WvC/vfKifcxDYEvwm6XT
         m8CQCAvRp8LZAYNtTb7K5Nr4kysd8POhhdyqAbCNSBRfCImOhPsd16s8y+cRmcWFjZWp
         yJJkZZecNtb9yErUeTLWfNGHSc9PiEgFn9FzucsioBHkw6X5LHSE/BVGcRovxsGhhJ26
         WCfNIJ6A0DOB3uSKDiytpDb+e/dVKohREnZdNuTWsjF+if8ZjvOQMz0EVaYeGWexDFxs
         4xXw==
X-Gm-Message-State: APjAAAXzBJcC81X6yy0ZhPLgPz4DmBVsQ+myhqgziVBAeSok42QTYpBO
	nx8uv+PgYpfH9HXMK3r2iiyjcOKIoHro/ha2ORAbEXKx8jz9ACsRlR0TGQK+/usg6Ad3Yv7SrnF
	ADnYz2jvdpopL5B+Zpv+iUaahEnpCksw1DYMNeI4WFwG6QeBsRm/KLl5ohN9ZyhAtLw==
X-Received: by 2002:a62:1483:: with SMTP id 125mr78212939pfu.137.1558647844625;
        Thu, 23 May 2019 14:44:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyP0pyL6zi477MnqTWmNAiyeZNblmgFBZ7vxO2yfijyHiDmbawjRWOUcECNXbnaKMV3xwW2
X-Received: by 2002:a62:1483:: with SMTP id 125mr78212863pfu.137.1558647844017;
        Thu, 23 May 2019 14:44:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558647844; cv=none;
        d=google.com; s=arc-20160816;
        b=ZycULAeL9u0tUmrF2CzHO+RccXM/eXfZwCIMAN1vMYQucHj5yqAOJsZTz+sJZUJu1J
         G4mu8CFzDWRFNWqxkQVYT2Cg85x+nq3pCfGORbphfFpIF2Ad5jjKXtjUftbhKY6SWdqu
         UTztIVt8BgA5rumjezANB7CayuT1NzVKuiigeC3s8Z8lV+8o8wi0fVBs1REPZYIX1oR9
         8UgdAWYBhXHx2fPS8WTCGAabfnv7Y5BWtOV6db6k6ZEJiEUsMYblEz8KyXajZs3Bi/cr
         I/tvxd9g8NP+JjDHUZ+tV4dLkgypmPt5vbK7HRQUUMIo17FIpx91QKH4MZ0vHHpKFDY+
         TllQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=LWF1ZSU5v2KUo/wbBrAOUpnVrOtjAGamVdAm8iRVjtg=;
        b=h+Hjbuj8XlChsQfnh7KpDVIWKgn9GOdv4Lh74NGbwrQfnBPqLU3Kqk7cUc8cBr3iOa
         Y6DPYvJWzSAR1F5q7rac135hS8JWamSiC5Pvypd32NJ5i4/X46Qz5kJaUPRHZCgPA2f6
         AK3OewtQoiAT0MVRFEDxJz2c5ahE6N4jqc98KXNutUqy+E5UmULvvV4rvuJqRwTyhIE+
         pRuzo7UDrbWiYQAjTo9W2Pt5COX9NVi8wQ0v/ITdeEDZpHMma12INbexKCFQYTiglC0f
         EzVG34prjAOPLLNQfxuvjQyETet7mp5xQHlGqmmyyGtYSSuKJt3StdIeQVKp9WcexAEN
         hBSw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=cdxTmVIm;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id p24si1119597plr.269.2019.05.23.14.44.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 23 May 2019 14:44:03 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=cdxTmVIm;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=LWF1ZSU5v2KUo/wbBrAOUpnVrOtjAGamVdAm8iRVjtg=; b=cdxTmVImkU5LRvZgguafFIAsl
	b+DTSLP+4ymunPD8+21iptVKKE/2QArNd/sunmjs48nbqGHr3WFu7f27Z1qmYj8R4sAaLTO40/S6p
	hsjUI+Gec5wBU/WEEjXikZmvF2S0yOz0nTUcNeW+d+yih+u7syVuhAgn9duj9IM1RBBpjUtBBWcLG
	tt7XiNTcEkJwistjkEjvoFfBiw8Fkxq+CVnvtiG8N0HXlVB9cQoTUwExWkwW8EJMs5o5jLWjN+SnT
	jMqoT693wguEYpbapj2lHbWMgG4G21Fjsm/QJsbyH/uFvkKlEFiBBVapYgLwbEDtzwXdpG7LS30qH
	U1vD/pd+Q==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hTvVK-00033b-L8; Thu, 23 May 2019 21:44:02 +0000
Date: Thu, 23 May 2019 14:44:02 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Kirill Tkhai <ktkhai@virtuozzo.com>, linux-mm@kvack.org
Subject: Re: [PATCH] mm: Introduce page_size()
Message-ID: <20190523214402.GA1075@bombadil.infradead.org>
References: <20190510181242.24580-1-willy@infradead.org>
 <eb4db346-fe5f-5b3e-1a7b-d92aee03332c@virtuozzo.com>
 <20190522130318.4ad4dda1169e652528ecd7af@linux-foundation.org>
 <20190523015511.GD6738@bombadil.infradead.org>
 <20190523143315.9191b62231fc57942b490079@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190523143315.9191b62231fc57942b490079@linux-foundation.org>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 23, 2019 at 02:33:15PM -0700, Andrew Morton wrote:
> On Wed, 22 May 2019 18:55:11 -0700 Matthew Wilcox <willy@infradead.org> wrote:
> 
> > > > +	return (unsigned long)PAGE_SIZE << compound_order(page);
> > > > + }
> > > 
> > > Also, I suspect the cast here is unneeded.  Architectures used to
> > > differe in the type of PAGE_SIZE but please tell me that's been fixed
> > > for a lomng time...
> > 
> > It's an unsigned int for most, if not all architectures.  For, eg,
> > PowerPC, a PUD page is larger than 4GB.  So let's just include the cast
> > and not have to worry about undefined semantics screwing us over.
> 
> I think you'll find that PAGE_SIZE is unsigned long on all
> architectures.

arch/openrisc/include/asm/page.h:#define PAGE_SIZE       (1 << PAGE_SHIFT)

The others are a miscellany of different defines, but I think you're
right for every other architecture.

