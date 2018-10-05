Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3EAEF6B000A
	for <linux-mm@kvack.org>; Fri,  5 Oct 2018 13:03:11 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id w18-v6so11559196plp.3
        for <linux-mm@kvack.org>; Fri, 05 Oct 2018 10:03:11 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id h25-v6si9149121pgn.567.2018.10.05.10.03.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Oct 2018 10:03:09 -0700 (PDT)
Message-ID: <aa5a061c159471f410d677af6a609793906cece1.camel@intel.com>
Subject: Re: [RFC PATCH v4 3/9] x86/cet/ibt: Add IBT legacy code bitmap
 allocation function
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Date: Fri, 05 Oct 2018 09:58:24 -0700
In-Reply-To: <5BF3AE8F-CC2A-4160-9FF6-FEA171A76371@amacapital.net>
References: <20180921150553.21016-1-yu-cheng.yu@intel.com>
	 <20180921150553.21016-4-yu-cheng.yu@intel.com>
	 <20181003195702.GF32759@asgard.redhat.com>
	 <fc2f98ab46240c0498bdf4d7458b4373c1f02bf8.camel@intel.com>
	 <5BF3AE8F-CC2A-4160-9FF6-FEA171A76371@amacapital.net>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Eugene Syromiatnikov <esyr@redhat.com>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Florian Weimer <fweimer@redhat.com>, "H.J.
 Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, Randy Dunlap <rdunlap@infradead.org>, "Ravi V.
 Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>

On Fri, 2018-10-05 at 09:28 -0700, Andy Lutomirski wrote:
> > On Oct 5, 2018, at 9:13 AM, Yu-cheng Yu <yu-cheng.yu@intel.com> wrote:
> > 
> > > On Wed, 2018-10-03 at 21:57 +0200, Eugene Syromiatnikov wrote:
> > > > On Fri, Sep 21, 2018 at 08:05:47AM -0700, Yu-cheng Yu wrote:
> > > > Indirect branch tracking provides an optional legacy code bitmap
> > > > that indicates locations of non-IBT compatible code.  When set,
> > > > each bit in the bitmap represents a page in the linear address is
> > > > legacy code.
> > > > 
> > > > We allocate the bitmap only when the application requests it.
> > > > Most applications do not need the bitmap.
> > > > 
> > > > Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
> > > > ---
> > > > arch/x86/kernel/cet.c | 45 +++++++++++++++++++++++++++++++++++++++++++
> > > > 1 file changed, 45 insertions(+)
> > > > 
> > > > diff --git a/arch/x86/kernel/cet.c b/arch/x86/kernel/cet.c
> > > > index 6adfe795d692..a65d9745af08 100644
> > > > --- a/arch/x86/kernel/cet.c
> > > > +++ b/arch/x86/kernel/cet.c
> > > > @@ -314,3 +314,48 @@ void cet_disable_ibt(void)
> > > >    wrmsrl(MSR_IA32_U_CET, r);
> > > >    current->thread.cet.ibt_enabled = 0;
> > > > }
> > > > +
> > > > +int cet_setup_ibt_bitmap(void)
> > > > +{
> > > > +    u64 r;
> > > > +    unsigned long bitmap;
> > > > +    unsigned long size;
> > > > +
> > > > +    if (!cpu_feature_enabled(X86_FEATURE_IBT))
> > > > +        return -EOPNOTSUPP;
> > > > +
> > > > +    if (!current->thread.cet.ibt_bitmap_addr) {
> > > > +        /*
> > > > +         * Calculate size and put in thread header.
> > > > +         * may_expand_vm() needs this information.
> > > > +         */
> > > > +        size = TASK_SIZE / PAGE_SIZE / BITS_PER_BYTE;
> > > 
> > > TASK_SIZE_MAX is likely needed here, as an application can easily switch
> > > between long an 32-bit protected mode.  And then the case of a CPU that
> > > doesn't support 5LPT.
> > 
> > If we had calculated bitmap size from TASK_SIZE_MAX, all 32-bit apps would
> > have
> > failed the allocation for bitmap size > TASK_SIZE.  Please see values below,
> > which is printed from the current code.
> > 
> > Yu-cheng
> > 
> > 
> > x64:
> > TASK_SIZE_MAX    = 0000 7fff ffff f000
> > TASK_SIZE    = 0000 7fff ffff f000
> > bitmap size    = 0000 0000 ffff ffff
> > 
> > x32:
> > TASK_SIZE_MAX    = 0000 7fff ffff f000
> > TASK_SIZE    = 0000 0000 ffff e000
> > bitmap size    = 0000 0000 0001 ffff
> > 
> 
> I havena??t followed all the details here, but I have a general policy of
> objecting to any new use of TASK_SIZE. If you really really need to depend on
> 32-bitness in new code, please figure out what exactly you mean by a??32-bita??
> and use an explicit check.

The explicit check would be:

test_thread_flag(TIF_ADDR32) ? IA32_PAGE_OFFSET : TASK_SIZE_MAX

which is the same as TASK_SIZE.

Or, do we want a new macro?

#define IBT_BITMAP_SIZE (test_thread_flag(TIF_ADDR32) ? \
	(IA32_PAGE_OFFSET / PAGE_SIZE / BITS_PER_BYTE) : \
	(TASK_SIZE_MAX / PAGE_SIZE / BITS_PER_BYTE))

Yu-cheng
