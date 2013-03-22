Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id 806B16B0044
	for <linux-mm@kvack.org>; Fri, 22 Mar 2013 14:28:15 -0400 (EDT)
Message-ID: <514CA4EA.9030206@sr71.net>
Date: Fri, 22 Mar 2013 11:37:30 -0700
From: Dave <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [PATCHv2, RFC 21/30] x86-64, mm: proper alignment mappings with
 hugepages
References: <1363283435-7666-1-git-send-email-kirill.shutemov@linux.intel.com> <1363283435-7666-22-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1363283435-7666-22-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On 03/14/2013 10:50 AM, Kirill A. Shutemov wrote:
> +	if (filp)
> +		info.align_mask = mapping_can_have_hugepages(filp->f_mapping) ?
> +			PAGE_MASK & ~HPAGE_MASK : get_align_mask();
> +	else
> +		info.align_mask = 0;
>  	info.align_offset = pgoff << PAGE_SHIFT;
>  	return vm_unmapped_area(&info);
>  }
> @@ -174,7 +179,11 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
>  	info.length = len;
>  	info.low_limit = PAGE_SIZE;
>  	info.high_limit = mm->mmap_base;
> -	info.align_mask = filp ? get_align_mask() : 0;
> +	if (filp)
> +		info.align_mask = mapping_can_have_hugepages(filp->f_mapping) ?
> +			PAGE_MASK & ~HPAGE_MASK : get_align_mask();
> +	else
> +		info.align_mask = 0;
>  	info.align_offset = pgoff << PAGE_SHIFT;
>  	addr = vm_unmapped_area(&info);
>  	if (!(addr & ~PAGE_MASK))

how about

static inline
unsigned long mapping_align_mask(struct address_space *mapping)
{
	if (mapping_can_have_hugepages(filp->f_mapping))
		return PAGE_MASK & ~HPAGE_MASK;
	return get_align_mask();
}

to replace these two open-coded versions?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
