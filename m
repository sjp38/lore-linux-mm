Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 2D7A6440313
	for <linux-mm@kvack.org>; Mon,  5 Oct 2015 03:53:24 -0400 (EDT)
Received: by wicfx3 with SMTP id fx3so106710046wic.1
        for <linux-mm@kvack.org>; Mon, 05 Oct 2015 00:53:23 -0700 (PDT)
Received: from casper.infradead.org (casper.infradead.org. [2001:770:15f::2])
        by mx.google.com with ESMTPS id gz7si14909624wib.35.2015.10.05.00.53.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Oct 2015 00:53:23 -0700 (PDT)
Date: Mon, 5 Oct 2015 09:53:18 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v4 2/4] mm, proc: account for shmem swap in
 /proc/pid/smaps
Message-ID: <20151005075318.GE2903@worktop.programming.kicks-ass.net>
References: <1443792951-13944-1-git-send-email-vbabka@suse.cz>
 <1443792951-13944-3-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1443792951-13944-3-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Jerome Marchand <jmarchan@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Randy Dunlap <rdunlap@infradead.org>, linux-s390@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Paul Mackerras <paulus@samba.org>, Arnaldo Carvalho de Melo <acme@kernel.org>, Oleg Nesterov <oleg@redhat.com>, Linux API <linux-api@vger.kernel.org>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>

On Fri, Oct 02, 2015 at 03:35:49PM +0200, Vlastimil Babka wrote:
> +static unsigned long smaps_shmem_swap(struct vm_area_struct *vma)
> +{
> +	struct inode *inode;
> +	unsigned long swapped;
> +	pgoff_t start, end;
> +
> +	if (!vma->vm_file)
> +		return 0;
> +
> +	inode = file_inode(vma->vm_file);
> +
> +	if (!shmem_mapping(inode->i_mapping))
> +		return 0;
> +
> +	/*
> +	 * The easier cases are when the shmem object has nothing in swap, or
> +	 * we have the whole object mapped. Then we can simply use the stats
> +	 * that are already tracked by shmem.
> +	 */
> +	swapped = shmem_swap_usage(inode);
> +
> +	if (swapped == 0)
> +		return 0;
> +
> +	if (vma->vm_end - vma->vm_start >= inode->i_size)
> +		return swapped;
> +
> +	/*
> +	 * Here we have to inspect individual pages in our mapped range to
> +	 * determine how much of them are swapped out. Thanks to RCU, we don't
> +	 * need i_mutex to protect against truncating or hole punching.
> +	 */

At the very least put in an assertion that we hold the RCU read lock,
otherwise RCU doesn't guarantee anything and its not obvious it is held
here.

> +	start = linear_page_index(vma, vma->vm_start);
> +	end = linear_page_index(vma, vma->vm_end);
> +
> +	return shmem_partial_swap_usage(inode->i_mapping, start, end);
> +}

> + * Determine (in bytes) how much of the whole shmem object is swapped out.
> + */
> +unsigned long shmem_swap_usage(struct inode *inode)
> +{
> +	struct shmem_inode_info *info = SHMEM_I(inode);
> +	unsigned long swapped;
> +
> +	/* Mostly an overkill, but it's not atomic64_t */

Yeah, that don't make any kind of sense.

> +	spin_lock(&info->lock);
> +	swapped = info->swapped;
> +	spin_unlock(&info->lock);
> +
> +	return swapped << PAGE_SHIFT;
> +}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
