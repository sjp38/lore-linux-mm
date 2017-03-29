Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 786BD6B0390
	for <linux-mm@kvack.org>; Wed, 29 Mar 2017 07:06:39 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id l95so2130093wrc.12
        for <linux-mm@kvack.org>; Wed, 29 Mar 2017 04:06:39 -0700 (PDT)
Received: from mail-wr0-x22c.google.com (mail-wr0-x22c.google.com. [2a00:1450:400c:c0c::22c])
        by mx.google.com with ESMTPS id e16si6782587wmd.4.2017.03.29.04.06.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Mar 2017 04:06:37 -0700 (PDT)
Received: by mail-wr0-x22c.google.com with SMTP id w43so10066479wrb.0
        for <linux-mm@kvack.org>; Wed, 29 Mar 2017 04:06:37 -0700 (PDT)
Date: Wed, 29 Mar 2017 14:06:35 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: Consolidate calls to unmap_mapping_range in collapse_shmem
Message-ID: <20170329110635.fqgspc7sr5pgqohr@node.shutemov.name>
References: <20170329021503.GA7760@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170329021503.GA7760@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org

On Tue, Mar 28, 2017 at 07:15:03PM -0700, Matthew Wilcox wrote:
> 
> Is there a reason we call unmap_mapping_range() for a single page at a
> time instead of the entire hugepage?  This is surely more efficient ...
> but does it do something like increase the refcount on the page?

Yes, mapcount holds refcount on the page. So page_ref_freeze() will fail
with proposed change.

> I suppose we might be able to skip all the calls to unmap_mapping_range()
> if none of the pages are mapped, but surely anonymous pages are usually
> mapped?

The valid optimization I *think* would be to call unmap_mapping_range()
for whole huge page range before iterating over individual pages. This way
we would only hit page_mapped() case if there was race with page fault.

P.S. proper To/Cc would helped me to notice it. :)

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
