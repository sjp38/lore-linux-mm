From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14546.9883.575748.695740@dukat.scot.redhat.com>
Date: Fri, 17 Mar 2000 12:35:39 +0000 (GMT)
Subject: Re: [patch] first bit of vm balancing fixes for 2.3.52-1
In-Reply-To: <Pine.LNX.4.21.0003131743410.6254-100000@devserv.devel.redhat.com>
References: <Pine.LNX.4.21.0003131743410.6254-100000@devserv.devel.redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ben LaHaise <bcrl@redhat.com>
Cc: linux-mm@kvack.org, torvalds@transmeta.com, Stephen Tweedie <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, 13 Mar 2000 17:50:50 -0500 (EST), Ben LaHaise <bcrl@redhat.com>
said:

> This is the first little bit of a few vm balancing patches I've been
> working on.  

Just out of interest, is anyone working on fixing the zone balancing?

The current behaviour is highly suboptimal: if you have two zones to
pick from for a given alloc_page(), and the first zone is at its
pages_min threshold, then we will always allocate from that first zone
and push it into kswap activation no matter how much free space there is
in the next zone.

The net effect of this is that we may not _ever_ end up using the next
zone for allocations if the request trickle in slowly enough; and that
either way, the memory use between the two zones is unbalanced.  On an
8GB box it may be reasonable to keep the lomem zone for non-himem
allocations, but on 2GB we probably want to allocate page cache and user
pages as fairly as possible above and below 1GB.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
