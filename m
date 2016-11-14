Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5E1146B0069
	for <linux-mm@kvack.org>; Mon, 14 Nov 2016 14:40:58 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id m203so33381149wma.2
        for <linux-mm@kvack.org>; Mon, 14 Nov 2016 11:40:58 -0800 (PST)
Received: from mail-wm0-x242.google.com (mail-wm0-x242.google.com. [2a00:1450:400c:c09::242])
        by mx.google.com with ESMTPS id k81si7330wmk.114.2016.11.14.11.40.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Nov 2016 11:40:57 -0800 (PST)
Received: by mail-wm0-x242.google.com with SMTP id u144so18312188wmu.0
        for <linux-mm@kvack.org>; Mon, 14 Nov 2016 11:40:57 -0800 (PST)
Date: Mon, 14 Nov 2016 22:40:54 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 1/6] mm: khugepaged: fix radix tree node leak in shmem
 collapse error path
Message-ID: <20161114194054.GA12829@node.shutemov.name>
References: <20161107190741.3619-2-hannes@cmpxchg.org>
 <20161108095352.GH32353@quack2.suse.cz>
 <20161108161245.GA4020@cmpxchg.org>
 <20161111105921.GC19382@node.shutemov.name>
 <20161111122224.GA5090@quack2.suse.cz>
 <20161111163753.GH19382@node.shutemov.name>
 <20161114080744.GA2524@quack2.suse.cz>
 <20161114142902.GA10455@node.shutemov.name>
 <20161114155250.GB3291@cmpxchg.org>
 <20161114164822.GB5141@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161114164822.GB5141@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Mon, Nov 14, 2016 at 11:48:22AM -0500, Johannes Weiner wrote:
> On Mon, Nov 14, 2016 at 10:52:50AM -0500, Johannes Weiner wrote:
> > On Mon, Nov 14, 2016 at 05:29:02PM +0300, Kirill A. Shutemov wrote:
> > > @@ -1400,7 +1400,9 @@ static void collapse_shmem(struct mm_struct *mm,
> > >  					PAGE_SIZE, 0);
> > >  
> > >  		spin_lock_irq(&mapping->tree_lock);
> > > -
> > > +		slot = radix_tree_lookup_slot(&mapping->page_tree, index);
> > > +		VM_BUG_ON_PAGE(page != radix_tree_deref_slot_protected(slot,
> > > +					&mapping->tree_lock), page);
> > >  		VM_BUG_ON_PAGE(page_mapped(page), page);
> > 
> > That looks good to me. The slot may get relocated, but the content
> > shouldn't change with the page locked.
> > 
> > Are you going to send a full patch with changelog and sign-off? If so,
> > please add:
> > 
> > Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> 
> Just to clarify, this is in addition to my radix_tree_iter_next()
> change. The iterator still needs to be reloaded because the number of
> valid slots that come after the current one can change as well.

Could you just amend all these fixups into your patch?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
