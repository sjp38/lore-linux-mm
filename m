Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 1B2546B0068
	for <linux-mm@kvack.org>; Tue,  4 Sep 2012 17:53:52 -0400 (EDT)
Received: by pbbro12 with SMTP id ro12so10830533pbb.14
        for <linux-mm@kvack.org>; Tue, 04 Sep 2012 14:53:51 -0700 (PDT)
Date: Tue, 4 Sep 2012 14:53:47 -0700
From: Michel Lespinasse <walken@google.com>
Subject: Re: [PATCH 2/7] mm: fix potential anon_vma locking issue in
 mprotect()
Message-ID: <20120904215347.GA6769@google.com>
References: <1346750457-12385-1-git-send-email-walken@google.com>
 <1346750457-12385-3-git-send-email-walken@google.com>
 <20120904142745.GE3334@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120904142745.GE3334@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, riel@redhat.com, peterz@infradead.org, hughd@google.com, daniel.santos@pobox.com, linux-kernel@vger.kernel.org, akpm@linux-foundation.org

On Tue, Sep 04, 2012 at 04:27:45PM +0200, Andrea Arcangeli wrote:
> Hi Michel,
> 
> On Tue, Sep 04, 2012 at 02:20:52AM -0700, Michel Lespinasse wrote:
> > This change fixes an anon_vma locking issue in the following situation:
> > - vma has no anon_vma
> > - next has an anon_vma
> > - vma is being shrunk / next is being expanded, due to an mprotect call
> > 
> > We need to take next's anon_vma lock to avoid races with rmap users
> > (such as page migration) while next is being expanded.
> > 
> > This change also removes an optimization which avoided taking anon_vma
> > lock during brk adjustments. We could probably make that optimization
> > work again, but the following anon rmap change would break it,
> > so I kept things as simple as possible here.
> 
> Agreed, definitely a bug not to take the lock whenever any
> vm_start/vm_pgoff are moved, regardless if they're the next or current
> vma. Only vm_end can be moved without taking the lock.
> 
> I'd prefer to fix it like this though:
> 
> -	if (vma->anon_vma && (importer || start != vma->vm_start)) {
> +	if ((vma->anon_vma && (importer || start != vma->vm_start) ||
> +           (adjust_next && next->anon_vma)) {

I think the minimal fix would actually be:

 	if (vma->anon_vma && (importer || start != vma->vm_start)) {
 		anon_vma = vma->anon_vma;
+	else if (next->anon_vma && adjust_next)
+		anon_vma = next->anon_vma;

I suppose if we were to consider adding this fix to the stable series,
we should probably do it in such a minimal way. I hadn't actually
considered it, because I was only thinking about this patch series,
and at patch 4/7 it becomes necessary to lock the anon_vma even if
only the vm_end side gets modified (so we'd still end up with what I
proposed in the end)

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
