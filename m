Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_2 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6F4CFC433FF
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 16:20:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2EED2206B8
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 16:20:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="Mvpx3v8T"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2EED2206B8
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B37008E0032; Thu,  1 Aug 2019 12:20:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AE7D48E0001; Thu,  1 Aug 2019 12:20:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9D52D8E0032; Thu,  1 Aug 2019 12:20:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7BFCE8E0001
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 12:20:38 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id k125so61598610qkc.12
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 09:20:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:subject:from:to:cc
         :date:in-reply-to:references:mime-version:content-transfer-encoding;
        bh=D5T2Uxf2pvzlQgNSYEF3ht0LNwLAYlgpi5hrr37GkRA=;
        b=afwqNkSYDfUxkF22sflbObvDAu2I0/6rkDHxH8dvYHieCdVPHPnLvQYeq6B8WEbXxm
         fDWkR06yKpfIhaLHhitTPLVze3XQEBWDHjJ/jXPCrMx2chmHVzLNpYGgriNwVAPvSyXs
         kh0wu0+J+xlHjGT+A4qj+k0UqWscBSPX+RYWrlyVZ8rQTZ2WsG70i36fbNE1MFMbzFr/
         3Rhnt7YHNiQUuNwJzHJ+VlC7pMpiES8WU8YIKxW7wCs7ia7wuSvcmzCc1ovy1370Kdg7
         mFUe3uuwQhJ2ozgUKETolqYYgNmgixrlY8BYYgfiqGNUtKZfu3i8+qVKip1PUONkWW52
         7zkQ==
X-Gm-Message-State: APjAAAW8NcMwqFgReb/nQ1ChrrZxH60A76y8hEr81vScJYnFZpwv9upY
	cfyaPu1LZ0jIv7aIalbBdHNKRdGx3eEDacIB69KK/XOevmwJFYfmXRbfPt3XEWc1rf9dn9jB3eG
	2hA/njaoQOV3dA8vWyNfUrZaKUTpttq30ozVkk3GpO6/sbjnBUtY+yLavaqCSvrYJnA==
X-Received: by 2002:a05:620a:125b:: with SMTP id a27mr65926465qkl.112.1564676438221;
        Thu, 01 Aug 2019 09:20:38 -0700 (PDT)
X-Received: by 2002:a05:620a:125b:: with SMTP id a27mr65926414qkl.112.1564676437616;
        Thu, 01 Aug 2019 09:20:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564676437; cv=none;
        d=google.com; s=arc-20160816;
        b=KphHGJmytV1N0NztZG36vIm2lrBjbE0WdGp1DQoOpHOm0hc+xRpD6+14TIjn3wMgM9
         mDGen4nUMRH2vn/AY7a35o7ArRCJjSwZoR4t6WDTIHIIMonoE9qX15PS8eZdysvBanck
         FqkCnpY/gjscDRRToIG2KjQEprYlULqgDpwJfJrMmVE4FcLJm3vvAWqdBXqc0CXvtQgi
         IxcMXm9gKNupJD+7Rkz99rDpAjJiEEdTeb7fxnGuednnSxTGD+Bo8H0tuWFnzf+dnJe+
         6/A+Mi4Tss9hwadQNkfjULrVrEByQBRFYF6SLXQPPqjlKituNiFbLuXlFEiNXIfjYLTY
         AY0Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id:dkim-signature;
        bh=D5T2Uxf2pvzlQgNSYEF3ht0LNwLAYlgpi5hrr37GkRA=;
        b=VrnRFHEjCWpwA0PtvRblVAsiBHr6RxEFW68dhRyFSPUY0pnSLxW0uWsnxP9j5KNQyA
         4zv2qT1hQZ7RCininz4bXKHBoGPk3UfB447LJqg/9EBKQw7B4So3O15wvuLWbGxu53d4
         I6KcYSybYAYoLTrwb9mtQy9vbCJR32GpeV3yTHcptTwOpq+IEeYGJ+2mE1MSS+ZSZQDk
         aE0StwjfjxvvmFINsf7ufFdA71H1ICsqNwzyr4wtGkUfA1yGeuBZTjIxSCafttugvcUW
         Nu46sLUAQaJF9XdHwpHG7vtonIbQBQh6oGIqCIRbhYc6tukVi7Ff/e9T6FWOz8221746
         42rw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=Mvpx3v8T;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l19sor86753044qtr.52.2019.08.01.09.20.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 01 Aug 2019 09:20:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=Mvpx3v8T;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=D5T2Uxf2pvzlQgNSYEF3ht0LNwLAYlgpi5hrr37GkRA=;
        b=Mvpx3v8Tm65xrnLV1EEww37UC+PyVjoVk0+zWXwvZuOSfAQOvUYvAIomjd6kZXE1gm
         fjhkNNRtdDpAu+RewXXHKx7mSV8JMWpKCGvIxwTvHgMK27WN/QZa/a7srPkJ/HxDu3V2
         L4k8BVG8VOyNSVwuZTpgxORfTSMmIcshkYReCcSchZWN5KARvBqEfc8kdMGiQBXUjIUl
         YFrLvqbdBF3FWqokJ5gbVYX2/kk6/jj28S7bgpAlFL6davzgmsWX2aYIDuj7lPw+9n2B
         I/mVkvDLFFDWnvklQinWPZ4RpGz+2EhoWotw4JVe3y5rClcRe4FvA1kWYpnKfD5YbNt0
         DS3A==
X-Google-Smtp-Source: APXvYqzM49uTepjuXeJZkp34ZRE7q5866HZ2LXXYjec4bp0ukiC80b9AapClXJ0hht1pT/TpSFVcmQ==
X-Received: by 2002:ac8:2a99:: with SMTP id b25mr91869588qta.223.1564676437174;
        Thu, 01 Aug 2019 09:20:37 -0700 (PDT)
Received: from dhcp-41-57.bos.redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id 47sm41640083qtw.90.2019.08.01.09.20.35
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Aug 2019 09:20:36 -0700 (PDT)
Message-ID: <1564676434.11067.46.camel@lca.pw>
Subject: Re: [PATCH v2] arm64/mm: fix variable 'tag' set but not used
From: Qian Cai <cai@lca.pw>
To: Matthew Wilcox <willy@infradead.org>
Cc: catalin.marinas@arm.com, will@kernel.org, andreyknvl@google.com, 
	aryabinin@virtuozzo.com, glider@google.com, dvyukov@google.com, 
	linux-arm-kernel@lists.infradead.org, kasan-dev@googlegroups.com, 
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Date: Thu, 01 Aug 2019 12:20:34 -0400
In-Reply-To: <20190801160013.GK4700@bombadil.infradead.org>
References: <1564670825-4050-1-git-send-email-cai@lca.pw>
	 <20190801160013.GK4700@bombadil.infradead.org>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-10.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2019-08-01 at 09:00 -0700, Matthew Wilcox wrote:
> On Thu, Aug 01, 2019 at 10:47:05AM -0400, Qian Cai wrote:
> 
> Given this:
> 
> > -#define __tag_set(addr, tag)	(addr)
> > +static inline const void *__tag_set(const void *addr, u8 tag)
> > +{
> > +	return addr;
> > +}
> > +
> >  #define __tag_reset(addr)	(addr)
> >  #define __tag_get(addr)		0
> >  #endif
> > @@ -301,8 +305,8 @@ static inline void *phys_to_virt(phys_addr_t x)
> >  #define page_to_virt(page)	({					
> > \
> >  	unsigned long __addr =						
> > \
> >  		((__page_to_voff(page)) | PAGE_OFFSET);			
> > \
> > -	unsigned long __addr_tag =					\
> > -		 __tag_set(__addr, page_kasan_tag(page));		\
> > +	const void *__addr_tag =					\
> > +		__tag_set((void *)__addr, page_kasan_tag(page));	\
> >  	((void *)__addr_tag);						
> > \
> >  })
> 
> Can't you simplify that macro to:
> 
>  #define page_to_virt(page)	({					\
>  	unsigned long __addr =						
> \
>  		((__page_to_voff(page)) | PAGE_OFFSET);			
> \
> -	unsigned long __addr_tag =					\
> -		 __tag_set(__addr, page_kasan_tag(page));		\
> -	((void *)__addr_tag);						
> \
> +	__tag_set((void *)__addr, page_kasan_tag(page));		\
>  })

It still need a cast or lowmem_page_address() will complain of a discarded
"const". It might be a bit harder to read when adding a cast as in,

((void *)__tag_set((void *)__addr, page_kasan_tag(page)));

But, that feel like more of a followup patch for me if ever needed.

