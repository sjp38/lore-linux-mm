Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 4C8C76B00CB
	for <linux-mm@kvack.org>; Mon, 17 Mar 2014 16:53:39 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id fa1so6285151pad.0
        for <linux-mm@kvack.org>; Mon, 17 Mar 2014 13:53:38 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id wp10si15700486pbc.227.2014.03.17.13.53.35
        for <linux-mm@kvack.org>;
        Mon, 17 Mar 2014 13:53:36 -0700 (PDT)
Message-ID: <532760CF.10704@intel.com>
Date: Mon, 17 Mar 2014 13:53:35 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/9] mm: Provide new get_vaddr_pfns() helper
References: <1395085776-8626-1-git-send-email-jack@suse.cz> <1395085776-8626-2-git-send-email-jack@suse.cz>
In-Reply-To: <1395085776-8626-2-git-send-email-jack@suse.cz>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>, linux-mm@kvack.org
Cc: linux-media@vger.kernel.org

On 03/17/2014 12:49 PM, Jan Kara wrote:
> +int get_vaddr_pfns(unsigned long start, int nr_pfns, int write, int force,
> +		   struct pinned_pfns *pfns)
> +{
...
> +	if (!(vma->vm_flags & (VM_IO | VM_PFNMAP))) {
> +		pfns->got_ref = 1;
> +		pfns->is_pages = 1;
> +		ret = get_user_pages(current, mm, start, nr_pfns, write, force,
> +				     pfns_vector_pages(pfns), NULL);
> +		goto out;
> +	}

Have you given any thought to how this should deal with VM_MIXEDMAP
vmas?  get_user_pages() will freak when it hits the !vm_normal_page()
test on the pfnmapped ones, and jump out.  Shouldn't get_vaddr_pfns() be
able to handle those too?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
