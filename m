Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EE470C0650F
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 15:01:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A49152089E
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 15:01:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="GdNRwja+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A49152089E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 369888E0006; Tue, 30 Jul 2019 11:01:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 31A8A8E0001; Tue, 30 Jul 2019 11:01:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1E1E88E0006; Tue, 30 Jul 2019 11:01:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id C1BE08E0001
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 11:01:11 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id f19so40530836edv.16
        for <linux-mm@kvack.org>; Tue, 30 Jul 2019 08:01:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=bQWucyIKvCKeKopDX4ZksHy14UtOcimGNYOu7selEmU=;
        b=dxJRE4/KduStPXm1fZhPV/5TXv5VgdpGbDtBhVALNMjpnzM1b0vDs6brpzOGBQtIm8
         A249tnyyf7Py1YQh3F/r5mfXsKmk+hUUjuZGKTnD9wYgq6+Fucpr4W1ccLcika4bDvQT
         pWXgiG0/65Q+Lrocj66jVPhXTsKqXv/6BZ0qXYsfO1Q4i6vyEer9yR7iuBQsw9NRBRoM
         tz04g2hAZmEbaQHIgzZg9HgIHbLbGFXkMFJHzT8hm8U/e9DMFx0il7QtGT9c7JFuug1e
         NodV9KL2HnloRZBzctY76sWIoyjXdHyOGuDsKDaCYuWTJV6MfjxGpX2aCUn9+ghPcl5C
         TavA==
X-Gm-Message-State: APjAAAUkx5i0VS+AgjIsxX/pIk8BEoALCpPxCfsaiQQH/i2HQCEx6WYz
	/PoNUFfQwDMLtC8/0rtQJMJEAvjZAfl0/+8bpfoz9eryTFpvRy5KaVfcpCh1P+FwZ80euqRIgf6
	0o+32/JD/XmNkcnowbQJLARXfuCi7b7ZzEEgopwRHxuvalBqi8qhD9r42reUi7zk=
X-Received: by 2002:a17:906:3d69:: with SMTP id r9mr35568522ejf.28.1564498871348;
        Tue, 30 Jul 2019 08:01:11 -0700 (PDT)
X-Received: by 2002:a17:906:3d69:: with SMTP id r9mr35568426ejf.28.1564498870435;
        Tue, 30 Jul 2019 08:01:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564498870; cv=none;
        d=google.com; s=arc-20160816;
        b=lt0tsr70bBrVnUt1xwbq8eaTBgwqOpg8GrlrwcqzokJfGlZ+heOs0fnDIiNHFr4tD6
         xC6d7JDewA1PfiKthSpc1tQG0fD+xCLsUYYt82rj6AxcwsPPOgyyew1ynQSskUeEoiD8
         xzl1QwpmNkEc4VkykBVEZKZe1N3yB3tvcZcYYHyXDiuCALnsN8IYLYszQampj9rHGZT9
         DDdFAw3gE6LEfpImTaf9dhFvQrM5se9WLRUj47hMuDE2fcg2Lw+6i0zf3000YYbdX2CO
         ffNtqDp3TGLhVhug8haoEh8Ft2mGACKpZkoHM1odmmbaTOS9QF4oxqP2qc3mQcJKTQ5A
         w/Xw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=bQWucyIKvCKeKopDX4ZksHy14UtOcimGNYOu7selEmU=;
        b=ajPngsgEcTpmmrJS46M/4EbmrbqxD3vlG6uk+keG3g+eGvxNAl0sCiq4N/k/6g8ljp
         5Ay02kq8CgGaZXcSWJ6usAd8jeOzWjUHkY8XyGnb8E0zoCSlNduJ5ajqMTJY+lh0cu75
         GFtDsoqGDPSEzwpW//WVSa14YUpjWqNbMQkIY0qk+LQYcTRW5ZINvbLfpVSWzwSrctiX
         ReaYf3ak5oCFHjbm13ne5YVdxM3ATrCLNNnYTyLQAfQXDY5SZJ2FR6C02muJpONDGBZr
         WbMSpx1MYznipgx/sYti0kq5vIZvakudpvOkkAmdY8N/atP1LIUvLWx0msFltR1nBW6S
         sV5Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=GdNRwja+;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b56sor49328549edb.9.2019.07.30.08.01.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 30 Jul 2019 08:01:10 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=GdNRwja+;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=bQWucyIKvCKeKopDX4ZksHy14UtOcimGNYOu7selEmU=;
        b=GdNRwja+/25H4SxUZ4ralc99QLXtPYO2kj4H0jLiarKQZUn/l8l1B/z2ZXWZRqNuZz
         Bo97G25Ewtp9jrs7GZbl+3mcVqn/Z6kURcIxMGDgvQxtCGAakJaf/QdyTAVoApyqsPCi
         +KeelUNoacnfmu1MSDGt1BE4PkOnW93teyfZjh0bIJ++GsJrR+OqNatermEhdUGCzqvs
         MR5irSWphHO6klpLr30FcWHLDfGZR65mQYzA7D2nmY0kJui2TgthhRjXVcKuBE9X5ooQ
         Y2u+Fy9LUIhK3lJN/lDzNl8X1ZwlZ5ztF/YApdnpbYcs7UzifwAgUuDC5YHTQ6AJ8kA+
         CLsQ==
X-Google-Smtp-Source: APXvYqyL2odYUrW+8WuVCn0Ui36foqk2fFzmQK1cuc8eMBoSNxrRogxxj3ymkZEHr7GpPbiBvSWG9w==
X-Received: by 2002:a50:9107:: with SMTP id e7mr102905767eda.280.1564498870080;
        Tue, 30 Jul 2019 08:01:10 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id 34sm16475720eds.5.2019.07.30.08.01.09
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jul 2019 08:01:09 -0700 (PDT)
Received: by box.localdomain (Postfix, from userid 1000)
	id BB4A2100AD0; Tue, 30 Jul 2019 18:01:10 +0300 (+03)
Date: Tue, 30 Jul 2019 18:01:10 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Song Liu <songliubraving@fb.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	akpm@linux-foundation.org, matthew.wilcox@oracle.com,
	kirill.shutemov@linux.intel.com, oleg@redhat.com,
	kernel-team@fb.com, william.kucharski@oracle.com,
	srikar@linux.vnet.ibm.com
Subject: Re: [PATCH 2/2] uprobe: collapse THP pmd after removing all uprobes
Message-ID: <20190730150110.yqib7bawsude2vqt@box>
References: <20190729054335.3241150-1-songliubraving@fb.com>
 <20190729054335.3241150-3-songliubraving@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190729054335.3241150-3-songliubraving@fb.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Jul 28, 2019 at 10:43:35PM -0700, Song Liu wrote:
> After all uprobes are removed from the huge page (with PTE pgtable), it
> is possible to collapse the pmd and benefit from THP again. This patch
> does the collapse by calling khugepaged_add_pte_mapped_thp().
> 
> Signed-off-by: Song Liu <songliubraving@fb.com>
> ---
>  kernel/events/uprobes.c | 9 +++++++++
>  1 file changed, 9 insertions(+)
> 
> diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
> index 58ab7fc7272a..cc53789fefc6 100644
> --- a/kernel/events/uprobes.c
> +++ b/kernel/events/uprobes.c
> @@ -26,6 +26,7 @@
>  #include <linux/percpu-rwsem.h>
>  #include <linux/task_work.h>
>  #include <linux/shmem_fs.h>
> +#include <linux/khugepaged.h>
>  
>  #include <linux/uprobes.h>
>  
> @@ -470,6 +471,7 @@ int uprobe_write_opcode(struct arch_uprobe *auprobe, struct mm_struct *mm,
>  	struct page *old_page, *new_page;
>  	struct vm_area_struct *vma;
>  	int ret, is_register, ref_ctr_updated = 0;
> +	bool orig_page_huge = false;
>  
>  	is_register = is_swbp_insn(&opcode);
>  	uprobe = container_of(auprobe, struct uprobe, arch);
> @@ -525,6 +527,9 @@ int uprobe_write_opcode(struct arch_uprobe *auprobe, struct mm_struct *mm,
>  
>  				/* dec_mm_counter for old_page */
>  				dec_mm_counter(mm, MM_ANONPAGES);
> +
> +				if (PageCompound(orig_page))
> +					orig_page_huge = true;
>  			}
>  			put_page(orig_page);
>  		}
> @@ -543,6 +548,10 @@ int uprobe_write_opcode(struct arch_uprobe *auprobe, struct mm_struct *mm,
>  	if (ret && is_register && ref_ctr_updated)
>  		update_ref_ctr(uprobe, mm, -1);
>  
> +	/* try collapse pmd for compound page */
> +	if (!ret && orig_page_huge)
> +		khugepaged_add_pte_mapped_thp(mm, vaddr & HPAGE_PMD_MASK);
> +

IIUC, here you have all locks taken, so you should be able to call
collapse_pte_mapped_thp() directly, shouldn't you?

-- 
 Kirill A. Shutemov

