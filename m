Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id C07D928025F
	for <linux-mm@kvack.org>; Thu, 16 Nov 2017 07:02:21 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id q127so2284964wmd.1
        for <linux-mm@kvack.org>; Thu, 16 Nov 2017 04:02:21 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x31si796412ede.181.2017.11.16.04.02.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 16 Nov 2017 04:02:20 -0800 (PST)
Date: Thu, 16 Nov 2017 13:02:16 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/3] lockdep: Apply crossrelease to PG_locked locks
Message-ID: <20171116120216.nxbwkj5y3kvim6cj@dhcp22.suse.cz>
References: <1510802067-18609-1-git-send-email-byungchul.park@lge.com>
 <1510802067-18609-2-git-send-email-byungchul.park@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1510802067-18609-2-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <byungchul.park@lge.com>
Cc: peterz@infradead.org, mingo@kernel.org, akpm@linux-foundation.org, tglx@linutronix.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, kernel-team@lge.com, jack@suse.cz, jlayton@redhat.com, viro@zeniv.linux.org.uk, hannes@cmpxchg.org, npiggin@gmail.com, rgoldwyn@suse.com, vbabka@suse.cz, pombredanne@nexb.com, vinmenon@codeaurora.org, gregkh@linuxfoundation.org

[I have only briefly looked at patches so I might have missed some
details.]

On Thu 16-11-17 12:14:25, Byungchul Park wrote:
> Although lock_page() and its family can cause deadlock, lockdep have not
> worked with them, because unlock_page() might be called in a different
> context from the acquire context, which violated lockdep's assumption.
>
> Now CONFIG_LOCKDEP_CROSSRELEASE has been introduced, lockdep can work
> with page locks.

I definitely agree that debugging page_lock deadlocks is a major PITA
but your implementation seems prohibitively too expensive.

[...]
> @@ -218,6 +222,10 @@ struct page {
>  #ifdef LAST_CPUPID_NOT_IN_PAGE_FLAGS
>  	int _last_cpupid;
>  #endif
> +
> +#ifdef CONFIG_LOCKDEP_PAGELOCK
> +	struct lockdep_map_cross map;
> +#endif
>  }

now you are adding 
struct lockdep_map_cross {
        struct lockdep_map         map;                  /*     0    40 */
        struct cross_lock          xlock;                /*    40    56 */
        /* --- cacheline 1 boundary (64 bytes) was 32 bytes ago --- */

        /* size: 96, cachelines: 2, members: 2 */
        /* last cacheline: 32 bytes */
};

for each struct page. So you are doubling the size. Who is going to
enable this config option? You are moving this to page_ext in a later
patch which is a good step but it doesn't go far enough because this
still consumes those resources. Is there any problem to make this
kernel command line controllable? Something we do for page_owner for
example?

Also it would be really great if you could give us some measures about
the runtime overhead. I do not expect it to be very large but this is
something people are usually interested in when enabling debugging
features.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
