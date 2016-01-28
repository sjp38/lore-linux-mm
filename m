Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 2FF3B6B0254
	for <linux-mm@kvack.org>; Thu, 28 Jan 2016 16:33:18 -0500 (EST)
Received: by mail-wm0-f48.google.com with SMTP id l66so43155584wml.0
        for <linux-mm@kvack.org>; Thu, 28 Jan 2016 13:33:18 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id bj10si17801503wjc.110.2016.01.28.13.33.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Jan 2016 13:33:17 -0800 (PST)
Date: Thu, 28 Jan 2016 16:33:02 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm: do not let vdso pages into LRU rotation
Message-ID: <20160128213302.GB4163@cmpxchg.org>
References: <20160127193958.GA31407@cmpxchg.org>
 <CALCETrVy_QzNyaCiOsdwDdgXAgdRmwXsdiyPz8R5h3xaNR00TQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrVy_QzNyaCiOsdwDdgXAgdRmwXsdiyPz8R5h3xaNR00TQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Andy Lutomirski <luto@kernel.org>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Wed, Jan 27, 2016 at 12:32:16PM -0800, Andy Lutomirski wrote:
> On Wed, Jan 27, 2016 at 11:39 AM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> > Could the VDSO be a VM_MIXEDMAP to keep the initial unmanaged pages
> > out of the VM while allowing COW into regular anonymous pages?
> 
> Probably.  What are its limitations?  We want ptrace to work on it,
> and mprotect needs to work and allow COW.  access_process_vm should
> probably work, too.

Thanks, that's good to know.

However, after looking at this a little longer, it appears this would
need work in do_wp_page() to support non-page COW copying, then adding
vm_ops->access and complicating ->fault in all VDSO implementations.

And it looks like - at least theoretically - drivers can inject non-VM
pages into the page tables as well (comment above insert_page())

Given that this behavior has been around for a long time (the comment
at the bottom of vm_normal_page is ancient), I'll probably go with a
more conservative approach; add a comment to mark_page_accessed() and
filter out non-VM pages in the function I'm going to call from it.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
