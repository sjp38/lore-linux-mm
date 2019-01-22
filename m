Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id D5FE28E0001
	for <linux-mm@kvack.org>; Tue, 22 Jan 2019 11:07:03 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id m19so9639799edc.6
        for <linux-mm@kvack.org>; Tue, 22 Jan 2019 08:07:03 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f7si192538eda.363.2019.01.22.08.07.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Jan 2019 08:07:02 -0800 (PST)
Date: Tue, 22 Jan 2019 17:07:01 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: no need to check return value of debugfs_create
 functions
Message-ID: <20190122160701.GK4087@dhcp22.suse.cz>
References: <20190122152151.16139-14-gregkh@linuxfoundation.org>
 <20190122153102.GJ4087@dhcp22.suse.cz>
 <20190122155255.GA20142@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190122155255.GA20142@kroah.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Laura Abbott <labbott@redhat.com>, linux-mm@kvack.org

On Tue 22-01-19 16:52:55, Greg KH wrote:
> On Tue, Jan 22, 2019 at 04:31:02PM +0100, Michal Hocko wrote:
> > On Tue 22-01-19 16:21:13, Greg KH wrote:
> > [...]
> > > diff --git a/mm/memblock.c b/mm/memblock.c
> > > index 022d4cbb3618..18ee657fb918 100644
> > > --- a/mm/memblock.c
> > > +++ b/mm/memblock.c
> > > @@ -1998,8 +1998,7 @@ DEFINE_SHOW_ATTRIBUTE(memblock_debug);
> > >  static int __init memblock_init_debugfs(void)
> > >  {
> > >  	struct dentry *root = debugfs_create_dir("memblock", NULL);
> > > -	if (!root)
> > > -		return -ENXIO;
> > > +
> > >  	debugfs_create_file("memory", 0444, root,
> > >  			    &memblock.memory, &memblock_debug_fops);
> > >  	debugfs_create_file("reserved", 0444, root,
> > 
> > I haven't really read the whole patch but this has just hit my eyes. Is
> > this a correct behavior?
> > 
> > Documentations says:
> >  * @parent: a pointer to the parent dentry for this file.  This should be a
> >  *          directory dentry if set.  If this parameter is NULL, then the
> >  *          file will be created in the root of the debugfs filesystem.
> > 
> > so in case of failure we would get those debugfs files outside of their
> > intended scope. I believe it is much more correct to simply not create
> > anything, no?
> 
> If debugfs_create_dir() returns NULL, then something is really wrong
> (you passed it an invalid pointer as the parent dentry, or free memory
> is gone), so there's nothing you can do except keep moving forward and
> take that result and pass it as any parent pointer you want to.  Your
> code logic should never care if a debugfs file is created or not, it is
> "fire and forget".

OK, but does it make any sense to continue creating files when you know
that the parent directory has failed to create? What kind of advantage
does this have?

> And any result of a debugfs call, like this one, that is to be passed
> into another debugfs call, will work just fine if the first one failed
> (the second one usually will also fail, which is fine.)
> 
> Also, and this is the biggest problem, everyone gets the return value
> check wrong thinking NULL will be an error, it is one type of error, but
> other ones are also returned and no one checks them properly.  So just
> don't check at all, that is the design goal here.

sounds like a poor design goal to me but not mine code to maintain so...
-- 
Michal Hocko
SUSE Labs
