Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f176.google.com (mail-we0-f176.google.com [74.125.82.176])
	by kanga.kvack.org (Postfix) with ESMTP id 7898A6B0105
	for <linux-mm@kvack.org>; Tue, 10 Jun 2014 18:05:02 -0400 (EDT)
Received: by mail-we0-f176.google.com with SMTP id u56so3622887wes.21
        for <linux-mm@kvack.org>; Tue, 10 Jun 2014 15:05:01 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id a10si18895363wiz.51.2014.06.10.15.05.00
        for <linux-mm@kvack.org>;
        Tue, 10 Jun 2014 15:05:01 -0700 (PDT)
Date: Wed, 11 Jun 2014 00:04:51 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH, RFC 00/10] THP refcounting redesign
Message-ID: <20140610220451.GG19660@redhat.com>
References: <1402329861-7037-1-git-send-email-kirill.shutemov@linux.intel.com>
 <alpine.DEB.2.10.1406101518510.19364@gentwo.org>
 <20140610204640.GA9594@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140610204640.GA9594@node.dhcp.inet.fi>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Christoph Lameter <cl@gentwo.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Jun 10, 2014 at 11:46:40PM +0300, Kirill A. Shutemov wrote:
> Agreed. The patchset drops tail page refcounting.

Very possibly I misread something or a later patch fixes this up, I
just did a basic code review, but from the new code of split_huge_page
it looks like it returns -EBUSY after checking the individual tail
page refcounts, so it's not clear how that defines as "dropped".

+       for (i = 0; i < HPAGE_PMD_NR; i++)
+               tail_count += page_mapcount(page + i);
+       if (tail_count != page_count(page) - 1) {
+               BUG_ON(tail_count > page_count(page) - 1);
+               compound_unlock(page);
+               spin_unlock_irq(&zone->lru_lock);
+               return -EBUSY;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
