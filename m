Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 4BD786B00AF
	for <linux-mm@kvack.org>; Mon,  3 Jan 2011 09:10:54 -0500 (EST)
Received: by qyk10 with SMTP id 10so13874270qyk.14
        for <linux-mm@kvack.org>; Mon, 03 Jan 2011 06:10:51 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1294062351.3948.7.camel@gandalf.stny.rr.com>
References: <E1PZXeb-0004AV-2b@tytso-glaptop>
	<AANLkTi=9ZNk6w8PxvveWHy5+okfTyKUj3L2ywFOuFjoq@mail.gmail.com>
	<AANLkTinz52Ky5BhU-gHq8vx9=1uoN+iuDn1f0C8fnSjQ@mail.gmail.com>
	<1294062351.3948.7.camel@gandalf.stny.rr.com>
Date: Mon, 3 Jan 2011 16:10:51 +0200
Message-ID: <AANLkTik9VodSjNnubf4Psbb9TgOEufw0m2q1_e5+X165@mail.gmail.com>
Subject: Re: Should we be using unlikely() around tests of GFP_ZERO?
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Minchan Kim <minchan.kim@gmail.com>, Theodore Ts'o <tytso@mit.edu>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, David Rientjes <rientjes@google.com>, npiggin@kernel.dk
List-ID: <linux-mm.kvack.org>

On Mon, Jan 3, 2011 at 3:45 PM, Steven Rostedt <rostedt@goodmis.org> wrote:
> On Mon, 2011-01-03 at 09:40 +0200, Pekka Enberg wrote:
>> Hi,
>>
>> On Mon, Jan 3, 2011 at 8:48 AM, Theodore Ts'o <tytso@mit.edu> wrote:
>> >> Given the patches being busily submitted by trivial patch submitters =
to
>> >> make use kmem_cache_zalloc(), et. al, I believe we should remove the
>> >> unlikely() tests around the (gfp_flags & __GFP_ZERO) tests, such as:
>> >>
>> >> - =A0 =A0 =A0 if (unlikely((flags & __GFP_ZERO) && objp))
>> >> + =A0 =A0 =A0 if ((flags & __GFP_ZERO) && objp)
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0memset(objp, 0, obj_size(cachep));
>> >>
>> >> Agreed? =A0If so, I'll send a patch...
>>
>> On Mon, Jan 3, 2011 at 5:46 AM, Minchan Kim <minchan.kim@gmail.com> wrot=
e:
>> > I support it.
>>
>> I guess the rationale here is that if you're going to take the hit of
>> memset() you can take the hit of unlikely() as well. We're optimizing
>> for hot call-sites that allocate a small amount of memory and
>> initialize everything themselves. That said, I don't think the
>> unlikely() annotation matters much either way and am for removing it
>> unless people object to that.
>>
>> On Mon, Jan 3, 2011 at 5:46 AM, Minchan Kim <minchan.kim@gmail.com> wrot=
e:
>> > Recently Steven tried to gather the information.
>> > http://thread.gmane.org/gmane.linux.kernel/1072767
>> > Maybe he might have a number for that.
>>
>> That would be interesting, sure.
>
> Note, you could do it yourself too. Just enable:
>
> =A0Kernel Hacking -> Tracers -> Branch Profiling
> =A0 =A0(Trace likely/unlikely profiler)
>
> =A0 CONFIG_PROFILE_ANNOTATED_BRANCHES
>
> Then search /debug/tracing/trace_stats/branch_annotated.
>
> (hmm, the help in Kconfig is wrong, I need to fix that)
>
>
> Anyway, here's my box. I just started it an hour ago, and have not been
> doing too much on it yet. But here's what I got (using SLUB)
>
>
> =A0correct incorrect =A0% =A0 =A0 =A0 =A0Function =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0File =A0 =A0 =A0 =A0 =A0 =A0 =A0Line
> =A0------- --------- =A0- =A0 =A0 =A0 =A0-------- =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0---- =A0 =A0 =A0 =A0 =A0 =A0 =A0----
> =A06890998 =A02784830 =A028 =A0 =A0 =A0 =A0slab_alloc =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0slub.c =A0 =A0 =A0 =A0 =A0 =A01719
>
> That's incorrect 28% of the time.

Thanks! AFAICT, that number is high enough to justify removing the
unlikely() annotations, no?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
