Subject: Re: migratepage failures on reiserfs
From: Zan Lynx <zlynx@acm.org>
In-Reply-To: <4727B979.8030207@us.ibm.com>
References: <1193768824.8904.11.camel@dyn9047017100.beaverton.ibm.com>
	 <20071030135442.5d33c61c@think.oraclecorp.com>
	 <1193781245.8904.28.camel@dyn9047017100.beaverton.ibm.com>
	 <20071030185840.48f5a10b@think.oraclecorp.com>
	 <4727B979.8030207@us.ibm.com>
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-rnt15PnDYb7aVOWipuCx"
Date: Wed, 31 Oct 2007 00:05:26 +0000
Message-Id: <1193789126.7320.34.camel@localhost>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari <pbadari@us.ibm.com>
Cc: Chris Mason <chris.mason@oracle.com>, reiserfs-devel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

--=-rnt15PnDYb7aVOWipuCx
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


On Tue, 2007-10-30 at 16:08 -0700, Badari wrote:
> Chris Mason wrote:
> > On Tue, 30 Oct 2007 13:54:05 -0800
[cut]
> > The easy way to narrow our search is to try without data=3Dordered, it =
is
> > certainly complicating things.
> >  =20
>=20
> I can try that, its my root filesystem :(

You meant to write "can't?"

Download BusyBox and build it into an initramfs.  It's pretty easy, you
can do it yourself.  Or you could download the Debian mkinitramfs (I
think) package and look at it.  Or the Fedora equivalent (I think
mkinitrd).

Then you can boot into that and mount your / with whatever options you
like.

Here's what I use for my own custom BusyBox initramfs /init script:
#!/bin/sh

get_arg() {
	local arg=3D"$1"
	local x=3D`cat /proc/cmdline`
	for i in $x; do
		if [ "${i%=3D*}" =3D "$arg" ]; then
			echo ${i#*=3D}
			break
		fi
	done
}

do_switch() {
	mount -t proc none /proc
	local root=3D`get_arg root`
	local flags=3D`get_arg rootflags`
	mount "$root" /new ${flags:+-o "$flags"}
	umount /proc
	cd /new
	exec switch_root . /sbin/init
}

do_shell() {
	exec /sbin/init
}

# The following will wait 2 seconds for Enter before booting.
trap "do_switch" ALRM

target=3D$$
( sleep 2; kill -ALRM $target ) &
alarm=3D$!

echo -n "Press Enter for a shell: "
while read action; do
	kill $alarm
	break
done
do_shell

--=20
Zan Lynx <zlynx@acm.org>

--=-rnt15PnDYb7aVOWipuCx
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.7 (GNU/Linux)

iD8DBQBHJ8bGG8fHaOLTWwgRAs3SAJ48lwrAe6tUS2HMcof4YUlRN+ip5wCeLdzm
8SgJtBGqFrgWSYrlbN30Ejo=
=DNiW
-----END PGP SIGNATURE-----

--=-rnt15PnDYb7aVOWipuCx--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
