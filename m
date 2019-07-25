Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D251DC76194
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 18:58:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9AD06206DD
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 18:58:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="lopY/BRo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9AD06206DD
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 335CB6B000C; Thu, 25 Jul 2019 14:58:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2E6318E0002; Thu, 25 Jul 2019 14:58:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1AE456B026A; Thu, 25 Jul 2019 14:58:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id D8F6C6B000C
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 14:58:43 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id x10so31495244pfa.23
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 11:58:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=uM1m72nodYHDEUlSsjslsPY2INrx+IqGO9Kqpg6MkME=;
        b=kRR2KYZKRrV3TOdfGIA0uPqJDQfKT/ECd+BmBz9h8QmB3ht764gnaTYQX5RTQ+/OX0
         efS2UPemSNPfnTBEVlWbqFUProHWHJ3BhDbmOptOE+FCYIPzrTC9WyL4YeU+zcla4fZP
         PM0CT6Tz9UPYt3AzAdeol+4IHgbrzljSVq9pMg3Eye3e77P3icS+gbi9h8LDXQUw7fsV
         tlRp4cjd9Hf9IG33sxXZ3FaXDbuWymdhVBAZCLRd0SX8AshIcW6EtKrC0B3OqpsbfbNG
         8e30kaMZr3fiCa0Lrm8ppfdudlYZzoL1x6+WnWg3X1Bkqgxwh8fZmVf5UX5rfxHwstvF
         v1HA==
X-Gm-Message-State: APjAAAUuaQgVg4cZ/mx5YBzfBOOLn0LlB2lfRp/1AQplw1yPds/owSu+
	q7HTSAdXWSqw7IFztaEuhStB4AdkEgR58cmUIj6rR6+hk4QB+Wiz+TX53SR9LDQsjX4KibMeLoZ
	ax7HDEs7W+QPjiWU+9RAwHNTCI4Lzpgs9r7SpGRVNEY8NyAOlxGRW2kse4L6J+Vg8qw==
X-Received: by 2002:a63:b102:: with SMTP id r2mr17310295pgf.370.1564081123377;
        Thu, 25 Jul 2019 11:58:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzmYDrI1kINEPMC4gsDxxffSv2JGy9EsujirQv5BB37hoyZVxmpAAcRnzuABzCoyXjFnnfa
X-Received: by 2002:a63:b102:: with SMTP id r2mr17310257pgf.370.1564081122563;
        Thu, 25 Jul 2019 11:58:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564081122; cv=none;
        d=google.com; s=arc-20160816;
        b=i1+vTM8d/b3WzraEo7KWFP1rJI0r5R+aVanXUQ+sxsPnXMpGFqafZfLb7SGN+Hhs47
         FA5+cppXsK6luMDkEPJ9N3NZdtvnfCtAr/OMlm73wcqrIhHswdtizlBzF0dkP2JE00eE
         VnjweCHaHOj9X7JMsjnw2dRZIJ37CoNdgYqUunRtOJEkBn2ZiR2iuYzxqikyqZ4wVnSq
         R2zS3xxGixPphm8vItINhGDG+vnlW6s2QVQnx3njjI6bX8RlOZmFZd1FoHKmwnPtENtt
         oAtpT4yE0Xx/obsnQkN0F2S0K1wyzobUEQJlJPCglLf0wJHKqo/cLUTHyLJiYM+b47Ga
         95Qw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=uM1m72nodYHDEUlSsjslsPY2INrx+IqGO9Kqpg6MkME=;
        b=BQvX9KN8qlAEgAS5YY12OP8tw4/Y/4hWhyC9nsctU/GYboHomdGdZgzsPcjfKfN+sH
         Hfoy0SluFEt5tk2S9QDKy3RdzLRhmlQ0Wtqt+2OxhcUHt5EgnqIiROCUVm2JQiZXHSSx
         TaJSoVT9BTQ8XR1+OhffG7zycF7UV8yCfdPp5xeVf420ib5cyU3GS9V/Pd+vU0dOKRdr
         mwNRTuE9afbXiiyCBcZSzajDMaj9jMkbk8WL9XXUi76KINrb8cbN0RhHm1HFbl17prD7
         squ6KblHIxIoPeDsBQ8L3pFai48e8uISYWf9oeoWiHvKzWNv4NOo1zFNvhG/vY5JUea8
         w/Mw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="lopY/BRo";
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id c189si29553300pfa.110.2019.07.25.11.58.42
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 25 Jul 2019 11:58:42 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="lopY/BRo";
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=uM1m72nodYHDEUlSsjslsPY2INrx+IqGO9Kqpg6MkME=; b=lopY/BRo9oAHx6/JdfjuDyu9Z
	RMbXMxg4xB9JD+NYF+mRAUKmgCXsDuWmLIj3Hogbw28fXWoV4lzj2niNe8BIFE7DXuibFeiN0cdBE
	UCfcTVOUloizBGEhRd1Ng4REhVzIeqKYOlKicz1HOKsdZL/wPDBxAtvww+zKrNc1vKtihZZxKhmJu
	1jWKI7WPrnq43+9RYoGp9ZLcwucz40YhAeSEbJZjaWlbWXQhqXWIbUfFKCUTxy4HDN2J5a4HKBcTW
	VZMHVSESwIGnKO9XWRap/PffQi54zOUHP+U4G0juZqRkC6p98l/DBV8JDhUC+Vi4/Q2jIvmvsMRf+
	Up7EnRc7Q==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hqiwC-0007WD-Ug; Thu, 25 Jul 2019 18:58:01 +0000
Date: Thu, 25 Jul 2019 11:58:00 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Pengfei Li <lpf.vector@gmail.com>
Cc: akpm@linux-foundation.org, mgorman@techsingularity.net, mhocko@suse.com,
	vbabka@suse.cz, cai@lca.pw, aryabinin@virtuozzo.com,
	osalvador@suse.de, rostedt@goodmis.org, mingo@redhat.com,
	pavel.tatashin@microsoft.com, rppt@linux.ibm.com,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH 01/10] mm/page_alloc: use unsigned int for "order" in
 should_compact_retry()
Message-ID: <20190725185800.GC30641@bombadil.infradead.org>
References: <20190725184253.21160-1-lpf.vector@gmail.com>
 <20190725184253.21160-2-lpf.vector@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190725184253.21160-2-lpf.vector@gmail.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 26, 2019 at 02:42:44AM +0800, Pengfei Li wrote:
>  static inline bool
> -should_compact_retry(struct alloc_context *ac, int order, int alloc_flags,
> -		     enum compact_result compact_result,
> -		     enum compact_priority *compact_priority,
> -		     int *compaction_retries)
> +should_compact_retry(struct alloc_context *ac, unsigned int order,
> +	int alloc_flags, enum compact_result compact_result,
> +	enum compact_priority *compact_priority, int *compaction_retries)
>  {
>  	int max_retries = MAX_COMPACT_RETRIES;

One tab here is insufficient indentation.  It should be at least two.
Some parts of the kernel insist on lining up arguments with the opening
parenthesis of the function; I don't know if mm really obeys this rule,
but you're indenting function arguments to the same level as the opening
variables of the function, which is confusing.

