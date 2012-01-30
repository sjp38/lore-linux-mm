Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 281A16B004D
	for <linux-mm@kvack.org>; Mon, 30 Jan 2012 14:16:25 -0500 (EST)
Received: by mail-wi0-f177.google.com with SMTP id o1so4819632wic.22
        for <linux-mm@kvack.org>; Mon, 30 Jan 2012 11:16:24 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.00.1201271458130.3402@eggly.anvils>
References: <1327557574-6125-1-git-send-email-roland@kernel.org>
 <alpine.LSU.2.00.1201261133230.1369@eggly.anvils> <CAG4TOxNEV2VY9wOE86p9RnKGqpruB32ci9Wq3yBt8O2zc7f05w@mail.gmail.com>
 <alpine.LSU.2.00.1201271458130.3402@eggly.anvils>
From: Roland Dreier <roland@kernel.org>
Date: Mon, 30 Jan 2012 11:16:04 -0800
Message-ID: <CAL1RGDXqguZ2QKV=yjLXtk2n_Ag4Nf3CW+kF2BFQFR4ySTNaRA@mail.gmail.com>
Subject: Re: [PATCH/RFC G-U-P experts] IB/umem: Modernize our get_user_pages() parameters
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: linux-rdma@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Jan 27, 2012 at 6:19 PM, Hugh Dickins <hughd@google.com> wrote:
>> > > This patch comes from me trying to do userspace RDMA on a memory
>> > > region exported from a character driver and mapped with
>> > >
>> > > =A0 =A0 mmap(... PROT_READ, MAP_PRIVATE ...)
>
> Why MAP_PRIVATE? =A0There you are explicitly asking for COW: okay,
> you wouldn't normally expect any COW while it's just PROT_READ, but
> once you bring GUP into the picture, with use of write and force,
> then you are just begging for COW with that MAP_PRIVATE. =A0Please
> change it to MAP_SHARED - any reason why not?

I have no idea of the history there... probably could be changed with
no problems.

However, get_user_pages has this comment:

 * @force:	whether to force write access even if user mapping is
 *		readonly. This will result in the page being COWed even
 *		in MAP_SHARED mappings. You do not want this.

but I don't see where in the code FOLL_FORCE does COW
for MAP_SHARED mappings.  But on the OTOH I don't see
why we set force in the first place.  Why wouldn't we respect
the user's mapping permissions.

> I feel you're trying to handle two very different cases (rdma into
> user-supplied anonymous memory, and exporting driver memory to the
> user) with the same set of args to get_user_pages(). =A0In fact, I
> don't even see why you need get_user_pages() at all when exporting
> driver memory to the user. =A0Ah, perhaps you don't, but you do want
> your standard access method (which already involves GUP) not to
> mess up when applied to such a mapping - is that it?

Exactly.  Right now we have the libibverbs userspace API, which
basically lets userspace create an abstract "memory region" (MR)
that is then given to the RDMA hardware to do IO on.  Userspace does

    mr =3D ibv_reg_mr(..., buf, size, access_flags);

where access flags say whether we're going to let the hardware
read and/or write the memory.

Ideally userspace should not have to know where the memory
underlying its "buf" came from or what type of mapping it is.

Certainly there are still more unresolved issues around the case
where userspace wants to map, say, part of a GPUs PCI memory
(which won't have any underlying page structs at all), but I'm at
least hoping we can come up with a way to handle both anonymous
private maps (which will be COWed from the zero page when
the memory is touched for writing) and shared mappings of kernel
memory exported by a driver's mmap method.


So I guess I'm left thinking that it seems at least plausible that
what we want is a new FOLL_ flag for __get_user_pages() that triggers
COW exactly on the pages that userspace might trigger COW on,
and avoids COW otherwise -- ie do FOLL_WRITE exactly for the
pages that have VM_WRITE in their mapping.

I don't think we want to do the "force" semantics or deal with the
VM_MAYWRITE possiblity -- the access we give the hardware on
behalf of userspace should just match the access that userspace
actually has.  It seems that if we don't try to get pages for writing
when VM_WRITE isn't set, we don't need force anymore.

 - R.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
