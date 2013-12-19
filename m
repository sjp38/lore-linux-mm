Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f179.google.com (mail-ig0-f179.google.com [209.85.213.179])
	by kanga.kvack.org (Postfix) with ESMTP id 6A3F96B0031
	for <linux-mm@kvack.org>; Wed, 18 Dec 2013 20:30:48 -0500 (EST)
Received: by mail-ig0-f179.google.com with SMTP id hk11so2686316igb.0
        for <linux-mm@kvack.org>; Wed, 18 Dec 2013 17:30:48 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id mg9si2036132icc.63.2013.12.18.17.30.46
        for <linux-mm@kvack.org>;
        Wed, 18 Dec 2013 17:30:47 -0800 (PST)
Date: Wed, 18 Dec 2013 20:30:32 -0500
From: Dave Jones <davej@redhat.com>
Subject: Re: [PATCH] mm/rmap: fix BUG at rmap_walk
Message-ID: <20131219013032.GA1156@redhat.com>
References: <1387412195-26498-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <20131218162858.6ec808c067baf4644532e110@linux-foundation.org>
 <52B240C8.5070805@oracle.com>
 <20131218165049.32462271f314185aed81de39@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131218165049.32462271f314185aed81de39@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Sasha Levin <sasha.levin@oracle.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Hugh Dickins <hughd@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Dec 18, 2013 at 04:50:49PM -0800, Andrew Morton wrote:
 > On Wed, 18 Dec 2013 19:41:44 -0500 Sasha Levin <sasha.levin@oracle.com> wrote:
 > 
 > > On 12/18/2013 07:28 PM, Andrew Morton wrote:
 > > > On Thu, 19 Dec 2013 08:16:35 +0800 Wanpeng Li <liwanp@linux.vnet.ibm.com> wrote:
 > > >
 > > >> page_get_anon_vma() called in page_referenced_anon() will lock and
 > > >> increase the refcount of anon_vma, page won't be locked for anonymous
 > > >> page. This patch fix it by skip check anonymous page locked.
 > > >>
 > > >> [  588.698828] kernel BUG at mm/rmap.c:1663!
 > > >
 > > > Why is all this suddenly happening.  Did we change something, or did a
 > > > new test get added to trinity?
 > > 
 > > Dave has improved mmap testing in trinity, maybe it's related?
 > 
 > Dave, can you please summarise recent trinity changes for us?

In the past, the only mmaps we did were created on startup by the initial process,
and were then inherited by the child processes when they fork()'d.

After the recent changes, that's still true, but in addition, we now have
some smarts so that when a child does a random mmap() call, if it succeeds,
we store the result in a per-child list for re-use in subsequent syscalls by
that same child process.

Another reason that a lot of hugepage stuff seems to be falling out is that
trinity didn't do big mmaps before, because after a few children forked
and the maps got touched, we'd run into oom's pretty quickly.
Now that we have per-child mmapping, sometimes it successfully does a hugepage map.

http://git.codemonkey.org.uk/?p=trinity.git;a=blob_plain;f=syscalls/mmap.c;hb=HEAD
is the code that's generating the random map arguments. It should be pretty obvious,
but holler if there's something that needs explaining.

dirty_mapping() is here http://git.codemonkey.org.uk/?p=trinity.git;a=blob_plain;f=maps.c;hb=HEAD

	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
