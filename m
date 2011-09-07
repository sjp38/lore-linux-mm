Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 1BC4D6B016A
	for <linux-mm@kvack.org>; Wed,  7 Sep 2011 07:26:11 -0400 (EDT)
Subject: Re: [PATCH 17/18] writeback: fix dirtied pages accounting on redirty
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Wed, 07 Sep 2011 10:19:47 +0200
In-Reply-To: <20110907065635.GA12619@lst.de>
References: <20110904015305.367445271@intel.com>
	 <20110904020916.841463184@intel.com> <1315325936.14232.22.camel@twins>
	 <20110907002222.GF31945@quack.suse.cz> <20110907065635.GA12619@lst.de>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Message-ID: <1315383587.11101.18.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Jan Kara <jack@suse.cz>, Wu Fengguang <fengguang.wu@intel.com>, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, 2011-09-07 at 08:56 +0200, Christoph Hellwig wrote:
> On Wed, Sep 07, 2011 at 02:22:22AM +0200, Jan Kara wrote:
> > > So wtf is ext4 doing? Shouldn't a page stay dirty until its written o=
ut?
> > >=20
> > > That is, should we really frob around this behaviour or fix ext4 beca=
use
> > > its on crack?
> >   Fengguang, could you please verify your findings with recent kernel? =
I
> > believe ext4 got fixed in this regard some time ago already (and yes, o=
ld
> > delalloc writeback code in ext4 was terrible).
>=20
> The pattern we do in writeback is:
>=20
> in pageout / write_cache_pages:
> 	lock_page();
> 	clear_page_dirty_for_io();
>=20
> in ->writepage:
> 	set_page_writeback();
> 	unlock_page();
> 	end_page_writeback();
>=20
> So whenever ->writepage decides it doesn't want to write things back
> we have to redirty pages.  We have this happen quite a bit in every
> filesystem, but ext4 hits it a lot more than usual because it refuses
> to write out delalloc pages from plain ->writepage and only allows
> ->writepages to do it.

Ah, right, so it is a fairly common thing and not something easily fixed
in filesystems.

Ok so I guess the patch is good. Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
