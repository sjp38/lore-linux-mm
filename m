Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1FB879000C2
	for <linux-mm@kvack.org>; Tue, 12 Jul 2011 18:35:59 -0400 (EDT)
Received: from wpaz33.hot.corp.google.com (wpaz33.hot.corp.google.com [172.24.198.97])
	by smtp-out.google.com with ESMTP id p6CMZu2Z022271
	for <linux-mm@kvack.org>; Tue, 12 Jul 2011 15:35:56 -0700
Received: from iwn39 (iwn39.prod.google.com [10.241.68.103])
	by wpaz33.hot.corp.google.com with ESMTP id p6CMZs76032649
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 12 Jul 2011 15:35:54 -0700
Received: by iwn39 with SMTP id 39so5040624iwn.3
        for <linux-mm@kvack.org>; Tue, 12 Jul 2011 15:35:54 -0700 (PDT)
Date: Tue, 12 Jul 2011 15:35:41 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 2/12] mm: let swap use exceptional entries
In-Reply-To: <20110618145546.12e175bf.akpm@linux-foundation.org>
Message-ID: <alpine.LSU.2.00.1107121509230.2112@sister.anvils>
References: <alpine.LSU.2.00.1106140327550.29206@sister.anvils> <alpine.LSU.2.00.1106140342330.29206@sister.anvils> <20110618145546.12e175bf.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sat, 18 Jun 2011, Andrew Morton wrote:
> On Tue, 14 Jun 2011 03:43:47 -0700 (PDT) Hugh Dickins <hughd@google.com> wrote:
> 
> > In an i386 kernel this limits its information (type and page offset)
> > to 30 bits: given 32 "types" of swapfile and 4kB pagesize, that's
> > a maximum swapfile size of 128GB.  Which is less than the 512GB we
> > previously allowed with X86_PAE (where the swap entry can occupy the
> > entire upper 32 bits of a pte_t), but not a new limitation on 32-bit
> > without PAE; and there's not a new limitation on 64-bit (where swap
> > filesize is already limited to 16TB by a 32-bit page offset).
> 
> hm.
> 
> >  Thirty
> > areas of 128GB is probably still enough swap for a 64GB 32-bit machine.
> 
> What if it was only one area?  128GB is close enough to 64GB (or, more
> realistically, 32GB) to be significant.  For the people out there who
> are using a single 200GB swap partition and actually needed that much,
> what happens?  swapon fails?

No, it doesn't fail: it just trims back the amount of swap that is used
(and counted) to the maximum that the running kernel supports (just like
when you switch between 64bit and 32bit-PAE and 32bit-nonPAE kernels
using the same large swap device, the 64bit being able to access more
of it than the 32bit-PAE kernel, and that more than the 32bit-nonPAE).

I'd grown to think that the users of large amounts of RAM may like to
have a little swap for leeway, but live in dread of the slow death that a
large amount of swap can result in.  Maybe that's just one class of user.

I'd worry more about this if it were a new limitation for 64bit; but it's
just a lower limitation for the 32bit-PAE case.  If it actually proves
to be an issue (and we abandon our usual mantra to go to 64bit), then I
don't think having 32 distinct areas is sacrosanct: we can (configurably
or tunably) lower the number of areas and increase their size; but I
doubt we shall need to bother.

ARM is getting LPAE?  Then I guess this is a good moment to enforce
the new limit.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
