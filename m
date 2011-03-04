Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 84BC48D0039
	for <linux-mm@kvack.org>; Fri,  4 Mar 2011 16:30:57 -0500 (EST)
Received: by gyb13 with SMTP id 13so1235973gyb.14
        for <linux-mm@kvack.org>; Fri, 04 Mar 2011 13:30:56 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1299272907.2071.1415.camel@dan>
References: <1299174652.2071.12.camel@dan>
	<1299185882.3062.233.camel@calx>
	<1299186986.2071.90.camel@dan>
	<1299188667.3062.259.camel@calx>
	<1299191400.2071.203.camel@dan>
	<2DD7330B-2FED-4E58-A76D-93794A877A00@mit.edu>
	<AANLkTimpfk8EHjVKYsJv0p_G7tS2yB-n=PPbD2v7xefV@mail.gmail.com>
	<1299260164.8493.4071.camel@nimitz>
	<AANLkTim+XcYiiM9u8nT659FHaZO1RPDEtyAgFtiA8VOk@mail.gmail.com>
	<1299262495.3062.298.camel@calx>
	<AANLkTimRN_=APe_PWMFe_6CHHC7psUbCYE-O0qc=mmYY@mail.gmail.com>
	<1299270709.3062.313.camel@calx>
	<1299271377.2071.1406.camel@dan>
	<AANLkTik6tAfaSr3wxdQ1u_Hd326TmNZe0-FQc3NuYMKN@mail.gmail.com>
	<1299272907.2071.1415.camel@dan>
Date: Fri, 4 Mar 2011 23:30:55 +0200
Message-ID: <AANLkTina+O77BFV+7mO9fX2aJimpO0ov_MKwxGtMwqG+@mail.gmail.com>
Subject: Re: [PATCH] Make /proc/slabinfo 0400
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Rosenberg <drosenberg@vsecurity.com>
Cc: Matt Mackall <mpm@selenic.com>, Linus Torvalds <torvalds@linux-foundation.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Theodore Tso <tytso@mit.edu>, cl@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>

Hi Dan,

[ Thanks to you and Matt for taking the time to explain this to me. ]

On Fri, Mar 4, 2011 at 11:08 PM, Dan Rosenberg <drosenberg@vsecurity.com> w=
rote:
> I could be mistaken on this, so feel free to correct me. =A0What if you
> just fill more than one slab with the object you'd like to overflow
> into, then pick an object that's guaranteed to reside in a slab filled
> with your objects. =A0Upon freeing that object and allocating a new
> to-be-overflowed object (that's sized so it's handled by the same slab
> cache), this new object will be guaranteed to be sitting immediately
> before one of your objects (or before the end of the slab if you're
> unlucky). =A0You can still win because it doesn't matter which specific
> object you overflow, only that you overflow one of them.

Right. So you fill a slab with objects A that you want to overflow
(struct shmid_kernel in the example exploit) then free one of them,
allocate object B, smash it (and the next object), and find the
smashed object A.

But doesn't that make the whole /slab/procinfo discussion moot? You
can always use brute force to allocate N objects (where N is larger
than max objects in a slab) and then just free nth object that's most
likely to land on the slab you have full control over (as explained by
Matt).

                        Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
