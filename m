Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id C44CF8D003B
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 11:28:49 -0400 (EDT)
Received: from mail-ew0-f41.google.com (mail-ew0-f41.google.com [209.85.215.41])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id p3PFSEgx018467
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=FAIL)
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 08:28:15 -0700
Received: by ewy9 with SMTP id 9so1052223ewy.14
        for <linux-mm@kvack.org>; Mon, 25 Apr 2011 08:28:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110425111705.786ef0c5@neptune.home>
References: <20110424202158.45578f31@neptune.home> <20110424235928.71af51e0@neptune.home>
 <20110425114429.266A.A69D9226@jp.fujitsu.com> <BANLkTinVQtLbmBknBZeY=7w7AOyQk61Pew@mail.gmail.com>
 <20110425111705.786ef0c5@neptune.home>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 25 Apr 2011 08:22:38 -0700
Message-ID: <BANLkTi=d0UHrYXyTK0CBZYCSK-ax8+wuWQ@mail.gmail.com>
Subject: Re: 2.6.39-rc4+: Kernel leaking memory during FS scanning, regression?
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?ISO-8859-1?Q?Bruno_Pr=E9mont?= <bonbons@linux-vserver.org>
Cc: Mike Frysinger <vapier.adi@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Paul E. McKenney" <paul.mckenney@linaro.org>, Pekka Enberg <penberg@kernel.org>

On Mon, Apr 25, 2011 at 2:17 AM, Bruno Pr=E9mont
<bonbons@linux-vserver.org> wrote:
>
> Here it seems to happened when I run 2 intensive tasks in parallel, e.g.
> (re)emerging gimp and running revdep-rebuild -pi in another terminal.
> This produces a fork rate of about 100-300 per second.
>
> Suddenly kmalloc-128 slabs stop being freed and things degrade.

So everything seems to imply some kind of filesystem/vfs thing, but
let's try to gather a bit more information about exactly what it is.

Some of it also points to RCU freeing, but that "kmalloc-128" doesn't
really match my expectations. According to your slabinfo, it's not the
dentries.

One thing I'd ask you to do is to boot with the "slub_nomerge" kernel
command  line switch. The SLUB "merge slab caches" thing may save some
memory, but it has been a disaster from every other standpoint - every
time there's a memory leak, it ends up making it very confusing to try
to figure things out.

For example, your traces seem to imply that the kmalloc-128 allocation
is actually the "filp" cache, but it has gotten merged with the
kmalloc-128 cache, so slabinfo doesn't actually show the right user.

(Pekka? This is a real _problem_. The whole "confused debugging" is
wasting a lot of peoples time. Can we please try to get slabinfo
statistics work right for the merged state. Or perhaps decide to just
not merge at all?)

As to why it has started to happen now: with the whole RCU lookup
thing, many more filesystem objects are RCU-free'd (dentries have been
for a long time, but now we have inodes and filp's too), and that may
end up delaying allocations sufficiently that you end up seeing
something that used to be borderline become a major problem.

Also, what's your kernel config, in particular wrt RCU? The RCU
freeing _should_ be self-limiting (if I recall correctly) and not let
infinite amounts of RCU work (ie pending freeing) accumulate, but
maybe something is broken. Do you have a UP kernel with TINY_RCU, for
example? Or maybe I'm just confused, and there's never any RCU
throttling at all. Paul?

                               Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
