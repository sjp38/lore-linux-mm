Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id B60076B0073
	for <linux-mm@kvack.org>; Wed, 17 Apr 2013 03:26:10 -0400 (EDT)
In-Reply-To: <516D9A74.8030109@linux.intel.com>
Subject: =?GB2312?B?tPC4tDogUmU6IFtQQVRDSF0gZnV0ZXg6IGJ1Z2ZpeCBmb3IgZnV0ZXgta2V5?=
 =?GB2312?B?IGNvbmZsaWN0IHdoZW4gZnV0ZXggdXNlIGh1Z2VwYWdl?=
MIME-Version: 1.0
Message-ID: <OF70EE3A18.189A18D4-ON48257B50.002812BC-48257B50.0028D956@zte.com.cn>
From: zhang.yi20@zte.com.cn
Date: Wed, 17 Apr 2013 15:25:35 +0800
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
