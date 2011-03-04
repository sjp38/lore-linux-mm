Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 567758D0039
	for <linux-mm@kvack.org>; Fri,  4 Mar 2011 12:49:46 -0500 (EST)
Received: from mail-iw0-f169.google.com (mail-iw0-f169.google.com [209.85.214.169])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id p24Hn81b013239
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=FAIL)
	for <linux-mm@kvack.org>; Fri, 4 Mar 2011 09:49:08 -0800
Received: by iwl42 with SMTP id 42so2857524iwl.14
        for <linux-mm@kvack.org>; Fri, 04 Mar 2011 09:49:08 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1299260164.8493.4071.camel@nimitz>
References: <1299174652.2071.12.camel@dan> <1299185882.3062.233.camel@calx>
 <1299186986.2071.90.camel@dan> <1299188667.3062.259.camel@calx>
 <1299191400.2071.203.camel@dan> <2DD7330B-2FED-4E58-A76D-93794A877A00@mit.edu>
 <AANLkTimpfk8EHjVKYsJv0p_G7tS2yB-n=PPbD2v7xefV@mail.gmail.com> <1299260164.8493.4071.camel@nimitz>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 4 Mar 2011 09:48:47 -0800
Message-ID: <AANLkTim+XcYiiM9u8nT659FHaZO1RPDEtyAgFtiA8VOk@mail.gmail.com>
Subject: Re: [PATCH] Make /proc/slabinfo 0400
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Pekka Enberg <penberg@kernel.org>, Theodore Tso <tytso@mit.edu>, Dan Rosenberg <drosenberg@vsecurity.com>, Matt Mackall <mpm@selenic.com>, cl@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>

On Fri, Mar 4, 2011 at 9:36 AM, Dave Hansen <dave@linux.vnet.ibm.com> wrote=
:
>
> We need to either keep the bad guys away from the counts (this patch),
> or de-correlate the counts moving around with the position of objects in
> the slab. =A0Ted's suggestion is a good one, and the only other thing I
> can think of is to make the values useless, perhaps by batching and
> delaying the (exposed) counts by a random amount.

We might just decide to expose the 'active' count for regular users
(and then, in case there are tools there that parse this as normal
users, we could set the 'total' fields to be the same as the active
one, possibly rounded up to the slab allocation or something.

I know, I know, from a memory usage standpoint, 'active' is secondary,
but it still correlates fairly well, so it's still useful.  And for
seeing memory leaks (as opposed to slab fragmentation etc issues),
it's actually the interesting case.

And at the same time, it's actually much less involved with actual
physical allocations than 'total' is, and thus much less of an attack
vector. The fact that we got another socket allocation when we opened
a new socket is not "useful" information for an attacker, not in the
way it is to see a hint of _where_ the socket got allocated.

Of course, as you say, '/proc/meminfo' still does give you the trigger
for "oh, now somebody actually allocated a new page". That's totally
independent of slabinfo, though (and knowing the number of active
slabs would neither help nor hurt somebody who uses meminfo - you
might as well allocate new sockets in a loop, and use _only_ meminfo
to see when that allocated a new page).

                                    Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
