Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id 9CD976B0039
	for <linux-mm@kvack.org>; Tue, 29 Jan 2013 07:14:05 -0500 (EST)
Received: by mail-ob0-f171.google.com with SMTP id lz20so329673obb.2
        for <linux-mm@kvack.org>; Tue, 29 Jan 2013 04:14:04 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1359365068-10147-7-git-send-email-kirill.shutemov@linux.intel.com>
References: <1359365068-10147-1-git-send-email-kirill.shutemov@linux.intel.com>
	<1359365068-10147-7-git-send-email-kirill.shutemov@linux.intel.com>
Date: Tue, 29 Jan 2013 20:14:04 +0800
Message-ID: <CAJd=RBA2Kr-sKEFdJNQAjgVzesn6Q2Ockci58DsNQ0fa_7qkQw@mail.gmail.com>
Subject: Re: [PATCH, RFC 06/16] thp, mm: rewrite add_to_page_cache_locked() to
 support huge pages
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Jan 28, 2013 at 5:24 PM, Kirill A. Shutemov
<kirill.shutemov@linux.intel.com> wrote:
> +       page_cache_get(page);
> +       spin_lock_irq(&mapping->tree_lock);
> +       page->mapping = mapping;
> +       if (PageTransHuge(page)) {
> +               int i;
> +               for (i = 0; i < HPAGE_CACHE_NR; i++) {
> +                       page_cache_get(page + i);

Page count is raised twice for head page, why?

> +                       page[i].index = offset + i;
> +                       error = radix_tree_insert(&mapping->page_tree,
> +                                       offset + i, page + i);
> +                       if (error) {
> +                               page_cache_release(page + i);
> +                               break;
> +                       }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
