Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f52.google.com (mail-ee0-f52.google.com [74.125.83.52])
	by kanga.kvack.org (Postfix) with ESMTP id A278A6B0031
	for <linux-mm@kvack.org>; Fri, 27 Dec 2013 06:11:04 -0500 (EST)
Received: by mail-ee0-f52.google.com with SMTP id d17so4054584eek.39
        for <linux-mm@kvack.org>; Fri, 27 Dec 2013 03:11:04 -0800 (PST)
Received: from jenni2.inet.fi (mta-out.inet.fi. [195.156.147.13])
        by mx.google.com with ESMTP id s8si37676702eeh.143.2013.12.27.03.11.02
        for <linux-mm@kvack.org>;
        Fri, 27 Dec 2013 03:11:02 -0800 (PST)
Date: Fri, 27 Dec 2013 12:38:47 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm: dump page when hitting a VM_BUG_ON using
 VM_BUG_ON_PAGE
Message-ID: <20131227103847.GA19453@node.dhcp.inet.fi>
References: <1388114452-30769-1-git-send-email-sasha.levin@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1388114452-30769-1-git-send-email-sasha.levin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Dec 26, 2013 at 10:20:52PM -0500, Sasha Levin wrote:
> Most of the VM_BUG_ON assertions are performed on a page. Usually, when
> one of these assertions fails we'll get a BUG_ON with a call stack and
> the registers.
> 
> I've recently noticed based on the requests to add a small piece of code
> that dumps the page to various VM_BUG_ON sites that the page dump is quite
> useful to people debugging issues in mm.
> 
> This patch adds a VM_BUG_ON_PAGE(cond, page) which beyond doing what
> VM_BUG_ON() does, also dumps the page before executing the actual BUG_ON.
> 
> Signed-off-by: Sasha Levin <sasha.levin@oracle.com>

I like the idea. One thing I've noticed you have a lot of page flag based
asserts, like:

	VM_BUG_ON_PAGE(PageLRU(page), page);
	VM_BUG_ON_PAGE(!PageLocked(page), page);

What about adding per-page-flag assert macros, like:

	PageNotLRU_assert(page);
	PageLocked_assert(page);

? This way we will always dump right page on bug.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
