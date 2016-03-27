Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 5906B6B007E
	for <linux-mm@kvack.org>; Sun, 27 Mar 2016 15:46:53 -0400 (EDT)
Received: by mail-wm0-f43.google.com with SMTP id l68so78759770wml.0
        for <linux-mm@kvack.org>; Sun, 27 Mar 2016 12:46:53 -0700 (PDT)
Received: from mail-wm0-x229.google.com (mail-wm0-x229.google.com. [2a00:1450:400c:c09::229])
        by mx.google.com with ESMTPS id hd9si25067147wjc.110.2016.03.27.12.46.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 27 Mar 2016 12:46:51 -0700 (PDT)
Received: by mail-wm0-x229.google.com with SMTP id l68so62458140wml.0
        for <linux-mm@kvack.org>; Sun, 27 Mar 2016 12:46:51 -0700 (PDT)
Date: Sun, 27 Mar 2016 22:46:49 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: Bloat caused by unnecessary calls to compound_head()?
Message-ID: <20160327194649.GA9638@node.shutemov.name>
References: <20160326185049.GA4257@zzz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160326185049.GA4257@zzz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Biggers <ebiggers3@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kirill.shutemov@linux.intel.com, Hugh Dickins <hughd@google.com>

On Sat, Mar 26, 2016 at 01:50:49PM -0500, Eric Biggers wrote:
> Hi,
> 
> I noticed that after the recent "page-flags" patchset, there are an excessive
> number of calls to compound_head() in certain places.
> 
> For example, the frequently executed mark_page_accessed() function already
> starts out by calling compound_head(), but then each time it tests a page flag
> afterwards, there is an extra, seemingly unnecessary, call to compound_head().
> This causes a series of instructions like the following to appear no fewer than
> 10 times throughout the function:
> 
> ffffffff81119db4:       48 8b 53 20             mov    0x20(%rbx),%rdx
> ffffffff81119db8:       48 8d 42 ff             lea    -0x1(%rdx),%rax
> ffffffff81119dbc:       83 e2 01                and    $0x1,%edx
> ffffffff81119dbf:       48 0f 44 c3             cmove  %rbx,%rax
> ffffffff81119dc3:       48 8b 00                mov    (%rax),%rax
> 
> Part of the problem, I suppose, is that the compiler doesn't know that the pages
> can't be linked more than one level deep.
> 
> Is this a known tradeoff, and have any possible solutions been considered?

<I'm sick, so my judgment may be off>

Yes, it's known problem. And I've tried to approach it few times without
satisfying results.

Your mail made me try again.

The idea is to introduce new type to indicate head page --
'struct head_page' -- it's compatible with struct page on memory layout,
but distinct from C point of view. compound_head() should return pointer
of that type. For the proof-of-concept I've introduced new helper --
compound_head_t().

Then we can make page-flag helpers to accept both types, by converting
them to macros and use __builtin_types_compatible_p().

When a page-flag helper sees pointer to 'struct head_page' as an argument,
it can safely assume that it deals with head or non-compound page and therefore
can bypass all policy restrictions and get rid of compound_head() calls.

I'll send proof-of-concept patches in reply to this message. The code is
not pretty. I myself consider the idea rather ugly.

Any comments are welcome.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
