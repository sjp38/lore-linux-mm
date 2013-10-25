Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 4440A6B00DD
	for <linux-mm@kvack.org>; Fri, 25 Oct 2013 18:11:33 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id w10so2729743pde.3
        for <linux-mm@kvack.org>; Fri, 25 Oct 2013 15:11:32 -0700 (PDT)
Received: from psmtp.com ([74.125.245.180])
        by mx.google.com with SMTP id gj2si6250483pac.138.2013.10.25.15.11.30
        for <linux-mm@kvack.org>;
        Fri, 25 Oct 2013 15:11:31 -0700 (PDT)
Date: Sat, 26 Oct 2013 09:11:12 +1100
From: NeilBrown <neilb@suse.de>
Subject: Re: Disabling in-memory write cache for x86-64 in Linux II
Message-ID: <20131026091112.241da260@notabene.brown>
In-Reply-To: <476525596.14731.1382735024280.JavaMail.mail@webmail11>
References: <160824051.3072.1382685914055.JavaMail.mail@webmail07>
	<20131025214952.3eb41201@notabene.brown>
	<alpine.DEB.2.02.1310250425270.22538@nftneq.ynat.uz>
	<154617470.12445.1382725583671.JavaMail.mail@webmail11>
	<20131026074349.0adc9646@notabene.brown>
	<476525596.14731.1382735024280.JavaMail.mail@webmail11>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/rrWLFApImeDIgsMleg656mr"; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Artem S. Tashkinov" <t.artem@lycos.com>
Cc: david@lang.hm, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, linux-fsdevel@vger.kernel.org, axboe@kernel.dk, linux-mm@kvack.org

--Sig_/rrWLFApImeDIgsMleg656mr
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Fri, 25 Oct 2013 21:03:44 +0000 (UTC) "Artem S. Tashkinov"
<t.artem@lycos.com> wrote:

> Oct 26, 2013 02:44:07 AM, neil wrote:
> On Fri, 25 Oct 2013 18:26:23 +0000 (UTC) "Artem S. Tashkinov"
> >>=20
> >> Exactly. And not being able to use applications which show you IO perf=
ormance
> >> like Midnight Commander. You might prefer to use "cp -a" but I cannot =
imagine
> >> my life without being able to see the progress of a copying operation.=
 With the current
> >> dirty cache there's no way to understand how you storage media actuall=
y behaves.
> >
> >So fix Midnight Commander.  If you want the copy to be actually finished=
 when
> >it says  it is finished, then it needs to call 'fsync()' at the end.
>=20
> This sounds like a very bad joke. How applications are supposed to show a=
nd
> calculate an _average_ write speed if there are no kernel calls/ioctls to=
 actually
> make the kernel flush dirty buffers _during_ copying? Actually it's a goo=
d way to
> solve this problem in user space - alas, even if such calls are implement=
ed, user
> space will start using them only in 2018 if not further from that.

But there is a way to flush dirty buffers *during* copies. =20
  man 2 sync_file_range

if giving precise feedback is is paramount importance to you, then this wou=
ld
be the interface to use.
>=20
> >>=20
> >> Per device dirty cache seems like a nice idea, I, for one, would like =
to disable it
> >> altogether or make it an absolute minimum for things like USB flash dr=
ives - because
> >> I don't care about multithreaded performance or delayed allocation on =
such devices -
> >> I'm interested in my data reaching my USB stick ASAP - because it's ho=
w most people
> >> use them.
> >>
> >
> >As has already been said, you can substantially disable  the cache by tu=
ning
> >down various values in /proc/sys/vm/.
> >Have you tried?
>=20
> I don't understand who you are replying to. I asked about per device sett=
ings, you are
> again referring me to system wide settings - they don't look that good if=
 we're talking
> about a 3MB/sec flash drive and 500MB/sec SSD drive. Besides it makes no =
sense
> to allocate 20% of physical RAM for things which don't belong to it in th=
e first place.

Sorry, missed the per-device bit.
You could try playing with
  /sys/class/bdi/XX:YY/max_ratio

where XX:YY is the major/minor number of the device, so 8:0 for /dev/sda.
Wind it right down for slow devices and you might get something like what y=
ou
want.


>=20
> I don't know any other OS which has a similar behaviour.

I don't know about the internal details of any other OS, so I cannot really
comment.

>=20
> And like people (including me) have already mentioned, such a huge dirty =
cache can
> stall their PCs/servers for a considerable amount of time.

Yes.  But this is a different issue.
There are two very different issues that should be kept separate.

One is that when "cp" or similar complete, the data hasn't all be written o=
ut
yet.  It typically takes another 30 seconds before the flush will complete.
You seemed to primarily complain about this, so that is what I originally
address.  That is where in the "dirty_*_centisecs" values apply.

The other, quite separate, issue is that Linux will cache more dirty data
than it can write out in a reasonable time.  All the tuning parameters refer
to the amount of data (whether as a percentage of RAM or as a number of
bytes), but what people really care about is a number of seconds.

As you might imagine, estimating how long it will take to write out a certa=
in
amount of data is highly non-trivial.  The relationship between megabytes a=
nd
seconds can be non-linear and can change over time.

Caching nothing at all can hurt a lot of workloads.  Caching too much can
obviously hurt too.  Caching "5 seconds" worth of data would be ideal, but
would be incredibly difficult to implement.
It is possible that keeping a sliding estimate of device throughput for each
device would be possible, and using that to automatically adjust the
"max_ratio" value (or some related internal thing) might be a 70% solution.

Certainly it would be an interesting project for someone.


>=20
> Of course, if you don't use Linux on the desktop you don't really care - =
well, I do. Also
> not everyone in this world has an UPS - which means such a huge buffer ca=
n lead to a
> serious data loss in case of a power blackout.

I don't have a desk (just a lap), but I use Linux on all my computers and
I've never really noticed the problem.  Maybe I'm just very patient, or may=
be
I don't work with large data sets and slow devices.

However I don't think data-loss is really a related issue.  Any process that
cares about data safety *must* use fsync at appropriate places.  This has
always been true.

NeilBrown

>=20
> Regards,
>=20
> Artem


--Sig_/rrWLFApImeDIgsMleg656mr
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUmrsgDnsnt1WYoG5AQJ4BRAAu4vKVv8ecehnzp1wUp6/oN1n1Bqlae4H
oL9uZdxbmcfrkoq3n/IKkpVqc/Rt9ps0Zcx9LLHcheGmSghQwSOE7fxzUUHtkaXA
dZlFshh2kbR0qrwa4/ogrmYLbhi6JrT6vQKFDbn6sp4UdeHhauBUHHKhpaxypEHL
HoSVSsnG9OOWB3H0i8NLe9z19jTdSOKT6SOiZf0M8+OonR/M7oJVuaH0k1Gclcw0
U4wzrPjaGaAAHB0b6VL8v64OZnasgz9G8MfRGZ5Ff+Ui5UZ2W2u33mx+IvCs/wnu
MDq55S0pRI6t8dl79FgdYhcxySUY7etynbe2rUBOlLe5fo4LUQjG80wLwODB0N9q
DPb0sVH6NxmB6NSLSOaTZpXaNQlIG0nAxDgo1rt7uCknpScSlHmz3p4DqeGp892S
MNP3cxOQFSYT7Y8/DY1ChnwJ/U099NdVWWnGfRco0qSlCZ3R/+Mf3ejere0bl/PL
QCZSvneQVS6eejyd8G23Ka2WxaTkG6/NzpQlE9QkVQ2uf/I+LYgQPeYoAK5Jdlna
k8O6QWVlOVsQsCHcMJAhqRJBQKde0g7T4SQjs1aR59cfd/kRY4ts0U0klIWsGwmc
OCJd8HKLrdMPF2Ufl006QiJ0oTp7a/O9cyWj4jJQoaqZBGISP4kEpH5MGUBSz3lX
FOsv7ZmhC8s=
=Hz1y
-----END PGP SIGNATURE-----

--Sig_/rrWLFApImeDIgsMleg656mr--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
