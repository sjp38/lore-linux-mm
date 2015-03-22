Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f54.google.com (mail-oi0-f54.google.com [209.85.218.54])
	by kanga.kvack.org (Postfix) with ESMTP id 35D816B0038
	for <linux-mm@kvack.org>; Sun, 22 Mar 2015 02:06:15 -0400 (EDT)
Received: by oiag65 with SMTP id g65so119255338oia.2
        for <linux-mm@kvack.org>; Sat, 21 Mar 2015 23:06:15 -0700 (PDT)
Received: from mail-ob0-x22a.google.com (mail-ob0-x22a.google.com. [2607:f8b0:4003:c01::22a])
        by mx.google.com with ESMTPS id 70si3174830oic.132.2015.03.21.23.06.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 21 Mar 2015 23:06:14 -0700 (PDT)
Received: by obdfc2 with SMTP id fc2so103456523obd.3
        for <linux-mm@kvack.org>; Sat, 21 Mar 2015 23:06:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <550A5FF8.90504@gmail.com>
References: <deaa4139de6e6422a0cec1e3282553aed3495e94.1426626497.git.shli@fb.com>
	<20150318153100.5658b741277f3717b52e42d9@linux-foundation.org>
	<550A5FF8.90504@gmail.com>
Date: Sat, 21 Mar 2015 23:06:14 -0700
Message-ID: <CADpJO7zBLhjecbiQeTubnTReiicVLr0-K43KbB4uCL5w_dyqJg@mail.gmail.com>
Subject: Re: [PATCH] mremap: add MREMAP_NOHOLE flag --resend
From: Aliaksey Kandratsenka <alkondratenko@gmail.com>
Content-Type: multipart/alternative; boundary=001a11c313bed05ec80511da5877
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Micay <danielmicay@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Shaohua Li <shli@fb.com>, linux-mm@kvack.org, linux-api@vger.kernel.org, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Andy Lutomirski <luto@amacapital.net>, "google-perftools@googlegroups.com" <google-perftools@googlegroups.com>

--001a11c313bed05ec80511da5877
Content-Type: text/plain; charset=UTF-8

On Wed, Mar 18, 2015 at 10:34 PM, Daniel Micay <danielmicay@gmail.com>
wrote:
>
> On 18/03/15 06:31 PM, Andrew Morton wrote:
> > On Tue, 17 Mar 2015 14:09:39 -0700 Shaohua Li <shli@fb.com> wrote:
> >
> >> There was a similar patch posted before, but it doesn't get merged.
I'd like
> >> to try again if there are more discussions.
> >> http://marc.info/?l=linux-mm&m=141230769431688&w=2
> >>
> >> mremap can be used to accelerate realloc. The problem is mremap will
> >> punch a hole in original VMA, which makes specific memory allocator
> >> unable to utilize it. Jemalloc is an example. It manages memory in 4M
> >> chunks. mremap a range of the chunk will punch a hole, which other
> >> mmap() syscall can fill into. The 4M chunk is then fragmented, jemalloc
> >> can't handle it.
> >
> > Daniel's changelog had additional details regarding the userspace
> > allocators' behaviour.  It would be best to incorporate that into your
> > changelog.
> >
> > Daniel also had microbenchmark testing results for glibc and jemalloc.
> > Can you please do this?
> >
> > I'm not seeing any testing results for tcmalloc and I'm not seeing
> > confirmation that this patch will be useful for tcmalloc.  Has anyone
> > tried it, or sought input from tcmalloc developers?
>
> TCMalloc and jemalloc are currently equally slow in this benchmark, as
> neither makes use of mremap. They're ~2-3x slower than glibc. I CC'ed
> the currently most active TCMalloc developer so they can give input
> into whether this patch would let them use it.


Hi.

Thanks for looping us in for feedback (I'm CC-ing gperftools mailing list).

Yes, that might be useful feature. (Assuming I understood it correctly) I
believe
tcmalloc would likely use:

mremap(old_ptr, move_size, move_size,
       MREMAP_MAYMOVE | MREMAP_FIXED | MREMAP_NOHOLE,
       new_ptr);

as optimized equivalent of:

memcpy(new_ptr, old_ptr, move_size);
madvise(old_ptr, move_size, MADV_DONTNEED);

And btw I find MREMAP_RETAIN name from original patch to be slightly more
intuitive than MREMAP_NOHOLE. In my humble opinion the later name does not
reflect semantic of this feature at all (assuming of course I correctly
understood what the patch does).

I do have a couple of questions about this approach however. Please feel
free to
educate me on them.

a) what is the smallest size where mremap is going to be faster ?

My initial thinking was that we'd likely use mremap in all cases where we
know
that touching destination would cause minor page faults (i.e. when
destination
chunk was MADV_DONTNEED-ed or is brand new mapping). And then also always
when
size is large enough, i.e. because "teleporting" large count of pages is
likely
to be faster than copying them.

But now I realize that it is more interesting than that. I.e. because as
Daniel
pointed out, mremap holds mmap_sem exclusively, while page faults are
holding it
for read. That could be optimized of course. Either by separate "teleport
ptes"
syscall (again, as noted by Daniel), or by having mremap drop mmap_sem for
write
and retaking it for read for "moving pages" part of work. Being not really
familiar with kernel code I have no idea if that's doable or not. But it
looks
like it might be quite important.

Another aspect where I am similarly illiterate is performance effect of tlb
flushes needed for such operation.

We can certainly experiment and find that limit. But if mremap threshold is
going to be large, then perhaps this kernel feature is not as useful as we
may
hope.

b) is that optimization worth having at all ?

After all, memcpy is actually known to be fast. I understand that copying
memory
in user space can be slowed down by minor page faults (results below seem to
confirm that). But this is something where either allocator may retain
populated
pages a bit longer or where kernel could help. E.g. maybe by exposing
something
similar to MAP_POPULATE in madvise, or even doing some safe combination of
madvise and MAP_UNINITIALIZED.

I've played with Daniel's original benchmark (copied from
http://marc.info/?l=linux-mm&m=141230769431688&w=2) with some tiny
modifications:

#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <sys/mman.h>

int main(int argc, char **argv)
{
        if (argc > 1 && strcmp(argv[1], "--mlock") == 0) {
                int rv = mlockall(MCL_CURRENT | MCL_FUTURE);
                if (rv) {
                        perror("mlockall");
                        abort();
                }
                puts("mlocked!");
        }

        for (size_t i = 0; i < 64; i++) {
                void *ptr = NULL;
                size_t old_size = 0;
                for (size_t size = 4; size < (1 << 30); size *= 2) {
                        /*
                         * void *hole = malloc(1 << 20);
                         * if (!hole) {
                         *      perror("malloc");
                         *      abort();
                         * }
                         */
                        ptr = realloc(ptr, size);
                        if (!ptr) {
                                perror("realloc");
                                abort();
                        }
                        /* free(hole); */
                        memset(ptr + old_size, 0xff, size - old_size);
                        old_size = size;
                }
                free(ptr);
        }
}

I cannot say if this benchmark's vectors of up to 0.5 gigs are common in
important applications or not. It can be argued that apps that care about
such
large vectors can do mremap themselves.

On the other hand, I believe that this micro benchmark could be plausibly
changed to grow vector by smaller factor (i.e. see
https://github.com/facebook/folly/blob/master/folly/docs/FBVector.md#memory-handling).
And
with smaller growth factor, is seems reasonable to expect larger overhead
from
memcpy and smaller overhead from mremap. And thus favor mremap more.

And I confirm that with all default settings tcmalloc and jemalloc lose to
glibc. Also, notably, recent dev build of jemalloc (what is going to be 4.0
AFAIK) actually matches or exceeds glibc speed, despite still not doing
mremap. Apparently it is smarter about avoiding moving allocation for those
realloc-s. And it was even able to resist my attempt to force it to move
allocation. I haven't investigated why. Note that I built it couple weeks
or so
ago from dev branch, so it might simply have bugs.

Results also vary greatly depending in transparent huge pages setting.
Here's
what I've got:

allocator |   mode    | time  | sys time | pgfaults |             extra
----------+-----------+-------+----------+----------+-------------------------------
glibc     |           | 10.75 |     8.44 |  8388770 |
glibc     |    thp    |  5.67 |     3.44 |   310882 |
glibc     |   mlock   | 13.22 |     9.41 |  8388821 |
glibc     | thp+mlock |  8.43 |     4.63 |   310933 |
tcmalloc  |           | 11.46 |     2.00 |  2104826 |
TCMALLOC_AGGRESSIVE_DECOMMIT=f
tcmalloc  |    thp    | 10.61 |     0.89 |   386206 |
TCMALLOC_AGGRESSIVE_DECOMMIT=f
tcmalloc  |   mlock   | 10.11 |     0.27 |   264721 |
TCMALLOC_AGGRESSIVE_DECOMMIT=f
tcmalloc  | thp+mlock | 10.28 |     0.17 |    46011 |
TCMALLOC_AGGRESSIVE_DECOMMIT=f
tcmalloc  |           | 23.63 |    17.16 | 16770107 |
TCMALLOC_AGGRESSIVE_DECOMMIT=t
tcmalloc  |    thp    | 11.82 |     5.14 |   352477 |
TCMALLOC_AGGRESSIVE_DECOMMIT=t
tcmalloc  |   mlock   | 10.10 |     0.28 |   264724 |
TCMALLOC_AGGRESSIVE_DECOMMIT=t
tcmalloc  | thp+mlock | 10.30 |     0.17 |    49168 |
TCMALLOC_AGGRESSIVE_DECOMMIT=t
jemalloc1 |           | 23.71 |    17.33 | 16744572 |
jemalloc1 |    thp    | 11.65 |     4.68 |    64988 |
jemalloc1 |   mlock   | 10.13 |     0.29 |   263305 |
jemalloc1 | thp+mlock | 10.05 |     0.17 |    50217 |
jemalloc2 |           | 10.87 |     8.64 |  8521796 |
jemalloc2 |    thp    |  4.64 |     2.32 |    56060 |
jemalloc2 |   mlock   |  4.22 |     0.28 |   263181 |
jemalloc2 | thp+mlock |  4.12 |     0.19 |    50411 |
----------+-----------+-------+----------+----------+-------------------------------

NOTE: usual disclaimer applies about possibility of screwing something up
and
getting invalid benchmark results without being able to see it. I apologize
in
advance.

NOTE: jemalloc1 is 3.6 as shipped by up-to-date Debian Sid. jemalloc2 is
home-built snapshot of upcoming jemalloc 4.0.

NOTE: TCMALLOC_AGGRESSIVE_DECOMMIT=t (and default since 2.4) makes tcmalloc
MADV_DONTNEED large free blocks immediately. As opposed to less rare with
setting of "false". And it makes big difference on page faults counts and
thus
on runtime.

Another notable thing is how mlock effectively disables MADV_DONTNEED for
jemalloc{1,2} and tcmalloc, lowers page faults count and thus improves
runtime. It can be seen that tcmalloc+mlock on thp-less configuration is
slightly better on runtime to glibc. The later spends a ton of time in
kernel,
probably handling minor page faults, and the former burns cpu in user space
doing memcpy-s. So "tons of memcpys" seems to be competitive to what glibc
is
doing in this benchmark.

THP changes things however. Where apparently minor page faults become a lot
cheaper. Which makes glibc case a lot faster than even tcmalloc+mlock case.
So
in THP case, cost of page faults is smaller than cost of large memcpy.

So results are somewhat mixed, but overall I'm not sure that I'm able to see
very convincing story for MREMAP_HOLE yet. However:

1) it is possible that I am missing something. If so, please, educate me.

2) if kernel implements this API, I'm going to use it in tcmalloc.

P.S. benchmark results also seem to indicate that tcmalloc could do
something to
explicitly enable THP and maybe better adapt to it's presence. Perhaps with
some
collaboration with kernel, i.e. to prevent that famous delay-ful-ness which
causes people to disable THP.

--001a11c313bed05ec80511da5877
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><br><br>On Wed, Mar 18, 2015 at 10:34 PM, Daniel Micay &lt=
;<a href=3D"mailto:danielmicay@gmail.com">danielmicay@gmail.com</a>&gt; wro=
te:<br>&gt;<br>&gt; On 18/03/15 06:31 PM, Andrew Morton wrote:<br>&gt; &gt;=
 On Tue, 17 Mar 2015 14:09:39 -0700 Shaohua Li &lt;<a href=3D"mailto:shli@f=
b.com">shli@fb.com</a>&gt; wrote:<br>&gt; &gt;<br>&gt; &gt;&gt; There was a=
 similar patch posted before, but it doesn&#39;t get merged. I&#39;d like<b=
r>&gt; &gt;&gt; to try again if there are more discussions.<br>&gt; &gt;&gt=
; <a href=3D"http://marc.info/?l=3Dlinux-mm&amp;m=3D141230769431688&amp;w=
=3D2">http://marc.info/?l=3Dlinux-mm&amp;m=3D141230769431688&amp;w=3D2</a><=
br>&gt; &gt;&gt;<br>&gt; &gt;&gt; mremap can be used to accelerate realloc.=
 The problem is mremap will<br>&gt; &gt;&gt; punch a hole in original VMA, =
which makes specific memory allocator<br>&gt; &gt;&gt; unable to utilize it=
. Jemalloc is an example. It manages memory in 4M<br>&gt; &gt;&gt; chunks. =
mremap a range of the chunk will punch a hole, which other<br>&gt; &gt;&gt;=
 mmap() syscall can fill into. The 4M chunk is then fragmented, jemalloc<br=
>&gt; &gt;&gt; can&#39;t handle it.<br>&gt; &gt;<br>&gt; &gt; Daniel&#39;s =
changelog had additional details regarding the userspace<br>&gt; &gt; alloc=
ators&#39; behaviour.=C2=A0 It would be best to incorporate that into your<=
br>&gt; &gt; changelog.<br>&gt; &gt;<br>&gt; &gt; Daniel also had microbenc=
hmark testing results for glibc and jemalloc.<br>&gt; &gt; Can you please d=
o this?<br>&gt; &gt;<br>&gt; &gt; I&#39;m not seeing any testing results fo=
r tcmalloc and I&#39;m not seeing<br>&gt; &gt; confirmation that this patch=
 will be useful for tcmalloc.=C2=A0 Has anyone<br>&gt; &gt; tried it, or so=
ught input from tcmalloc developers?<br>&gt;<br>&gt; TCMalloc and jemalloc =
are currently equally slow in this benchmark, as<br>&gt; neither makes use =
of mremap. They&#39;re ~2-3x slower than glibc. I CC&#39;ed<br>&gt; the cur=
rently most active TCMalloc developer so they can give input<br>&gt; into w=
hether this patch would let them use it.<br><br><br>Hi.<br><br>Thanks for l=
ooping us in for feedback (I&#39;m CC-ing gperftools mailing list).<br><br>=
Yes, that might be useful feature. (Assuming I understood it correctly) I b=
elieve<br>tcmalloc would likely use:<br><br>mremap(old_ptr, move_size, move=
_size,<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0MREMAP_MAYMOVE | MREMAP_FIXED | MREMAP=
_NOHOLE,<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0new_ptr);<br><br>as optimized equiva=
lent of:<br><br>memcpy(new_ptr, old_ptr, move_size);<br>madvise(old_ptr, mo=
ve_size, MADV_DONTNEED);<br><br>And btw I find MREMAP_RETAIN name from orig=
inal patch to be slightly more<br>intuitive than MREMAP_NOHOLE. In my humbl=
e opinion the later name does not<br>reflect semantic of this feature at al=
l (assuming of course I correctly<br>understood what the patch does).<br><b=
r>I do have a couple of questions about this approach however. Please feel =
free to<br>educate me on them.<br><br>a) what is the smallest size where mr=
emap is going to be faster ?<br><br>My initial thinking was that we&#39;d l=
ikely use mremap in all cases where we know<br>that touching destination wo=
uld cause minor page faults (i.e. when destination<br>chunk was MADV_DONTNE=
ED-ed or is brand new mapping). And then also always when<br>size is large =
enough, i.e. because &quot;teleporting&quot; large count of pages is likely=
<br>to be faster than copying them.<br><br>But now I realize that it is mor=
e interesting than that. I.e. because as Daniel<br>pointed out, mremap hold=
s mmap_sem exclusively, while page faults are holding it<br>for read. That =
could be optimized of course. Either by separate &quot;teleport ptes&quot;<=
br>syscall (again, as noted by Daniel), or by having mremap drop mmap_sem f=
or write<br>and retaking it for read for &quot;moving pages&quot; part of w=
ork. Being not really<br>familiar with kernel code I have no idea if that&#=
39;s doable or not. But it looks<br>like it might be quite important.<br><b=
r>Another aspect where I am similarly illiterate is performance effect of t=
lb<br>flushes needed for such operation.<br><br>We can certainly experiment=
 and find that limit. But if mremap threshold is<br>going to be large, then=
 perhaps this kernel feature is not as useful as we may<br>hope.<br><br>b) =
is that optimization worth having at all ?<br><br>After all, memcpy is actu=
ally known to be fast. I understand that copying memory<br>in user space ca=
n be slowed down by minor page faults (results below seem to<br>confirm tha=
t). But this is something where either allocator may retain populated<br>pa=
ges a bit longer or where kernel could help. E.g. maybe by exposing somethi=
ng<br>similar to MAP_POPULATE in madvise, or even doing some safe combinati=
on of<br>madvise and MAP_UNINITIALIZED.<br><br>I&#39;ve played with Daniel&=
#39;s original benchmark (copied from<br><a href=3D"http://marc.info/?l=3Dl=
inux-mm&amp;m=3D141230769431688&amp;w=3D2">http://marc.info/?l=3Dlinux-mm&a=
mp;m=3D141230769431688&amp;w=3D2</a>) with some tiny<br>modifications:<br><=
font face=3D"monospace, monospace"><br>#include &lt;string.h&gt;<br>#includ=
e &lt;stdlib.h&gt;<br>#include &lt;stdio.h&gt;<br>#include &lt;sys/mman.h&g=
t;<br><br>int main(int argc, char **argv)<br>{<br>=C2=A0 =C2=A0 =C2=A0 =C2=
=A0 if (argc &gt; 1 &amp;&amp; strcmp(argv[1], &quot;--mlock&quot;) =3D=3D =
0) {<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 int rv =3D =
mlockall(MCL_CURRENT | MCL_FUTURE);<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 if (rv) {<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 perror(&quot;mlockall&quot;);<br=
>=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 abort();<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 }<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 puts(&quot=
;mlocked!&quot;);<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0 }<br><br>=C2=A0 =C2=A0 =C2=
=A0 =C2=A0 for (size_t i =3D 0; i &lt; 64; i++) {<br>=C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 void *ptr =3D NULL;<br>=C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 size_t old_size =3D 0;<br>=C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 for (size_t size =3D 4; size =
&lt; (1 &lt;&lt; 30); size *=3D 2) {<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /*<br>=C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* voi=
d *hole =3D malloc(1 &lt;&lt; 20);<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* if (!hole) {<br>=
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0* =C2=A0 =C2=A0 =C2=A0perror(&quot;malloc&quot;);<br>=C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0* =C2=A0 =C2=A0 =C2=A0abort();<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* }<br>=C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0*/<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 ptr =3D realloc(ptr, size);<br>=C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!ptr=
) {<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 perror(&quot;realloc&quot;);<=
br>=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 abort();<br>=C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }<br>=C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 /* free(hole); */<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 memset(ptr + old_size, 0xff, size - old_=
size);<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 old_size =3D size;<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 }<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 free(ptr);<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0 }<br>}<br></font><br>I=
 cannot say if this benchmark&#39;s vectors of up to 0.5 gigs are common in=
<br>important applications or not. It can be argued that apps that care abo=
ut such<br>large vectors can do mremap themselves.<br><br>On the other hand=
, I believe that this micro benchmark could be plausibly<br>changed to grow=
 vector by smaller factor (i.e. see<br><a href=3D"https://github.com/facebo=
ok/folly/blob/master/folly/docs/FBVector.md#memory-handling">https://github=
.com/facebook/folly/blob/master/folly/docs/FBVector.md#memory-handling</a>)=
. And<br>with smaller growth factor, is seems reasonable to expect larger o=
verhead from<br>memcpy and smaller overhead from mremap. And thus favor mre=
map more.<br><br>And I confirm that with all default settings tcmalloc and =
jemalloc lose to<br>glibc. Also, notably, recent dev build of jemalloc (wha=
t is going to be 4.0<br>AFAIK) actually matches or exceeds glibc speed, des=
pite still not doing<br>mremap. Apparently it is smarter about avoiding mov=
ing allocation for those<br>realloc-s. And it was even able to resist my at=
tempt to force it to move<br>allocation. I haven&#39;t investigated why. No=
te that I built it couple weeks or so<br>ago from dev branch, so it might s=
imply have bugs.<br><br>Results also vary greatly depending in transparent =
huge pages setting. Here&#39;s<br>what I&#39;ve got:<br><br><font face=3D"m=
onospace, monospace">allocator | =C2=A0 mode =C2=A0 =C2=A0| time =C2=A0| sy=
s time | pgfaults | =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 extra<br>----=
------+-----------+-------+----------+----------+--------------------------=
-----<br>glibc =C2=A0 =C2=A0 | =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | 10.75 |=
 =C2=A0 =C2=A0 8.44 | =C2=A08388770 |<br>glibc =C2=A0 =C2=A0 | =C2=A0 =C2=
=A0thp =C2=A0 =C2=A0| =C2=A05.67 | =C2=A0 =C2=A0 3.44 | =C2=A0 310882 |<br>=
glibc =C2=A0 =C2=A0 | =C2=A0 mlock =C2=A0 | 13.22 | =C2=A0 =C2=A0 9.41 | =
=C2=A08388821 |<br>glibc =C2=A0 =C2=A0 | thp+mlock | =C2=A08.43 | =C2=A0 =
=C2=A0 4.63 | =C2=A0 310933 |<br>tcmalloc =C2=A0| =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 | 11.46 | =C2=A0 =C2=A0 2.00 | =C2=A02104826 | TCMALLOC_AGGRESSI=
VE_DECOMMIT=3Df<br>tcmalloc =C2=A0| =C2=A0 =C2=A0thp =C2=A0 =C2=A0| 10.61 |=
 =C2=A0 =C2=A0 0.89 | =C2=A0 386206 | TCMALLOC_AGGRESSIVE_DECOMMIT=3Df<br>t=
cmalloc =C2=A0| =C2=A0 mlock =C2=A0 | 10.11 | =C2=A0 =C2=A0 0.27 | =C2=A0 2=
64721 | TCMALLOC_AGGRESSIVE_DECOMMIT=3Df<br>tcmalloc =C2=A0| thp+mlock | 10=
.28 | =C2=A0 =C2=A0 0.17 | =C2=A0 =C2=A046011 | TCMALLOC_AGGRESSIVE_DECOMMI=
T=3Df<br>tcmalloc =C2=A0| =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | 23.63 | =C2=
=A0 =C2=A017.16 | 16770107 | TCMALLOC_AGGRESSIVE_DECOMMIT=3Dt<br>tcmalloc =
=C2=A0| =C2=A0 =C2=A0thp =C2=A0 =C2=A0| 11.82 | =C2=A0 =C2=A0 5.14 | =C2=A0=
 352477 | TCMALLOC_AGGRESSIVE_DECOMMIT=3Dt<br>tcmalloc =C2=A0| =C2=A0 mlock=
 =C2=A0 | 10.10 | =C2=A0 =C2=A0 0.28 | =C2=A0 264724 | TCMALLOC_AGGRESSIVE_=
DECOMMIT=3Dt<br>tcmalloc =C2=A0| thp+mlock | 10.30 | =C2=A0 =C2=A0 0.17 | =
=C2=A0 =C2=A049168 | TCMALLOC_AGGRESSIVE_DECOMMIT=3Dt<br>jemalloc1 | =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | 23.71 | =C2=A0 =C2=A017.33 | 16744572 |<br>j=
emalloc1 | =C2=A0 =C2=A0thp =C2=A0 =C2=A0| 11.65 | =C2=A0 =C2=A0 4.68 | =C2=
=A0 =C2=A064988 |<br>jemalloc1 | =C2=A0 mlock =C2=A0 | 10.13 | =C2=A0 =C2=
=A0 0.29 | =C2=A0 263305 |<br>jemalloc1 | thp+mlock | 10.05 | =C2=A0 =C2=A0=
 0.17 | =C2=A0 =C2=A050217 |<br>jemalloc2 | =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 | 10.87 | =C2=A0 =C2=A0 8.64 | =C2=A08521796 |<br>jemalloc2 | =C2=A0 =
=C2=A0thp =C2=A0 =C2=A0| =C2=A04.64 | =C2=A0 =C2=A0 2.32 | =C2=A0 =C2=A0560=
60 |<br>jemalloc2 | =C2=A0 mlock =C2=A0 | =C2=A04.22 | =C2=A0 =C2=A0 0.28 |=
 =C2=A0 263181 |<br>jemalloc2 | thp+mlock | =C2=A04.12 | =C2=A0 =C2=A0 0.19=
 | =C2=A0 =C2=A050411 |<br>----------+-----------+-------+----------+------=
----+-------------------------------</font><br><br>NOTE: usual disclaimer a=
pplies about possibility of screwing something up and<br>getting invalid be=
nchmark results without being able to see it. I apologize in<br>advance.<br=
><br>NOTE: jemalloc1 is 3.6 as shipped by up-to-date Debian Sid. jemalloc2 =
is<br>home-built snapshot of upcoming jemalloc 4.0.<br><br>NOTE: TCMALLOC_A=
GGRESSIVE_DECOMMIT=3Dt (and default since 2.4) makes tcmalloc<br>MADV_DONTN=
EED large free blocks immediately. As opposed to less rare with<br>setting =
of &quot;false&quot;. And it makes big difference on page faults counts and=
 thus<br>on runtime.<br><br>Another notable thing is how mlock effectively =
disables MADV_DONTNEED for<br>jemalloc{1,2} and tcmalloc, lowers page fault=
s count and thus improves<br>runtime. It can be seen that tcmalloc+mlock on=
 thp-less configuration is<br>slightly better on runtime to glibc. The late=
r spends a ton of time in kernel,<br>probably handling minor page faults, a=
nd the former burns cpu in user space<br>doing memcpy-s. So &quot;tons of m=
emcpys&quot; seems to be competitive to what glibc is<br>doing in this benc=
hmark.<br><br>THP changes things however. Where apparently minor page fault=
s become a lot<br>cheaper. Which makes glibc case a lot faster than even tc=
malloc+mlock case. So<br>in THP case, cost of page faults is smaller than c=
ost of large memcpy.<br><br><div>So results are somewhat mixed, but overall=
 I&#39;m not sure that I&#39;m able to see</div><div>very convincing story =
for MREMAP_HOLE yet. However:</div><div><br></div>1) it is possible that I =
am missing something. If so, please, educate me.<br><br>2) if kernel implem=
ents this API, I&#39;m going to use it in tcmalloc.<br><br>P.S. benchmark r=
esults also seem to indicate that tcmalloc could do something to<br>explici=
tly enable THP and maybe better adapt to it&#39;s presence. Perhaps with so=
me<br>collaboration with kernel, i.e. to prevent that famous delay-ful-ness=
 which<br>causes people to disable THP.<br><div><br></div></div>

--001a11c313bed05ec80511da5877--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
