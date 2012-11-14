Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 44B896B0089
	for <linux-mm@kvack.org>; Wed, 14 Nov 2012 18:40:39 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id fa10so720876pad.14
        for <linux-mm@kvack.org>; Wed, 14 Nov 2012 15:40:38 -0800 (PST)
Date: Wed, 14 Nov 2012 15:40:37 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v5 10/11] thp: implement refcounting for huge zero page
In-Reply-To: <1352300463-12627-11-git-send-email-kirill.shutemov@linux.intel.com>
Message-ID: <alpine.DEB.2.00.1211141538450.22537@chino.kir.corp.google.com>
References: <1352300463-12627-1-git-send-email-kirill.shutemov@linux.intel.com> <1352300463-12627-11-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, "H. Peter Anvin" <hpa@linux.intel.com>, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>

On Wed, 7 Nov 2012, Kirill A. Shutemov wrote:

> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> 
> H. Peter Anvin doesn't like huge zero page which sticks in memory forever
> after the first allocation. Here's implementation of lockless refcounting
> for huge zero page.
> 
> We have two basic primitives: {get,put}_huge_zero_page(). They
> manipulate reference counter.
> 
> If counter is 0, get_huge_zero_page() allocates a new huge page and
> takes two references: one for caller and one for shrinker. We free the
> page only in shrinker callback if counter is 1 (only shrinker has the
> reference).
> 
> put_huge_zero_page() only decrements counter. Counter is never zero
> in put_huge_zero_page() since shrinker holds on reference.
> 
> Freeing huge zero page in shrinker callback helps to avoid frequent
> allocate-free.
> 
> Refcounting has cost. On 4 socket machine I observe ~1% slowdown on
> parallel (40 processes) read page faulting comparing to lazy huge page
> allocation.  I think it's pretty reasonable for synthetic benchmark.
> 

Eek, this is disappointing that we need to check a refcount before 
referencing the zero huge page and it obviously shows in your benchmark 
(which I consider 1% to be significant given the alternative is 2MB of 
memory for a system where thp was enabled to be on).  I think it would be 
much better to simply allocate and reference the zero huge page locklessly 
when thp is enabled to be either "madvise" or "always", i.e. allocate it 
when enabled.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
