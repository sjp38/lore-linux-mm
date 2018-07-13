Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7E20F6B0003
	for <linux-mm@kvack.org>; Fri, 13 Jul 2018 12:11:42 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id t19-v6so19974193plo.9
        for <linux-mm@kvack.org>; Fri, 13 Jul 2018 09:11:42 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id z7-v6si23435985pln.145.2018.07.13.09.11.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Jul 2018 09:11:41 -0700 (PDT)
Message-ID: <1531498079.8494.16.camel@intel.com>
Subject: Re: [RFC PATCH v2 25/27] x86/cet: Add PTRACE interface for CET
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Date: Fri, 13 Jul 2018 09:07:59 -0700
In-Reply-To: <alpine.DEB.2.21.1807130102470.1597@nanos.tec.linutronix.de>
References: <20180710222639.8241-1-yu-cheng.yu@intel.com>
	  <20180710222639.8241-26-yu-cheng.yu@intel.com>
	  <20180711102035.GB8574@gmail.com> <1531323638.13297.24.camel@intel.com>
	  <20180712140327.GA7810@gmail.com> <1531435034.2965.15.camel@intel.com>
	 <alpine.DEB.2.21.1807130102470.1597@nanos.tec.linutronix.de>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@kernel.org>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromiun.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>

On Fri, 2018-07-13 at 01:08 +0200, Thomas Gleixner wrote:
> On Thu, 12 Jul 2018, Yu-cheng Yu wrote:
> > 
> > On Thu, 2018-07-12 at 16:03 +0200, Ingo Molnar wrote:
> > > 
> > > * Yu-cheng Yu <yu-cheng.yu@intel.com> wrote:
> > > > 
> > > > > 
> > > > > > 
> > > > > > diff --git a/arch/x86/kernel/ptrace.c b/arch/x86/kernel/ptrace.c
> > > > > > index e2ee403865eb..ac2bc3a18427 100644
> > > > > > --- a/arch/x86/kernel/ptrace.c
> > > > > > +++ b/arch/x86/kernel/ptrace.c
> > > > > > @@ -49,7 +49,9 @@ enum x86_regset {
> > > > > > A 	REGSET_IOPERM64 = REGSET_XFP,
> > > > > > A 	REGSET_XSTATE,
> > > > > > A 	REGSET_TLS,
> > > > > > +	REGSET_CET64 = REGSET_TLS,
> > > > > > A 	REGSET_IOPERM32,
> > > > > > +	REGSET_CET32,
> > > > > > A };
> > > > > Why does REGSET_CET64 alias on REGSET_TLS?
> > > > In x86_64_regsets[], there is no [REGSET_TLS]. A The core dump code
> > > > cannot handle holes in the array.
> > > Is there a fundamental (ABI) reason for that?
> > What I did was, ran Linux with 'slub_debug', and forced a core dump
> > (kill -abrt <pid>), then there was a red zone warning in the dmesg.
> > My feeling is there could be issues in the core dump code. A These
> Kernel development is not about feelings.

I got that :-)

> 
> Either you can track down the root cause or you cannot. There is no place
> for feelings and no place in between. And if you cannot track down the root
> cause and explain it proper then the resulting patch is just papering over
> the symptoms and will come back to hunt you (or others) sooner than later.
> 
> No if, no could, no feelings. Facts is what matters. Really.

In kernel/ptrace.c,

find_regset(const struct user_regset_view *view, unsigned int type)
{
	const struct user_regset *regset;
	int n;

	for (n = 0; n < view->n; ++n) {
		regset = view->regsets + n;
		if (regset->core_note_type == type)
			return regset;
	}

	return NULL;
}

If there is a hole in the regset array, the empty slot's
regset->core_note_type is not defined.

We can add some comments near those enum's.

Yu-cheng
