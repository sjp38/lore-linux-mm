Date: Tue, 26 Mar 2002 17:42:36 +0100
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [patch] mmap bug with drivers that adjust vm_start
Message-ID: <20020326174236.B13052@dualathlon.random>
References: <20020325230046.A14421@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20020325230046.A14421@redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin LaHaise <bcrl@redhat.com>
Cc: Marcelo Tosatti <marcelo@conectiva.com.br>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 25, 2002 at 11:00:47PM -0500, Benjamin LaHaise wrote:
> Hello all,
> 
> The patch below fixes a problem whereby a vma which has its vm_start 
> address changed by the file's mmap operation can result in the vma 
> being inserted into the wrong location within the vma tree.  This 
> results in page faults not being handled correctly leading to SEGVs, 
> as well as various BUG()s hitting on exit of the mm.  The fix is to 
> recalculate the insertion point when we know the address has changed.  
> Comments?  Patch is against 2.4.19-pre4.

The patch is obviously safe.

However if the patch is needed it means the ->mmap also must do the
do_munmap stuff by hand internally, which is very ugly given we also did
our own do_munmap in a completly different region (the one requested by
the user). Our do_munmap should not happen if we place the mapping
elsewhere. If possible I would prefer to change those drivers to
advertise their enforced vm_start with a proper callback, the current
way is halfway broken still. BTW, which are those drivers, and why they
needs to enforce a certain vm_start (also despite MAP_FIXED that they
cannot check within the ->mmap callback)?

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
