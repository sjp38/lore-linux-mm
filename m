Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 0C0B16B0038
	for <linux-mm@kvack.org>; Wed, 18 Mar 2015 12:53:20 -0400 (EDT)
Received: by wibg7 with SMTP id g7so95498472wib.1
        for <linux-mm@kvack.org>; Wed, 18 Mar 2015 09:53:19 -0700 (PDT)
Received: from kirsi1.inet.fi (mta-out1.inet.fi. [62.71.2.195])
        by mx.google.com with ESMTP id pi10si4594442wic.66.2015.03.18.09.53.17
        for <linux-mm@kvack.org>;
        Wed, 18 Mar 2015 09:53:18 -0700 (PDT)
Date: Wed, 18 Mar 2015 18:53:13 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm: don't count preallocated pmds
Message-ID: <20150318165313.GB5822@node.dhcp.inet.fi>
References: <alpine.LRH.2.02.1503181057340.14516@file01.intranet.prod.int.rdu2.redhat.com>
 <20150318161246.GA5822@node.dhcp.inet.fi>
 <alpine.LRH.2.02.1503181219001.6223@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LRH.2.02.1503181219001.6223@file01.intranet.prod.int.rdu2.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, linux-parisc@vger.kernel.org, jejb@parisc-linux.org, dave.anglin@bell.net

On Wed, Mar 18, 2015 at 12:25:11PM -0400, Mikulas Patocka wrote:
> 
> 
> On Wed, 18 Mar 2015, Kirill A. Shutemov wrote:
> 
> > On Wed, Mar 18, 2015 at 11:16:42AM -0400, Mikulas Patocka wrote:
> > > Hi
> > > 
> > > Here I'm sending a patch that fixes numerous "BUG: non-zero nr_pmds on 
> > > freeing mm: -1" errors on 64-bit PA-RISC kernel.
> > > 
> > > I think the patch posted here 
> > > http://www.spinics.net/lists/linux-parisc/msg05981.html is incorrect, it 
> > > wouldn't work if the affected address range is freed and allocated 
> > > multiple times.
> > > 	- 1. alloc pgd with built-in pmd, the count of pmds is 1
> > > 	- 2. free the range covered by the built-in pmd, the count of pmds 
> > > 		is 0, but the built-in pmd is still present
> > 
> > Hm. Okay. I didn't realize you have special case in pmd_clear() for these
> > pmds.
> > 
> > What about adding mm_inc_nr_pmds() in pmd_clear() for PxD_FLAG_ATTACHED
> > to compensate mm_dec_nr_pmds() in free_pmd_range()?
> 
> pmd_clear clears one entry in the pmd, it wouldn't work. You need to add 
> it to pgd_clear. That clears the pointer to the pmd (and does nothing if 
> it is asked to clear the pointer to the preallocated pmd). But pgd_clear 
> doesn't receive the pointer to mm.

I meant pmd_free(), not pmd_clear(). This should work fine.

> 
> > I don't like pmd_preallocated() in generic code. It's too specific to
> > parisc.
> 
> The question is if it is better to use pmd_preallocated, or pass the 
> pointer to the mm to pgd_clear (that would affect all architectures).
> 
> Mikulas

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
