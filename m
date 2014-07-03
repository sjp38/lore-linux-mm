Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f181.google.com (mail-we0-f181.google.com [74.125.82.181])
	by kanga.kvack.org (Postfix) with ESMTP id 499B86B0035
	for <linux-mm@kvack.org>; Thu,  3 Jul 2014 07:42:06 -0400 (EDT)
Received: by mail-we0-f181.google.com with SMTP id q59so92630wes.26
        for <linux-mm@kvack.org>; Thu, 03 Jul 2014 04:42:05 -0700 (PDT)
Received: from kirsi1.inet.fi (mta-out1.inet.fi. [62.71.2.200])
        by mx.google.com with ESMTP id gh11si23694099wic.86.2014.07.03.04.41.56
        for <linux-mm@kvack.org>;
        Thu, 03 Jul 2014 04:41:56 -0700 (PDT)
Date: Thu, 3 Jul 2014 14:41:00 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] rmap: fix pgoff calculation to handle hugepage correctly
Message-ID: <20140703114100.GA27140@node.dhcp.inet.fi>
References: <1404225982-22739-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20140701180739.GA4985@node.dhcp.inet.fi>
 <20140701185021.GA10356@nhori.bos.redhat.com>
 <20140701201540.GA5953@node.dhcp.inet.fi>
 <20140702043057.GA19813@nhori.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140702043057.GA19813@nhori.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Hillf Danton <dhillf@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Wed, Jul 02, 2014 at 12:30:57AM -0400, Naoya Horiguchi wrote:
> On Tue, Jul 01, 2014 at 11:15:40PM +0300, Kirill A. Shutemov wrote:
> > On Tue, Jul 01, 2014 at 02:50:21PM -0400, Naoya Horiguchi wrote:
> > > On Tue, Jul 01, 2014 at 09:07:39PM +0300, Kirill A. Shutemov wrote:
> > > > Why do we need this special case for hugetlb page ->index? Why not use
> > > > PAGE_SIZE units there too? Or I miss something?
> > > 
> > > hugetlb pages are never split, so we use larger page cache size for
> > > hugetlbfs file (to avoid large sparse page cache tree.)
> > 
> > For transparent huge page cache I would like to have native support in
> > page cache radix-tree: since huge pages are always naturally aligned we
> > can create a leaf node for it several (RADIX_TREE_MAP_SHIFT -
> > HPAGE_PMD_ORDER) levels up by tree, which would cover all indexes in the
> > range the huge page represents. This approach should fit hugetlb too. And
> > -1 special case for hugetlb.
> > But I'm not sure when I'll get time to play with this...
> 
> So I'm OK that hugetlb page should have ->index in PAGE_CACHE_SIZE
> when transparent huge page is merged. I may try to write patches
> on top of your tree after I've done a few series in my work queue.
> 
> In order to fix the current problem, I suggest a page_to_pgoff() as a
> short-term workaround. I found a few other call sites which can call
> on hugepage, so this function help us track such callers.
> The similar function seems to be introduced in your transparent huge
> page cache tree (page_cache_index()). So this function will be finally
> overwritten with it.
> 
> Thanks,
> Naoya Horiguchi
> ---
> From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Date: Tue, 1 Jul 2014 21:38:22 -0400
> Subject: [PATCH v2] rmap: fix pgoff calculation to handle hugepage correctly
> 
> I triggered VM_BUG_ON() in vma_address() when I try to migrate an anonymous
> hugepage with mbind() in the kernel v3.16-rc3. This is because pgoff's
> calculation in rmap_walk_anon() fails to consider compound_order() only to
> have an incorrect value.
> 
> This patch introduces page_to_pgoff(), which gets the page's offset in
> PAGE_CACHE_SIZE. Kirill pointed out that page cache tree should natively
> handle hugepages, and in order to make hugetlbfs fit it, page->index of
> hugetlbfs page should be in PAGE_CACHE_SIZE. This is beyond this patch,
> but page_to_pgoff() contains the point to be fixed in a single function.
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
