Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 38F85C10F03
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 17:39:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EA22821738
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 17:39:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="PqUPvHzH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EA22821738
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8AFE76B0003; Tue, 23 Apr 2019 13:39:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 85E4E6B0005; Tue, 23 Apr 2019 13:39:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 74E076B0007; Tue, 23 Apr 2019 13:39:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5589C6B0003
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 13:39:22 -0400 (EDT)
Received: by mail-it1-f197.google.com with SMTP id w1so692060itk.4
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 10:39:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=2q5bHxyVaSUQ5sH4NkpY5LEKO5vrmJSao/hJT9S7ZPk=;
        b=j89iKvPy+u2W0Ph2fbuyaInEctNpfaRTJKN2wPBrZujLAJu/jOEtQyh861QPmQpgTa
         HAxQspUo1OGV8r35I2j3Pwu9uiUrYWjYXVT2FCalFMw/CkfOkjmb6Kb4kRHSp6UrA2w/
         uQ0gNoZ+hTraHInrkmqVvWfAiLsr+xHMcA9KYBcGXkJxfe8yaZ+GxeVg0C9FtUQ/7xBw
         f5oA03e/qs79Dmm5jZAkrdTdVLWUZaOhhLes4VUPUc7pMYMLGsnIzy158ELOwyr8ifbw
         rU0jezd5EcGHPnBNz+fn1SSvPgUE+LkjmsMsmq4xxi9hL8tCU3o9tI238oVeB/pWVyD2
         qOPw==
X-Gm-Message-State: APjAAAXZJEjvloe2Aau6CoxH54YPB6t99zn9c+6aCkMdw1V7plEnld0x
	TloEraspYfuYz5NNY5+fwmGHVuDGtoaPLGKNCllt48frISH+VZ2ACquaOVUnRQQDayPfvN6I+A8
	SxeyiLyeQYv9BBSuj7BfoEKLzd5N9HdDCDVQd236H0PbTWVwiGTsLfRVuf/8fdPBy6g==
X-Received: by 2002:a6b:b989:: with SMTP id j131mr3349148iof.131.1556041162118;
        Tue, 23 Apr 2019 10:39:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwP86klV6XRov8X9vDvU/wZRasFJB1LSqIFXkaiM68QBvoFB/1MHedqoh4ckl2soJ4ZiQG+
X-Received: by 2002:a6b:b989:: with SMTP id j131mr3349113iof.131.1556041161614;
        Tue, 23 Apr 2019 10:39:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556041161; cv=none;
        d=google.com; s=arc-20160816;
        b=NLJ1DrR1MMAv2FbfPT1kJ//V7byPuVYeQWiyn/NjPbszKfzPYesHauOmQ6T8HOapa7
         O//Oj4/yOcoDbkwvBfLxUkGUYHTWEFACYz7mQ9PyZZihPvtcRzHBKtjVGi0W5traiv7b
         mudFtDMyte5mhLM90ADD17ht5dguo6JPXh6peQApT2jLfR+V7EPh2G4F6XnQ+zUTacqM
         lqPt3Fpc5jIhEC73dtJlGGjpRqXL4Kw8kfWN/hc9OuQ3bbpiTEaUfu2lm7jBaA1lJHk+
         +cablMOss4tHdubRxe7yAdOwDHFMvSIz+pVc6wYRAOUX6lp7anyZTnd5BwQMzs/fdZSi
         sHNQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=2q5bHxyVaSUQ5sH4NkpY5LEKO5vrmJSao/hJT9S7ZPk=;
        b=dYlA5Tih9d/mux4Id67cbT1IegIfDYn97trWcA+2MzU4DHW+sAxNeFqwzUb1S6Rr+R
         ztNNsograRQu3Eh4EAIXEC59jPjIiPG5h9ll5guKz8YAYWxFCGfF6GFlyHPuNERMWWIy
         xQXe8JoId6eyS75e0MSj9P0NhUXQc9XS/W5CWPUUT2KggCBEWZ8w/lpkVi3hPVDhUJ8d
         P9C/OvvpC83fzkTfFBaKCIpJeY1NBehug0iZK8kqhEY7qKg4bJYBmGE6x18i3WSpRTcu
         lv73bvl532FAWGQHxvRGg6Qr2VR//QkLIpixeMJLKwoG4zM+qxzvR8TNGJzhTFfoS4r1
         WkjA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=PqUPvHzH;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id m11si10533867itb.79.2019.04.23.10.39.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 23 Apr 2019 10:39:21 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=PqUPvHzH;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=In-Reply-To:Content-Transfer-Encoding:
	Content-Type:MIME-Version:References:Message-ID:Subject:Cc:To:From:Date:
	Sender:Reply-To:Content-ID:Content-Description:Resent-Date:Resent-From:
	Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=2q5bHxyVaSUQ5sH4NkpY5LEKO5vrmJSao/hJT9S7ZPk=; b=PqUPvHzHaTirYCRxEP+XrBzgPZ
	9auAeGoNGTgXWGZx88vZeAN3Jiz/+1hHQvoXSFrdmXqhMMApe9PrCBlXvXOKQkfOSk+jGb8B63rQq
	Vj9mMG10eV3l1yeve4Z0XspSSk/QHzwhbArig58OJ36rzK6FVsuKwTjkV40jsS41Ge6DmJn6GW7fE
	41f8LDaeNFYP9/HOu0nAMKmI5PhQtAf5qGo5/2fPFKDGkrUOLxXLuKM/nIAwoJAtyfURaG1WdnRzm
	/+QYE0P4R4DXwB0zAZRoCCJluLayqJsTt3fUR3TgCl7E2nCCk/jxFSDBTWoCHPxVP8eur5TL2n4MS
	Hdh/vxSw==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by merlin.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hIzNy-0007YS-7H; Tue, 23 Apr 2019 17:39:14 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id EF79E29C2574D; Tue, 23 Apr 2019 19:39:12 +0200 (CEST)
Date: Tue, 23 Apr 2019 19:39:12 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Randy Dunlap <rdunlap@infradead.org>, akpm@linux-foundation.org,
	broonie@kernel.org, linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	linux-next@vger.kernel.org, mhocko@suse.cz,
	mm-commits@vger.kernel.org, sfr@canb.auug.org.au,
	Josh Poimboeuf <jpoimboe@redhat.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andy Lutomirski <luto@kernel.org>
Subject: Re: mmotm 2019-04-19-14-53 uploaded (objtool)
Message-ID: <20190423173912.GJ12232@hirez.programming.kicks-ass.net>
References: <20190419215358.WMVFXV3bT%akpm@linux-foundation.org>
 <af3819b4-008f-171e-e721-a9a20f85d8d1@infradead.org>
 <20190423082448.GY11158@hirez.programming.kicks-ass.net>
 <D7626BC0-FCE9-4424-A6F5-D4AAB6727ED4@amacapital.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <D7626BC0-FCE9-4424-A6F5-D4AAB6727ED4@amacapital.net>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 23, 2019 at 09:07:01AM -0700, Andy Lutomirski wrote:
> > diff --git a/arch/x86/include/asm/uaccess.h b/arch/x86/include/asm/uaccess.h
> > index 22ba683afdc2..c82abd6e4ca3 100644
> > --- a/arch/x86/include/asm/uaccess.h
> > +++ b/arch/x86/include/asm/uaccess.h
> > @@ -427,10 +427,11 @@ do {                                    \
> > ({                                \
> >    __label__ __pu_label;                    \
> >    int __pu_err = -EFAULT;                    \
> > -    __typeof__(*(ptr)) __pu_val;                \
> > -    __pu_val = x;                        \
> > +    __typeof__(*(ptr)) __pu_val = (x);            \
> > +    __typeof__(ptr) __pu_ptr = (ptr);            \
> 
> Hmm.  I wonder if this forces the address calculation to be done
> before STAC, which means that gcc can’t use mov ..., %gs:(fancy
> stuff).  It probably depends on how clever the optimizer is. Have you
> looked at the generated code?

I have not; will do before posting the real patch.

