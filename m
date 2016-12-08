Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1F4D16B0260
	for <linux-mm@kvack.org>; Thu,  8 Dec 2016 03:22:40 -0500 (EST)
Received: by mail-qt0-f197.google.com with SMTP id w39so284602870qtw.0
        for <linux-mm@kvack.org>; Thu, 08 Dec 2016 00:22:40 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a97si16707418qkh.90.2016.12.08.00.22.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Dec 2016 00:22:39 -0800 (PST)
Date: Thu, 8 Dec 2016 09:22:31 +0100
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH] mm: page_alloc: High-order per-cpu page allocator v7
Message-ID: <20161208092231.55c7eacf@redhat.com>
In-Reply-To: <20161207232531.fxqdgrweilej5gs6@techsingularity.net>
References: <20161207101228.8128-1-mgorman@techsingularity.net>
	<1481137249.4930.59.camel@edumazet-glaptop3.roam.corp.google.com>
	<20161207194801.krhonj7yggbedpba@techsingularity.net>
	<1481141424.4930.71.camel@edumazet-glaptop3.roam.corp.google.com>
	<20161207211958.s3ymjva54wgakpkm@techsingularity.net>
	<20161207232531.fxqdgrweilej5gs6@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linux-MM <linux-mm@kvack.org>, Linux-Kernel <linux-kernel@vger.kernel.org>, brouer@redhat.com

On Wed, 7 Dec 2016 23:25:31 +0000
Mel Gorman <mgorman@techsingularity.net> wrote:

> On Wed, Dec 07, 2016 at 09:19:58PM +0000, Mel Gorman wrote:
> > At small packet sizes on localhost, I see relatively low page allocator
> > activity except during the socket setup and other unrelated activity
> > (khugepaged, irqbalance, some btrfs stuff) which is curious as it's
> > less clear why the performance was improved in that case. I considered
> > the possibility that it was cache hotness of pages but that's not a
> > good fit. If it was true then the first test would be slow and the rest
> > relatively fast and I'm not seeing that. The other side-effect is that
> > all the high-order pages that are allocated at the start are physically
> > close together but that shouldn't have that big an impact. So for now,
> > the gain is unexplained even though it happens consistently.
> >  =20
>=20
> Further investigation led me to conclude that the netperf automation on
> my side had some methodology errors that could account for an artifically
> low score in some cases. The netperf automation is years old and would
> have been developed against a much older and smaller machine which may be
> why I missed it until I went back looking at exactly what the automation
> was doing. Minimally in a server/client test on remote maching there was
> potentially higher packet loss than is acceptable. This would account why
> some machines "benefitted" while others did not -- there would be boot to
> boot variations that some machines happened to be "lucky". I believe I've
> corrected the errors, discarded all the old data and scheduled a rest to
> see what falls out.

I guess you are talking about setting the netperf socket queue low
(+256 bytes above msg size), that I pointed out in[1].  I can see from
GitHub-mmtests-commit[2] "netperf: Set remote and local socket max
buffer sizes", that you have removed that, good! :-)

=46rom the same commit[2] I can see you explicitly set (local+remote):

  sysctl net.core.rmem_max=3D16777216
  sysctl net.core.wmem_max=3D16777216

Eric do you have any advice on this setting?

And later[4] you further increase this to 32MiB.  Notice that the
netperf UDP_STREAM test will still use the default value from:
net.core.rmem_default =3D 212992.

(To Eric) Mel's small UDP queues also interacted badly with Eric and
Paolo's UDP improvements, which was fixed in net-next commit[3]
363dc73acacb ("udp: be less conservative with sock rmem accounting").


[1] http://lkml.kernel.org/r/20161201183402.2fbb8c5b@redhat.com
[2] https://github.com/gormanm/mmtests/commit/7f16226577b
[3] https://git.kernel.org/davem/net-next/c/363dc73acacb
[4] https://github.com/gormanm/mmtests/commit/777d1f5cd08
--=20
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
