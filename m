Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id AF42D6B005A
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 06:24:18 -0400 (EDT)
Date: Thu, 9 Jul 2009 13:42:02 +0300
From: Sergey Senozhatsky <sergey.senozhatsky@mail.by>
Subject: kmemeleak BUG: lock held when returning to user space!
Message-ID: <20090709104202.GA3434@localdomain.by>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="LQksG6bCIzRHxTLp"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


--LQksG6bCIzRHxTLp
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hello.

kernel: [  149.507103] ================================================
kernel: [  149.507113] [ BUG: lock held when returning to user space! ]
kernel: [  149.507119] ------------------------------------------------
kernel: [  149.507127] cat/3279 is leaving the kernel with locks still held!
kernel: [  149.507135] 1 lock held by cat/3279:
kernel: [  149.507141]  #0:  (scan_mutex){+.+.+.}, at: [<c110707c>] kmemleak_open+0x4c/0x80

problem is here:
static int kmemleak_open(struct inode *inode, struct file *file)
{
	int ret = 0;

	if (!atomic_read(&kmemleak_enabled))
		return -EBUSY;

	ret = mutex_lock_interruptible(&scan_mutex);
	if (ret < 0)
		goto out;
	if (file->f_mode & FMODE_READ) {
		ret = seq_open(file, &kmemleak_seq_ops);
		if (ret < 0)
			goto scan_unlock;
	}
>>-	return ret;

scan_unlock:
	mutex_unlock(&scan_mutex);
out:
	return ret;
}

we should not return before mutex_unlock(&scan_mutex);

	Sergey

--LQksG6bCIzRHxTLp
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iJwEAQECAAYFAkpVyXoACgkQfKHnntdSXjRE8wP/dQjwYNJnTVeEebnGMlsUZpS9
klr+L0s+3eKBBLjGEG17SE9jcVWwvRUBAYwumMXTHGLCrTwaYX18j4QR6EDNT3Gi
dWl2maYbYRsUl2S9gFMbqjy8DHV0CR6Fv/jlMHCkWt/NkrGXzgd2ltOBGVhj6bnU
GGIMykJwJQmHIda6By0=
=9+4L
-----END PGP SIGNATURE-----

--LQksG6bCIzRHxTLp--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
