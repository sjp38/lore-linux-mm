Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f52.google.com (mail-wg0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id C79716B0031
	for <linux-mm@kvack.org>; Mon,  2 Jun 2014 05:14:32 -0400 (EDT)
Received: by mail-wg0-f52.google.com with SMTP id l18so4721107wgh.11
        for <linux-mm@kvack.org>; Mon, 02 Jun 2014 02:14:32 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w3si20358012wia.46.2014.06.02.02.14.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 02 Jun 2014 02:14:31 -0700 (PDT)
Date: Mon, 2 Jun 2014 11:14:27 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v2 0/3] File Sealing & memfd_create()
Message-ID: <20140602091427.GD3224@quack.suse.cz>
References: <1397587118-1214-1-git-send-email-dh.herrmann@gmail.com>
 <alpine.LSU.2.11.1405132118330.4401@eggly.anvils>
 <537396A2.9090609@cybernetics.com>
 <alpine.LSU.2.11.1405141456420.2268@eggly.anvils>
 <CANq1E4QgSbD9G70H7W4QeXbZ77_Kn1wV7edwzN4k4NjQJS=36A@mail.gmail.com>
 <20140602044259.GV10092@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140602044259.GV10092@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: David Herrmann <dh.herrmann@gmail.com>, Hugh Dickins <hughd@google.com>, Tony Battersby <tonyb@cybernetics.com>, Al Viro <viro@zeniv.linux.org.uk>, Jan Kara <jack@suse.cz>, Michael Kerrisk <mtk.manpages@gmail.com>, Ryan Lortie <desrt@desrt.ca>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-kernel <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Greg Kroah-Hartman <greg@kroah.com>, John Stultz <john.stultz@linaro.org>, Kristian Hogsberg <krh@bitplanet.net>, Lennart Poettering <lennart@poettering.net>, Daniel Mack <zonque@gmail.com>, Kay Sievers <kay@vrfy.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>

On Mon 02-06-14 13:42:59, Minchan Kim wrote:
> Hello,
> 
> On Mon, May 19, 2014 at 01:44:25PM +0200, David Herrmann wrote:
> > Hi
> > 
> > On Thu, May 15, 2014 at 12:35 AM, Hugh Dickins <hughd@google.com> wrote:
> > > The aspect which really worries me is this: the maintenance burden.
> > > This approach would add some peculiar new code, introducing a rare
> > > special case: which we might get right today, but will very easily
> > > forget tomorrow when making some other changes to mm.  If we compile
> > > a list of danger areas in mm, this would surely belong on that list.
> > 
> > I tried doing the page-replacement in the last 4 days, but honestly,
> > it's far more complex than I thought. So if no-one more experienced
> > with mm/ comes up with a simple implementation, I'll have to delay
> > this for some more weeks.
> > 
> > However, I still wonder why we try to fix this as part of this
> > patchset. Using FUSE, a DIRECT-IO call can be delayed for an arbitrary
> > amount of time. Same is true for network block-devices, NFS, iscsi,
> > maybe loop-devices, ... This means, _any_ once mapped page can be
> > written to after an arbitrary delay. This can break any feature that
> > makes FS objects read-only (remounting read-only, setting S_IMMUTABLE,
> > sealing, ..).
> > 
> > Shouldn't we try to fix the _cause_ of this?
> 
> I didn't follow this patchset and couldn't find what's your most cocern
> but at a first glance, it seems you have troubled with pinned page.
> If so, it's really big problem for CMA and I think peterz's approach(ie,
> mm_mpin) is really make sense to me.
  Well, his concern are pinned pages (and also pages used for direct IO and
similar) but not because they are pinned but because they can be modified
while someone holds reference to them. So I'm not sure Peter's patches will
help here.
 
> https://lkml.org/lkml/2014/5/26/340

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
