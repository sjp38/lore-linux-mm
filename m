Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id C2E006B026F
	for <linux-mm@kvack.org>; Fri,  5 Oct 2018 12:18:47 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id i81-v6so9094945pfj.1
        for <linux-mm@kvack.org>; Fri, 05 Oct 2018 09:18:47 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id z29-v6si8205276pfl.209.2018.10.05.09.18.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Oct 2018 09:18:46 -0700 (PDT)
Message-ID: <fc2f98ab46240c0498bdf4d7458b4373c1f02bf8.camel@intel.com>
Subject: Re: [RFC PATCH v4 3/9] x86/cet/ibt: Add IBT legacy code bitmap
 allocation function
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Date: Fri, 05 Oct 2018 09:13:40 -0700
In-Reply-To: <20181003195702.GF32759@asgard.redhat.com>
References: <20180921150553.21016-1-yu-cheng.yu@intel.com>
	 <20180921150553.21016-4-yu-cheng.yu@intel.com>
	 <20181003195702.GF32759@asgard.redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eugene Syromiatnikov <esyr@redhat.com>
Cc: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, Randy Dunlap <rdunlap@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>

On Wed, 2018-10-03 at 21:57 +0200, Eugene Syromiatnikov wrote:
> On Fri, Sep 21, 2018 at 08:05:47AM -0700, Yu-cheng Yu wrote:
> > Indirect branch tracking provides an optional legacy code bitmap
> > that indicates locations of non-IBT compatible code.  When set,
> > each bit in the bitmap represents a page in the linear address is
> > legacy code.
> > 
> > We allocate the bitmap only when the application requests it.
> > Most applications do not need the bitmap.
> > 
> > Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
> > ---
> >  arch/x86/kernel/cet.c | 45 +++++++++++++++++++++++++++++++++++++++++++
> >  1 file changed, 45 insertions(+)
> > 
> > diff --git a/arch/x86/kernel/cet.c b/arch/x86/kernel/cet.c
> > index 6adfe795d692..a65d9745af08 100644
> > --- a/arch/x86/kernel/cet.c
> > +++ b/arch/x86/kernel/cet.c
> > @@ -314,3 +314,48 @@ void cet_disable_ibt(void)
> >  	wrmsrl(MSR_IA32_U_CET, r);
> >  	current->thread.cet.ibt_enabled = 0;
> >  }
> > +
> > +int cet_setup_ibt_bitmap(void)
> > +{
> > +	u64 r;
> > +	unsigned long bitmap;
> > +	unsigned long size;
> > +
> > +	if (!cpu_feature_enabled(X86_FEATURE_IBT))
> > +		return -EOPNOTSUPP;
> > +
> > +	if (!current->thread.cet.ibt_bitmap_addr) {
> > +		/*
> > +		 * Calculate size and put in thread header.
> > +		 * may_expand_vm() needs this information.
> > +		 */
> > +		size = TASK_SIZE / PAGE_SIZE / BITS_PER_BYTE;
> 
> TASK_SIZE_MAX is likely needed here, as an application can easily switch
> between long an 32-bit protected mode.  And then the case of a CPU that
> doesn't support 5LPT.

If we had calculated bitmap size from TASK_SIZE_MAX, all 32-bit apps would have
failed the allocation for bitmap size > TASK_SIZE.  Please see values below,
which is printed from the current code.

Yu-cheng


x64:
TASK_SIZE_MAX	= 0000 7fff ffff f000
TASK_SIZE	= 0000 7fff ffff f000
bitmap size	= 0000 0000 ffff ffff

x32:
TASK_SIZE_MAX	= 0000 7fff ffff f000
TASK_SIZE	= 0000 0000 ffff e000
bitmap size	= 0000 0000 0001 ffff
