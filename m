Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 456976B0037
	for <linux-mm@kvack.org>; Wed, 18 Dec 2013 20:04:32 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id kq14so419299pab.6
        for <linux-mm@kvack.org>; Wed, 18 Dec 2013 17:04:31 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id xa2si1262430pab.200.2013.12.18.17.04.30
        for <linux-mm@kvack.org>;
        Wed, 18 Dec 2013 17:04:30 -0800 (PST)
Date: Wed, 18 Dec 2013 17:04:29 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/rmap: fix BUG at rmap_walk
Message-Id: <20131218170429.0858bb069d51a469e8c237d8@linux-foundation.org>
In-Reply-To: <20131219005805.GA25161@lge.com>
References: <1387412195-26498-1-git-send-email-liwanp@linux.vnet.ibm.com>
	<20131218162858.6ec808c067baf4644532e110@linux-foundation.org>
	<20131219005805.GA25161@lge.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Wanpeng Li <liwanp@linux.vnet.ibm.com>, Sasha Levin <sasha.levin@oracle.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 19 Dec 2013 09:58:05 +0900 Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:

> On Wed, Dec 18, 2013 at 04:28:58PM -0800, Andrew Morton wrote:
> > On Thu, 19 Dec 2013 08:16:35 +0800 Wanpeng Li <liwanp@linux.vnet.ibm.com> wrote:
> > 
> > > page_get_anon_vma() called in page_referenced_anon() will lock and 
> > > increase the refcount of anon_vma, page won't be locked for anonymous 
> > > page. This patch fix it by skip check anonymous page locked.
> > > 
> > > [  588.698828] kernel BUG at mm/rmap.c:1663!
> > 
> > Why is all this suddenly happening.  Did we change something, or did a
> > new test get added to trinity?
> 
> It is my fault.
> I should remove this VM_BUG_ON() since rmap_walk() can be called
> without holding PageLock() in this case.
> 
> I think that adding VM_BUG_ON() to each rmap_walk calllers is better
> than this patch, because, now, rmap_walk() is called by many places and
> each places has different contexts.

I don't think that putting the assertion into the caller makes a lot of
sense, particularly if that code just did a lock_page()!  If a *callee*
needs PageLocked() then that callee should assert that the page is
locked.  So

	VM_BUG_ON(!PageLocked(page));

means "this code requires that the page be locked".  And if that code
requires PageLocked(), there must be reasons for this.  Let's also
include an explanation of those reasons.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
