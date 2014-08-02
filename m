Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f54.google.com (mail-qg0-f54.google.com [209.85.192.54])
	by kanga.kvack.org (Postfix) with ESMTP id 2EF6F6B0074
	for <linux-mm@kvack.org>; Fri,  1 Aug 2014 21:21:28 -0400 (EDT)
Received: by mail-qg0-f54.google.com with SMTP id z60so6687660qgd.13
        for <linux-mm@kvack.org>; Fri, 01 Aug 2014 18:21:27 -0700 (PDT)
Received: from mail-qa0-f43.google.com (mail-qa0-f43.google.com [209.85.216.43])
        by mx.google.com with ESMTPS id n63si18355890qge.1.2014.08.01.18.21.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 01 Aug 2014 18:21:26 -0700 (PDT)
Received: by mail-qa0-f43.google.com with SMTP id w8so4699367qac.16
        for <linux-mm@kvack.org>; Fri, 01 Aug 2014 18:21:26 -0700 (PDT)
Date: Fri, 1 Aug 2014 21:21:20 -0400
From: Jeff Layton <jlayton@poochiereds.net>
Subject: Re: Killing process in D state on mount to dead NFS server. (when
 process is in fsync)
Message-ID: <20140801212120.1ae0eb02@tlielax.poochiereds.net>
In-Reply-To: <20140801075053.2120cb33@notabene.brown>
References: <53DA8443.407@candelatech.com>
	<20140801064217.01852788@notabene.brown>
	<53DAB307.2000206@candelatech.com>
	<20140801075053.2120cb33@notabene.brown>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/VicZwCLwZxCKNuVzo4gaa4F"; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: NeilBrown <neilb@suse.de>
Cc: Ben Greear <greearb@candelatech.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

--Sig_/VicZwCLwZxCKNuVzo4gaa4F
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Fri, 1 Aug 2014 07:50:53 +1000
NeilBrown <neilb@suse.de> wrote:

> On Thu, 31 Jul 2014 14:20:07 -0700 Ben Greear <greearb@candelatech.com> w=
rote:
>=20
> > -----BEGIN PGP SIGNED MESSAGE-----
> > Hash: SHA1
> >=20
> > On 07/31/2014 01:42 PM, NeilBrown wrote:
> > > On Thu, 31 Jul 2014 11:00:35 -0700 Ben Greear <greearb@candelatech.co=
m> wrote:
> > >=20
> > >> So, this has been asked all over the interweb for years and years, b=
ut the best answer I can find is to reboot the system or create a fake NFS =
server
> > >> somewhere with the same IP as the gone-away NFS server.
> > >>=20
> > >> The problem is:
> > >>=20
> > >> I have some mounts to an NFS server that no longer exists (crashed/p=
owered down).
> > >>=20
> > >> I have some processes stuck trying to write to files open on these m=
ounts.
> > >>=20
> > >> I want to kill the process and unmount.
> > >>=20
> > >> umount -l will make the mount go a way, sort of.  But process is sti=
ll hung. umount -f complains: umount2:  Device or resource busy umount.nfs:=
 /mnt/foo:
> > >> device is busy
> > >>=20
> > >> kill -9 does not work on process.
> > >=20
> > > Kill -1 should work (since about 2.6.25 or so).
> >=20
> > That is -[ONE], right?  Assuming so, it did not work for me.
>=20
> No, it was "-9" .... sorry, I really shouldn't be let out without my proof
> reader.
>=20
> However the 'stack' is sufficient to see what is going on.
>=20
> The problem is that it is blocked inside the "VM" well away from NFS and
> there is no way for NFS to say "give up and go home".
>=20
> I'd suggest that is a bug.   I cannot see any justification for fsync to =
not
> be killable.
> It wouldn't be too hard to create a patch to make it so.
> It would be a little harder to examine all call paths and create a
> convincing case that the patch was safe.
> It might be herculean task to convince others that it was the right thing
> to do.... so let's start with that one.
>=20
> Hi Linux-mm and fs-devel people.  What do people think of making "fsync" =
and
> variants "KILLABLE" ??
>=20
> I probably only need a little bit of encouragement to write a patch....
>=20
> Thanks,
> NeilBrown
>=20


It would be good to fix this in some fashion once and for all, and the
wait_on_page_writeback wait is a major source of pain for a lot of
people.

So to summarize...

The problem in a nutshell is that Ben has some cached writes to the
NFS server, but the server has gone away (presumably forever). The
question is -- how do we communicate to the kernel that that server
isn't coming back and that those dirty pages should be invalidated so
that we can umount the filesystem?

Allowing fsync/close to be killable sounds reasonable to me as at least
a partial solution. Both close(2) and fsync(2) are allowed to return
EINTR according to the POSIX spec. Allowing a kill -9 there seems
like it should be fine, and maybe we ought to even consider letting it
be susceptible to lesser signals.

That still leaves some open questions though...

Is that enough to fix it? You'd still have the dirty pages lingering
around, right? Would a umount -f presumably work at that point?

> >=20
> > Kernel is 3.14.4+, with some of extra patches, but probably nothing that
> > influences this particular behaviour.
> >=20
> > [root@lf1005-14010010 ~]# cat /proc/3805/stack
> > [<ffffffff811371ba>] sleep_on_page+0x9/0xd
> > [<ffffffff8113738e>] wait_on_page_bit+0x71/0x78
> > [<ffffffff8113769a>] filemap_fdatawait_range+0xa2/0x16d
> > [<ffffffff8113780e>] filemap_write_and_wait_range+0x3b/0x77
> > [<ffffffffa0f04734>] nfs_file_fsync+0x37/0x83 [nfs]
> > [<ffffffff811a8d32>] vfs_fsync_range+0x19/0x1b
> > [<ffffffff811a8d4b>] vfs_fsync+0x17/0x19
> > [<ffffffffa0f05305>] nfs_file_flush+0x6b/0x6f [nfs]
> > [<ffffffff81183e46>] filp_close+0x3f/0x71
> > [<ffffffff8119c8ae>] __close_fd+0x80/0x98
> > [<ffffffff81183de5>] SyS_close+0x1c/0x3e
> > [<ffffffff815c55f9>] system_call_fastpath+0x16/0x1b
> > [<ffffffffffffffff>] 0xffffffffffffffff
> > [root@lf1005-14010010 ~]# kill -1 3805
> > [root@lf1005-14010010 ~]# cat /proc/3805/stack
> > [<ffffffff811371ba>] sleep_on_page+0x9/0xd
> > [<ffffffff8113738e>] wait_on_page_bit+0x71/0x78
> > [<ffffffff8113769a>] filemap_fdatawait_range+0xa2/0x16d
> > [<ffffffff8113780e>] filemap_write_and_wait_range+0x3b/0x77
> > [<ffffffffa0f04734>] nfs_file_fsync+0x37/0x83 [nfs]
> > [<ffffffff811a8d32>] vfs_fsync_range+0x19/0x1b
> > [<ffffffff811a8d4b>] vfs_fsync+0x17/0x19
> > [<ffffffffa0f05305>] nfs_file_flush+0x6b/0x6f [nfs]
> > [<ffffffff81183e46>] filp_close+0x3f/0x71
> > [<ffffffff8119c8ae>] __close_fd+0x80/0x98
> > [<ffffffff81183de5>] SyS_close+0x1c/0x3e
> > [<ffffffff815c55f9>] system_call_fastpath+0x16/0x1b
> > [<ffffffffffffffff>] 0xffffffffffffffff
> >=20
> > Thanks,
> > Ben
> >=20
> > > If it doesn't please report the kernel version and cat /proc/$PID/sta=
ck
> > >=20
> > > for some processes that cannot be killed.
> > >=20
> > > NeilBrown
> > >=20
> > >>=20
> > >>=20
> > >> Aside from bringing a fake NFS server back up on the same IP, is the=
re any other way to get these mounts unmounted and the processes killed wit=
hout=20
> > >> rebooting?
> > >>=20
> > >> Thanks, Ben
> > >>=20
> > >=20
> >=20
> >=20
> > - --=20
> > Ben Greear <greearb@candelatech.com>
> > Candela Technologies Inc  http://www.candelatech.com
> >=20
> > -----BEGIN PGP SIGNATURE-----
> > Version: GnuPG v1.4.13 (GNU/Linux)
> > Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/
> >=20
> > iQEcBAEBAgAGBQJT2rLiAAoJELbHqkYeJT4OqPgH/0taKW6Be90c1mETZf9yeqZF
> > YMLZk8XC2wloEd9nVz//mXREmiu18Hc+5p7Upd4Os21J2P4PBMGV6P/9DMxxehwH
> > YX1HKha0EoAsbO5ILQhbLf83cRXAPEpvJPgYHrq6xjlKB8Q8OxxND37rY7kl19Zz
> > sdAw6GiqHICF3Hq1ATa/jvixMluDnhER9Dln3wOdAGzmmuFYqpTsV4EwzbKKqInJ
> > 6C15q+cq/9aYh6usN6z2qJhbHgqM9EWcPL6jOrCwX4PbC1XjKHekpFN0t9oKQClx
> > qSPuweMQ7fP4IBd2Ke8L/QlyOVblAKSE7t+NdrjfzLmYPzyHTyfLABR/BI053to=3D
> > =3D/9FJ
> > -----END PGP SIGNATURE-----
>=20


--=20
Jeff Layton <jlayton@poochiereds.net>

--Sig_/VicZwCLwZxCKNuVzo4gaa4F
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBAgAGBQJT3D0QAAoJEAAOaEEZVoIVmXkQAI6fWiPs6GBlOfVvnIANzVYy
ch16DSrsvbEVUPHh+52KX2VX4f2MczXoMqDF9rZOGSJzgooqZkour3p3U0Yi4RmJ
BA2MWGjOHpKK8IiufnAmjzj2dS87pfnf3+3YOrgOtK/aAwfrXbmLjpAja6lx4UKN
c+ei0WggGLYoVPjgoTJiEiKNyuTdQc1tbe4sxm7itkyo/HCpuxRXZ9fh3eJZfezr
eaLWcR26icDrixBLhaTB1EE/frJ1epC8CabIIIt1po40Sx+oixAwCYEo9B+DEx7g
IjyKT4GNm/RLJB2NY/tcNDl+oZg1GmrmlTUjMB8akQImxlhTg4urTSWdfBtxkRZx
QObB8xota4Z8QIDwlZqMzqkerNwf+G+ReNhPkm3WSvYXGO9Nr/aAmGhxO1eGo31l
U1r3Z/+rOfuN8D+vm10aeIDOIpecHXFQN8Xl86bLJWCIRQZactcl6ooFmAMCjXE8
JAiqp5Ik7oh/sRdIuUxP9DBeyb9c6ZDla8Sv1UCNKzTC5iBo0T9d2Q0BLmOIc46N
/zF/meV11s016tskepLz0EPsjdDkrxkjK6X0r7vwM+oOjxBthLcjGGhuI++aGzCB
AWl/jTjMhuz1pVntdOHSY0Ib715UbhoFtwCywmIxB/JIky5aVIpb376NG/WCQkBi
W1jHrOGVgjsYigJqxBfa
=TbQS
-----END PGP SIGNATURE-----

--Sig_/VicZwCLwZxCKNuVzo4gaa4F--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
