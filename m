Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1188B6B0292
	for <linux-mm@kvack.org>; Wed,  9 Aug 2017 20:58:32 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id k71so10826721wrc.15
        for <linux-mm@kvack.org>; Wed, 09 Aug 2017 17:58:32 -0700 (PDT)
Received: from mail-wm0-x242.google.com (mail-wm0-x242.google.com. [2a00:1450:400c:c09::242])
        by mx.google.com with ESMTPS id q46si5323236eda.37.2017.08.09.17.58.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Aug 2017 17:58:30 -0700 (PDT)
Received: by mail-wm0-x242.google.com with SMTP id y206so1247551wmd.5
        for <linux-mm@kvack.org>; Wed, 09 Aug 2017 17:58:30 -0700 (PDT)
Date: Thu, 10 Aug 2017 03:58:28 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 05/16] mm: Protect VMA modifications using VMA sequence
 count
Message-ID: <20170810005828.qmw3p7d676hjwkss@node.shutemov.name>
References: <1502202949-8138-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1502202949-8138-6-git-send-email-ldufour@linux.vnet.ibm.com>
 <20170809101241.ek4fqinqaq5qfkq4@node.shutemov.name>
 <f935091a-d8f9-1951-8397-f5c464a2b922@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f935091a-d8f9-1951-8397-f5c464a2b922@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

On Wed, Aug 09, 2017 at 12:43:33PM +0200, Laurent Dufour wrote:
> On 09/08/2017 12:12, Kirill A. Shutemov wrote:
> > On Tue, Aug 08, 2017 at 04:35:38PM +0200, Laurent Dufour wrote:
> >> The VMA sequence count has been introduced to allow fast detection of
> >> VMA modification when running a page fault handler without holding
> >> the mmap_sem.
> >>
> >> This patch provides protection agains the VMA modification done in :
> >> 	- madvise()
> >> 	- mremap()
> >> 	- mpol_rebind_policy()
> >> 	- vma_replace_policy()
> >> 	- change_prot_numa()
> >> 	- mlock(), munlock()
> >> 	- mprotect()
> >> 	- mmap_region()
> >> 	- collapse_huge_page()
> > 
> > I don't thinks it's anywhere near complete list of places where we touch
> > vm_flags. What is your plan for the rest?
> 
> The goal is only to protect places where change to the VMA is impacting the
> page fault handling. If you think I missed one, please advise.

That's very fragile approach. We rely here too much on specific compiler behaviour.

Any write access to vm_flags can, in theory, be translated to several
write accesses. For instance with setting vm_flags to 0 in the middle,
which would result in sigfault on page fault to the vma.

Nothing (apart from common sense) prevents compiler from generating this
kind of pattern.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
