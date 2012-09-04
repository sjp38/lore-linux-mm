Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id E53CC6B0068
	for <linux-mm@kvack.org>; Tue,  4 Sep 2012 18:16:48 -0400 (EDT)
Date: Wed, 5 Sep 2012 00:16:41 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 2/7] mm: fix potential anon_vma locking issue in
 mprotect()
Message-ID: <20120904221641.GL3334@redhat.com>
References: <1346750457-12385-1-git-send-email-walken@google.com>
 <1346750457-12385-3-git-send-email-walken@google.com>
 <20120904142745.GE3334@redhat.com>
 <20120904215347.GA6769@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120904215347.GA6769@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: linux-mm@kvack.org, riel@redhat.com, peterz@infradead.org, hughd@google.com, daniel.santos@pobox.com, linux-kernel@vger.kernel.org, akpm@linux-foundation.org

On Tue, Sep 04, 2012 at 02:53:47PM -0700, Michel Lespinasse wrote:
> I think the minimal fix would actually be:
> 
>  	if (vma->anon_vma && (importer || start != vma->vm_start)) {
>  		anon_vma = vma->anon_vma;
> +	else if (next->anon_vma && adjust_next)
> +		anon_vma = next->anon_vma;

Right indeed. The last change required to the above is to check
adjust_next first.

> I suppose if we were to consider adding this fix to the stable series,
> we should probably do it in such a minimal way. I hadn't actually
> considered it, because I was only thinking about this patch series,
> and at patch 4/7 it becomes necessary to lock the anon_vma even if
> only the vm_end side gets modified (so we'd still end up with what I
> proposed in the end)

Ah, that fully explains you removed the optimization :). I was
reviewing the patch as a bugfix for upstream without noticing the
new requirements introduced by the later patches.

I would suggest to do the strict fix as above in as patch 1/8 and push
it in -mm, and to do only the optimization removal in 3/8. I think
we want it in -stable too later, so it'll make life easier to
cherry-pick the commit if it's merged independently.

Thanks!
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
