Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 15B356B0034
	for <linux-mm@kvack.org>; Mon, 15 Jul 2013 09:53:02 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <1373885274-25249-5-git-send-email-kirill.shutemov@linux.intel.com>
References: <1373885274-25249-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1373885274-25249-5-git-send-email-kirill.shutemov@linux.intel.com>
Subject: RE: [PATCH 4/8] mm: cleanup add_to_page_cache_locked()
Content-Transfer-Encoding: 7bit
Message-Id: <20130715135547.22A94E0090@blue.fi.intel.com>
Date: Mon, 15 Jul 2013 16:55:47 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Kirill A. Shutemov wrote:
> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> 
> The patch makes add_to_page_cache_locked() cleaner:
>  - unindent most code of the function by inverting one condition;
>  - streamline code no-error path;
>  - move insert error path outside normal code path;
>  - call radix_tree_preload_end() earlier;
> 
> No functional changes.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Acked-by: Dave Hansen <dave.hansen@linux.intel.com>
> ---

...

> +	spin_lock_irq(&mapping->tree_lock);
> +	error = radix_tree_insert(&mapping->page_tree, offset, page);
> +	radix_tree_preload_end();
> +	if (unlikely(!error))
> +		goto err_insert;

Nadav Shemer noticed mistake here. It should be 'if (unlikely(error))'.

I've missed this during becase it was fixed by other patch in my
thp-pagecache series.

Fixed patch is below. Retested with this patchset applied only.
Looks okay now.

Sorry for this.

---
