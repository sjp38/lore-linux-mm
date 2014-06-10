Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f181.google.com (mail-we0-f181.google.com [74.125.82.181])
	by kanga.kvack.org (Postfix) with ESMTP id 625BA6B010B
	for <linux-mm@kvack.org>; Tue, 10 Jun 2014 18:14:40 -0400 (EDT)
Received: by mail-we0-f181.google.com with SMTP id q59so2949396wes.12
        for <linux-mm@kvack.org>; Tue, 10 Jun 2014 15:14:39 -0700 (PDT)
Received: from kirsi1.inet.fi (mta-out1.inet.fi. [62.71.2.199])
        by mx.google.com with ESMTP id da1si18913342wib.71.2014.06.10.15.14.38
        for <linux-mm@kvack.org>;
        Tue, 10 Jun 2014 15:14:39 -0700 (PDT)
Date: Wed, 11 Jun 2014 01:14:31 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH, RFC 00/10] THP refcounting redesign
Message-ID: <20140610221431.GA10634@node.dhcp.inet.fi>
References: <1402329861-7037-1-git-send-email-kirill.shutemov@linux.intel.com>
 <alpine.DEB.2.10.1406101518510.19364@gentwo.org>
 <20140610204640.GA9594@node.dhcp.inet.fi>
 <20140610220451.GG19660@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140610220451.GG19660@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Christoph Lameter <cl@gentwo.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Jun 11, 2014 at 12:04:51AM +0200, Andrea Arcangeli wrote:
> On Tue, Jun 10, 2014 at 11:46:40PM +0300, Kirill A. Shutemov wrote:
> > Agreed. The patchset drops tail page refcounting.
> 
> Very possibly I misread something or a later patch fixes this up, I
> just did a basic code review, but from the new code of split_huge_page
> it looks like it returns -EBUSY after checking the individual tail
> page refcounts, so it's not clear how that defines as "dropped".

page_mapcount() here is really mapcount: how many times the page is
mapped, not pins on tail pages as we have it now.

> 
> +       for (i = 0; i < HPAGE_PMD_NR; i++)
> +               tail_count += page_mapcount(page + i);
> +       if (tail_count != page_count(page) - 1) {
> +               BUG_ON(tail_count > page_count(page) - 1);
> +               compound_unlock(page);
> +               spin_unlock_irq(&zone->lru_lock);
> +               return -EBUSY;
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
