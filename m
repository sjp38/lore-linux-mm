Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f50.google.com (mail-pb0-f50.google.com [209.85.160.50])
	by kanga.kvack.org (Postfix) with ESMTP id 023666B003B
	for <linux-mm@kvack.org>; Wed, 18 Dec 2013 20:14:40 -0500 (EST)
Received: by mail-pb0-f50.google.com with SMTP id rr13so431695pbb.9
        for <linux-mm@kvack.org>; Wed, 18 Dec 2013 17:14:40 -0800 (PST)
Received: from LGEAMRELO02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id 5si1266085pbj.305.2013.12.18.17.14.38
        for <linux-mm@kvack.org>;
        Wed, 18 Dec 2013 17:14:39 -0800 (PST)
Date: Thu, 19 Dec 2013 10:14:40 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH] mm/rmap: fix BUG at rmap_walk
Message-ID: <20131219011440.GB25161@lge.com>
References: <1387412195-26498-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <20131218162858.6ec808c067baf4644532e110@linux-foundation.org>
 <20131219005805.GA25161@lge.com>
 <20131218170429.0858bb069d51a469e8c237d8@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131218170429.0858bb069d51a469e8c237d8@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Wanpeng Li <liwanp@linux.vnet.ibm.com>, Sasha Levin <sasha.levin@oracle.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Dec 18, 2013 at 05:04:29PM -0800, Andrew Morton wrote:
> On Thu, 19 Dec 2013 09:58:05 +0900 Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
> 
> > On Wed, Dec 18, 2013 at 04:28:58PM -0800, Andrew Morton wrote:
> > > On Thu, 19 Dec 2013 08:16:35 +0800 Wanpeng Li <liwanp@linux.vnet.ibm.com> wrote:
> > > 
> > > > page_get_anon_vma() called in page_referenced_anon() will lock and 
> > > > increase the refcount of anon_vma, page won't be locked for anonymous 
> > > > page. This patch fix it by skip check anonymous page locked.
> > > > 
> > > > [  588.698828] kernel BUG at mm/rmap.c:1663!
> > > 
> > > Why is all this suddenly happening.  Did we change something, or did a
> > > new test get added to trinity?
> > 
> > It is my fault.
> > I should remove this VM_BUG_ON() since rmap_walk() can be called
> > without holding PageLock() in this case.
> > 
> > I think that adding VM_BUG_ON() to each rmap_walk calllers is better
> > than this patch, because, now, rmap_walk() is called by many places and
> > each places has different contexts.
> 
> I don't think that putting the assertion into the caller makes a lot of
> sense, particularly if that code just did a lock_page()!  If a *callee*
> needs PageLocked() then that callee should assert that the page is
> locked.  So
> 
> 	VM_BUG_ON(!PageLocked(page));
> 
> means "this code requires that the page be locked".  And if that code
> requires PageLocked(), there must be reasons for this.  Let's also
> include an explanation of those reasons.

Yes, if this condition is invariant for rmap_walk(), we should put this on
rmap_walk(). But if not, we should put this on the other place. I will
investigate more and send good solution :)

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
