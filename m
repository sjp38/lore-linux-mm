Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9FFF46B02C3
	for <linux-mm@kvack.org>; Wed, 31 May 2017 10:08:38 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id w131so5838449qka.5
        for <linux-mm@kvack.org>; Wed, 31 May 2017 07:08:38 -0700 (PDT)
Received: from resqmta-ch2-01v.sys.comcast.net (resqmta-ch2-01v.sys.comcast.net. [2001:558:fe21:29:69:252:207:33])
        by mx.google.com with ESMTPS id t18si15818551qta.84.2017.05.31.07.08.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 May 2017 07:08:37 -0700 (PDT)
Date: Wed, 31 May 2017 09:06:03 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: 4.12-rc ppc64 4k-page needs costly allocations
In-Reply-To: <alpine.LSU.2.11.1705301151090.2133@eggly.anvils>
Message-ID: <alpine.DEB.2.20.1705310902340.14920@east.gentwo.org>
References: <alpine.LSU.2.11.1705301151090.2133@eggly.anvils>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

On Tue, 30 May 2017, Hugh Dickins wrote:

> I wanted to try removing CONFIG_SLUB_DEBUG, but didn't succeed in that:
> it seemed to be a hard requirement for something, but I didn't find what.

CONFIG_SLUB_DEBUG does not enable debugging. It only includes the code to
be able to enable it at runtime.

> I did try CONFIG_SLAB=y instead of SLUB: that lowers these allocations to
> the expected order:3, which then results in OOM-killing rather than direct
> allocation failure, because of the PAGE_ALLOC_COSTLY_ORDER 3 cutoff.  But
> makes no real difference to the outcome: swapping loads still abort early.

SLAB uses order 3 and SLUB order 4??? That needs to be tracked down.

Why are the slab allocators used to create slab caches for large object
sizes?

> Relying on order:3 or order:4 allocations is just too optimistic: ppc64
> with 4k pages would do better not to expect to support a 128TB userspace.

I thought you had these huge 64k page sizes?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
