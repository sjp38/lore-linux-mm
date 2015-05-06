Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 919BD6B0038
	for <linux-mm@kvack.org>; Wed,  6 May 2015 08:50:05 -0400 (EDT)
Received: by wief7 with SMTP id f7so124652453wie.0
        for <linux-mm@kvack.org>; Wed, 06 May 2015 05:50:05 -0700 (PDT)
Received: from jenni2.inet.fi (mta-out1.inet.fi. [62.71.2.203])
        by mx.google.com with ESMTP id 18si10520431wju.82.2015.05.06.05.50.03
        for <linux-mm@kvack.org>;
        Wed, 06 May 2015 05:50:04 -0700 (PDT)
Date: Wed, 6 May 2015 15:50:00 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: TLB flushes on s390
Message-ID: <20150506125000.GB17739@node.dhcp.inet.fi>
References: <20150506112939.GA17739@node.dhcp.inet.fi>
 <20150506140002.6f9e4e5d@mschwide>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150506140002.6f9e4e5d@mschwide>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>, linux-mm@kvack.org

On Wed, May 06, 2015 at 02:00:02PM +0200, Martin Schwidefsky wrote:
> On Wed, 6 May 2015 14:29:39 +0300
> "Kirill A. Shutemov" <kirill@shutemov.name> wrote:
> 
> > I'm looking though s390 code around page table handling and I found that
> > in many places s390 does tlb flush before changing page table entry.
> 
> Uhh, have fun with that.. it is complicated :-/
>  
> > Let's look for instance on pmdp_clear_flush() implementation on s390.
> > It's implemented with pmdp_get_and_clear() which does pmdp_flush_direct()
> > *before* pmd_clear(). That's invert order comparing to generic
> > pmdp_flush_direct().
> > 
> > The question is what prevents tlb from being re-fill between flushing tlb
> > and clearing page table entry?
>  
> Look again at pmdp_flush_direct(), either __pmdp_idte_local or __pmdp_idte is
> called. Both functions use the IDTE instruction but in two different flavors.
> The mnemonic IDTE stands for invalidate-dat-table-entry, the instruction sets
> the invalid bit in the PMD and flushes all TLB entries on all CPUs that are
> affected by the now invalid PMD. The pmd_clear after the pmdp_flush_direct is
> done to set all the other bits of the PMD to the "empty" state. The invalid
> bit is already set prior to pmd_clear.

Okay, it makes some sense.

One more question: why does __tlb_flush_full()/__tlb_flush_asce() require
disabling preemption and pmdp_flush_direct() doesn't?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
