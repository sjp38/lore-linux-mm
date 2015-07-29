Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id EB7AB6B0255
	for <linux-mm@kvack.org>; Wed, 29 Jul 2015 06:50:08 -0400 (EDT)
Received: by wicgb10 with SMTP id gb10so194565322wic.1
        for <linux-mm@kvack.org>; Wed, 29 Jul 2015 03:50:08 -0700 (PDT)
Received: from outbound-smtp04.blacknight.com (outbound-smtp04.blacknight.com. [81.17.249.35])
        by mx.google.com with ESMTPS id pu2si43060241wjc.109.2015.07.29.03.50.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 29 Jul 2015 03:50:07 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp04.blacknight.com (Postfix) with ESMTPS id DAF8E99281
	for <linux-mm@kvack.org>; Wed, 29 Jul 2015 10:50:05 +0000 (UTC)
Date: Wed, 29 Jul 2015 11:50:03 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 1/4] fs/anon_inodes: new interface to create new inode
Message-ID: <20150729105003.GB30872@techsingularity.net>
References: <1436776519-17337-1-git-send-email-gioh.kim@lge.com>
 <1436776519-17337-2-git-send-email-gioh.kim@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1436776519-17337-2-git-send-email-gioh.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gioh Kim <gioh.kim@lge.com>
Cc: jlayton@poochiereds.net, bfields@fieldses.org, vbabka@suse.cz, iamjoonsoo.kim@lge.com, viro@zeniv.linux.org.uk, mst@redhat.com, koct9i@gmail.com, minchan@kernel.org, aquini@redhat.com, linux-fsdevel@vger.kernel.org, virtualization@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, linux-mm@kvack.org, dri-devel@lists.freedesktop.org, akpm@linux-foundation.org, Gioh Kim <gurugio@hanmail.net>

On Mon, Jul 13, 2015 at 05:35:16PM +0900, Gioh Kim wrote:
> From: Gioh Kim <gurugio@hanmail.net>
> 
> The anon_inodes has already complete interfaces to create manage
> many anonymous inodes but don't have interface to get
> new inode. Other sub-modules can create anonymous inode
> without creating and mounting it's own pseudo filesystem.
> 
> Signed-off-by: Gioh Kim <gioh.kim@lge.com>
> Acked-by: Rafael Aquini <aquini@redhat.com>

This is my first run through the series so I'm going to miss details but
this patch confuses me a little. You create an inode to associate with
the balloon dev_info so that page->mapping can be assigned. It's only the
mapping you care about for the aops so why are multiple inodes required? A
driver should be able to share and reference count a single inode. The
motivation to do it that way would be to reduce memory consumption and
this series is motivated by embedded platforms.

anon_inode_getfd has the following

 * Creates a new file by hooking it on a single inode. This is useful for files
 * that do not need to have a full-fledged inode in order to operate correctly.
 * All the files created with anon_inode_getfd() will share a single inode,
 * hence saving memory and avoiding code duplication for the file/inode/dentry
 * setup.  Returns new descriptor or an error code.

If all we care about the inode is the aops then it would follow that
anon_inode_getfd() is ideal. The tradeoff is reference counting overhead.
The changelog needs to explain why anon_inode_getfd() cannot be used.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
