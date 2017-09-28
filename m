Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 69C906B0038
	for <linux-mm@kvack.org>; Thu, 28 Sep 2017 09:19:14 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id v109so2222648wrc.5
        for <linux-mm@kvack.org>; Thu, 28 Sep 2017 06:19:14 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d21sor963248edb.24.2017.09.28.06.19.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 28 Sep 2017 06:19:12 -0700 (PDT)
Date: Thu, 28 Sep 2017 16:19:10 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv7 11/19] x86/mm: Make STACK_TOP_MAX dynamic
Message-ID: <20170928131910.7t7ops6b7h7fcrmm@node.shutemov.name>
References: <20170918105553.27914-1-kirill.shutemov@linux.intel.com>
 <20170918105553.27914-12-kirill.shutemov@linux.intel.com>
 <20170928082955.n7t4wlz7olsgwkfn@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170928082955.n7t4wlz7olsgwkfn@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Sep 28, 2017 at 10:29:55AM +0200, Ingo Molnar wrote:
> 
> * Kirill A. Shutemov <kirill.shutemov@linux.intel.com> wrote:
> 
> > For boot-time switching between paging modes, we need to be able to
> > change STACK_TOP_MAX at runtime.
> > 
> > The change is trivial and it doesn't affect kernel image size.
> > 
> > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > ---
> >  arch/x86/include/asm/processor.h | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff --git a/arch/x86/include/asm/processor.h b/arch/x86/include/asm/processor.h
> > index 3fa26a61eabc..fa9300ccce1b 100644
> > --- a/arch/x86/include/asm/processor.h
> > +++ b/arch/x86/include/asm/processor.h
> > @@ -871,7 +871,7 @@ static inline void spin_lock_prefetch(const void *x)
> >  					IA32_PAGE_OFFSET : TASK_SIZE_MAX)
> >  
> >  #define STACK_TOP		TASK_SIZE_LOW
> > -#define STACK_TOP_MAX		TASK_SIZE_MAX
> > +#define STACK_TOP_MAX		(pgtable_l5_enabled ? TASK_SIZE_MAX : DEFAULT_MAP_WINDOW)
> 
> While it's only used once in fs/exec.c, why doesn't it affect kernel image size?

Oh. After closer look the patch is redundant. The STACK_TOP_MAX is already
dynamic due to dynamic TASK_SIZE_MAX, so gcc generates exactly the same
code before and after the patch.

I'll drop it.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
