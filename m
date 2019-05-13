Return-Path: <SRS0=GvbC=TN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5D6CCC04AA7
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 15:16:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1F152208C3
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 15:16:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="dOoxRqeI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1F152208C3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BB10D6B027E; Mon, 13 May 2019 11:16:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B61016B027F; Mon, 13 May 2019 11:16:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A50C56B0280; Mon, 13 May 2019 11:16:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5CAFB6B027E
	for <linux-mm@kvack.org>; Mon, 13 May 2019 11:16:43 -0400 (EDT)
Received: by mail-wm1-f72.google.com with SMTP id o82so5257246wmb.8
        for <linux-mm@kvack.org>; Mon, 13 May 2019 08:16:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=fZCXLRK6siZkJzRThAZU41Qk9STzd0Ms+LwmndLzT4U=;
        b=Ji8Mv35k8cAixu/xVtI8WoR2H4fBmx2Ow3Ya4YCQ/JFX38jnflG3nfIQMCZzN1+cbc
         zqiuX4ywZsuex8lRo1DXB09LlZhJ9fLT+yquKDBxHsGsiTiuuaRmeylmsg9XWO9P6UAg
         ozi1lFIL6FPg7Bxybk3YbjDNyoZzQjCaUFbc7iFDkKrXqUXmoGsaYZgTEEiWQxIqwUOF
         mXD4A9fZcmLIpVs8YNz36e+CS53v4AxEi8M857qU+TyPijGRQ5Q3ueZL/aDqfmzS4cle
         iphWeq+UKvgzbbLROvBjV1Hy0MvngEdrWpTCt9HXUhUpHa0KwPn8DUaSlMUkDdfrBbDW
         mAqg==
X-Gm-Message-State: APjAAAXOYXnh1yIk+WE4YLNtwj8jmcTt5wfbs3N7d7v70STliwxpDvA1
	CywdeY/m9IPF79553Des6NMdmcRREbn6cIZoJVXU5G3CMBHQ1uerzZezfhyUatxioiQJbDso24l
	N3hiWWvFzKvPNr2l3BCR2LmEWwlsXyafg3wBrpumohYpQvkWleV1XPdSGhXmZ+UZPww==
X-Received: by 2002:a7b:c0d1:: with SMTP id s17mr15431663wmh.124.1557760602931;
        Mon, 13 May 2019 08:16:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx5J2AQM8tCAJiFaXq3qa3DG7Sos4Q7s0jfh2vvannFfvQMOmOGIwt8CW7Opt0RbdewMhR7
X-Received: by 2002:a7b:c0d1:: with SMTP id s17mr15431630wmh.124.1557760602243;
        Mon, 13 May 2019 08:16:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557760602; cv=none;
        d=google.com; s=arc-20160816;
        b=c0aeHDk+oDTPNViWO3tE6/FyQnD6uovC49CoIdimskVT1ZHE3lFZ+aArWW9httSeNl
         HrSC63Fs8429a/0kfdqwIb5pPYLJ1XSYjIp/w0nUhKwpABNuMRoqm+R/KYTpwHKbjEXS
         TF+f8oz0NuEPfN666oUwphQ+uSsfjM+zeqohoSHKdHB3O/yRQIbbjxmG+i31HO/VrUWi
         gFr6RJRek2L8YOyZag/0Fw5pL8AyEgdkyR/SlNQ7vtGAEgpIc0mN8ikuQOeXO5gTdyHc
         OiBlBlq2bNLuw8AVd5RECaZbuflTdPo/urgrXPtpwsUfPxkHA7bApWkGDuXyOmjH7zDT
         hv+A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=fZCXLRK6siZkJzRThAZU41Qk9STzd0Ms+LwmndLzT4U=;
        b=ya0SToerSpV5yUxPe+vYw2fq6KYMiHI+0Ux7Rr2FauOyWLA7hDWa0+2d2DJhSjaaJX
         cnUmKZFnw+hWbJs0smtigcDzsTaF1fTHFJJifZLEcA2UsxhdLv9WhHcGqE87jOB5feOO
         CgPvStJvIV8L/q8WD4oMxSbu0xqxBkauu+DiVOzlREkqkc35avO0muJuwmahU0vPv4uu
         XHSxEKISmGadoUFDKGvlGhuIu+YT1DZHiIDGMxhkirzjygBohQH/jflVTK2p9Bri8XrS
         mgWHzJ5/Hy+YPhOywvED8EzQPfDKnpxs2mQ9NaQ8UDtlcMTIZWBr8AQeU1o+eYN8BEEv
         Mo7Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=dOoxRqeI;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id c14si8556676wmb.11.2019.05.13.08.16.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 13 May 2019 08:16:42 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=dOoxRqeI;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=In-Reply-To:Content-Type:MIME-Version:
	References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=fZCXLRK6siZkJzRThAZU41Qk9STzd0Ms+LwmndLzT4U=; b=dOoxRqeIU0IcG57wCspBazrWD
	09pvLZ3B5B5JIvlkaPW2v9wmDfMD64eHIMMM9VvHovmSQKCVTDs7AE4x5WHR7JayzOyj0JrbYDzto
	ib/qLZIhKW6+9A9vmS6HmBS/La4Q8rd9fYbZQHpxTGe4fty4HDIjEm12v3yGcwPrVPWKPQb5fN8J4
	Sb8DsdDGSKgndaqMp41piHOpX3l/9BQxCbIIi+bigL7I/3SyPyENVxM/pguzcSVXd93Vsm7UtGVx8
	wQyZBWobruR2cR6mtbgUMTPFk/d/d7NZw3IEuj7HoEUIK5wB4IyvT2P1fkqsaxnzVT2JIKk5vnAFX
	I9EMq7JEw==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by merlin.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hQCgx-00083R-0e; Mon, 13 May 2019 15:16:39 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id C83E22029F877; Mon, 13 May 2019 17:16:37 +0200 (CEST)
Date: Mon, 13 May 2019 17:16:37 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Alexandre Chartre <alexandre.chartre@oracle.com>
Cc: pbonzini@redhat.com, rkrcmar@redhat.com, tglx@linutronix.de,
	mingo@redhat.com, bp@alien8.de, hpa@zytor.com,
	dave.hansen@linux.intel.com, luto@kernel.org, kvm@vger.kernel.org,
	x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	konrad.wilk@oracle.com, jan.setjeeilers@oracle.com,
	liran.alon@oracle.com, jwadams@google.com
Subject: Re: [RFC KVM 25/27] kvm/isolation: implement actual KVM isolation
 enter/exit
Message-ID: <20190513151637.GA2589@hirez.programming.kicks-ass.net>
References: <1557758315-12667-1-git-send-email-alexandre.chartre@oracle.com>
 <1557758315-12667-26-git-send-email-alexandre.chartre@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1557758315-12667-26-git-send-email-alexandre.chartre@oracle.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 13, 2019 at 04:38:33PM +0200, Alexandre Chartre wrote:
> diff --git a/arch/x86/mm/tlb.c b/arch/x86/mm/tlb.c
> index a4db7f5..7ad5ad1 100644
> --- a/arch/x86/mm/tlb.c
> +++ b/arch/x86/mm/tlb.c
> @@ -444,6 +444,7 @@ void switch_mm_irqs_off(struct mm_struct *prev, struct mm_struct *next,
>  		switch_ldt(real_prev, next);
>  	}
>  }
> +EXPORT_SYMBOL_GPL(switch_mm_irqs_off);
>  
>  /*
>   * Please ignore the name of this function.  It should be called

NAK

