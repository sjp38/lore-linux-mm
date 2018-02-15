Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 021B46B0003
	for <linux-mm@kvack.org>; Thu, 15 Feb 2018 12:36:44 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id h8so215959pgr.12
        for <linux-mm@kvack.org>; Thu, 15 Feb 2018 09:36:43 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id bg11-v6si1397123plb.272.2018.02.15.09.36.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 15 Feb 2018 09:36:42 -0800 (PST)
Date: Thu, 15 Feb 2018 09:36:39 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v2 2/8] mm: Add kvmalloc_ab_c and kvzalloc_struct
Message-ID: <20180215173639.GA10146@bombadil.infradead.org>
References: <20180214201154.10186-1-willy@infradead.org>
 <20180214201154.10186-3-willy@infradead.org>
 <1518641152.3678.28.camel@perches.com>
 <20180214211203.GF20627@bombadil.infradead.org>
 <20180214155833.9f1563b87391f7ff79ca7ed0@linux-foundation.org>
 <20180215034050.GA5775@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180215034050.GA5775@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Joe Perches <joe@perches.com>, Matthew Wilcox <mawilcox@microsoft.com>, linux-mm@kvack.org, Kees Cook <keescook@chromium.org>, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com

On Wed, Feb 14, 2018 at 07:40:50PM -0800, Matthew Wilcox wrote:
> > 	a_foo = kvzalloc_struct_buf(struct foo, struct bar, nr_bars);
> > 
> > or, of course.
> > 
> > 	a_foo = kvzalloc_struct_buf(typeof(*a_foo), typeof(a_foo->bar[0]),
> > 				    nr_bars);
> > 
> > or whatever.

This version works, although it's more typing in the callers:

-               attr_group = kvzalloc_struct(attr_group, attrs, i + 1,
+               attr_group = kvzalloc_struct(typeof(*attr_group), attrs, i + 1,
                                                                GFP_KERNEL);
...
-       dev_dax = kvzalloc_struct(dev_dax, res, count, GFP_KERNEL);
+       dev_dax = kvzalloc_struct(struct dev_dax, res, count, GFP_KERNEL);
...
-#define kvzalloc_struct(p, member, n, gfp)                             \
-       (typeof(p))kvzalloc_ab_c(n,                                     \
-               sizeof(*(p)->member) + __must_be_array((p)->member),    \
-               offsetof(typeof(*(p)), member), gfp)
+#define kvzalloc_struct(s, member, n, gfp) ({                          \
+       s *__p;                                                         \
+       (s *)kvzalloc_ab_c(n,                                           \
+               sizeof(*(__p)->member) + __must_be_array((__p)->member),\
+               offsetof(s, member), gfp);                              \
+})

Gives all the same checking as the current version, and doesn't involve
passing an uninitialised pointer to the macro.

It also looks pretty similar:

	p = kvzalloc(sizeof(*p), GFP_KERNEL);
	p = kvzalloc_struct(typeof(*p), array, count, GFP_KERNEL);
	p = kvzalloc_array(sizeof(*p), count);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
