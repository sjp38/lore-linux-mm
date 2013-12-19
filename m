Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f47.google.com (mail-pb0-f47.google.com [209.85.160.47])
	by kanga.kvack.org (Postfix) with ESMTP id 25F846B0031
	for <linux-mm@kvack.org>; Wed, 18 Dec 2013 19:50:53 -0500 (EST)
Received: by mail-pb0-f47.google.com with SMTP id um1so404416pbc.20
        for <linux-mm@kvack.org>; Wed, 18 Dec 2013 16:50:52 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id xa2si1227565pab.287.2013.12.18.16.50.50
        for <linux-mm@kvack.org>;
        Wed, 18 Dec 2013 16:50:51 -0800 (PST)
Date: Wed, 18 Dec 2013 16:50:49 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/rmap: fix BUG at rmap_walk
Message-Id: <20131218165049.32462271f314185aed81de39@linux-foundation.org>
In-Reply-To: <52B240C8.5070805@oracle.com>
References: <1387412195-26498-1-git-send-email-liwanp@linux.vnet.ibm.com>
	<20131218162858.6ec808c067baf4644532e110@linux-foundation.org>
	<52B240C8.5070805@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Wanpeng Li <liwanp@linux.vnet.ibm.com>, Hugh Dickins <hughd@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dave Jones <davej@redhat.com>

On Wed, 18 Dec 2013 19:41:44 -0500 Sasha Levin <sasha.levin@oracle.com> wrote:

> On 12/18/2013 07:28 PM, Andrew Morton wrote:
> > On Thu, 19 Dec 2013 08:16:35 +0800 Wanpeng Li <liwanp@linux.vnet.ibm.com> wrote:
> >
> >> page_get_anon_vma() called in page_referenced_anon() will lock and
> >> increase the refcount of anon_vma, page won't be locked for anonymous
> >> page. This patch fix it by skip check anonymous page locked.
> >>
> >> [  588.698828] kernel BUG at mm/rmap.c:1663!
> >
> > Why is all this suddenly happening.  Did we change something, or did a
> > new test get added to trinity?
> 
> Dave has improved mmap testing in trinity, maybe it's related?

Dave, can you please summarise recent trinity changes for us?

> > Or if there is no reason why the page must be locked for
> > rmap_walk_ksm() and rmap_walk_file(), let's just remove rmap_walk()'s
> > VM_BUG_ON()?  And rmap_walk_ksm()'s as well - it's duplicative anyway.
> 
> IMO, removing all these VM_BUG_ON()s (which is happening quite often recently) will
> lead to having bugs sneak by causing obscure undetected corruption instead of
> being very obvious through a BUG.
> 

Well.  a) My patch was functionally the same as the one Wanpeng
proposed, only better ;) and b) we shouldn't just assert X because we
observed that the existing code does X.  If a particular function
*needs* PageLocked(page) then sure, it can and should assert that the
page is locked.  Preferably with a comment explaining *why*
PageLocked() is needed.  That way we don't end up with years-old
assertions which nobody understands any more, which is what we have
now.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
