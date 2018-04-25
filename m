Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 97A7A6B000E
	for <linux-mm@kvack.org>; Wed, 25 Apr 2018 11:25:12 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id h135so1367384qke.10
        for <linux-mm@kvack.org>; Wed, 25 Apr 2018 08:25:12 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id a16si1312664qvj.58.2018.04.25.08.25.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Apr 2018 08:25:11 -0700 (PDT)
Date: Wed, 25 Apr 2018 11:25:09 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: vmalloc with GFP_NOFS
In-Reply-To: <20180425144557.GD17484@dhcp22.suse.cz>
Message-ID: <alpine.LRH.2.02.1804251114120.11848@file01.intranet.prod.int.rdu2.redhat.com>
References: <20180424162712.GL17484@dhcp22.suse.cz> <3732370.1623zxSvNg@blindfold> <20180424192803.GT17484@dhcp22.suse.cz> <3894056.cxOY6eVYVp@blindfold> <20180424230943.GY17484@dhcp22.suse.cz> <alpine.LRH.2.02.1804241911040.19786@file01.intranet.prod.int.rdu2.redhat.com>
 <20180424232517.GC17484@dhcp22.suse.cz> <alpine.LRH.2.02.1804250841230.16455@file01.intranet.prod.int.rdu2.redhat.com> <20180425144557.GD17484@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Richard Weinberger <richard@nod.at>, LKML <linux-kernel@vger.kernel.org>, Artem Bityutskiy <dedekind1@gmail.com>, David Woodhouse <dwmw2@infradead.org>, Brian Norris <computersforpeace@gmail.com>, Boris Brezillon <boris.brezillon@free-electrons.com>, Marek Vasut <marek.vasut@gmail.com>, Cyrille Pitchen <cyrille.pitchen@wedev4u.fr>, Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Steven Whitehouse <swhiteho@redhat.com>, Bob Peterson <rpeterso@redhat.com>, Trond Myklebust <trond.myklebust@primarydata.com>, Anna Schumaker <anna.schumaker@netapp.com>, Adrian Hunter <adrian.hunter@intel.com>, Philippe Ombredanne <pombredanne@nexb.com>, Kate Stewart <kstewart@linuxfoundation.org>, linux-mtd@lists.infradead.org, linux-ext4@vger.kernel.org, cluster-devel@redhat.com, linux-nfs@vger.kernel.org, linux-mm@kvack.org



On Wed, 25 Apr 2018, Michal Hocko wrote:

> On Wed 25-04-18 08:43:32, Mikulas Patocka wrote:
> > 
> > 
> > On Tue, 24 Apr 2018, Michal Hocko wrote:
> > 
> > > On Tue 24-04-18 19:17:12, Mikulas Patocka wrote:
> > > > 
> > > > 
> > > > On Tue, 24 Apr 2018, Michal Hocko wrote:
> > > > 
> > > > > > So in a perfect world a filesystem calls memalloc_nofs_save/restore and
> > > > > > always uses GFP_KERNEL for kmalloc/vmalloc?
> > > > > 
> > > > > Exactly! And in a dream world those memalloc_nofs_save act as a
> > > > > documentation of the reclaim recursion documentation ;)
> > > > > -- 
> > > > > Michal Hocko
> > > > > SUSE Labs
> > > > 
> > > > BTW. should memalloc_nofs_save and memalloc_noio_save be merged into just 
> > > > one that prevents both I/O and FS recursion?
> > > 
> > > Why should FS usage stop IO altogether?
> > 
> > Because the IO may reach loop and loop may redirect it to the same 
> > filesystem that is running under memalloc_nofs_save and deadlock.
> 
> So what is the difference with the current GFP_NOFS?

My point is that filesystems should use GFP_NOIO too. If 
alloc_pages(GFP_NOFS) issues some random I/O to some block device, the I/O 
may be end up being redirected (via block loop device) to the filesystem 
that is calling alloc_pages(GFP_NOFS).

> > > > memalloc_nofs_save allows submitting bios to I/O stack and the bios 
> > > > created under memalloc_nofs_save could be sent to the loop device and the 
> > > > loop device calls the filesystem...
> > > 
> > > Don't those use NOIO context?
> > 
> > What do you mean?
> 
> That the loop driver should make sure it will not recurse. The scope API
> doesn't add anything new here.

The loop driver doesn't recurse. The loop driver will add the request to a 
queue and wake up a thread that processes it. But if the request queue is 
full, __get_request will wait until the loop thread finishes processing 
some other request.

It doesn't recurse, but it waits until the filesystem makes some progress.

Mikulas
