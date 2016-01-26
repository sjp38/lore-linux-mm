Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 6449F6B0009
	for <linux-mm@kvack.org>; Tue, 26 Jan 2016 18:29:40 -0500 (EST)
Received: by mail-pa0-f54.google.com with SMTP id cy9so105245100pac.0
        for <linux-mm@kvack.org>; Tue, 26 Jan 2016 15:29:40 -0800 (PST)
Received: from mail-pa0-x234.google.com (mail-pa0-x234.google.com. [2607:f8b0:400e:c03::234])
        by mx.google.com with ESMTPS id y5si4955424pfa.0.2016.01.26.15.29.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Jan 2016 15:29:39 -0800 (PST)
Received: by mail-pa0-x234.google.com with SMTP id uo6so107202893pac.1
        for <linux-mm@kvack.org>; Tue, 26 Jan 2016 15:29:39 -0800 (PST)
Date: Tue, 26 Jan 2016 15:29:38 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH/RFC 3/3] s390: query dynamic DEBUG_PAGEALLOC setting
In-Reply-To: <20160126181903.GB4671@osiris>
Message-ID: <alpine.DEB.2.10.1601261525580.25141@chino.kir.corp.google.com>
References: <1453799905-10941-1-git-send-email-borntraeger@de.ibm.com> <1453799905-10941-4-git-send-email-borntraeger@de.ibm.com> <20160126181903.GB4671@osiris>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Christian Borntraeger <borntraeger@de.ibm.com>, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, x86@kernel.org

On Tue, 26 Jan 2016, Heiko Carstens wrote:

> On Tue, Jan 26, 2016 at 10:18:25AM +0100, Christian Borntraeger wrote:
> > We can use debug_pagealloc_enabled() to check if we can map
> > the identity mapping with 1MB/2GB pages as well as to print
> > the current setting in dump_stack.
> > 
> > Signed-off-by: Christian Borntraeger <borntraeger@de.ibm.com>
> > ---
> >  arch/s390/kernel/dumpstack.c |  4 +++-
> >  arch/s390/mm/vmem.c          | 10 ++++------
> >  2 files changed, 7 insertions(+), 7 deletions(-)
> > 
> > diff --git a/arch/s390/kernel/dumpstack.c b/arch/s390/kernel/dumpstack.c
> > index dc8e204..a1c0530 100644
> > --- a/arch/s390/kernel/dumpstack.c
> > +++ b/arch/s390/kernel/dumpstack.c
> > @@ -11,6 +11,7 @@
> >  #include <linux/export.h>
> >  #include <linux/kdebug.h>
> >  #include <linux/ptrace.h>
> > +#include <linux/mm.h>
> >  #include <linux/module.h>
> >  #include <linux/sched.h>
> >  #include <asm/processor.h>
> > @@ -186,7 +187,8 @@ void die(struct pt_regs *regs, const char *str)
> >  	printk("SMP ");
> >  #endif
> >  #ifdef CONFIG_DEBUG_PAGEALLOC
> > -	printk("DEBUG_PAGEALLOC");
> > +	printk("DEBUG_PAGEALLOC(%s)",
> > +		debug_pagealloc_enabled() ? "enabled" : "disabled");
> >  #endif
> 
> I'd prefer if you change this to
> 
> 	if (debug_pagealloc_enabled())
> 		printk("DEBUG_PAGEALLOC");
> 
> That way we can get rid of yet another ifdef. Having
> "DEBUG_PAGEALLOC(disabled)" doesn't seem to be very helpful.
> 

I'd agree if CONFIG_DEBUG_PAGEALLOC only did anything when 
debug_pagealloc_enabled() is true, but that doesn't seem to be the case.  
When CONFIG_DEBUG_SLAB is enabled, for instance, CONFIG_DEBUG_PAGEALLOC 
also enables stackinfo storing and poisoning and it's not guarded by 
debug_pagealloc_enabled().

It seems like CONFIG_DEBUG_PAGEALLOC enables debugging functionality 
outside the scope of the debug_pagealloc=on kernel parameter, so 
DEBUG_PAGEALLOC(disabled) actually does mean something.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
