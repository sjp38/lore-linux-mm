Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 853DF6B000A
	for <linux-mm@kvack.org>; Wed, 10 Oct 2018 12:01:16 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id y86-v6so5011367pff.6
        for <linux-mm@kvack.org>; Wed, 10 Oct 2018 09:01:16 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id 3-v6si27340739pfm.51.2018.10.10.09.01.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Oct 2018 09:01:14 -0700 (PDT)
Message-ID: <f6dcfb3c548f49cd096088e4366e44f57ec5964e.camel@intel.com>
Subject: Re: [RFC PATCH v4 3/9] x86/cet/ibt: Add IBT legacy code bitmap
 allocation function
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Date: Wed, 10 Oct 2018 08:56:03 -0700
In-Reply-To: <20181005172622.GD19360@asgard.redhat.com>
References: <20180921150553.21016-1-yu-cheng.yu@intel.com>
	 <20180921150553.21016-4-yu-cheng.yu@intel.com>
	 <20181003195702.GF32759@asgard.redhat.com>
	 <fc2f98ab46240c0498bdf4d7458b4373c1f02bf8.camel@intel.com>
	 <5BF3AE8F-CC2A-4160-9FF6-FEA171A76371@amacapital.net>
	 <aa5a061c159471f410d677af6a609793906cece1.camel@intel.com>
	 <CALCETrXVdYsJsVy=QWruDYdRc6wb44b=0J3OK3zjR_fT1fQH7w@mail.gmail.com>
	 <20181005172622.GD19360@asgard.redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eugene Syromiatnikov <esyr@redhat.com>, Andy Lutomirski <luto@amacapital.net>
Cc: X86 ML <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, LKML <linux-kernel@vger.kernel.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Florian Weimer <fweimer@redhat.com>, "H. J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, Randy Dunlap <rdunlap@infradead.org>, "Shankar, Ravi V" <ravi.v.shankar@intel.com>, "Shanbhogue, Vedvyas" <vedvyas.shanbhogue@intel.com>

On Fri, 2018-10-05 at 10:26 -0700, Eugene Syromiatnikov wrote:
> On Fri, Oct 05, 2018 at 10:07:46AM -0700, Andy Lutomirski wrote:
> > On Fri, Oct 5, 2018 at 10:03 AM Yu-cheng Yu <yu-cheng.yu@intel.com> wrote:
> > > 
> > > On Fri, 2018-10-05 at 09:28 -0700, Andy Lutomirski wrote:
> > > > > On Oct 5, 2018, at 9:13 AM, Yu-cheng Yu <yu-cheng.yu@intel.com> wrote:
> > > > > 
> > > > > > On Wed, 2018-10-03 at 21:57 +0200, Eugene Syromiatnikov wrote:
> > > > > > > On Fri, Sep 21, 2018 at 08:05:47AM -0700, Yu-cheng Yu wrote:
> > > > > > > Indirect branch tracking provides an optional legacy code bitmap
> > > > > > > that indicates locations of non-IBT compatible code.  When set,
> > > > > > > each bit in the bitmap represents a page in the linear address is
> > > > > > > legacy code.
> > > > > > > 
> > > > > > > We allocate the bitmap only when the application requests it.
> > > > > > > Most applications do not need the bitmap.
> > > > > > > 
> > > > > > > Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
> > > > > > > ---
> > > > > > > arch/x86/kernel/cet.c | 45
> > > > > > > +++++++++++++++++++++++++++++++++++++++++++
> > > > > > > 1 file changed, 45 insertions(+)
> > > > > > > 
> > > > > > > diff --git a/arch/x86/kernel/cet.c b/arch/x86/kernel/cet.c
> > > > > > > index 6adfe795d692..a65d9745af08 100644
> > > > > > > --- a/arch/x86/kernel/cet.c
> > > > > > > +++ b/arch/x86/kernel/cet.c
> > > > > > > @@ -314,3 +314,48 @@ void cet_disable_ibt(void)
> > > > > > >    wrmsrl(MSR_IA32_U_CET, r);
> > > > > > >    current->thread.cet.ibt_enabled = 0;
> > > > > > > }
> > > > > > > +
> > > > > > > +int cet_setup_ibt_bitmap(void)
> > > > > > > +{
> > > > > > > +    u64 r;
> > > > > > > +    unsigned long bitmap;
> > > > > > > +    unsigned long size;
> > > > > > > +
> > > > > > > +    if (!cpu_feature_enabled(X86_FEATURE_IBT))
> > > > > > > +        return -EOPNOTSUPP;
> > > > > > > +
> > > > > > > +    if (!current->thread.cet.ibt_bitmap_addr) {
> > > > > > > +        /*
> > > > > > > +         * Calculate size and put in thread header.
> > > > > > > +         * may_expand_vm() needs this information.
> > > > > > > +         */
> > > > > > > +        size = TASK_SIZE / PAGE_SIZE / BITS_PER_BYTE;
> > > > > > 
> > > > > > TASK_SIZE_MAX is likely needed here, as an application can easily
> > > > > > switch
> > > > > > between long an 32-bit protected mode.  And then the case of a CPU
> > > > > > that
> > > > > > doesn't support 5LPT.
> > > > > 
> > > > > If we had calculated bitmap size from TASK_SIZE_MAX, all 32-bit apps
> > > > > would
> > > > > have
> > > > > failed the allocation for bitmap size > TASK_SIZE.  Please see values
> > > > > below,
> > > > > which is printed from the current code.
> > > > > 
> > > > > Yu-cheng
> > > > > 
> > > > > 
> > > > > x64:
> > > > > TASK_SIZE_MAX    = 0000 7fff ffff f000
> > > > > TASK_SIZE    = 0000 7fff ffff f000
> > > > > bitmap size    = 0000 0000 ffff ffff
> > > > > 
> > > > > x32:
> > > > > TASK_SIZE_MAX    = 0000 7fff ffff f000
> > > > > TASK_SIZE    = 0000 0000 ffff e000
> > > > > bitmap size    = 0000 0000 0001 ffff
> > > > > 
> > > > 
> > > > I havena??t followed all the details here, but I have a general policy of
> > > > objecting to any new use of TASK_SIZE. If you really really need to
> > > > depend on
> > > > 32-bitness in new code, please figure out what exactly you mean by a??32-
> > > > bita??
> > > > and use an explicit check.
> > > 
> > > The explicit check would be:
> > > 
> > > test_thread_flag(TIF_ADDR32) ? IA32_PAGE_OFFSET : TASK_SIZE_MAX
> > > 
> > > which is the same as TASK_SIZE.
> > 
> > But this is only ever done in response to a syscall, right?  So
> > wouldn't in_compat_syscall() be the right check?
> > 
> > Also, this whole thing makes me extremely nervous.  The MSR only
> > contains the start address, not the size, right?  So what prevents
> > some goof from causing the CPU to read way past the end of the bitmap
> > if the bitmap is short because the kernel thought it was supposed to
> > be 32-bit?
> 
> That's what I've mentioned initially: every syscall made with int 0x80
> is interpreted as compat, even if it was made from long mode.
> 
> > I'm inclined to suggest something awful-ish: always allocate the
> > bitmap as though it's for a 64-bit process, and just let it be at a
> > high address.  And add a syscall or arch_prctl() to manipulate it for
> > the benefit of 32-bit programs that can't address it directly.
> 
> That's likely the only way to go.

This bitmap is needed only when the app does dlopen() a non-IBT .so file.  Most
applications do not need it.  Can't we let dlopen mmap() the bitmap when needed
and pass it to the kernel?

Yu-cheng
