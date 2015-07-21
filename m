Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f46.google.com (mail-qg0-f46.google.com [209.85.192.46])
	by kanga.kvack.org (Postfix) with ESMTP id 17B0D9003C7
	for <linux-mm@kvack.org>; Tue, 21 Jul 2015 19:28:28 -0400 (EDT)
Received: by qgii95 with SMTP id i95so64576138qgi.2
        for <linux-mm@kvack.org>; Tue, 21 Jul 2015 16:28:27 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f92si30248941qge.71.2015.07.21.16.28.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Jul 2015 16:28:26 -0700 (PDT)
Date: Wed, 22 Jul 2015 01:28:19 +0200
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH 3/3] slub: build detached freelist with look-ahead
Message-ID: <20150722012819.6b98a599@redhat.com>
In-Reply-To: <alpine.DEB.2.11.1507210846060.27213@east.gentwo.org>
References: <20150715155934.17525.2835.stgit@devil>
	<20150715160212.17525.88123.stgit@devil>
	<20150716115756.311496af@redhat.com>
	<20150720025415.GA21760@js1304-P5Q-DELUXE>
	<20150720232817.05f08663@redhat.com>
	<alpine.DEB.2.11.1507210846060.27213@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, brouer@redhat.com
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Alexander Duyck <alexander.duyck@gmail.com>, Hannes Frederic Sowa <hannes@stressinduktion.org>

On Tue, 21 Jul 2015 08:50:36 -0500 (CDT)
Christoph Lameter <cl@linux.com> wrote:

> On Mon, 20 Jul 2015, Jesper Dangaard Brouer wrote:
> 
> > Yes, I think it is merged... how do I turn off merging?
> 
> linux/Documentation/kernel-parameters.txt
> 
>         slab_nomerge    [MM]
>                         Disable merging of slabs with similar size. May be
>                         necessary if there is some reason to distinguish
>                         allocs to different slabs. Debug options disable
>                         merging on their own.
>                         For more information see Documentation/vm/slub.txt.

I was hoping I could define this per slub runtime.  Any chance this
would be made possible?

Setting boot param "slab_nomerge" made my benchmarking VERY stable
between runs (obj size 256).


Run01: slab_nomerge
1 - 63 cycles(tsc) 15.927 ns -  46 cycles(tsc) 11.707 ns
2 - 56 cycles(tsc) 14.185 ns -  28 cycles(tsc) 7.129 ns
3 - 54 cycles(tsc) 13.588 ns -  23 cycles(tsc) 5.762 ns
4 - 53 cycles(tsc) 13.291 ns -  20 cycles(tsc) 5.085 ns
8 - 51 cycles(tsc) 12.918 ns -  19 cycles(tsc) 4.886 ns
16 - 50 cycles(tsc) 12.607 ns -  19 cycles(tsc) 4.858 ns
30 - 51 cycles(tsc) 12.759 ns -  19 cycles(tsc) 4.980 ns
32 - 51 cycles(tsc) 12.930 ns -  19 cycles(tsc) 4.975 ns
34 - 93 cycles(tsc) 23.410 ns -  27 cycles(tsc) 6.924 ns
48 - 80 cycles(tsc) 20.193 ns -  25 cycles(tsc) 6.279 ns
64 - 73 cycles(tsc) 18.322 ns -  23 cycles(tsc) 5.939 ns
128 - 88 cycles(tsc) 22.083 ns -  29 cycles(tsc) 7.413 ns
158 - 97 cycles(tsc) 24.274 ns -  34 cycles(tsc) 8.696 ns
250 - 102 cycles(tsc) 25.556 ns -  40 cycles(tsc) 10.100 ns

Run02: slab_nomerge
1 - 63 cycles(tsc) 15.879 ns -  46 cycles(tsc) 11.701 ns
2 - 56 cycles(tsc) 14.222 ns -  28 cycles(tsc) 7.140 ns
3 - 54 cycles(tsc) 13.586 ns -  23 cycles(tsc) 5.783 ns
4 - 53 cycles(tsc) 13.339 ns -  20 cycles(tsc) 5.095 ns
8 - 51 cycles(tsc) 12.899 ns -  19 cycles(tsc) 4.905 ns
16 - 50 cycles(tsc) 12.624 ns -  19 cycles(tsc) 4.853 ns
30 - 51 cycles(tsc) 12.781 ns -  19 cycles(tsc) 4.984 ns
32 - 51 cycles(tsc) 12.933 ns -  19 cycles(tsc) 4.997 ns
34 - 93 cycles(tsc) 23.421 ns -  27 cycles(tsc) 6.909 ns
48 - 80 cycles(tsc) 20.241 ns -  25 cycles(tsc) 6.267 ns
64 - 73 cycles(tsc) 18.346 ns -  23 cycles(tsc) 5.947 ns
128 - 88 cycles(tsc) 22.192 ns -  29 cycles(tsc) 7.415 ns
158 - 97 cycles(tsc) 24.358 ns -  34 cycles(tsc) 8.693 ns
250 - 102 cycles(tsc) 25.597 ns -  40 cycles(tsc) 10.144 ns

Run03: slab_nomerge
1 - 63 cycles(tsc) 15.897 ns -  46 cycles(tsc) 11.685 ns
2 - 56 cycles(tsc) 14.178 ns -  28 cycles(tsc) 7.132 ns
3 - 54 cycles(tsc) 13.590 ns -  23 cycles(tsc) 5.774 ns
4 - 53 cycles(tsc) 13.314 ns -  20 cycles(tsc) 5.092 ns
8 - 51 cycles(tsc) 12.872 ns -  19 cycles(tsc) 4.886 ns
16 - 50 cycles(tsc) 12.603 ns -  19 cycles(tsc) 4.840 ns
30 - 50 cycles(tsc) 12.750 ns -  19 cycles(tsc) 4.966 ns
32 - 51 cycles(tsc) 12.910 ns -  19 cycles(tsc) 4.977 ns
34 - 93 cycles(tsc) 23.372 ns -  27 cycles(tsc) 6.929 ns
48 - 80 cycles(tsc) 20.205 ns -  25 cycles(tsc) 6.276 ns
64 - 73 cycles(tsc) 18.292 ns -  23 cycles(tsc) 5.929 ns
128 - 90 cycles(tsc) 22.516 ns -  29 cycles(tsc) 7.425 ns
158 - 99 cycles(tsc) 24.825 ns -  34 cycles(tsc) 8.668 ns
250 - 102 cycles(tsc) 25.652 ns -  40 cycles(tsc) 10.129 ns


-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
