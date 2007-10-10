Received: from zps35.corp.google.com (zps35.corp.google.com [172.25.146.35])
	by smtp-out.google.com with ESMTP id l9A7oEKT018478
	for <linux-mm@kvack.org>; Wed, 10 Oct 2007 00:50:14 -0700
Received: from rv-out-0910.google.com (rvbg11.prod.google.com [10.140.83.11])
	by zps35.corp.google.com with ESMTP id l9A7oD4j012507
	for <linux-mm@kvack.org>; Wed, 10 Oct 2007 00:50:14 -0700
Received: by rv-out-0910.google.com with SMTP id g11so99750rvb
        for <linux-mm@kvack.org>; Wed, 10 Oct 2007 00:50:13 -0700 (PDT)
Message-ID: <b040c32a0710100050x51498022m247acf34da7bc3de@mail.gmail.com>
Date: Wed, 10 Oct 2007 00:50:13 -0700
From: "Ken Chen" <kenchen@google.com>
Subject: Re: [rfc] more granular page table lock for hugepages
In-Reply-To: <b040c32a0710092310t22693865ue0b53acec85fae44@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20071008225234.GC27824@linux-os.sc.intel.com>
	 <b040c32a0710091323v7fab02b0vaab61f0ea12278d@mail.gmail.com>
	 <1191963958.12131.43.camel@dyn9047017100.beaverton.ibm.com>
	 <20071010001523.GA30676@linux-os.sc.intel.com>
	 <b040c32a0710092310t22693865ue0b53acec85fae44@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Siddha, Suresh B" <suresh.b.siddha@intel.com>
Cc: Badari Pulavarty <pbadari@gmail.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On 10/9/07, Ken Chen <kenchen@google.com> wrote:
> That's what I figures.  In that case, why don't we get rid of all spin
> lock in the fast path of follow_hugetlb_pages.
>
> follow_hugetlb_page is called from get_user_pages, which should
> already hold mm->mmap_sem in read mode.  That means page table tear
> down can not happen.  We do a racy read on page table chain.  If a
> race happened with another thread, no big deal, it will just fall into
> hugetlb_fault() which will then serialize with
> hugetlb_instantiation_mutex or mm->page_table_lock.  And that's slow
> path anyway.

never mind.  ftruncate can come through in another path removes
mapping without holding mm->mmap_sem.  So much for the crazy idea.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
