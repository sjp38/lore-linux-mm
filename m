Date: Tue, 11 Apr 2006 12:33:06 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 2.6.17-rc1-mm1 2/6] Migrate-on-fault - check for misplaced
 page
In-Reply-To: <1144783687.5160.66.camel@localhost.localdomain>
Message-ID: <Pine.LNX.4.64.0604111227460.1349@schroedinger.engr.sgi.com>
References: <1144441108.5198.36.camel@localhost.localdomain>
 <1144441382.5198.40.camel@localhost.localdomain>
 <Pine.LNX.4.64.0604111109370.878@schroedinger.engr.sgi.com>
 <1144783687.5160.66.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: linux-mm <linux-mm@kvack.org>, ak@suse.de
List-ID: <linux-mm.kvack.org>

On Tue, 11 Apr 2006, Lee Schermerhorn wrote:

> > The misplaced page function should not consider the vma policy if the page 
> > is mapped because the VM does not handle vma policies for file 
> > mapped pages yet. This version may be checking for a policy that would
> > not be applied to the page for regular allocations.
> 
> When you say "mapped" here, you mean a mmap()ed file?  As opposed to
> "mapped by a pte" such that page_mapcount(page) != 0, right?  Because if
> the mapcount() isn't zero, we won't even look for misplaced pages.  And,
> with the V0.2 series, I'm only checking for misplaced pages with
> mapcount == 0 in the anon page fault path.  If necessary, I can skip
> pages in VMAs that have non-NULL vm_file.  Do we get these in the anon
> fault path?

You would need to skip evaluating the vma policy for file backed pages
for the misplaced page check.

> > You need to use the task policy instead of the vma policy if the page is 
> > file backed because vma policies do not apply in that case.
> 
> OK, but again, I haven't hooked up migrate-on-fault for file backed
> pages yet.  Here, you're saying that if I DID hook it up before fixing
> how file back pages are handled, then to be consistent with current
> behavior, I should use task policy for file back pages?

If this applied only to anonymous pages then its okay.

> How about shmem backed pages?

Those have a valid policy even when they are unmapped.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
