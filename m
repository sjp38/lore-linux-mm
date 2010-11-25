Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id E864D6B004A
	for <linux-mm@kvack.org>; Thu, 25 Nov 2010 10:33:03 -0500 (EST)
Received: by iwn5 with SMTP id 5so50284iwn.14
        for <linux-mm@kvack.org>; Thu, 25 Nov 2010 07:33:02 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1290619929.10586.6.camel@nimitz>
References: <AANLkTikg-sR97tkG=ST9kjZcHe6puYSvMGh-eA3cnH7X@mail.gmail.com>
	<20101122161158.02699d10.akpm@linux-foundation.org>
	<1290501502.2390.7029.camel@nimitz>
	<AANLkTik2Fn-ynUap2fPcRxRdKA=5ZRYG0LJTmqf80y+q@mail.gmail.com>
	<1290529171.2390.7994.camel@nimitz>
	<AANLkTikCn-YvORocXSJ1Z+ovYNMhKF7TaX=BHWKwrQup@mail.gmail.com>
	<AANLkTi=mgTHPEYFsryDYnxPa78f-Nr+H7i4+0KPZbxh3@mail.gmail.com>
	<1290619929.10586.6.camel@nimitz>
Date: Thu, 25 Nov 2010 16:33:01 +0100
Message-ID: <AANLkTikT-svqverRLr7Mf6s-17VrOcP_BpyXFpDV=_7s@mail.gmail.com>
Subject: Re: Sudden and massive page cache eviction
From: =?UTF-8?Q?Peter_Sch=C3=BCller?= <scode@spotify.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Mattias de Zalenski <zalenski@spotify.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> simple thing to do in any case. =C2=A0You can watch the entries in slabin=
fo
> and see if any of the ones with sizes over 4096 bytes are getting used
> often. =C2=A0You can also watch /proc/buddyinfo and see how often columns
> other than the first couple are moving around.

I collected some information from
/proc/{buddyinfo,meminfo,slabinfo,vmstat} and let it sit, polling
approximately once per minute. I have some results correlated with
another page eviction in graphs. The graph is here:

   http://files.spotify.com/memcut/memgraph-20101124.png

The last sudden eviction there occurred somewhere between 22:30 and
22:45. Some URL:s that can be compared for those periods:

   Before:
   http://files.spotify.com/memcut/memstat-20101124/2010-11-24T22:39:30/vms=
tat
   http://files.spotify.com/memcut/memstat-20101124/2010-11-24T22:39:30/bud=
dyinfo
   http://files.spotify.com/memcut/memstat-20101124/2010-11-24T22:39:30/mem=
info
   http://files.spotify.com/memcut/memstat-20101124/2010-11-24T22:39:30/sla=
binfo

   After:
   http://files.spotify.com/memcut/memstat-20101124/2010-11-24T22:45:31/vms=
tat
   http://files.spotify.com/memcut/memstat-20101124/2010-11-24T22:45:31/bud=
dyinfo
   http://files.spotify.com/memcut/memstat-20101124/2010-11-24T22:45:31/mem=
info
   http://files.spotify.com/memcut/memstat-20101124/2010-11-24T22:45:31/sla=
binfo

A more complete set of files for several minutes before/after/during
is in this tarball:

   http://files.spotify.com/memcut/memgraph-20101124.tar.gz

Diffing the two slabinfos above yields among other things the
following expected or at least plausible decreases since they
correlate with the symptomes:

-ext3_inode_cache  254638 693552    760   43    8 : tunables    0    0
   0 : slabdata  16130  16130      0
+ext3_inode_cache   81698 468958    760   43    8 : tunables    0    0
   0 : slabdata  10906  10906      0
-dentry             96504 344232    192   42    2 : tunables    0    0
   0 : slabdata   8196   8196      0
+dentry             55628 243810    192   42    2 : tunables    0    0
   0 : slabdata   5805   5805      0

And if my understanding is correct, buffer_head would be meta-data
associated with cached pages and thus be expected to drop in
correlation with less data cached:

-buffer_head       2109250 4979052    104   39    1 : tunables    0
0    0 : slabdata 127668 127668      0
+buffer_head       838859 4059822    104   39    1 : tunables    0
0    0 : slabdata 104098 104098      0

My knowledge of the implementation is lacking far too much to know
where best to look for the likely culprit in terms of the root cause
of the eviction. The one thing I thought looked suspicious was the
kmalloc increases:

-kmalloc-4096         301    328   4096    8    8 : tunables    0    0
   0 : slabdata     41     41      0
+kmalloc-4096         637    680   4096    8    8 : tunables    0    0
   0 : slabdata     85     85      0
-kmalloc-2048       18215  19696   2048   16    8 : tunables    0    0
   0 : slabdata   1231   1231      0
+kmalloc-2048       41908  51792   2048   16    8 : tunables    0    0
   0 : slabdata   3237   3237      0
-kmalloc-1024       85444  97280   1024   32    8 : tunables    0    0
   0 : slabdata   3040   3040      0
+kmalloc-1024      267031 327104   1024   32    8 : tunables    0    0
   0 : slabdata  10222  10222      0
-kmalloc-512         1988   2176    512   32    4 : tunables    0    0
   0 : slabdata     68     68      0
+kmalloc-512         1692   2080    512   32    4 : tunables    0    0
   0 : slabdata     65     65      0
-kmalloc-256       102588 119776    256   32    2 : tunables    0    0
   0 : slabdata   3743   3743      0
+kmalloc-256       308470 370720    256   32    2 : tunables    0    0
   0 : slabdata  11585  11585      0
-kmalloc-128         8435   9760    128   32    1 : tunables    0    0
   0 : slabdata    305    305      0
+kmalloc-128         8524   9760    128   32    1 : tunables    0    0
   0 : slabdata    305    305      0
-kmalloc-64         96176 405440     64   64    1 : tunables    0    0
   0 : slabdata   6335   6335      0
+kmalloc-64         50001 352448     64   64    1 : tunables    0    0
   0 : slabdata   5507   5507      0

If my interpretation and understanding is correct, this indicates that
for example, ~3000 to ~10000 3-order allocations resulting from 1 kb
kmalloc():s. Meaning about 0.2 gig ( 7000*4*8*1024/1024/1024). Add the
other ones and we get some more, but only a few hundred megs in total.

Going by the hypothesis that we are seeing the same thing as reported
by Simon Kirby (I'll respond to that E-Mail separately), the total
amount is (as far as I understand) not the important part, but the
fact that we saw a non-trivial increase in 3-order allocations would
perhaps be a consistent observation in that frequent 3-order
allocations might be more likely to trigger the behavior Simon
reports.

I can do additional post-processing on the data that was dumped (such
as graphing it), but I'm not sure which parts would be the most
interesting for figuring out what is going on. Is there something else
I should be collecting for that matter, than the
vmstat/slabinfo/buddyinfo/meminfo?

--=20
/ Peter Schuller aka scode

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
