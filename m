Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 585866B044B
	for <linux-mm@kvack.org>; Thu, 16 Feb 2017 20:46:57 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id e4so44844385pfg.4
        for <linux-mm@kvack.org>; Thu, 16 Feb 2017 17:46:57 -0800 (PST)
Received: from mail-pf0-x230.google.com (mail-pf0-x230.google.com. [2607:f8b0:400e:c00::230])
        by mx.google.com with ESMTPS id q16si8640462pgn.206.2017.02.16.17.46.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Feb 2017 17:46:56 -0800 (PST)
Received: by mail-pf0-x230.google.com with SMTP id c73so9594792pfb.0
        for <linux-mm@kvack.org>; Thu, 16 Feb 2017 17:46:56 -0800 (PST)
Date: Thu, 16 Feb 2017 17:46:44 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: swap_cluster_info lockdep splat
In-Reply-To: <1487273646.2833.100.camel@linux.intel.com>
Message-ID: <alpine.LSU.2.11.1702161702490.24224@eggly.anvils>
References: <20170216052218.GA13908@bbox> <87o9y2a5ji.fsf@yhuang-dev.intel.com> <alpine.LSU.2.11.1702161050540.21773@eggly.anvils> <1487273646.2833.100.camel@linux.intel.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="0-345812320-1487296014=:24224"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Hugh Dickins <hughd@google.com>, "Huang, Ying" <ying.huang@intel.com>, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--0-345812320-1487296014=:24224
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Thu, 16 Feb 2017, Tim Chen wrote:
>=20
> > I do not understand your zest for putting wrappers around every little
> > thing, making it all harder to follow than it need be.=C2=A0 Here's the=
 patch
> > I've been running with (but you have a leak somewhere, and I don't have
> > time to search out and fix it: please try sustained swapping and swapof=
f).
> >=20
>=20
> Hugh, trying to duplicate your test case. =C2=A0So you were doing swappin=
g,
> then swap off, swap on the swap device and restart swapping?

Repeated pair of make -j20 kernel builds in 700M RAM, 1.5G swap on SSD,
8 cpus; one of the builds in tmpfs, other in ext4 on loop on tmpfs file;
sizes tuned for plenty of swapping but no OOMing (it's an ancient 2.6.24
kernel I build, modern one needing a lot more space with a lot less in use)=
=2E

How much of that is relevant I don't know: hopefully none of it, it's
hard to get the tunings right from scratch.  To answer your specific
question: yes, I'm not doing concurrent swapoffs in this test showing
the leak, just waiting for each of the pair of builds to complete,
then tearing down the trees, doing swapoff followed by swapon, and
starting a new pair of builds.

Sometimes it's the swapoff that fails with ENOMEM, more often it's a
fork during build that fails with ENOMEM: after 6 or 7 hours of load
(but timings show it getting slower leading up to that).  /proc/meminfo
did not give me an immediate clue, Slab didn't look surprising but
I may not have studied close enough.

I quilt-bisected it as far as the mm-swap series, good before, bad
after, but didn't manage to narrow it down further because of hitting
a presumably different issue inside the series, where swapoff ENOMEMed
much sooner (after 25 mins one time, during first iteration the next).

Hugh
--0-345812320-1487296014=:24224--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
