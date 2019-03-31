Return-Path: <SRS0=Vnw4=SC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 80381C43381
	for <linux-mm@archiver.kernel.org>; Sun, 31 Mar 2019 03:23:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 015D321726
	for <linux-mm@archiver.kernel.org>; Sun, 31 Mar 2019 03:23:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="hBZWz+3H"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 015D321726
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8749D6B0005; Sat, 30 Mar 2019 23:23:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 820D66B0006; Sat, 30 Mar 2019 23:23:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6E9466B0007; Sat, 30 Mar 2019 23:23:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 349136B0005
	for <linux-mm@kvack.org>; Sat, 30 Mar 2019 23:23:31 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id b12so4452712pfj.5
        for <linux-mm@kvack.org>; Sat, 30 Mar 2019 20:23:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=G8zdvqeMT0A0X+iMFAIkvGmqpX02zoNQMcZMLsL1dGw=;
        b=tSessCOYr2JJOtO6JwjlbQcwBru7VWC1a7kjyoL6wRVpJjsfCE05lvc6p+fYOKVRSY
         n2WQhZsmEFN1MaS5cb3JIKxkb618GrLctWEUbZGQdTKFl7+3yzmiwsExgPWiSz+ppA0D
         nBPbFxQyJs0ZObKwbsHtoR6kAFuTzjPdgfy3+4uUmyyvq4EYNtcFoAzweuNcU6KPwtt/
         pb3ruO7TcIkR/A5kPSE0mEceAwe5T8vsmkSb4mmQHRPld6cJnDBkyVmVgH0uSZUZHmYL
         8YhXUMq4p60BRfzFJjqKe2YvNGKf4mWd4NPYpACbAufUApCHJhcOyQewLMlwKP5Mlh+n
         92Xg==
X-Gm-Message-State: APjAAAXDsX9kcB1ioxTh+v8idoaZOWGZwiUU1eaKVc1d0hIoriEPzyep
	8SgAQDrA13cDaXu4/WrPMGyNH2CwlZ3q/oGVnsK6D7LeUXRSy3kO4T7mU0Z6iBoW4PAkBc80wk1
	TFWDZlg78ehjM3dgj4UP+VxYWyeYaVpsaDz5DVM1rjpDdh6r0lG/+hwsCxrDCmDXY3Q==
X-Received: by 2002:a17:902:7242:: with SMTP id c2mr21286746pll.245.1554002610752;
        Sat, 30 Mar 2019 20:23:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzwqwKs7r/GPn0z9e3rEFkrCDdQBbMEVj0mPDEmx03PKQiAIqK5wQpFeG5/SMZI6oMmQBTm
X-Received: by 2002:a17:902:7242:: with SMTP id c2mr21286700pll.245.1554002609811;
        Sat, 30 Mar 2019 20:23:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554002609; cv=none;
        d=google.com; s=arc-20160816;
        b=y5nLzbnSUE3xj3YkdkkTv5Q3jhzVPF7Af9b3NgWQXl4fTDUBd34ZugvIQ4Y9652ImH
         kLYzsQVGUEVMDZskEVAc2xAjYkXUWHlcqPbEB2mRRTb3K1AZucy69+8NqBWbNXR9LaMV
         hMiHrrlfLjo6nTO2ozJH5aJv0RtSFuUdPbxqrU9hkE7n0e7Qzf5ejcqgaswsin1D7BGG
         u9oxu3C7iR0iTXCx1JyYCIy25gAZrRob35ZXPau2+pJZThJN6xXXtFwh/ktj2P4uc7zG
         conGf8hW5sb9tLBU1ZpJc2ZZMXYuGtpOTr/7kQMLGZClL5Lk/yhBYgyAdvN+VGjps2Js
         W67w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=G8zdvqeMT0A0X+iMFAIkvGmqpX02zoNQMcZMLsL1dGw=;
        b=UnKDul6RdxCqiXZ1Wyy4cRX+/mAM1q4JROC3WzVXuex3440aMt6LuVqHO1Aq00qHbh
         o1coe0NAV8hNf/GJVmFK7hBluoD+65CCZfXvCiuWBVupscBkT63nZ950I91Sj+GvmYGV
         LTqIhBn4i9K6zWXnXoJMrN4DB1Va3dH4wCCYg9A42TGZli9F361N++8x6CAvsyl4jwyW
         +iTTdOkfqvVG8CDx/c7uY89lskKhIJlKjGd/N0ZtFkbkYvAha7VXeqepjmr8KMPGFgUX
         wCj+XQUpEIf+LKmOFL3w1P9Vj4S2hrtC8sucT0eya6yGLAI9WgxBgiTaJLrMOyrVnF1T
         zKUw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=hBZWz+3H;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id e67si6226165plb.107.2019.03.30.20.23.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 30 Mar 2019 20:23:29 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=hBZWz+3H;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=G8zdvqeMT0A0X+iMFAIkvGmqpX02zoNQMcZMLsL1dGw=; b=hBZWz+3HEMhYV7pu7WWkZLMuC
	Zrq5Vyt5Mb8njh/hNm/Y6+o5z6QKEBMNu9uDJqXXhbW29BQj6ZXHDHxpJj2cvLZXz9EcEYU+itCdl
	YmFiULx1u5ebEcc0llu4ncW6JZJGWA/beJuw4aFtObsmYutAvyi9OwuihVEGaa4qTywh4lG86d1AO
	YpgZZSq3lF6viCLcBDKKsQ7KjbQ3/X+Z1+wE/n5k6GbRMJlV6wPCL3Is2KlbLaTbr8AyO0Ohf7OrC
	7wdt1kTrnV09JV/3SLlz9uJzRFFSBeb3mRKto6ShDeAp4x+4Ujt5GDO1xO6sg5HWzSFiJOzrqkq4f
	8UGx2MJnQ==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hAR4A-0007Rb-T0; Sun, 31 Mar 2019 03:23:26 +0000
Date: Sat, 30 Mar 2019 20:23:26 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Qian Cai <cai@lca.pw>
Cc: Huang Ying <ying.huang@intel.com>, linux-mm@kvack.org,
	"Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: page cache: Store only head pages in i_pages
Message-ID: <20190331032326.GA10344@bombadil.infradead.org>
References: <20190323033852.GC10344@bombadil.infradead.org>
 <f26c4cce-5f71-5235-8980-86d8fcd69ce6@lca.pw>
 <20190324020614.GD10344@bombadil.infradead.org>
 <897cfdda-7686-3794-571a-ecb8b9f6101f@lca.pw>
 <20190324030422.GE10344@bombadil.infradead.org>
 <d35bc0a3-07b7-f0ee-fdae-3d5c750a4421@lca.pw>
 <20190329195941.GW10344@bombadil.infradead.org>
 <1553894734.26196.30.camel@lca.pw>
 <20190330030431.GX10344@bombadil.infradead.org>
 <20190330141052.GZ10344@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190330141052.GZ10344@bombadil.infradead.org>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Mar 30, 2019 at 07:10:52AM -0700, Matthew Wilcox wrote:
> On Fri, Mar 29, 2019 at 08:04:32PM -0700, Matthew Wilcox wrote:
> > Excellent!  I'm not comfortable with the rule that you have to be holding
> > the i_pages lock in order to call find_get_page() on a swap address_space.
> > How does this look to the various smart people who know far more about the
> > MM than I do?
> > 
> > The idea is to ensure that if this race does happen, the page will be
> > handled the same way as a pagecache page.  If __delete_from_swap_cache()
> > can be called while the page is still part of a VMA, then this patch
> > will break page_to_pgoff().  But I don't think that can happen ... ?
> 
> Oh, blah, that can totally happen.  reuse_swap_page() calls
> delete_from_swap_cache().  Need a new plan.

I don't see a good solution here that doesn't involve withdrawing this
patch and starting over.  Bad solutions:

 - Take the i_pages lock around each page lookup call in the swap code
   (not just the one you found; there are others like mc_handle_swap_pte()
   in memcontrol.c)
 - Call synchronize_rcu() in __delete_from_swap_cache()
 - Swap the roles of ->index and ->private for swap pages, and then don't
   clear ->index when deleting a page from the swap cache

The first two would be slow and non-scalable.  The third is still prone
to a race where the page is looked up on one CPU, while another CPU
removes it from one swap file then moves it to a different location,
potentially in a different swap file.  Hard to hit, but not a race we
want to introduce.

I believe that the swap code actually never wants to see subpages.  So if
we start again, introducing APIs (eg find_get_head()) which return the
head page, then convert the swap code over to use those APIs, we don't
need to solve the problem of finding the subpage of a swap page while
not holding the page lock.

I'm obviously reluctant to withdraw the patch, but I don't see a better
option.  Your testing has revealed a problem that needs a deeper solution
than just adding a fix patch.

