Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id AEAA86B0008
	for <linux-mm@kvack.org>; Thu, 19 Jul 2018 05:13:28 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id 66-v6so4170543plb.18
        for <linux-mm@kvack.org>; Thu, 19 Jul 2018 02:13:28 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j21-v6si5708691pgg.303.2018.07.19.02.13.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Jul 2018 02:13:27 -0700 (PDT)
Date: Thu, 19 Jul 2018 11:13:24 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v6 0/7] fs/dcache: Track & limit # of negative dentries
Message-ID: <20180719091324.ohattgzh53zlpi3p@quack2.suse.cz>
References: <1531416080.18255.8.camel@HansenPartnership.com>
 <CA+55aFzfQz7c8pcMfLDaRNReNF2HaKJGoWpgB6caQjNAyjg-hA@mail.gmail.com>
 <1531425435.18255.17.camel@HansenPartnership.com>
 <20180713003614.GW2234@dastard>
 <20180716090901.GG17280@dhcp22.suse.cz>
 <20180716124115.GA7072@bombadil.infradead.org>
 <20180716164032.94e13f765c5f33c6022eca38@linux-foundation.org>
 <20180717083326.GD16803@dhcp22.suse.cz>
 <20180719003329.GD19934@dastard>
 <20180719084538.GP7193@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180719084538.GP7193@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Dave Chinner <david@fromorbit.com>, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>, James Bottomley <James.Bottomley@HansenPartnership.com>, Linus Torvalds <torvalds@linux-foundation.org>, Waiman Long <longman@redhat.com>, Al Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, "Luis R. Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, Jan Kara <jack@suse.cz>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Miklos Szeredi <mszeredi@redhat.com>, Larry Woodman <lwoodman@redhat.com>, "Wangkai (Kevin,C)" <wangkai86@huawei.com>

On Thu 19-07-18 10:45:38, Michal Hocko wrote:
> On Thu 19-07-18 10:33:29, Dave Chinner wrote:
> > > > and, apart from the external name thing (grr), that should address
> > > > these fragmentation issues, no?  I assume it's easy to ask slab how
> > > > many pages are presently in use for a particular cache.
> > > 
> > > I remember Dave Chinner had an idea how to age dcache pages to push
> > > dentries with similar live time to the same page. Not sure what happened
> > > to that.
> > 
> > Same thing that happened to all the "select the dentries on this
> > page for reclaim". i.e. it's referenced dentries that we can't
> > reclaim or move that are the issue, not the reclaimable dentries on
> > the page.
> > 
> > Bsaically, without a hint at allocation time as to the expected life
> > time of the dentry, we can't be smart about how we select partial
> > pages to allocate from. And because we don't know at allocation time
> > if the dentry is going to remain a negative dentry or not, we can't
> > provide a hint about expected lifetime of teh object being
> > allocated.
> 
> Can we allocate a new dentry at the time when we know the life time or
> the dentry pointer is so spread by that time that we cannot?

It's difficult. We allocate dentry, put it in our structures, use it for
synchronization e.g. of parallel lookups of the same name (so for that it is
important that it is visible to everybody) and only after that we ask
filesystem what does it have (if anything) under that name... So delaying
allocation would mean overhauling the locking logic in the whole dcache.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
