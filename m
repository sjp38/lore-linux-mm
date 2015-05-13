Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 2FAA76B0038
	for <linux-mm@kvack.org>; Wed, 13 May 2015 04:08:44 -0400 (EDT)
Received: by pdbnk13 with SMTP id nk13so43918247pdb.0
        for <linux-mm@kvack.org>; Wed, 13 May 2015 01:08:43 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id fr13si26033230pdb.203.2015.05.13.01.08.43
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 May 2015 01:08:43 -0700 (PDT)
Date: Wed, 13 May 2015 11:08:23 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH v2] rmap: fix theoretical race between do_wp_page and
 shrink_active_list
Message-ID: <20150513080823.GH17628@esperanza>
References: <1431425919-28057-1-git-send-email-vdavydov@parallels.com>
 <20150512152840.20805775ae82c69b9a8f3028@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20150512152840.20805775ae82c69b9a8f3028@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>

On Tue, May 12, 2015 at 03:28:40PM -0700, Andrew Morton wrote:
> Please let's not put things like WRITE_ONCE() in there without
> documenting them - otherwise it's terribly hard for readers to work out
> why it was added.
> 
> How's this look?
> 
> --- a/mm/rmap.c~rmap-fix-theoretical-race-between-do_wp_page-and-shrink_active_list-fix
> +++ a/mm/rmap.c
> @@ -950,6 +950,11 @@ void page_move_anon_rmap(struct page *pa
>  	VM_BUG_ON_PAGE(page->index != linear_page_index(vma, address), page);
>  
>  	anon_vma = (void *) anon_vma + PAGE_MAPPING_ANON;
> +	/*
> +	 * Ensure that anon_vma and the PAGE_MAPPING_ANON bit are written
> +	 * simultaneously, so a concurrent reader (eg shrink_active_list) will
> +	 * not see one without the other.
> +	 */
>  	WRITE_ONCE(page->mapping, (struct address_space *) anon_vma);
>  }

Looks good to me.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
