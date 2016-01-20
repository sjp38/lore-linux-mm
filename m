Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 1A3ED6B0005
	for <linux-mm@kvack.org>; Wed, 20 Jan 2016 12:57:02 -0500 (EST)
Received: by mail-wm0-f46.google.com with SMTP id 123so143187495wmz.0
        for <linux-mm@kvack.org>; Wed, 20 Jan 2016 09:57:02 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v9si55014195wjw.76.2016.01.20.09.57.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 20 Jan 2016 09:57:00 -0800 (PST)
Subject: Re: [PATCH] mm, gup: introduce concept of "foreign" get_user_pages()
References: <20160120173504.59300BEC@viggo.jf.intel.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <569FCA5A.8040906@suse.cz>
Date: Wed, 20 Jan 2016 18:56:42 +0100
MIME-Version: 1.0
In-Reply-To: <20160120173504.59300BEC@viggo.jf.intel.com>
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, x86@kernel.org, dave.hansen@linux.intel.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, aarcange@redhat.com, n-horiguchi@ah.jp.nec.com, jack@suse.cz

On 01/20/2016 06:35 PM, Dave Hansen wrote:
> Here's another revision taking Vlastimil's suggestions about
> keeping __get_user_pages_unlocked() as-is in to account.
> This does, indeed, look nicer.  Now, all the "__" variants
> take a full tsk/mm and flags.
> 
> He also noted that the two sites where we called gup with
> tsk=NULL were probably incorrectly changing behavior with respect
> to fault accounting.  Long-term, I wonder if we should just add
> a "FOLL_" flag to make that more explicit, but for now, I've
> fixed up those sites.
> 
> ---
> 
> From: Dave Hansen <dave.hansen@linux.intel.com>
> 
> For protection keys, we need to understand whether protections
> should be enforced in software or not.  In general, we enforce
> protections when working on our own task, but not when on others.
> We call these "current" and "foreign" operations.
> 
> This patch introduces a new get_user_pages() variant:
> 
> 	get_user_pages_foreign()
> 
> The plain get_user_pages() can no longer be used on mm/tasks
> other than 'current/current->mm', which is by far the most common
> way it is called.  Using it makes a few of the call sites look a
> bit nicer.
> 
> In other words, get_user_pages_foreign() is a replacement for
> when get_user_pages() is called on non-current tsk/mm.
> 
> This also switches get_user_pages_(un)locked() over to be like
> get_user_pages() and not take a tsk/mm.  There is no
> get_user_pages_foreign_(un)locked().  If someone wants that
> behavior they just have to use "__" variant and pass in
> FOLL_FOREIGN explicitly.

Hm so this gets a bit ahead of patch "mm: add gup flag to indicate "foreign" mm
access", right? It might be cleaner to postpone passing FOLL_FOREIGN until then,
but not critical.

BTW doesn't that other patch miss passing FOLL_FOREIGN from
get_user_pages_foreign() or something? I see it only uses it from break_ksm(),
am I missing something?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
