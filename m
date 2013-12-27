Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 121FD6B0035
	for <linux-mm@kvack.org>; Fri, 27 Dec 2013 17:26:07 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id hz1so9663054pad.40
        for <linux-mm@kvack.org>; Fri, 27 Dec 2013 14:26:07 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id bc2si25532656pad.158.2013.12.27.14.26.06
        for <linux-mm@kvack.org>;
        Fri, 27 Dec 2013 14:26:06 -0800 (PST)
Date: Fri, 27 Dec 2013 14:26:05 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: dump page when hitting a VM_BUG_ON using
 VM_BUG_ON_PAGE
Message-Id: <20131227142605.5830bf0e4b9bb007c2916dfc@linux-foundation.org>
In-Reply-To: <52BDFD00.7020909@oracle.com>
References: <1388114452-30769-1-git-send-email-sasha.levin@oracle.com>
	<20131227103847.GA19453@node.dhcp.inet.fi>
	<52BDFD00.7020909@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 27 Dec 2013 17:19:44 -0500 Sasha Levin <sasha.levin@oracle.com> wrote:

> On 12/27/2013 05:38 AM, Kirill A. Shutemov wrote:
> > On Thu, Dec 26, 2013 at 10:20:52PM -0500, Sasha Levin wrote:
> >> Most of the VM_BUG_ON assertions are performed on a page. Usually, when
> >> one of these assertions fails we'll get a BUG_ON with a call stack and
> >> the registers.
> >>
> >> I've recently noticed based on the requests to add a small piece of code
> >> that dumps the page to various VM_BUG_ON sites that the page dump is quite
> >> useful to people debugging issues in mm.
> >>
> >> This patch adds a VM_BUG_ON_PAGE(cond, page) which beyond doing what
> >> VM_BUG_ON() does, also dumps the page before executing the actual BUG_ON.
> >>
> >> Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
> >
> > I like the idea. One thing I've noticed you have a lot of page flag based
> > asserts, like:
> >
> > 	VM_BUG_ON_PAGE(PageLRU(page), page);
> > 	VM_BUG_ON_PAGE(!PageLocked(page), page);
> >
> > What about adding per-page-flag assert macros, like:
> >
> > 	PageNotLRU_assert(page);
> > 	PageLocked_assert(page);
> >
> > ? This way we will always dump right page on bug.
> >
> 
> Sure, sounds good.
> 
> I'll send another patch on top of this one.

I think I prefer the patch as-is.  To do what Kirill suggests we'd have
to add a heck of a lot more macros and they add little value.  And the
suggested names of those macros aren't very good - there's nothing in
"PageNotLRU_assert" which tells the reader that this code is
conditional on CONFIG_DEBUG_VM, which is a somewhat important thing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
