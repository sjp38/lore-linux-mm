Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 505886B7383
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 04:07:45 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id m16so10807179pgd.0
        for <linux-mm@kvack.org>; Wed, 05 Dec 2018 01:07:45 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id t63si17535120pgd.78.2018.12.05.01.07.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 05 Dec 2018 01:07:40 -0800 (PST)
Date: Wed, 5 Dec 2018 10:07:34 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC v2 09/13] mm: Restrict memory encryption to anonymous VMA's
Message-ID: <20181205090734.GA4234@hirez.programming.kicks-ass.net>
References: <cover.1543903910.git.alison.schofield@intel.com>
 <0b294e74f06a0d6bee51efcd7b0eb1f20b00babe.1543903910.git.alison.schofield@intel.com>
 <20181204091044.GP11614@hirez.programming.kicks-ass.net>
 <20181205053020.GB18596@alison-desk.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181205053020.GB18596@alison-desk.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alison Schofield <alison.schofield@intel.com>
Cc: dhowells@redhat.com, tglx@linutronix.de, jmorris@namei.org, mingo@redhat.com, hpa@zytor.com, bp@alien8.de, luto@kernel.org, kirill.shutemov@linux.intel.com, dave.hansen@intel.com, kai.huang@intel.com, jun.nakajima@intel.com, dan.j.williams@intel.com, jarkko.sakkinen@intel.com, keyrings@vger.kernel.org, linux-security-module@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org

On Tue, Dec 04, 2018 at 09:30:20PM -0800, Alison Schofield wrote:
> On Tue, Dec 04, 2018 at 10:10:44AM +0100, Peter Zijlstra wrote:
> > > + * Encrypted mprotect is only supported on anonymous mappings.
> > > + * All VMA's in the requested range must be anonymous. If this
> > > + * test fails on any single VMA, the entire mprotect request fails.
> > > + */
> > > +bool mem_supports_encryption(struct vm_area_struct *vma, unsigned long end)
> > 
> > That's a 'weird' interface and cannot do what the comment says it should
> > do.
> 
> More please? With MKTME, only anonymous memory supports encryption.
> Is it the naming that's weird, or you don't see it doing what it says?

It's weird because you don't fully speficy the range -- ie. it cannot
verify the vma argument. It is also weird because the start and end are
not of the same type -- or rather, there is no start at all.

So while the comment talks about a range, there is not in fact a range
(only the implied @start is somewhere inside @vma). The comment also
states all vmas in the range, but again, because of a lack of range
specification it cannot verify this statement.

Now, I don't necessarily object to the function and its implementation,
but that comment is just plain misleading.
