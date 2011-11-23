Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id C74496B00E1
	for <linux-mm@kvack.org>; Wed, 23 Nov 2011 11:06:29 -0500 (EST)
Date: Wed, 23 Nov 2011 10:06:24 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: WARNING: at mm/slub.c:3357, kernel BUG at mm/slub.c:3413
In-Reply-To: <20111123160353.GA1673@x4.trippels.de>
Message-ID: <alpine.DEB.2.00.1111231004490.17317@router.home>
References: <1321605837.30341.551.camel@debian> <20111118085436.GC1615@x4.trippels.de> <20111118120201.GA1642@x4.trippels.de> <1321836285.30341.554.camel@debian> <20111121080554.GB1625@x4.trippels.de> <20111121082445.GD1625@x4.trippels.de>
 <1321866988.2552.10.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <20111121131531.GA1679@x4.trippels.de> <1321884966.10470.2.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <20111121153621.GA1678@x4.trippels.de> <20111123160353.GA1673@x4.trippels.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Markus Trippelsdorf <markus@trippelsdorf.de>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, "Alex,Shi" <alex.shi@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, tj@kernel.org, dri-devel@lists.freedesktop.org, Alex Deucher <alexander.deucher@amd.com>

On Wed, 23 Nov 2011, Markus Trippelsdorf wrote:

> > FIX idr_layer_cache: Marking all objects used
>
> Yesterday I couldn't reproduce the issue at all. But today I've hit
> exactly the same spot again. (CCing the drm list)

Well this is looks like write after free.

> =============================================================================
> BUG idr_layer_cache: Poison overwritten
> -----------------------------------------------------------------------------
> Object ffff8802156487c0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> Object ffff8802156487d0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> Object ffff8802156487e0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> Object ffff8802156487f0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> Object ffff880215648800: 00 00 00 00 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  ....kkkkkkkkkkkk
> Object ffff880215648810: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk

And its an integer sized write of 0. If you look at the struct definition
and lookup the offset you should be able to locate the field that
was modified.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
