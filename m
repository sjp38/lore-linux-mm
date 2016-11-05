Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0FCA86B0261
	for <linux-mm@kvack.org>; Sat,  5 Nov 2016 19:38:24 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id 144so9726535pfv.5
        for <linux-mm@kvack.org>; Sat, 05 Nov 2016 16:38:24 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id j69si13795913pfk.19.2016.11.05.16.38.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 05 Nov 2016 16:38:23 -0700 (PDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH/RFC] z3fold: use per-page read/write lock
References: <20161105144946.3b4be0ee799ae61a82e1d918@gmail.com>
Date: Sat, 05 Nov 2016 16:38:22 -0700
In-Reply-To: <20161105144946.3b4be0ee799ae61a82e1d918@gmail.com> (Vitaly
	Wool's message of "Sat, 5 Nov 2016 14:49:46 +0100")
Message-ID: <87lgwxo5u9.fsf@tassilo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Wool <vitalywool@gmail.com>
Cc: Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, Dan Streetman <ddstreet@ieee.org>, Andrew Morton <akpm@linux-foundation.org>

Vitaly Wool <vitalywool@gmail.com> writes:

> Most of z3fold operations are in-page, such as modifying z3fold
> page header or moving z3fold objects within a page. Taking
> per-pool spinlock to protect per-page objects is therefore
> suboptimal, and the idea of having a per-page spinlock (or rwlock)
> has been around for some time. However, adding one directly to the
> z3fold header makes the latter quite big on some systems so that
> it won't fit in a signle chunk.

> +	atomic_t page_lock;

This doesnt make much sense. A standard spinlock is not bigger
than 4 bytes either. Also reinventing locks is usually a bad
idea: they are tricky to get right, you have no debugging support,
hard to analyze, etc.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
