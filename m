Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id AC6BD6B0080
	for <linux-mm@kvack.org>; Wed, 17 Apr 2013 03:48:05 -0400 (EDT)
In-Reply-To: <516D9A74.8030109@linux.intel.com>
Subject: Re: Re: [PATCH] futex: bugfix for futex-key conflict when futex use
 hugepage
MIME-Version: 1.0
Message-ID: <OF137D0ABE.5A739596-ON48257B50.002AB95E-48257B50.002AD807@zte.com.cn>
From: zhang.yi20@zte.com.cn
Date: Wed, 17 Apr 2013 15:47:23 +0800
Content-Type: text/plain; charset="US-ASCII"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Darren Hart <dvhart@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>

Dave Hansen <dave.hansen@linux.intel.com> wrote on 2013/04/17 02:37:40:

> Instead of bothering to store the index, why not just calculate it, 
like:
> 
> On 04/15/2013 08:37 PM, zhang.yi20@zte.com.cn wrote:
> > +static inline int get_page_compound_index(struct page *page)
> > +{
> > +       if (PageHead(page))
> > +               return 0;
> > +       return compound_head(page) - page;
> > +}
> 
> BTW, you've really got to get your mail client fixed.  Your patch is
> still line-wrapped.


I agree that I should calculate the compound index, but refer to 
prep_compound_gigantic_page, I think it may like this:

+static inline int get_page_compound_index(struct page *page)
+{
+       struct page *head_page;
+       if (PageHead(page))
+               return 0;
+
+       head_page = compound_head(page);
+       if (compound_order(head_page) >= MAX_ORDER)
+               return page_to_pfn(page) - page_to_pfn(head_page);
+       else
+               return page - compound_head(page);
+}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
