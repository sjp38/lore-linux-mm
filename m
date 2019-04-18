Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E394CC10F14
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 11:18:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 840292183F
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 11:18:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="SGzmY92g"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 840292183F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E1A3A6B0010; Thu, 18 Apr 2019 07:18:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DCA626B0266; Thu, 18 Apr 2019 07:18:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CDF586B0269; Thu, 18 Apr 2019 07:18:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 972B86B0010
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 07:18:48 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id 33so1170843pgv.17
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 04:18:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=MTWvlBGcxn9p8FR3xNRCHkLm1a2gvjsLaACCdCKLnec=;
        b=eWabgg3rlpgWtoZH7vc9uEzIvFEtagZBRXndbv5lMk0wbzII75TNvJKLuyfWQBmU1O
         6qLtfqXKe/0h3n/QXjKT67QolhTHxfxTm/swC7Sww+rSJsMMzQnEVlFy427ezeamAtBI
         WMuvwUmdPgHUKrjQ0oGgx5W+NfNaa9fm3fGZEgp5mkURDfOQ7FbuyBiD7U8Vmgt4Aav2
         R8LohTipLhgLd9G9TJdLGjIHFEUfw0f9G85P1cwR9QfXZvR9xvnDPp8bnJOoDbYH6oVa
         HqHtXgBTS7l7mnDTjI1TzAXX8VV0bGPh2Gds1l2C0Ww7Vko7jYlMotg3muzD85w03w3p
         tr2A==
X-Gm-Message-State: APjAAAWGqgW8eVTbx063PbxxST5ZkaHdIAVz18lXuyY7vERDXxK43hEb
	jfXgoptWqIM0Lpv9BI80z5Sgu60LF1DAN9T/OwMkLreRb+u4sMiyc5938VKjYXrA5MiAnANabhJ
	T+bErEGjSeXJAEa9/4as8eNVWzi1lha+zkdSfH2ZGkofOfDVkApBm3UT3LjxFKZpGeA==
X-Received: by 2002:a17:902:9686:: with SMTP id n6mr51907736plp.282.1555586327771;
        Thu, 18 Apr 2019 04:18:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzJJYQ38kF7qgAzmVgXmWA+ufMvpe1ldwsRx81o5dSg30WjGTA8mkNUBmDZQ+PIixIzoJNy
X-Received: by 2002:a17:902:9686:: with SMTP id n6mr51907673plp.282.1555586327009;
        Thu, 18 Apr 2019 04:18:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555586327; cv=none;
        d=google.com; s=arc-20160816;
        b=SZMgzUcxJqyv2csnlt+fQvmJR8ykyKNZ0v2JUYxEgQiZJp2hN0Olpn3+ZzpT32qsYa
         CwcZm1f5pZCkIXwXV0QLUHSfeS2eQDz0e3TVPM8d3qIn0SWt5Y0Z/bgJFtMNlEc7KxpS
         DhN0nIe4VEep7ZjJWiDIU0fGT+wMKGulx52gqYQy0pyAAIOFEE6OFdYJRUqqHO5JP8JO
         w5RxqwyTnTqRhSEtIe+FFCQKHWKUG1G/N1ZhsUkmyR+Q+KjvKJP0MSgjF5ghx8lvZ92/
         kIOWmTkryn4Zf6/mgPX/HBGfDCsOoIFePsLLldzlWWWv/JtYuVGM2ZeFQsMz4pH/gQr9
         horA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=MTWvlBGcxn9p8FR3xNRCHkLm1a2gvjsLaACCdCKLnec=;
        b=zlNn4nKPL2AlEanlYQHIcSZVIpXhaYuJmHGtXFwMDXWFAsDuvUobHf/i8qz0fAQ0y4
         ce5wIYcVkCcdrDUclWmqBVR6Bby0jRglI0K5rroMNDrvM4Z+ZAg96XDNh1CMZ+4H4Wag
         EwXnX2HLxjzRxSNr7e6wl0RtnlXdupq5oyqTFXeYEQAvKHY9BB7N/INRxbahvz++e2uJ
         LWCMJnAKrrVVfS2N62DJyjpCua8C3K40mehPGNI+Io8HBNL/pf5zBToGSZK2QYKpwtu3
         Od/7sXeo1n6D8rkXgclX8cZWJJZd4sF/RtteGWvG6TjPtVilnkp3cmSWg//b4DiPtmP0
         IYLQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=SGzmY92g;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id h189si1623841pge.378.2019.04.18.04.18.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 18 Apr 2019 04:18:46 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=SGzmY92g;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=MTWvlBGcxn9p8FR3xNRCHkLm1a2gvjsLaACCdCKLnec=; b=SGzmY92ghxsMhmzlBuin913fI
	/+o5g6YsxrK7Fp5r8fX/4EJ0GcGp9GrtntToMJbYLeqW3dZJDBXvhJ0ItboRp5ZLFTvnXdoN+crY/
	gz6AU6iXTqUPJstsFJHxGKv4W4BXHZw9pRE+jd6u6kdmg2QDE3U27rHMrC7vxB8t26Zc3ZiIDiEh1
	JgBIvTy1kdkGg0J6VLNDitmFJ6VdDPpIvJH98ytffJbwqg7DU+09yemWAOU4eQuikT8XkxSe09/TY
	6+sYhftp+jG99z8NJZQGfvgm4InbKAnYJtpNdqQoxXK2nqjnkCBasoMyOW3Pq53OwOclJdu/jPeBj
	okUu0Y0tQ==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hH53r-00027y-4L; Thu, 18 Apr 2019 11:18:35 +0000
Date: Thu, 18 Apr 2019 04:18:34 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Roman Gushchin <guroan@gmail.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, kernel-team@fb.com,
	Johannes Weiner <hannes@cmpxchg.org>,
	Vlastimil Babka <vbabka@suse.cz>, Roman Gushchin <guro@fb.com>,
	Christoph Hellwig <hch@lst.de>, Joel Fernandes <joelaf@google.com>
Subject: Re: [PATCH v4 1/2] mm: refactor __vunmap() to avoid duplicated call
 to find_vm_area()
Message-ID: <20190418111834.GE7751@bombadil.infradead.org>
References: <20190417194002.12369-1-guro@fb.com>
 <20190417194002.12369-2-guro@fb.com>
 <20190417145827.8b1c83bf22de8ba514f157e3@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190417145827.8b1c83bf22de8ba514f157e3@linux-foundation.org>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 17, 2019 at 02:58:27PM -0700, Andrew Morton wrote:
> On Wed, 17 Apr 2019 12:40:01 -0700 Roman Gushchin <guroan@gmail.com> wrote:
> > +static struct vm_struct *__remove_vm_area(struct vmap_area *va)
> > +{
> > +	struct vm_struct *vm = va->vm;
> > +
> > +	might_sleep();
> 
> Where might __remove_vm_area() sleep?
> 
> >From a quick scan I'm only seeing vfree(), and that has the
> might_sleep_if(!in_interrupt()).
> 
> So perhaps we can remove this...

See commit 5803ed292e63 ("mm: mark all calls into the vmalloc subsystem as potentially sleeping")

It looks like the intent is to unconditionally check might_sleep() at
the entry points to the vmalloc code, rather than only catch them in
the occasional place where it happens to go wrong.

