Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9F94B6B240A
	for <linux-mm@kvack.org>; Wed, 22 Aug 2018 07:11:06 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id k48-v6so805442ede.14
        for <linux-mm@kvack.org>; Wed, 22 Aug 2018 04:11:06 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q34-v6si1802868edq.412.2018.08.22.04.11.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Aug 2018 04:11:05 -0700 (PDT)
Subject: Re: [RFC v8 PATCH 3/5] mm: mmap: zap pages with read mmap_sem in
 munmap
References: <1534358990-85530-1-git-send-email-yang.shi@linux.alibaba.com>
 <1534358990-85530-4-git-send-email-yang.shi@linux.alibaba.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <7145895b-ef56-f5ee-d139-609819d9a107@suse.cz>
Date: Wed, 22 Aug 2018 13:11:03 +0200
MIME-Version: 1.0
In-Reply-To: <1534358990-85530-4-git-send-email-yang.shi@linux.alibaba.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>, mhocko@kernel.org, willy@infradead.org, ldufour@linux.vnet.ibm.com, kirill@shutemov.name, akpm@linux-foundation.org, peterz@infradead.org, mingo@redhat.com, acme@kernel.org, alexander.shishkin@linux.intel.com, jolsa@redhat.com, namhyung@kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 08/15/2018 08:49 PM, Yang Shi wrote:

> +	start_vma = munmap_lookup_vma(mm, start, end);
> +	if (!start_vma)
> +		goto out;
> +	if (IS_ERR(start_vma)) {
> +		ret = PTR_ERR(start_vma);
> +		goto out;
> +	}
> +
> +	prev = start_vma->vm_prev;
> +
> +	if (unlikely(uf)) {
> +		ret = userfaultfd_unmap_prep(start_vma, start, end, uf);
> +		if (ret)
> +			goto out;
> +	}
> +

You sure it's ok to redo this in case of goto regular path? The
preparations have some side-effects... I would rather move this after
the regular path check?
