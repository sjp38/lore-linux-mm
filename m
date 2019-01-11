Return-Path: <SRS0=ysF+=PT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5FF32C43612
	for <linux-mm@archiver.kernel.org>; Fri, 11 Jan 2019 18:16:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 24AC02177B
	for <linux-mm@archiver.kernel.org>; Fri, 11 Jan 2019 18:16:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="lTCr9aGG"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 24AC02177B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B58358E0002; Fri, 11 Jan 2019 13:16:09 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B05B88E0001; Fri, 11 Jan 2019 13:16:09 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9F4668E0002; Fri, 11 Jan 2019 13:16:09 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5E2A98E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 13:16:09 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id y88so10915395pfi.9
        for <linux-mm@kvack.org>; Fri, 11 Jan 2019 10:16:09 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=Nmx4asMzroV5sBI0wqplHX3gob/sn7xzkvUWEPDo4YU=;
        b=S/1ZVCbCA4VZKveEjm7kDdasfUxUta9msFjEf/qzHCLPfN6KgV37Wi6dQekmxxLkFo
         gLSWNgMwidLMr8niSMm/h4YrFYLCNIlo2pamylrQ1zigIq1wiqFqjc+wXOq8UZghgJUr
         Oql0vlBLpF+Iw3bmKaX5nJ3v9zZl3ZX3LhX8bZdBA6wB7nVT0lb6lLzMcZKHoOrxqbQc
         qvIF2nz9o/pY3zIVEg7Y5ag8hdPn4u8YgSfxeRHNF9O5rhmsKl8ZkLFqwyfTKXdjDsbY
         oLpWcADn3KkVGaTAZ4qHlGR6yR1Ww2+p5E+0+J2DyTpwOsICaiAZe/HyIz9/PLiMhnWg
         Sxqw==
X-Gm-Message-State: AJcUukeNNIs1P1BaCGAIcIGP4ffHorFRzkCxvAwCippHucVrjNY2hKRG
	WBfw5GFn8f2hZS0loQPQAkvKyMl8Taq35bAi85tVxd6FpiulKoBCNJFuWIqy8Dh5eGD1Q/Pnekh
	pisi9Ua94B39rFvAh4iyJ57NLYDSYjSSQLhCDQtIIq8FcbSpRp6Gk8l5JUhWbbffZdA==
X-Received: by 2002:a17:902:145:: with SMTP id 63mr15589657plb.256.1547230569054;
        Fri, 11 Jan 2019 10:16:09 -0800 (PST)
X-Google-Smtp-Source: ALg8bN65nxYhbkCQO0eP1M8Jg6IoLhqBA17fmQoQITc9R61fZKVcWpfucrLYloXzd0xpIACoI11C
X-Received: by 2002:a17:902:145:: with SMTP id 63mr15589613plb.256.1547230568369;
        Fri, 11 Jan 2019 10:16:08 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547230568; cv=none;
        d=google.com; s=arc-20160816;
        b=vQzsxh/go5fKvbrJgEabHWXfeqsd4rni4tOcli/Hp3JmNJHqPchoCAK+dlutw1Y+f/
         FCjEtuFPeF1RggDmglTLkmnw2Vrh0ZgJGlOAYLHgCGbDGw1xYtu/CxiFwaV+uS3CsT6Y
         vBNfc+CmV0x1b7uIaA5GDWLW6kDlNZYde+7Nnbh1/uTzc6kSpTGIMhQO3hRUhStD85dx
         TmOhuZGQ3PMZeRBB4Hk/B33GwHA/s7/deLary+kOE+iW3ibjJ4vBI1CtBbnSh9mL8Lun
         l50FoHZJUR6ZY3Z2Uixdy00hR7PQdRi2iT0ObdTVxkZzR91ny4AjWcRjrACyR8NDL0uW
         kLCg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=Nmx4asMzroV5sBI0wqplHX3gob/sn7xzkvUWEPDo4YU=;
        b=A+spacKOk9ZEuxfstiO4ebdM/NWKTCIxj2hPMcJH/jF96cMjeYx/betZbb7bN5eUJo
         pQJMdU7/Sdz0hMT9x1UMqwfV3SUcLK+iR5dbztPog99bPZemxhtdlmHeCfgtrpolEuY1
         As66AA6yLK0n4vZ3OV1JtcuAV5uhw0E7NDy1B60zzitilfnqRko00a35C8RRmiyjLbgv
         QzxonykUvR8Bz0D5yzcEfqS0vVbpmU9EInLy4V74IBAwT4XAPudr9VhnLVbYcXwtMGLK
         3GnwGlRDfv4CkO6zdLDcv2Ejh9jMFs3f2lAdR+ga7juh8ckur2hOWtY4JTLmy9LNu4FY
         Kuvg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=lTCr9aGG;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id x5si16263760pgq.535.2019.01.11.10.16.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 11 Jan 2019 10:16:08 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=lTCr9aGG;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Transfer-Encoding
	:Content-Type:MIME-Version:References:Message-ID:Subject:Cc:To:From:Date:
	Sender:Reply-To:Content-ID:Content-Description:Resent-Date:Resent-From:
	Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=Nmx4asMzroV5sBI0wqplHX3gob/sn7xzkvUWEPDo4YU=; b=lTCr9aGG28zQaVC/ak9w+BxbBq
	Yl6l4kuGG4gV8wGelcfDSp/tx+qs1FzJJdpZ753xYJXbGv1FINzBAx3qH0McDCjGEC4dbeiTAULud
	3Ofv2ZNrZFXaVaVAwuLQcdZCvSMX+Edz/X7N2Gi2d5pi8CfYgvYvOR89CBOgUd/aPSqJqCx/H9495
	+PCa105LqDzWedVTQCcoXt+KmENBUcHRFeQhK8DShVKMVoy320P1jUvG+hGjabTYThv2LCyG+3l2G
	+e4mNscbG0l/26QPj+THE81fHfhwrVWhhDoJp9YaO6TGZk5l4cIZLO0ikROozRkAYrH1qu58NRYkp
	Qksf27cA==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1gi1Lc-0000qm-Ns; Fri, 11 Jan 2019 18:16:00 +0000
Date: Fri, 11 Jan 2019 10:16:00 -0800
From: Matthew Wilcox <willy@infradead.org>
To: Qian Cai <cai@lca.pw>
Cc: akpm@linux-foundation.org, esploit@protonmail.ch, jejb@linux.ibm.com,
	dgilbert@interlog.com, martin.petersen@oracle.com,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org, walken@google.com,
	David.Woodhouse@intel.com
Subject: Re: [PATCH] rbtree: fix the red root
Message-ID: <20190111181600.GJ6310@bombadil.infradead.org>
References: <YrcPMrGmYbPe_xgNEV6Q0jqc5XuPYmL2AFSyeNmg1gW531bgZnBGfEUK5_ktqDBaNW37b-NP2VXvlliM7_PsBRhSfB649MaW1Ne7zT9lHc=@protonmail.ch>
 <20190111165145.23628-1-cai@lca.pw>
 <20190111173132.GH6310@bombadil.infradead.org>
 <1547230356.6911.23.camel@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1547230356.6911.23.camel@lca.pw>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190111181600.ELTYkgvh64vko1ggxiTGzHncAvJmTDbjzm7i7P03QxQ@z>

On Fri, Jan 11, 2019 at 01:12:36PM -0500, Qian Cai wrote:
> On Fri, 2019-01-11 at 09:31 -0800, Matthew Wilcox wrote:
> > On Fri, Jan 11, 2019 at 11:51:45AM -0500, Qian Cai wrote:
> > > Reported-by: Esme <esploit@protonmail.ch>
> > > Signed-off-by: Qian Cai <cai@lca.pw>
> > 
> > What change introduced this bug?  We need a Fixes: line so the stable
> > people know how far to backport this fix.
> 
> It looks like,
> 
> Fixes: 6d58452dc06 (rbtree: adjust root color in rb_insert_color() only when
> necessary)
> 
> where it no longer always paint the root as black.
> 
> Also, copying this fix for the original author and reviewer.
> 
> https://lore.kernel.org/lkml/20190111165145.23628-1-cai@lca.pw/

Great, thanks!  We have a test-suite (lib/rbtree_test.c); could you add
a test to it that will reproduce this bug without your patch applied?

