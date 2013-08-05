Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 1CAC16B0034
	for <linux-mm@kvack.org>; Mon,  5 Aug 2013 05:58:18 -0400 (EDT)
Received: by mail-bk0-f41.google.com with SMTP id jc10so895880bkc.14
        for <linux-mm@kvack.org>; Mon, 05 Aug 2013 02:58:16 -0700 (PDT)
Date: Mon, 5 Aug 2013 11:58:12 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [RFC v2 0/5] Transparent on-demand struct page initialization
 embedded in the buddy allocator
Message-ID: <20130805095812.GA29404@gmail.com>
References: <1373594635-131067-1-git-send-email-holt@sgi.com>
 <1375465467-40488-1-git-send-email-nzimmer@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1375465467-40488-1-git-send-email-nzimmer@sgi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nathan Zimmer <nzimmer@sgi.com>
Cc: hpa@zytor.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, holt@sgi.com, rob@landley.net, travis@sgi.com, daniel@numascale-asia.com, akpm@linux-foundation.org, gregkh@linuxfoundation.org, yinghai@kernel.org, mgorman@suse.de


* Nathan Zimmer <nzimmer@sgi.com> wrote:

> We are still restricting ourselves ourselves to 2MiB initialization to 
> keep the patch set a little smaller and more clear.
> 
> We are still struggling with the expand().  Nearly always the first 
> reference to a struct page which is in the middle of the 2MiB region.  
> We were unable to find a good solution.  Also, given the strong warning 
> at the head of expand(), we did not feel experienced enough to refactor 
> it to make things always reference the 2MiB page first. The only other 
> fastpath impact left is the expansion in prep_new_page.

I suppose it's about this chunk:

@@ -860,6 +917,7 @@ static inline void expand(struct zone *zone, struct page *page,
                area--;
                high--;
                size >>= 1;
+               ensure_page_is_initialized(page);
                VM_BUG_ON(bad_range(zone, &page[size]));

where ensure_page_is_initialized() does, in essence:

+       while (aligned_start_pfn < aligned_end_pfn) {
+               if (pfn_valid(aligned_start_pfn)) {
+                       page = pfn_to_page(aligned_start_pfn);
+
+                       if (PageUninitialized2m(page))
+                               expand_page_initialization(page);
+               }
+
+               aligned_start_pfn += PTRS_PER_PMD;
+       }

where aligned_start_pfn is 2MB rounded down.

which looks like an expensive loop to execute for a single page: there are 
512 pages in a 2MB range, so on average this iterates 256 times, for every 
single page of allocation. Right?

I might be missing something, but why not just represent the 
initialization state in 2MB chunks: it is either fully uninitialized, or 
fully initialized. If any page in the 'middle' gets allocated, all page 
heads have to get initialized.

That should make the fast path test fairly cheap, basically just 
PageUninitialized2m(page) has to be tested - and that will fail in the 
post-initialization fastpath.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
