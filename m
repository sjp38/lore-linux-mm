Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6267B8E0038
	for <linux-mm@kvack.org>; Wed,  9 Jan 2019 11:50:21 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id p3so4471002plk.9
        for <linux-mm@kvack.org>; Wed, 09 Jan 2019 08:50:21 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id u3si20402570pgj.300.2019.01.09.08.50.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 09 Jan 2019 08:50:20 -0800 (PST)
Date: Wed, 9 Jan 2019 08:50:09 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [RFC PATCH 03/15] mm/vmalloc: introduce new vrealloc() call and
 its subsidiary reach analog
Message-ID: <20190109165009.GM6310@bombadil.infradead.org>
References: <20190109164025.24554-1-rpenyaev@suse.de>
 <20190109164025.24554-4-rpenyaev@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190109164025.24554-4-rpenyaev@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Penyaev <rpenyaev@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Joe Perches <joe@perches.com>, "Luis R. Rodriguez" <mcgrof@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Jan 09, 2019 at 05:40:13PM +0100, Roman Penyaev wrote:
> Basically vrealloc() repeats glibc realloc() with only one big difference:
> old area is not freed, i.e. caller is responsible for calling vfree() in
> case of successfull reallocation.

Ouch.  Don't call it the same thing when you're providing such different
semantics.  I agree with you that the new semantics are useful ones,
I just want it called something else.  Maybe vcopy()?  vclone()?

> + *	Do not forget to call vfree() passing old address.  But careful,
> + *	calling vfree() from interrupt will cause vfree_deferred() call,
> + *	which in its turn uses freed address as a temporal pointer for a

"temporary", not temporal.

> + *	llist element, i.e. memory will be corrupted.
