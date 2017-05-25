Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9A87A6B0279
	for <linux-mm@kvack.org>; Wed, 24 May 2017 21:21:16 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id g13so22006704wmd.9
        for <linux-mm@kvack.org>; Wed, 24 May 2017 18:21:16 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i2si26480038eda.252.2017.05.24.18.21.14
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 24 May 2017 18:21:15 -0700 (PDT)
From: NeilBrown <neilb@suse.com>
Date: Thu, 25 May 2017 11:21:05 +1000
Subject: Re: [RFC PATCH 2/4] mm, tree wide: replace __GFP_REPEAT by __GFP_RETRY_MAYFAIL with more useful semantic
In-Reply-To: <20170307154843.32516-3-mhocko@kernel.org>
References: <20170307154843.32516-1-mhocko@kernel.org> <20170307154843.32516-3-mhocko@kernel.org>
Message-ID: <87a861ivem.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org
Cc: Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, Mar 07 2017, Michal Hocko wrote:

> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> index 2bfcfd33e476..60af7937c6f2 100644
> --- a/include/linux/gfp.h
> +++ b/include/linux/gfp.h
> @@ -25,7 +25,7 @@ struct vm_area_struct;
>  #define ___GFP_FS		0x80u
>  #define ___GFP_COLD		0x100u
>  #define ___GFP_NOWARN		0x200u
> -#define ___GFP_REPEAT		0x400u
> +#define ___GFP_RETRY_MAYFAIL		0x400u
>  #define ___GFP_NOFAIL		0x800u
>  #define ___GFP_NORETRY		0x1000u
>  #define ___GFP_MEMALLOC		0x2000u
> @@ -136,26 +136,38 @@ struct vm_area_struct;
>   *
>   * __GFP_RECLAIM is shorthand to allow/forbid both direct and kswapd rec=
laim.
>   *
> - * __GFP_REPEAT: Try hard to allocate the memory, but the allocation att=
empt
> - *   _might_ fail.  This depends upon the particular VM implementation.
> + * The default allocator behavior depends on the request size. We have a=
 concept
> + * of so called costly allocations (with order > PAGE_ALLOC_COSTLY_ORDER=
).

Boundary conditions is one of my pet peeves....
The description here suggests that an allocation of
"1<<PAGE_ALLOC_COSTLY_ORDER" pages is not "costly", which is
inconsistent with how those words would normally be interpreted.

Looking at the code I see comparisons like:

   order < PAGE_ALLOC_COSTLY_ORDER
or
   order >=3D PAGE_ALLOC_COSTLY_ORDER

which supports the documented (but incoherent) meaning.

But I also see:

  order =3D max_t(int, PAGE_ALLOC_COSTLY_ORDER - 1, 0);

which looks like it is trying to perform the largest non-costly
allocation, but is making a smaller allocation than necessary.

I would *really* like it if the constant actually meant what its name
implied.

 PAGE_ALLOC_MAX_NON_COSTLY
??

> + * !costly allocations are too essential to fail so they are implicitly
> + * non-failing (with some exceptions like OOM victims might fail) by def=
ault while
> + * costly requests try to be not disruptive and back off even without in=
voking
> + * the OOM killer. The following three modifiers might be used to overri=
de some of
> + * these implicit rules
> + *
> + * __GFP_NORETRY: The VM implementation must not retry indefinitely and =
will
> + *   return NULL when direct reclaim and memory compaction have failed t=
o allow
> + *   the allocation to succeed.  The OOM killer is not called with the c=
urrent
> + *   implementation. This is a default mode for costly allocations.

The name here is "NORETRY", but the text says "not retry indefinitely".
So does it retry or not?
I would assuming it "tried" once, and only once.
However it could be that a "try" is not a simple well defined task.
Maybe some escalation happens on the 2nd or 3rd "try", so they are really
trying different things?

The word "indefinitely" implies there is a definite limit.  It might
help to say what that is, or at least say that it is small.

Also, this documentation is phrased to tell the VM implementor what is,
or is not, allowed.  Most readers will be more interested is the
responsibilities of the caller.

  __GFP_NORETRY: The VM implementation will not retry after all
     reasonable avenues for finding free memory have been pursued.  The
     implementation may sleep (i.e. call 'schedule()'), but only while
     waiting for another task to perform some specific action.
     The caller must handle failure.  This flag is suitable when failure can
     easily be handled at small cost, such as reduced throughput.
=20=20

> + *
> + * __GFP_RETRY_MAYFAIL: Try hard to allocate the memory, but the allocat=
ion attempt
> + *   _might_ fail. All viable forms of memory reclaim are tried before t=
he fail.
> + *   The OOM killer is excluded because this would be too disruptive. Th=
is can be
> + *   used to override non-failing default behavior for !costly requests =
as well as
> + *   fortify costly requests.

What does "Try hard" mean?
In part, it means "retry everything a few more times", I guess in the
hope that something happened in the mean time.
It also seems to mean waiting for compaction to happen, which I
guess is only relevant for >PAGE_SIZE allocations?
Maybe it also means waiting for page-out to complete.
So the summary would be that it waits for a little while, hoping for a
miracle.

   __GFP_RETRY_MAYFAIL:  The VM implementation will retry memory reclaim
     procedures that have previously failed if there is some indication
     that progress has been made else where.  It can wait for other
     tasks to attempt high level approaches to freeing memory such as
     compaction (which removed fragmentation) and page-out.
     There is still a definite limit to the number of retries, but it is
     a larger limit than with __GFP_NORERY.
     Allocations with this flag may fail, but only when there is
     genuinely little unused memory.  While these allocations do not
     directly trigger the OOM killer, their failure indicates that the
     system is likely to need to use the OOM killer soon.
     The caller must handle failure, but can reasonably do so by failing
     a higher-level request, or completing it only in a much less
     efficient manner.
     If the allocation does fail, and the caller is in a position to
     free some non-essential memory, doing so could benefit the system
     as a whole.
=20=20=20=20


>   *
>   * __GFP_NOFAIL: The VM implementation _must_ retry infinitely: the call=
er
>   *   cannot handle allocation failures. New users should be evaluated ca=
refully
>   *   (and the flag should be used only when there is no reasonable failu=
re
>   *   policy) but it is definitely preferable to use the flag rather than
> - *   opencode endless loop around allocator.
> - *
> - * __GFP_NORETRY: The VM implementation must not retry indefinitely and =
will
> - *   return NULL when direct reclaim and memory compaction have failed t=
o allow
> - *   the allocation to succeed.  The OOM killer is not called with the c=
urrent
> - *   implementation.
> + *   opencode endless loop around allocator. Using this flag for costly =
allocations
> + *   is _highly_ discouraged.

Should this explicitly say that the OOM killer might be invoked in an attem=
pt
to satisfy this allocation?  Is the OOM killer *only* invoked from
allocations with __GFP_NOFAIL ?
Maybe be extra explicit "The allocation could block indefinitely but
will never return with failure.  Testing for failure is pointless.".


I've probably got several specifics wrong.  I've tried to answer the
questions that I would like to see answered by the documentation.   If
you can fix it up so that those questions are answered correctly, that
would be great.

Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlkmMYEACgkQOeye3VZi
gbkZyg//ZSk3VSzhr1tEg6L9B7HsWZ4a+ErFj4SJLFRtXnPt4FcMjA4N+L0oLJYp
uA/oLrNHpPjybNSsIA45BSpUQuDDwJBaiRV070wbG2ze4X1lAAdc3qurSZC8KH9g
IyUOQSKm8HZ/2+ob+znRQGEdGmDC6oirxakETC0MQ63e3898MHSRnPQb/ZuHI4yD
rEepBESRuVvGU9ZeQb9qI8K+n27jTwdaJkZmd21gJMaJFk7nkVRnoYHa+koSsIiF
uuzj6JgA3P84B0BqMREIaYv98UN5QQ3tfQ+WNn7Az0CCD8hAqIhdji6JxZAMzVPU
Q65cORncbvXPhRhMd+VOILHCKFGv2jOzZXiPnPPJkcTXp148irytyU+iGJ3zhepd
84sTmbb8WXnAA1eUAFSu0G0jqmHcbUA2AcLetJRSqI0J5PNH5OC2421QYiO+cFbp
VTuDdQXXaK8728D8AuZwiCNWtu/yXoPFKFCBvRw+5BLoN6OkXc2zD7PDb/G8XlsF
QceQvk8zcJ1eI9d8J68R9nR9c5pNxEfpe4gPmKeXhJlsDOgyURtre0ZEsSj+AGkd
/07ZNHoh2K03eUiuUWYeRZfIPzDWbaZ30u2Ey/Sl1IHOGERqH+tPvnHqzTaMyzOO
dvX1QFiOfqLu7tBxJXSwjb1D+xcVGENERxU+Fm1XnAYeT6kb260=
=lsyr
-----END PGP SIGNATURE-----
--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
