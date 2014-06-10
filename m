Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f54.google.com (mail-qa0-f54.google.com [209.85.216.54])
	by kanga.kvack.org (Postfix) with ESMTP id E63526B010C
	for <linux-mm@kvack.org>; Tue, 10 Jun 2014 16:25:46 -0400 (EDT)
Received: by mail-qa0-f54.google.com with SMTP id v10so89027qac.13
        for <linux-mm@kvack.org>; Tue, 10 Jun 2014 13:25:46 -0700 (PDT)
Received: from qmta15.emeryville.ca.mail.comcast.net (qmta15.emeryville.ca.mail.comcast.net. [2001:558:fe2d:44:76:96:27:228])
        by mx.google.com with ESMTP id e10si27929353qcd.14.2014.06.10.13.25.45
        for <linux-mm@kvack.org>;
        Tue, 10 Jun 2014 13:25:46 -0700 (PDT)
Date: Tue, 10 Jun 2014 15:25:42 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [PATCH, RFC 00/10] THP refcounting redesign
In-Reply-To: <1402329861-7037-1-git-send-email-kirill.shutemov@linux.intel.com>
Message-ID: <alpine.DEB.2.10.1406101518510.19364@gentwo.org>
References: <1402329861-7037-1-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 9 Jun 2014, Kirill A. Shutemov wrote:

> To be able to split huge page at any point we have to track which tail
> page was pinned. It leads to tricky and expensive get_page() on tail pages
> and also occupy tail_page->_mapcount.

Maybe we should give up the requirement to be able to split a huge page at
any point? This got us into the mess AFAICT. Instead we could use the
locking mechanisms that we have to stop all access to the page and then do
the conversion? Page migration can do that so it should be fine with
refcounting for huge pages exclusively in the head page exactly like a
regular page.

The problem is then dealing with the locations where we now do rely on
the ability to split at "any point" (notion is weird in itself and
suggests issues with synchronization). Use the standard locking schemes
for pages instead?

I thought the idea was that we would modify the relevant code and
that at some point this requirement could go away?

Huge pages (and other larger order pages) will become increasingly
difficult to handle if relevant page state has to be maintained in tail
pages and if it differs significantly from regular pages.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
