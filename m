Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id C44086B000D
	for <linux-mm@kvack.org>; Sat, 14 Jul 2018 13:35:28 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id o1-v6so7992982wmc.6
        for <linux-mm@kvack.org>; Sat, 14 Jul 2018 10:35:28 -0700 (PDT)
Received: from atrey.karlin.mff.cuni.cz (atrey.karlin.mff.cuni.cz. [195.113.26.193])
        by mx.google.com with ESMTPS id h9-v6si6589322wmh.53.2018.07.14.10.35.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 14 Jul 2018 10:35:27 -0700 (PDT)
Date: Sat, 14 Jul 2018 19:35:16 +0200
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH v5 0/6] fs/dcache: Track & limit # of negative dentries
Message-ID: <20180714173516.uumlhs4wgfgrlc32@devuan>
References: <1530510723-24814-1-git-send-email-longman@redhat.com>
 <CA+55aFyH6dHw-7R3364dn32J4p7kxT=TqmnuozCn9_Bz-MHhxQ@mail.gmail.com>
 <20180702141811.ef027fd7d8087b7fb2ba0cce@linux-foundation.org>
 <1530570880.3179.9.camel@HansenPartnership.com>
 <20180702161925.1c717283dd2bd4a221bc987c@linux-foundation.org>
 <20180703091821.oiywpdxd6rhtxl4p@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180703091821.oiywpdxd6rhtxl4p@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, James Bottomley <James.Bottomley@HansenPartnership.com>, Linus Torvalds <torvalds@linux-foundation.org>, Waiman Long <longman@redhat.com>, Al Viro <viro@zeniv.linux.org.uk>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Miklos Szeredi <mszeredi@redhat.com>, Matthew Wilcox <willy@infradead.org>, Larry Woodman <lwoodman@redhat.com>, "Wangkai (Kevin,C)" <wangkai86@huawei.com>, linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>

> > Yes, "should be".  I could understand that the presence of huge
> > nunmbers of -ve dentries could result in undesirable reclaim of
> > pagecache, etc.  Triggering oom-killings is very bad, and presumably
> > has the same cause.
> > 
> > Before we go and add a large amount of code to do the shrinker's job
> > for it, we should get a full understanding of what's going wrong.  Is
> > it because the dentry_lru had a mixture of +ve and -ve dentries? 
> > Should we have a separate LRU for -ve dentries?  Are we appropriately
> > aging the various dentries?  etc.
> > 
> > It could be that tuning/fixing the current code will fix whatever
> > problems inspired this patchset.
> 
> What I think is contributing to the problems and could lead to reclaim
> oddities is the internal fragmentation of dentry slab cache. Dentries are
> relatively small, you get 21 per page on my system, so if trivial to
> reclaim negative dentries get mixed with a small amount of unreclaimable
> positive dentries, you can get a lot of pages in dentry slab cache that are
> unreclaimable.

Could we allocate -ve entries from separate slab?

-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
