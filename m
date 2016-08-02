Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id B59536B0005
	for <linux-mm@kvack.org>; Tue,  2 Aug 2016 10:59:29 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id q62so370883024oih.0
        for <linux-mm@kvack.org>; Tue, 02 Aug 2016 07:59:29 -0700 (PDT)
Received: from resqmta-ch2-11v.sys.comcast.net (resqmta-ch2-11v.sys.comcast.net. [2001:558:fe21:29:69:252:207:43])
        by mx.google.com with ESMTPS id a99si3623620ioj.94.2016.08.02.07.59.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Aug 2016 07:59:28 -0700 (PDT)
Date: Tue, 2 Aug 2016 09:59:26 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm/slab: Improve performance of gathering slabinfo
 stats
In-Reply-To: <20160802024342.GA15062@js1304-P5Q-DELUXE>
Message-ID: <alpine.DEB.2.20.1608020953160.24620@east.gentwo.org>
References: <1470096548-15095-1-git-send-email-aruna.ramakrishna@oracle.com> <20160802005514.GA14725@js1304-P5Q-DELUXE> <4a3fe3bc-eb1d-ea18-bd70-98b8b9c6a7d7@oracle.com> <20160802024342.GA15062@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Aruna Ramakrishna <aruna.ramakrishna@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mike Kravetz <mike.kravetz@oracle.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>

Hmm.... What SLUB does is:

1. Keep a count of the total number of allocated slab pages per node.
	This counter only needs to be updated when a slab page is
	allocated from the page allocator or when it is freed to the
	page allocator. At that point we already hold the per node lock,
	page allocator operations are extremely costly anyways and so that
	is ok.

2. Keep a count of the number of partially allocated slab pages per node.
	At that point we have to access the partial list and take a per
	node lock. Placing the counter into the same cacheline and
	the increment/decrement into the period when the lock has been taken
	avoids the overhead.

The number of full pages is then

	total - partial


If both allocators would use the same scheme here then the code to
maintain the counter can be moved into mm/slab_common.c. Plus the per node
structures could be mostly harmonized between both allocators. Maybe even
the page allocator operations could become common code.

Aruna: Could you work on a solution like that?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
