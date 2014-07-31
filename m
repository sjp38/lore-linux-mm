Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 98CE16B0035
	for <linux-mm@kvack.org>; Thu, 31 Jul 2014 17:51:06 -0400 (EDT)
Received: by mail-wi0-f173.google.com with SMTP id f8so350229wiw.12
        for <linux-mm@kvack.org>; Thu, 31 Jul 2014 14:51:06 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id sh6si1424151wic.25.2014.07.31.14.51.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 31 Jul 2014 14:51:04 -0700 (PDT)
Date: Fri, 1 Aug 2014 07:50:53 +1000
From: NeilBrown <neilb@suse.de>
Subject: Re: Killing process in D state on mount to dead NFS server. (when
 process is in fsync)
Message-ID: <20140801075053.2120cb33@notabene.brown>
In-Reply-To: <53DAB307.2000206@candelatech.com>
References: <53DA8443.407@candelatech.com>
	<20140801064217.01852788@notabene.brown>
	<53DAB307.2000206@candelatech.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/0rsoDSzS+wKUixuGpkIJ=Xy"; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ben Greear <greearb@candelatech.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

--Sig_/0rsoDSzS+wKUixuGpkIJ=Xy
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Thu, 31 Jul 2014 14:20:07 -0700 Ben Greear <greearb@candelatech.com> wro=
te:

> -----BEGIN PGP SIGNED MESSAGE-----
> Hash: SHA1
>=20
> On 07/31/2014 01:42 PM, NeilBrown wrote:
> > On Thu, 31 Jul 2014 11:00:35 -0700 Ben Greear <greearb@candelatech.com>=
 wrote:
> >=20
> >> So, this has been asked all over the interweb for years and years, but=
 the best answer I can find is to reboot the system or create a fake NFS se=
rver
> >> somewhere with the same IP as the gone-away NFS server.
> >>=20
> >> The problem is:
> >>=20
> >> I have some mounts to an NFS server that no longer exists (crashed/pow=
ered down).
> >>=20
> >> I have some processes stuck trying to write to files open on these mou=
nts.
> >>=20
> >> I want to kill the process and unmount.
> >>=20
> >> umount -l will make the mount go a way, sort of.  But process is still=
 hung. umount -f complains: umount2:  Device or resource busy umount.nfs: /=
mnt/foo:
> >> device is busy
> >>=20
> >> kill -9 does not work on process.
> >=20
> > Kill -1 should work (since about 2.6.25 or so).
>=20
> That is -[ONE], right?  Assuming so, it did not work for me.

No, it was "-9" .... sorry, I really shouldn't be let out without my proof
reader.

However the 'stack' is sufficient to see what is going on.

The problem is that it is blocked inside the "VM" well away from NFS and
there is no way for NFS to say "give up and go home".

I'd suggest that is a bug.   I cannot see any justification for fsync to not
be killable.
It wouldn't be too hard to create a patch to make it so.
It would be a little harder to examine all call paths and create a
convincing case that the patch was safe.
It might be herculean task to convince others that it was the right thing
to do.... so let's start with that one.

Hi Linux-mm and fs-devel people.  What do people think of making "fsync" and
variants "KILLABLE" ??

I probably only need a little bit of encouragement to write a patch....

Thanks,
NeilBrown

>=20
> Kernel is 3.14.4+, with some of extra patches, but probably nothing that
> influences this particular behaviour.
>=20
> [root@lf1005-14010010 ~]# cat /proc/3805/stack
> [<ffffffff811371ba>] sleep_on_page+0x9/0xd
> [<ffffffff8113738e>] wait_on_page_bit+0x71/0x78
> [<ffffffff8113769a>] filemap_fdatawait_range+0xa2/0x16d
> [<ffffffff8113780e>] filemap_write_and_wait_range+0x3b/0x77
> [<ffffffffa0f04734>] nfs_file_fsync+0x37/0x83 [nfs]
> [<ffffffff811a8d32>] vfs_fsync_range+0x19/0x1b
> [<ffffffff811a8d4b>] vfs_fsync+0x17/0x19
> [<ffffffffa0f05305>] nfs_file_flush+0x6b/0x6f [nfs]
> [<ffffffff81183e46>] filp_close+0x3f/0x71
> [<ffffffff8119c8ae>] __close_fd+0x80/0x98
> [<ffffffff81183de5>] SyS_close+0x1c/0x3e
> [<ffffffff815c55f9>] system_call_fastpath+0x16/0x1b
> [<ffffffffffffffff>] 0xffffffffffffffff
> [root@lf1005-14010010 ~]# kill -1 3805
> [root@lf1005-14010010 ~]# cat /proc/3805/stack
> [<ffffffff811371ba>] sleep_on_page+0x9/0xd
> [<ffffffff8113738e>] wait_on_page_bit+0x71/0x78
> [<ffffffff8113769a>] filemap_fdatawait_range+0xa2/0x16d
> [<ffffffff8113780e>] filemap_write_and_wait_range+0x3b/0x77
> [<ffffffffa0f04734>] nfs_file_fsync+0x37/0x83 [nfs]
> [<ffffffff811a8d32>] vfs_fsync_range+0x19/0x1b
> [<ffffffff811a8d4b>] vfs_fsync+0x17/0x19
> [<ffffffffa0f05305>] nfs_file_flush+0x6b/0x6f [nfs]
> [<ffffffff81183e46>] filp_close+0x3f/0x71
> [<ffffffff8119c8ae>] __close_fd+0x80/0x98
> [<ffffffff81183de5>] SyS_close+0x1c/0x3e
> [<ffffffff815c55f9>] system_call_fastpath+0x16/0x1b
> [<ffffffffffffffff>] 0xffffffffffffffff
>=20
> Thanks,
> Ben
>=20
> > If it doesn't please report the kernel version and cat /proc/$PID/stack
> >=20
> > for some processes that cannot be killed.
> >=20
> > NeilBrown
> >=20
> >>=20
> >>=20
> >> Aside from bringing a fake NFS server back up on the same IP, is there=
 any other way to get these mounts unmounted and the processes killed witho=
ut=20
> >> rebooting?
> >>=20
> >> Thanks, Ben
> >>=20
> >=20
>=20
>=20
> - --=20
> Ben Greear <greearb@candelatech.com>
> Candela Technologies Inc  http://www.candelatech.com
>=20
> -----BEGIN PGP SIGNATURE-----
> Version: GnuPG v1.4.13 (GNU/Linux)
> Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/
>=20
> iQEcBAEBAgAGBQJT2rLiAAoJELbHqkYeJT4OqPgH/0taKW6Be90c1mETZf9yeqZF
> YMLZk8XC2wloEd9nVz//mXREmiu18Hc+5p7Upd4Os21J2P4PBMGV6P/9DMxxehwH
> YX1HKha0EoAsbO5ILQhbLf83cRXAPEpvJPgYHrq6xjlKB8Q8OxxND37rY7kl19Zz
> sdAw6GiqHICF3Hq1ATa/jvixMluDnhER9Dln3wOdAGzmmuFYqpTsV4EwzbKKqInJ
> 6C15q+cq/9aYh6usN6z2qJhbHgqM9EWcPL6jOrCwX4PbC1XjKHekpFN0t9oKQClx
> qSPuweMQ7fP4IBd2Ke8L/QlyOVblAKSE7t+NdrjfzLmYPzyHTyfLABR/BI053to=3D
> =3D/9FJ
> -----END PGP SIGNATURE-----


--Sig_/0rsoDSzS+wKUixuGpkIJ=Xy
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBU9q6PTnsnt1WYoG5AQLpnA/9EeEvHe0bFrg9WztWnX7jocD3s6TC8pD4
Jeq1vNoAbSWMzgHqdk91ddHy3xbB+r1fjre6AVtpr6tQ0ZJprEteqCQ3bg6CErSo
FrqSC+eoQs1C2tXFLzv2V4NLbG/LQrbOOazTHW06kzzNde/8aC5ZYGpmQJUy8khT
v3D4tpvZg35nVmR6OLLJNogbt2vlLBzkVrsFQV1Myp26Pt13oQVYWL/NjbHbVYA9
cYALts3QpBCQx36yQR1Q2T/LhhsKA8S9bgxJN923N0r0CNoPz8EX1S3vOyZ3bPOL
uPSvR4srtS53s3+mSL2b14/DS+7hqHXP63x9ZSvBf5LbjrZSO7KkLhsMmk5fDXqy
y+IcZvEo+Pu1Hisx3X1nlXzuOMqHU3Yzhjj7RgQW0mFuA9KhttS7D1T6+uiB0fRJ
yN/aRI8im5JR4kqiOrRRncToB9YpjxFfW4CAqyfSCaY96C1ohyomDQ5A1YUk8KbE
yXhVZpoU3TQJRZ8PutYFbfB6OHj1YDiZ2kM6U1OJOiFV/e58dYJa52YQAWqdfbqd
yge1p8vq7KELEL+m+YTyKOX5+RIN1k5YnSB3JKGi6yx0ThqY5KonHNSSMQvIEpcn
GwAsENgS7DQmQixbIv47eTzaDSg3w5a4nkSqr+pj4KXAolunOu1M203B+OOqXmeT
l9YxqmsinO4=
=9A61
-----END PGP SIGNATURE-----

--Sig_/0rsoDSzS+wKUixuGpkIJ=Xy--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
