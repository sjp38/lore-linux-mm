Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 547F96B006E
	for <linux-mm@kvack.org>; Mon,  1 Oct 2012 12:31:26 -0400 (EDT)
Date: Mon, 1 Oct 2012 18:31:18 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 0/3] Virtual huge zero page
Message-ID: <20121001163118.GC18051@redhat.com>
References: <1348875441-19561-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20120929134811.GC26989@redhat.com>
 <5069B804.6040902@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5069B804.6040902@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@linux.intel.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>, Arnd Bergmann <arnd@arndb.de>, Ingo Molnar <mingo@kernel.org>, linux-arch@vger.kernel.org

On Mon, Oct 01, 2012 at 08:34:28AM -0700, H. Peter Anvin wrote:
> On 09/29/2012 06:48 AM, Andrea Arcangeli wrote:
> > 
> > There would be a small cache benefit here... but even then some first
> > level caches are virtually indexed IIRC (always physically tagged to
> > avoid the software to notice) and virtually indexed ones won't get any
> > benefit.
> > 
> 
> Not quite.  The virtual indexing is limited to a few bits (e.g. three
> bits on K8); the right way to deal with that is to color the zeropage,
> both the regular one and the virtual one (the virtual one would circle
> through all the colors repeatedly.)
> 
> The cache difference, therefore, is *huge*.

Kirill measured the cache benefit and it provided a 6% gain, not very
huge but certainly significant.

> It's a performance tradeoff, and it can, and should, be measured.

I now measured the other side of the trade, by touching only one
character every 4k page in the range to simulate a very seeking load,
and doing so the physical huge zero page wins with a 600% margin, so
if the cache benefit is huge for the virtual zero page, the TLB
benefit is massive for the physical zero page.

Overall I think picking the solution that risks to regress the least
(also compared to current status of no zero page) is the safest.

Thanks!
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
