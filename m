Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 0C1BD6B13F0
	for <linux-mm@kvack.org>; Mon,  6 Feb 2012 12:40:02 -0500 (EST)
Received: by mail-we0-f182.google.com with SMTP id m13so7144879wer.13
        for <linux-mm@kvack.org>; Mon, 06 Feb 2012 09:40:02 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.00.1201301217530.4505@eggly.anvils>
References: <1327557574-6125-1-git-send-email-roland@kernel.org>
 <alpine.LSU.2.00.1201261133230.1369@eggly.anvils> <CAG4TOxNEV2VY9wOE86p9RnKGqpruB32ci9Wq3yBt8O2zc7f05w@mail.gmail.com>
 <alpine.LSU.2.00.1201271458130.3402@eggly.anvils> <CAL1RGDXqguZ2QKV=yjLXtk2n_Ag4Nf3CW+kF2BFQFR4ySTNaRA@mail.gmail.com>
 <alpine.LSU.2.00.1201301217530.4505@eggly.anvils>
From: Roland Dreier <roland@kernel.org>
Date: Mon, 6 Feb 2012 09:39:42 -0800
Message-ID: <CAL1RGDVSBb1DVsfvuz=ijRZX06crsqQfKoXWJ+6FO4xi3aYyTg@mail.gmail.com>
Subject: Re: [PATCH/RFC G-U-P experts] IB/umem: Modernize our get_user_pages() parameters
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: linux-rdma@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Sorry for the slow reply, I got caught in other business...

On Mon, Jan 30, 2012 at 12:34 PM, Hugh Dickins <hughd@google.com> wrote:
> The hardest part about implementing that is deciding what snappy
> name to give the FOLL_ flag.

Yes... FOLL_SOFT_COW ?  FOLL_READONLY_COW ?
(plus a good comment explaining it I guess)

>> I don't think we want to do the "force" semantics or deal with the
>> VM_MAYWRITE possiblity -- the access we give the hardware on
>> behalf of userspace should just match the access that userspace
>> actually has. =A0It seems that if we don't try to get pages for writing
>> when VM_WRITE isn't set, we don't need force anymore.
>
> I suspect you never needed or wanted the weird force behaviour on
> shared maywrite, but that you did need the force COW behaviour on
> private currently-unwritable maywrite. =A0You (or your forebears)
> defined that interface to use the force flag, I'm guessing it was
> for a reason; now you want to change it not to use the force flag,
> and it sounds good, but I'm afraid you'll discover down the line
> what the force flag was for.

Actually I think I understand why the original code passed !write
as the force parameter.

If the user is registering memory with read-only access, there are
two common cases.  Possibly the underlying memory really has
a read-only mapping, but probably more often it is just an ordinary
buffer allocated in userspace with malloc() or the like.

In the second case, it's quite likely we have a read/write mapping
of anonymous pages.  We'll expose it read-only for RDMA but the
userspace process will write data into the memory via ordinary CPU
access.  However, if we do ibv_reg_mr() before initializing the memory
it's quite possible that the mapping actually points to the zero page,
waiting for a CPU write to trigger a COW.

So in the second case, doing GUP without the write flag will leave
the COW untriggered, and we'll end up mapping the zero page to
the hardware, and RDMA won't read the data that userspace actually
writes.  So (without GUP extension as we're discussing in this thread)
we're forced to pass write=3D=3D1 to GUP, even if we expect hardware
to only do reads.

But if we pass write=3D=3D1, then GUP on the first case (mapping that
is genuinely read-only) will fail, unless we pass force=3D=3D1 too.  But
this should only succeed if we're going to only access the memory
read-only, so we should set force to !writable-access-by-rdma.

Which I think explains why the code is the way it is.  But clearly
we could do better if we had a better way of telling GUP our real
intentions -- ie the FOLL_READONLY_COW flag.

> Can you, for example, enforce the permissions set up by the user?
> I mean, if they do the ibv_reg_mr() on a private readonly area,
> so __get_user_pages with the FOLL_APPROPRIATELY flag will fault
> in ZERO_PAGEs, can you enforce that RDMA will never spray data
> into those pages?

Yes, the access flags passed into ibv_reg_mr() are enforced by
the RDMA hardware, so if no write access is request, no write
access is possible.

And presumably if we do GUP with write=3D=3D1, force=3D=3D0 that will
fail on a read-only mapping?

 - R.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
