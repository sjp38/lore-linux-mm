Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 874666B002C
	for <linux-mm@kvack.org>; Wed,  8 Feb 2012 18:10:49 -0500 (EST)
Received: by dadv6 with SMTP id v6so1114237dad.14
        for <linux-mm@kvack.org>; Wed, 08 Feb 2012 15:10:48 -0800 (PST)
Date: Wed, 8 Feb 2012 15:10:17 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH/RFC G-U-P experts] IB/umem: Modernize our get_user_pages()
 parameters
In-Reply-To: <alpine.LSU.2.00.1202071225250.2024@eggly.anvils>
Message-ID: <alpine.LSU.2.00.1202081446110.1320@eggly.anvils>
References: <1327557574-6125-1-git-send-email-roland@kernel.org> <alpine.LSU.2.00.1201261133230.1369@eggly.anvils> <CAG4TOxNEV2VY9wOE86p9RnKGqpruB32ci9Wq3yBt8O2zc7f05w@mail.gmail.com> <alpine.LSU.2.00.1201271458130.3402@eggly.anvils>
 <CAL1RGDXqguZ2QKV=yjLXtk2n_Ag4Nf3CW+kF2BFQFR4ySTNaRA@mail.gmail.com> <alpine.LSU.2.00.1201301217530.4505@eggly.anvils> <CAL1RGDVSBb1DVsfvuz=ijRZX06crsqQfKoXWJ+6FO4xi3aYyTg@mail.gmail.com> <alpine.LSU.2.00.1202071225250.2024@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roland Dreier <roland@kernel.org>
Cc: linux-rdma@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 7 Feb 2012, Hugh Dickins wrote:
> On Mon, 6 Feb 2012, Roland Dreier wrote:
> > Which I think explains why the code is the way it is.  But clearly
> > we could do better if we had a better way of telling GUP our real
> > intentions -- ie the FOLL_READONLY_COW flag.
> 
> You've persuaded me.  Yes, you have been using force because that was
> the only tool available at the time, to get close to the sensible
> behaviour you are now asking for.
> 
> > 
> > > Can you, for example, enforce the permissions set up by the user?
> > > I mean, if they do the ibv_reg_mr() on a private readonly area,
> > > so __get_user_pages with the FOLL_APPROPRIATELY flag will fault
> > > in ZERO_PAGEs, can you enforce that RDMA will never spray data
> > > into those pages?
> > 
> > Yes, the access flags passed into ibv_reg_mr() are enforced by
> > the RDMA hardware, so if no write access is request, no write
> > access is possible.
> 
> Okay, if you enforce the agreed permissions in hardware, that's fine.

A doubt assaulted me overnight: sorry, I'm back to not understanding.

What are these access flags passed into ibv_reg_mr() that are enforced?
What relation do they bear to what you will pass to __get_user_pages()?

You are asking for a FOLL_FOLLOW ("follow permissions of the vma") flag,
which automatically works for read-write access to a VM_READ|VM_WRITE vma,
but read-only access to a VM_READ-only vma, without you having to know
which permission applies to which range of memory in the area specified.

But you don't need that new flag to set up read-only access, and if you
use that new flag to set up read-write access to an area which happens to
contain VM_READ-only ranges, you have set it up to write into ZERO_PAGEs.

?Hugh?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
