Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id DED506B010E
	for <linux-mm@kvack.org>; Tue, 10 Jun 2014 16:46:57 -0400 (EDT)
Received: by mail-wi0-f175.google.com with SMTP id f8so6851063wiw.14
        for <linux-mm@kvack.org>; Tue, 10 Jun 2014 13:46:57 -0700 (PDT)
Received: from kirsi1.inet.fi (mta-out1.inet.fi. [62.71.2.198])
        by mx.google.com with ESMTP id w13si18652547wiv.49.2014.06.10.13.46.55
        for <linux-mm@kvack.org>;
        Tue, 10 Jun 2014 13:46:56 -0700 (PDT)
Date: Tue, 10 Jun 2014 23:46:40 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH, RFC 00/10] THP refcounting redesign
Message-ID: <20140610204640.GA9594@node.dhcp.inet.fi>
References: <1402329861-7037-1-git-send-email-kirill.shutemov@linux.intel.com>
 <alpine.DEB.2.10.1406101518510.19364@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1406101518510.19364@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@gentwo.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Jun 10, 2014 at 03:25:42PM -0500, Christoph Lameter wrote:
> On Mon, 9 Jun 2014, Kirill A. Shutemov wrote:
> 
> > To be able to split huge page at any point we have to track which tail
> > page was pinned. It leads to tricky and expensive get_page() on tail pages
> > and also occupy tail_page->_mapcount.
> 
> Maybe we should give up the requirement to be able to split a huge page at
> any point?

Yes, that's what the patchset does: we don't allow to split the page if
any sub-page is pinned.

> This got us into the mess AFAICT. Instead we could use the locking
> mechanisms that we have to stop all access to the page and then do the
> conversion?

I end up with compound_lock to freeze page count. Not sure if it's the
best option we have

> Page migration can do that so it should be fine with refcounting for
> huge pages exclusively in the head page exactly like a regular page.

We've discussed "split via migration" with Dave. I need to look more on
how migration works.

> The problem is then dealing with the locations where we now do rely on
> the ability to split at "any point" (notion is weird in itself and
> suggests issues with synchronization).

As I said, we have only 4 places where we need to split the page (not only
PMD): swap out, memory failure, KSM, migration. All of them can tolerate
split failure.

> Use the standard locking schemes for pages instead?

Could you elaborate here?

> I thought the idea was that we would modify the relevant code and
> that at some point this requirement could go away?
> 
> Huge pages (and other larger order pages) will become increasingly
> difficult to handle if relevant page state has to be maintained in tail
> pages and if it differs significantly from regular pages.

Agreed. The patchset drops tail page refcounting.
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
