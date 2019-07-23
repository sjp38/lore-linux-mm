Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F3A67C7618F
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 03:08:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 84CBC22389
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 03:08:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=plexistor-com.20150623.gappssmtp.com header.i=@plexistor-com.20150623.gappssmtp.com header.b="t088Puwr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 84CBC22389
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=plexistor.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E21426B0003; Mon, 22 Jul 2019 23:08:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DD19C8E0003; Mon, 22 Jul 2019 23:08:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C97FB8E0001; Mon, 22 Jul 2019 23:08:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7FCE86B0003
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 23:08:44 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id g8so20077518wrw.2
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 20:08:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=2PtG4zp50XPwrR+6BzWVC0eSAfvVyl2TtA+I12FZ4Qs=;
        b=QWbwJrWYAh9b7q0PYHtemu+p/3qtEPflJrP0/xkU7phE3DClB9kr/qo5U7AEYuw3lP
         xJ1UbgId+TsXaSEe/FevVzXmTR8wGkMtx2AsSGwBiyfCELC6Ta0GnePgzO19KflsqVbv
         YPkQTL/Yn/tR6YA9LwnX5qdoA1jMoq9wLZ8mHpnIDTME7iWzKOqQDvzeOTWrsUEasXi1
         CDuIiUrWEWgznya3SpS8XqahAiHyBUpTvG0lFJcWq/clR4mOQ6E86CDtrVHK1c0BQhGc
         AXIYVxLPFkXJlU26BIM6MvCinJkWsH72okpA9Yvs11aumJ4DSTAOCV3x1scNiRMX3IjH
         h+FQ==
X-Gm-Message-State: APjAAAV33tQLUigmG1HegKsCR10k7/hZJYHT1sOhPyZZJ4kH9Zbv7yQO
	1krm4N8dCv8CnRVWYSLwq9ubnuFTFt+Na6S4pD7ETl18Nqc0geKSIjaTJ+/o1gQ5MHRoErZ6sKc
	ghG+NOZ9o50txNLe+olSTOulODwbMxGzHNHCLxTqOCxWwocw9yMDZBS2xWmnR5XI=
X-Received: by 2002:adf:d4c1:: with SMTP id w1mr5119445wrk.229.1563851322968;
        Mon, 22 Jul 2019 20:08:42 -0700 (PDT)
X-Received: by 2002:adf:d4c1:: with SMTP id w1mr5119303wrk.229.1563851321750;
        Mon, 22 Jul 2019 20:08:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563851321; cv=none;
        d=google.com; s=arc-20160816;
        b=QOk6EJ1h2TWLmE+6nhAfPAysusGsRLf2GRQsRhmF1y7Rkh5ekvrktZAG42Q1VDUkoT
         Umw2llLE6ZEhoHSAXVN9VxxEspIuX5qeBW7RhszL3kVNLFywKZgYW5BCZzWOCgKRCcJj
         2Bnl2wNYl5UxplE4hLjElLueQ+5IDwp2bNTkZTZL7PLu52XRfI0+RCH9izK3M8jEk4Nk
         4DWXXsJYji5XHduTGlQCtnh8wrvNxYppqyY+Ffpc85jTFhG36a7fOUtPoBtKPlWuBKt1
         TuYAngCSsxO5NFQHb0T3g2atpMuo90dFUkHVsUnavhNi58D723278SJkw488SetyJBAm
         2xRQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=2PtG4zp50XPwrR+6BzWVC0eSAfvVyl2TtA+I12FZ4Qs=;
        b=ti8LYmFoKyuMZ9r3cjfmcVpygTuc1IqbJ1bYUCJST6wD+mdCM+RN+ZhCOOIf9jFk4Q
         kfGFD+PCuTZW/wRXIBXzmStl5kLT7NStg/LzMDpBeVAKDsvcpR61frNYin52Ah6Bc2y+
         6rApSXzMcFAA/p7CAHL7aL0Dxr+F2y9wsUfvzyUwrzNXSzpatVg4vv1hNIMtmapxkbpO
         lX0R0bCod3ZvqNbR1el136nkhIiz0ILXuy9hwJBiLjKurN+5avzn6bNxAqADqDqYuokO
         Jf2R8SEl+hkih2F8Vl+kUESOu5GhjFIUD5pau2Iaba7O+YO4nq5e68Nmt5wutqQgA0Ag
         bBCg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@plexistor-com.20150623.gappssmtp.com header.s=20150623 header.b=t088Puwr;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of boaz@plexistor.com) smtp.mailfrom=boaz@plexistor.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g5sor19805591wrr.21.2019.07.22.20.08.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 22 Jul 2019 20:08:41 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of boaz@plexistor.com) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@plexistor-com.20150623.gappssmtp.com header.s=20150623 header.b=t088Puwr;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of boaz@plexistor.com) smtp.mailfrom=boaz@plexistor.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=plexistor-com.20150623.gappssmtp.com; s=20150623;
        h=subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=2PtG4zp50XPwrR+6BzWVC0eSAfvVyl2TtA+I12FZ4Qs=;
        b=t088Puwr+O8xjDR0LPzH0uhmskUhFRDzq/e5yWqd9g4mTsJFSj1S8dO3Udg3AD+2dq
         577gq+lrNqf7sOUaIKlAIg68s6dMsyjSs0AyIDSOkpt5PhVWmunLgfW4eLp513Mlb1dz
         hAthKC5YrLG3+UsBNzzMEn66Vp8I84yf4OmLzUtLOIDsydvY/m2V9Y1SBBuZm56n/NjR
         3VI7f9unQ+ojYhFSe+nzZrMq0XIIGh1qqLtK6pZX2UPkTPmhyqD7TeoDZgVK21zQ6zVp
         kGifCWbuMNbOthtwiH4tiML3heQt5GgCfkR2Jfx9fgtIhwEbgVELVaS9zHJdqsUoWHgv
         +95g==
X-Google-Smtp-Source: APXvYqwNjbQQHEnQf9EO2BooRCjynSwNWlhbjrMQSdKfWJ6RSFiQMVrNJoUDRH/BuXrQurKluvxoFg==
X-Received: by 2002:adf:e941:: with SMTP id m1mr68919804wrn.279.1563851321164;
        Mon, 22 Jul 2019 20:08:41 -0700 (PDT)
Received: from [10.68.217.182] ([217.70.211.18])
        by smtp.googlemail.com with ESMTPSA id e6sm41743574wrw.23.2019.07.22.20.08.39
        (version=TLS1_3 cipher=AEAD-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Jul 2019 20:08:40 -0700 (PDT)
Subject: Re: [PATCH 1/3] mm: Handle MADV_WILLNEED through vfs_fadvise()
To: Jan Kara <jack@suse.cz>, linux-fsdevel@vger.kernel.org
Cc: linux-mm@kvack.org, linux-xfs@vger.kernel.org,
 Amir Goldstein <amir73il@gmail.com>, Boaz Harrosh <boaz@plexistor.com>,
 stable@vger.kernel.org
References: <20190711140012.1671-1-jack@suse.cz>
 <20190711140012.1671-2-jack@suse.cz>
From: Boaz Harrosh <boaz@plexistor.com>
Message-ID: <9da4596e-7de2-9ba1-0fc0-62bf83c39488@plexistor.com>
Date: Tue, 23 Jul 2019 06:08:37 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190711140012.1671-2-jack@suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-MW
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 11/07/2019 17:00, Jan Kara wrote:
> Currently handling of MADV_WILLNEED hint calls directly into readahead
> code. Handle it by calling vfs_fadvise() instead so that filesystem can
> use its ->fadvise() callback to acquire necessary locks or otherwise
> prepare for the request.
> 
> Suggested-by: Amir Goldstein <amir73il@gmail.com>
> CC: stable@vger.kernel.org # Needed by "xfs: Fix stale data exposure
> 					when readahead races with hole punch"
> Signed-off-by: Jan Kara <jack@suse.cz>

I had a similar patch for my needs. But did not drop the mmap_sem when calling into
the FS. This one is much better.

Reviewed-by: Boaz Harrosh <boazh@netapp.com>

I tested this patch, Works perfect for my needs.

Thank you for this patch
Boaz

> ---
>  mm/madvise.c | 22 ++++++++++++++++------
>  1 file changed, 16 insertions(+), 6 deletions(-)
> 
> diff --git a/mm/madvise.c b/mm/madvise.c
> index 628022e674a7..ae56d0ef337d 100644
> --- a/mm/madvise.c
> +++ b/mm/madvise.c
> @@ -14,6 +14,7 @@
>  #include <linux/userfaultfd_k.h>
>  #include <linux/hugetlb.h>
>  #include <linux/falloc.h>
> +#include <linux/fadvise.h>
>  #include <linux/sched.h>
>  #include <linux/ksm.h>
>  #include <linux/fs.h>
> @@ -275,6 +276,7 @@ static long madvise_willneed(struct vm_area_struct *vma,
>  			     unsigned long start, unsigned long end)
>  {
>  	struct file *file = vma->vm_file;
> +	loff_t offset;
>  
>  	*prev = vma;
>  #ifdef CONFIG_SWAP
> @@ -298,12 +300,20 @@ static long madvise_willneed(struct vm_area_struct *vma,
>  		return 0;
>  	}
>  
> -	start = ((start - vma->vm_start) >> PAGE_SHIFT) + vma->vm_pgoff;
> -	if (end > vma->vm_end)
> -		end = vma->vm_end;
> -	end = ((end - vma->vm_start) >> PAGE_SHIFT) + vma->vm_pgoff;
> -
> -	force_page_cache_readahead(file->f_mapping, file, start, end - start);
> +	/*
> +	 * Filesystem's fadvise may need to take various locks.  We need to
> +	 * explicitly grab a reference because the vma (and hence the
> +	 * vma's reference to the file) can go away as soon as we drop
> +	 * mmap_sem.
> +	 */
> +	*prev = NULL;	/* tell sys_madvise we drop mmap_sem */
> +	get_file(file);
> +	up_read(&current->mm->mmap_sem);
> +	offset = (loff_t)(start - vma->vm_start)
> +			+ ((loff_t)vma->vm_pgoff << PAGE_SHIFT);
> +	vfs_fadvise(file, offset, end - start, POSIX_FADV_WILLNEED);
> +	fput(file);
> +	down_read(&current->mm->mmap_sem);
>  	return 0;
>  }
>  
> 

