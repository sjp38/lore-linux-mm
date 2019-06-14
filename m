Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 04FBAC31E44
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 11:47:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AE5662082C
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 11:47:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="Yz3VHco4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AE5662082C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4B5AE6B000A; Fri, 14 Jun 2019 07:47:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 467406B000D; Fri, 14 Jun 2019 07:47:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2E1516B000E; Fri, 14 Jun 2019 07:47:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0E04B6B000A
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 07:47:40 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id y13so2449322iol.6
        for <linux-mm@kvack.org>; Fri, 14 Jun 2019 04:47:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=h/RkmMY6lU3xp3EMTfM5htXXlyGM/FqAFdB3EA1Y/ks=;
        b=WmEMBKfNpe8z3seMUOILRjhFfNIYdEN175I6qPIkNkHP1mGvh70ri2N4LGGWYyZB0i
         FOtGtQusECu3kWsJ/fw4g7m0hKmTmwW2F6OyUh/qPkrCSmg6gV8q+8jZREY16yBQfzGf
         C7s2zZgTKkggp83ERye2n2gfznwDqsPPnt/suD/EYmmPZyj+KCxlWXZa1WRJcv3Y8DSk
         P8ssWsPYtRIOJHKEPaIFWrVmI5Nr9paFX9ki+f6vcJGQHBHBUnQ4+v4mN+BkheIAVD/M
         pVW6KWItL/TFdhwgyTP6iVO9szWgZPoeQRy9AoC25M/CPMJLvYXjUkdutnll7A9EOuj9
         FR/g==
X-Gm-Message-State: APjAAAU7rWiSffuDo9DcZR6814yfZoX15iMvHPRT2B5bQfXiDrLmiziC
	R9OGgmRnBTwAhrecpyYMnwZSULdvOtOjdxqo2ymvF2n+7LbvEsbKYi2foiS8zGIcz5wDmrA3tye
	C70nxdQBbCD9Ud2A32WG7hrbxE9wWgx9PiOfMt/mP9U/C94hftj8AO4toSW3GQkr4fA==
X-Received: by 2002:a02:84e6:: with SMTP id f93mr31738486jai.73.1560512859751;
        Fri, 14 Jun 2019 04:47:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxj6FHoaODvps4i1pvoxiw5K6S4GZ/ONKsicihX517F7fy+wkNhXjnDrv9DgGNGyzyFZehK
X-Received: by 2002:a02:84e6:: with SMTP id f93mr31738436jai.73.1560512859059;
        Fri, 14 Jun 2019 04:47:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560512859; cv=none;
        d=google.com; s=arc-20160816;
        b=vEs7hrpAhdwxnZ+XDWjG0LncBTiOgXNnk29N1KPVPoc0okQTWEJ8kGJEfNpRSP9foM
         mRFzbe3lSw75PFoUrrVK6uErcm9CKntl8exbmSRYKtJBa5g3BRAbeBr8ETq3im55/ecQ
         zvgzY+0ZWFqo+q+R2s6WfiQg2X2OWkX1qGA7yrKIho4haAyh/k5iLtm7nHhDk1EQDYhu
         j/CvSWTlxhAVHlUrgTm3g9ouw/KIVX8Z/++wtKKhT3qWV8wp9+QXUvUiAbHPh/nMmGgO
         uqDrEEmxnHBCpT9dfO497v1khUN+eDyQL53pGACxQbos7XbEQJT5DYEX0sg3SQqln/Bp
         CCqQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=h/RkmMY6lU3xp3EMTfM5htXXlyGM/FqAFdB3EA1Y/ks=;
        b=eGeKVuQjx1Qcz1zl8IfLsWEn8uVAaaVGXG+PM51yC/1MNBAA8Cn0bRU1oqlBecI5jO
         q+R2wsC8V1y5Kbb3K4sbgQl09+wBRQy+uo1dpW8h4ug3gvgQz8SdPu6cQnB7yK+FXUKM
         9iM3jqYbSEzxgbc2ILz9xdSO5RIaGMb5uNZ4Pjgd8Rat3bk46WyAMDMotu2D8Xp0SfmY
         ksJ79znZmFE7z+CTfen3MiJw1YOnPnWxQTnSB5HY9Uy21PtWkGXRAOanhY8+oXQRZOdi
         ABhJcs6C+XodRYfgtdh2BFjAASi3/Ukyz1yU6p8cEQnnvG0G16Dl0w+EZQarpMV7v6pV
         i+Zw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=Yz3VHco4;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id f8si2666601iok.62.2019.06.14.04.47.38
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 14 Jun 2019 04:47:39 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=Yz3VHco4;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=In-Reply-To:Content-Type:MIME-Version:
	References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=h/RkmMY6lU3xp3EMTfM5htXXlyGM/FqAFdB3EA1Y/ks=; b=Yz3VHco4uNAMcgPZbDG6qh7er
	eyVNjQVW5bYjEJukcYBJwivb4xqu5hgxItRTEdKs4buH3AXHlovCUsFgM4epbNxV0iY5ba0uMHMZ8
	CWCiINOZTNYV1VwpSzAcQDDfhTRSGKCFsJEhqtW97Rtrkv8ZjURnPLimYnmBvbqSPmHCgJ1bTkjjR
	hbIq33RYkrsI5a/5ZgK75sZ9yi5LdcQI1hG6R04omFQLTtocKREkBmYuc2ZRr/ixVqQkcqsXUwbTS
	KI8WzFSOe2tswjzNVG9vd58kOfnWxDuMA8G+6hbedadtDIlIEo/qgiEU3fgjKgKRxFfoCdLXeH/Dj
	LrbNR3Ebg==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by merlin.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hbkg9-0007LF-S6; Fri, 14 Jun 2019 11:47:34 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id 9FD0E2013F74A; Fri, 14 Jun 2019 13:47:32 +0200 (CEST)
Date: Fri, 14 Jun 2019 13:47:32 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org,
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
Subject: Re: [PATCH, RFC 45/62] mm: Add the encrypt_mprotect() system call
 for MKTME
Message-ID: <20190614114732.GE3436@hirez.programming.kicks-ass.net>
References: <20190508144422.13171-1-kirill.shutemov@linux.intel.com>
 <20190508144422.13171-46-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190508144422.13171-46-kirill.shutemov@linux.intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 08, 2019 at 05:44:05PM +0300, Kirill A. Shutemov wrote:
> diff --git a/fs/exec.c b/fs/exec.c
> index 2e0033348d8e..695c121b34b3 100644
> --- a/fs/exec.c
> +++ b/fs/exec.c
> @@ -755,8 +755,8 @@ int setup_arg_pages(struct linux_binprm *bprm,
>  	vm_flags |= mm->def_flags;
>  	vm_flags |= VM_STACK_INCOMPLETE_SETUP;
>  
> -	ret = mprotect_fixup(vma, &prev, vma->vm_start, vma->vm_end,
> -			vm_flags);
> +	ret = mprotect_fixup(vma, &prev, vma->vm_start, vma->vm_end, vm_flags,
> +			     -1);

You added a nice NO_KEY helper a few patches back, maybe use it?

>  	if (ret)
>  		goto out_unlock;
>  	BUG_ON(prev != vma);

