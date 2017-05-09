Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5E74D831F8
	for <linux-mm@kvack.org>; Tue,  9 May 2017 18:03:33 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id g67so3554204wrd.0
        for <linux-mm@kvack.org>; Tue, 09 May 2017 15:03:33 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 9si1301178wml.49.2017.05.09.15.03.30
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 09 May 2017 15:03:31 -0700 (PDT)
From: NeilBrown <neil@brown.name>
Date: Wed, 10 May 2017 08:03:13 +1000
Subject: Re: [PATCH v4 13/27] lib: add errseq_t type and infrastructure for handling it
In-Reply-To: <20170509154930.29524-14-jlayton@redhat.com>
References: <20170509154930.29524-1-jlayton@redhat.com> <20170509154930.29524-14-jlayton@redhat.com>
Message-ID: <87inl9n0wu.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Layton <jlayton@redhat.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org, linux-mm@kvack.org, jfs-discussion@lists.sourceforge.net, linux-xfs@vger.kernel.org, cluster-devel@redhat.com, linux-f2fs-devel@lists.sourceforge.net, v9fs-developer@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-block@vger.kernel.org
Cc: dhowells@redhat.com, akpm@linux-foundation.org, hch@infradead.org, ross.zwisler@linux.intel.com, mawilcox@microsoft.com, jack@suse.com, viro@zeniv.linux.org.uk, corbet@lwn.net, neilb@suse.de, clm@fb.com, tytso@mit.edu, axboe@kernel.dk, josef@toxicpanda.com, hubcap@omnibond.com, rpeterso@redhat.com, bo.li.liu@oracle.com

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, May 09 2017, Jeff Layton wrote:

> An errseq_t is a way of recording errors in one place, and allowing any
> number of "subscribers" to tell whether an error has been set again
> since a previous time.
>
> It's implemented as an unsigned 32-bit value that is managed with atomic
> operations. The low order bits are designated to hold an error code
> (max size of MAX_ERRNO). The upper bits are used as a counter.
>
> The API works with consumers sampling an errseq_t value at a particular
> point in time. Later, that value can be used to tell whether new errors
> have been set since that time.
>
> Note that there is a 1 in 512k risk of collisions here if new errors
> are being recorded frequently, since we have so few bits to use as a
> counter. To mitigate this, one bit is used as a flag to tell whether the
> value has been sampled since a new value was recorded. That allows
> us to avoid bumping the counter if no one has sampled it since it
> was last bumped.
>
> Later patches will build on this infrastructure to change how writeback
> errors are tracked in the kernel.
>
> Signed-off-by: Jeff Layton <jlayton@redhat.com>

I like that this is a separate lib/*.c - nicely structured too.

Reviewed-by: NeilBrown <neilb@suse.com>

Thanks,
NeilBrown


> ---
>  include/linux/errseq.h |  19 +++++
>  lib/Makefile           |   2 +-
>  lib/errseq.c           | 199 +++++++++++++++++++++++++++++++++++++++++++=
++++++
>  3 files changed, 219 insertions(+), 1 deletion(-)
>  create mode 100644 include/linux/errseq.h
>  create mode 100644 lib/errseq.c
>
> diff --git a/include/linux/errseq.h b/include/linux/errseq.h
> new file mode 100644
> index 000000000000..0d2555f310cd
> --- /dev/null
> +++ b/include/linux/errseq.h
> @@ -0,0 +1,19 @@
> +#ifndef _LINUX_ERRSEQ_H
> +#define _LINUX_ERRSEQ_H
> +
> +/* See lib/errseq.c for more info */
> +
> +typedef u32	errseq_t;
> +
> +void __errseq_set(errseq_t *eseq, int err);
> +static inline void errseq_set(errseq_t *eseq, int err)
> +{
> +	/* Optimize for the common case of no error */
> +	if (unlikely(err))
> +		__errseq_set(eseq, err);
> +}
> +
> +errseq_t errseq_sample(errseq_t *eseq);
> +int errseq_check(errseq_t *eseq, errseq_t since);
> +int errseq_check_and_advance(errseq_t *eseq, errseq_t *since);
> +#endif
> diff --git a/lib/Makefile b/lib/Makefile
> index 320ac46a8725..2423afef40f7 100644
> --- a/lib/Makefile
> +++ b/lib/Makefile
> @@ -41,7 +41,7 @@ obj-y +=3D bcd.o div64.o sort.o parser.o debug_locks.o =
random32.o \
>  	 gcd.o lcm.o list_sort.o uuid.o flex_array.o iov_iter.o clz_ctz.o \
>  	 bsearch.o find_bit.o llist.o memweight.o kfifo.o \
>  	 percpu-refcount.o percpu_ida.o rhashtable.o reciprocal_div.o \
> -	 once.o refcount.o
> +	 once.o refcount.o errseq.o
>  obj-y +=3D string_helpers.o
>  obj-$(CONFIG_TEST_STRING_HELPERS) +=3D test-string_helpers.o
>  obj-y +=3D hexdump.o
> diff --git a/lib/errseq.c b/lib/errseq.c
> new file mode 100644
> index 000000000000..0f8b4ed460f0
> --- /dev/null
> +++ b/lib/errseq.c
> @@ -0,0 +1,199 @@
> +#include <linux/err.h>
> +#include <linux/bug.h>
> +#include <linux/atomic.h>
> +#include <linux/errseq.h>
> +
> +/*
> + * An errseq_t is a way of recording errors in one place, and allowing a=
ny
> + * number of "subscribers" to tell whether it has changed since an arbit=
rary
> + * time of their choosing.
> + *
> + * It's implemented as an unsigned 32-bit value. The low order bits are
> + * designated to hold an error code (between 0 and -MAX_ERRNO). The uppe=
r bits
> + * are used as a counter. This is done with atomics instead of locking s=
o that
> + * these functions can be called from any context.
> + *
> + * The general idea is for consumers to sample an errseq_t value at a
> + * particular point in time. Later, that value can be used to tell wheth=
er any
> + * new errors have occurred since that time.
> + *
> + * Note that there is a risk of collisions, if new errors are being reco=
rded
> + * frequently, since we have so few bits to use as a counter.
> + *
> + * To mitigate this, one bit is used as a flag to tell whether the value=
 has
> + * been sampled since a new value was recorded. That allows us to avoid =
bumping
> + * the counter if no one has sampled it since the last time an error was
> + * recorded.
> + *
> + * A new errseq_t should always be zeroed out.  A errseq_t value of all =
zeroes
> + * is the special (but common) case where there has never been an error.=
 An all
> + * zero value thus serves as the "epoch" if one wishes to know whether t=
here
> + * has ever been an error set since it was first initialized.
> + */
> +
> +/* The low bits are designated for error code (max of MAX_ERRNO) */
> +#define ERRSEQ_SHIFT		ilog2(MAX_ERRNO + 1)
> +
> +/* This bit is used as a flag to indicate whether the value has been see=
n */
> +#define ERRSEQ_SEEN		(1 << ERRSEQ_SHIFT)
> +
> +/* The "ones" bit for the counter */
> +#define ERRSEQ_CTR_INC		(1 << (ERRSEQ_SHIFT + 1))
> +
> +/**
> + * __errseq_set - set a errseq_t for later reporting
> + * @eseq: errseq_t field that should be set
> + * @err: error to set
> + *
> + * This function sets the error in *eseq, and increments the sequence co=
unter
> + * if the last sequence was sampled at some point in the past.
> + *
> + * Any error set will always overwrite an existing error.
> + *
> + * Most callers will want to use the errseq_set inline wrapper to effici=
ently
> + * handle the common case where err is 0.
> + */
> +void __errseq_set(errseq_t *eseq, int err)
> +{
> +	errseq_t old;
> +
> +	/* MAX_ERRNO must be able to serve as a mask */
> +	BUILD_BUG_ON_NOT_POWER_OF_2(MAX_ERRNO + 1);
> +
> +	/*
> +	 * Ensure the error code actually fits where we want it to go. If it
> +	 * doesn't then just throw a warning and don't record anything. We
> +	 * also don't accept zero here as that would effectively clear a
> +	 * previous error.
> +	 */
> +	if (WARN(unlikely(err =3D=3D 0 || (unsigned int)-err > MAX_ERRNO),
> +				"err =3D %d\n", err))
> +		return;
> +
> +	old =3D READ_ONCE(*eseq);
> +	for (;;) {
> +		errseq_t new, cur;
> +
> +		/* Clear out error bits and set new error */
> +		new =3D (old & ~(MAX_ERRNO|ERRSEQ_SEEN)) | -err;
> +
> +		/* Only increment if someone has looked at it */
> +		if (old & ERRSEQ_SEEN)
> +			new +=3D ERRSEQ_CTR_INC;
> +
> +		/* If there would be no change, then call it done */
> +		if (new =3D=3D old)
> +			break;
> +
> +		/* Try to swap the new value into place */
> +		cur =3D cmpxchg(eseq, old, new);
> +
> +		/*
> +		 * Call it success if we did the swap or someone else beat us
> +		 * to it for the same value.
> +		 */
> +		if (likely(cur =3D=3D old || cur =3D=3D new))
> +			break;
> +
> +		/* Raced with an update, try again */
> +		old =3D cur;
> +	}
> +}
> +EXPORT_SYMBOL(__errseq_set);
> +
> +/**
> + * errseq_sample - grab current errseq_t value
> + * @eseq: pointer to errseq_t to be sampled
> + *
> + * This function allows callers to sample an errseq_t value, marking it =
as
> + * "seen" if required.
> + */
> +errseq_t errseq_sample(errseq_t *eseq)
> +{
> +	errseq_t old =3D READ_ONCE(*eseq);
> +	errseq_t new =3D old;
> +
> +	/*
> +	 * For the common case of no errors ever having been set, we can skip
> +	 * marking the SEEN bit. Once an error has been set, the value will
> +	 * never go back to zero.
> +	 */
> +	if (old !=3D 0) {
> +		new |=3D ERRSEQ_SEEN;
> +		if (old !=3D new)
> +			cmpxchg(eseq, old, new);
> +	}
> +	return new;
> +}
> +EXPORT_SYMBOL(errseq_sample);
> +
> +/**
> + * errseq_check - has an error occurred since a particular point in time?
> + * @eseq: pointer to errseq_t value to be checked
> + * @since: previously-sampled errseq_t from which to check
> + *
> + * Grab the value that eseq points to, and see if it has changed "since"
> + * the given value was sampled. The "since" value is not advanced, so th=
ere
> + * is no need to mark the value as seen.
> + *
> + * Returns the latest error set in the errseq_t or 0 if it hasn't change=
d.
> + */
> +int errseq_check(errseq_t *eseq, errseq_t since)
> +{
> +	errseq_t cur =3D READ_ONCE(*eseq);
> +
> +	if (likely(cur =3D=3D since))
> +		return 0;
> +	return -(cur & MAX_ERRNO);
> +}
> +EXPORT_SYMBOL(errseq_check);
> +
> +/**
> + * errseq_check_and_advance - check an errseq_t and advance it to the cu=
rrent value
> + * @eseq: pointer to value being checked reported
> + * @since: pointer to previously-sampled errseq_t to check against and a=
dvance
> + *
> + * Grab the eseq value, and see whether it matches the value that "since"
> + * points to. If it does, then just return 0.
> + *
> + * If it doesn't, then the value has changed. Set the "seen" flag, and t=
ry to
> + * swap it into place as the new eseq value. Then, set that value as the=
 new
> + * "since" value, and return whatever the error portion is set to.
> + *
> + * Note that no locking is provided here for concurrent updates to the "=
since"
> + * value. The caller must provide that if necessary. Because of this, ca=
llers
> + * may want to do a lockless errseq_check before taking the lock and cal=
ling
> + * this.
> + */
> +int errseq_check_and_advance(errseq_t *eseq, errseq_t *since)
> +{
> +	int err =3D 0;
> +	errseq_t old, new;
> +
> +	/*
> +	 * Most callers will want to use the inline wrapper to check this,
> +	 * so that the common case of no error is handled without needing
> +	 * to lock.
> +	 */
> +	old =3D READ_ONCE(*eseq);
> +	if (old !=3D *since) {
> +		/*
> +		 * Set the flag and try to swap it into place if it has
> +		 * changed.
> +		 *
> +		 * We don't care about the outcome of the swap here. If the
> +		 * swap doesn't occur, then it has either been updated by a
> +		 * writer who is bumping the seq count anyway, or another
> +		 * reader who is just setting the "seen" flag. Either outcome
> +		 * is OK, and we can advance "since" and return an error based
> +		 * on what we have.
> +		 */
> +		new =3D old | ERRSEQ_SEEN;
> +		if (new !=3D old)
> +			cmpxchg(eseq, old, new);
> +		*since =3D new;
> +		err =3D -(new & MAX_ERRNO);
> +	}
> +	return err;
> +}
> +EXPORT_SYMBOL(errseq_check_and_advance);
> --=20
> 2.9.3
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-btrfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlkSPKEACgkQOeye3VZi
gbnuIxAAh+uwr7ld5xG/+sJ34NQGClTF5XiM8XKxTPt2KqGf1ub0p8+BybGKM+QU
K8ccb9N6DbIxJBQRF4SE8IrmD8lsXOt9wtukewcU0QFSJdLGpXC3knZ5AbRWfSYs
jNNiY/nTIMWTHFvmTvI5CV6jYms5t74IyN5qBZr63YZ5wV7Vmf9MwZNRu2hdjMD1
fLSaxbwbiLh1Lgwvjg2IFvcRPKNDeMgJV7UNHbTm6IofEETccs1JbNx6dWRXOJ8C
pQzn1k69vsht6rcl1wZHtrSenXJh5u3pw5NekKRFyhg+sb89jBORPnINQWSCI1fI
iZLg9f57jmiBRLPKm22LkgQQmHlMYQ8POct6Uh1BgvSf/0ob5f6vuxj8Cp93uWoR
Tbdz55R9OLfAhdCqltG32SC7avQP6xj/OndP1BXpFac7X+j2+kIZaDUqACvB1Uc1
XpsAozqut2ZdepA/60Bxf4B2DdxEv9VmUVxYsztr/742fFDX5EB1xL/yQlzLjsgY
mHYWIWsuOdVqGaH2Wry0aABurx6kW/qFqEQ2Xkoc152WX5PFZnU2uQk1a4IFBxDM
Dj/yLNuHBAUy3actoadIj2ttg4EY3HrAfnpDxxvg2gF4aTS1jqAeOkv/euk0b4NN
gimJWImKKEdRKuWOfBHtGe8gwuOwrQbIKkUIX4Dz+Yg086nNv+0=
=XxtA
-----END PGP SIGNATURE-----
--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
