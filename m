Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id C75866B03A0
	for <linux-mm@kvack.org>; Wed, 29 Mar 2017 04:02:29 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id l95so1346706wrc.12
        for <linux-mm@kvack.org>; Wed, 29 Mar 2017 01:02:29 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n106si7563787wrb.62.2017.03.29.01.02.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 29 Mar 2017 01:02:28 -0700 (PDT)
Date: Wed, 29 Mar 2017 10:02:24 +0200 (CEST)
From: Miroslav Benes <mbenes@suse.cz>
Subject: Re: [PATCH v2] module: check if memory leak by module.
In-Reply-To: <20170329074522.GB27994@dhcp22.suse.cz>
Message-ID: <alpine.LSU.2.20.1703290958390.4250@pobox.suse.cz>
References: <CGME20170329060315epcas5p1c6f7ce3aca1b2770c5e1d9aaeb1a27e1@epcas5p1.samsung.com> <1490767322-9914-1-git-send-email-maninder1.s@samsung.com> <20170329074522.GB27994@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Maninder Singh <maninder1.s@samsung.com>, jeyu@redhat.com, rusty@rustcorp.com.au, akpm@linux-foundation.org, chris@chris-wilson.co.uk, aryabinin@virtuozzo.com, joonas.lahtinen@linux.intel.com, keescook@chromium.org, pavel@ucw.cz, jinb.park7@gmail.com, anisse@astier.eu, rafael.j.wysocki@intel.com, zijun_hu@htc.com, mingo@kernel.org, mawilcox@microsoft.com, thgarnie@google.com, joelaf@google.com, kirill.shutemov@linux.intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, pankaj.m@samsung.com, ajeet.y@samsung.com, hakbong5.lee@samsung.com, a.sahrawat@samsung.com, lalit.mohan@samsung.com, cpgs@samsung.com, Vaneet Narang <v.narang@samsung.com>

On Wed, 29 Mar 2017, Michal Hocko wrote:

> On Wed 29-03-17 11:32:02, Maninder Singh wrote:
> > This patch checks if any module which is going to be unloaded
> > is doing vmalloc memory leak or not.
> 
> Hmm, how can you track _all_ vmalloc allocations done on behalf of the
> module? It is quite some time since I've checked kernel/module.c but
> from my vague understading your check is basically only about statically
> vmalloced areas by module loader. Is that correct? If yes then is this
> actually useful? Were there any bugs in the loader code recently? What
> led you to prepare this patch? All this should be part of the changelog!

Moreover, I don't understand one thing:
  
> > Logs:-
> > [  129.336368] Module [test_module] is getting unloaded before doing vfree

ok, but...

> > +static void check_memory_leak(struct module *mod)
> > +{
> > +	struct vmap_area *va;
> > +
> > +	rcu_read_lock();
> > +	list_for_each_entry_rcu(va, &vmap_area_list, list) {
> > +		if (!(va->flags & VM_VM_AREA))
> > +			continue;
> > +		if ((mod->core_layout.base < va->vm->caller) &&
> > +			(mod->core_layout.base + mod->core_layout.size) > va->vm->caller) {
> > +			pr_err("Module [%s] is getting unloaded before doing vfree\n", mod->name);
> > +			pr_err("Memory still allocated: addr:0x%lx - 0x%lx, pages %u\n",
> > +				va->va_start, va->va_end, va->vm->nr_pages);
> > +			pr_err("Allocating function %pS\n", va->vm->caller);
> > +		}
> > +
> > +	}
> > +	rcu_read_unlock();
> > +}
> > +
> >  /* Free a module, remove from lists, etc. */
> >  static void free_module(struct module *mod)
> >  {
> > +	check_memory_leak(mod);
> > +

Of course, vfree() has not been called yet. It is the beginning of 
free_module(). vfree() is one of the last things you need to do. See 
module_memfree(). If I am not missing something, you get pr_err() 
everytime a module is unloaded.

Regards,
Miroslav

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
