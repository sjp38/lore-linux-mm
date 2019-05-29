Return-Path: <SRS0=FSMz=T5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 268EEC28CC1
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 19:49:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E2B6724109
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 19:49:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="aZ+H6638"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E2B6724109
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5F28E6B0266; Wed, 29 May 2019 15:49:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 57BE66B026A; Wed, 29 May 2019 15:49:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3F5DE6B026E; Wed, 29 May 2019 15:49:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 01FFA6B0266
	for <linux-mm@kvack.org>; Wed, 29 May 2019 15:49:00 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id j36so617173pgb.20
        for <linux-mm@kvack.org>; Wed, 29 May 2019 12:48:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=OLgwDGpkIUZU8BMYV5tPlIqkgGPiffjQ+cEUtOoxAWs=;
        b=iYc7yissUkU27ybzdeFnVcFtBNT8rXmUVu9i2F7rG4plJJR9+50fL8mZCrZm7oG3sg
         6KrAo3MLc1FSA+T1YtEZ8wLukM7her05jR2Q7LpN8iN4OJpQMYY8O6oIziM+JkNSRnfO
         gsivUzSro0A43+S0UK4rYnNjXMU9gccT29MeoNLq694EPnyTH9SoIzJudFOccci+yf3g
         nH2oQlKOiRB1GckGKqmIixxDwwK4bc/3vPmJDVYDPYpYWftZ3i9wgf8fDXzoZQCo6AKm
         M3Pi1D8ko9cLJV8WEr/ewTsRIT7ovaxbgLN7HMG64t1FGR7KIR91wZPxgj0obIF2AoI0
         LDnQ==
X-Gm-Message-State: APjAAAXlIJNnqhd0+m+t0xra/SEi6UUhaiJV5hURT9EsZrTLafEBJAq4
	7TrH15JghZJA244ZSsb6BstBPwGNakzb1kVWUKdhy4qa1Rvcvr4dyaMQ1nZPsHS5fnui64Y69O2
	qsXW9+OWio32/L9kCYf6/09BjbbYvuemRZTo23bLw3gfHIw/ZOBDuAXUfEB1NP+o+kg==
X-Received: by 2002:a17:90a:5d0a:: with SMTP id s10mr14355413pji.94.1559159339581;
        Wed, 29 May 2019 12:48:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxbBOHQyfKp/T8YaVd3IUNHyMEiMX3kAc0peMFU7YoOZQin4xY9KzsTZHWaNWZGmAQWH9rf
X-Received: by 2002:a17:90a:5d0a:: with SMTP id s10mr14355332pji.94.1559159338734;
        Wed, 29 May 2019 12:48:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559159338; cv=none;
        d=google.com; s=arc-20160816;
        b=N/7eDJFAa52B9HUfSv2y+/2neFjJG/RvrPM7bJDpKHMHvLB9WkP2q/f8iq9h19oROP
         rXSY+5ajLQftS8Ldn0oxUDZejVB7P77I7cfIQosGne5/V6Os+z24/DiWj9Ode6ZUyUvG
         muUoRxT9zMaxJhOCan2sdmwjvmzWkXhDPDjiIXlPNiY779xWLQRCbixogIrYcbO1AQj6
         HEyeu0RnlIqy7eDsbNbdqrLQmfgeSVRxzTFEAgt1C/AcjeJYQuTrvB0iRbdAg28bGLSf
         NZeW5LBTNphokAw7AUAg0I4WJuRoYSzZX1gcMd8ZkO0FFc7mqDe0cUrU/JMCsoW5GKm1
         ofUQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=OLgwDGpkIUZU8BMYV5tPlIqkgGPiffjQ+cEUtOoxAWs=;
        b=vDz3D065SX70g8xoGJEBoIcKxtcF+JrTc36uoQfnKGFPqBKwaC3DcQXNycRTFbuHhZ
         chWQg0+xMhF7mkYwhGrEc/ysHkHdb9UvM3rzK6AER4U8zXS7HgLKm5r5PYHxZfimromP
         j+3Xn7CPdVVixbhDwXaVSHN42zr0/VKNwXZyG3QNOyQGZFgZwGzPHmXWkehojldJsLKn
         T26a2mL7csmG0PeR4pnI8YfPWXwUkxKHNkQmwpc001Or5FRsBHsnSVRa/WSi+53+zYbF
         zAtJOYLigb4cSf86n0UJTqenzS/D9j9wOv8ebUGVzuHKqg0oJP0yeWszd+PKSy1b8EPv
         fb0A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=aZ+H6638;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id f14si768242plr.1.2019.05.29.12.48.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 29 May 2019 12:48:58 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=aZ+H6638;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=OLgwDGpkIUZU8BMYV5tPlIqkgGPiffjQ+cEUtOoxAWs=; b=aZ+H6638Jr/eJP0r9vD0KZOpZ
	Q1YIKRNl65MHD/BNONUIH2B8tKseMs0w+wEioKPL0iKwh81FIbuGWIZtRDJ6D9WdJUVI7X9Ht/z++
	0vR/yJRNbp4zW+UDATrpA/AtNqjdTkQWo+qR6sHknI9YyqmF2MyeS84krXwWRxI8h7lS+Ur++4Juu
	eU93kc6SKCDgxQa7TTwyAJahGzjffDvHdSn4/jYBH/GlXXh6lBa1bcTl7cY+t9cI4FB/xzrlD/Su3
	GGXvQyfSr+0xvyFE11rK50ZOUejNc3WniZr2FLkzFQ2QGlOhNia2FlRjwoOH++DuqySvTe35ynqvg
	5RhkqLWeg==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hW4ZA-0008Gb-LH; Wed, 29 May 2019 19:48:52 +0000
Date: Wed, 29 May 2019 12:48:52 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Dianzhang Chen <dianzhangchen0@gmail.com>
Cc: cl@linux.com, penberg@kernel.org, rientjes@google.com,
	iamjoonsoo.kim@lge.com, akpm@linux-foundation.org,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm/slab_common.c: fix possible spectre-v1 in
 kmalloc_slab()
Message-ID: <20190529194852.GA23461@bombadil.infradead.org>
References: <1559133448-31779-1-git-send-email-dianzhangchen0@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1559133448-31779-1-git-send-email-dianzhangchen0@gmail.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000004, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 29, 2019 at 08:37:28PM +0800, Dianzhang Chen wrote:
> The `size` in kmalloc_slab() is indirectly controlled by userspace via syscall: poll(defined in fs/select.c), hence leading to a potential exploitation of the Spectre variant 1 vulnerability.
> The `size` can be controlled from: poll -> do_sys_poll -> kmalloc -> __kmalloc -> kmalloc_slab.
> 
> Fix this by sanitizing `size` before using it to index size_index.

I think it makes more sense to sanitize size in size_index_elem(),
don't you?

 static inline unsigned int size_index_elem(unsigned int bytes)
 {
-	return (bytes - 1) / 8;
+	return array_index_nospec((bytes - 1) / 8, ARRAY_SIZE(size_index));
 }

(untested)

