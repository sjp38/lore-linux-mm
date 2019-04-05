Return-Path: <SRS0=BJvi=SH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 39FC1C4360F
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 00:09:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CE2AE217D7
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 00:09:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CE2AE217D7
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3F0466B0269; Thu,  4 Apr 2019 20:09:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 39CB36B026A; Thu,  4 Apr 2019 20:09:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2B3FA6B026B; Thu,  4 Apr 2019 20:09:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 024F36B0269
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 20:09:11 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id q18so2850937pll.16
        for <linux-mm@kvack.org>; Thu, 04 Apr 2019 17:09:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=c/JC7q5fyfKLorS01EzaZEL6Gu6QufIyOw1g8TbQ67g=;
        b=bhieqH7XI4UllGM8RNIHoZdhhTjTkbGLiZZ0r1saIl5+5mIPjNmJQnyCF6rOLL4XK6
         /RGZzWMPzgxGjI/MGQqhuKZqzURtIfdFOnHmvxg4Ahf2xjoJZOS0rjfl9heSdzTWBqCu
         rfCr0ehhwLEinycu5jKb64seK54tGeJcARX2Pggi52Mykcm9DAzyNWIXYCjhxwAR9uLx
         QYCTF8M7uiT+YmLQN559Jjwzgp8HvVlHkOTzHwsextgX62NRkeVvJAxDsdXxTUHkHXcA
         ishcytrZRPNBVquxe7t2mFJ7hKapllPPqtQxb/iO3wlRI2Tn8dgDsFal4ygyPBIANsrD
         rm7A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: APjAAAUHW8UG5N1hgw4QSo8Y7q9rRRxq/1GJ/bfjvtPC6vlbjBHV2b2J
	HjltUncVf6t2pI6Wox1UBiz/rM0O5CEDRe3er22RC3p86woINHP9I5s1slKuAAQUD6O4cyStx3s
	TcEyjtIbe5+5DSdrW7idmKHJTMS513AsazIHVLW2LcycXo5dhtX3WGGcMKdcfwSvU/g==
X-Received: by 2002:a63:c706:: with SMTP id n6mr8911927pgg.310.1554422950481;
        Thu, 04 Apr 2019 17:09:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz6iQlJPcmf+n8RPG8SzA5/BhbfnQIR+QjoIYWd7F8oqJB9EgzAHTo+CFED9YJdwLps3297
X-Received: by 2002:a63:c706:: with SMTP id n6mr8911866pgg.310.1554422949655;
        Thu, 04 Apr 2019 17:09:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554422949; cv=none;
        d=google.com; s=arc-20160816;
        b=ri/1TNpMqLYu+4arSk+Ncw+L3yU58O/27EiMcCXh6yrL+E8flcPfDacNkyn5Vjz3qx
         Kx30EGjFsNUD6j7LWQrEH7NxWTjVtJBl+WYGNh+eBGW+lKKNIvF9go2cVNqp8dR+3Of3
         mszV7Fg3s7sXumNI+jLXuQZxAW4YFLU2U8vtr9b9Ck9w1LhQDtXtQU7yL6De+hIQBQUg
         qeqHMqSZdki0Vtb3vHZCDcrcGNAglQ9UDF5fwb1XgNFs6kG3ArqV4F9C+pRjNlZc50QJ
         nnuGRFKObBr32x8xW7IxY/Eqk16e45wi0UZAcR9IsORODATUs8eM2eLkzKKMZNfMEcte
         Q4oQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=c/JC7q5fyfKLorS01EzaZEL6Gu6QufIyOw1g8TbQ67g=;
        b=bkOmDLfCLjHjPV62tYz/GvBTWpixpekUgdx0jxUiGaGokyQcewWySaqk2f8odi0SHo
         QI7nI+ZRlr4zYKV+V0etBszrekuFOQs5DAuSNBW41yGkVxyMjT9rrBx6dTAjqvNhW/iF
         1Reo8moE9pMJMlpa8Tb4wN6FNTx7s32iR1oLB5e2zM1Jsf9SsAB/Vbrjyojv8GrgAeL2
         VVuSpU6ayZBzyj4toycvXxgtkNKdy0G/xtf1crNxP/qy/GmaFGC69ek9FljOH/UUSupx
         GcNTp3v0snMYmiujl26cOl+wgIbxEt0AnlsrQN0CGSa0gNxLZyPQ7Hf5nYTRKx1g8mm6
         cu6A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 133si18452912pfu.82.2019.04.04.17.09.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Apr 2019 17:09:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id 4D0322184;
	Fri,  5 Apr 2019 00:09:08 +0000 (UTC)
Date: Thu, 4 Apr 2019 17:09:07 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Huang Shijie <sjhuang@iluvatar.ai>, kirill.shutemov@linux.intel.com,
 linux-mm@kvack.org
Subject: Re: [PATCH] mm:rmap: use the pra.mapcount to do the check
Message-Id: <20190404170907.878fecfaeb150098ea61a806@linux-foundation.org>
In-Reply-To: <de5865e2-a9e4-f0f9-f740-f1301679258a@oracle.com>
References: <20190404054828.2731-1-sjhuang@iluvatar.ai>
	<de5865e2-a9e4-f0f9-f740-f1301679258a@oracle.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 4 Apr 2019 16:08:33 -0700 Mike Kravetz <mike.kravetz@oracle.com> wrote:

> On 4/3/19 10:48 PM, Huang Shijie wrote:
> > We have the pra.mapcount already, and there is no need to call
> > the page_mapped() which may do some complicated computing
> > for compound page.
> > 
> > Signed-off-by: Huang Shijie <sjhuang@iluvatar.ai>
> 
> This looks good to me.  I had to convince myself that there were no
> issues if we were operating on a sub-page of a compound-page.  However,
> Kirill is the expert here and would know of any subtle issues I may have
> overlooked.
> 
> -- 
> Mike Kravetz
> 
> > ---
> >  mm/rmap.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff --git a/mm/rmap.c b/mm/rmap.c
> > index 76c8dfd3ae1c..6c5843dddb5a 100644
> > --- a/mm/rmap.c
> > +++ b/mm/rmap.c
> > @@ -850,7 +850,7 @@ int page_referenced(struct page *page,
> >  	};
> >  
> >  	*vm_flags = 0;
> > -	if (!page_mapped(page))
> > +	if (!pra.mapcount)
> >  		return 0;
> >  
> >  	if (!page_rmapping(page))
> > 

