Date: Fri, 14 Jan 2005 22:09:17 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: smp_rmb in mm/memory.c in 2.6.10
In-Reply-To: <20050114211441.59635.qmail@web14305.mail.yahoo.com>
Message-ID: <Pine.LNX.4.44.0501142127430.3050-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanojsarcar@yahoo.com>
Cc: Anton Blanchard <anton@samba.org>, Andi Kleen <ak@suse.de>, William Lee Irwin III <wli@holomorphy.com>, Andrea Arcangeli <andrea@suse.de>, linux-mm@kvack.org, davem@redhat.com
List-ID: <linux-mm.kvack.org>

On Fri, 14 Jan 2005, Kanoj Sarcar wrote:
> 
> Here are the relevant steps of the two procedures:
> 
> do_no_page()
> 1. sequence = atomic_read(&mapping->truncate_count);
> 2. smp_rmb();
> 3. vma->vm_ops->nopage()
> 4. spin_lock(&mm->page_table_lock);
> 5. Retry if sequence !=
> atomic_read(&mapping->truncate_count)
> 5a. See later.
> 6. update_mmu_cache()
> 7. spin_unlock(&mm->page_table_lock);
> 
> unmap_mapping_range()
> 8. spin_lock(&mapping->i_mmap_lock); /* irrelevant */
> 9. atomic_inc(&mapping->truncate_count);
> 10.zap_page_range():spin_lock(&mm->page_table_lock);
> zap_page_range():tlbcleaning
> zap_page_range():spin_unlock(&mm->page_table_lock)
> 11. spin_unlock(&mapping->i_mmap_lock);

Yes (except that 8 is somewhat relevant to removing atomicity;
I say somewhat because there's also an exclusive i_sem protecting).

> --- Hugh Dickins <hugh@veritas.com> wrote:
> > On Thu, 13 Jan 2005, Kanoj Sarcar wrote:
> > > 
> > > Thanks, I think this explains it. IE, if
> > do_no_page()
> > > reads truncate_count, and then later goes on to
> > > acquire a lock in nopage(), the smp_rmb() is
> > > guaranteeing that the read of truncate_count
> > completes
> > > before nopage() starts executing. 
> > > 
> > > For x86 at least, it seems to me that since the
> > > spin_lock (in nopage()) uses a "lock" instruction,
> > > that itself guarantees that the truncate_count
> > read is
> > > completed, even without the smp_rmb(). (Refer to
> > IA32
> > > SDM Vol 3 section 7.2.4 last para page 7-11). Thus
> > for
> > > x86, the smp_rmb is superfluous.
> > 
> > You're making me nervous.  If you look at 2.6.11-rc1
> > you'll find
> > that I too couldn't see the point of that smp_rmb(),
> > on any architecture,
> > and so removed it; while also removing the
> > "atomicity" of truncate_count.
> 
> I haven't looked at the 2.6.11 code,

Please do if you have time.

> but you could look at atomicity and smp_rmb()
> as two different changes.

Definitely (oh, the shame that I put them together in one patch!)

> I believe the ordering of the C code in steps
> 8 and 9 could be interchanged without any problems, ie
> truncate_count is not protected by i_mmap_lock. In
> that case, you would need truncate_count to be atomic,
> unless you can guarantee unmap_mapping_range() is
> single threaded wrt "mapping" from callers.  

Right, but given the ordering 8 before 9,
there is no point to truncate_count being atomic.

> > Here was my comment to that patch:
> > > Why is mapping->truncate_count atomic?  It's
> > incremented inside
> > > i_mmap_lock (and i_sem), and the reads don't need
> > it to be atomic.
> > > 
> > > And why smp_rmb() before call to ->nopage?  The
> > compiler cannot reorder
> > > the initial assignment of sequence after the call
> > to ->nopage, and no
> > > cpu (yet!) can read from the future, which is all
> > that matters there.
> > 
> > Now I'm not so convinced by that "no cpu can read
> > from the future".
> > 
> > I don't entirely follow your remarks above, but I do
> > think people
> > on this thread have a better grasp of these matters
> > than I have:
> > does anyone now think that smp_rmb() needs to be
> > restored?
> 
> As to the smp_rmb() part, I believe it is required; we
> are not talking about compiler reorderings,

Did need to be considered, but I still agree with
myself that the function call makes it no problem.

> rather cpu
> reorderings. Given just steps 1 and 3 above, there is
> no guarantee from the cpu that the read of
> truncate_count would not be performed before nopage()
> is almost complete, even though the compiler generated
> the proper instruction order (ie the cpu could pull
> down the read of truncate_count).

This is your crucial point.  Now I think you're right.

But I have remembered how I was thinking at the time,
what's behind my "no cpu can read from the future" remark.

Suppose unmap_mapping_range is incrementing truncate_count
from 0 to 1.  I could conceive of do_no_page's read into
"sequence" not completing until the spin_lock at step 4.
But I believed that the read issued before ->nopage could
only err on the safe side, sometimes fetching 0 instead of 1
when 1 would already be safe, but never seeing 1 too soon.

That belief was naive, wasn't it?  I was thinking in terms
of "slow" instructions rather than reordered instructions.

> Whoever wrote this code did a careful job.

It was Andrea (one reason I've copied him now -
as I did when posting the patch to remove it).

Unless someone sees this differently, I should send a patch to
restore the smp_rmb(), with a longer code comment on what it's for.

Thanks a lot for your detailed answer.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
