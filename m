Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 7C04990014E
	for <linux-mm@kvack.org>; Mon,  1 Aug 2011 08:45:07 -0400 (EDT)
Received: by vxg38 with SMTP id 38so5941177vxg.14
        for <linux-mm@kvack.org>; Mon, 01 Aug 2011 05:45:04 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1108010229150.1062@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1107290145080.3279@tiger>
	<alpine.DEB.2.00.1107291002570.16178@router.home>
	<alpine.DEB.2.00.1107311136150.12538@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1107311253560.12538@chino.kir.corp.google.com>
	<1312145146.24862.97.camel@jaguar>
	<alpine.DEB.2.00.1107311426001.944@chino.kir.corp.google.com>
	<1312175306.24862.103.camel@jaguar>
	<alpine.DEB.2.00.1108010229150.1062@chino.kir.corp.google.com>
Date: Mon, 1 Aug 2011 15:45:04 +0300
Message-ID: <CAOJsxLGyC4=WwGu7kUTwVKF3AxhfWjBg2sZu=W08RtVMHKk8eQ@mail.gmail.com>
Subject: Re: [GIT PULL] Lockless SLUB slowpaths for v3.1-rc1
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Christoph Lameter <cl@linux.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, hughd@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi David,

On Mon, Aug 1, 2011 at 1:02 PM, David Rientjes <rientjes@google.com> wrote:
> Here's the same testing environment with CONFIG_SLUB_STATS for 16 threads
> instead of 160:

[snip]

Looking at the data (in slightly reorganized form):

  alloc
  =3D=3D=3D=3D=3D

    16 threads:

=A0  =A0  cache =A0 =A0 =A0 =A0 =A0 alloc_fastpath =A0 =A0 =A0 =A0 =A0alloc=
_slowpath
=A0  =A0  kmalloc-256 =A0 =A0 4263275 (91.1%) =A0 =A0 =A0 =A0 417445   (8.9=
%)
=A0  =A0  kmalloc-1024 =A0 =A04636360 (99.1%) =A0 =A0 =A0 =A0 42091    (0.9=
%)
=A0  =A0  kmalloc-4096 =A0 =A02570312 (54.4%) =A0 =A0 =A0 =A0 2155946  (45.=
6%)

    160 threads:

=A0 =A0   cache =A0 =A0 =A0 =A0 =A0 alloc_fastpath =A0 =A0 =A0 =A0 =A0alloc=
_slowpath
 =A0   =A0kmalloc-256 =A0 =A0 10937512 (62.8%) =A0 =A0 =A0 =A06490753  (37.=
2%)
 =A0   =A0kmalloc-1024 =A0 =A017121172 (98.3%) =A0 =A0 =A0 =A0303547   (1.7=
%)
 =A0   =A0kmalloc-4096 =A0 =A05526281  (31.7%)=A0 =A0 =A0 =A0 11910454 (68.=
3%)

  free
  =3D=3D=3D=3D

    16 threads:

=A0 =A0   cache =A0 =A0 =A0 =A0 =A0 free_fastpath =A0 =A0 =A0 =A0 =A0 free_=
slowpath
=A0 =A0   kmalloc-256 =A0 =A0 210115   (4.5%)=A0 =A0 =A0 =A0 =A04470604  (9=
5.5%)
=A0 =A0   kmalloc-1024 =A0 =A03579699  (76.5%)  =A0 =A0 =A0 1098764  (23.5%=
)
=A0 =A0   kmalloc-4096 =A0 =A067616    (1.4%)=A0  =A0 =A0 =A0 4658678  (98.=
6%)

    160 threads:
 =A0  =A0 cache =A0 =A0 =A0 =A0 =A0 free_fastpath =A0 =A0 =A0 =A0 =A0 free_=
slowpath
 =A0  =A0 kmalloc-256 =A0 =A0 15469    (0.1%)   =A0 =A0 =A0 17412798 (99.9%=
)
 =A0  =A0 kmalloc-1024 =A0 =A011604742 (66.6%) =A0 =A0 =A0 =A05819973  (33.=
4%)
 =A0  =A0 kmalloc-4096 =A0 =A014848    (0.1%)=A0=A0 =A0 =A0 =A0 17421902 (9=
9.9%)

it's pretty sad to see how SLUB alloc fastpath utilization drops so
dramatically. Free fastpath utilization isn't all that great with 160
threads either but it seems to me that most of the performance
regression compared to SLAB still comes from the alloc paths.

I guess the problem here is that __slab_free() happens on a remote CPU
which puts the object to 'struct page' freelist which effectively means
we're unable to recycle free'd objects. As the number of concurrent
threads increase, we simply drain out the fastpath freelists more
quickly. Did I understand the problem correctly?

If that's really happening, I'm still bit puzzled why we're hitting the
slowpath so much. I'd assume that __slab_alloc() would simply reload the
'struct page' freelist once the per-cpu freelist is empty.  Why is that
not happening? I see __slab_alloc() does deactivate_slab() upon
node_match() failure. What kind of ALLOC_NODE_MISMATCH stats are you
seeing?

                        Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
