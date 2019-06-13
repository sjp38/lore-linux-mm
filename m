Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 31B3CC46477
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 21:48:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 00C0F21537
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 21:48:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 00C0F21537
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 976386B026A; Thu, 13 Jun 2019 17:48:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8FFA18E0002; Thu, 13 Jun 2019 17:48:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7C7C96B026C; Thu, 13 Jun 2019 17:48:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 429696B026A
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 17:48:19 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id i26so192992pfo.22
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 14:48:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=QU3QbMKFn9UlxsDbT2cszrYfUFCkaD3v90aNFW8PRog=;
        b=dZJBVFvyiIUhmyCyGl6gjfjD6H3QRvoJdvH7mQfhFGuv3Tg4vkK7rhfdwmSdfYHoSk
         2pRdXO9WYFgzpzWUihNLSIltAldJr3GQvswxRLNtpg8axcdnOdjnZ0pfgEmMsc55okH4
         B2SxAllPzA/JWy5nYXYHsWF3Ig/vTh5pYyYreVkek8RoyQerufTXJnHlxE1EB0z3LkjM
         DWgRFQJxfkE39qHqGDBgxiQo9r3/AUz4mCLFlrYhNc3MyyUa1ozETEwO2INpCd4pW7cT
         rvIDFCL+iPR8BXZJx5Gv8CK8mfwz3iU9jaMDC6hPNfu4Ju81TbF7uHYICTBrqS7mqmXi
         95IA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUiWuaSbZnWyGfykl2XhO/tlU+IblRzqOWinAcWxLcNb7aj33pZ
	uy75NJU/dUvDJRchP9BiFNd2M+ACBkW7G8uIx8pccgobLs6M+9MpO91uMR1Js5Y00GWk3eTElnp
	2lSGv1YJb1YRz0rFEbVZwjViazqWfMipLQs1r11mNE0SEdwddI5Vcx/jN65NyEE8NGw==
X-Received: by 2002:a63:6841:: with SMTP id d62mr32030083pgc.17.1560462498809;
        Thu, 13 Jun 2019 14:48:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxjWUzLooYoSu9aVPMj5IZkvqhyWW95ezDtDfeibvwquehzArfufYtHI+UHexQCEbR+gc0e
X-Received: by 2002:a63:6841:: with SMTP id d62mr32030049pgc.17.1560462498113;
        Thu, 13 Jun 2019 14:48:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560462498; cv=none;
        d=google.com; s=arc-20160816;
        b=ukDTsv1SDkSyyqFUzwALzCJJMmE+SYMrpdmBi6TNvZuvAbvJOCCPz698hXsT25r529
         nMSlfM6I7c72iPgXNb5Ouo0sUdYqP4EEo42BMz4x3gzjlX6cDdgvAQtPHSgFb86JelrG
         GHBZTV2bltLMGJg/Ze0PaNkoq9/TOHI0EiTL4naNeeBpWSmA3T06ijv7qTels55SN8ox
         a1pAnk3hZN/VlN3vbHqlPHnd37Rpal76WDx0tvq++9bC62Pg/o9JlJuc5EoixD8M7G8N
         4eeuvU1VwETBw1n3tJVH023pnLcBoqqzkxIFQtQ28puUpH6uHotE3Ez0codc5GsGSeKL
         JuFA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=QU3QbMKFn9UlxsDbT2cszrYfUFCkaD3v90aNFW8PRog=;
        b=ylHOZ7u5x2C8GAST4oC/CnbVrlyyoyKbcDiqm1m9A7ZF6pD63T7/Kluq7Ahxo6JymY
         LjBIUnOjsB7M5csYLiDGYOMT7yLRBKgmhvctwwPViBosBxoBKmcBCQLj78uRlhuP02p1
         BxA+sZizcngm/+Rx1rB41fRTK5CmQocGRxkQIb0QG6T7rUG4pIAoqi7vrRkwrwwHKJvU
         7TGwgJb3FUY33OSiLSBe3ZesAXVayGr2obqJMZ8vrY2UQcm8BLX/rqCPkMELPj3v/nRZ
         fRwhd51zVDSCE8/WTIw/u/n7J6dhH2yKtnfoRY0iqDdBOrCjvpVdJiM14ti7EIxJNrXX
         Q88g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id b24si551824pfd.156.2019.06.13.14.48.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jun 2019 14:48:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.65 as permitted sender) client-ip=134.134.136.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by orsmga103.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 13 Jun 2019 14:48:17 -0700
X-ExtLoop1: 1
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga002.jf.intel.com with ESMTP; 13 Jun 2019 14:48:16 -0700
Date: Thu, 13 Jun 2019 14:49:38 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: Pingfan Liu <kernelfans@gmail.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Matthew Wilcox <willy@infradead.org>,
	John Hubbard <jhubbard@nvidia.com>,
	"Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>,
	Keith Busch <keith.busch@intel.com>,
	Christoph Hellwig <hch@infradead.org>,
	Shuah Khan <shuah@kernel.org>, linux-kernel@vger.kernel.org
Subject: Re: [PATCHv4 3/3] mm/gup_benchemark: add LONGTERM_BENCHMARK test in
 gup fast path
Message-ID: <20190613214938.GG32404@iweiny-DESK2.sc.intel.com>
References: <1560422702-11403-1-git-send-email-kernelfans@gmail.com>
 <1560422702-11403-4-git-send-email-kernelfans@gmail.com>
 <20190613214247.GF32404@iweiny-DESK2.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190613214247.GF32404@iweiny-DESK2.sc.intel.com>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 13, 2019 at 02:42:47PM -0700, 'Ira Weiny' wrote:
> On Thu, Jun 13, 2019 at 06:45:02PM +0800, Pingfan Liu wrote:
> > Introduce a GUP_LONGTERM_BENCHMARK ioctl to test longterm pin in gup fast
> > path.
> > 
> > Signed-off-by: Pingfan Liu <kernelfans@gmail.com>
> > Cc: Ira Weiny <ira.weiny@intel.com>
> > Cc: Andrew Morton <akpm@linux-foundation.org>
> > Cc: Mike Rapoport <rppt@linux.ibm.com>
> > Cc: Dan Williams <dan.j.williams@intel.com>
> > Cc: Matthew Wilcox <willy@infradead.org>
> > Cc: John Hubbard <jhubbard@nvidia.com>
> > Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
> > Cc: Keith Busch <keith.busch@intel.com>
> > Cc: Christoph Hellwig <hch@infradead.org>
> > Cc: Shuah Khan <shuah@kernel.org>
> > Cc: linux-kernel@vger.kernel.org
> > ---
> >  mm/gup_benchmark.c                         | 11 +++++++++--
> >  tools/testing/selftests/vm/gup_benchmark.c | 10 +++++++---
> >  2 files changed, 16 insertions(+), 5 deletions(-)
> > 
> > diff --git a/mm/gup_benchmark.c b/mm/gup_benchmark.c
> > index 7dd602d..83f3378 100644
> > --- a/mm/gup_benchmark.c
> > +++ b/mm/gup_benchmark.c
> > @@ -6,8 +6,9 @@
> >  #include <linux/debugfs.h>
> >  
> >  #define GUP_FAST_BENCHMARK	_IOWR('g', 1, struct gup_benchmark)
> > -#define GUP_LONGTERM_BENCHMARK	_IOWR('g', 2, struct gup_benchmark)
> > -#define GUP_BENCHMARK		_IOWR('g', 3, struct gup_benchmark)
> > +#define GUP_FAST_LONGTERM_BENCHMARK	_IOWR('g', 2, struct gup_benchmark)
> > +#define GUP_LONGTERM_BENCHMARK	_IOWR('g', 3, struct gup_benchmark)
> > +#define GUP_BENCHMARK		_IOWR('g', 4, struct gup_benchmark)
> 
> But I really like this addition!  Thanks!
> 
> But why not just add GUP_FAST_LONGTERM_BENCHMARK to the end of this list (value
> 4)?  I know the user space test program is probably expected to be lock step
> with this code but it seems odd to redefine GUP_LONGTERM_BENCHMARK and
> GUP_BENCHMARK with this change.

I see that Andrew pull this change.  So if others don't think this renumbering
is an issue feel free to add my:

Reviewed-by: Ira Weiny <ira.weiny@intel.com>

> 
> Ira
> 
> >  
> >  struct gup_benchmark {
> >  	__u64 get_delta_usec;
> > @@ -53,6 +54,11 @@ static int __gup_benchmark_ioctl(unsigned int cmd,
> >  			nr = get_user_pages_fast(addr, nr, gup->flags & 1,
> >  						 pages + i);
> >  			break;
> > +		case GUP_FAST_LONGTERM_BENCHMARK:
> > +			nr = get_user_pages_fast(addr, nr,
> > +					(gup->flags & 1) | FOLL_LONGTERM,
> > +					 pages + i);
> > +			break;
> >  		case GUP_LONGTERM_BENCHMARK:
> >  			nr = get_user_pages(addr, nr,
> >  					    (gup->flags & 1) | FOLL_LONGTERM,
> > @@ -96,6 +102,7 @@ static long gup_benchmark_ioctl(struct file *filep, unsigned int cmd,
> >  
> >  	switch (cmd) {
> >  	case GUP_FAST_BENCHMARK:
> > +	case GUP_FAST_LONGTERM_BENCHMARK:
> >  	case GUP_LONGTERM_BENCHMARK:
> >  	case GUP_BENCHMARK:
> >  		break;
> > diff --git a/tools/testing/selftests/vm/gup_benchmark.c b/tools/testing/selftests/vm/gup_benchmark.c
> > index c0534e2..ade8acb 100644
> > --- a/tools/testing/selftests/vm/gup_benchmark.c
> > +++ b/tools/testing/selftests/vm/gup_benchmark.c
> > @@ -15,8 +15,9 @@
> >  #define PAGE_SIZE sysconf(_SC_PAGESIZE)
> >  
> >  #define GUP_FAST_BENCHMARK	_IOWR('g', 1, struct gup_benchmark)
> > -#define GUP_LONGTERM_BENCHMARK	_IOWR('g', 2, struct gup_benchmark)
> > -#define GUP_BENCHMARK		_IOWR('g', 3, struct gup_benchmark)
> > +#define GUP_FAST_LONGTERM_BENCHMARK	_IOWR('g', 2, struct gup_benchmark)
> > +#define GUP_LONGTERM_BENCHMARK	_IOWR('g', 3, struct gup_benchmark)
> > +#define GUP_BENCHMARK		_IOWR('g', 4, struct gup_benchmark)
> >  
> >  struct gup_benchmark {
> >  	__u64 get_delta_usec;
> > @@ -37,7 +38,7 @@ int main(int argc, char **argv)
> >  	char *file = "/dev/zero";
> >  	char *p;
> >  
> > -	while ((opt = getopt(argc, argv, "m:r:n:f:tTLUSH")) != -1) {
> > +	while ((opt = getopt(argc, argv, "m:r:n:f:tTlLUSH")) != -1) {
> >  		switch (opt) {
> >  		case 'm':
> >  			size = atoi(optarg) * MB;
> > @@ -54,6 +55,9 @@ int main(int argc, char **argv)
> >  		case 'T':
> >  			thp = 0;
> >  			break;
> > +		case 'l':
> > +			cmd = GUP_FAST_LONGTERM_BENCHMARK;
> > +			break;
> >  		case 'L':
> >  			cmd = GUP_LONGTERM_BENCHMARK;
> >  			break;
> > -- 
> > 2.7.5
> > 
> 

