Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f47.google.com (mail-qg0-f47.google.com [209.85.192.47])
	by kanga.kvack.org (Postfix) with ESMTP id BCFEC6B006E
	for <linux-mm@kvack.org>; Wed, 17 Dec 2014 12:24:47 -0500 (EST)
Received: by mail-qg0-f47.google.com with SMTP id q108so10148282qgd.34
        for <linux-mm@kvack.org>; Wed, 17 Dec 2014 09:24:47 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z3si5230924qaj.112.2014.12.17.09.24.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Dec 2014 09:24:46 -0800 (PST)
Message-ID: <5491B031.3070107@redhat.com>
Date: Wed, 17 Dec 2014 11:32:49 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v4] mm: prevent endless growth of anon_vma hierarchy
References: <20141217085737.16381.75639.stgit@zurg>
In-Reply-To: <20141217085737.16381.75639.stgit@zurg>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Tim Hartrick <tim@edgecast.com>, Daniel Forrest <dan.forrest@ssec.wisc.edu>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Michel Lespinasse <walken@google.com>, Vlastimil Babka <vbabka@suse.cz>

On 12/17/2014 02:57 AM, Konstantin Khlebnikov wrote:

> @@ -236,6 +240,13 @@ static inline void unlock_anon_vma_root(struct anon_vma *root)
>  /*
>   * Attach the anon_vmas from src to dst.
>   * Returns 0 on success, -ENOMEM on failure.
> + *
> + * If dst->anon_vma is NULL this function tries to find and reuse existing
> + * anon_vma which has no vmas and only one child anon_vma. This prevents
> + * degradation of anon_vma hierarchy to endless linear chain in case of
> + * constantly forking task. In other hand anon_vma with more than one child
> + * isn't reused even if was no alive vma, thus rmap walker has a good chance
> + * to avoid scanning whole hieraryhy when it searches where page is mapped.
                              ^^^^^^^^^
                              hierarchy

Other than that:

Reviewed-by: Rik van Riel <riel@redhat.com>


Thanks for fixing this long standing issue, Konstantin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
