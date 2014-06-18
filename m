Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f52.google.com (mail-qg0-f52.google.com [209.85.192.52])
	by kanga.kvack.org (Postfix) with ESMTP id A5D3C6B0031
	for <linux-mm@kvack.org>; Wed, 18 Jun 2014 11:28:10 -0400 (EDT)
Received: by mail-qg0-f52.google.com with SMTP id f51so876356qge.25
        for <linux-mm@kvack.org>; Wed, 18 Jun 2014 08:28:10 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l9si2758251qaa.85.2014.06.18.08.28.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Jun 2014 08:28:10 -0700 (PDT)
Date: Wed, 18 Jun 2014 17:22:09 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] fork: dup_mm: init vm stat counters under mmap_sem
Message-ID: <20140618152209.GA14818@redhat.com>
References: <1403098391-24546-1-git-send-email-vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1403098391-24546-1-git-send-email-vdavydov@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: akpm@linux-foundation.org, rientjes@google.com, cl@linux.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 06/18, Vladimir Davydov wrote:
>
> @@ -365,7 +365,12 @@ static int dup_mmap(struct mm_struct *mm, struct mm_struct *oldmm)
>  	 */
>  	down_write_nested(&mm->mmap_sem, SINGLE_DEPTH_NESTING);
>  
> +	mm->total_vm = oldmm->total_vm;
>  	mm->locked_vm = 0;
> +	mm->pinned_vm = 0;
> +	mm->shared_vm = oldmm->shared_vm;
> +	mm->exec_vm = oldmm->exec_vm;
> +	mm->stack_vm = oldmm->stack_vm;
>  	mm->mmap = NULL;
>  	mm->vmacache_seqnum = 0;
>  	mm->map_count = 0;

I think the patch is fine.


But perhaps this deserves more cleanups, with or without this patch
the initialization does not look consistent. dup_mmap() nullifies
locked_vm/pinned_vm/mmap/map_count while mm_init() clears core_state/
nr_ptes/rss_stat.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
