Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 708C56B0069
	for <linux-mm@kvack.org>; Mon,  7 Nov 2011 04:11:44 -0500 (EST)
Subject: Re: [RFC PATCH] tmpfs: support user quotas
In-Reply-To: Your message of "Sun, 06 Nov 2011 18:15:01 -0300."
             <1320614101.3226.5.camel@offbook>
From: Valdis.Kletnieks@vt.edu
References: <1320614101.3226.5.camel@offbook>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1320657093_7081P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Date: Mon, 07 Nov 2011 04:11:33 -0500
Message-ID: <25866.1320657093@turing-police.cc.vt.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dave@gnu.org
Cc: Hugh Dickins <hughd@google.com>, Lennart Poettering <lennart@poettering.net>, Andrew Morton <akpm@linux-foundation.org>, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

--==_Exmh_1320657093_7081P
Content-Type: text/plain; charset=us-ascii

On Sun, 06 Nov 2011 18:15:01 -0300, Davidlohr Bueso said:

> @@ -1159,7 +1159,12 @@ shmem_write_begin(struct file *file, struct address_space *mapping,
>  			struct page **pagep, void **fsdata)

> +	if (atomic_long_read(&user->shmem_bytes) + len > 
> +	    rlimit(RLIMIT_TMPFSQUOTA))
> +		return -ENOSPC;

Is this a per-process or per-user limit?  If it's per-process, it doesn't
really do much good, because a user can use multiple processes to over-run the
limit (either intentionally or accidentally).

> @@ -1169,10 +1174,12 @@ shmem_write_end(struct file *file, struct address_space *mapping,
>  			struct page *page, void *fsdata)

> +	if (pos + copied > inode->i_size) {
>  		i_size_write(inode, pos + copied);
> +		atomic_long_add(copied, &user->shmem_bytes);
> +	}

If this is per-user, it's racy with shmem_write_begin() - two processes can hit
the write_begin(), be under quota by (say) 1M, but by the time they both
complete the user is 1M over the quota.

>  @@ -1535,12 +1542,15 @@ static int shmem_unlink(struct inode *dir, struct dentry *dentry)
> +	struct user_struct *user = current_user();
> +	atomic_long_sub(inode->i_size, &user->shmem_bytes);

What happens here if user 'fred' creates a file on a tmpfs, and then logs out so he has
no processes running, and then root does a 'find tmpfs -user fred -exec rm {} \;' to clean up?
We just decremented root's quota, not fred's....


--==_Exmh_1320657093_7081P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFOt6DFcC3lWbTT17ARAvgcAKCfOLpiqvy4o2wOLlDpgfbbXKPDtgCg+i9l
P1HySIiEz+1LnLj38+VVp/k=
=gCbY
-----END PGP SIGNATURE-----

--==_Exmh_1320657093_7081P--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
