Received: from renko.ucs.ed.ac.uk (renko.ucs.ed.ac.uk [129.215.13.3])
	by kvack.org (8.8.7/8.8.7) with ESMTP id NAA06119
	for <linux-mm@kvack.org>; Thu, 23 Jul 1998 13:16:43 -0400
Date: Thu, 23 Jul 1998 18:09:41 +0100
Message-Id: <199807231709.SAA13482@dax.dcs.ed.ac.uk>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: Important - MM panic in 2.1.109 [PATCH + Oops]
In-Reply-To: <Pine.LNX.3.95.980722160724.440A-200000@mikeg.weiden.de>
References: <35AF3BC6.E316ED09@actcom.co.il>
	<Pine.LNX.3.95.980722160724.440A-200000@mikeg.weiden.de>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>, "Michael L. Galbraith" <mikeg@weiden.de>
Cc: Itai Nahshon <nahshon@actcom.co.il>, linux kernel list <linux-kernel@vger.rutgers.edu>, linux-mm@kvack.org, Stephen Tweedie <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, 22 Jul 1998 16:37:29 +0200 (MET DST), "Michael L. Galbraith"
<mikeg@weiden.de> said:

> On Fri, 17 Jul 1998, Itai Nahshon wrote:
>> 1. I sent a similar report some time ago.. the panic still happens.
>> The problem is when unmapping the last part (but not all) of
>> a segment acquired by shmget + shmat. Ref count goes down to 0
>> and then the segment is reused!!

Definitely reproducible, thanks.

> Hi Folks,

> I've attached an oops for _real_ hackers to examine. Patch follows.
> It should illuminate the problem, and at least does stop the oops.

> --- linux-2.1.111-pre1/ipc/shm.c.org	Wed Jul 22 13:07:27 1998
> +++ linux-2.1.111-pre1/ipc/shm.c	Wed Jul 22 15:56:50 1998
> @@ -626,7 +626,12 @@
>  	remove_attach(shp,shmd);  /* remove from shp->attaches */
> shp-> shm_lpid = current->pid;
> shp-> shm_dtime = CURRENT_TIME;
> -	if (--shp->shm_nattch <= 0 && shp->shm_perm.mode & SHM_DEST)
> +	/* FIXME: If vm_end = vm_start, we are doing unmap_fixup().
> +	 * This is very fragile and stupid.  It's also the best I
> +	 * could come up with without special casing unmap_fixup().
> +	 */
> +	if (--shp->shm_nattch <= 0 && shp->shm_perm.mode & SHM_DEST
> +			&& shmd->vm_end != shmd->vm_start)
>  		killseg (id);
>  }
 
This fixes the problem right enough.

However, there's an alternative fix in mm/mmap.c:

----------------------------------------------------------------
diff -u mm/mmap.c~ mm/mmap.c
--- mm/mmap.c~  Wed Jul 22 14:48:04 1998
+++ mm/mmap.c   Thu Jul 23 15:39:50 1998
@@ -421,16 +421,6 @@
                insert_vm_struct(current->mm, mpnt);
        }
 
-       /* Close the current area ... */
-       if (area->vm_ops && area->vm_ops->close) {
-               end = area->vm_end; /* save new end */
-               area->vm_end = area->vm_start;
-               area->vm_ops->close(area);
-               area->vm_end = end;
-       }
-       /* ... then reopen and reinsert. */
-       if (area->vm_ops && area->vm_ops->open)
-               area->vm_ops->open(area);
        insert_vm_struct(current->mm, area);
        return 1;
 }
----------------------------------------------------------------

This seems to be a far less messy way to deal with the underlying bug,
which arises due to the close then reopen of a vma if we unmap from one
end.  *Any* vm type which refcounts its objects will be hit by this
behaviour in unmap_fixup(), which lets the underlying mapped object's
refcount go to zero only to be brought back up to one via the same vma.

Currently the only user of vm->open and ->close is shm, and it is only
used as a reference counting mechanism.  If the reference count is not
being modified, then why should we call close/open at all, especially if
we don't even bother to supply the correct vm_start parameter to the
close call?

The oops is definitely eliminated by the second patch, although the
first one looks reasonable too.

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
