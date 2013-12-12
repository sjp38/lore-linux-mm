Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f77.google.com (mail-oa0-f77.google.com [209.85.219.77])
	by kanga.kvack.org (Postfix) with ESMTP id C5B8E6B0031
	for <linux-mm@kvack.org>; Fri, 13 Dec 2013 09:56:35 -0500 (EST)
Received: by mail-oa0-f77.google.com with SMTP id o6so35172oag.8
        for <linux-mm@kvack.org>; Fri, 13 Dec 2013 06:56:35 -0800 (PST)
Received: from blackbird.sr71.net ([2001:19d0:2:6:209:6bff:fe9a:902])
        by mx.google.com with ESMTP id j69si22614650yhb.296.2013.12.12.11.29.35
        for <linux-mm@kvack.org>;
        Thu, 12 Dec 2013 11:29:36 -0800 (PST)
Message-ID: <52AA0E5D.30903@sr71.net>
Date: Thu, 12 Dec 2013 11:28:29 -0800
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [PATCH] [RFC] mm: slab: separate slab_page from 'struct page'
References: <20131210204641.3CB515AE@viggo.jf.intel.com> <00000142de5634af-f92870a7-efe2-45cd-b50d-a6fbdf3b353c-000000@email.amazonses.com> <52A78B55.8050500@sr71.net> <00000142de866123-cf1406b5-b7a3-4688-b46f-80e338a622a1-000000@email.amazonses.com> <52A793D0.4020306@sr71.net> <00000142e7e23135-20f346b1-a880-47b0-946c-122323669ec1-000000@email.amazonses.com>
In-Reply-To: <00000142e7e23135-20f346b1-a880-47b0-946c-122323669ec1-000000@email.amazonses.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kirill.shutemov@linux.intel.com, Andi Kleen <ak@linux.intel.com>

On 12/12/2013 09:37 AM, Christoph Lameter wrote:
> On Tue, 10 Dec 2013, Dave Hansen wrote:
>> See? *EVERYTHING* is overridden by at least one of the sl?b allocators
>> except ->flags.  In other words, there *ARE* no relationships when it
>> comes to the sl?bs, except for page->flags.
> 
> Slab objects can be used for I/O and then the page fields become
> important.

OK, which fields?  How are they important?  Looking at 'struct page', I
don't see any fields other than ->flags that the slab allocators leave
alone.

I do see some refcounting (page->_count) done on
request_queue->dma_drain_buffer which is kmalloc()'d.  Although, I'm a
bit skeptical that this is correct or has been audited because the slabs
do seem to write over this storage.  Anything needing to do per-page
could probably be converted over to a raw alloc_pages() anyway because
it couldn't possibly be doing sub-page-size allocations.

What other cases were you thinking of?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
