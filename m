Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 71C866B0005
	for <linux-mm@kvack.org>; Tue, 12 Feb 2013 03:46:44 -0500 (EST)
Received: from /spool/local
	by e06smtp18.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <schwidefsky@de.ibm.com>;
	Tue, 12 Feb 2013 08:44:48 -0000
Received: from d06av11.portsmouth.uk.ibm.com (d06av11.portsmouth.uk.ibm.com [9.149.37.252])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r1C8kUWm21364940
	for <linux-mm@kvack.org>; Tue, 12 Feb 2013 08:46:30 GMT
Received: from d06av11.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av11.portsmouth.uk.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r1C8kcPj016778
	for <linux-mm@kvack.org>; Tue, 12 Feb 2013 01:46:38 -0700
Date: Tue, 12 Feb 2013 09:46:36 +0100
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: Re: [PATCH] s390/mm: implement software dirty bits
Message-ID: <20130212094636.56299155@mschwide>
In-Reply-To: <alpine.LNX.2.00.1302111315070.1174@eggly.anvils>
References: <1360087925-8456-1-git-send-email-schwidefsky@de.ibm.com>
	<1360087925-8456-3-git-send-email-schwidefsky@de.ibm.com>
	<alpine.LNX.2.00.1302061504340.7256@eggly.anvils>
	<20130207111838.27fea18f@mschwide>
	<20130211152715.03fab00a@mschwide>
	<alpine.LNX.2.00.1302111315070.1174@eggly.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org, linux-s390@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>, Russell King <linux@arm.linux.org.uk>

On Mon, 11 Feb 2013 14:08:23 -0800 (PST)
Hugh Dickins <hughd@google.com> wrote:

> On Mon, 11 Feb 2013, Martin Schwidefsky wrote:
> > On Thu, 7 Feb 2013 11:18:38 -0800
> > Martin Schwidefsky <schwidefsky@de.ibm.com> wrote:
> > > On Wed, 6 Feb 2013 16:20:40 -0800 (PST)
> > > Hugh Dickins <hughd@google.com> wrote:
> > > 
> > > Anon page and accounted file pages won't need the mk_pte optimization,
> > > that is there for tmpfs/shmem. We could do that in common code as well,
> > > to make the dependency on PageDirty more obvious.
> > > 
> > > > --- 3.8-rc6/mm/memory.c	2013-01-09 19:25:05.028321379 -0800
> > > > +++ linux/mm/memory.c	2013-02-06 15:01:17.904387877 -0800
> > > > @@ -3338,6 +3338,10 @@ static int __do_fault(struct mm_struct *
> > > >  				dirty_page = page;
> > > >  				get_page(dirty_page);
> > > >  			}
> > > > +#ifdef CONFIG_S390
> > > > +			else if (pte_write(entry) && PageDirty(page))
> > > > +				pte_mkdirty(entry);
> > > > +#endif
> > > >  		}
> > > >  		set_pte_at(mm, address, page_table, entry);
> > > > 
> > > > And then I wonder, is that something we should do on all architectures?
> > > > On the one hand, it would save a hardware fault when and if the pte is
> > > > dirtied later; on the other hand, it seems wrong to claim pte dirty when
> > > > not (though I didn't find anywhere that would care).
> > > 
> > > I don't like the fact that we are adding another CONFIG_S390, if we could
> > > pre-dirty the pte for all architectures that would be nice. It has no
> > > ill effects for s390 to make the pte dirty, I can think of no reason
> > > why it should hurt for other architectures.
> > 
> > Having though further on the issue, it does not make sense to force all
> > architectures to set the dirty bit in the pte as this would make
> > try_to_unmap_one to call set_page_dirty even for ptes which have not
> > been used for writing.
> 
> In this particular case of shmem/tmpfs/ramfs (perhaps a few unaccounted
> others too, I doubt many are mmap'able), on pages that were already
> PageDirty when mapped.  And ramfs doesn't get as far as try_to_unmap_one,
> because it has already failed the page_evictable test.

The important case is shmem for databases, no? 

> > set_page_dirty is a non-trivial function that
> > calls mapping->a_ops->set_page_dirty or __set_page_dirty_buffers. These
> > cycles should imho not be spent on architectures with h/w pte dirty
> > bits.
> 
> The almost no-op __set_page_dirty_no_writeback is actually the one
> that gets called.  Now, I don't disagree with you that I'd prefer not
> to have to call it; but I'd also prefer to do the same thing on s390
> as other architectures.

Even if that would mean that unnecessary cycles are spent on the other
architectures? My feeling is that we should try to avoid that.
 
> I'm undecided which I prefer.  Before you wrote, I was going to suggest
> that you put your original patch into your tree for linux-next, then I
> propose an mm patch on top, restoring the s390 mk_pte() to normalcy, and
> adding the pte_mkdirty() to __do_fault() as above; but with a comment
> (you have), taking out the #ifdef, doing it on all architectures - so
> that if we see a problem on one (because some code elsewhere is deducing
> something from pte_dirty), it's advance warning of a problem on s390.
> But if anyone objected to my patch, it would cast doubt upon yours.

That is certainly a workable approach.

> > 
> > To avoid CONFIG_S390 in common code I'd like to introduce a new
> > __ARCH_WANT_PTE_WRITE_DIRTY define which then is used in __do_fault
> > like this:
> 
> My personal opinion is that an __ARCH_WANT_PTE_WRITE_DIRTY that is set
> by only a single architecture just obfuscates the issue, that CONFIG_S390
> is clearer for everyone.  Much of my dislike of page_test_and_clear_dirty
> was that it looks so brilliantly generic, and yet is so peculiar to s390.
> 
> But it's quite likely that I'm in a minority of one on that:
> #ifdef CONFIG_HUGHD
> #define __DEVELOPER_PREFERS_MORE_EXPLICIT_SINGLE_ARCH_DEPENDENCE 1
> #endif
> 
> And at least #ifdef CONFIG_S390_OR_WHATEVER flags it as exceptional:
> this might be a case where I'd say the ugliness of an #ifdef is good.
> I am glad that you've come around to doing it this way, rather than
> hiding the PageDirty peculiarity down in arch/s390's mk_pte().

I am not so sure about that. Arm seems to have exactly the same problem,
they do not set the h/w write bit as long as the user ptes are not dirty.
My guess is that arm is the second architectures that could use the define.

Putting the arm maintainer on CC. Russell, the question is if a pre-dirty
of writable user PTEs if the PageDirty bit is set would help arm to avoid
protection faults for tmpfs/shmem. The relevant hunk from the patch:

--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3338,6 +3338,18 @@ static int __do_fault(struct mm_struct *mm, struct vm_are
a_struct *vma,
                                dirty_page = page;
                                get_page(dirty_page);
                        }
+#ifdef __ARCH_WANT_PTE_WRITE_DIRTY
+                       /*
+                        * Architectures that use software dirty bits may
+                        * want to set the dirty bit in the pte if the pte
+                        * is writable and the PageDirty bit is set for the
+                        * page. This avoids unnecessary protection faults
+                        * for writable mappings which do not use
+                        * mapping_cap_account_dirty, e.g. tmpfs and shmem.
+                        */
+                       else if (pte_write(entry) && PageDirty(page))
+                               entry = pte_mkdirty(entry);
+#endif
                }
                set_pte_at(mm, address, page_table, entry);
 
-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
