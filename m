Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 05FB26B0036
	for <linux-mm@kvack.org>; Mon, 16 Dec 2013 08:50:11 -0500 (EST)
Received: by mail-pd0-f171.google.com with SMTP id z10so5330688pdj.16
        for <linux-mm@kvack.org>; Mon, 16 Dec 2013 05:50:11 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id tr4si8956077pab.63.2013.12.16.05.50.10
        for <linux-mm@kvack.org>;
        Mon, 16 Dec 2013 05:50:10 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <20131216100446.GT21999@twins.programming.kicks-ass.net>
References: <alpine.LNX.2.00.1312160053530.3066@eggly.anvils>
 <20131216100446.GT21999@twins.programming.kicks-ass.net>
Subject: Re: mm: ptl is not bloated if it fits in pointer
Content-Transfer-Encoding: 7bit
Message-Id: <20131216135005.AC5FDE0090@blue.fi.intel.com>
Date: Mon, 16 Dec 2013 15:50:05 +0200 (EET)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Peter Zijlstra wrote:
> On Mon, Dec 16, 2013 at 01:04:13AM -0800, Hugh Dickins wrote:
> > It's silly to force the 64-bit CONFIG_GENERIC_LOCKBREAK architectures
> > to kmalloc eight bytes for an indirect page table lock: the lock needs
> > to fit in the space that a pointer to it would occupy, not into an int.
> 
> Ah, no. A spinlock is very much assumed to be 32bit, any spinlock that's
> bigger than that is bloated.
> 
> For the page-frame case we do indeed not care about the strict 32bit but
> more about not being larger than a pointer, however there are already
> other users.
> 
> See for instance include/linux/lockref.h and lib/lockref.c, they very
> much require the spinlock to be 32bit and the below would break that.

What about this instead? Smoke-tested.
