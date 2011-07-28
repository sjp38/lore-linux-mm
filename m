Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 23DD16B0169
	for <linux-mm@kvack.org>; Thu, 28 Jul 2011 05:27:09 -0400 (EDT)
Received: from hpaq1.eem.corp.google.com (hpaq1.eem.corp.google.com [172.25.149.1])
	by smtp-out.google.com with ESMTP id p6S9R6vZ006979
	for <linux-mm@kvack.org>; Thu, 28 Jul 2011 02:27:06 -0700
Received: from gxk1 (gxk1.prod.google.com [10.202.11.1])
	by hpaq1.eem.corp.google.com with ESMTP id p6S9R2wE020463
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 28 Jul 2011 02:27:05 -0700
Received: by gxk1 with SMTP id 1so1790355gxk.38
        for <linux-mm@kvack.org>; Thu, 28 Jul 2011 02:27:02 -0700 (PDT)
Date: Thu, 28 Jul 2011 02:26:38 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 2/3] tmpfs radix_tree: locate_item to speed up swapoff
In-Reply-To: <alpine.LSU.2.00.1107271801450.9888@sister.anvils>
Message-ID: <alpine.LSU.2.00.1107280159480.4995@sister.anvils>
References: <alpine.LSU.2.00.1107191549540.1593@sister.anvils> <alpine.LSU.2.00.1107191553040.1593@sister.anvils> <20110727162819.b595e442.akpm@linux-foundation.org> <alpine.LSU.2.00.1107271801450.9888@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 27 Jul 2011, Hugh Dickins wrote:
> On Wed, 27 Jul 2011, Andrew Morton wrote:
> > On Tue, 19 Jul 2011 15:54:23 -0700 (PDT)
> > Hugh Dickins <hughd@google.com> wrote:
> > 
> > > But it was a shock to find swapoff of a 500MB file 20 times slower
> > > on my laptop, taking 10 minutes; and at that rate it significantly
> > > slows down my testing.
> > 
> > So it used to take half a minute?  That was already awful.
> > Why?  Was it IO-bound?  It doesn't sound like it.
> 
> No, not IO-bound at all.

I oversimplified: about 10 seconds of that was waiting for IO,
the rest (of 10 minutes or of half a minute) was cpu.  It's the cpu
part of it which the change of radix tree has affected, for the worse.

> > How much did that 10 minutes improve?
> 
> To 1 minute: still twice as slow as before.  I believe that's because of
> the smaller nodes and greater height of the generic radix tree.  I ought
> to experiment with a bigger RADIX_TREE_MAP_SHIFT to verify that belief
> (though I don't think tmpfs swapoff would justify raising it): will do.

Yes, raising RADIX_TREE_MAP_SHIFT from 6 to 10 (so on 32-bit the rnode
is just over 4kB, comparable with the old shmem's use of pages for this)
brings the time down considerably: still slower than before, but 12%
slower instead of twice as slow (or 20% slower instead of 3 times as
slow when comparing sys times).

Not that making a radix_tree_node need order:1 page would be sensible.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
