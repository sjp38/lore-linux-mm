Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 7A7B16B01B5
	for <linux-mm@kvack.org>; Sun, 27 Jun 2010 21:48:16 -0400 (EDT)
Subject: kmem_cache_destroy() badness with SLUB
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 28 Jun 2010 11:31:41 +1000
Message-ID: <1277688701.4200.159.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Christoph Lameter <cl@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
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
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
