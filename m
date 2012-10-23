Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 927FD6B0071
	for <linux-mm@kvack.org>; Tue, 23 Oct 2012 02:34:18 -0400 (EDT)
Date: Tue, 23 Oct 2012 09:35:32 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v4 10/10] thp: implement refcounting for huge zero page
Message-ID: <20121023063532.GA15870@shutemov.name>
References: <1350280859-18801-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1350280859-18801-11-git-send-email-kirill.shutemov@linux.intel.com>
 <20121018164502.b32791e7.akpm@linux-foundation.org>
 <20121018235941.GA32397@shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121018235941.GA32397@shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, "H. Peter Anvin" <hpa@linux.intel.com>, linux-kernel@vger.kernel.org

On Fri, Oct 19, 2012 at 02:59:41AM +0300, Kirill A. Shutemov wrote:
> On Thu, Oct 18, 2012 at 04:45:02PM -0700, Andrew Morton wrote:
> > On Mon, 15 Oct 2012 09:00:59 +0300
> > "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:
> > 
> > > H. Peter Anvin doesn't like huge zero page which sticks in memory forever
> > > after the first allocation. Here's implementation of lockless refcounting
> > > for huge zero page.
> > > 
> > > We have two basic primitives: {get,put}_huge_zero_page(). They
> > > manipulate reference counter.
> > > 
> > > If counter is 0, get_huge_zero_page() allocates a new huge page and
> > > takes two references: one for caller and one for shrinker. We free the
> > > page only in shrinker callback if counter is 1 (only shrinker has the
> > > reference).
> > > 
> > > put_huge_zero_page() only decrements counter. Counter is never zero
> > > in put_huge_zero_page() since shrinker holds on reference.
> > > 
> > > Freeing huge zero page in shrinker callback helps to avoid frequent
> > > allocate-free.
> > 
> > I'd like more details on this please.  The cost of freeing then
> > reinstantiating that page is tremendous, because it has to be zeroed
> > out again.  If there is any way at all in which the kernel can be made
> > to enter a high-frequency free/reinstantiate pattern then I expect the
> > effects would be quite bad.
> > 
> > Do we have sufficient mechanisms in there to prevent this from
> > happening in all cases?  If so, what are they, because I'm not seeing
> > them?
> 
> We only free huge zero page in shrinker callback if nobody in the system
> uses it. Never on put_huge_zero_page(). Shrinker runs only under memory
> pressure or if user asks (drop_caches).
> Do you think we need an additional protection mechanism?

Andrew?

> > > Refcounting has cost. On 4 socket machine I observe ~1% slowdown on
> > > parallel (40 processes) read page faulting comparing to lazy huge page
> > > allocation.  I think it's pretty reasonable for synthetic benchmark.
> 
> -- 
>  Kirill A. Shutemov

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
