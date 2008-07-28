Received: by ti-out-0910.google.com with SMTP id j3so2276318tid.8
        for <linux-mm@kvack.org>; Mon, 28 Jul 2008 10:37:57 -0700 (PDT)
Date: Mon, 28 Jul 2008 20:35:54 +0300
From: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
Subject: Re: [RFC PATCH 1/4] kmemtrace: Core implementation.
Message-ID: <20080728173549.GA5185@localhost>
References: <1216751808-14428-1-git-send-email-eduard.munteanu@linux360.ro> <1216751808-14428-2-git-send-email-eduard.munteanu@linux360.ro> <1217237084.5998.5.camel@penberg-laptop> <20080728162916.GD17823@Krystal>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="SLDf9lqlvOQaIe6s"
Content-Disposition: inline
In-Reply-To: <20080728162916.GD17823@Krystal>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, cl@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, rdunlap@xenotime.net, mpm@selenic.com, Steven Rostedt <rostedt@goodmis.org>, Thomas Gleixner <tglx@linutronix.de>
List-ID: <linux-mm.kvack.org>

--SLDf9lqlvOQaIe6s
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Jul 28, 2008 at 12:29:17PM -0400, Mathieu Desnoyers wrote:
> Hmm ? why record an invalid event ?? I see it's not used in the code, is
> that actually used in some way because the memory is set to 0 ?

The relay interface is really inconsistent and produces erroneous output
if it's not used in a specific way. It's nice to be able to catch these
errors if they occur (e.g. in case we have a regression).

> > > +	Target CPU	(4 bytes)	Signed integer, valid for event id 1.
> > > +					If equal to -1, target CPU is the same
> > > +					as origin CPU, but the reverse might
> > > +					not be true.
>=20
> If only valid for event ID 1 and only in NUMA case, please don't waste
> space in each event header and make that a event-specific field... ?

Yes, this would probably be a better approach.

> > > +	Caller address	(8 bytes)	Return address to the caller.
>=20
> Not true on 32 bits machines. You are wasting 4 bytes on those archs.

Pekka suggested we use types that have constant size on every arch. I
could change this.

> 8 bytes for GFP flags ?? Whoah, that's a lot of one-hot bits ! :) I knew
> that some allocators were bloated, bit not that much. :)

This could change too, but if the number of GFP flags is too close to
32, I'd rather keep the ABI stable, providing for a larger number of GFP
flags.

> > > +	Timestamp	(8 bytes)	Signed integer representing timestamp.
> > > +
>=20
> With a heartbeat, as lttng does, you can cut that to a 4 bytes field.

Hmm, I'll look at lttng's code and see what exactly you are talking
about. For now, I'm not sure how 32-bit timestamps perform.

> > > +The data is made available in the same endianness the machine has.
> > > +
>=20
> Using a magic number in the trace header lets you deal with
> cross-endianness.

Why? I mean I can do this in the userspace app when I record the data.

> Saving the type sizes in the trace header lets you deal with different
> int/long/pointer type sizes.
>=20
> > > +Other event ids and type ids may be defined and added. Other fields =
may be
> > > +added by increasing event size. Every modification to the ABI, inclu=
ding
> > > +new id definitions, are followed by bumping the ABI version by one.
> > > +
>=20
> I personally prefer a self-describing trace :)

ASCII/text? :)
I'm not sure what you meant, but non-binary traces would result in huge
amounts of data.

> Not currently true : cross-endianness/wastes space for 32 bits archs.

Sure, cross-endianness is not even currently implemented in the
userspace app.

> > > +	- be fast and anticipate usage in high-load environments (*)
>=20
> LTTng will be faster though : per-cpu atomic ops instead of interrupt
> disable makes the probe faster.

I'm not sure how one could record a timestamp orderly into relay buffers
using only atomic ops and no locks.

> > > +	- be reasonably extensible
>=20
> Automatic description of markers and dynamic assignation of IDs to
> markers should provide a bit more flexibility here.

Dynamic assignation makes it hard to preserve ABI compatibility with the
userspace app. And Pekka suggested it's important to preserve it in
order to allow distros to include kmemtrace.
=20
> > > +	- make it possible for GNU/Linux distributions to have kmemtrace
> > > +	included in their repositories
> > > +
> > > +(*) - one of the reasons Pekka Enberg's original userspace data anal=
ysis
> > > +    tool's code was rewritten from Perl to C (although this is more =
than a
> > > +    simple conversion)
> > > +
> > > +
> > > +III. Quick usage guide
> > > +=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> > > +
> > > +1) Get a kernel that supports kmemtrace and build it accordingly (i.=
e. enable
> > > +CONFIG_KMEMTRACE and CONFIG_DEFAULT_ENABLED).
> > > +
> > > +2) Get the userspace tool and build it:
> > > +$ git-clone git://repo.or.cz/kmemtrace-user.git		# current repository
> > > +$ cd kmemtrace-user/
> > > +$ ./autogen.sh
> > > +$ ./configure
> > > +$ make
> > > +
> > > +3) Boot the kmemtrace-enabled kernel if you haven't, preferably in t=
he
> > > +'single' runlevel (so that relay buffers don't fill up easily), and =
run
> > > +kmemtrace:
> > > +# '$' does not mean user, but root here.
>=20
> Change the documentation to prefix a root command line by "#" instead of
> leaving this weird comment.

Yes, it's probably better. I just wanted to avoid a user taking that as
a comment.

> What in the world can be causing that ? Shouldn't it be fixed ? It might
> be due to unexpected allocator behavior, non-instrumented alloc/free
> code or broken tracer....

Of course it will be fixed. But this FAQ entry also serves as a warning
that future allocator patches could introduce untraced functions.
=20
> > > +struct kmemtrace_event {
> > > +	u8		event_id;	/* Allocate or free? */
> > > +	u8		type_id;	/* Kind of allocation/free. */
> > > +	u16		event_size;	/* Size of event */
> > > +	s32		node;		/* Target CPU. */
> > > +	u64		call_site;	/* Caller address. */
> > > +	u64		ptr;		/* Pointer to allocation. */
> > > +	u64		bytes_req;	/* Number of bytes requested. */
> > > +	u64		bytes_alloc;	/* Number of bytes allocated. */
> > > +	u64		gfp_flags;	/* Requested flags. */
> > > +	s64		timestamp;	/* When the operation occured in ns. */
> > > +} __attribute__ ((__packed__));
> > > +
>=20
> See below for detail, but this event record is way too big and not
> adapted to 32 bits architectures.

Pekka, what do you think?

> > > +static inline void kmemtrace_mark_free(enum kmemtrace_type_id type_i=
d,
> > > +				       unsigned long call_site,
> > > +				       const void *ptr)
> > > +{
> > > +	trace_mark(kmemtrace_free, "type_id %d call_site %lu ptr %lu",
> > > +		   type_id, call_site, (unsigned long) ptr);
> > > +}
>=20
> This could be trivially turned into a tracepoint probe.

Okay, will rebase my patches on a tracepoints-enabled branch. How close
are they to mainline?

> > > +
> > > +#define KMEMTRACE_SUBBUF_SIZE	(8192 * sizeof(struct kmemtrace_event))
> > > +#define KMEMTRACE_N_SUBBUFS	20
> > > +
>=20
> Isn't this overridable by a command line param ? Shouldn't it be called
> "DEFAULT_KMEMTRACE_*" then ?

I wanted to avoid using too long macro names. But I can change this.

> > > +static struct rchan *kmemtrace_chan;
> > > +static u32 kmemtrace_buf_overruns;
> > > +
> > > +static unsigned int kmemtrace_n_subbufs;
> > > +#ifdef CONFIG_KMEMTRACE_DEFAULT_ENABLED
> > > +static unsigned int kmemtrace_enabled =3D 1;
> > > +#else
> > > +static unsigned int kmemtrace_enabled =3D 0;
> > > +#endif
>=20
> Hrm, I'd leave that as a kernel command line option, not config option.
> If you ever want to _aways_ have it on, then change your lilo/grub file.

Not quite true. I saw a few kernel subsystems that provide compile-time opt=
ions
for those arches where supplying command-line options is hard/impossible.

> > > +	 * Don't convert this to use structure initializers,
> > > +	 * C99 does not guarantee the rvalues evaluation order.
> > > +	 */
> > > +	ev.event_id =3D KMEMTRACE_EVENT_ALLOC;
> > > +	ev.type_id =3D va_arg(*args, int);
> > > +	ev.event_size =3D sizeof(struct kmemtrace_event);
> > > +	ev.call_site =3D va_arg(*args, unsigned long);
> > > +	ev.ptr =3D va_arg(*args, unsigned long);
>=20
> Argh, and you do a supplementary copy here. You could simply alias the
> buffers and write directly to them after reserving the correct amount of
> space.

Oh, good point. I could use relay_reserve() here.

> > > +	/* Don't trace ignored allocations. */
> > > +	if (!ev.ptr)
> > > +		return;
> > > +	ev.bytes_req =3D va_arg(*args, unsigned long);
> > > +	ev.bytes_alloc =3D va_arg(*args, unsigned long);
> > > +	/* ev.timestamp set below, to preserve event ordering. */
> > > +	ev.gfp_flags =3D va_arg(*args, unsigned long);
> > > +	ev.node =3D va_arg(*args, int);
> > > +
> > > +	/* We disable IRQs for timestamps to match event ordering. */
> > > +	local_irq_save(flags);
> > > +	ev.timestamp =3D ktime_to_ns(ktime_get());
>=20
> ktime_get is monotonic, but with potentially coarse granularity. I see
> that you use ktime_to_ns here, which gives you a resolution of 1 timer
> tick in the case where the TSCs are not synchronized. While it should be
> "good enough" for the scheduler, I doubt it's enough for a tracer.
>=20
> It also takes the xtime seqlock, which adds a potentially big delay to
> the tracing code (if you read the clock while the writer lock is taken).
>=20
> Also, when NTP modifies the clock, although it stays monotonic, the rate
> at which it increments can dramatically change. I doubt you want to use
> that as a reference for performance analysis.

What would you suggest instead?

Please keep in mind timer resolution is not that critical, we're not
benchmarking the allocators cycle-wise; instead we're merely looking at
allocation lifetimes, fragmentation, patterns etc.. Timestamps are most
important for reordering events in userspace.

> > > +static int __init kmemtrace_set_boot_enabled(char *str)
> > > +{
> > > +	if (!str)
> > > +		return -EINVAL;
> > > +
> > > +	if (!strcmp(str, "yes"))
>=20
> I think the standard is to use =3D0, =3D1 here, not =3Dyes, =3Dno ?

Okay.

> Mathieu
>=20
> --=20
> Mathieu Desnoyers
> OpenPGP key fingerprint: 8CD5 52C3 8E3C 4140 715F  BA06 3F25 A8FE 3BAE 9A=
68

Thanks for your comments.


	Cheers,
	Eduard


--SLDf9lqlvOQaIe6s
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.7 (GNU/Linux)

iQIVAwUBSI4DddxcOkuRpXptAQL9Fg//Shsn1N8zzt6Ev2ED4dZg9+GSubqlWHnV
MnjieEXpW/qbl01FkJ09ZqbiNAAQEqkeJN94OmAKroFtfksPsQRaNrJ9hJ28/1b3
dsgSMahoHYtwt8QpNSGlQLWiwcIejRqmskvbAsweB4WIa4NbjtUQ0uy9wVgCmuJ2
uxdKlcyFzLIVIwffLDPFnUjYGyXZ4n+51ba1lMmkKJX6L9Z08Qui15S/dANS1AYa
uvhGZIwUcmQjYnZy8arFO5VUDUgegjFvV9Lcy9COfo+hi3hxg2usDFQAPe1Lnity
qu5pkGnO316BzF5/YYxGlAy3LaFU4XCP5CKegtcoZVC/gG8hbsau/z85sw15+q9E
qibctxuXN+n35OxpULD/iuABcucRaicR9ATZN2kh2w5UqgvIHzFU+vXoTXVOwMew
1+PWLm9jZqGvlleiiNgE/Qn+PTvDuK+vleRIdKfXKD5YXfN4IbmGs8E6Wg1k5B2x
aPouHhVfdax3FthCf01uaqPY/LhvCeaK2VRjE8XAm0KOw+ccy2KZHinLqLqUOw2E
TrNZdEEA7ntF39BBu03ycGJjDRsOLjR9wuhR37rbMViDzU6z9/+U6RjqYrIG1HMu
71MkoXBKID1/RtZNyfLcbEqhM07DnQp9RKHQoHDffRSw29n8AV+hieLZxGDacnDx
D5D9XPjlPgM=
=Gv+Z
-----END PGP SIGNATURE-----

--SLDf9lqlvOQaIe6s--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
