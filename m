Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 1EF4D6B0036
	for <linux-mm@kvack.org>; Mon,  8 Sep 2014 10:36:45 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id fp1so1334048pdb.28
        for <linux-mm@kvack.org>; Mon, 08 Sep 2014 07:36:44 -0700 (PDT)
Received: from qmta08.emeryville.ca.mail.comcast.net (qmta08.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:80])
        by mx.google.com with ESMTPS id us5si18457255pac.4.2014.09.08.07.36.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 08 Sep 2014 07:36:42 -0700 (PDT)
Date: Mon, 8 Sep 2014 09:36:38 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] slab: implement kmalloc guard
In-Reply-To: <alpine.LRH.2.02.1409051833510.9790@file01.intranet.prod.int.rdu2.redhat.com>
Message-ID: <alpine.DEB.2.11.1409080932490.20388@gentwo.org>
References: <alpine.LRH.2.02.1409051833510.9790@file01.intranet.prod.int.rdu2.redhat.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Alasdair G. Kergon" <agk@redhat.com>, Mike Snitzer <msnitzer@redhat.com>, Milan Broz <gmazyland@gmail.com>, kkolasa@winsoft.pl, dm-devel@redhat.com

On Fri, 5 Sep 2014, Mikulas Patocka wrote:

> This patch adds a new option DEBUG_KMALLOC that makes it possible to
> detect writes beyond the end of space allocated with kmalloc. Normally,
> the kmalloc function rounds the size to the next power of two (there is
> exception to this rule - sizes 96 and 192). Slab debugging detects only
> writes beyond the end of the slab object, it is unable to detect writes
> beyond the end of kmallocated size that fit into the slab object.
>
> The motivation for this patch was this: There was 6 year old bug in
> dm-crypt (d49ec52ff6ddcda178fc2476a109cf1bd1fa19ed) where the driver would
> write beyond the end of kmallocated space, but the bug went undetected
> because the write would fit into the power-of-two-sized slab object. Only
> recent changes to dm-crypt made the bug show up. There is similar problem
> in the nx-crypto driver in the function nx_crypto_ctx_init - again,
> because kmalloc rounds the size up to the next power of two, this bug went
> undetected.

The problem with the kmalloc array for debugging is inded that it is
only for powers of two for efficiency purposes. In the debug
situation we may not have the need for that efficiency. Maybe simply
creating kmalloc arrays for each size will do the trick?

> This patch works for slab, slub and slob subsystems. The end of slab block
> can be found out with ksize (this patch renames it to __ksize). At the end
> of the block, we put a structure kmalloc_guard. This structure contains a
> magic number and a real size of the block - the exact size given to

We already have a redzone structure to check for writes over the end of
the object. Lets use that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
