Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7DE3F6B0033
	for <linux-mm@kvack.org>; Fri, 19 Jan 2018 13:01:56 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id e186so2615527iof.9
        for <linux-mm@kvack.org>; Fri, 19 Jan 2018 10:01:56 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id h62sor4858809iod.291.2018.01.19.10.01.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 19 Jan 2018 10:01:55 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180119124924.25642-1-kirill.shutemov@linux.intel.com>
References: <20180119124924.25642-1-kirill.shutemov@linux.intel.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 19 Jan 2018 10:01:54 -0800
Message-ID: <CA+55aFxobYQ5cqnCZuf8xVWr3hCUmg=rTxDPV3zHWqeQysVkxA@mail.gmail.com>
Subject: Re: [PATCHv2] mm, page_vma_mapped: Drop faulty pointer arithmetics in check_pte()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, stable <stable@vger.kernel.org>

On Fri, Jan 19, 2018 at 4:49 AM, Kirill A. Shutemov
<kirill.shutemov@linux.intel.com> wrote:
>
> +       if (pfn < page_to_pfn(pvmw->page))
> +               return false;
> +
> +       /* THP can be referenced by any subpage */
> +       if (pfn - page_to_pfn(pvmw->page) >= hpage_nr_pages(pvmw->page))
> +               return false;
> +

Is gcc actually clever enough to merge these? The "page_to_pfn()"
logic can be pretty expensive (exactly for the sparsemem case, but
per-node DISCOTIGMEM has some complexity too.

So I'd prefer to make that explicit, perhaps by having a helper
function that does this something like

   static inline bool pfn_in_hpage(unsigned long pfn, struct page *hpage)
   {
        unsigned long hpage_pfn = page_to_pfn(hpage);

        return pfn >= hpage_pfn &&  pfn - hpage_pfn < hpage_nr_pages(hpage);
    }

and then just use

    return pfn_in_hpage(pfn, pvmw->page);

in that caller. Hmm? Wouldn't that be more legible, and avoid the
repeated pvmw->page and page_to_pfn() cases?

Even if maybe gcc can do the CSE and turn it all into the same thing
in the end..

               Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
