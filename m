Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id XAA05159
	for <linux-mm@kvack.org>; Mon, 21 Oct 2002 23:21:02 -0700 (PDT)
Message-ID: <3DB4EE4E.88311B7B@digeo.com>
Date: Mon, 21 Oct 2002 23:21:02 -0700
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: ZONE_NORMAL exhaustion (dcache slab)
References: <3DB4D20A.8A579516@digeo.com> <2629107186.1035240598@[10.10.2.3]>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: Rik van Riel <riel@conectiva.com.br>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

"Martin J. Bligh" wrote:
> 
> > Oh it's reproduceable OK.  Just run
> >
> >       make-teeny-files 7 7
> 
> Excellent - thanks for that ... will try it.

When it goes stupid, you can then run and kill some big memory-hog
to force reclaim of lots of highmem pages.   Once you've done that,
you can watch the inode cache fall away as the inodes which used
to have pagecache become reclaimable.
 
> > Maybe you didn't cat /dev/sda2 for long enough?
> 
> Well, it's a multi-gigabyte partition. IIRC, I just ran it until
> it died with "input/output error" ... which I assumed at the time
> was the end of the partition, but it should be able to find that
> without error, so maybe it just ran out of ZONE_NORMAL ;-)

Oh.  Well it should have just hit eof.  Maybe you have a dud
sector and it terminated early.

> > Perhaps we need to multiply the slab cache scanning pressure by the
> > slab occupancy.  That's simple to do.
> 
> That'd make a lot of sense (to me, at least). I presume you mean
> occupancy on a per-slab basis, not global.

It's already performing slab cache scanning proportional to
the size of the slab. Multiplied by the rate of page scanning.

But I'm thinking that this linear pressure isn't right
at either end of the scale, so it needs to become nonlinear - even
less pressure when there's little slab, and more pressure when
there's a lot.  So multiply the slab scanning ratio by
amount_of_slab/amount_of_normal_zone.   Maybe.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
