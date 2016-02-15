Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f177.google.com (mail-ob0-f177.google.com [209.85.214.177])
	by kanga.kvack.org (Postfix) with ESMTP id A968F6B0005
	for <linux-mm@kvack.org>; Mon, 15 Feb 2016 01:15:51 -0500 (EST)
Received: by mail-ob0-f177.google.com with SMTP id wb13so199531680obb.1
        for <linux-mm@kvack.org>; Sun, 14 Feb 2016 22:15:51 -0800 (PST)
Received: from e23smtp04.au.ibm.com (e23smtp04.au.ibm.com. [202.81.31.146])
        by mx.google.com with ESMTPS id dq4si10123351oeb.52.2016.02.14.22.15.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 14 Feb 2016 22:15:51 -0800 (PST)
Received: from localhost
	by e23smtp04.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Mon, 15 Feb 2016 16:15:47 +1000
Received: from d23relay07.au.ibm.com (d23relay07.au.ibm.com [9.190.26.37])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 43C0C2CE8059
	for <linux-mm@kvack.org>; Mon, 15 Feb 2016 17:15:44 +1100 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay07.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u1F6FX2G55640162
	for <linux-mm@kvack.org>; Mon, 15 Feb 2016 17:15:44 +1100
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u1F6F8NR024729
	for <linux-mm@kvack.org>; Mon, 15 Feb 2016 17:15:09 +1100
Date: Mon, 15 Feb 2016 11:44:41 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH 01/33] mm: introduce get_user_pages_remote()
Message-ID: <20160215061441.GB31846@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20160212210152.9CAD15B0@viggo.jf.intel.com>
 <20160212210154.3F0E51EA@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20160212210154.3F0E51EA@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, torvalds@linux-foundation.org, dave.hansen@linux.intel.com, vbabka@suse.cz, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, aarcange@redhat.com, n-horiguchi@ah.jp.nec.com, jack@suse.cz

> diff -puN kernel/events/uprobes.c~introduce-get_user_pages_remote kernel/events/uprobes.c
> --- a/kernel/events/uprobes.c~introduce-get_user_pages_remote	2016-02-12 10:44:13.178107026 -0800
> +++ b/kernel/events/uprobes.c	2016-02-12 10:44:13.193107711 -0800
> @@ -299,7 +299,7 @@ int uprobe_write_opcode(struct mm_struct
> 
>  retry:
>  	/* Read the page with vaddr into memory */
> -	ret = get_user_pages(NULL, mm, vaddr, 1, 0, 1, &old_page, &vma);
> +	ret = get_user_pages_remote(NULL, mm, vaddr, 1, 0, 1, &old_page, &vma);
>  	if (ret <= 0)
>  		return ret;
> 
> @@ -1700,7 +1700,13 @@ static int is_trap_at_addr(struct mm_str
>  	if (likely(result == 0))
>  		goto out;
> 
> -	result = get_user_pages(NULL, mm, vaddr, 1, 0, 1, &page, NULL);
> +	/*
> +	 * The NULL 'tsk' here ensures that any faults that occur here
> +	 * will not be accounted to the task.  'mm' *is* current->mm,
> +	 * but we treat this as a 'remote' access since it is
> +	 * essentially a kernel access to the memory.
> +	 */
> +	result = get_user_pages_remote(NULL, mm, vaddr, 1, 0, 1, &page, NULL);
>  	if (result < 0)
>  		return result;
> 

Reviewed-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>

-- 
Thanks and Regards
Srikar Dronamraju

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
