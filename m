Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 006446B0260
	for <linux-mm@kvack.org>; Tue, 31 Jan 2017 10:44:46 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id i34so139231952qkh.6
        for <linux-mm@kvack.org>; Tue, 31 Jan 2017 07:44:45 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d123si12166524qkg.286.2017.01.31.07.44.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Jan 2017 07:44:45 -0800 (PST)
Date: Tue, 31 Jan 2017 16:44:42 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCHv3 01/12] uprobes: split THPs before trying replace them
Message-ID: <20170131154442.GA21637@redhat.com>
References: <20170129173858.45174-1-kirill.shutemov@linux.intel.com>
 <20170129173858.45174-2-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170129173858.45174-2-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>

On 01/29, Kirill A. Shutemov wrote:
>
> For THPs page_check_address() always fails. It leads to endless loop in
> uprobe_write_opcode().
>
> Testcase with huge-tmpfs (not sure if it's possible to trigger this
> uprobe codepath for anon memory):

No, you can't probe the anonymous memory,

> --- a/kernel/events/uprobes.c
> +++ b/kernel/events/uprobes.c
> @@ -300,8 +300,8 @@ int uprobe_write_opcode(struct mm_struct *mm, unsigned long vaddr,
>  
>  retry:
>  	/* Read the page with vaddr into memory */
> -	ret = get_user_pages_remote(NULL, mm, vaddr, 1, FOLL_FORCE, &old_page,
> -			&vma, NULL);
> +	ret = get_user_pages_remote(NULL, mm, vaddr, 1,
> +			FOLL_FORCE | FOLL_SPLIT, &old_page, &vma, NULL);
>  	if (ret <= 0)
>  		return ret;

Thanks,

Acked-by: Oleg Nesterov <oleg@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
