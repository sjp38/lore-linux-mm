Received: from peculier ([10.10.188.58]) (1548 bytes) by megami.veritas.com
    via sendmail with P:esmtp/R:smart_host/T:smtp
    (sender: <hugh@veritas.com>) id <m1BEyHr-0000iuC@megami.veritas.com> for
    <linux-mm@kvack.org>; Sat, 17 Apr 2004 15:27:47 -0700 (PDT)
    (Smail-3.2.0.101 1997-Dec-17 #15 built 2001-Aug-30)
Date: Sat, 17 Apr 2004 23:27:43 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: PTE aging, ptep_test_and_clear_young() and TLB
In-Reply-To: <20040417211506.C21974@flint.arm.linux.org.uk>
Message-ID: <Pine.LNX.4.44.0404172311120.2124-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Russell King <rmk@arm.linux.org.uk>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 17 Apr 2004, Russell King wrote:
> 
> So, it seems to me that maintaining the PTE age state is far more
> important, and a lazy approach is no longer possible.
> 
> This in turn means that we need to replace ptep_test_and_clear_young()
> with ptep_clear_flush_young(), which in turn means we need the VMA and
> address.  However, this implies introducing more code into
> page_referenced().
> 
> Comments?

I think you're quite likely right on all counts; and this may be why
ppc and ppc64 have arranged their ptep_test_and_clear_young to flush TLB.

But I don't much like the thought of flushing TLB on all cpus each time
page_referenced finds the referenced bit set in a pte, perhaps many times
even for the one page.  We'd prefer page_referenced to remain lightweight
in contrast to try_to_unmap.  Need to do some kind of gathering before
TLB flush.

(Andrea will know one reason why I'm afraid of vmas in page_referenced ;)

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
