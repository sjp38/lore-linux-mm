Return-Path: <SRS0=3S0K=WB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B871EC0650F
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 03:44:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 63723217D9
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 03:44:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel-dk.20150623.gappssmtp.com header.i=@kernel-dk.20150623.gappssmtp.com header.b="IXcfai26"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 63723217D9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=kernel.dk
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B83C86B0003; Sun,  4 Aug 2019 23:44:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B33F56B0005; Sun,  4 Aug 2019 23:44:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A4BA26B0006; Sun,  4 Aug 2019 23:44:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7271B6B0003
	for <linux-mm@kvack.org>; Sun,  4 Aug 2019 23:44:27 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id j12so45374550pll.14
        for <linux-mm@kvack.org>; Sun, 04 Aug 2019 20:44:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=qaevOKKBkx9wzczWsPhokAptJGi+7DJxhR9knuVBhIc=;
        b=kIRI4aIjM/n7234LYCR4QBcUE4HCu0EtlJWGcywsS3YjxaRbatNWjEqlgfPH9DeIqf
         kzwnvAp5gc/j4jod6plmGl3Hmtp6aJCNn3WqQQ1gh3IX/qSpfh4qDg/3rcOJNkhCGaNO
         1t7obfxu+8eY1itQBrQkmADjh/QE35gHaoQ+314wmBdApImw/DEaIbBUYp8dl5Hq1wHT
         BZinYq0RBPs4Lx8xPzG96RXE5ZnIKN2CuL/TZeJzbD1Favm+VLLlperfEBsszCXSA3Wv
         4XtuLLdWotNSdheAprWtgx+nIbfKFwbg3P6CIC1kGk4p7l+EKCUjEad+VPLSS+05RjeN
         z3XQ==
X-Gm-Message-State: APjAAAXUEiqyR4vpqw1TrJB00zCYoTaUJBwWYc6Bv+2Q0E0oTb1yGb9L
	O5m30rJtx0qjK6+EfAXo7QySowcXxaXrPOVb9VzfmXwkowjN7KxumP4Q2cHDM+I9b0a9pTIRyyI
	Y+PUoFO5DTpQ2GDyUWm9sglMYzJmM8C6HTXMSxz0wWIl6Sx9ClNru1Zi245pRJV5ylw==
X-Received: by 2002:a17:902:7202:: with SMTP id ba2mr144909579plb.266.1564976666992;
        Sun, 04 Aug 2019 20:44:26 -0700 (PDT)
X-Received: by 2002:a17:902:7202:: with SMTP id ba2mr144909556plb.266.1564976666364;
        Sun, 04 Aug 2019 20:44:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564976666; cv=none;
        d=google.com; s=arc-20160816;
        b=lbK2DNcKd4hll3UTDaFJvaDqQbg7P4oQ9A+7EqI0+6xSjLL62CarEWDWyZXX6CB5oK
         KNdQRHZ6oUN9T3f7woo7Mkj3eKSDnafpa6ZHh/NR9PGMamhlj0BBLzfqy96EF3bp5eJo
         jokTT22pwy3d5n3c/C2AfMfKdqqNv62sUAmZ231hiJdATrJ19pa/xfgoD0TbpyYtZ/lh
         WwLu56efwTf2B/Uiwqowmm5TNIwvW+pHlOuQ0hrgwC5EjnB3C9rHYsAPwYB9/azoEvAv
         1wNVGZ1lRe9O4Uy92nWVtNIsdkVSV/aaNUAqO0CSk13F8nxranIVMpqWWMM7zza7iGlH
         Z8lA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=qaevOKKBkx9wzczWsPhokAptJGi+7DJxhR9knuVBhIc=;
        b=wOAlr+7KR28QMxBodQyfXo4/ffBApcfq5mUzRki0wxu670F4OibmKPv/qJqU/hKMLr
         GRmAmPKQ3mXOC3hPDmm77cI/b11NAhkb5ZN2J8kXkbQ1bL0sizA4OKh1r1YIFndVPWlX
         kndbjGExTrUBnek48K6Wq8zZbOYp8eCnofCiH1W6lBXEAJ9YGTIRA40/OcZSRPUnY57k
         hJWm94cJJBpRNefycCxgKwv9oaKfx3X2Oo+ZHShSRdkBTVW3VkK/ucjDcf4Cdxmnqu+w
         hoo470GgwD76Rs95ZGIEq8DuG3GAWhs97fIHvD8OylienL0ABbzdY6hv4m/nobNHxmM3
         8e0g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel-dk.20150623.gappssmtp.com header.s=20150623 header.b=IXcfai26;
       spf=pass (google.com: domain of axboe@kernel.dk designates 209.85.220.65 as permitted sender) smtp.mailfrom=axboe@kernel.dk
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id cu6sor18710625pjb.22.2019.08.04.20.44.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 04 Aug 2019 20:44:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of axboe@kernel.dk designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel-dk.20150623.gappssmtp.com header.s=20150623 header.b=IXcfai26;
       spf=pass (google.com: domain of axboe@kernel.dk designates 209.85.220.65 as permitted sender) smtp.mailfrom=axboe@kernel.dk
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=kernel-dk.20150623.gappssmtp.com; s=20150623;
        h=subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=qaevOKKBkx9wzczWsPhokAptJGi+7DJxhR9knuVBhIc=;
        b=IXcfai26P/X8GzjqUOtmAH/Jo83R/2UjSztaety4x290UiwGJr62Nqbed+2gcSQnQq
         dqrgQtS9ocweR9XW2Mm9pHhrHFFRMBaxYLcm1pzOCTxIROUS9hvQ0qWmtamBqxPLZnOT
         EhjWLNHhSgeW0KfvyTB5RDtd5Dx9aJd7gcu2qMZsycPbBk5FRPwlnfzs1JqQpV41O2NT
         TPWPxUu0Sy5kUJDKrSn5SMTtpXqbO/vsBlmx8w9Dg1h8usHVPrStDNgIQeda0jezkGNQ
         kPsX+LoS4FBe/97ALO78rYF45eRlRbbdHtywIrV0PhhVjh1e7t5mswweENmRPEKXbsYl
         gxSQ==
X-Google-Smtp-Source: APXvYqy4lnuT+Nq4f5lxPk3nmqptozGkTW1Nn0qcFMewuAbFZKOxXjof5Tv5YsVkUmYJ47dOKqH08g==
X-Received: by 2002:a17:90a:376f:: with SMTP id u102mr16333110pjb.5.1564976665920;
        Sun, 04 Aug 2019 20:44:25 -0700 (PDT)
Received: from ?IPv6:2605:e000:100e:83a1:61e6:1197:7c18:827e? ([2605:e000:100e:83a1:61e6:1197:7c18:827e])
        by smtp.gmail.com with ESMTPSA id t8sm13977229pji.24.2019.08.04.20.44.24
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 04 Aug 2019 20:44:25 -0700 (PDT)
Subject: Re: [PATCH] fs/io_uring.c: convert put_page() to put_user_page*()
To: john.hubbard@gmail.com, Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@infradead.org>, Ira Weiny <ira.weiny@intel.com>,
 Jan Kara <jack@suse.cz>, Jason Gunthorpe <jgg@ziepe.ca>,
 Jerome Glisse <jglisse@redhat.com>, LKML <linux-kernel@vger.kernel.org>,
 linux-mm@kvack.org, linux-fsdevel@vger.kernel.org,
 John Hubbard <jhubbard@nvidia.com>, Alexander Viro
 <viro@zeniv.linux.org.uk>, linux-block@vger.kernel.org
References: <20190805023206.8831-1-jhubbard@nvidia.com>
From: Jens Axboe <axboe@kernel.dk>
Message-ID: <fe0b9303-fce0-e7a8-a27d-af8e3903f097@kernel.dk>
Date: Sun, 4 Aug 2019 20:44:23 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190805023206.8831-1-jhubbard@nvidia.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/4/19 7:32 PM, john.hubbard@gmail.com wrote:
> From: John Hubbard <jhubbard@nvidia.com>
> 
> For pages that were retained via get_user_pages*(), release those pages
> via the new put_user_page*() routines, instead of via put_page() or
> release_pages().
> 
> This is part a tree-wide conversion, as described in commit fc1d8e7cca2d
> ("mm: introduce put_user_page*(), placeholder versions").

Applied for 5.4, thanks.

-- 
Jens Axboe

