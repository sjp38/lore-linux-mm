Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f178.google.com (mail-qc0-f178.google.com [209.85.216.178])
	by kanga.kvack.org (Postfix) with ESMTP id 54C246B0035
	for <linux-mm@kvack.org>; Mon, 16 Dec 2013 05:05:01 -0500 (EST)
Received: by mail-qc0-f178.google.com with SMTP id i17so3477111qcy.23
        for <linux-mm@kvack.org>; Mon, 16 Dec 2013 02:05:01 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id a4si7544743qat.156.2013.12.16.02.04.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Dec 2013 02:04:57 -0800 (PST)
Date: Mon, 16 Dec 2013 11:04:46 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: mm: ptl is not bloated if it fits in pointer
Message-ID: <20131216100446.GT21999@twins.programming.kicks-ass.net>
References: <alpine.LNX.2.00.1312160053530.3066@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.00.1312160053530.3066@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Dec 16, 2013 at 01:04:13AM -0800, Hugh Dickins wrote:
> It's silly to force the 64-bit CONFIG_GENERIC_LOCKBREAK architectures
> to kmalloc eight bytes for an indirect page table lock: the lock needs
> to fit in the space that a pointer to it would occupy, not into an int.

Ah, no. A spinlock is very much assumed to be 32bit, any spinlock that's
bigger than that is bloated.

For the page-frame case we do indeed not care about the strict 32bit but
more about not being larger than a pointer, however there are already
other users.

See for instance include/linux/lockref.h and lib/lockref.c, they very
much require the spinlock to be 32bit and the below would break that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
