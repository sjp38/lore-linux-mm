Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id EAACF6B000A
	for <linux-mm@kvack.org>; Wed, 11 Jul 2018 19:04:23 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id m2-v6so15857724plt.14
        for <linux-mm@kvack.org>; Wed, 11 Jul 2018 16:04:23 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id d1-v6si18729605pgo.337.2018.07.11.16.04.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Jul 2018 16:04:22 -0700 (PDT)
Message-ID: <1531350028.15351.102.camel@intel.com>
Subject: Re: [RFC PATCH v2 22/27] x86/cet/ibt: User-mode indirect branch
 tracking support
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Date: Wed, 11 Jul 2018 16:00:28 -0700
In-Reply-To: <f97ce234-52fa-e666-2250-098925cf3c39@linux.intel.com>
References: <20180710222639.8241-1-yu-cheng.yu@intel.com>
	 <20180710222639.8241-23-yu-cheng.yu@intel.com>
	 <3a7e9ce4-03c6-cc28-017b-d00108459e94@linux.intel.com>
	 <1531347019.15351.89.camel@intel.com>
	 <f97ce234-52fa-e666-2250-098925cf3c39@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>, x86@kernel.org, "H. Peter
 Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Florian Weimer <fweimer@redhat.com>, "H.J.
 Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromiun.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>

On Wed, 2018-07-11 at 15:40 -0700, Dave Hansen wrote:
> On 07/11/2018 03:10 PM, Yu-cheng Yu wrote:
> > 
> > On Tue, 2018-07-10 at 17:11 -0700, Dave Hansen wrote:
> > > 
> > > Is this feature *integral* to shadow stacks?A A Or, should it just
> > > be
> > > in a
> > > different series?
> > The whole CET series is mostly about SHSTK and only a minority for
> > IBT.
> > IBT changes cannot be applied by itself without first applying
> > SHSTK
> > changes. A Would the titles help, e.g. x86/cet/ibt, x86/cet/shstk,
> > etc.?
> That doesn't really answer what I asked, though.
> 
> Do shadow stacks *require* IBT?A A Or, should we concentrate on merging
> shadow stacks themselves first and then do IBT at a later time, in a
> different patch series?
> 
> But, yes, better patch titles would help, although I'm not sure
> that's
> quite the format that Ingo and Thomas prefer.

Shadow stack does not require IBT, but they complement each other. A If
we can resolve the legacy bitmap, both features can be merged at the
same time.

> 
> > 
> > > 
> > > > 
> > > > +int cet_setup_ibt_bitmap(void)
> > > > +{
> > > > +	u64 r;
> > > > +	unsigned long bitmap;
> > > > +	unsigned long size;
> > > > +
> > > > +	if (!cpu_feature_enabled(X86_FEATURE_IBT))
> > > > +		return -EOPNOTSUPP;
> > > > +
> > > > +	size = TASK_SIZE_MAX / PAGE_SIZE / BITS_PER_BYTE;
> > > Just a note: this table is going to be gigantic on 5-level paging
> > > systems, and userspace won't, by default use any of that extra
> > > address
> > > space.A A I think it ends up being a 512GB allocation in a 128TB
> > > address
> > > space.
> > > 
> > > Is that a problem?
> > > 
> > > On 5-level paging systems, maybe we should just stick it up in
> > > theA 
> > > high part of the address space.
> > We do not know in advance if dlopen() needs to create the bitmap.
> > A Do
> > we always reserve high address or force legacy libs to low address?
> Does it matter?A A Does code ever get pointers to this area?A A Might
> they
> be depending on high address bits for the IBT being clear?

GLIBC does the bitmap setup. A It sets bits in there.
I thought you wanted a smaller bitmap? A One way is forcing legacy libs
to low address, or not having the bitmap at all, i.e. turn IBT off.

> 
> 
> > 
> > > 
> > > > 
> > > > +	bitmap = ibt_mmap(0, size);
> > > > +
> > > > +	if (bitmap >= TASK_SIZE_MAX)
> > > > +		return -ENOMEM;
> > > > +
> > > > +	bitmap &= PAGE_MASK;
> > > We're page-aligning the result of an mmap()?A A Why?
> > This may not be necessary. A The lower bits of MSR_IA32_U_CET are
> > settings and not part of the bitmap address. A Is this is safer?
> No.A A If we have mmap() returning non-page-aligned addresses, we have
> bigger problems.A A Worst-case, do
> 
> 	WARN_ON_ONCE(bitmap & ~PAGE_MASK);
> 

Ok.

> > 
> > > 
> > > > 
> > > > +	current->thread.cet.ibt_bitmap_addr = bitmap;
> > > > +	current->thread.cet.ibt_bitmap_size = size;
> > > > +	return 0;
> > > > +}
> > > > +
> > > > +void cet_disable_ibt(void)
> > > > +{
> > > > +	u64 r;
> > > > +
> > > > +	if (!cpu_feature_enabled(X86_FEATURE_IBT))
> > > > +		return;
> > > Does this need a check for being already disabled?
> > We need that. A We cannot write to those MSRs if the CPU does not
> > support it.
> No, I mean for code doing cet_disable_ibt() twice in a row.

Got it.

> 
> > 
> > > 
> > > > 
> > > > +	rdmsrl(MSR_IA32_U_CET, r);
> > > > +	r &= ~(MSR_IA32_CET_ENDBR_EN | MSR_IA32_CET_LEG_IW_EN
> > > > |
> > > > +	A A A A A A A MSR_IA32_CET_NO_TRACK_EN);
> > > > +	wrmsrl(MSR_IA32_U_CET, r);
> > > > +	current->thread.cet.ibt_enabled = 0;
> > > > +}
> > > What's the locking for current->thread.cet?
> > Now CET is not locked until the application callsA ARCH_CET_LOCK.
> No, I mean what is the in-kernel locking for the current->thread.cet
> data structure?A A Is there none because it's only every modified via
> current->thread and it's entirely thread-local?

Yes, that is the case.
