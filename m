Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id C5E6F6B0292
	for <linux-mm@kvack.org>; Thu, 10 Aug 2017 01:57:41 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id z48so11566191wrc.4
        for <linux-mm@kvack.org>; Wed, 09 Aug 2017 22:57:41 -0700 (PDT)
Received: from mail-wm0-x22a.google.com (mail-wm0-x22a.google.com. [2a00:1450:400c:c09::22a])
        by mx.google.com with ESMTPS id j6si4977412edd.217.2017.08.09.22.57.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Aug 2017 22:57:40 -0700 (PDT)
Received: by mail-wm0-x22a.google.com with SMTP id f15so13113220wmg.1
        for <linux-mm@kvack.org>; Wed, 09 Aug 2017 22:57:40 -0700 (PDT)
Date: Thu, 10 Aug 2017 08:57:37 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: How can we share page cache pages for reflinked files?
Message-ID: <20170810055737.v6yexikxa5zxvntv@node.shutemov.name>
References: <20170810042849.GK21024@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170810042849.GK21024@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Thu, Aug 10, 2017 at 02:28:49PM +1000, Dave Chinner wrote:
> Hi folks,
> 
> I've recently been looking into what is involved in sharing page
> cache pages for shared extents in a filesystem. That is, create a
> file, reflink it so there's two files but only one copy of the data
> on disk, then read both files.  Right now, we get two copies of the
> data in the page cache - one in each inode mapping tree.
> 
> If we scale this up to a container host which is using reflink trees
> it's shared root images, there might be hundreds of copies of the
> same data held in cache (i.e. one page per container). Given that
> the filesystem knows that the underlying data extent is shared when
> we go to read it, it's relatively easy to add mechanisms to the
> filesystem to return the same page for all attempts to read the
> from a shared extent from all inodes that share it.
> 
> However, the problem I'm getting stuck on is that the page cache
> itself can't handle inserting a single page into multiple page cache
> mapping trees. i.e. The page has a single pointer to the mapping
> address space, and the mapping has a single pointer back to the
> owner inode. As such, a cached page has a 1:1 mapping to it's host
> inode and this structure seems to be assumed rather widely through
> the code.

I think to solve the problem with page->mapping we need something similar
to what we have for anon rmap[1]. In this case we would be able to keep
the same page in page cache for multiple inodes.

The long term benefit for this is that we might be able to unify a lot of
code for anon and file code paths in mm, making anon memory a special case
of file mapping.

The downside is that anon rmap is rather complicated. I have to re-read
the article everytime I deal with anon rmap to remind myself how it works.

[1] https://lwn.net/Articles/383162/

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
