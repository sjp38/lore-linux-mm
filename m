Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id KAA24390
	for <linux-mm@kvack.org>; Tue, 22 Oct 2002 10:05:35 -0700 (PDT)
Message-ID: <3DB5855B.FD4CD26C@digeo.com>
Date: Tue, 22 Oct 2002 10:05:31 -0700
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: ZONE_NORMAL exhaustion (dcache slab)
References: <3DB4855F.D5DA002E@digeo.com> <Pine.LNX.4.44L.0210221428060.1648-100000@duckman.distro.conectiva>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: "Martin J. Bligh" <mbligh@aracnet.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> 
> On Mon, 21 Oct 2002, Andrew Morton wrote:
> 
> > He had 3 million dentries and only 100k pages on the LRU,
> > so we should have been reclaiming 60 dentries per scanned
> > page.
> >
> > Conceivably the multiply in shrink_slab() overflowed, where
> > we calculate local variable `delta'.  But doubtful.
> 
> What if there were no pages left to scan for shrink_caches ?

Historically, this causes an ints-off lockup, but I think we've
fixed all them now ;)

> Could it be possible that for some strange reason the machine
> ended up scanning 0 slab objects ?
> 
> 60 * 0 is still 0, after all ;)
> 

More by good luck than by good judgement, if there are zero inactive
pages in a zone we come out of shrink_caches with max_scan equal
to SWAP_CLUSTER_MAX*2.  So if all of a zone's pages are out in
pagetables/skbuffs/whatever we'll put a lot of pressure on slab.

Which is good.  But it'll do that even if the offending zone cannot
contain any slab, which is not so good, but not very serious in
practice.  Search for "FIXME"...
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
