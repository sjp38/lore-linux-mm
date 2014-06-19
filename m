Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f179.google.com (mail-qc0-f179.google.com [209.85.216.179])
	by kanga.kvack.org (Postfix) with ESMTP id 986E16B0031
	for <linux-mm@kvack.org>; Thu, 19 Jun 2014 16:19:43 -0400 (EDT)
Received: by mail-qc0-f179.google.com with SMTP id x3so2643150qcv.38
        for <linux-mm@kvack.org>; Thu, 19 Jun 2014 13:19:43 -0700 (PDT)
Received: from qmta12.emeryville.ca.mail.comcast.net (qmta12.emeryville.ca.mail.comcast.net. [2001:558:fe2d:44:76:96:27:227])
        by mx.google.com with ESMTP id b2si8023395qar.16.2014.06.19.13.19.42
        for <linux-mm@kvack.org>;
        Thu, 19 Jun 2014 13:19:42 -0700 (PDT)
Date: Thu, 19 Jun 2014 15:19:39 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: slub/debugobjects: lockup when freeing memory
In-Reply-To: <alpine.DEB.2.10.1406192127100.5170@nanos>
Message-ID: <alpine.DEB.2.11.1406191519090.4002@gentwo.org>
References: <53A2F406.4010109@oracle.com> <alpine.DEB.2.11.1406191001090.2785@gentwo.org> <20140619165247.GA4904@linux.vnet.ibm.com> <alpine.DEB.2.10.1406192127100.5170@nanos>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Sasha Levin <sasha.levin@oracle.com>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Jones <davej@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, 19 Jun 2014, Thomas Gleixner wrote:

> Well, no. Look at the callchain:
>
> __call_rcu
>     debug_object_activate
>        rcuhead_fixup_activate
>           debug_object_init
>               kmem_cache_alloc
>
> So call rcu activates the object, but the object has no reference in
> the debug objects code so the fixup code is called which inits the
> object and allocates a reference ....

So we need to init the object in the page struct before the __call_rcu?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
