Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A97D1C282CE
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 13:49:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6553D2080A
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 13:49:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6553D2080A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 17CC58E0014; Tue, 12 Feb 2019 08:49:50 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 12C658E0012; Tue, 12 Feb 2019 08:49:50 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F378F8E0014; Tue, 12 Feb 2019 08:49:49 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id C79EA8E0012
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 08:49:49 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id q17so2712374qta.17
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 05:49:49 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=W/onbmx2FIi+5eaFeSaLj8Y5pxYi5HlmQ1a+UOJy8ZM=;
        b=HYon0ael2eZjkbxXErtH/p5cz3fVmTF5MJJjwQHNX8hT0rUDdJgXFwFck4CCN4jjbw
         qpuO5TGBAz1DNHRBtqjQzvngdMabMbL1U2kNwVTW5pl7CXCGGMHV/xaqErrW//oH1IeA
         dhFBY/jzgRAoYhH5Jm+JQVqwNqQ+IFNRnBXGsV9Hup166qEQ1lUQgw4sYGu7PGkYUluF
         kWTX/vNpYhGoscgNetECVWGG/nVwVGUum2hKDVufFBS8/sV+Ui5czrtiVy8JKruHqRiS
         fMFFoVRAGa+iZrB6dzSBjd2Rt77j3X0pLrVwejzq/YDClIUrOuFNF7WfGRh+ikiDALbz
         i7rA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of brouer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=brouer@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAub90k9fPQbWuGqEZwFEdzAWcvyjDrkfxZTLLbJ6aqWaYhtH6WnF
	yeOatRKhRbM8y+V6r7KhWnAH0ijprGcY5TNHasGNc4F/0Fn4W6iqSCXqRKX1jKrj/d+rZvHhXVm
	SHbgEt9G6es5c+OiO9H6dSVkW/YrMh6OV0GWEBRNG+Gb0Q8/3e2NKwUdbkYmglL4mBw==
X-Received: by 2002:ac8:3361:: with SMTP id u30mr2835639qta.5.1549979389537;
        Tue, 12 Feb 2019 05:49:49 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbforYWqfz1SahM2mlUfqer5d2yLvBZsKf6lMfki2QPufY4xjjdg/TsQbOmaxNKU/cD764L
X-Received: by 2002:ac8:3361:: with SMTP id u30mr2835607qta.5.1549979388997;
        Tue, 12 Feb 2019 05:49:48 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549979388; cv=none;
        d=google.com; s=arc-20160816;
        b=dGfT/wjfPRqY6L6YF2huaUgF2tZRszTn8Ze1TZi4ZyEZoYUqGPopv+H2y4sD8LFMww
         8zf2vxcvfVqDJezkHfsGEu1YdY2T1R5UXzgTkyvuYV4msQUNZj3SmfiaW3FiWyHtu/Q4
         o97WpRyCnZksHJlJzXdu0a9IhP5CU8zeO2D/zE+V+TAG3d5CZGwTjKJZClJdMIUgv5DR
         hyk1VXBP72XVd2CeKT886JOo4tqz81a9Rl40fKvRWfPX7T2fPb9AU6bISTuHN6NLdqJs
         MZ6VCg/slgmfl/zD4g+NJiVKvMNdIqMr84cDzMK8nd7iYKVl/4RqYu8amtwkfKZda+6R
         ANZg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=W/onbmx2FIi+5eaFeSaLj8Y5pxYi5HlmQ1a+UOJy8ZM=;
        b=aCejf/qnYwBtDksEKWjMMon3SEysbwZDYPbIX2VkX4yrQ3jGANiZStlEdbw/nu/NpY
         MYLV9QrJ5iJo4ez+/r2CJcDC8vYhLnU1qKJeyrOPKT1JDTpAHQChXKD88rE2vX3pgqu3
         0mnHqqJ7tCYfK73XjjHeF9re1MKWgJsKUgGLXJG39qPco7YPoUfkYElcazeo3XSk4r71
         FCS6iIb2W9jNeik+4ToLj5gL0G3ElfMd/RVTJo6F2nL3gm6wj+ciW8H5sSRQ0o1/5w7O
         2wcGFNQcJj0X7SvRm1RJO2AYwNt6MsD0B0ucYIKgmyn3wVhrQ7zhOp+3kd8IQ5bjeD4S
         PUBA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of brouer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=brouer@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o17si2365016qtk.304.2019.02.12.05.49.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 05:49:48 -0800 (PST)
Received-SPF: pass (google.com: domain of brouer@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of brouer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=brouer@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 160CC90906;
	Tue, 12 Feb 2019 13:49:48 +0000 (UTC)
Received: from carbon (ovpn-200-42.brq.redhat.com [10.40.200.42])
	by smtp.corp.redhat.com (Postfix) with ESMTP id C873A5D736;
	Tue, 12 Feb 2019 13:49:39 +0000 (UTC)
Date: Tue, 12 Feb 2019 14:49:38 +0100
From: Jesper Dangaard Brouer <brouer@redhat.com>
To: Tariq Toukan <tariqt@mellanox.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Ilias Apalodimas
 <ilias.apalodimas@linaro.org>, Matthew Wilcox <willy@infradead.org>, David
 Miller <davem@davemloft.net>, "toke@redhat.com" <toke@redhat.com>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "mgorman@techsingularity.net" <mgorman@techsingularity.net>,
 "linux-mm@kvack.org" <linux-mm@kvack.org>, brouer@redhat.com
Subject: Re: [RFC, PATCH] net: page_pool: Don't use page->private to store
 dma_addr_t
Message-ID: <20190212144938.36dd45b4@carbon>
In-Reply-To: <27e97aac-f25b-d46c-3e70-7d0d44f784b5@mellanox.com>
References: <1549550196-25581-1-git-send-email-ilias.apalodimas@linaro.org>
	<20190207150745.GW21860@bombadil.infradead.org>
	<20190207152034.GA3295@apalos>
	<20190207.132519.1698007650891404763.davem@davemloft.net>
	<20190207213400.GA21860@bombadil.infradead.org>
	<20190207214237.GA10676@Iliass-MBP.lan>
	<bfd83487-7073-18c8-6d89-e50fe9a83313@mellanox.com>
	<64f7af75-e6df-7abc-c4ce-82e6ca51fafe@gmail.com>
	<27e97aac-f25b-d46c-3e70-7d0d44f784b5@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.29]); Tue, 12 Feb 2019 13:49:48 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 12 Feb 2019 12:39:59 +0000
Tariq Toukan <tariqt@mellanox.com> wrote:

> On 2/11/2019 7:14 PM, Eric Dumazet wrote:
> > 
> > On 02/11/2019 12:53 AM, Tariq Toukan wrote:  
> >>  
> >   
> >> Hi,
> >>
> >> It's great to use the struct page to store its dma mapping, but I am
> >> worried about extensibility.
> >> page_pool is evolving, and it would need several more per-page fields.
> >> One of them would be pageref_bias, a planned optimization to reduce the
> >> number of the costly atomic pageref operations (and replace existing
> >> code in several drivers).
> >>  
> > 
> > But the point about pageref_bias is to place it in a different
> > cache line than "struct page"

Yes, exactly.


> > The major cost is having a cache line bouncing between producer and
> > consumer. 
> 
> pageref_bias is meant to be dirtied only by the page requester, i.e. the 
> NIC driver / page_pool.
> All other components (basically, SKB release flow / put_page) should 
> continue working with the atomic page_refcnt, and not dirty the 
> pageref_bias.
> 
> However, what bothers me more is another issue.
> The optimization doesn't cleanly combine with the new page_pool 
> direction for maintaining a queue for "available" pages, as the put_page 
> flow would need to read pageref_bias, asynchronously, and act accordingly.
> 
> The suggested hook in put_page (to catch the 2 -> 1 "biased refcnt" 
> transition) causes a problem to the traditional pageref_bias idea, as it 
> implies a new point in which the pageref_bias field is read 
> *asynchronously*. This would risk missing the this critical 2 -> 1 
> transition! Unless pageref_bias is atomic...

I want to stop you here...

It seems to me that you are trying to shoehorn in a refcount
optimization into page_pool.  The page_pool is optimized for the XDP
case of one-frame-per-page, where we can avoid changing the refcount,
and tradeoff memory usage for speed.  It is compatible with the elevated
refcount usage, but that is not the optimization target.

If the case you are optimizing for is "packing" more frames in a page,
then the page_pool might be the wrong choice.  To me it would make more
sense to create another enum xdp_mem_type, that generalize the
pageref_bias tricks also used by some drivers.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer

