Received: from atlas.CARNet.hr (zcalusic@atlas.CARNet.hr [161.53.123.163])
	by kvack.org (8.8.7/8.8.7) with ESMTP id PAA07294
	for <linux-mm@kvack.org>; Thu, 23 Jul 1998 15:34:09 -0400
Subject: Re: More info: 2.1.108 page cache performance on low memory
References: <199807131653.RAA06838@dax.dcs.ed.ac.uk> 	<m190lxmxmv.fsf@flinx.npwt.net> 	<199807141730.SAA07239@dax.dcs.ed.ac.uk> 	<m14swgm0am.fsf@flinx.npwt.net> 	<87d8b370ge.fsf@atlas.CARNet.hr> 	<m1pvf3jeob.fsf@flinx.npwt.net> 	<87hg0c6fz3.fsf@atlas.CARNet.hr> 	<199807221040.LAA00832@dax.dcs.ed.ac.uk> 	<87iukovq42.fsf@atlas.CARNet.hr> 	<199807231222.NAA04748@dax.dcs.ed.ac.uk> 	<87zpe0u0dg.fsf@atlas.CARNet.hr> <199807231718.SAA13683@dax.dcs.ed.ac.uk>
Reply-To: Zlatko.Calusic@CARNet.hr
From: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
Date: 23 Jul 1998 21:33:47 +0200
In-Reply-To: "Stephen C. Tweedie"'s message of "Thu, 23 Jul 1998 18:18:49 +0100"
Message-ID: <87af60bbvo.fsf@atlas.CARNet.hr>
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: "Eric W. Biederman" <ebiederm+eric@npwt.net>, werner@suse.de, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

"Stephen C. Tweedie" <sct@redhat.com> writes:

> Hi,
> 
> On 23 Jul 1998 16:07:23 +0200, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
> said:
> 
> > Strangely enough, I think I never explained why do *I* think
> > integrating buffer cache functionality into page cache would (in my
> > thought) be a good thing. Since both caches are very different, I'm
> > not sure memory management can be fair enough in some cases.
> 
> > Take a simple example: two applications, I/O bound, where one is
> > accessing raw partition (e.g. fsck) and other uses filesystem (web,
> > ftp...). Question is, how do I know that MM is fair. Maybe page cache
> > grows too large on behalf of buffer cache, so fsck runs much slower
> > than it could. Or if buffer cache grows faster (which is not the case,
> > IMO) then web would be fast, but fsck (or some database accessing raw
> > partition) could take a penalty.
> 
> There's a single loop in shrink_mmap() which treats both buffer-cache
> pages and page-cache pages identically.  It just propogates the buffer
> referenced bits into the page's PG_referenced bit before doing any
> ageing on the page.  It should be fair enough.  There are other issues
> concerning things like locked and dirty buffers which complicate the
> issue, but they are not sufficient reason to throw away the buffer
> cache!
> 

Hm, I know how shrink_mmap work, but I never looked at it that way.
My eyes are wide open.

Seems like all my reasons are not valid, so I will forget about my
ideas for a while. :)

In the mean time, I applied the same benchmark, I was already doing,
to kernel with Werner's lowmem patch applied, and results are
interesting. Performance is very similar to that with my change, but
there are some differences. With Werner's patch, kernel behaviour is
yet slightly less aggressive:

 procs                  memory    swap        io    system         cpu
 r b w  swpd  free  buff cache  si  so   bi   bo   in   cs  us  sy  id
 0 0 0     0  6492  4548 23100   0   0  179   16  219  157  23   9  68
 0 0 0     0  6492  4548 23100   0   0    0    2  108    9   0   0 100
 1 0 0    84  1384  1964 31168   0   8 6051    3  229  222   1  24  74
 1 0 0   128  1200  1964 31404   0   4 6630    3  238  237   1  25  75
 1 0 0   476  1024  1964 31928   0  35 6802    9  240  241   1  26  73
 1 0 0  1764  1316  1964 32932   0 129 6522   33  240  233   1  23  76
 1 0 0  2584  1172  1964 33896   0  82 6392   21  237  227   1  23  76
 1 0 0  3384  1284  1964 34584   0  80 6330   21  234  224   1  24  75
 1 0 0  4100  1232  1964 35352   0  72 6365   19  234  228   0  23  76
 1 0 0  4164  1432  1964 35236   0   6 6176    2  229  223   1  24  75
 1 0 0  4220  1136  1964 35580   0   6 7331    2  250  258   2  27  71
 1 0 0  4892  1284  1964 36096   0  67 7417   18  255  261   2  28  70
 1 0 0  4940  1532  1964 35896   0   5 7460    2  252  258   1  28  71
 1 0 0  4980  1540  1964 35932   0   4 7307    2  251  256   2  27  72
 0 0 0  4996  1536  1964 35984   0   2 1496    2  140   66   0   5  95
 0 0 0  4996  1536  1964 35984   0   0    0    1  102    7   0   0 100

So whichever solution find a way to the official kernel, will make me
happy. :)

Thank you for your thoughts and opinions!

Wish you a nice weekend (at that wedding, is it yours?) :)
-- 
Posted by Zlatko Calusic           E-mail: <Zlatko.Calusic@CARNet.hr>
---------------------------------------------------------------------
	Crime doesn't pay... does that mean my job is a crime?
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
