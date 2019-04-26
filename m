Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 40AD4C43219
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 07:42:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F002820684
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 07:42:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="HzSM0zqj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F002820684
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8011E6B0282; Fri, 26 Apr 2019 03:42:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 786DF6B028B; Fri, 26 Apr 2019 03:42:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 64EA36B028D; Fri, 26 Apr 2019 03:42:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2C7716B0282
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 03:42:34 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id a5so1454971plh.14
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 00:42:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=VSMhN+nfzaw1tZG3jJEpjZvzXxWyKbRMlymqbYuBFjg=;
        b=kecZssZwebf40vqKuTjGTBgBmQojJyn9t1MVTWmPz3rtz9BvrjJtllgwg1LEEqUDFb
         2+zWR2e1xHyp5mT7XKr09WqDSWQY+C5S1INOln5slpcaqRrZSa6+/l8W2OYYkMFXTVW4
         NfLV+KFtK8HJLQLOgGrgEb9OnM5w8M9oK9go4ndhsG/0Tsl/RYUjbtlqpTjiqY2sgTI7
         3J34INwaq8PiEswUEFe8gLSN0vBH6bFujZasgyuTd3dfOnFNWB1Xs8191ObY86CzjKdL
         FJnv1w8+0vWaWAXyHGu2/GSTVZzMg1CySRRq8Qunatn0xLgc3cQmYw8JoBAk466WECGZ
         6NIw==
X-Gm-Message-State: APjAAAXnjYsVfTCRu7li3vDqi32X3B626EG5KazbCTs0UnTWiaJLVswe
	nvI/Plq9C7ij8u/i/fj/qWBlvS1Ee0QGgXA8r9p1TgkHhsImp/NN4ljOIknSGfLQP8AesB6uWfU
	32WlJbWpQCSePEkLd46JQJpNeyqkPzFm36uY32rJOl5QqkqEC1YYWvQeMsKAsGSgDQA==
X-Received: by 2002:a63:d10b:: with SMTP id k11mr18399063pgg.59.1556264553687;
        Fri, 26 Apr 2019 00:42:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyT+w+tmZ6zF6nKp7bN+Vyi6UbJ8xJIydJ13i9gmcFLZ6cuntN3aaUuKW/ReXhm92FiQDFm
X-Received: by 2002:a63:d10b:: with SMTP id k11mr18399024pgg.59.1556264553009;
        Fri, 26 Apr 2019 00:42:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556264553; cv=none;
        d=google.com; s=arc-20160816;
        b=ldDbhIY5MurhPffPy1sFGj8u1+S9Wd6hFyzKcuVdFQpzSZd+eyeD3WITdc0lRvpzoY
         Cw0EJnxuCRIE86p2UKwiLkWC2p4k9PAiAIajjPFUh+KJ2IDEWXB+NxLYjZ4kc6HiY1Vw
         omu2Q6SS+tYNd5EtZTCvKDkh8FmoJGEqkqkqSdkRUVEHjEKMsVzIzFynvD/ABiKebZZ5
         CXdW7YMtZAnTSTNThTYWeURJIEuHnTf2yqSehy0hyc1FUnLfapLmNmuOcKjRXElHvTjy
         wIiL2N1ROWwqPJylFjwi2n08FnYIKZ1zCEigHoJ8X/AtwtxLqO48/YV7Vw13hOcykP3f
         9JWg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=VSMhN+nfzaw1tZG3jJEpjZvzXxWyKbRMlymqbYuBFjg=;
        b=rGM+2lMSSjhmOUBRhFPQCfA9UsV1iRSNjhJrXU5bDvT8NORKC1YdpvfIDgMAjLB+T9
         uEhH/OYNoHdPKDwOrqbQ3+cO/wwH+wpg1Ppk4OgFnnAvo1Ar/9GP9eTC7xMn2AiT9tiV
         MjageTEbMdFagP+AYZ3S41iYFmJjHSJNaGRbHLRq7h5jEAfHn02ahnRX9jzOz6wttQSP
         R0K0YLElLZWCpFGcWzL8r/VYhOpt60SCydsVyd5NBT1MIE88de4hjIIVqYfOLhsfHlek
         Mm7D7LTCIHlmAn3Oqz/MVsR9x8t9uEq8eMuvej9Z1FWPfUeyVRAWYKhUeqZIzOrk4S48
         jq3A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=HzSM0zqj;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id x10si24107543plo.422.2019.04.26.00.42.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 26 Apr 2019 00:42:32 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=HzSM0zqj;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=VSMhN+nfzaw1tZG3jJEpjZvzXxWyKbRMlymqbYuBFjg=; b=HzSM0zqj3Ao+/TzgNdgd1swkv
	JUIT5sLDscQK7QUjPui60Fvql3zrVQm8NFusS8MfvwLnn55u3O48d96ky/W/rckJ6suzG75KqhZvp
	goK9pKaYevwe0u0lWHZ/+tgW9cfR9Rhl3MSHvwuZ7mpfbVrxMvYP44caQxNOw681WR2JB4Hn9raAF
	SoVI0o6PWu/nkXUh6kwm/JtEvs9Tw/s3BJSK1mR7t1FTOJki6PrvzB1LUl2J022GsIZyhT+n+oqh/
	WFMNNLbCiyBzUksflqli8vZGvY7c1Ng1ZDfA4aDL35wGDW56lsq8MBGvtNgQMfbfcuCMquiyDm4dL
	GfZMyX+tA==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hJvV3-0005gQ-VC; Fri, 26 Apr 2019 07:42:26 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id CB82029D1A321; Fri, 26 Apr 2019 09:42:23 +0200 (CEST)
Date: Fri, 26 Apr 2019 09:42:23 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: linux-kernel@vger.kernel.org,
	Alexandre Chartre <alexandre.chartre@oracle.com>,
	Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@alien8.de>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	"H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>,
	James Bottomley <James.Bottomley@hansenpartnership.com>,
	Jonathan Adams <jwadams@google.com>,
	Kees Cook <keescook@chromium.org>, Paul Turner <pjt@google.com>,
	Thomas Gleixner <tglx@linutronix.de>, linux-mm@kvack.org,
	linux-security-module@vger.kernel.org, x86@kernel.org
Subject: Re: [RFC PATCH 5/7] x86/mm/fault: hook up SCI verification
Message-ID: <20190426074223.GY4038@hirez.programming.kicks-ass.net>
References: <1556228754-12996-1-git-send-email-rppt@linux.ibm.com>
 <1556228754-12996-6-git-send-email-rppt@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1556228754-12996-6-git-send-email-rppt@linux.ibm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 26, 2019 at 12:45:52AM +0300, Mike Rapoport wrote:
> If a system call runs in isolated context, it's accesses to kernel code and
> data will be verified by SCI susbsytem.
> 
> Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
> ---
>  arch/x86/mm/fault.c | 28 ++++++++++++++++++++++++++++
>  1 file changed, 28 insertions(+)

There's a distinct lack of touching do_double_fault(). It appears to me
that you'll instantly trigger #DF when you #PF, because the #PF handler
itself will not be able to run.

And then obviously you have to be very careful to make sure #DF can,
_at_all_times_ run, otherwise you'll tripple-fault and we all know what
that does.

