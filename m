Return-Path: <SRS0=IoHm=TO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DATE_IN_PAST_96_XX,
	DKIM_SIGNED,DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4A850C04AB4
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 13:16:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0B4E420879
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 13:16:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="P1l8g6qK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0B4E420879
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A92796B0003; Tue, 14 May 2019 09:16:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A43016B0006; Tue, 14 May 2019 09:16:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9574C6B0007; Tue, 14 May 2019 09:16:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 488FF6B0003
	for <linux-mm@kvack.org>; Tue, 14 May 2019 09:16:56 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id y12so23259283ede.19
        for <linux-mm@kvack.org>; Tue, 14 May 2019 06:16:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=DMMeXloYNXsHa1DqFGLBzPdlsVj69m1EQu9H4CY/upE=;
        b=USXlQ3dFadNikf7D+KpuhDIs84nnwJRX0odXC6OvbtILT9IBiydqXMfXTr5cotCpvf
         SBTON6Wet22Zo58bFbP8qpIz7Q5wBPlaco4x5DPMq6RbNkcsx3srbzsSdqrPr6mW8n65
         qy0/5ZJnD1Ah5mdJ03Lefaws1GUX13TKgaUqY5wjH81l7hQ1NCfG0S8RzVK0RyUvteo2
         DRiTaowW8btFjQaRZaatGc7P3PlF/lmVgkN8Un5jIyy2ARD1ozSDVS0xKwFlW6yXsNB5
         fIGrsXahIO3hSmE6vhP3WccgWJW7OdjqtaMBEGQ3eJ9wBkuxB5YlnWNd56hKI0Ri87aJ
         VGhg==
X-Gm-Message-State: APjAAAXmlFN3eIy7e58EWv4dTZxgprIoRxbFlaxQ4JjF+KSLO87EMPXC
	XgUEqyVysjh9PPvPiWKRsYWN0dOYsGLUgKoKrd04PfC9Ngxwc33F12Ez+DzbW9hm2J4p/Dnlqv0
	/4eAGXOq7IXw5QKodwNaCgnsIFQO3TgUj9F79FmfNHjZ9xwQ1fe+5OaIsMBU764xNdg==
X-Received: by 2002:a50:ad18:: with SMTP id y24mr36606105edc.64.1557839815725;
        Tue, 14 May 2019 06:16:55 -0700 (PDT)
X-Received: by 2002:a50:ad18:: with SMTP id y24mr36606026edc.64.1557839815044;
        Tue, 14 May 2019 06:16:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557839815; cv=none;
        d=google.com; s=arc-20160816;
        b=qOzpQeXbsGKi0vDt1q4+vZ9psK/azyJObHS6q7v6S0XWOBF8nvLiqx4fTNfIgLTc0D
         6t4pnBCE48PpuQErYLNqQauzNUfciHqTn4iilHd42vrToLHlToApwKrKWK3yBOc26yzX
         41ZJuy6pdwv5ZaOGzKc/V1YuGaxhRTgU4nj9WVAlswq7VVU6Sl0zz9a864njlgocekPV
         vTIhvaL4JOChINrLFTphGfr8j0ONN0N238jCg8wNRvECJh7SiuISNz5mWrgD3FexBRN0
         MbqMxpWFO+NSxtpAkbHp3bGCSlhT3SsevKu/p6+ec/FjXv0kKCLUBld6rBa7XgVA1i+t
         A8nQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=DMMeXloYNXsHa1DqFGLBzPdlsVj69m1EQu9H4CY/upE=;
        b=u2bPXewvPotXhkEyoDYXW/gk0bCrgj4Wfrs+iTVTdsPfHqBDAIMjzrRDDVgMuPcvZX
         jUO3ZcXLAx+JwVNJ26nJbizBkk6Twtq/hiYJVN9gnzQVZF4QlccVvks8q8+7MK+bMhJJ
         BshNB6B783yiwpYxWqSkVyl535LiOjHfJsMqtu2p3LxIWNv7HHi22Mel6x7zN5Mfl9LU
         PEOKrZ6yQHfxqXfNFPSrLBwvyg/Gj+AaYwzvcIDngzXLOgyw3kgz7cj7bZ1y2hIWwt6T
         Zo8ZNIgUOvp4pd2L3AYK22MciPQo6cdNu7uXDv3ivqEUtE1IXJHpBmczqtFkydNuoJ+F
         QJAw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=P1l8g6qK;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id kb22sor5195938ejb.13.2019.05.14.06.16.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 14 May 2019 06:16:55 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=P1l8g6qK;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=DMMeXloYNXsHa1DqFGLBzPdlsVj69m1EQu9H4CY/upE=;
        b=P1l8g6qKkTpvazZNgEG789rkpAkJMQJm4pk9hctUQ9h89W3IgrBs/KgHa9Fb1zxnui
         W2330iqUBIoLjWZonCco2dtId9Kl0phvHqldzxfBltKdhLYDyC8uIpkf6tp+V0iq1BxG
         svfnDJZitgICCRUBqnuga1FDe1lrbVNPDRkApVCLDevZc5yyQ5IHQ/2mroPM7Px/vA6L
         jfpggbUFC/muL2k99gv4rjOa5CHBlXDxTdKQWyeLx59LpKKfoLR/fJpJpksMCvZjcWG6
         aQpPgIq0slG8CEKkRYj/mcq4ezesDPUx/0uVZdUBfaVquoDbOmPJncORKkQppyUesrkM
         HJRg==
X-Google-Smtp-Source: APXvYqwNO1ewBQCQqon8r61mllDoNkAvufxo8spaxP/gb25hNZVSeAfxaDnzlIBOfR5Vb1gsJ1htDw==
X-Received: by 2002:a17:906:3553:: with SMTP id s19mr7437608eja.204.1557839814632;
        Tue, 14 May 2019 06:16:54 -0700 (PDT)
Received: from box.localdomain (mm-137-212-121-178.mgts.dynamic.pppoe.byfly.by. [178.121.212.137])
        by smtp.gmail.com with ESMTPSA id v15sm351133ejj.23.2019.05.14.06.16.53
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 May 2019 06:16:53 -0700 (PDT)
Received: by box.localdomain (Postfix, from userid 1000)
	id 01D1910015E; Thu,  9 May 2019 14:07:55 +0300 (+03)
Date: Thu, 9 May 2019 14:07:55 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org
Subject: Re: [RFC 00/11] Remove 'order' argument from many mm functions
Message-ID: <20190509110755.v4dzyophpaoinqhr@box>
References: <20190507040609.21746-1-willy@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190507040609.21746-1-willy@infradead.org>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 06, 2019 at 09:05:58PM -0700, Matthew Wilcox wrote:
> From: "Matthew Wilcox (Oracle)" <willy@infradead.org>
> 
> It's possible to save a few hundred bytes from the kernel text by moving
> the 'order' argument into the GFP flags.  I had the idea while I was
> playing with THP pagecache (notably, I didn't want to add an 'order'
> parameter to pagecache_get_page())
> 
> What I got for a -tiny config for page_alloc.o (with a tinyconfig,
> x86-32) after each step:
> 
>    text	   data	    bss	    dec	    hex	filename
>   21462	    349	     44	  21855	   555f	1.o
>   21447	    349	     44	  21840	   5550	2.o
>   21415	    349	     44	  21808	   5530	3.o
>   21399	    349	     44	  21792	   5520	4.o
>   21399	    349	     44	  21792	   5520	5.o
>   21367	    349	     44	  21760	   5500	6.o
>   21303	    349	     44	  21696	   54c0	7.o
>   21303	    349	     44	  21696	   54c0	8.o
>   21303	    349	     44	  21696	   54c0	9.o
>   21303	    349	     44	  21696	   54c0	A.o
>   21303	    349	     44	  21696	   54c0	B.o
> 
> I assure you that the callers all shrink as well.  vmscan.o also
> shrinks, but I didn't keep detailed records.
> 
> Anyway, this is just a quick POC due to me being on an aeroplane for
> most of today.  Maybe we don't want to spend five GFP bits on this.
> Some bits of this could be pulled out and applied even if we don't want
> to go for the main objective.  eg rmqueue_pcplist() doesn't use its
> gfp_flags argument.

I like the idea. But I'm somewhat worried about running out of bits in
gfp_t. Is there anything preventing us to bump gfp_t to u64 in the future?

