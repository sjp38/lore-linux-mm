Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id AC63D6B0007
	for <linux-mm@kvack.org>; Sat, 14 Jul 2018 14:37:09 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id s14-v6so6736444wra.0
        for <linux-mm@kvack.org>; Sat, 14 Jul 2018 11:37:09 -0700 (PDT)
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk. [195.92.253.2])
        by mx.google.com with ESMTPS id d2-v6si23824721wrd.300.2018.07.14.11.37.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 14 Jul 2018 11:37:08 -0700 (PDT)
Date: Sat, 14 Jul 2018 19:36:57 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH v5 0/6] fs/dcache: Track & limit # of negative dentries
Message-ID: <20180714183657.GK30522@ZenIV.linux.org.uk>
References: <1530510723-24814-1-git-send-email-longman@redhat.com>
 <CA+55aFyH6dHw-7R3364dn32J4p7kxT=TqmnuozCn9_Bz-MHhxQ@mail.gmail.com>
 <20180702141811.ef027fd7d8087b7fb2ba0cce@linux-foundation.org>
 <1530570880.3179.9.camel@HansenPartnership.com>
 <20180702161925.1c717283dd2bd4a221bc987c@linux-foundation.org>
 <20180703091821.oiywpdxd6rhtxl4p@quack2.suse.cz>
 <20180714173516.uumlhs4wgfgrlc32@devuan>
 <CA+55aFw1vrsTjJyoq4Q3jBwv1nXaTkkmSbHO6vozWZuTc7_6Kg@mail.gmail.com>
 <20180714183445.GJ30522@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180714183445.GJ30522@ZenIV.linux.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Pavel Machek <pavel@ucw.cz>, Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, James Bottomley <James.Bottomley@hansenpartnership.com>, Waiman Long <longman@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Miklos Szeredi <mszeredi@redhat.com>, Matthew Wilcox <willy@infradead.org>, Larry Woodman <lwoodman@redhat.com>, "Wangkai (Kevin,C)" <wangkai86@huawei.com>, linux-mm <linux-mm@kvack.org>, Michal Hocko <mhocko@kernel.org>

On Sat, Jul 14, 2018 at 07:34:45PM +0100, Al Viro wrote:
> On Sat, Jul 14, 2018 at 11:00:32AM -0700, Linus Torvalds wrote:
> > On Sat, Jul 14, 2018 at 10:35 AM Pavel Machek <pavel@ucw.cz> wrote:
> > >
> > > Could we allocate -ve entries from separate slab?
> > 
> > No, because negative dentrires don't stay negative.
> > 
> > Every single positive dentry starts out as a negative dentry that is
> > passed in to "lookup()" to maybe be made positive.
> > 
> > And most of the time they <i>do</i> turn positive, because most of the
> > time people actually open files that exist.
> > 
> > But then occasionally you don't, because you're just blindly opening a
> > filename whether it exists or not (to _check_ whether it's there).
> 
> BTW, one point that might not be realized by everyone: negative dentries
> are *not* the hard case.
> mount -t tmpfs none /mnt
> touch /mnt/a
> for i in `seq 100000`; do ln /mnt/a /mnt/$i; done
> 
> and you've got 100000 *unevictable* dentries, with the time per iteration
> being not all that high (especially if you just call link(2) in a loop).
> They are all positive and all pinned.  And you've got only one inode
> there and no persistently opened files, so rlimit and quota won't help
> any.

OK, this
        /*   
         * No ordinary (disk based) filesystem counts links as inodes;
         * but each new link needs a new dentry, pinning lowmem, and
         * tmpfs dentries cannot be pruned until they are unlinked.
         */
        ret = shmem_reserve_inode(inode->i_sb);
        if (ret)
                goto out;
will probably help (on ramfs it won't, though).
