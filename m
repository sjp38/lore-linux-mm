Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f50.google.com (mail-qg0-f50.google.com [209.85.192.50])
	by kanga.kvack.org (Postfix) with ESMTP id D14A56B0070
	for <linux-mm@kvack.org>; Wed, 18 Mar 2015 12:25:18 -0400 (EDT)
Received: by qgfa8 with SMTP id a8so41520760qgf.0
        for <linux-mm@kvack.org>; Wed, 18 Mar 2015 09:25:18 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y60si17050608qgd.68.2015.03.18.09.25.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Mar 2015 09:25:18 -0700 (PDT)
Date: Wed, 18 Mar 2015 12:25:11 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: [PATCH] mm: don't count preallocated pmds
In-Reply-To: <20150318161246.GA5822@node.dhcp.inet.fi>
Message-ID: <alpine.LRH.2.02.1503181219001.6223@file01.intranet.prod.int.rdu2.redhat.com>
References: <alpine.LRH.2.02.1503181057340.14516@file01.intranet.prod.int.rdu2.redhat.com> <20150318161246.GA5822@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, linux-parisc@vger.kernel.org, jejb@parisc-linux.org, dave.anglin@bell.net



On Wed, 18 Mar 2015, Kirill A. Shutemov wrote:

> On Wed, Mar 18, 2015 at 11:16:42AM -0400, Mikulas Patocka wrote:
> > Hi
> > 
> > Here I'm sending a patch that fixes numerous "BUG: non-zero nr_pmds on 
> > freeing mm: -1" errors on 64-bit PA-RISC kernel.
> > 
> > I think the patch posted here 
> > http://www.spinics.net/lists/linux-parisc/msg05981.html is incorrect, it 
> > wouldn't work if the affected address range is freed and allocated 
> > multiple times.
> > 	- 1. alloc pgd with built-in pmd, the count of pmds is 1
> > 	- 2. free the range covered by the built-in pmd, the count of pmds 
> > 		is 0, but the built-in pmd is still present
> 
> Hm. Okay. I didn't realize you have special case in pmd_clear() for these
> pmds.
> 
> What about adding mm_inc_nr_pmds() in pmd_clear() for PxD_FLAG_ATTACHED
> to compensate mm_dec_nr_pmds() in free_pmd_range()?

pmd_clear clears one entry in the pmd, it wouldn't work. You need to add 
it to pgd_clear. That clears the pointer to the pmd (and does nothing if 
it is asked to clear the pointer to the preallocated pmd). But pgd_clear 
doesn't receive the pointer to mm.

> I don't like pmd_preallocated() in generic code. It's too specific to
> parisc.

The question is if it is better to use pmd_preallocated, or pass the 
pointer to the mm to pgd_clear (that would affect all architectures).

Mikulas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
