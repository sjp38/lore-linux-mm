Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id AB61D6B0006
	for <linux-mm@kvack.org>; Wed, 23 May 2018 09:21:23 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id g92-v6so14142209plg.6
        for <linux-mm@kvack.org>; Wed, 23 May 2018 06:21:23 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 127-v6si1107804pge.159.2018.05.23.06.21.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 23 May 2018 06:21:22 -0700 (PDT)
Date: Wed, 23 May 2018 06:21:19 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 3/8] md: raid5: use refcount_t for reference counting
 instead atomic_t
Message-ID: <20180523132119.GC19987@bombadil.infradead.org>
References: <20180509193645.830-1-bigeasy@linutronix.de>
 <20180509193645.830-4-bigeasy@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180509193645.830-4-bigeasy@linutronix.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Cc: linux-kernel@vger.kernel.org, tglx@linutronix.de, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, linux-mm@kvack.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org, Anna-Maria Gleixner <anna-maria@linutronix.de>

On Wed, May 09, 2018 at 09:36:40PM +0200, Sebastian Andrzej Siewior wrote:
> refcount_t type and corresponding API should be used instead of atomic_t when
> the variable is used as a reference counter. This allows to avoid accidental
> refcounter overflows that might lead to use-after-free situations.
> 
> Most changes are 1:1 replacements except for
> 	BUG_ON(atomic_inc_return(&sh->count) != 1);
> 
> which has been turned into
>         refcount_inc(&sh->count);
>         BUG_ON(refcount_read(&sh->count) != 1);

@@ -5387,7 +5387,8 @@ static struct stripe_head *__get_priority_stripe(struct
+r5conf *conf, int group)
                sh->group = NULL;
        }
        list_del_init(&sh->lru);
-       BUG_ON(atomic_inc_return(&sh->count) != 1);
+       refcount_inc(&sh->count);
+	BUG_ON(refcount_read(&sh->count) != 1);
        return sh;
 }


That's the only problematic usage.  And I think what it's really saying is:

	BUG_ON(refcount_read(&sh->count) != 0);
	refcount_set(&sh->count, 1);

With that, this looks like a reasonable use of refcount_t to me.
