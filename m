Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1B50E6B0038
	for <linux-mm@kvack.org>; Fri, 15 Dec 2017 05:25:52 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id r6so13954897itr.1
        for <linux-mm@kvack.org>; Fri, 15 Dec 2017 02:25:52 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id s15si4736825ith.152.2017.12.15.02.25.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Dec 2017 02:25:47 -0800 (PST)
Date: Fri, 15 Dec 2017 11:25:29 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v2 01/17] mm/gup: Fixup p*_access_permitted()
Message-ID: <20171215102529.vtsjhb7h7jiufkr3@hirez.programming.kicks-ass.net>
References: <20171214112726.742649793@infradead.org>
 <20171214113851.146259969@infradead.org>
 <20171214124117.wfzcjdczyta2sery@hirez.programming.kicks-ass.net>
 <20171214143730.s6w7sd6c7b5t6fqp@hirez.programming.kicks-ass.net>
 <f0244eb7-bd9f-dce4-68a5-cf5f8b43652e@intel.com>
 <20171214205450.GI3326@worktop>
 <8eedb9a3-0ba2-52df-58f6-3ed869d18ca3@intel.com>
 <20171215080041.zftzuxdonxrtmssq@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171215080041.zftzuxdonxrtmssq@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: linux-kernel@vger.kernel.org, tglx@linutronix.de, x86@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirsky <luto@kernel.org>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, keescook@google.com, hughd@google.com, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, aliguori@amazon.com, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, kirill.shutemov@linux.intel.com, dan.j.williams@intel.com

On Fri, Dec 15, 2017 at 09:00:41AM +0100, Peter Zijlstra wrote:
> On Thu, Dec 14, 2017 at 09:04:56PM -0800, Dave Hansen wrote:
> > 
> > I've got some additions to the selftests and a fix where we pass FOLL_*
> > flags around a bit more instead of just 'write'.  I'll get those out as
> > soon as I do a bit more testing.
> 
> Try the below; I have more in the works, but this already fixes a whole
> bunch of obvious fail and should fix the case I described.
> 
> The thing is, you should _never_ return NULL for an access error, that's
> complete crap.
> 
> You should also not blindly change every pte_write() test to
> pte_access_permitted(), that's also wrong, because then you're missing
> the read-access tests.
> 
> Basically you need to very carefully audit each and every
> p??_access_permitted() call; they're currently mostly wrong.

I think we also want this:

diff --git a/fs/dax.c b/fs/dax.c
index 78b72c48374e..95981591977a 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -627,8 +627,7 @@ static void dax_mapping_entry_mkclean(struct address_space *mapping,
 
 			if (pfn != pmd_pfn(*pmdp))
 				goto unlock_pmd;
-			if (!pmd_dirty(*pmdp)
-					&& !pmd_access_permitted(*pmdp, WRITE))
+			if (!pmd_dirty(*pmdp) && !pmd_write(*pmdp))
 				goto unlock_pmd;
 
 			flush_cache_page(vma, address, pfn);
diff --git a/mm/memory.c b/mm/memory.c
index 5eb3d2524bdc..6ce3ba12e07d 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3948,7 +3948,7 @@ static int handle_pte_fault(struct vm_fault *vmf)
 	if (unlikely(!pte_same(*vmf->pte, entry)))
 		goto unlock;
 	if (vmf->flags & FAULT_FLAG_WRITE) {
-		if (!pte_access_permitted(entry, WRITE))
+		if (!pte_write(entry))
 			return do_wp_page(vmf);
 		entry = pte_mkdirty(entry);
 	}


the DAX one is both inconsistent (only the PMD case, not also the PTE
case) and just wrong; you don't want PKEYs to avoid cleaning pages,
that's crazy.

The memory one is also clearly wrong, not having access does not a write
fault make. If we have pte_write() set we should not do_wp_page() just
because we don't have access. This falls under the "doing anything other
than hard failure for !access is crazy" header.


Still looking at __handle_mm_fault(), they smell bad, but I can't get my
brain started today :/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
