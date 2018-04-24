Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3A6FF6B0006
	for <linux-mm@kvack.org>; Tue, 24 Apr 2018 13:05:28 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id u9-v6so15290398qtg.2
        for <linux-mm@kvack.org>; Tue, 24 Apr 2018 10:05:28 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id 19-v6si18542763qts.253.2018.04.24.10.05.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Apr 2018 10:05:27 -0700 (PDT)
Date: Tue, 24 Apr 2018 13:05:25 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: vmalloc with GFP_NOFS
In-Reply-To: <20180424165532.GO17484@dhcp22.suse.cz>
Message-ID: <alpine.LRH.2.02.1804241300430.28995@file01.intranet.prod.int.rdu2.redhat.com>
References: <20180424162712.GL17484@dhcp22.suse.cz> <alpine.LRH.2.02.1804241240120.27049@file01.intranet.prod.int.rdu2.redhat.com> <20180424165532.GO17484@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Artem Bityutskiy <dedekind1@gmail.com>, Richard Weinberger <richard@nod.at>, David Woodhouse <dwmw2@infradead.org>, Brian Norris <computersforpeace@gmail.com>, Boris Brezillon <boris.brezillon@free-electrons.com>, Marek Vasut <marek.vasut@gmail.com>, Cyrille Pitchen <cyrille.pitchen@wedev4u.fr>, Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Steven Whitehouse <swhiteho@redhat.com>, Bob Peterson <rpeterso@redhat.com>, Trond Myklebust <trond.myklebust@primarydata.com>, Anna Schumaker <anna.schumaker@netapp.com>, Adrian Hunter <adrian.hunter@intel.com>, Philippe Ombredanne <pombredanne@nexb.com>, Kate Stewart <kstewart@linuxfoundation.org>, linux-mtd@lists.infradead.org, linux-ext4@vger.kernel.org, cluster-devel@redhat.com, linux-nfs@vger.kernel.org, linux-mm@kvack.org



On Tue, 24 Apr 2018, Michal Hocko wrote:

> On Tue 24-04-18 12:46:55, Mikulas Patocka wrote:
> > 
> > 
> > On Tue, 24 Apr 2018, Michal Hocko wrote:
> > 
> > > Hi,
> > > it seems that we still have few vmalloc users who perform GFP_NOFS
> > > allocation:
> > > drivers/mtd/ubi/io.c
> > > fs/ext4/xattr.c
> > > fs/gfs2/dir.c
> > > fs/gfs2/quota.c
> > > fs/nfs/blocklayout/extent_tree.c
> > > fs/ubifs/debug.c
> > > fs/ubifs/lprops.c
> > > fs/ubifs/lpt_commit.c
> > > fs/ubifs/orphan.c
> > > 
> > > Unfortunatelly vmalloc doesn't suppoer GFP_NOFS semantinc properly
> > > because we do have hardocded GFP_KERNEL allocations deep inside the
> > > vmalloc layers. That means that if GFP_NOFS really protects from
> > > recursion into the fs deadlocks then the vmalloc call is broken.
> > > 
> > > What to do about this? Well, there are two things. Firstly, it would be
> > > really great to double check whether the GFP_NOFS is really needed. I
> > > cannot judge that because I am not familiar with the code. It would be
> > > great if the respective maintainers (hopefully get_maintainer.sh pointed
> > > me to all relevant ones). If there is not reclaim recursion issue then
> > > simply use the standard vmalloc (aka GFP_KERNEL request).
> > > 
> > > If the use is really valid then we have a way to do the vmalloc
> > > allocation properly. We have memalloc_nofs_{save,restore} scope api. How
> > > does that work? You simply call memalloc_nofs_save when the reclaim
> > > recursion critical section starts (e.g. when you take a lock which is
> > > then used in the reclaim path - e.g. shrinker) and memalloc_nofs_restore
> > > when the critical section ends. _All_ allocations within that scope
> > > will get GFP_NOFS semantic automagically. If you are not sure about the
> > > scope itself then the easiest workaround is to wrap the vmalloc itself
> > > with a big fat comment that this should be revisited.
> > > 
> > > Does that sound like something that can be done in a reasonable time?
> > > I have tried to bring this up in the past but our speed is glacial and
> > > there are attempts to do hacks like checking for abusers inside the
> > > vmalloc which is just too ugly to live.
> > > 
> > > Please do not hesitate to get back to me if something is not clear.
> > > 
> > > Thanks!
> > > -- 
> > > Michal Hocko
> > > SUSE Labs
> > 
> > I made a patch that adds memalloc_noio/fs_save around these calls a year 
> > ago: http://lkml.iu.edu/hypermail/linux/kernel/1707.0/01376.html
> 
> Yeah, and that is the wrong approach.

It is crude, but it fixes the deadlock possibility. Then, the maintainers 
will have a lot of time to refactor the code and move these 
memalloc_noio_save calls to the proper scope.

> Let's try to fix this properly
> this time. As the above outlines, the worst case we can end up mid-term
> would be to wrap vmalloc calls with the scope api with a TODO. But I am
> pretty sure the respective maintainers can come up with a better
> solution. I am definitely willing to help here.
> -- 
> Michal Hocko
> SUSE Labs

Mikulas
