Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 623826B0003
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 19:04:25 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id g15-v6so1351806plo.11
        for <linux-mm@kvack.org>; Tue, 17 Jul 2018 16:04:25 -0700 (PDT)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id n88-v6si1945256pfi.360.2018.07.17.16.04.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Jul 2018 16:04:23 -0700 (PDT)
Message-ID: <1531868435.3541.18.camel@intel.com>
Subject: Re: [RFC PATCH v2 16/27] mm: Modify can_follow_write_pte/pmd for
 shadow stack
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Date: Tue, 17 Jul 2018 16:00:35 -0700
In-Reply-To: <20180711092951.GW2476@hirez.programming.kicks-ass.net>
References: <20180710222639.8241-1-yu-cheng.yu@intel.com>
	 <20180710222639.8241-17-yu-cheng.yu@intel.com>
	 <20180711092951.GW2476@hirez.programming.kicks-ass.net>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromiun.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>

On Wed, 2018-07-11 at 11:29 +0200, Peter Zijlstra wrote:
> On Tue, Jul 10, 2018 at 03:26:28PM -0700, Yu-cheng Yu wrote:
> > 
> > There are three possible shadow stack PTE settings:
> > 
> > A  Normal SHSTK PTE: (R/O + DIRTY_HW)
> > A  SHSTK PTE COW'ed: (R/O + DIRTY_HW)
> > A  SHSTK PTE shared as R/O data: (R/O + DIRTY_SW)
> I count _2_ distinct states there.
> 
> > 
> > Update can_follow_write_pte/pmd for the shadow stack.
> So the below disallows can_follow_write when shstk && _PAGE_DIRTY_SW,
> but this here Changelog doesn't explain why. Doesn't even get close.

Can we add the following to the log:

When a SHSTK PTE is shared, it is (R/O + DIRTY_SW); otherwise it is
(R/O + DIRTY_HW).

When we (FOLL_WRITE | FOLL_FORCE) on a SHSTK PTE, the following
must be true:

A  - It has been COW'ed at least once (FOLL_COW is set);
A  - It still is not shared, i.e. PTE is (R/O + DIRTY_HW);

> 
> Also, the code is a right mess :/ Can't we try harder to not let this
> shadow stack stuff escape arch code.

We either check here if the VMA is SHSTK mapping or move the logic
to pte_dirty(). A The latter would be less obvious. A Or can we
create a can_follow_write_shstk_pte()?

Yu-cheng
