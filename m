Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f176.google.com (mail-qc0-f176.google.com [209.85.216.176])
	by kanga.kvack.org (Postfix) with ESMTP id 30B6C28000D
	for <linux-mm@kvack.org>; Mon, 10 Nov 2014 17:58:27 -0500 (EST)
Received: by mail-qc0-f176.google.com with SMTP id x3so6653262qcv.35
        for <linux-mm@kvack.org>; Mon, 10 Nov 2014 14:58:26 -0800 (PST)
Received: from mail-qg0-x22e.google.com (mail-qg0-x22e.google.com. [2607:f8b0:400d:c04::22e])
        by mx.google.com with ESMTPS id ia3si29878985qcb.22.2014.11.10.14.58.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 10 Nov 2014 14:58:26 -0800 (PST)
Received: by mail-qg0-f46.google.com with SMTP id i50so6217864qgf.19
        for <linux-mm@kvack.org>; Mon, 10 Nov 2014 14:58:26 -0800 (PST)
Date: Mon, 10 Nov 2014 17:58:22 -0500
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: [PATCH 3/5] lib: lockless generic and arch independent page
 table (gpt) v2.
Message-ID: <20141110225821.GC4186@gmail.com>
References: <1415644096-3513-1-git-send-email-j.glisse@gmail.com>
 <1415644096-3513-4-git-send-email-j.glisse@gmail.com>
 <CA+55aFwHd4QYopHvd=H6hxoQeqDV3HT6=436LGU-FRb5A0p7Vg@mail.gmail.com>
 <20141110205814.GA4186@gmail.com>
 <CA+55aFwwKV_D5oWT6a97a70G7OnvsPD_j9LsuR+_e4MEdCOO9A@mail.gmail.com>
 <CA+55aFyh1ZOuLZw5Vb_ZTYhSsbwdqRFOceYSj7nh02NmKxy4AQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CA+55aFyh1ZOuLZw5Vb_ZTYhSsbwdqRFOceYSj7nh02NmKxy4AQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Joerg Roedel <joro@8bytes.org>, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Oded Gabbay <Oded.Gabbay@amd.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>

On Mon, Nov 10, 2014 at 01:47:01PM -0800, Linus Torvalds wrote:
> On Mon, Nov 10, 2014 at 1:35 PM, Linus Torvalds
> <torvalds@linux-foundation.org> wrote:
> >
> > Or do you actually have a setup where actual non-CPU hardware actually
> > walks the page tables you create and call "page tables"?
> 
> So just to clarify: I haven't looked at all your follow-up patches at
> all, although I've seen the overviews in earlier versions. When trying
> to read through the latest version, I got stuck on this one, and felt
> it was crazy.
> 
> But maybe I'm misreading it and it actually has good reasons for it.
> But just from the details I look at, some of it looks too incestuous
> with the system (the split PTL lock use), other parts look really
> really odd (like the 64-bit shift counts), and some of it looks just
> plain buggy (the bitops for synchronization). And none of it is all
> that easy to actually read.

I hope my other emails explained the motivation for all this. The PTL
because update will happen concurrently as CPU page table update and
as CPU page table update i want the same kind of concurrency btw update
to disjoint address.

For 64bit shift and count i explained it is because some hw will have
a 64bit entry format for the page table no matter what arch they are
on (64bit hw page table on x86 32bit page table).

For bitop they are not use for synchronization but as flag inside a
single CPU thread and never share among different thread. This are
not synchronization point.


Sadly no matter how we wish code that is clear in our mind does not
necessarily end up as clear for other and i know the whole macro
things does not make this any easier. As i said the v1 is a non macro
version but it does pre-compute more things inside init and use more
of this precomputed value as parameter for CPU walk down.

Cheers,
Jerome

> 
>                         Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
