Message-ID: <20050114211441.59635.qmail@web14305.mail.yahoo.com>
Date: Fri, 14 Jan 2005 13:14:40 -0800 (PST)
From: Kanoj Sarcar <kanojsarcar@yahoo.com>
Subject: Re: smp_rmb in mm/memory.c in 2.6.10
In-Reply-To: <Pine.LNX.4.44.0501142012300.2938-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Anton Blanchard <anton@samba.org>, Andi Kleen <ak@suse.de>, William Lee Irwin III <wli@holomorphy.com>, Andrea Arcangeli <andrea@suse.de>, linux-mm@kvack.org, davem@redhat.com
List-ID: <linux-mm.kvack.org>

Hi Hugh,

Here are the relevant steps of the two procedures:

do_no_page()
1. sequence = atomic_read(&mapping->truncate_count);
2. smp_rmb();
3. vma->vm_ops->nopage()
4. spin_lock(&mm->page_table_lock);
5. Retry if sequence !=
atomic_read(&mapping->truncate_count)
5a. See later.
6. update_mmu_cache()
7. spin_unlock(&mm->page_table_lock);

unmap_mapping_range()
8. spin_lock(&mapping->i_mmap_lock); /* irrelevant */
9. atomic_inc(&mapping->truncate_count);
10.zap_page_range():spin_lock(&mm->page_table_lock);
zap_page_range():tlbcleaning
zap_page_range():spin_unlock(&mm->page_table_lock)
11. spin_unlock(&mapping->i_mmap_lock);



--- Hugh Dickins <hugh@veritas.com> wrote:

> On Thu, 13 Jan 2005, Kanoj Sarcar wrote:
> > 
> > Thanks, I think this explains it. IE, if
> do_no_page()
> > reads truncate_count, and then later goes on to
> > acquire a lock in nopage(), the smp_rmb() is
> > guaranteeing that the read of truncate_count
> completes
> > before nopage() starts executing. 
> > 
> > For x86 at least, it seems to me that since the
> > spin_lock (in nopage()) uses a "lock" instruction,
> > that itself guarantees that the truncate_count
> read is
> > completed, even without the smp_rmb(). (Refer to
> IA32
> > SDM Vol 3 section 7.2.4 last para page 7-11). Thus
> for
> > x86, the smp_rmb is superfluous.
> 
> You're making me nervous.  If you look at 2.6.11-rc1
> you'll find
> that I too couldn't see the point of that smp_rmb(),
> on any architecture,
> and so removed it; while also removing the
> "atomicity" of truncate_count.

I haven't looked at the 2.6.11 code, but you could
look at atomicity and smp_rmb() as two different
changes. I believe the ordering of the C code in steps
8 and 9 could be interchanged without any problems, ie
truncate_count is not protected by i_mmap_lock. In
that case, you would need truncate_count to be atomic,
unless you can guarantee unmap_mapping_range() is
single threaded wrt "mapping" from callers.  

> 
> Here was my comment to that patch:
> > Why is mapping->truncate_count atomic?  It's
> incremented inside
> > i_mmap_lock (and i_sem), and the reads don't need
> it to be atomic.
> > 
> > And why smp_rmb() before call to ->nopage?  The
> compiler cannot reorder
> > the initial assignment of sequence after the call
> to ->nopage, and no
> > cpu (yet!) can read from the future, which is all
> that matters there.
> 
> Now I'm not so convinced by that "no cpu can read
> from the future".
> 
> I don't entirely follow your remarks above, but I do
> think people
> on this thread have a better grasp of these matters
> than I have:
> does anyone now think that smp_rmb() needs to be
> restored?

As to the smp_rmb() part, I believe it is required; we
are not talking about compiler reorderings, rather cpu
reorderings. Given just steps 1 and 3 above, there is
no guarantee from the cpu that the read of
truncate_count would not be performed before nopage()
is almost complete, even though the compiler generated
the proper instruction order (ie the cpu could pull
down the read of truncate_count). You do not need a
similar smp_rmb() before step 5, because the
spin_lock() in step4 will prevent the cpu from pulling
up the read of truncate_count to any earlier than
step4. The other part is that the spin_lock() in step4
can not be moved down to step 5a, because that opens a
race with the unmap_mapping_range() code.

Whoever wrote this code did a careful job.

Kanoj
 
> 
> Hugh
> 
> 



		
__________________________________ 
Do you Yahoo!? 
The all-new My Yahoo! - What will yours do?
http://my.yahoo.com 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
