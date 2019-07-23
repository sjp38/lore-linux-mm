Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 032BEC76190
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 17:58:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BBFF7218A0
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 17:58:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BBFF7218A0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5B7ED8E0003; Tue, 23 Jul 2019 13:58:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 569528E0002; Tue, 23 Jul 2019 13:58:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 47E4E8E0003; Tue, 23 Jul 2019 13:58:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 123FD8E0002
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 13:58:41 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id 65so22413889plf.16
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 10:58:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=cxjj6HCJraV+egdJ+3NbJ1/3TKaPpFlrf63qB3Yr8FE=;
        b=KszA8lpMejGfQxJ6jZImlCjNVTTN7yYXLNK+XPgd6kHZ1+BBdLIbXdXb5nJFTP1lYn
         NUH/Q0fDZP2/DJykX+GSjz1yBZHbOMbkAULjFg4/gzuaBz1wAYlpchFuBKtDw+A4DMLx
         Syo9zSwBhif0uEbDonh6AX/7oL8dQnzjO6V6S0OcI5zLXrtsGo6KW6CnmsYl3992Vsro
         XBoyMhRQ+pcr7MmdupLNvSuTU97/i0uc0+ZSrx80lg+/29AZon2IRwxbqAlbAvr29HmZ
         bYPD8U1cPCXQL3+BaMxNFB2eCBaqE3vkiQKVDm3L6o+bD1qBQny4UCNXEaVnsCZxgldo
         gdww==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUb65ahOkBdVBxJGnXrgDWDnHLdkYEXdanUIlKBUOnyubrWm16t
	RsV9kZawR+VObYe5A7DbWOLPU0BcgXHxePv2qhzJrSXBbxoBSdZb/w0aCT12zWSecNE4hMjIYPV
	x2z/JJP1qZrAbUYJMdrgupm5RAypO6ii2vjpCHTp668oxHllguA/Dtv3J0zxFg40gAQ==
X-Received: by 2002:a63:d210:: with SMTP id a16mr75715197pgg.77.1563904720632;
        Tue, 23 Jul 2019 10:58:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzcaLBRPHZy3vnzUqoggjVnqorIJ+cWOd9n6jLVt4+gfbF4jTQ6152KBuhXUbwSTuDQEjO/
X-Received: by 2002:a63:d210:: with SMTP id a16mr75715165pgg.77.1563904719842;
        Tue, 23 Jul 2019 10:58:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563904719; cv=none;
        d=google.com; s=arc-20160816;
        b=A25rEeIKYRfDwYdukRfyCBFclJtloRH96JPpuQpLjkJbXtOY/qcwMetFElMkYk+DKG
         U6kMUCuCkx171gwjbi8uDbfRlyZy6KJMPOqOndaPnUj/X5/3qgKfbeDApFAtDaTBSxn6
         yn4ce6NdOPwf4QFKqum6ewarQntQeSg6w+3AqznYo49n2r4j5WN9pskyQSNBePS8QNMc
         fyfn/HP3N5D4FZzxmwVZen1q7me8JWRm4NAhxHCEjOuw2zphfvo3Wjt2+K3/VCB85ijY
         uJOZzC8Rf10TOPmqI/3ILr7t/IR1Qg+tR36yPiULoqdso/mZO8uio1nLzRPesVlKCkhD
         rfCA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=cxjj6HCJraV+egdJ+3NbJ1/3TKaPpFlrf63qB3Yr8FE=;
        b=PXtUCJaDcQCl+PFnAMYS/t9DwLEeVqWLkJnI9QPz89Wcn7okBCAD/9UMCFORzZJnfK
         6QXyVCgz3BMApvak6VbJfmByQAKZ+USzGGBr7LZ9p4BBZsuTAzX7uEGsCgY/ePCd01eb
         7fbAJ6u6fbfjWXrPhjk0nO7uRruurBKLEIkqqBFxL6wqBnzUtJuquXbVvrPK0Y+ZpBrP
         fUg5hoQI01ikEPNNpT2LBB5nJGbsI+g0V0+/plckjM3vSBoMEfZx1AwDapKFth9ZwmcG
         7vPSaOwtCF1M2Uw+TB53QA1ZF9ojE0JbSqDchfWddeqctyT9ETpOl8wv+3hyqiD5QPos
         fHIg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id c190si13602160pfb.192.2019.07.23.10.58.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Jul 2019 10:58:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.151 as permitted sender) client-ip=192.55.52.151;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga007.jf.intel.com ([10.7.209.58])
  by fmsmga107.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 23 Jul 2019 10:58:39 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,299,1559545200"; 
   d="scan'208";a="160276390"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga007.jf.intel.com with ESMTP; 23 Jul 2019 10:58:38 -0700
Date: Tue, 23 Jul 2019 10:58:38 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: Matthew Wilcox <willy@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	Atul Gupta <atul.gupta@chelsio.com>, linux-crypto@vger.kernel.org
Subject: Re: [PATCH v2 1/3] mm: Introduce page_size()
Message-ID: <20190723175838.GA29729@iweiny-DESK2.sc.intel.com>
References: <20190721104612.19120-1-willy@infradead.org>
 <20190721104612.19120-2-willy@infradead.org>
 <20190723004307.GB10284@iweiny-DESK2.sc.intel.com>
 <20190723160248.GK363@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190723160248.GK363@bombadil.infradead.org>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 23, 2019 at 09:02:48AM -0700, Matthew Wilcox wrote:
> On Mon, Jul 22, 2019 at 05:43:07PM -0700, Ira Weiny wrote:
> > > diff --git a/drivers/crypto/chelsio/chtls/chtls_io.c b/drivers/crypto/chelsio/chtls/chtls_io.c
> > > index 551bca6fef24..925be5942895 100644
> > > --- a/drivers/crypto/chelsio/chtls/chtls_io.c
> > > +++ b/drivers/crypto/chelsio/chtls/chtls_io.c
> > > @@ -1078,7 +1078,7 @@ int chtls_sendmsg(struct sock *sk, struct msghdr *msg, size_t size)
> > >  			bool merge;
> > >  
> > >  			if (page)
> > > -				pg_size <<= compound_order(page);
> > > +				pg_size = page_size(page);
> > >  			if (off < pg_size &&
> > >  			    skb_can_coalesce(skb, i, page, off)) {
> > >  				merge = 1;
> > > @@ -1105,8 +1105,7 @@ int chtls_sendmsg(struct sock *sk, struct msghdr *msg, size_t size)
> > >  							   __GFP_NORETRY,
> > >  							   order);
> > >  					if (page)
> > > -						pg_size <<=
> > > -							compound_order(page);
> > > +						pg_size <<= order;
> > 
> > Looking at the code I see pg_size should be PAGE_SIZE right before this so why
> > not just use the new call and remove the initial assignment?
> 
> This driver is really convoluted.

Agreed...

>
> I wasn't certain I wouldn't break it
> in some horrid way.  I made larger changes to it originally, then they
> touched this part of the driver and I had to rework the patch to apply
> on top of their changes.  So I did something more minimal.
> 
> This, on top of what's in Andrew's tree, would be my guess, but I don't
> have the hardware.
> 
> diff --git a/drivers/crypto/chelsio/chtls/chtls_io.c b/drivers/crypto/chelsio/chtls/chtls_io.c
> index 925be5942895..d4eb0fcd04c7 100644
> --- a/drivers/crypto/chelsio/chtls/chtls_io.c
> +++ b/drivers/crypto/chelsio/chtls/chtls_io.c
> @@ -1073,7 +1073,7 @@ int chtls_sendmsg(struct sock *sk, struct msghdr *msg, size_t size)
>  		} else {
>  			int i = skb_shinfo(skb)->nr_frags;
>  			struct page *page = TCP_PAGE(sk);
> -			int pg_size = PAGE_SIZE;
> +			unsigned int pg_size = 0;
>  			int off = TCP_OFF(sk);
>  			bool merge;
>  
> @@ -1092,7 +1092,7 @@ int chtls_sendmsg(struct sock *sk, struct msghdr *msg, size_t size)
>  			if (page && off == pg_size) {
>  				put_page(page);
>  				TCP_PAGE(sk) = page = NULL;
> -				pg_size = PAGE_SIZE;
> +				pg_size = 0;

Yea...  I was not sure about this one at first...  :-/

>  			}
>  
>  			if (!page) {
> @@ -1104,15 +1104,13 @@ int chtls_sendmsg(struct sock *sk, struct msghdr *msg, size_t size)
>  							   __GFP_NOWARN |
>  							   __GFP_NORETRY,
>  							   order);
> -					if (page)
> -						pg_size <<= order;
>  				}
>  				if (!page) {
>  					page = alloc_page(gfp);
> -					pg_size = PAGE_SIZE;
>  				}
>  				if (!page)
>  					goto wait_for_memory;

Side note: why 2 checks for !page?

Reviewed-by: Ira Weiny <ira.weiny@intel.com>

> +				pg_size = page_size(page);
>  				off = 0;
>  			}
>  copy:

