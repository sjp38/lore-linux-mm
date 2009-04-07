Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 32B215F0001
	for <linux-mm@kvack.org>; Tue,  7 Apr 2009 15:37:47 -0400 (EDT)
Date: Tue, 7 Apr 2009 21:40:34 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] [13/16] POISON: The high level memory error handler in the VM
Message-ID: <20090407194034.GW17934@one.firstfloor.org>
References: <20090407509.382219156@firstfloor.org> <20090407151010.E72A91D0471@basil.firstfloor.org> <20090407185146.GA3818@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090407185146.GA3818@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andi Kleen <andi@firstfloor.org>, hugh@veritas.com, npiggin@suse.de, riel@redhat.com, lee.schermerhorn@hp.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 07, 2009 at 08:51:46PM +0200, Johannes Weiner wrote:
> > +
> > +	if (av == NULL)	/* Not actually mapped anymore */
> > +		goto out;
> > +
> > +	read_lock(&tasklist_lock);
> > +	for_each_process (tsk) {
> > +		if (!tsk->mm)
> > +			continue;
> > +		list_for_each_entry (vma, &av->head, anon_vma_node) {
> > +			if (vma->vm_mm == tsk->mm)
> > +				add_to_kill(tsk, page, vma, to_kill, tkc);
> > +		}
> > +	}
> > +	read_unlock(&tasklist_lock);
> > +out:
> > +	page_unlock_anon_vma(av);
> 
> If !av, this doesn't need an unlock and in fact crashes due to
> dereferencing NULL.

Good point. Fixed. Thanks.
> 
> > +static int poison_page_prepare(struct page *p, unsigned long pfn, int trapno)
> > +{
> > +	if (PagePoison(p)) {
> > +		printk(KERN_ERR
> > +		       "MCE: Error for already poisoned page at %lx\n", pfn);
> > +		return -1;
> > +	}
> > +	SetPagePoison(p);
> 
> TestSetPagePoison()?

It doesn't matter in this case because it doesn't need to be atomic.
The normal reason for TestSet is atomicity requirements. If someone
feels strongly about it I can add it.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
