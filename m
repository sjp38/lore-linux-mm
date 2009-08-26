Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 90F776B004D
	for <linux-mm@kvack.org>; Wed, 26 Aug 2009 04:28:45 -0400 (EDT)
Date: Wed, 26 Aug 2009 10:27:41 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [Bug #14016] mm/ipw2200 regression
Message-ID: <20090826082741.GA25955@cmpxchg.org>
References: <riPp5fx5ECC.A.2IG.qsGlKB@chimera> <_yaHeGjHEzG.A.FIH.7sGlKB@chimera> <84144f020908252309u5cff8afdh2214577ca4db9b5d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <84144f020908252309u5cff8afdh2214577ca4db9b5d@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Kernel Testers List <kernel-testers@vger.kernel.org>, Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>, Mel Gorman <mel@skynet.ie>, Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

[Cc netdev]

On Wed, Aug 26, 2009 at 09:09:44AM +0300, Pekka Enberg wrote:
> On Tue, Aug 25, 2009 at 11:34 PM, Rafael J. Wysocki<rjw@sisk.pl> wrote:
> > This message has been generated automatically as a part of a report
> > of recent regressions.
> >
> > The following bug entry is on the current list of known regressions
> > from 2.6.30. A Please verify if it still should be listed and let me know
> > (either way).
> >
> > Bug-Entry A  A  A  : http://bugzilla.kernel.org/show_bug.cgi?id=14016
> > Subject A  A  A  A  : mm/ipw2200 regression
> > Submitter A  A  A  : Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>
> > Date A  A  A  A  A  A : 2009-08-15 16:56 (11 days old)
> > References A  A  A : http://marc.info/?l=linux-kernel&m=125036437221408&w=4
> 
> If am reading the page allocator dump correctly, there's plenty of
> pages left but we're unable to satisfy an order 6 allocation. There's
> no slab allocator involved so the page allocator changes that went
> into 2.6.31 seem likely. Mel, ideas?

It's an atomic order-6 allocation, the chances for this to succeed
after some uptime become infinitesimal.  The chunks > order-2 are
pretty much exhausted on this dump.

64 pages, presumably 256k, for fw->boot_size while current ipw
firmware images have ~188k.  I don't know jack squat about this
driver, but given the field name and the struct:

	struct ipw_fw {
		__le32 ver;
		__le32 boot_size;
		__le32 ucode_size;
		__le32 fw_size;
		u8 data[0];
	};

fw->boot_size alone being that big sounds a bit fishy to me.

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
