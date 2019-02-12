Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D7289C282CE
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 18:19:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A31B9222C0
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 18:19:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A31B9222C0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 325838E0002; Tue, 12 Feb 2019 13:19:26 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2D5928E0001; Tue, 12 Feb 2019 13:19:26 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1C49C8E0002; Tue, 12 Feb 2019 13:19:26 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id E4F0E8E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 13:19:25 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id f24so3616993qte.4
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 10:19:25 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=aU+3qxSN70gh0pMTari7drSkOhCiBMYN8BGy7xRa7/c=;
        b=kd0ntbmyGHoMXMkE1/9EVz5E9IZ8urAskJuD69/VRNisPHKkKC8Z0YZSUBbzc5jqWQ
         z39K+xwcFjAeWcOfNEJFBlNreHWQooYx3KdDyv9VleZrFM58yqKSJjQkjUliWFcwTLxg
         AEJNxI8b3G7C5fahGsbscil8CzQ71ED5z+FhQZm9UYwbx7Kgsnqpdg2S65Fp2BeZGnkX
         vJPURqd2W3UkB+/CT/omTSEVx45jElgSdRBehG4sziC3s/XgpssqQYOEwi4TO8G+AB0i
         HVZNtWpcEy9gFqJnuB5biGZoqgYEItVvGdvdcw7dg7Qq8P/XUEAAe8/9yhf9tzQCe3Kb
         P1fw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of brouer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=brouer@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAubpyj4qKIWlIf+ZdkpryHAr7EKLYA0eUN69sx4R297E8jGBLoUE
	rr351cZGvVRAv5LbgbaxgvPf1PK2Lc8s+hv08xtdfdEoWW5DCYEkDm6HYNilOcWAIYOIP9APUSN
	rEk8yaQFaUrmREv6JPbWqAyCB0E3ily5BQLobslQe7Q6f752iFNaWGZD5VC9F5qmbpA==
X-Received: by 2002:a37:5b47:: with SMTP id p68mr3560904qkb.299.1549995565685;
        Tue, 12 Feb 2019 10:19:25 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbHZ4MRW1safCjuPLPs8Fa+2ubsCqa0HQHPw1XwFO8H1t8Q0kkUdMfFu86dPvZzYq3QjMcR
X-Received: by 2002:a37:5b47:: with SMTP id p68mr3560878qkb.299.1549995565164;
        Tue, 12 Feb 2019 10:19:25 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549995565; cv=none;
        d=google.com; s=arc-20160816;
        b=JgGcqOGsjsDBHbQQNWgoV+sXRMa8fa2AUgUQnCOc/jOM/eU6ptQY9uaE9Z+Be03gIx
         o0g2SZMM+NhUFwiUuLRgHq5jjNMByHTlw1lQDJ6h9MKZ4H0QpyfRW4xZnu4A7yFYKAbS
         Hgxnqs/PCeXJpAwd9AW9jdqYfDoVP7WVGG0vKeyOK2YNvmQrAF7avvycmcAAivk1KzV/
         ids1rxdAnGxl1I5QKuyB2y3VAnOK31tJUgxCTZIaQMo5oaCbArzfp4WmSwOmbKoypGtb
         IjVMRGXdj1xNyVKU8Kt0NFYJGuxOCLYRCAr/pTSNCE9anCiwbemn3XJsPdfokdPzSsn6
         t5jw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=aU+3qxSN70gh0pMTari7drSkOhCiBMYN8BGy7xRa7/c=;
        b=c7fgKK1XfvljP+KSlS+lvhdKPvM6iJovVJyH4C00MO3DuQfa6ZXc314jLv8Zg8xWZo
         4qcLus+7b8f9HuWgU1LFSipH6d4xyjft8jltNo/Hgu8uzToGDOKQBH21i7shoFFHlg9o
         szWLHMoqcdS/LJkEEpS0cp2tzkaxOt8fAmCANh5oMVUNH3ZJm6uLPDzl0h0D+SYdoKsj
         NUcGX+mwULbXM9UFG8JL5JFQO+Gtzm268w1Dp6gdWELQsn51mIe7+RlVGCsmqKzFduq/
         C3xixqWibS5M7zGtwcmL+nAjGhjCQNbk6KqXxpc46PNGFA+6bkNHypnvqZfGfeiTtpN4
         XSyQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of brouer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=brouer@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c4si3182747qvo.215.2019.02.12.10.19.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 10:19:25 -0800 (PST)
Received-SPF: pass (google.com: domain of brouer@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of brouer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=brouer@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 7A5ADA428D;
	Tue, 12 Feb 2019 18:19:23 +0000 (UTC)
Received: from carbon (ovpn-200-42.brq.redhat.com [10.40.200.42])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 1AD1D5E25F;
	Tue, 12 Feb 2019 18:19:18 +0000 (UTC)
Date: Tue, 12 Feb 2019 19:19:17 +0100
From: Jesper Dangaard Brouer <brouer@redhat.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Cc: netdev@vger.kernel.org, linux-mm@kvack.org, Toke =?UTF-8?B?SMO4aWxh?=
 =?UTF-8?B?bmQtSsO4cmdlbnNlbg==?= <toke@toke.dk>, Ilias Apalodimas
 <ilias.apalodimas@linaro.org>, willy@infradead.org, Saeed Mahameed
 <saeedm@mellanox.com>, Alexander Duyck <alexander.duyck@gmail.com>, Andrew
 Morton <akpm@linux-foundation.org>, mgorman@techsingularity.net, "David S.
 Miller" <davem@davemloft.net>, Tariq Toukan <tariqt@mellanox.com>,
 brouer@redhat.com
Subject: Re: [net-next PATCH V2 1/3] mm: add dma_addr_t to struct page
Message-ID: <20190212191917.2ef91a88@carbon>
In-Reply-To: <dc34bb0b-1efd-4200-2ee7-bf8adef8a0b5@gmail.com>
References: <154998290571.8783.11827147914798438839.stgit@firesoul>
	<154998294324.8783.9045146111677125556.stgit@firesoul>
	<dc34bb0b-1efd-4200-2ee7-bf8adef8a0b5@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.28]); Tue, 12 Feb 2019 18:19:24 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 12 Feb 2019 10:05:39 -0800
Florian Fainelli <f.fainelli@gmail.com> wrote:

> On 2/12/19 6:49 AM, Jesper Dangaard Brouer wrote:
> > The page_pool API is using page->private to store DMA addresses.
> > As pointed out by David Miller we can't use that on 32-bit architectures
> > with 64-bit DMA
> > 
> > This patch adds a new dma_addr_t struct to allow storing DMA addresses
> > 
> > Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
> > Signed-off-by: Ilias Apalodimas <ilias.apalodimas@linaro.org>
> > Acked-by: Andrew Morton <akpm@linux-foundation.org>
> > ---
> >  include/linux/mm_types.h |    7 +++++++
> >  1 file changed, 7 insertions(+)
> > 
> > diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> > index 2c471a2c43fa..581737bd0878 100644
> > --- a/include/linux/mm_types.h
> > +++ b/include/linux/mm_types.h
> > @@ -95,6 +95,13 @@ struct page {
> >  			 */
> >  			unsigned long private;
> >  		};
> > +		struct {	/* page_pool used by netstack */
> > +			/**
> > +			 * @dma_addr: page_pool requires a 64-bit value even on
> > +			 * 32-bit architectures.
> > +			 */  
> 
> Nit: might require? dma_addr_t, as you mention in the commit may have a
> different size based on CONFIG_ARCH_DMA_ADDR_T_64BIT.

So you want me to change the comment to be:

/**
 * @dma_addr: might require a 64-bit value even on
 * 32-bit architectures.
 */

Correctly understood?
-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer

