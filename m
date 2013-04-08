Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 758916B003D
	for <linux-mm@kvack.org>; Mon,  8 Apr 2013 15:38:40 -0400 (EDT)
Message-ID: <51631CC0.5010908@sr71.net>
Date: Mon, 08 Apr 2013 12:38:40 -0700
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [PATCHv3, RFC 09/34] thp: represent file thp pages in meminfo
 and friends
References: <1365163198-29726-1-git-send-email-kirill.shutemov@linux.intel.com> <1365163198-29726-10-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1365163198-29726-10-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On 04/05/2013 04:59 AM, Kirill A. Shutemov wrote:
> The patch adds new zone stat to count file transparent huge pages and
> adjust related places.
> 
> For now we don't count mapped or dirty file thp pages separately.

I can understand tracking NR_FILE_TRANSPARENT_HUGEPAGES itself.  But,
why not also account for them in NR_FILE_PAGES?  That way, you don't
have to special-case each of the cases below:

> --- a/fs/proc/meminfo.c
> +++ b/fs/proc/meminfo.c
> @@ -41,6 +41,9 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
>  
>  	cached = global_page_state(NR_FILE_PAGES) -
>  			total_swapcache_pages() - i.bufferram;
> +	if (IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE))
> +		cached += global_page_state(NR_FILE_TRANSPARENT_HUGEPAGES) *
> +			HPAGE_PMD_NR;
>  	if (cached < 0)
>  		cached = 0;
....
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -135,6 +135,9 @@ int __vm_enough_memory(struct mm_struct *mm, long pages, int cap_sys_admin)
>  	if (sysctl_overcommit_memory == OVERCOMMIT_GUESS) {
>  		free = global_page_state(NR_FREE_PAGES);
>  		free += global_page_state(NR_FILE_PAGES);
> +		if (IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE))
> +			free += global_page_state(NR_FILE_TRANSPARENT_HUGEPAGES)
> +				* HPAGE_PMD_NR;
...
> -	printk("%ld total pagecache pages\n", global_page_state(NR_FILE_PAGES));
> +	cached = global_page_state(NR_FILE_PAGES);
> +	if (IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE))
> +		cached += global_page_state(NR_FILE_TRANSPARENT_HUGEPAGES) *
> +			HPAGE_PMD_NR;
> +	printk("%ld total pagecache pages\n", cached);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
