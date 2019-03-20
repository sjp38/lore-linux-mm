Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 94A85C43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 11:23:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4AD522175B
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 11:23:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="k/O7iAIO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4AD522175B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F01F46B0003; Wed, 20 Mar 2019 07:23:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EB1E46B0006; Wed, 20 Mar 2019 07:23:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DA1D06B0007; Wed, 20 Mar 2019 07:23:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 988486B0003
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 07:23:05 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id f12so2446234pgs.2
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 04:23:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=RwGTGene4l5p7MPYR0Zrx0BW45jaABhyE21chVO0jp0=;
        b=Pm3jrYLgKG8rF0uft6Di/zK3w/Vs9qdrCJW8yBz22BvH7p8Ur0sRWDK3UHsV5wB3g1
         QotJ3jvetJoD4PgGZOXYq2u0kUTPxxEEv2BeekthPIvfUTWJ36iEEbsU9sUPscU0ykAh
         iI+iUsZKT87/PDBPtGLshv0/zhWeO/bMnvvIBrMHVdcdEwa6JvOQkc3j9E24cZpQs2sh
         kr2baJbbyN2t6EWUvoHKnqpFl9WVt2aJ0azD0YtOyGyksWWYF077oivZVUg2bTm+MmAm
         rErHNXIMPAgLKZX6GGyZDEcPQz13fPUuu7n/6oqKiIGH91ocJkB67uxD1hPvZTOjjLkJ
         v7Zw==
X-Gm-Message-State: APjAAAVVxGtpmSce0fqkNMIhLuH+E9lKtH6TfMWDxIze16MB7pQ3y1KC
	RIw8o7v8Le6QIzMmPdZQokTIXtJNz8GUp37L1IMPm5mgrInDYKpCY35YKFR9XoYAV/9NL89rOtH
	fQbNXRd0KCQ9ZVkhAOcrTBeQRenk8rm6M69LXdpIxtmqalC8n+hINEu12oxXBzTEoIA==
X-Received: by 2002:a17:902:526:: with SMTP id 35mr7011089plf.276.1553080985179;
        Wed, 20 Mar 2019 04:23:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwseH0/YkJluEoR62eaT6g2g2lZNP7HTPSVFskZQy8lOBZy70kpowuZI82Q1eAtvtt9mmo9
X-Received: by 2002:a17:902:526:: with SMTP id 35mr7011045plf.276.1553080984529;
        Wed, 20 Mar 2019 04:23:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553080984; cv=none;
        d=google.com; s=arc-20160816;
        b=j7Lau5aGAVqGfsjy56iSnCYnVC2I6UHxhBbS1FntTA27L9IzSDUWBtKdj/rQYHb4Js
         K/ZhHWNmLUMtzwxTT5TFWNeYdbvDpZy7BdXft9BEENIXVtHgyr9dY6D9gGsg5uDi7hGY
         GnP+KqGMI4tLGmYMeplc8OEMPwRNGy1nYYwiXBENSoQ7TWncAcDrwgxxeVHHaRvwNyJX
         xuDHZ+mWvobQiRMvZAQqFvMPVRMn9Ngu772WT/QWcAHxVOoX9VhBa6YED6tScWtTERdl
         MX9Y0tLsn8Bh+yMS6qdD0K0i/HOl6S9CHffSpxVk7NM7VIvdYW9NU3v2xWuHW2buYhKA
         S2mg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=RwGTGene4l5p7MPYR0Zrx0BW45jaABhyE21chVO0jp0=;
        b=sdyZdZGcTLT6CsBDgiG8c7on922UcMeeogbC6enUjxap1qC+cr8li8tOZN655kHfuX
         uz0nGbGJmqePbowKSZtVCAhtbgqGKBr2E59PBTRbfp3YFoawVdLqoqrk4p/lO/SHIZgG
         7aTh1LTKHbAauvwa24p4ju83sQpCDverY3hS9J3IN5JQfokGmvAJTeCGcCnXwNxYwSkX
         WwGaLXGxZXvVQ1VBMkMSDQOI5JkybJe5FeQl/kkgHSzyZ7QKmMjCCxemo1jEeyrT98rC
         iKIkAjMxd9s2yp+hFxRR6Oq1KyuCPthAr9kxLIWfUA7lzEicqmvSgFjPEjiK1uGR0Jd9
         L+1w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="k/O7iAIO";
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id e2si1770937pln.45.2019.03.20.04.23.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 20 Mar 2019 04:23:04 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="k/O7iAIO";
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=RwGTGene4l5p7MPYR0Zrx0BW45jaABhyE21chVO0jp0=; b=k/O7iAIOy9XbE3sh69klrAVTq
	4cC5oIxDGGC83Oxv0x9dsSXQKLi+Cbcki8gQGz0c457zT9Nw5R3c/qIhXQAq4Yi9fOicr5+jNPuWl
	HC5JiD7oJ5ZZQs10oPO3Nl3lbqzALRVJ5MUDKYjuZsMZscYu9HeWzBxxWPrIbJ3kOMIJdbcoSskbC
	6kwxZCifdyDGrBv1mBkXrU3b6smoTk+35HDCQgQCIp7mHKx5EdHRZdTPr7dEj6KP85c9RNNtsoDJa
	A8HffEJUJmqWQJ9+8LAA8dVoJQjvX6r1LSbgz9y0AbDtPhxj82svcM+sijBQIjfiVpPlHQKoRUJ25
	HwJBJKDwA==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1h6ZJD-0007OI-MC; Wed, 20 Mar 2019 11:22:59 +0000
Date: Wed, 20 Mar 2019 04:22:59 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Baoquan He <bhe@redhat.com>
Cc: Mike Rapoport <rppt@linux.ibm.com>, linux-kernel@vger.kernel.org,
	akpm@linux-foundation.org, pasha.tatashin@oracle.com,
	mhocko@suse.com, rppt@linux.vnet.ibm.com, richard.weiyang@gmail.com,
	linux-mm@kvack.org
Subject: Re: [PATCH 2/3] mm/sparse: Optimize sparse_add_one_section()
Message-ID: <20190320112259.GW19508@bombadil.infradead.org>
References: <20190320073540.12866-1-bhe@redhat.com>
 <20190320073540.12866-2-bhe@redhat.com>
 <20190320075649.GC13626@rapoport-lnx>
 <20190320101318.GP18740@MiWiFi-R3L-srv>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190320101318.GP18740@MiWiFi-R3L-srv>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 20, 2019 at 06:13:18PM +0800, Baoquan He wrote:
> +	if (!memmap) {
> +		ret = -ENOMEM;
> +		goto out2;

Documentation/process/coding-style:

Choose label names which say what the goto does or why the goto exists.  An
example of a good name could be ``out_free_buffer:`` if the goto frees ``buffer``.
Avoid using GW-BASIC names like ``err1:`` and ``err2:``, as you would have to
renumber them if you ever add or remove exit paths, and they make correctness
difficult to verify anyway.

