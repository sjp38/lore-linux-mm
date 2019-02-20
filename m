Return-Path: <SRS0=8949=Q3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 52E90C43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 14:52:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EEBBF2146E
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 14:52:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EEBBF2146E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=kernel.crashing.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 84A318E001E; Wed, 20 Feb 2019 09:52:01 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7F9B08E0002; Wed, 20 Feb 2019 09:52:01 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 70FBC8E001E; Wed, 20 Feb 2019 09:52:01 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id 477BF8E0002
	for <linux-mm@kvack.org>; Wed, 20 Feb 2019 09:52:01 -0500 (EST)
Received: by mail-it1-f198.google.com with SMTP id i63so11172077itb.0
        for <linux-mm@kvack.org>; Wed, 20 Feb 2019 06:52:01 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=la6SAN/rh+9VRfJ8pRNH9BXqosPKB/OETVQHuy06bnI=;
        b=udz0BAArZ9JHoybX4i1CdHzim6c0FW4hjA2goW512dKhje50xWA8TiYPdADVPvDbtn
         2GGq8rG3HldLjwubJZFJ9W5k8Vaxf2fk/mEvw0WvyO2HRK66zED9BlkwYYjT8WcDcZY1
         Y779muNglqHN+IOJ8owibYQXZ0BcHXTiXglKT3HU7AFI8ATFfU0T7Zfucw9FmzbRug4N
         wAZ+P1Z/etUtF/sezhYBt8qbl72n1TukXDZRfF7KGkJyEym4/RY+3JjXgKQtAeqdmOJ/
         U1Ga/LGWN5RMgFgOYFK9Ahf8VqClLUNvjgCvh9D7FH2xcnceHablPnfZ4zW0+7m+SDcB
         RzSw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of segher@kernel.crashing.org designates 63.228.1.57 as permitted sender) smtp.mailfrom=segher@kernel.crashing.org
X-Gm-Message-State: AHQUAuaRq6Mw1QEUGoGYeoheMBB8iOsfAq8XzMKP7kU5r1TQV/bnaBL5
	GbsZYKB0V/Ugk1ggbSfz1Bidtiio04sPWPl8KRWxIYWeQKstTKMrcv0g8RzEWO2ZQa0DUM+u92j
	teDeYATL6PHFAAzWVHs6YKnhc63OhmGpOMs4OrLZlrqs5WJ64cqXp4W+++0J3eQAZqQ==
X-Received: by 2002:a24:5015:: with SMTP id m21mr4838726itb.2.1550674321010;
        Wed, 20 Feb 2019 06:52:01 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ib+Kf5EyiGoE1Nm4ZKHzdVV6o2Al6h2eP+By+Z0b3Tj6/+YN76smvkB5XIOdFYcQw00P+N1
X-Received: by 2002:a24:5015:: with SMTP id m21mr4838684itb.2.1550674320246;
        Wed, 20 Feb 2019 06:52:00 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550674320; cv=none;
        d=google.com; s=arc-20160816;
        b=epvN1d7aryFv0aIIs44qxWOaltq9O3+AMTVRzUAKrnUt2Zb5CrqONnMhZ4Gusb9lJs
         exdQR3aIimMGvvpwG+PMTGErfOqGBVmmX7iFWeXNwreUJ7SxUF7iR/iNYdZQM4bzqZdW
         d2X9dJAMLY4iCXa1Fv9EeoJSTg0YlxuCpPOYqyR7eQtqoAivQz/2QGJ/UlDr/pUVpFLQ
         QE6TzsiFqR4N6CIQ2suF3O+ua+hiwt1PqwNLJNZFTZfLbPsWRs5VXDRWkH4E0lDyvRHr
         l3KyFMXvjmOrPqXkVOlIFICRPtP2UY5pW4kMWorfjLMxC0eOpggebrPT2CYnzbvPT1AX
         fAaA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=la6SAN/rh+9VRfJ8pRNH9BXqosPKB/OETVQHuy06bnI=;
        b=ZDflbEick/+Oq8L9hqPEqZJh56221eAKrzvWgwM4V9BjEXozbPb/9NRbbJgq1paege
         ksSE7UcS29P7qqX+WNHNPEcCrZjXXdSlmeZIu3lcwVQ7I/KzZs0Hh+Qqy8cU0R5KjE+0
         m52Yl58kO1sfVYEdCTTO85NVLwghrdAVC9Va0SuvH9HC5kr4dW8Xx+y5G8GAUElIuj7X
         4Tjx/zqaEJK82W//MIOO9GGVbuJHL5TsBTOk0pItbWBzi5Y2IPUcjIbtDoFXYcPUJA+u
         PERWVxtAhLMjtn8w8SnBYNdEcnu3djcK9BJSwRetCo4gDAfYMqFT11sYJRPmTf4CJKOl
         HaEw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of segher@kernel.crashing.org designates 63.228.1.57 as permitted sender) smtp.mailfrom=segher@kernel.crashing.org
Received: from gate.crashing.org (gate.crashing.org. [63.228.1.57])
        by mx.google.com with ESMTPS id p16si2974246itk.125.2019.02.20.06.51.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 20 Feb 2019 06:52:00 -0800 (PST)
Received-SPF: pass (google.com: domain of segher@kernel.crashing.org designates 63.228.1.57 as permitted sender) client-ip=63.228.1.57;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of segher@kernel.crashing.org designates 63.228.1.57 as permitted sender) smtp.mailfrom=segher@kernel.crashing.org
Received: from gate.crashing.org (localhost.localdomain [127.0.0.1])
	by gate.crashing.org (8.14.1/8.14.1) with ESMTP id x1KEpYL4023289;
	Wed, 20 Feb 2019 08:51:34 -0600
Received: (from segher@localhost)
	by gate.crashing.org (8.14.1/8.14.1/Submit) id x1KEpPRx023288;
	Wed, 20 Feb 2019 08:51:25 -0600
X-Authentication-Warning: gate.crashing.org: segher set sender to segher@kernel.crashing.org using -f
Date: Wed, 20 Feb 2019 08:51:25 -0600
From: Segher Boessenkool <segher@kernel.crashing.org>
To: Michael Ellerman <mpe@ellerman.id.au>
Cc: Balbir Singh <bsingharora@gmail.com>, erhard_f@mailbox.org, jack@suse.cz,
        linuxppc-dev@ozlabs.org, linux-kernel@vger.kernel.org,
        linux-mm@kvack.org, aneesh.kumar@linux.vnet.ibm.com
Subject: Re: [PATCH] powerpc/64s: Fix possible corruption on big endian due to pgd/pud_present()
Message-ID: <20190220145112.GW14180@gate.crashing.org>
References: <20190214062339.7139-1-mpe@ellerman.id.au> <20190216105511.GA31125@350D> <20190216142206.GE14180@gate.crashing.org> <20190217062333.GC31125@350D> <87ef86dd9v.fsf@concordia.ellerman.id.au> <20190217215556.GH31125@350D> <87imxhrkdt.fsf@concordia.ellerman.id.au> <20190219201539.GT14180@gate.crashing.org> <87sgwi7lo1.fsf@concordia.ellerman.id.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87sgwi7lo1.fsf@concordia.ellerman.id.au>
User-Agent: Mutt/1.4.2.3i
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 20, 2019 at 10:18:38PM +1100, Michael Ellerman wrote:
> Segher Boessenkool <segher@kernel.crashing.org> writes:
> > On Mon, Feb 18, 2019 at 11:49:18AM +1100, Michael Ellerman wrote:
> >> Balbir Singh <bsingharora@gmail.com> writes:
> >> > Fair enough, my point was that the compiler can help out. I'll see what
> >> > -Wconversion finds on my local build :)
> >> 
> >> I get about 43MB of warnings here :)
> >
> > Yes, -Wconversion complains about a lot of things that are idiomatic C.
> > There is a reason -Wconversion is not in -Wall or -Wextra.
> 
> Actually a lot of those go away when I add -Wno-sign-conversion.
> 
> And what's left seems mostly reasonable, they all indicate the
> possibility of a bug I think.
> 
> In fact this works and would have caught the bug:
> 
> diff --git a/arch/powerpc/include/asm/book3s/64/pgtable.h b/arch/powerpc/include/asm/book3s/64/pgtable.h
> index d8c8d7c9df15..3114e3f368e2 100644
> --- a/arch/powerpc/include/asm/book3s/64/pgtable.h
> +++ b/arch/powerpc/include/asm/book3s/64/pgtable.h
> @@ -904,7 +904,12 @@ static inline int pud_none(pud_t pud)
>  
>  static inline int pud_present(pud_t pud)
>  {
> +	__diag_push();
> +	__diag_warn(GCC, 8, "-Wconversion", "ulong -> int");
> +
>  	return !!(pud_raw(pud) & cpu_to_be64(_PAGE_PRESENT));
> +
> +	__diag_pop();
>  }
>  
>  extern struct page *pud_page(pud_t pud);
> 
> 
> 
> Obviously we're not going to instrument every function like that. But we
> could start instrumenting particular files.

So you want to instrument the functions that you know are buggy, using some
weird incantations to catch only those errors you already know about?

(I am worried this does not scale, in many dimensions).


Segher

