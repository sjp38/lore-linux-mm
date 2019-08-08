Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 64BF3C0650F
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 18:18:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0D5EB21743
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 18:18:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="DYL+FtPK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0D5EB21743
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6D3196B0003; Thu,  8 Aug 2019 14:18:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6837A6B0006; Thu,  8 Aug 2019 14:18:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 572B26B0007; Thu,  8 Aug 2019 14:18:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1DE7E6B0003
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 14:18:30 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id 6so59628199pfz.10
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 11:18:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=XHC/DXG/AsJJpTqq+/d9d6/Y4cRytjPRBDIPDxq1Cy8=;
        b=n/RGxES/YeUhbCnTxq0WMo81eS08dUxo8yps5LCB2XIJsXz7Wah3yPSowjmzX/4MPB
         iJmZgw0EAcomWfbXmO4kIUHwC41bq4Gqu8Em5Rp59OtyUNGswZrRXgCf3a2n66bo1aJ0
         +u1W4fojzWzZ7nxuE5184WBTkbDakfbutcPwtDaOWbT/SetfRPNUIsnbgKC+dNx5Veld
         NMyqSSjm9MzlQ6c1gBzju7u74oPS/HGZdWaprBxV6vPdYmt4k7z+Vcwpeo+zb3d5DzNE
         vM8d6OWnMWNlWAb/95mRv+7VHvRhV31831jIyPy/vFzD1w7ks7z6relEfSfbBm4Nc6vj
         GJSw==
X-Gm-Message-State: APjAAAUgCMAh8W5q4v4IqEp6ddCT0+UZdHdqdwg2SPhvEaOxsCqipvE+
	6+hqTqPhWZfXpy471oLEGho5BFS+z252Z3nNjXK3gKKu/lkKY/IXi+8zAvfn8lrXVLKTPz0pPuB
	5SzAoJp6UXS94ANsJ4m5jJ4ldGpVnoYY1aGp8r4dtqeY6kXnusnwwqkd7htO32E+smA==
X-Received: by 2002:a17:90a:8d09:: with SMTP id c9mr5411808pjo.131.1565288309505;
        Thu, 08 Aug 2019 11:18:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyqCzY47hMdH6QumPABjHzYyB2q/t379RNGxsxmpGv3HyNkPpiuFB1lKu0Afm6qnFRT1MWt
X-Received: by 2002:a17:90a:8d09:: with SMTP id c9mr5411758pjo.131.1565288308646;
        Thu, 08 Aug 2019 11:18:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565288308; cv=none;
        d=google.com; s=arc-20160816;
        b=BJpIVEAbdI3qrFDuQe98ifXdLQ/7admQBlRwe9bBvRitZ62Ltgxyz5m7gKm/cQopxy
         Gwwl9N4+8BY80SJqobGzHcYj4JdTrhsDz1MbI+APDXPGeCnTHCnF6+7UB3JEyF4n6blH
         /Ai6ICvzSCGi+baPpqEMCKbBOClBwu5p7Mydb7EQ/dFWdW4eIX0WCmCPPSwa2x8bVuEy
         G+Tki+fxwP1EwxgsEj9bb56WuWITLEO4A8nF6r6LhF1rFoZ1X1FAEvvAaudKNVt6RpNa
         Gfn8OAaqukxMXphJHS8HFlB+kBRtkeOJgfDoHklO4FIWvAphjfl1eCvQdatYQ2chrN0T
         CBFQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=XHC/DXG/AsJJpTqq+/d9d6/Y4cRytjPRBDIPDxq1Cy8=;
        b=D+baL5kt3XY90tk9STDTp485gnYK+KXlK0kUih1S8yaHfIR5i8zVfo2BS1YZZNnUet
         8m0NdS44XB7/QouDTaxIag0Y+VqcgOEgdlL5ulC1jKGikVjGUxYo6WmDxDq80RM9ysYl
         UmVrrZmE+MuYy+3lNuePqZehMj+1nPMTCdzr9+XrbH484uhFBVdY0L8TIhQEHLYeCrZU
         Cedg7ek4Di+aTT9F14EUceqkF6dHSTvVKiqeAK+pZP67Egnt+xCU8aFJYZWeI+z9xLYN
         0Cb/8BknjOvF+U6Fn1KCG/jpzRvCDJG/L9QWq1fNsJCAw2WyTEcWd3YzVMYlA1SQMEam
         7dCw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=DYL+FtPK;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id j1si54866596pgb.482.2019.08.08.11.18.28
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 08 Aug 2019 11:18:28 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=DYL+FtPK;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=XHC/DXG/AsJJpTqq+/d9d6/Y4cRytjPRBDIPDxq1Cy8=; b=DYL+FtPKnBxAd1YCNMrIj6xkY
	eKutNn+BNnoaI3sMq4H+QMbxmgy9VXDqKFZPqganM0B80hcGGXKzySE46O3LFTkiBDmqvBZh2aOUs
	/iT6efBCnhCEBDnxSyaAb9xiqCJaHm1KkQO8wAY3DUZrlpXceJIRZHphT5Y2dNYWp64JvSCk1OG24
	wVrehRnbwmRLcsrhP4/2LH7SO23gmhofLVJC/Txjkmyyu1SCALyZwAJ089a3NiUww5OuZL/uENZxm
	9+ilgWbtvtjDr2GsbzCWKRlM+mz/Jikh65vgXwbLen0E3jqcn9WG0d9ERZsx/7DnfisQGbbP63wyt
	ZDBzuXLNA==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hvmzX-0005jr-2Q; Thu, 08 Aug 2019 18:18:23 +0000
Date: Thu, 8 Aug 2019 11:18:22 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Thomas =?iso-8859-1?Q?Hellstr=F6m?= <thomas@shipmail.org>,
	Jerome Glisse <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Steven Price <steven.price@arm.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH 3/3] pagewalk: use lockdep_assert_held for locking
 validation
Message-ID: <20190808181822.GK5482@bombadil.infradead.org>
References: <20190808154240.9384-1-hch@lst.de>
 <20190808154240.9384-4-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190808154240.9384-4-hch@lst.de>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 08, 2019 at 06:42:40PM +0300, Christoph Hellwig wrote:
> Use lockdep to check for held locks instead of using home grown
> asserts.
> 
> @@ -319,7 +319,7 @@ int walk_page_range(struct mm_struct *mm, unsigned long start,
>  	if (!walk.mm)
>  		return -EINVAL;
>  
> -	VM_BUG_ON_MM(!rwsem_is_locked(&walk.mm->mmap_sem), walk.mm);
> +	lockdep_assert_held(&walk.mm->mmap_sem);

It occurs to me that this is exactly the pattern that lockdep_pin_lock()
was designed for.  I'm pretty sure things will go badly if any callee
unlocks then relocks the lock.

