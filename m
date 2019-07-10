Return-Path: <SRS0=tO+N=VH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7A4DCC74A35
	for <linux-mm@archiver.kernel.org>; Wed, 10 Jul 2019 18:48:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2884B20844
	for <linux-mm@archiver.kernel.org>; Wed, 10 Jul 2019 18:48:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="OFjD/iLu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2884B20844
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A84738E008A; Wed, 10 Jul 2019 14:48:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A34618E0032; Wed, 10 Jul 2019 14:48:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 925708E008A; Wed, 10 Jul 2019 14:48:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5DC978E0032
	for <linux-mm@kvack.org>; Wed, 10 Jul 2019 14:48:18 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id d187so1987710pga.7
        for <linux-mm@kvack.org>; Wed, 10 Jul 2019 11:48:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=y9kooNntoKsSjfBoyAT/Wl3OUMWao+tgpJsSDEV/3mY=;
        b=b7fe/fV90IzbYkCPJs8BntBIjOIBGecNQOUD7uVIq7c785rfrvS7qw44mHGlsFZk6H
         62pZPIQb9eIkQDg3Fqjr6pP/2Z0WbKN/bmgeRpe+JU/+Mc57TjNeZIifwMZwHOpVdbSV
         6v9QAKgs+JyLJSNUTy2pMOHSJBuFzMY57B0wJjBu/F0TjIZ/oQU5NPRgIeiHlun0xcFO
         auRjhN/SB9AZu45brh/XWKhkEqpKQ+irQy5Bm+89c9T3BUw4S948W+ElUXeHu87rHcP/
         t0KbxgBph+Y151EUmbRlCcf5AW8t8uan47CsbgHt5UpIYGU+6Vrs9DcJfWuciolftLm2
         Cb2g==
X-Gm-Message-State: APjAAAU2e+4b1nEgjtXyHILRCLB4LlVaVALSrX/h492ayKdCoGzUnNUf
	SqO2qvdBFYymSE59EXQNkJB5nRS0NX6e6Xg28JfB/qaxRn9oKrZ8+82KzTztlHEIRUgJw9dEysx
	ThN9qEzMvGhnTwQrjfwq/1ZiSFEZVbpVT9xgL7UK47/xp/PABvmT9x9Xz2Rm8BJr+Tg==
X-Received: by 2002:a63:2246:: with SMTP id t6mr38398824pgm.209.1562784497852;
        Wed, 10 Jul 2019 11:48:17 -0700 (PDT)
X-Received: by 2002:a63:2246:: with SMTP id t6mr38398752pgm.209.1562784496812;
        Wed, 10 Jul 2019 11:48:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562784496; cv=none;
        d=google.com; s=arc-20160816;
        b=Az4WrTQCpGbe/xf7YKeUga+5HvsKQ5BCy6i71YSA7jDITG2jEgqvFhgEWZlpy+9eaf
         AbqFqyxy9ccGHe17lvf8S6OCaBunnNYtLX7BZwncGF3zA4fl33RBvqbz99msx5q7dCGv
         oqm0oxGb57u6lRHvmm7Efc6G8CSyXbEjIHy5Visq0MN3jYZG2Q5K11sBfl7GFP24pmgq
         7ZFnt8vTZo8biI7N9NdCDSUA1QLEALUCHuj5WmlwyxO0BzHeClKmwar0e46VkFl3CWWR
         eoTIKFfAFBNxZln2nTs+lsfkj8R3quWjtRJb0NLFqVT2OgedVR8kki836/W71ZT25sMC
         8IUA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=y9kooNntoKsSjfBoyAT/Wl3OUMWao+tgpJsSDEV/3mY=;
        b=qT8DkLKwYefLd/DEEqddLtVAfTqk1CCYsDPZt/MUEU0+47kWxY0OkFQ4Ty8G7GBtSL
         d7XAsQplwSvGvherU4EiSD0WrxN2LByPj20g/e35OeJBNwEp3kazIUmHoLX5I41JhvZ5
         nA+4aI/2aAml2ft7YTgMG9dqBeEg1/ZP9itXxdFdIaue1WAFsHcr8J0GOcg9lEip/bGN
         eKyCM/Dc0d2GVhCAvrVwWkfhz0U/XKSaQcvP5RJNdI8Ol4xqEf8oDtjY8o07vnqW7h8X
         0S5XhYgYko7GqgraldH/hUdkXukZdvD/JC0tR/dG9V7OgL5ib+4vssyEl/8L7+PqFTIf
         u61Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b="OFjD/iLu";
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x24sor1652328pgk.36.2019.07.10.11.48.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Jul 2019 11:48:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b="OFjD/iLu";
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=y9kooNntoKsSjfBoyAT/Wl3OUMWao+tgpJsSDEV/3mY=;
        b=OFjD/iLuYrkg1RhYeN3VKM0/ELOCopxGEBIDDqvo5swD04JGSTNq3LyO5brgEAqGsz
         UALrJXenvXS3YoCtUXy1CBNOI/pwmTHCuw1BEj4n86Ll2AEYX2iZ+SfVRUjx5S15W7RH
         33kEls+0jpJZbSW7GcqyjXCHCAByMD4WHssllukI4Py2WXt6L9Ad+H0i8h7E/WSQphKg
         RLLmcPbF1sWNvg8/UeJfoQwz3J9c8A9TsX8KPp/38Rp7oVTCobf/hHCqPtJqFMy7sNkW
         AYN0vfhtiynvE5ZxG7n4/uXDHiUgnIzwMO5st4VDEViLo5enzimobH+MdiHGRzTrhzD2
         +bGw==
X-Google-Smtp-Source: APXvYqw+kZW6sO6JboWw1tOGgmgFR3oUqPRhYylozUo7bOJrFZM3xbWs7lUQ85zycV3bVRZjD38Cyw==
X-Received: by 2002:a63:4404:: with SMTP id r4mr38331577pga.245.1562784493365;
        Wed, 10 Jul 2019 11:48:13 -0700 (PDT)
Received: from localhost ([2620:10d:c091:500::2:5b9d])
        by smtp.gmail.com with ESMTPSA id k184sm2700588pgk.7.2019.07.10.11.48.12
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 10 Jul 2019 11:48:12 -0700 (PDT)
Date: Wed, 10 Jul 2019 14:48:11 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Song Liu <songliubraving@fb.com>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org, matthew.wilcox@oracle.com,
	kirill.shutemov@linux.intel.com, kernel-team@fb.com,
	william.kucharski@oracle.com, akpm@linux-foundation.org,
	hdanton@sina.com
Subject: Re: [PATCH v9 5/6] mm,thp: add read-only THP support for (non-shmem)
 FS
Message-ID: <20190710184811.GF11197@cmpxchg.org>
References: <20190625001246.685563-1-songliubraving@fb.com>
 <20190625001246.685563-6-songliubraving@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190625001246.685563-6-songliubraving@fb.com>
User-Agent: Mutt/1.12.0 (2019-05-25)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 24, 2019 at 05:12:45PM -0700, Song Liu wrote:
> This patch is (hopefully) the first step to enable THP for non-shmem
> filesystems.
> 
> This patch enables an application to put part of its text sections to THP
> via madvise, for example:
> 
>     madvise((void *)0x600000, 0x200000, MADV_HUGEPAGE);
> 
> We tried to reuse the logic for THP on tmpfs.
> 
> Currently, write is not supported for non-shmem THP. khugepaged will only
> process vma with VM_DENYWRITE. sys_mmap() ignores VM_DENYWRITE requests
> (see ksys_mmap_pgoff). The only way to create vma with VM_DENYWRITE is
> execve(). This requirement limits non-shmem THP to text sections.
> 
> The next patch will handle writes, which would only happen when the all
> the vmas with VM_DENYWRITE are unmapped.
> 
> An EXPERIMENTAL config, READ_ONLY_THP_FOR_FS, is added to gate this
> feature.
> 
> Acked-by: Rik van Riel <riel@surriel.com>
> Signed-off-by: Song Liu <songliubraving@fb.com>

This is really cool, and less invasive than I anticipated. Nice work.

I only have one concern and one question:

> @@ -1392,6 +1401,29 @@ static void collapse_file(struct mm_struct *mm,
>  				result = SCAN_FAIL;
>  				goto xa_unlocked;
>  			}
> +		} else if (!page || xa_is_value(page)) {
> +			xas_unlock_irq(&xas);
> +			page_cache_sync_readahead(mapping, &file->f_ra, file,
> +						  index, PAGE_SIZE);
> +			/* drain pagevecs to help isolate_lru_page() */
> +			lru_add_drain();
> +			page = find_lock_page(mapping, index);
> +			if (unlikely(page == NULL)) {
> +				result = SCAN_FAIL;
> +				goto xa_unlocked;
> +			}
> +		} else if (!PageUptodate(page)) {
> +			VM_BUG_ON(is_shmem);
> +			xas_unlock_irq(&xas);
> +			wait_on_page_locked(page);
> +			if (!trylock_page(page)) {
> +				result = SCAN_PAGE_LOCK;
> +				goto xa_unlocked;
> +			}
> +			get_page(page);
> +		} else if (!is_shmem && PageDirty(page)) {
> +			result = SCAN_FAIL;
> +			goto xa_locked;
>  		} else if (trylock_page(page)) {
>  			get_page(page);
>  			xas_unlock_irq(&xas);

The many else ifs here check fairly complex page state and are hard to
follow and verify mentally. In fact, it's a bit easier now in the
patch when you see how it *used* to work with just shmem, but the end
result is fragile from a maintenance POV.

The shmem and file cases have little in common - basically only the
trylock_page(). Can you please make one big 'if (is_shmem) {} {}'
structure instead that keeps those two scenarios separate?

> @@ -1426,6 +1458,12 @@ static void collapse_file(struct mm_struct *mm,
>  			goto out_unlock;
>  		}
>  
> +		if (page_has_private(page) &&
> +		    !try_to_release_page(page, GFP_KERNEL)) {
> +			result = SCAN_PAGE_HAS_PRIVATE;
> +			break;
> +		}
> +
>  		if (page_mapped(page))
>  			unmap_mapping_pages(mapping, index, 1, false);

> @@ -1607,6 +1658,17 @@ static void khugepaged_scan_file(struct mm_struct *mm,
>  			break;
>  		}
>  
> +		if (page_has_private(page) && trylock_page(page)) {
> +			int ret;
> +
> +			ret = try_to_release_page(page, GFP_KERNEL);
> +			unlock_page(page);
> +			if (!ret) {
> +				result = SCAN_PAGE_HAS_PRIVATE;
> +				break;
> +			}
> +		}
> +
>  		if (page_count(page) != 1 + page_mapcount(page)) {
>  			result = SCAN_PAGE_COUNT;
>  			break;

There is already a try_to_release() inside the page lock section in
collapse_file(). I'm assuming you added this one because private data
affects the refcount. But it seems a bit overkill just for that; we
could also still fail the check, in which case we'd have dropped the
buffers in vain. Can you fix the check instead?

There is an is_page_cache_freeable() function in vmscan.c that handles
private fs references:

static inline int is_page_cache_freeable(struct page *page)
{
	/*
	 * A freeable page cache page is referenced only by the caller
	 * that isolated the page, the page cache and optional buffer
	 * heads at page->private.
	 */
	int page_cache_pins = PageTransHuge(page) && PageSwapCache(page) ?
		HPAGE_PMD_NR : 1;
	return page_count(page) - page_has_private(page) == 1 + page_cache_pins;
}

Wouldn't this work here as well?

The rest looks great to me.

