Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_PASS,USER_AGENT_NEOMUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EE80EC43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 22:03:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 901F121B1C
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 22:03:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="wHOYGZfL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 901F121B1C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1124B8E0002; Thu, 14 Feb 2019 17:03:52 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 09A708E0001; Thu, 14 Feb 2019 17:03:52 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E7E118E0002; Thu, 14 Feb 2019 17:03:51 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id A22968E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 17:03:51 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id b4so5308033plb.9
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 14:03:51 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=B89OifDmmp6xVyW6sHnZGToh8z4DfG522kiUz4LT+IY=;
        b=QNOJLJBR/I7c6K5G1kkEHrZwQJkWKcTQBaCikieFJzPpQp6pia6pwElvxVHAizEskv
         tHl8uI+3u0SVIzvHDtTkZkxctjENFyZ4esYbuvE2Eq14rsD7hxe5LG1FQPeaBWfU1BsN
         M0axZNUV+KywA+2ZYkQ1llWPXjzVG383ddKPJxxyuk0ADwfLd5yFzi9zqVZmQ+fEDhR8
         lDuqGgNWVo4EJX+b0vODaF+8hkLSWxCxar+3g/frOPelBIufAJNJOy+/a15XGFSpnSJp
         IKurM0O+K330zUYV8km3RozCREzZd2KENuKZrhV6JLoElDF1rqjuX0BPiA858/wkwpKy
         9I9w==
X-Gm-Message-State: AHQUAua7tPLjAeQuIJv+DW2PXYX0UHjysDVmmvI75TeIW200EvdktE5n
	ctTQofh+osENe7lSrH+wOThcqEzgdAdyeLFN0J5W0+7IbX4SQtsA69PWIhm4V8WkIfeBfE57OcQ
	XmTwMQjfkyC507Psp7t2vDfU5bxZ72twZFvpg/Kfy+d9aI72CGvLLtI6NUDbbZ9OX6N77NCPCUm
	UEZ5fb274nRJ8e7QbZA/J4/kDdqTfoBVjXjJizZrxGzDoGWu0ZfthqSImn0NQ24yh5P2hRPQl0R
	zNtYY3f6jXJyvt/kufaHQN7Q+riA8Fz4oidoqLGXD6zayE8Q0ZO2KxkdOuY7NiACmNH4bKIn86b
	QAQreKtgInuOdfcALFxlsegRGvy1RWrp+dUZtgqZjSB/KCPEZ3xZnUROW7D6jitCeMywNn2V87s
	g
X-Received: by 2002:a17:902:bb89:: with SMTP id m9mr6498236pls.320.1550181831258;
        Thu, 14 Feb 2019 14:03:51 -0800 (PST)
X-Received: by 2002:a17:902:bb89:: with SMTP id m9mr6498158pls.320.1550181830302;
        Thu, 14 Feb 2019 14:03:50 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550181830; cv=none;
        d=google.com; s=arc-20160816;
        b=hfcBD4K2kAMlJSKFp0AK8FBxv+MzklNAnHFy9pgMpcAQVa/Jbs84WQ+82uxVCPXPlB
         qTXn27ZkmHujfAscawQyrndSgZXj98TDAWFS83hOiBWl7ShWueZfd8EpygTG8ffwvbX6
         9vRErGS0CBZQ12E4k0AHnTtBRYhPBa0kGAd+Xf5twOfnf6dXP7CEB8tGWMIW+VMTmhOt
         ogf4wz91iPVocEa1J9NLoVvvBobSb+X/k1nWP6xgEq9qssjJ+sGRyMe3MsNQrj8L8qYb
         ZUgtk6BWIwzTQ9qIlb0AHBfH9cyOjZ0zUQiVNZX9nDt75N3vqnOKCnVfYUFxZvspaFtC
         8azA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=B89OifDmmp6xVyW6sHnZGToh8z4DfG522kiUz4LT+IY=;
        b=ezjgAzMQyCkrHgWFXyRawdzs6LnS2ltlxuyYeQTKmCHM6JhwbTosLY1CWOmc8ZhQ3R
         5n2NCiEpgArBo1LvVeaELESXHt+Eq9QejqQpObj0eKvHnOzU2O++fr/nBAa2eXBjYah5
         rzy8Qb9uJoZURKzYkB47RCCm4EUWuhEiBPdsz57jDMB9XEesTc8bC/pvgJG2TrNGaNHc
         vLaQLAQEietDOuhLNkv5C4//e6oV16euRjEvDGKjC16Xqjcz/BwygkQSkVgR3A3S0xFK
         iYvZZH38GR+/q/NFHNYl/hl+yZMbGR8LWCZ7yOjZ7ezcqijM1Cd9Hfel7lsk0Z9IBHiN
         fB9g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=wHOYGZfL;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r28sor5820826pgl.17.2019.02.14.14.03.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 14 Feb 2019 14:03:50 -0800 (PST)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=wHOYGZfL;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=B89OifDmmp6xVyW6sHnZGToh8z4DfG522kiUz4LT+IY=;
        b=wHOYGZfLYrHh706qxUK+u/Qgi3hm+soGvSPpvLI3zjfI17r3Ezi+4FD6L42KbcOgTQ
         +hgmKjZtgh9F2oZBB9hyUj+0o1ATKJNzx99AuaLf9SLDdRu+EjQJv4K4gk4jpDEsHC6+
         L0ZX7bBvMpmtxGng/gGAJKDcKfXb0Guc+wBzwVQGfX2u3cKntwQY2EF5mCGQwQeV+mlS
         sWfcLgI4VW5vKz6IsUhzZPQfbKOjDOhRj2OdTmoUIzyVTbxDONSMHZaiNN5CiLDrUk/E
         kOj4HZ0OOowVT7h7SnnoE297qX3lp6Nm4AgFMF9stmeWrJgeuar3+B5xsb5J9P3jz+Rz
         FBSQ==
X-Google-Smtp-Source: AHgI3IZv4s7H7az1cNaAQWVnMBosbkqWNfvx8fpOuwryswf4XSaTnoFKzyS2LbUg3kE6lIEN+KUgig==
X-Received: by 2002:a63:d842:: with SMTP id k2mr2019324pgj.8.1550181829465;
        Thu, 14 Feb 2019 14:03:49 -0800 (PST)
Received: from kshutemo-mobl1.localdomain ([192.55.54.45])
        by smtp.gmail.com with ESMTPSA id w185sm5843014pfb.135.2019.02.14.14.03.48
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Feb 2019 14:03:48 -0800 (PST)
Received: by kshutemo-mobl1.localdomain (Postfix, from userid 1000)
	id ECB693008A8; Fri, 15 Feb 2019 01:03:44 +0300 (+03)
Date: Fri, 15 Feb 2019 01:03:44 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>,
	William Kucharski <william.kucharski@oracle.com>
Subject: Re: [PATCH v2] page cache: Store only head pages in i_pages
Message-ID: <20190214220344.2ovvzwcfuxxehzzt@kshutemo-mobl1>
References: <20190212183454.26062-1-willy@infradead.org>
 <20190214133004.js7s42igiqc5pgwf@kshutemo-mobl1>
 <20190214205331.GD12668@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190214205331.GD12668@bombadil.infradead.org>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 14, 2019 at 12:53:31PM -0800, Matthew Wilcox wrote:
> On Thu, Feb 14, 2019 at 04:30:04PM +0300, Kirill A. Shutemov wrote:
> >  - page_cache_delete_batch() will blow up on
> > 
> > 			VM_BUG_ON_PAGE(page->index + HPAGE_PMD_NR - tail_pages
> > 					!= pvec->pages[i]->index, page);
> 
> Quite right.  I decided to rewrite page_cache_delete_batch.  What do you
> (and Jan!) think to this?  Compile-tested only.
> 
> diff --git a/mm/filemap.c b/mm/filemap.c
> index 0d71b1acf811..facaa6913ffa 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -279,11 +279,11 @@ EXPORT_SYMBOL(delete_from_page_cache);
>   * @pvec: pagevec with pages to delete
>   *
>   * The function walks over mapping->i_pages and removes pages passed in @pvec
> - * from the mapping. The function expects @pvec to be sorted by page index.
> + * from the mapping. The function expects @pvec to be sorted by page index
> + * and is optimised for it to be dense.
>   * It tolerates holes in @pvec (mapping entries at those indices are not
>   * modified). The function expects only THP head pages to be present in the
> - * @pvec and takes care to delete all corresponding tail pages from the
> - * mapping as well.
> + * @pvec.
>   *
>   * The function expects the i_pages lock to be held.
>   */
> @@ -292,40 +292,36 @@ static void page_cache_delete_batch(struct address_space *mapping,
>  {
>  	XA_STATE(xas, &mapping->i_pages, pvec->pages[0]->index);
>  	int total_pages = 0;
> -	int i = 0, tail_pages = 0;
> +	int i = 0;
>  	struct page *page;
>  
>  	mapping_set_update(&xas, mapping);
>  	xas_for_each(&xas, page, ULONG_MAX) {
> -		if (i >= pagevec_count(pvec) && !tail_pages)
> +		if (i >= pagevec_count(pvec))
>  			break;
> +
> +		/* A swap/dax/shadow entry got inserted? Skip it. */
>  		if (xa_is_value(page))
>  			continue;
> -		if (!tail_pages) {
> -			/*
> -			 * Some page got inserted in our range? Skip it. We
> -			 * have our pages locked so they are protected from
> -			 * being removed.
> -			 */
> -			if (page != pvec->pages[i]) {
> -				VM_BUG_ON_PAGE(page->index >
> -						pvec->pages[i]->index, page);
> -				continue;
> -			}
> -			WARN_ON_ONCE(!PageLocked(page));
> -			if (PageTransHuge(page) && !PageHuge(page))
> -				tail_pages = HPAGE_PMD_NR - 1;
> +		/*
> +		 * A page got inserted in our range? Skip it. We have our
> +		 * pages locked so they are protected from being removed.
> +		 */
> +		if (page != pvec->pages[i]) {

Maybe a comment for the VM_BUG while you're there?

> +			VM_BUG_ON_PAGE(page->index > pvec->pages[i]->index,
> +					page);
> +			continue;
> +		}
> +
> +		WARN_ON_ONCE(!PageLocked(page));
> +
> +		if (page->index == xas.xa_index)
>  			page->mapping = NULL;
> -			/*
> -			 * Leave page->index set: truncation lookup relies
> -			 * upon it
> -			 */
> +		/* Leave page->index set: truncation lookup relies on it */
> +
> +		if (page->index + (1UL << compound_order(page)) - 1 ==
> +				xas.xa_index)

It's 1am here and I'm slow, but it took me few minutes to understand how
it works. Please add a comment.

>  			i++;
> -		} else {
> -			VM_BUG_ON_PAGE(page->index + HPAGE_PMD_NR - tail_pages
> -					!= pvec->pages[i]->index, page);
> -			tail_pages--;
> -		}
>  		xas_store(&xas, NULL);
>  		total_pages++;
>  	}

-- 
 Kirill A. Shutemov

