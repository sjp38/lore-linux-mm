Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0894E6B025E
	for <linux-mm@kvack.org>; Mon, 14 Nov 2016 11:48:29 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id u144so30854289wmu.1
        for <linux-mm@kvack.org>; Mon, 14 Nov 2016 08:48:28 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id tc14si20675307wjb.136.2016.11.14.08.48.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Nov 2016 08:48:27 -0800 (PST)
Date: Mon, 14 Nov 2016 11:48:22 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 1/6] mm: khugepaged: fix radix tree node leak in shmem
 collapse error path
Message-ID: <20161114164822.GB5141@cmpxchg.org>
References: <20161107190741.3619-1-hannes@cmpxchg.org>
 <20161107190741.3619-2-hannes@cmpxchg.org>
 <20161108095352.GH32353@quack2.suse.cz>
 <20161108161245.GA4020@cmpxchg.org>
 <20161111105921.GC19382@node.shutemov.name>
 <20161111122224.GA5090@quack2.suse.cz>
 <20161111163753.GH19382@node.shutemov.name>
 <20161114080744.GA2524@quack2.suse.cz>
 <20161114142902.GA10455@node.shutemov.name>
 <20161114155250.GB3291@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161114155250.GB3291@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Mon, Nov 14, 2016 at 10:52:50AM -0500, Johannes Weiner wrote:
> On Mon, Nov 14, 2016 at 05:29:02PM +0300, Kirill A. Shutemov wrote:
> > @@ -1400,7 +1400,9 @@ static void collapse_shmem(struct mm_struct *mm,
> >  					PAGE_SIZE, 0);
> >  
> >  		spin_lock_irq(&mapping->tree_lock);
> > -
> > +		slot = radix_tree_lookup_slot(&mapping->page_tree, index);
> > +		VM_BUG_ON_PAGE(page != radix_tree_deref_slot_protected(slot,
> > +					&mapping->tree_lock), page);
> >  		VM_BUG_ON_PAGE(page_mapped(page), page);
> 
> That looks good to me. The slot may get relocated, but the content
> shouldn't change with the page locked.
> 
> Are you going to send a full patch with changelog and sign-off? If so,
> please add:
> 
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>

Just to clarify, this is in addition to my radix_tree_iter_next()
change. The iterator still needs to be reloaded because the number of
valid slots that come after the current one can change as well.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
