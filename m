Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 34D7F6B0031
	for <linux-mm@kvack.org>; Tue, 11 Feb 2014 08:20:05 -0500 (EST)
Received: by mail-pd0-f172.google.com with SMTP id p10so7532855pdj.3
        for <linux-mm@kvack.org>; Tue, 11 Feb 2014 05:20:04 -0800 (PST)
Received: from mail-pa0-x232.google.com (mail-pa0-x232.google.com [2607:f8b0:400e:c03::232])
        by mx.google.com with ESMTPS id va10si18991676pbc.158.2014.02.11.05.20.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 11 Feb 2014 05:20:02 -0800 (PST)
Received: by mail-pa0-f50.google.com with SMTP id kp14so7639903pab.37
        for <linux-mm@kvack.org>; Tue, 11 Feb 2014 05:20:01 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20140211121426.GQ4250@linux.vnet.ibm.com>
References: <20140102203320.GA27615@linux.vnet.ibm.com>
	<52F60699.8010204@iki.fi>
	<alpine.DEB.2.10.1402101304110.17517@nuc>
	<20140211121426.GQ4250@linux.vnet.ibm.com>
Date: Tue, 11 Feb 2014 15:20:01 +0200
Message-ID: <CAOJsxLET90NRnEKeFjWKWTgZm+otSSwfCkhFga2hGjhV12nz9Q@mail.gmail.com>
Subject: Re: Memory allocator semantics
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul McKenney <paulmck@linux.vnet.ibm.com>
Cc: Christoph Lameter <cl@linux.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Matt Mackall <mpm@selenic.com>

On Tue, Feb 11, 2014 at 2:14 PM, Paul E. McKenney
<paulmck@linux.vnet.ibm.com> wrote:
> In contrast, from kfree() to a kmalloc() returning some of the kfree()ed
> memory, I believe the kfree()/kmalloc() implementation must do any needed
> synchronization and ordering.  But that is a different set of examples,
> for example, this one:
>
>         CPU 0                   CPU 1
>         p->a = 42;              q = kmalloc(...); /* returning p */
>         kfree(p);               q->a = 5;
>                                 BUG_ON(q->a != 5);
>
> Unlike the situation with (A), (B), and (C), in this case I believe
> that it is kfree()'s and kmalloc()'s responsibility to ensure that
> the BUG_ON() never triggers.
>
> Make sense?

I'm not sure...

It's the caller's responsibility not to touch "p" after it's handed over to
kfree() - otherwise that's a "use-after-free" error.  If there's some reordering
going on here, I'm tempted to blame the caller for lack of locking.

                           Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
