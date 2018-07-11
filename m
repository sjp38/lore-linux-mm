Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 05FAC6B0008
	for <linux-mm@kvack.org>; Wed, 11 Jul 2018 13:31:56 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id t19-v6so15361546plo.9
        for <linux-mm@kvack.org>; Wed, 11 Jul 2018 10:31:55 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id n187-v6si19325375pgn.368.2018.07.11.10.31.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Jul 2018 10:31:54 -0700 (PDT)
Message-ID: <1531330096.15351.10.camel@intel.com>
Subject: Re: [RFC PATCH v2 12/27] x86/mm: Shadow stack page fault error
 checking
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Date: Wed, 11 Jul 2018 10:28:16 -0700
In-Reply-To: <61793360-f37c-ec19-c390-abe3c76a5f5c@linux.intel.com>
References: <20180710222639.8241-1-yu-cheng.yu@intel.com>
	 <20180710222639.8241-13-yu-cheng.yu@intel.com>
	 <61793360-f37c-ec19-c390-abe3c76a5f5c@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>, x86@kernel.org, "H. Peter
 Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Florian Weimer <fweimer@redhat.com>, "H.J.
 Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromiun.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>

On Tue, 2018-07-10 at 15:52 -0700, Dave Hansen wrote:
> On 07/10/2018 03:26 PM, Yu-cheng Yu wrote:
> > 
> > +++ b/arch/x86/include/asm/traps.h
> > @@ -157,6 +157,7 @@ enum {
> > A  *A A A bit 3 ==				1: use of reserved
> > bit detected
> > A  *A A A bit 4 ==				1: fault was an
> > instruction fetch
> > A  *A A A bit 5 ==				1: protection keys
> > block access
> > + *A A A bit 6 ==				1: shadow stack
> > access fault
> > A  */
> Could we document this bit better?
> 
> Is this a fault where the *processor* thought it should be a shadow
> stack fault?A A Or is it also set on faults to valid shadow stack PTEs
> that just happen to fault for other reasons, say protection keys?

Thanks Vedvyas for explaining this to me.
I will add this to comments:

This flag is 1 if (1) CR4.CET = 1; and (2) the access causing the page-
fault exception was a shadow-stack data access.

So this bit does not report the reason for the fault. It reports the
type of access; i.e. it was a shadow-stack-load or a shadow-stack-store 
that took the page fault. The fault could have been caused by any
variety of reasons including protection keys.
