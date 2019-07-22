Return-Path: <SRS0=80m6=VT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 64BEFC76190
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 23:35:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 100F521951
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 23:35:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="U09JlmRF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 100F521951
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6CFE26B000A; Mon, 22 Jul 2019 19:35:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 65AF88E0003; Mon, 22 Jul 2019 19:35:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5225D8E0001; Mon, 22 Jul 2019 19:35:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 199576B000A
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 19:35:34 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id j22so24824761pfe.11
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 16:35:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=85QgoVCMoUBXEV57x4G0PDzl0QhwTAJz3PR0yob8+QQ=;
        b=M3+XYFE5+KGsKQCMl6+KdnwFiCpItb/yeWkpbgkRNhtJx9GAFJ+rTFuqqkalGrahsp
         fDqFv41qx8UZbEBNlY1aeXb1TBfS9//nthh4ZCd4/7Gt7qnPHj5qPpBTyNcN2chskAp3
         c2YKQBDTvtSctMh4okRxp5NcwnpOfwnGaVgIJTz8wy2OK693eWH/TaQRFPG2wk8ogSmH
         +Io/bahwpl5H9HHuDgGfGEbzezzGq8f6+r8MlXV3enD4yDDsQlQW9DNLd/kg7Z8UT0fK
         GEvatVrxSg7q93XO+pKf5po37lepOuCbehiJjbTi1hG7J59ohztqtvlxIntGKLNj3hyO
         Wvcg==
X-Gm-Message-State: APjAAAXORYzE9bpmwTriPGmItNJh00iZi/PnQ4C1KoKVefbJ9z0v81O/
	Ji19gH9kDwwdtKUd4O877ZAhVHyij+S/DPGyRsk3zoPV439lvCqub/ZCza7+sbVGQjw548AYTnP
	KtEff5MtmQT55RP1hMxPPEtfLbmRotbwymFx2yTET10Yb0rXxpuw2+ABU+BPKlYWA4g==
X-Received: by 2002:a17:902:b70e:: with SMTP id d14mr77012534pls.309.1563838533616;
        Mon, 22 Jul 2019 16:35:33 -0700 (PDT)
X-Received: by 2002:a17:902:b70e:: with SMTP id d14mr77012484pls.309.1563838532721;
        Mon, 22 Jul 2019 16:35:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563838532; cv=none;
        d=google.com; s=arc-20160816;
        b=Lw6ANp4Y+YJdAHXjvhIAIVu0WckJ4N8Sjw1NzDK/e8gjp/74+u1BmRSIAVGi5c1CA8
         EPl8YOcT0rjVK6xQxbt2WqR4x0oJYhJzbKf8GIGEq+s8yKhax3on2z+xyExgmrn+OTGb
         jVisPreeAvviVgqB5H2R16hIwMtOPP9GA81PC8l7ykHxRT5iTVUx6cwUagjlr9XBfOOs
         ZdNh8U7n/CrMQuDfQxr3F6t8ptZbfRKkgQDcWDnRHt+bE8hAlfMpn+RuDw/OhivRMA6d
         98Ns+eBXGcYxUqnyqTIXdD3aRIRq9OK4N5HLSOruTkBsrw+QwUprGnNmu9xOECNHgPbe
         QpLQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=85QgoVCMoUBXEV57x4G0PDzl0QhwTAJz3PR0yob8+QQ=;
        b=zoCcyPGaIozT/Zo3bptzvNHJWk6N4rNC3gqQNQZLU/hx0LbzfRBssjswARMnjl1JZ0
         N28q0F3AKsqB4MSnbN0OjQkGk12/u5tpTTljAy00/E2zRw6MHoPIVt+Z8f7P+zb7hDoP
         mooAV34zAXxMa/PCinmwoOVuaG5cO+mwSM/Y/UXANgG10+KH7NtJZPPAL6eBWVBKNX+Q
         vcGE63GTIHizuFSg/Fbu2i1zjuLImcnjvfjR2Las32ZK+lyVY0pytbMh9XUA/hDirqbT
         qD//SIwmf+d0ybFWpWqrURQ1dh4baqdNH8cqUuu7X7kTDJp4AMuAwEihDhsF2EKDqDsk
         kCwA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=U09JlmRF;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 11sor18723616pgh.67.2019.07.22.16.35.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 22 Jul 2019 16:35:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=U09JlmRF;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=85QgoVCMoUBXEV57x4G0PDzl0QhwTAJz3PR0yob8+QQ=;
        b=U09JlmRF+1e0SXt1nVtPE+wsgbeVT+ODWkwh5EDZK/HI2W80i+GnSjYreZoZXSI25X
         H/SgYIii0FLjAEyz5fr1WEYrj2sBL7nya8427TlnXTltUbOXOAlyW3PNZsaBZvxVlt9p
         RgLWM5tK8Sx6N9INgAByIFLu9Ox5yaiWxUh//d2f8VulJfzD/2OGyTqkfx1tsYqpi2aZ
         9pTGAYQZrPIxM09wjYq9BG2H+3Xk4U/1Xw1EXLWHs6+EyDzpF9FgQvWLD1cdX6f1bApk
         +PT94ubpctMbcTGgGWiIX4I+Bn5Ly+Usy4Fm5gUH2puNJ6ZQxnG4w0K/QY7JYtZ7JJqP
         eD4w==
X-Google-Smtp-Source: APXvYqxd+2dzeBJuFB5qvEgV0O6zCpRw01LkZ+IA8kHWZ1vLbAH4HIeBFqUtXGy3QN5SDNyoAA0HPw==
X-Received: by 2002:a63:188:: with SMTP id 130mr72665111pgb.231.1563838529829;
        Mon, 22 Jul 2019 16:35:29 -0700 (PDT)
Received: from localhost ([2620:10d:c091:500::d1c7])
        by smtp.gmail.com with ESMTPSA id l6sm40554336pga.72.2019.07.22.16.35.28
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 22 Jul 2019 16:35:29 -0700 (PDT)
Date: Mon, 22 Jul 2019 19:35:27 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-btrfs@vger.kernel.org,
	linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-block@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] psi: annotate refault stalls from IO submission
Message-ID: <20190722233527.GA21594@cmpxchg.org>
References: <20190722201337.19180-1-hannes@cmpxchg.org>
 <20190722152607.dd175a9d517a5f6af06a8bdc@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190722152607.dd175a9d517a5f6af06a8bdc@linux-foundation.org>
User-Agent: Mutt/1.12.0 (2019-05-25)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 22, 2019 at 03:26:07PM -0700, Andrew Morton wrote:
> On Mon, 22 Jul 2019 16:13:37 -0400 Johannes Weiner <hannes@cmpxchg.org> wrote:
> 
> > psi tracks the time tasks wait for refaulting pages to become
> > uptodate, but it does not track the time spent submitting the IO. The
> > submission part can be significant if backing storage is contended or
> > when cgroup throttling (io.latency) is in effect - a lot of time is
> > spent in submit_bio(). In that case, we underreport memory pressure.
> 
> It's a somewhat broad patch.  How significant is this problem in the
> real world?  Can we be confident that the end-user benefit is worth the
> code changes?

The error scales with how aggressively IO is throttled compared to the
device's capability.

For example, we have system maintenance software throttled down pretty
hard on IO compared to the workload. When memory is contended, the
system software starts thrashing cache, but since the backing device
is actually pretty fast, the majority of "io time" is from injected
throttling delays during submit_bio().

As a result we barely see memory pressure, when the reality is that
there is almost no progress due to the thrashing and we should be
killing misbehaving stuff.

> > Annotate the submit_bio() paths (or the indirection through readpage)
> > for refaults and swapin to get proper psi coverage of delays there.
> > 
> > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> > ---
> >  fs/btrfs/extent_io.c | 14 ++++++++++++--
> >  fs/ext4/readpage.c   |  9 +++++++++
> >  fs/f2fs/data.c       |  8 ++++++++
> >  fs/mpage.c           |  9 +++++++++
> >  mm/filemap.c         | 20 ++++++++++++++++++++
> >  mm/page_io.c         | 11 ++++++++---
> >  mm/readahead.c       | 24 +++++++++++++++++++++++-
> 
> We touch three filesystems.  Why these three?  Are all other
> filesystems OK or will they need work as well?

These are the ones that I found open-coding add_to_page_cache_lru()
followed by submit_bio() instead of going through generic code like
mpage, use read_cache_pages(), implement ->readpage only.

> > @@ -2753,11 +2763,14 @@ static struct page *do_read_cache_page(struct address_space *mapping,
> >  				void *data,
> >  				gfp_t gfp)
> >  {
> > +	bool refault = false;
> >  	struct page *page;
> >  	int err;
> >  repeat:
> >  	page = find_get_page(mapping, index);
> >  	if (!page) {
> > +		unsigned long pflags;
> > +
> 
> That was a bit odd.  This?
> 
> --- a/mm/filemap.c~psi-annotate-refault-stalls-from-io-submission-fix
> +++ a/mm/filemap.c
> @@ -2815,12 +2815,12 @@ static struct page *do_read_cache_page(s
>  				void *data,
>  				gfp_t gfp)
>  {
> -	bool refault = false;
>  	struct page *page;
>  	int err;
>  repeat:
>  	page = find_get_page(mapping, index);
>  	if (!page) {
> +		bool refault = false;
>  		unsigned long pflags;
>  
>  		page = __page_cache_alloc(gfp);
> _
> 

It's so that when we jump to 'filler:' from outside the branch, the
'refault' variable is initialized from the first time through:

	bool refault = false;
	struct page *page;

	page = find_get_page(mapping, index);
	if (!page) {
	   	__page_cache_alloc()
		add_to_page_cache_lru()
		refault = PageWorkingset(page);
filler:
		if (refault)
			psi_memstall_enter(&pflags);

		readpage()

		if (refault)
			psi_memstall_leave(&pflags);
	}
	lock_page()
	if (PageUptodate())
		goto out;
	goto filler;

