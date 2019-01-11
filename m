Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id E3EC18E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 04:24:24 -0500 (EST)
Received: by mail-it1-f197.google.com with SMTP id w15so944336ita.1
        for <linux-mm@kvack.org>; Fri, 11 Jan 2019 01:24:24 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id v6si153745itg.59.2019.01.11.01.24.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 11 Jan 2019 01:24:23 -0800 (PST)
Date: Fri, 11 Jan 2019 10:24:08 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 3/3] bitops.h: set_mask_bits() to return old value
Message-ID: <20190111092408.GM30894@hirez.programming.kicks-ass.net>
References: <1547166387-19785-1-git-send-email-vgupta@synopsys.com>
 <1547166387-19785-4-git-send-email-vgupta@synopsys.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1547166387-19785-4-git-send-email-vgupta@synopsys.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vineet Gupta <vineet.gupta1@synopsys.com>
Cc: linux-kernel@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-mm@kvack.org, Miklos Szeredi <mszeredi@redhat.com>, Ingo Molnar <mingo@kernel.org>, Jani Nikula <jani.nikula@intel.com>, Chris Wilson <chris@chris-wilson.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>

On Thu, Jan 10, 2019 at 04:26:27PM -0800, Vineet Gupta wrote:

> @@ -246,7 +246,7 @@ static __always_inline void __assign_bit(long nr, volatile unsigned long *addr,
>  		new__ = (old__ & ~mask__) | bits__;		\
>  	} while (cmpxchg(ptr, old__, new__) != old__);		\

diff --git a/include/linux/bitops.h b/include/linux/bitops.h
index 705f7c442691..2060d26a35f5 100644
--- a/include/linux/bitops.h
+++ b/include/linux/bitops.h
@@ -241,10 +241,10 @@ static __always_inline void __assign_bit(long nr, volatile unsigned long *addr,
 	const typeof(*(ptr)) mask__ = (mask), bits__ = (bits);	\
 	typeof(*(ptr)) old__, new__;				\
 								\
+	old__ = READ_ONCE(*(ptr));				\
 	do {							\
-		old__ = READ_ONCE(*(ptr));			\
 		new__ = (old__ & ~mask__) | bits__;		\
-	} while (cmpxchg(ptr, old__, new__) != old__);		\
+	} while (!try_cmpxchg(ptr, &old__, new__));		\
 								\
 	new__;							\
 })


While there you probably want something like the above... although,
looking at it now, we seem to have 'forgotten' to add try_cmpxchg to the
generic code :/
