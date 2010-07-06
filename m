Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id B28756B01AF
	for <linux-mm@kvack.org>; Mon,  5 Jul 2010 23:58:31 -0400 (EDT)
From: Roland Dreier <rdreier@cisco.com>
Subject: Re: kmem_cache_destroy() badness with SLUB
References: <1277688701.4200.159.camel@pasglop>
Date: Mon, 05 Jul 2010 20:58:27 -0700
In-Reply-To: <1277688701.4200.159.camel@pasglop> (Benjamin Herrenschmidt's
	message of "Mon, 28 Jun 2010 11:31:41 +1000")
Message-ID: <aday6dpmfbw.fsf@roland-alpha.cisco.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>


Hi folks !
Internally, I'm hitting a little "nit"...

sysfs_slab_add() has this check:

	if (slab_state < SYSFS)
		/* Defer until later */
		return 0;

But sysfs_slab_remove() doesn't.

So if the slab is created -and- destroyed at, for example, arch_initcall
time, then we hit a WARN in the kobject code, trying to dispose of a
non-existing kobject.

Now, at first sight, just adding the same test to sysfs_slab_remove()
would do the job... but it all seems very racy to me.

I don't understand in fact how this slab_state deals with races at all. 

What prevents us from hitting slab_sysfs_init() at the same time as
another CPU deos sysfs_slab_add() ? How do that deal with collisions
trying to register the same kobject twice ? Similar race with remove...

Shouldn't we have a mutex around those guys ?

Cheers,
Ben.


--
To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
Please read the FAQ at  http://www.tux.org/lkml/


-- 
Roland Dreier <rolandd@cisco.com> || For corporate legal information go to:
http://www.cisco.com/web/about/doing_business/legal/cri/index.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
