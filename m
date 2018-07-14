Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 229536B000A
	for <linux-mm@kvack.org>; Sat, 14 Jul 2018 14:44:10 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id p21-v6so10411561itc.7
        for <linux-mm@kvack.org>; Sat, 14 Jul 2018 11:44:10 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k7-v6sor10933948ioc.34.2018.07.14.11.44.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 14 Jul 2018 11:44:09 -0700 (PDT)
MIME-Version: 1.0
References: <1530510723-24814-1-git-send-email-longman@redhat.com>
 <CA+55aFyH6dHw-7R3364dn32J4p7kxT=TqmnuozCn9_Bz-MHhxQ@mail.gmail.com>
 <20180702141811.ef027fd7d8087b7fb2ba0cce@linux-foundation.org>
 <1530570880.3179.9.camel@HansenPartnership.com> <20180702161925.1c717283dd2bd4a221bc987c@linux-foundation.org>
 <20180703091821.oiywpdxd6rhtxl4p@quack2.suse.cz> <20180714173516.uumlhs4wgfgrlc32@devuan>
 <CA+55aFw1vrsTjJyoq4Q3jBwv1nXaTkkmSbHO6vozWZuTc7_6Kg@mail.gmail.com>
 <20180714183445.GJ30522@ZenIV.linux.org.uk> <20180714183657.GK30522@ZenIV.linux.org.uk>
In-Reply-To: <20180714183657.GK30522@ZenIV.linux.org.uk>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sat, 14 Jul 2018 11:43:57 -0700
Message-ID: <CA+55aFwPcoWFxgHb2TYGO3Mh2WyPfkhpwNAw7xxbar=ncb3Nuw@mail.gmail.com>
Subject: Re: [PATCH v5 0/6] fs/dcache: Track & limit # of negative dentries
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: Pavel Machek <pavel@ucw.cz>, Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, James Bottomley <James.Bottomley@hansenpartnership.com>, Waiman Long <longman@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Miklos Szeredi <mszeredi@redhat.com>, Matthew Wilcox <willy@infradead.org>, Larry Woodman <lwoodman@redhat.com>, "Wangkai (Kevin,C)" <wangkai86@huawei.com>, linux-mm <linux-mm@kvack.org>, Michal Hocko <mhocko@kernel.org>

On Sat, Jul 14, 2018 at 11:36 AM Al Viro <viro@zeniv.linux.org.uk> wrote:
>
> OK, this
>         /*
>          * No ordinary (disk based) filesystem counts links as inodes;
>          * but each new link needs a new dentry, pinning lowmem, and
>          * tmpfs dentries cannot be pruned until they are unlinked.
>          */
>         ret = shmem_reserve_inode(inode->i_sb);
>         if (ret)
>                 goto out;
> will probably help (on ramfs it won't, though).

Nobody who cares about memory use would use ramfs and then allow
random users on it.

I think you can exhaust memory more easily on ramfs by just writing a
huge file. Do we have any limits at all?

ramfs is fine for things like initramfs, but I think the comment says it all:

 * NOTE! This filesystem is probably most useful
 * not as a real filesystem, but as an example of
 * how virtual filesystems can be written.

and even that comment may have been more correct back in 2000 than it is today.

             Linus
