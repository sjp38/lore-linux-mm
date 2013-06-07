Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id B0CEB6B0031
	for <linux-mm@kvack.org>; Fri,  7 Jun 2013 11:29:21 -0400 (EDT)
Message-ID: <51B1FC4F.2020700@sr71.net>
Date: Fri, 07 Jun 2013 08:29:19 -0700
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [PATCHv4 20/39] thp, mm: naive support of thp in generic read/write
 routines
References: <1368321816-17719-1-git-send-email-kirill.shutemov@linux.intel.com> <1368321816-17719-21-git-send-email-kirill.shutemov@linux.intel.com> <519BE6ED.8030202@sr71.net> <20130607151718.E126AE0090@blue.fi.intel.com>
In-Reply-To: <20130607151718.E126AE0090@blue.fi.intel.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On 06/07/2013 08:17 AM, Kirill A. Shutemov wrote:
<snip>
> I guess this way is better, right?
> 
> @@ -2382,6 +2393,7 @@ static ssize_t generic_perform_write(struct file *file,
>                 unsigned long bytes;    /* Bytes to write to page */
>                 size_t copied;          /* Bytes copied from user */
>                 void *fsdata;
> +               int subpage_nr = 0;
>  
>                 offset = (pos & (PAGE_CACHE_SIZE - 1));
>                 bytes = min_t(unsigned long, PAGE_CACHE_SIZE - offset,
> @@ -2411,8 +2423,14 @@ again:
>                 if (mapping_writably_mapped(mapping))
>                         flush_dcache_page(page);
>  
> +               if (PageTransHuge(page)) {
> +                       off_t huge_offset = pos & ~HPAGE_PMD_MASK;
> +                       subpage_nr = huge_offset >> PAGE_CACHE_SHIFT;
> +               }
> +
>                 pagefault_disable();
> -               copied = iov_iter_copy_from_user_atomic(page, i, offset, bytes);
> +               copied = iov_iter_copy_from_user_atomic(page + subpage_nr, i,
> +                               offset, bytes);
>                 pagefault_enable();
>                 flush_dcache_page(page);

That looks substantially easier to understand to me.  Nice.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
