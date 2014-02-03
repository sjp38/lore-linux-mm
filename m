Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f174.google.com (mail-ig0-f174.google.com [209.85.213.174])
	by kanga.kvack.org (Postfix) with ESMTP id 2D6396B0037
	for <linux-mm@kvack.org>; Mon,  3 Feb 2014 12:14:16 -0500 (EST)
Received: by mail-ig0-f174.google.com with SMTP id hl1so4534757igb.1
        for <linux-mm@kvack.org>; Mon, 03 Feb 2014 09:14:15 -0800 (PST)
Received: from relay.sgi.com (relay3.sgi.com. [192.48.152.1])
        by mx.google.com with ESMTP id ax4si28156902icc.129.2014.02.03.09.14.15
        for <linux-mm@kvack.org>;
        Mon, 03 Feb 2014 09:14:15 -0800 (PST)
Date: Mon, 3 Feb 2014 11:14:12 -0600
From: Alex Thorlton <athorlton@sgi.com>
Subject: Re: [PATCH 1/3] Revert "thp: make MADV_HUGEPAGE check for
 mm->def_flags"
Message-ID: <20140203171412.GA3034@sgi.com>
References: <1391192628-113858-1-git-send-email-athorlton@sgi.com>
 <1391192628-113858-3-git-send-email-athorlton@sgi.com>
 <20140131145224.7f8efc67d882a2e1a89b0778@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140131145224.7f8efc67d882a2e1a89b0778@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, Oleg Nesterov <oleg@redhat.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Paolo Bonzini <pbonzini@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Sasha Levin <sasha.levin@oracle.com>, linux390@de.ibm.com, linux-s390@vger.kernel.org, linux-mm@kvack.org

On Fri, Jan 31, 2014 at 02:52:24PM -0800, Andrew Morton wrote:
> On Fri, 31 Jan 2014 12:23:43 -0600 Alex Thorlton <athorlton@sgi.com> wrote:
> 
> > This reverts commit 8e72033f2a489b6c98c4e3c7cc281b1afd6cb85cm, and adds
> 
> 'm' is not a hex digit ;)

My mistake!  Sorry about that.

> > in code to fix up any issues caused by the revert.
> > 
> > The revert is necessary because hugepage_madvise would return -EINVAL
> > when VM_NOHUGEPAGE is set, which will break subsequent chunks of this
> > patch set.
> 
> This is a bit skimpy.  Why doesn't the patch re-break kvm-on-s390?
> 
> it would be nice to have a lot more detail here, please.  What was the
> intent of 8e72033f2a48, how this patch retains 8e72033f2a48's behavior,
> etc.

I'm actually not too sure about this, off hand.  I just know that we
couldn't have it in there because of the check for VM_NOHUGEPAGE.  The
s390 guys approved the revert, as long as we added in the following
piece:

> > --- a/arch/s390/mm/pgtable.c
> > +++ b/arch/s390/mm/pgtable.c
> > @@ -504,6 +504,9 @@ static int gmap_connect_pgtable(unsigned long address, unsigned long segment,
> >  	if (!pmd_present(*pmd) &&
> >  	    __pte_alloc(mm, vma, pmd, vmaddr))
> >  		return -ENOMEM;
> > +	/* large pmds cannot yet be handled */
> > +	if (pmd_large(*pmd))
> > +		return -EFAULT;
> 
> This bit wasn't in 8e72033f2a48.

I added the fix-up code in with the revert, so that it would all be in
one place; wasn't sure what the standard was for this sort of thing.  If
it's preferable to see this code in a separate patch, that's easy enough
to do.

I'll look into exactly what the original commit was intended to do, and
get a better description of what's going on here.  Let me know if I
should split the two changes into separate patches.

- Alex

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
