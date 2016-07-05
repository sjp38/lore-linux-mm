Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id C65A56B0005
	for <linux-mm@kvack.org>; Mon,  4 Jul 2016 20:11:15 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id a69so418274146pfa.1
        for <linux-mm@kvack.org>; Mon, 04 Jul 2016 17:11:15 -0700 (PDT)
Received: from mail-pa0-x22e.google.com (mail-pa0-x22e.google.com. [2607:f8b0:400e:c03::22e])
        by mx.google.com with ESMTPS id c133si967076pfc.145.2016.07.04.17.11.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Jul 2016 17:11:15 -0700 (PDT)
Received: by mail-pa0-x22e.google.com with SMTP id b13so62140466pat.0
        for <linux-mm@kvack.org>; Mon, 04 Jul 2016 17:11:14 -0700 (PDT)
Date: Mon, 4 Jul 2016 17:11:05 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [patch] Allow user.* xattr in tmpfs
In-Reply-To: <20160630223608.6ecbec55@lembas.zaitcev.lan>
Message-ID: <alpine.LSU.2.11.1607041614360.25599@eggly.anvils>
References: <20160630223608.6ecbec55@lembas.zaitcev.lan>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pete Zaitcev <zaitcev@kotori.zaitcev.us>
Cc: linux-mm@kvack.org, Hugh Dickins <hughd@google.com>

On Thu, 30 Jun 2016, Pete Zaitcev wrote:

> The lack of user extended attributes is a source of annoyance when
> testing something that uses it, such as OpenStack Swift (including
> Hummingbird). We used to "monkey-patch" this in Python, so that
> tests can run on development systems, but it became desirable
> to store correct attributes and existing stubs became impractical.
> 
> See:
> - my failed attempt to use /var/tmp:
>  https://review.openstack.org/328508
> - Sam Merritt removing monkey-patching:
>  https://review.openstack.org/336323

> 
> Signed-off-by: Pete Zaitcev <zaitcev@redhat.com>
> ---

I use a very similar patch for testing xattrs on tmpfs with xfstests.

> 
> This seems entirely too obvious. I'm getting concerned that we omitted
> the user xattr for a reason. Just can't imagine what it might be.

The reason is that it lets anyone who can write to a tmpfs file
allocate almost all of RAM (or lowmem) to those xattrs; without
even being able to swap them out.

We cannot enable user xattrs on tmpfs for everybody without
limiting them in some way: so NAK to your patch as it stands.

Config option?  Too inflexible, not much use here, except to you and me.

MEMCG KMEM charging?  A good solution, but we don't want to force every
system which might want tmpfs user xattrs to have to switch on MEMCG.

New mount option to limit the amount?  Probably the right solution,
consistent with how we limit swappable data with "nr_blocks=" or "size=".

Extend the "nr_inodes=" mount option to include memory for user xattrs?
I hadn't thought of this before your mail, maybe it's a good answer,
maybe not.  It is perfectly reasonable to account the two together:
xattrs are inode extensions, and they both use unswappable lowmem
slab memory.  Perhaps it would be the right solution if we invent
a new name to cover both uses, rather like "size=" got added as an
alternative for "nr_blocks=".

(And there is already a peculiar extra use of it in tmpfs: nr_inodes
limits hard links as well as inodes, to limit dentry memory usage.)

The advantage of the last would be, that installations would
automatically get (probably more than enough) space for tmpfs user
xattrs with a new kernel, without needing to mess with mount options.

Or would that be a disadvantage - a new way of quietly using up RAM?

But without a stronger case for user xattrs on tmpfs,
shouldn't you and I just stick with our patches?

Hugh

> 
> diff --git a/mm/shmem.c b/mm/shmem.c
> index 24463b6..4ddec69 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -2655,6 +2655,12 @@ static int shmem_xattr_handler_set(const struct xattr_handler *handler,
>  	return simple_xattr_set(&info->xattrs, name, value, size, flags);
>  }
>  
> +static const struct xattr_handler shmem_user_xattr_handler = {
> +	.prefix = XATTR_USER_PREFIX,
> +	.get = shmem_xattr_handler_get,
> +	.set = shmem_xattr_handler_set,
> +};
> +
>  static const struct xattr_handler shmem_security_xattr_handler = {
>  	.prefix = XATTR_SECURITY_PREFIX,
>  	.get = shmem_xattr_handler_get,
> @@ -2672,6 +2678,7 @@ static const struct xattr_handler *shmem_xattr_handlers[] = {
>  	&posix_acl_access_xattr_handler,
>  	&posix_acl_default_xattr_handler,
>  #endif
> +	&shmem_user_xattr_handler,
>  	&shmem_security_xattr_handler,
>  	&shmem_trusted_xattr_handler,
>  	NULL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
