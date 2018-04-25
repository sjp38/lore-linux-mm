Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id EED316B0003
	for <linux-mm@kvack.org>; Wed, 25 Apr 2018 08:43:37 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id k22-v6so17401554qtm.4
        for <linux-mm@kvack.org>; Wed, 25 Apr 2018 05:43:37 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id l28-v6si17292493qta.188.2018.04.25.05.43.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Apr 2018 05:43:37 -0700 (PDT)
Date: Wed, 25 Apr 2018 08:43:32 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: vmalloc with GFP_NOFS
In-Reply-To: <20180424232517.GC17484@dhcp22.suse.cz>
Message-ID: <alpine.LRH.2.02.1804250841230.16455@file01.intranet.prod.int.rdu2.redhat.com>
References: <20180424162712.GL17484@dhcp22.suse.cz> <3732370.1623zxSvNg@blindfold> <20180424192803.GT17484@dhcp22.suse.cz> <3894056.cxOY6eVYVp@blindfold> <20180424230943.GY17484@dhcp22.suse.cz> <alpine.LRH.2.02.1804241911040.19786@file01.intranet.prod.int.rdu2.redhat.com>
 <20180424232517.GC17484@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Richard Weinberger <richard@nod.at>, LKML <linux-kernel@vger.kernel.org>, Artem Bityutskiy <dedekind1@gmail.com>, David Woodhouse <dwmw2@infradead.org>, Brian Norris <computersforpeace@gmail.com>, Boris Brezillon <boris.brezillon@free-electrons.com>, Marek Vasut <marek.vasut@gmail.com>, Cyrille Pitchen <cyrille.pitchen@wedev4u.fr>, Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Steven Whitehouse <swhiteho@redhat.com>, Bob Peterson <rpeterso@redhat.com>, Trond Myklebust <trond.myklebust@primarydata.com>, Anna Schumaker <anna.schumaker@netapp.com>, Adrian Hunter <adrian.hunter@intel.com>, Philippe Ombredanne <pombredanne@nexb.com>, Kate Stewart <kstewart@linuxfoundation.org>, linux-mtd@lists.infradead.org, linux-ext4@vger.kernel.org, cluster-devel@redhat.com, linux-nfs@vger.kernel.org, linux-mm@kvack.org



On Tue, 24 Apr 2018, Michal Hocko wrote:

> On Tue 24-04-18 19:17:12, Mikulas Patocka wrote:
> > 
> > 
> > On Tue, 24 Apr 2018, Michal Hocko wrote:
> > 
> > > On Wed 25-04-18 00:18:40, Richard Weinberger wrote:
> > > > Am Dienstag, 24. April 2018, 21:28:03 CEST schrieb Michal Hocko:
> > > > > > Also only for debugging.
> > > > > > Getting rid of vmalloc with GFP_NOFS in UBIFS is no big problem.
> > > > > > I can prepare a patch.
> > > > > 
> > > > > Cool!
> > > > > 
> > > > > Anyway, if UBIFS has some reclaim recursion critical sections in general
> > > > > it would be really great to have them documented and that is where the
> > > > > scope api is really handy. Just add the scope and document what is the
> > > > > recursion issue. This will help people reading the code as well. Ideally
> > > > > there shouldn't be any explicit GFP_NOFS in the code.
> > > > 
> > > > So in a perfect world a filesystem calls memalloc_nofs_save/restore and
> > > > always uses GFP_KERNEL for kmalloc/vmalloc?
> > > 
> > > Exactly! And in a dream world those memalloc_nofs_save act as a
> > > documentation of the reclaim recursion documentation ;)
> > > -- 
> > > Michal Hocko
> > > SUSE Labs
> > 
> > BTW. should memalloc_nofs_save and memalloc_noio_save be merged into just 
> > one that prevents both I/O and FS recursion?
> 
> Why should FS usage stop IO altogether?

Because the IO may reach loop and loop may redirect it to the same 
filesystem that is running under memalloc_nofs_save and deadlock.

> > memalloc_nofs_save allows submitting bios to I/O stack and the bios 
> > created under memalloc_nofs_save could be sent to the loop device and the 
> > loop device calls the filesystem...
> 
> Don't those use NOIO context?

What do you mean?

Mikulas
