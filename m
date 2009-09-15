Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 0BEE36B004D
	for <linux-mm@kvack.org>; Tue, 15 Sep 2009 09:50:38 -0400 (EDT)
Received: by qw-out-1920.google.com with SMTP id 5so1179650qwf.44
        for <linux-mm@kvack.org>; Tue, 15 Sep 2009 06:50:44 -0700 (PDT)
Message-ID: <4AAF9BAF.3030109@gmail.com>
Date: Tue, 15 Sep 2009 09:50:39 -0400
From: Gregory Haskins <gregory.haskins@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCHv5 3/3] vhost_net: a kernel-level virtio server
References: <cover.1251388414.git.mst@redhat.com> <20090827160750.GD23722@redhat.com> <20090903183945.GF28651@ovro.caltech.edu> <20090907101537.GH3031@redhat.com> <20090908172035.GB319@ovro.caltech.edu> <4AAA7415.5080204@gmail.com> <20090913120140.GA31218@redhat.com> <4AAE6A97.7090808@gmail.com> <20090914164750.GB3745@redhat.com> <4AAE961B.6020509@gmail.com> <4AAF8A03.5020806@redhat.com> <4AAF909F.9080306@gmail.com> <4AAF95D1.1080600@redhat.com>
In-Reply-To: <4AAF95D1.1080600@redhat.com>
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigE58C3AB1B03AC57412E22747"
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: "Michael S. Tsirkin" <mst@redhat.com>, "Ira W. Snyder" <iws@ovro.caltech.edu>, netdev@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, akpm@linux-foundation.org, hpa@zytor.com, Rusty Russell <rusty@rustcorp.com.au>, s.hetze@linux-ag.com, alacrityvm-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigE58C3AB1B03AC57412E22747
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Avi Kivity wrote:
> On 09/15/2009 04:03 PM, Gregory Haskins wrote:
>>
>>> In this case the x86 is the owner and the ppc boards use translated
>>> access.  Just switch drivers and device and it falls into place.
>>>
>>>     =20
>> You could switch vbus roles as well, I suppose.
>=20
> Right, there's not real difference in this regard.
>=20
>> Another potential
>> option is that he can stop mapping host memory on the guest so that it=

>> follows the more traditional model.  As a bus-master device, the ppc
>> boards should have access to any host memory at least in the GFP_DMA
>> range, which would include all relevant pointers here.
>>
>> I digress:  I was primarily addressing the concern that Ira would need=

>> to manage the "host" side of the link using hvas mapped from userspace=

>> (even if host side is the ppc boards).  vbus abstracts that access so =
as
>> to allow something other than userspace/hva mappings.  OTOH, having ea=
ch
>> ppc board run a userspace app to do the mapping on its behalf and feed=

>> it to vhost is probably not a huge deal either.  Where vhost might
>> really fall apart is when any assumptions about pageable memory occur,=

>> if any.
>>   =20
>=20
> Why?  vhost will call get_user_pages() or copy_*_user() which ought to
> do the right thing.

I was speaking generally, not specifically to Ira's architecture.  What
I mean is that vbus was designed to work without assuming that the
memory is pageable.  There are environments in which the host is not
capable of mapping hvas/*page, but the memctx->copy_to/copy_from
paradigm could still work (think rdma, for instance).

>=20
>> As an aside: a bigger issue is that, iiuc, Ira wants more than a singl=
e
>> ethernet channel in his design (multiple ethernets, consoles, etc).  A=

>> vhost solution in this environment is incomplete.
>>   =20
>=20
> Why?  Instantiate as many vhost-nets as needed.

a) what about non-ethernets?
b) what do you suppose this protocol to aggregate the connections would
look like? (hint: this is what a vbus-connector does).
c) how do you manage the configuration, especially on a per-board basis?

>=20
>> Note that Ira's architecture highlights that vbus's explicit managemen=
t
>> interface is more valuable here than it is in KVM, since KVM already h=
as
>> its own management interface via QEMU.
>>   =20
>=20
> vhost-net and vbus both need management, vhost-net via ioctls and vbus
> via configfs.

Actually I have patches queued to allow vbus to be managed via ioctls as
well, per your feedback (and it solves the permissions/lifetime
critisims in alacrityvm-v0.1).

>  The only difference is the implementation.  vhost-net
> leaves much more to userspace, that's the main difference.

Also,

*) vhost is virtio-net specific, whereas vbus is a more generic device
model where thing like virtio-net or venet ride on top.

*) vhost is only designed to work with environments that look very
similar to a KVM guest (slot/hva translatable).  vbus can bridge various
environments by abstracting the key components (such as memory access).

*) vhost requires an active userspace management daemon, whereas vbus
can be driven by transient components, like scripts (ala udev)

Kind Regards,
-Greg



--------------enigE58C3AB1B03AC57412E22747
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.11 (Darwin)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAkqvm68ACgkQP5K2CMvXmqGjeACfaeq+q8+zPvMaTCbdNBdPCaWg
brsAoIQkXtftjfx+YbkfDtWCeVwCtpDw
=W5uC
-----END PGP SIGNATURE-----

--------------enigE58C3AB1B03AC57412E22747--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
