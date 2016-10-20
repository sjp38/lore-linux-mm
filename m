Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3BBAF6B0038
	for <linux-mm@kvack.org>; Thu, 20 Oct 2016 11:15:41 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id z65so113271984itc.2
        for <linux-mm@kvack.org>; Thu, 20 Oct 2016 08:15:41 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id sm3si37942600pac.261.2016.10.20.08.15.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Oct 2016 08:15:36 -0700 (PDT)
Message-ID: <1476976532.3002.6.camel@linux.intel.com>
Subject: Re: [Intel-gfx] [PATCH 1/2] shmem: Support for registration of
 Driver/file owner specific ops
From: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>
Date: Thu, 20 Oct 2016 18:15:32 +0300
In-Reply-To: <CAK_0AV3KKVZOr6WRtFOox-WKQ0wR34ry-hnR=O7aMX8DhgcGhA@mail.gmail.com>
References: <1458713384-25688-1-git-send-email-akash.goel@intel.com>
	 <1458821494.7860.9.camel@linux.intel.com>
	 <CAK_0AV3KKVZOr6WRtFOox-WKQ0wR34ry-hnR=O7aMX8DhgcGhA@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akash goel <akash.goels@gmail.com>, Chris Wilson <chris@chris-wilson.co.uk>
Cc: intel-gfx@lists.freedesktop.org, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, Sourab Gupta <sourab.gupta@intel.com>, "Goel, Akash" <akash.goel@intel.com>

On ke, 2016-10-19 at 20:41 +0530, akash goel wrote:
> On Thu, Mar 24, 2016 at 5:41 PM, Joonas Lahtinen
> > <joonas.lahtinen@linux.intel.com> wrote:
> > On ke, 2016-03-23 at 11:39 +0530, akash.goel@intel.com wrote:
> > > @@ -34,11 +34,28 @@ struct shmem_sb_info {
> > > A A A A A A struct mempolicy *mpol;A A A A A /* default memory policy for mappings */
> > > A };
> > > 
> > > +struct shmem_dev_info {
> > > +A A A A A void *dev_private_data;
> > > +A A A A A int (*dev_migratepage)(struct address_space *mapping,
> > > +A A A A A A A A A A A A A A A A A A A A A A A A A A A A struct page *newpage, struct page *page,
> > > +A A A A A A A A A A A A A A A A A A A A A A A A A A A A enum migrate_mode mode, void *dev_priv_data);
> > 
> > One might want to have a separate shmem_dev_operations struct or
> > similar.
> > 
> Sorry for the very late turnaround.
> 
> Sorry couldn't get your point here. Are you suggesting to rename the
> structure to shmem_dev_operations ?

I'm pretty sure I was after putting migratepage function pointer in
shmem_dev_operations struct, but I think that can be done once there
are more functions.

s/dev_private_data/private_data/ and s/dev_priv_data/private_data/
might be in order, too. I should be obvious from context.

> > > +};
> > > +
> > > A static inline struct shmem_inode_info *SHMEM_I(struct inode *inode)
> > > A {
> > > A A A A A A return container_of(inode, struct shmem_inode_info, vfs_inode);
> > > A }
> > > 
> > > +static inline int shmem_set_device_ops(struct address_space *mapping,
> > > +A A A A A A A A A A A A A A A A A A A A A A A A A A A A A struct shmem_dev_info *info)
> > > +{

This name could be shmem_set_dev_info, if there will be separate _ops
struct in future.

> > > +A A A A A if (mapping->private_data != NULL)
> > > +A A A A A A A A A A A A A return -EEXIST;
> > > +
> > 
> > I did a quick random peek and most set functions are just void and
> > override existing data. I'd suggest the same.
> > 
> > > 
> > > +A A A A A mapping->private_data = info;
> > 
> Fine will change the return type to void and remove the check.
> 
> > 
> > Also, doesn't this kinda steal the mapping->private_data, might that be
> > unexpected for the user? I notice currently it's not being touched at
> > all.
> > 
> Sorry by User do you mean the shmem client who called shmem_file_setup() ?
> It seems clients are not expected to touch mapping->private_data and
> so shmemfs can safely use it.

If it's not used by others, should be fine. Not sure if WARN would be
in place, Chris?

Regards, Joonas
-- 
Joonas Lahtinen
Open Source Technology Center
Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
