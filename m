Return-Path: <SRS0=5q+O=TJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 26D4BC04AB1
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 14:07:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CEC9021479
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 14:07:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="itWxOZBR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CEC9021479
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7DD336B0003; Thu,  9 May 2019 10:07:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 78DA36B0006; Thu,  9 May 2019 10:07:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 67C026B0007; Thu,  9 May 2019 10:07:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 318576B0003
	for <linux-mm@kvack.org>; Thu,  9 May 2019 10:07:15 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id t1so1674002pfa.10
        for <linux-mm@kvack.org>; Thu, 09 May 2019 07:07:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=5Vk8Apvrfg+i40tbt0Q7wdfTA+VOo7Dy+oZcL8EYyo0=;
        b=L6l2cFhExVWYQnlmnKbq5xZX7FgM1QMCSF2JW46oJdaViXypb9wrIzhkK4LnPKWJoe
         h87vSAG2DC5Nfn5SGuiWPQblTF8preFxWpdRczF8eBO7tzgdM7IArqYPHj44e1oH9GgL
         8uYZ3JeRG1im7WQ09HJVpmD4rDag5DbqUEe4ZDyFUyY+vJg8T7oThHqdHkrzqenc1H7c
         azLFlw4D6Y8qJZ96ewtJin4AA5DQ7yxyfBVdrfClrzTKoGap6ob2o3DEuDFD8nw4pIxY
         P7vhjgCF6tzrnyYKjJIDPJSUxSkryNnR6XM5pQdQSxVmTG6GEJr3/vahJwVyTlyeAFrb
         slaQ==
X-Gm-Message-State: APjAAAW8icyvm9zgRT0BjSjxJHGW5AhyAOCMVS6Tfuq8E7EQ0gxTEgYp
	aVqWtBGQ7Bg7ONrks3vA7YuOZO8VVOeQKlGPKGNCDsyAA8bH9ArydnkaWy2ciGnmsy69J+U+Cxb
	SW2NTUC8aMJuFcv0g7OBA2xadDKNLLUQHLe6WmPTyap2hnpKDdfQQutwK+G6M7+y1UA==
X-Received: by 2002:a63:7c54:: with SMTP id l20mr2348849pgn.167.1557410834850;
        Thu, 09 May 2019 07:07:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwWoZeKskSGwqGUYzEyCKI9tI6JcvwTDwrZqfETUJLabbU/yNZDkRDfKz8jwq3uKC1MNUKY
X-Received: by 2002:a63:7c54:: with SMTP id l20mr2348734pgn.167.1557410833987;
        Thu, 09 May 2019 07:07:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557410833; cv=none;
        d=google.com; s=arc-20160816;
        b=qz7xSMNaYBsPM/14UCvMRK6x4moYYO27f7cTQatV3fmqoMHYlsRqhwgTteLmnph49u
         DM7/JdcYJkMEWiAkoXfizF4ECoErVVcJ9L7yWafdvJGHdUdVmbUWdKrvPgoBjQfrQ1/t
         Zsv5CoLjPmI8aEFhqIqv2g32x/jFevXDrU+WA79Q6P46Ef72r5535hhqvBlO4oHpAbEo
         /ZJUgeRUQA5oH7qLKnlhE6VVjjTkvQEQJ6CauVQgHuyNt/3aZykx8KzVDH0sS60qVx51
         BsaHMCGBOaJgWwVF0h/gsJUo2rSQmGqxqL8RxvXGRTM+BHc7n9tQIx8p5y+1cgDakDVw
         lT/g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=5Vk8Apvrfg+i40tbt0Q7wdfTA+VOo7Dy+oZcL8EYyo0=;
        b=Rv35TNmkVuFMPWXCM+7xFLt8AJmgDDS1C7ABhAi8MEQiryec9aWz6tHkD6xjfJPwFL
         409qCxxgb3Wj0SJc07Etm1EE2b6Tj8uOPC3gGEk/DXiR4STA/svBFxIcx0PKpYblb3BY
         pN8h5uuTs2GX09QNbNEHs3cLCaeGnpSmEtaaPL6XB5a30VkS3Fw3un/6kgh+CXg93B5F
         xp9++0YeGUtEVLAVBUSeMlGLKO8Roe/8/hki7ZVcolrz/LVzGRJre3ZcxcTffK9w4sqk
         s9a2euH3h9AbpNBF1jhek+2BXEhOUdG4dKOl7lqvzdBcQ/FDNa0TgZ9qdXQNbZ8TV+GB
         HwzQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=itWxOZBR;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 33si3002525plh.3.2019.05.09.07.07.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 09 May 2019 07:07:13 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=itWxOZBR;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=5Vk8Apvrfg+i40tbt0Q7wdfTA+VOo7Dy+oZcL8EYyo0=; b=itWxOZBR+b7m3jbCnb8PzwjZg
	wQSdRv2D0/EdoNXkVMbisfQldFkLmDvQYVYYsI49oCpXPLe7B0RD0p4bBa6VzSQYCZsN8LG4KF2PC
	OF+Od2EHvv4VOdCkbtSNTPq/L+Zu263bCLAiy41BzRfSI2iHnBTDrmJSA8Yw+ec3fTVlXwj7TuE7k
	33nKdV4Gj7SQrtznKjrW0OWZYhOLDnZ82Pigbhm0E/GDGTKGfZ+QH0LARzjbBawuf8qYGndbx4/sO
	TreZMlVQENJzpVjTkvNjTVNBNBNrig23LKSHYB7H5zHP99IgA4m7Ci0dXGZd3jQX3btFgjBNpKOIv
	JBqfAmeUw==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hOjhZ-00062h-9e; Thu, 09 May 2019 14:07:13 +0000
Date: Thu, 9 May 2019 07:07:13 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Ira Weiny <ira.weiny@intel.com>
Cc: linux-mm@kvack.org
Subject: Re: [RFC 00/11] Remove 'order' argument from many mm functions
Message-ID: <20190509140713.GB23561@bombadil.infradead.org>
References: <20190507040609.21746-1-willy@infradead.org>
 <20190509015809.GB26131@iweiny-DESK2.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190509015809.GB26131@iweiny-DESK2.sc.intel.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 08, 2019 at 06:58:09PM -0700, Ira Weiny wrote:
> On Mon, May 06, 2019 at 09:05:58PM -0700, Matthew Wilcox wrote:
> > It's possible to save a few hundred bytes from the kernel text by moving
> > the 'order' argument into the GFP flags.  I had the idea while I was
> > playing with THP pagecache (notably, I didn't want to add an 'order'
> > parameter to pagecache_get_page())
...
> > Anyway, this is just a quick POC due to me being on an aeroplane for
> > most of today.  Maybe we don't want to spend five GFP bits on this.
> > Some bits of this could be pulled out and applied even if we don't want
> > to go for the main objective.  eg rmqueue_pcplist() doesn't use its
> > gfp_flags argument.
> 
> Over all I may just be a simpleton WRT this but I'm not sure that the added
> complexity justifies the gain.

I'm disappointed that you see it as added complexity.  I see it as
reducing complexity.  With this patch, we can simply pass GFP_PMD as
a flag to pagecache_get_page(); without it, we have to add a fifth
parameter to pagecache_get_page() and change all the callers to pass '0'.

