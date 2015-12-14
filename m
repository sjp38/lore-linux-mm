Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 2A6EA6B0255
	for <linux-mm@kvack.org>; Mon, 14 Dec 2015 07:11:11 -0500 (EST)
Received: by mail-wm0-f46.google.com with SMTP id n186so42585519wmn.0
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 04:11:11 -0800 (PST)
Received: from mail-wm0-x233.google.com (mail-wm0-x233.google.com. [2a00:1450:400c:c09::233])
        by mx.google.com with ESMTPS id ch4si45529416wjb.109.2015.12.14.04.11.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Dec 2015 04:11:10 -0800 (PST)
Received: by wmnn186 with SMTP id n186so117882522wmn.0
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 04:11:10 -0800 (PST)
Date: Mon, 14 Dec 2015 14:11:08 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC] mm: change find_vma() function
Message-ID: <20151214121107.GB4201@node.shutemov.name>
References: <1450090945-4020-1-git-send-email-yalin.wang2010@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1450090945-4020-1-git-send-email-yalin.wang2010@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: yalin wang <yalin.wang2010@gmail.com>
Cc: akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, oleg@redhat.com, gang.chen.5i5j@gmail.com, mhocko@suse.com, kwapulinski.piotr@gmail.com, aarcange@redhat.com, dcashman@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Dec 14, 2015 at 07:02:25PM +0800, yalin wang wrote:
> change find_vma() to break ealier when found the adderss
> is not in any vma, don't need loop to search all vma.
> 
> Signed-off-by: yalin wang <yalin.wang2010@gmail.com>
> ---
>  mm/mmap.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/mm/mmap.c b/mm/mmap.c
> index b513f20..8294c9b 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -2064,6 +2064,9 @@ struct vm_area_struct *find_vma(struct mm_struct *mm, unsigned long addr)
>  			vma = tmp;
>  			if (tmp->vm_start <= addr)
>  				break;
> +			if (!tmp->vm_prev || tmp->vm_prev->vm_end <= addr)
> +				break;
> +

This 'break' would return 'tmp' as found vma.

Have you even tried to test the code?

>  			rb_node = rb_node->rb_left;
>  		} else
>  			rb_node = rb_node->rb_right;
> -- 
> 1.9.1
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
