Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f170.google.com (mail-ig0-f170.google.com [209.85.213.170])
	by kanga.kvack.org (Postfix) with ESMTP id 4747B6B0255
	for <linux-mm@kvack.org>; Wed,  2 Dec 2015 23:13:51 -0500 (EST)
Received: by igbxm8 with SMTP id xm8so3754255igb.1
        for <linux-mm@kvack.org>; Wed, 02 Dec 2015 20:13:51 -0800 (PST)
Received: from cdptpa-oedge-vip.email.rr.com (cdptpa-outbound-snat.email.rr.com. [107.14.166.225])
        by mx.google.com with ESMTP id t82si10324470ioe.111.2015.12.02.20.13.50
        for <linux-mm@kvack.org>;
        Wed, 02 Dec 2015 20:13:50 -0800 (PST)
Date: Wed, 2 Dec 2015 23:13:48 -0500
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH V2 2/7] mm/gup: add gup trace points
Message-ID: <20151202231348.7058d6e2@grimm.local.home>
In-Reply-To: <565F8092.7000001@intel.com>
References: <1449096813-22436-1-git-send-email-yang.shi@linaro.org>
	<1449096813-22436-3-git-send-email-yang.shi@linaro.org>
	<565F8092.7000001@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Yang Shi <yang.shi@linaro.org>, akpm@linux-foundation.org, mingo@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linaro-kernel@lists.linaro.org

On Wed, 2 Dec 2015 15:36:50 -0800
Dave Hansen <dave.hansen@intel.com> wrote:

> On 12/02/2015 02:53 PM, Yang Shi wrote:
> > diff --git a/mm/gup.c b/mm/gup.c
> > index deafa2c..10245a4 100644
> > --- a/mm/gup.c
> > +++ b/mm/gup.c
> > @@ -13,6 +13,9 @@
> >  #include <linux/rwsem.h>
> >  #include <linux/hugetlb.h>
> >  
> > +#define CREATE_TRACE_POINTS
> > +#include <trace/events/gup.h>
> > +
> >  #include <asm/pgtable.h>
> >  #include <asm/tlbflush.h>  
> 
> This needs to be _the_ last thing that gets #included.  Otherwise, you
> risk colliding with any other trace header that gets implicitly included
> below.

Agreed.

> 
> > @@ -1340,6 +1346,8 @@ int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
> >  					start, len)))
> >  		return 0;
> >  
> > +	trace_gup_get_user_pages_fast(start, nr_pages, write, pages);
> > +
> >  	/*
> >  	 * Disable interrupts.  We use the nested form as we can already have
> >  	 * interrupts disabled by get_futex_key.  
> 
> It would be _really_ nice to be able to see return values from the
> various gup calls as well.  Is that feasible?

Only if you rewrite the functions to have a single return code path
that we can add a tracepoint too. Or have a wrapper function that gets
called directly that calls these functions internally and the tracepoint
can trap the return value.

I can probably make function_graph tracer give return values, although
it will give a return value for void functions as well. And it may give
long long returns for int returns that may have bogus data in the
higher bits.

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
