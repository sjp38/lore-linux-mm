Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 0BDF26B005D
	for <linux-mm@kvack.org>; Tue,  2 Oct 2012 18:55:13 -0400 (EDT)
Date: Wed, 3 Oct 2012 00:55:11 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH v3 00/10] Introduce huge zero page
Message-ID: <20121002225511.GS4763@redhat.com>
References: <1349191172-28855-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20121002153148.1ae1020a.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121002153148.1ae1020a.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, "H. Peter Anvin" <hpa@linux.intel.com>, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>

Hi Andrew,

On Tue, Oct 02, 2012 at 03:31:48PM -0700, Andrew Morton wrote:
> From reading the code, it appears that we initially allocate a huge
> page and point the pmd at that.  If/when there is a write fault against
> that page we then populate the mm with ptes which point at the normal
> 4k zero page and populate the pte at the fault address with a newly
> allocated page?   Correct and complete?  If not, please fix ;)

During the cow, we never use 4k ptes, unless the 2m page allocation
fails.

> Also, IIRC, the early versions of the patch did not allocate the
> initial huge page at all - it immediately filled the mm with ptes which
> point at the normal 4k zero page.  Is that a correct recollection?
> If so, why the change?

That was a different design yes. The design in this patchset will not
do that.

> Also IIRC, Andrea had a little test app which demonstrated the TLB
> costs of the inital approach, and they were high?

Yes we run the benchmarks yesterday, this version is the one that will
decrease the TLB cost and that seems the safest tradeoff.

> Please, let's capture all this knowledge in a single place, right here
> in the changelog.  And in code comments, where appropriate.  Otherwise
> people won't know why we made these decisions unless they go off and
> find lengthy, years-old and quite possibly obsolete email threads.

Agreed ;).

> Also, you've presented some data on the memory savings, but no
> quantitative testing results on the performance cost.  Both you and
> Andrea have run these tests and those results are important.  Let's
> capture them here.  And when designing such tests we should not just
> try to demonstrate the benefits of a code change - we should think of
> test cases whcih might be adversely affected and run those as well.

Right.

> It's not an appropriate time to be merging new features - please plan
> on preparing this patchset against 3.7-rc1.

Ok, I assume Kirill will take care of it.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
