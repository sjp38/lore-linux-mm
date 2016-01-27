Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f177.google.com (mail-pf0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 7E8886B0005
	for <linux-mm@kvack.org>; Tue, 26 Jan 2016 23:41:04 -0500 (EST)
Received: by mail-pf0-f177.google.com with SMTP id n128so110898428pfn.3
        for <linux-mm@kvack.org>; Tue, 26 Jan 2016 20:41:04 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id q76si6713746pfq.27.2016.01.26.20.41.03
        for <linux-mm@kvack.org>;
        Tue, 26 Jan 2016 20:41:03 -0800 (PST)
Date: Tue, 26 Jan 2016 23:40:36 -0500
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: [PATCH 1/3] x86: Honour passed pgprot in track_pfn_insert() and
 track_pfn_remap()
Message-ID: <20160127044036.GR2948@linux.intel.com>
References: <1453742717-10326-1-git-send-email-matthew.r.wilcox@intel.com>
 <1453742717-10326-2-git-send-email-matthew.r.wilcox@intel.com>
 <CALCETrWNx=H=u2R+JKM6Dr3oMqeiBSS+hdrYrGT=BJ-JrEyL+w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrWNx=H=u2R+JKM6Dr3oMqeiBSS+hdrYrGT=BJ-JrEyL+w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, Ingo Molnar <mingo@redhat.com>, Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Mon, Jan 25, 2016 at 09:33:35AM -0800, Andy Lutomirski wrote:
> On Mon, Jan 25, 2016 at 9:25 AM, Matthew Wilcox
> <matthew.r.wilcox@intel.com> wrote:
> > From: Matthew Wilcox <willy@linux.intel.com>
> >
> > track_pfn_insert() overwrites the pgprot that is passed in with a value
> > based on the VMA's page_prot.  This is a problem for people trying to
> > do clever things with the new vm_insert_pfn_prot() as it will simply
> > overwrite the passed protection flags.  If we use the current value of
> > the pgprot as the base, then it will behave as people are expecting.
> >
> > Also fix track_pfn_remap() in the same way.
> 
> Well that's embarrassing.  Presumably it worked for me because I only
> overrode the cacheability bits and lookup_memtype did the right thing.
> 
> But shouldn't the PAT code change the memtype if vm_insert_pfn_prot
> requests it?  Or are there no callers that actually need that?  (HPET
> doesn't, because there's a plain old ioremapped mapping.)

I'm confused.  Here's what I understand:

 - on x86, the bits in pgprot can be considered as two sets of bits;
   the 'cacheability bits' -- those in _PAGE_CACHE_MASK and the
   'protection bits' -- PRESENT, RW, USER, ACCESSED, NX
 - The purpose of track_pfn_insert() is to ensure that the cacheability bits
   are the same on all mappings of a given page, as strongly advised by the
   Intel manuals [1].  So track_pfn_insert() is really only supposed to
   modify _PAGE_CACHE_MASK of the passed pgprot, but in fact it ends up
   modifying the protection bits as well, due to the bug.

I don't think you overrode the cacheability bits at all.  It looks to
me like your patch ends up mapping the HPET into userspace writable.

I don't think the vm_insert_pfn_prot() call gets to change the memtype.
For one, that page may already be mapped into a differet userspace using
the pre-existing memtype, and [1] continues to bite you.  Then there
may be outstanding kernel users of the page that's being mapped in.

So I think track_pfn_insert() is doing the right thing with respect to
the cacheability bits (overwrite the ones passed in), it's just doing
an unexpected thing with regard to the protection bits, which my patch
should fix.

[1] "The PAT allows any memory type to be specified in the page tables,
and therefore it is possible to have a single physical page mapped to
two or more different linear addresses, each with different memory
types. Intel does not support this practice because it may lead to
undefined operations that can result in a system failure. In particular,
a WC page must never be aliased to a cacheable page because WC writes
may not check the processor caches."

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
