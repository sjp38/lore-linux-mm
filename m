Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 47D706B0012
	for <linux-mm@kvack.org>; Wed, 25 May 2011 15:54:02 -0400 (EDT)
Subject: Re: [RFC] [PATCH] drop_caches: add syslog entry
Mime-Version: 1.0 (Apple Message framework v1082)
Content-Type: text/plain; charset=us-ascii
From: Andreas Dilger <adilger@dilger.ca>
In-Reply-To: <BANLkTinKonvpASu_G=Gr8C56WKvFSH5QAA@mail.gmail.com>
Date: Wed, 25 May 2011 13:54:00 -0600
Content-Transfer-Encoding: quoted-printable
Message-Id: <B3BAB9C6-076A-43BE-9143-AE182DADB478@dilger.ca>
References: <BANLkTinKonvpASu_G=Gr8C56WKvFSH5QAA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Martin Tegtmeier <martin.tegtmeier@gmail.com>
Cc: linux-fsdevel@vger.kernel.org, viro@zeniv.linux.org.uk, linux-mm@kvack.org

On May 24, 2011, at 08:16, Martin Tegtmeier wrote:
> currently dropping the file system cache ("echo 1 >
> /proc/sys/vm/drop_caches") doesn't leave any trace. However dropping
> the fs cache can severely impact system behaviour and application
> response times. Therefore I suggest to write a syslog entry if the
> entire inode page cache is scrapped.
> Since it is not an easy task to calculate the size of the droppable
> filesystem cache I also suggest to add the number of dropped pages to
> the syslog entry. This can be accomplished by saving the return value
> of invalidate_mapping_pages().
>=20
> The number of dropped pages is an important measure for capacity
> planning. For the deployment of new SAP application instances we
> would like to know the amount of memory that was freed from
> fs caches.

I'm hugely in favour of this, because we don't need syslog to be an
auditing mechanism for userspace.

However, if something like this goes into the kernel it would probably
make a lot more sense to print out the values on a per-filesystem
basis, if any pages are dropped from a particular filesystem, so one
can see which filesystem was using the most cache.

> drop_caches.c |    9 +++++++--
> 1 file changed, 7 insertions(+), 2 deletions(-)
>=20
>=20
> commit b2219e84647bdf64fd6e7f9c5260c1e6bed24d58
> Author: Martin Tegtmeier <martin.tegtmeier@gmail.com>
> Date:   Tue May 24 15:24:20 2011 +0200
>=20
>    drop_caches: add syslog entry
>=20
>    Dropping the entire file system cache (inode cache) can severely
> influence system behaviour
>    yet currently dropping the file system cache is NOT traceable.
>    This patch adds an entry to /var/log/messages with a time stamp
> and the number of dropped pages.
>=20
>=20
>    Signed-off-by: Martin Tegtmeier <martin.tegtmeier@gmail.com>
>=20
> diff --git a/fs/drop_caches.c b/fs/drop_caches.c
> index 98b77c8..f2e4dc4 100644
> --- a/fs/drop_caches.c
> +++ b/fs/drop_caches.c
> @@ -12,6 +12,7 @@
>=20
> /* A global variable is a bit ugly, but it keeps the code simple */
> int sysctl_drop_caches;
> +unsigned long pages_dropped;
>=20
> static void drop_pagecache_sb(struct super_block *sb, void *unused)
> {
> @@ -28,7 +29,7 @@ static void drop_pagecache_sb(struct super_block
> *sb, void *unused)
> 		__iget(inode);
> 		spin_unlock(&inode->i_lock);
> 		spin_unlock(&inode_sb_list_lock);
> -		invalidate_mapping_pages(inode->i_mapping, 0, -1);
> +		pages_dropped +=3D =
invalidate_mapping_pages(inode->i_mapping, 0, -1);
> 		iput(toput_inode);
> 		toput_inode =3D inode;
> 		spin_lock(&inode_sb_list_lock);
> @@ -55,8 +56,12 @@ int drop_caches_sysctl_handler(ctl_table *table, =
int write,
> 	if (ret)
> 		return ret;
> 	if (write) {
> -		if (sysctl_drop_caches & 1)
> +		if (sysctl_drop_caches & 1) {
> +			pages_dropped =3D 0;
> 			iterate_supers(drop_pagecache_sb, NULL);
> +			printk(KERN_INFO "drop_caches: %lu pages dropped =
from inode cache\n",
> +				pages_dropped);
> +		}
> 		if (sysctl_drop_caches & 2)
> 			drop_slab();
> 	}
> --
> To unsubscribe from this list: send the line "unsubscribe =
linux-fsdevel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


Cheers, Andreas





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
