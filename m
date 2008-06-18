Date: Wed, 18 Jun 2008 22:46:09 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: Can get_user_pages( ,write=1, force=1, ) result in a read-only
 pte and _count=2?
In-Reply-To: <20080618203300.GA10123@sgi.com>
Message-ID: <Pine.LNX.4.64.0806182209320.16252@blonde.site>
References: <20080618164158.GC10062@sgi.com> <200806190329.30622.nickpiggin@yahoo.com.au>
 <Pine.LNX.4.64.0806181944080.4968@blonde.site> <20080618203300.GA10123@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robin Holt <holt@sgi.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Ingo Molnar <mingo@elte.hu>, Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 18 Jun 2008, Robin Holt wrote:
> On Wed, Jun 18, 2008 at 08:01:48PM +0100, Hugh Dickins wrote:
> > I think perhaps Robin is wanting to write into the page both from the
> > kernel (hence the get_user_pages) and from userspace: but finding that
> > the attempt to write from userspace breaks COW again (because gup
> > raised the page count and it's a readonly pte), so they end up
> > writing into different pages.  We know that COW didn't need to
> > be broken a second time, but do_wp_page doesn't know that.
> 
> That is exactly the problem I think I am seeing.  How should I be handling
> this to get the correct behavior?  As a test, should I be looking at
> the process's page table to see if the pfn matches and is writable.
> If it is not, putting the page and redoing the call to get_user_pages()?

I'd rather consider it a bug in get_user_pages than expect you to code
around it: it is the kind of job that get_user_pages is supposed to be
doing, but you've discovered a case it doesn't quite manage to handle
(if we're all interpreting things correctly).

But perhaps you need to work with distro kernels already out there:
in which case, yes, the procedure you describe above sounds right.
You're GPL, yes?  Then I expect you can use apply_to_page_range()
to do the page table walking for you (but I've not used it myself).

> > Might it help if do_wp_page returned VM_FAULT_WRITE (perhaps renamed)
> > only in the case where maybe_mkwrite decided not to mkwrite i.e. the
> > weird write=1,force=1 on readonly vma case?
> 
> I don't think it is in the return value, but rather the clearing of the
> FOLL_WRITE flag.  Is that being done to handle a force=1 where the vma
> is marked readonly?

Yes, and that's a much better way of changing it than I was suggesting.
Does the patch below work for you?  Does it look sensible to others?

> Could follow_page handle the force case differently?

IIRC it used to, but that proved unsatisfactory,
and the VM_FAULT_WRITE notification replaced that.

> 
> What is the intent of force=1?

Ah.  Ignoring the readonly case (which has never been problematic:
I've never had to think about it, I think it allows get_user_pages
to access PROT_NONE areas), write=1,force=1 is intended to allow
ptrace to modify a user-readonly area (e.g. set breakpoint in text),
avoiding the danger of its modifications leaking back into the file
which has been mapped.

But it's weird because it requires VM_MAYWRITE, which means if there
was any chance of the modification leaking back into the shared file,
it must have been opened for reading and writing, so the user process
has actually got permission to modify it.  And it's weird because it
causes COWs in a shared mapping which you normally think could never
contain COWs - I used to rail against it for that reason, but in the
end did an audit and couldn't find any place where that violation of
our assumptions actually mattered enough to get so excited.

Hugh

--- 2.6.26-rc6/mm/memory.c	2008-05-26 20:00:39.000000000 +0100
+++ linux/mm/memory.c	2008-06-18 22:06:46.000000000 +0100
@@ -1152,9 +1152,15 @@ int get_user_pages(struct task_struct *t
 				 * do_wp_page has broken COW when necessary,
 				 * even if maybe_mkwrite decided not to set
 				 * pte_write. We can thus safely do subsequent
-				 * page lookups as if they were reads.
+				 * page lookups as if they were reads. But only
+				 * do so when looping for pte_write is futile:
+				 * in some cases userspace may also be wanting
+				 * to write to the gotten user page, which a
+				 * read fault here might prevent (a readonly
+				 * page would get reCOWed by userspace write).
 				 */
-				if (ret & VM_FAULT_WRITE)
+				if ((ret & VM_FAULT_WRITE) &&
+				    !(vma->vm_flags & VM_WRITE))
 					foll_flags &= ~FOLL_WRITE;
 
 				cond_resched();

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
