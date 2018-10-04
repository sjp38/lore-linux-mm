Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7C5E26B0010
	for <linux-mm@kvack.org>; Thu,  4 Oct 2018 11:42:01 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id i76-v6so6249637pfk.14
        for <linux-mm@kvack.org>; Thu, 04 Oct 2018 08:42:01 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id c4-v6si4879304pgn.309.2018.10.04.08.41.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Oct 2018 08:42:00 -0700 (PDT)
Message-ID: <3350f7b42b32f3f7a1963a9c9c526210c24f7b05.camel@intel.com>
Subject: Re: [RFC PATCH v4 6/9] x86/cet/ibt: Add arch_prctl functions for IBT
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Date: Thu, 04 Oct 2018 08:37:16 -0700
In-Reply-To: <20181004132811.GJ32759@asgard.redhat.com>
References: <20180921150553.21016-1-yu-cheng.yu@intel.com>
	 <20180921150553.21016-7-yu-cheng.yu@intel.com>
	 <20181004132811.GJ32759@asgard.redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eugene Syromiatnikov <esyr@redhat.com>
Cc: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, Randy Dunlap <rdunlap@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>

On Thu, 2018-10-04 at 15:28 +0200, Eugene Syromiatnikov wrote:
> On Fri, Sep 21, 2018 at 08:05:50AM -0700, Yu-cheng Yu wrote:
> > Update ARCH_CET_STATUS and ARCH_CET_DISABLE to include Indirect
> > Branch Tracking features.
> > 
> > Introduce:
> > 
> > arch_prctl(ARCH_CET_LEGACY_BITMAP, unsigned long *addr)
> >     Enable the Indirect Branch Tracking legacy code bitmap.
> > 
> >     The parameter 'addr' is a pointer to a user buffer.
> >     On returning to the caller, the kernel fills the following:
> > 
> >     *addr = IBT bitmap base address
> >     *(addr + 1) = IBT bitmap size
> 
> Again, some structure with a size field would be better from
> UAPI/extensibility standpoint.
> 
> One additional point: "size" in the structure from kernel should have
> structure size expected by kernel, and at least providing there "0" from
> user space shouldn't lead to failure (in fact, it is possible to provide
> structure size back to userspace even if buffer is too small, along
> with error).

This has been in GLIBC v2.28.  We cannot change it anymore.

> 
> > 
> > Signed-off-by: H.J. Lu <hjl.tools@gmail.com>
> > Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
> > ---
> >  arch/x86/include/uapi/asm/prctl.h |  1 +
> >  arch/x86/kernel/cet_prctl.c       | 38 ++++++++++++++++++++++++++++++-
> >  arch/x86/kernel/process.c         |  1 +
> >  3 files changed, 39 insertions(+), 1 deletion(-)
> > 
> > diff --git a/arch/x86/include/uapi/asm/prctl.h
> > b/arch/x86/include/uapi/asm/prctl.h
> > index 3aec1088e01d..31d2465f9caf 100644
> > --- a/arch/x86/include/uapi/asm/prctl.h
> > +++ b/arch/x86/include/uapi/asm/prctl.h
> > @@ -18,5 +18,6 @@
> >  #define ARCH_CET_DISABLE	0x3002
> >  #define ARCH_CET_LOCK		0x3003
> >  #define ARCH_CET_ALLOC_SHSTK	0x3004
> > +#define ARCH_CET_LEGACY_BITMAP	0x3005
> 
> It would probably be nice to have mention of an architecture in these
> definitions ("ARCH_X86_CET_"...), but it's likely too late.

We can still change macro names.  I will work on that.

> 
> >  
> >  #endif /* _ASM_X86_PRCTL_H */
> > diff --git a/arch/x86/kernel/cet_prctl.c b/arch/x86/kernel/cet_prctl.c
> > index c4b7c19f5040..df47b5ebc3f4 100644
> > --- a/arch/x86/kernel/cet_prctl.c
> > +++ b/arch/x86/kernel/cet_prctl.c
> > @@ -20,6 +20,8 @@ static int handle_get_status(unsigned long arg2)
> >  
> >  	if (current->thread.cet.shstk_enabled)
> >  		features |= GNU_PROPERTY_X86_FEATURE_1_SHSTK;
> > +	if (current->thread.cet.ibt_enabled)
> > +		features |= GNU_PROPERTY_X86_FEATURE_1_IBT;
> >  
> >  	shstk_base = current->thread.cet.shstk_base;
> >  	shstk_size = current->thread.cet.shstk_size;
> > @@ -49,9 +51,35 @@ static int handle_alloc_shstk(unsigned long arg2)
> >  	return 0;
> >  }
> >  
> > +static int handle_bitmap(unsigned long arg2)
> > +{
> > +	unsigned long addr, size;
> > +
> > +	if (current->thread.cet.ibt_enabled) {
> > +		int err;
> > +
> > +		err  = cet_setup_ibt_bitmap();
> > +		if (err)
> > +			return err;
> > +
> > +		addr = current->thread.cet.ibt_bitmap_addr;
> > +		size = current->thread.cet.ibt_bitmap_size;
> > +	} else {
> > +		addr = 0;
> > +		size = 0;
> > +	}
> > +
> > +	if (put_user(addr, (unsigned long __user *)arg2) ||
> > +	    put_user(size, (unsigned long __user *)arg2 + 1))
> > +		return -EFAULT;
> > +
> > +	return 0;
> > +}
> > +
> >  int prctl_cet(int option, unsigned long arg2)
> >  {
> > -	if (!cpu_feature_enabled(X86_FEATURE_SHSTK))
> > +	if (!cpu_feature_enabled(X86_FEATURE_SHSTK) &&
> > +	    !cpu_feature_enabled(X86_FEATURE_IBT))
> 
> This check is repeated many times, it is probably worth defining
> something like cpu_x86_cet_enabled() or something like that.
> Besides, early introduction of the macro would allow avoiding all these
> changes over the code in IBT patches, only macro definition has
> to be changed that way.

Yes, that makes things easier.

> 
> > @@ -73,6 +103,12 @@ int prctl_cet(int option, unsigned long arg2)
> >  	case ARCH_CET_ALLOC_SHSTK:
> >  		return handle_alloc_shstk(arg2);
> >  
> > +	/*
> > +	 * Allocate legacy bitmap and return address & size to user.
> > +	 */
> > +	case ARCH_CET_LEGACY_BITMAP:
> > +		return handle_bitmap(arg2);
> > +
> >  	default:
> >  		return -EINVAL;
> >  	}
> > diff --git a/arch/x86/kernel/process.c b/arch/x86/kernel/process.c
> > index ac0ea9c7e89f..aea15a9b6a3e 100644
> > --- a/arch/x86/kernel/process.c
> > +++ b/arch/x86/kernel/process.c
> > @@ -797,6 +797,7 @@ long do_arch_prctl_common(struct task_struct *task, int
> > option,
> >  	case ARCH_CET_DISABLE:
> >  	case ARCH_CET_LOCK:
> >  	case ARCH_CET_ALLOC_SHSTK:
> > +	case ARCH_CET_LEGACY_BITMAP:
> >  		return prctl_cet(option, cpuid_enabled);
> >  	}
> 
> I wonder, whether this duplication is really needed for CET-related
> arch_prctl commands, why not just call them from do_arch_prctl_common?

I will fix it.

Yu-cheng
