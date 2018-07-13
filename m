Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6C4346B0003
	for <linux-mm@kvack.org>; Fri, 13 Jul 2018 14:00:35 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id t19-v6so20146519plo.9
        for <linux-mm@kvack.org>; Fri, 13 Jul 2018 11:00:35 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id 185-v6si23300408pgj.511.2018.07.13.11.00.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Jul 2018 11:00:34 -0700 (PDT)
Message-ID: <1531504609.11680.16.camel@intel.com>
Subject: Re: [RFC PATCH v2 22/27] x86/cet/ibt: User-mode indirect branch
 tracking support
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Date: Fri, 13 Jul 2018 10:56:49 -0700
In-Reply-To: <25675609-9ea7-55fb-6e73-b4a4c49b6c35@linux.intel.com>
References: <20180710222639.8241-1-yu-cheng.yu@intel.com>
	 <20180710222639.8241-23-yu-cheng.yu@intel.com>
	 <3a7e9ce4-03c6-cc28-017b-d00108459e94@linux.intel.com>
	 <1531347019.15351.89.camel@intel.com>
	 <f97ce234-52fa-e666-2250-098925cf3c39@linux.intel.com>
	 <1531350028.15351.102.camel@intel.com>
	 <25675609-9ea7-55fb-6e73-b4a4c49b6c35@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>, x86@kernel.org, "H. Peter
 Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Florian Weimer <fweimer@redhat.com>, "H.J.
 Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromiun.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>

On Wed, 2018-07-11 at 16:16 -0700, Dave Hansen wrote:
> On 07/11/2018 04:00 PM, Yu-cheng Yu wrote:
> > 
> > On Wed, 2018-07-11 at 15:40 -0700, Dave Hansen wrote:
> > > 
> > > On 07/11/2018 03:10 PM, Yu-cheng Yu wrote:
> > > > 
> > > > 
> > > > On Tue, 2018-07-10 at 17:11 -0700, Dave Hansen wrote:
> > > > > 
> > > > > 
> > > > > Is this feature *integral* to shadow stacks?A A Or, should it just
> > > > > be
> > > > > in a
> > > > > different series?
> > > > The whole CET series is mostly about SHSTK and only a minority for
> > > > IBT.
> > > > IBT changes cannot be applied by itself without first applying
> > > > SHSTK
> > > > changes. A Would the titles help, e.g. x86/cet/ibt, x86/cet/shstk,
> > > > etc.?
> > > That doesn't really answer what I asked, though.
> > > 
> > > Do shadow stacks *require* IBT?A A Or, should we concentrate on merging
> > > shadow stacks themselves first and then do IBT at a later time, in a
> > > different patch series?
> > > 
> > > But, yes, better patch titles would help, although I'm not sure
> > > that's
> > > quite the format that Ingo and Thomas prefer.
> > Shadow stack does not require IBT, but they complement each other. A If
> > we can resolve the legacy bitmap, both features can be merged at the
> > same time.
> As large as this patch set is, I'd really prefer to see you get shadow
> stacks merged and then move on to IBT.A A I say separate them.

Ok, separate them.

> 
> > 
> > GLIBC does the bitmap setup. A It sets bits in there.
> > I thought you wanted a smaller bitmap? A One way is forcing legacy libs
> > to low address, or not having the bitmap at all, i.e. turn IBT off.
> I'm concerned with two things:
> 1. the virtual address space consumption, especially the *default* case
> A A A which will be apps using 4-level address space amounts, but having
> A A A 5-level-sized tables.
> 2. the driving a truck-sized hole in the address space limits
> 
> You can force legacy libs to low addresses, but you can't stop anyone
> from putting code into a high address *later*, at least with the code we
> have today.

So we will always reserve a big space for all CET tasks?

Currently if an application does dlopen() a legacy lib, it will have only
partial IBT protection and no SHSTK. A Do we want to consider simply turning
off IBT in that case?

Yu-cheng
