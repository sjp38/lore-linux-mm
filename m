Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9DA306B05F3
	for <linux-mm@kvack.org>; Mon, 31 Jul 2017 08:38:45 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id x77so75690193qka.15
        for <linux-mm@kvack.org>; Mon, 31 Jul 2017 05:38:45 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 7si22242599qth.75.2017.07.31.05.38.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 31 Jul 2017 05:38:45 -0700 (PDT)
Date: Mon, 31 Jul 2017 08:38:41 -0400 (EDT)
From: Bob Peterson <rpeterso@redhat.com>
Message-ID: <1822812523.36420383.1501504721611.JavaMail.zimbra@redhat.com>
In-Reply-To: <1501503761.4663.11.camel@redhat.com>
References: <20170726175538.13885-1-jlayton@kernel.org> <20170727084914.GC21100@quack2.suse.cz> <1501159710.6279.1.camel@redhat.com> <1501500421.4663.4.camel@redhat.com> <8d46c4c6-76b5-9726-7d85-249cd9a899f1@redhat.com> <1501501456.4663.6.camel@redhat.com> <d2d77f03-53f0-12f5-4f14-bed0e848562c@redhat.com> <1501503761.4663.11.camel@redhat.com>
Subject: Re: [PATCH v2 2/4] mm: add file_fdatawait_range and
 file_write_and_wait
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: Steven Whitehouse <swhiteho@redhat.com>, Jan Kara <jack@suse.cz>, Marcelo Tosatti <mtosatti@redhat.com>, Alexander Viro <viro@zeniv.linux.org.uk>, "J . Bruce Fields" <bfields@fieldses.org>, Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Matthew Wilcox <willy@infradead.org>, cluster-devel@redhat.com, Benjamin Marzinski <bmarzins@redhat.com>

----- Original Message -----
| > If this can be called from anywhere without fs locks, then i_size is not
| > known. That has been a problem in the past since i_size may have changed
| > on another node. We avoid that in this case due to only changing i_size
| > under an exclusive lock, and also only having dirty pages when we have
| > an exclusive lock. There is another case though, if the inode is a block
| > device, i_size will be zero. That is the case for the address space that
| > looks after rgrps for GFS2. We do (luckily!) call
| > filemap_fdatawait_range() directly in that case. For "normal" inodes
| > though, the address space for metadata is backed by the block device
| > inode, so that looks like it might be an issue, since
| > fs/gfs2/glops.c:inode_go_sync() calls filemap_fdatawait() on the
| > metamapping. It might potentially be an issue in other cases too,
| > 
| > Steve.
| > 
| 
| Some of those do sound problematic.
| 
| Again though, we're only waiting on writeback here, and I assume with
| gfs2 that would only be pages that were written on the local node.
| 
| Is it possible to have pages under writeback and in still in the tree,
| but that are beyond the current i_size? It seems like that's the main
| worrisome case.
| 
| --
| Jeff Layton <jlayton@redhat.com>

Hi Jeff,

I believe the answer is yes.

I was recently "bitten" by a case where (whether due to a bug or not)
I had blocks allocated in a GFS2 file beyond i_size. I had implemented a
delete algorithm that used i_size, but I found cases where files couldn't
be deleted because of blocks hanging out past EOF. I'm not sure if they
can be in writeback, but possibly. It's already on my "to investigate"
list, but I haven't gotten to it yet. Yes, it seems like a bug. Yes, we
need to fix it. But now there may be lots of legacy file systems out in
the field that have this problem. Not sure if they can get to writeback
until I study the situation more closely.

I believe Ben Marzinski also may have come across a case in which we
can have blocks in writeback that are beyond i_size. See the commit
message on Ben's patch here:

https://git.kernel.org/pub/scm/linux/kernel/git/gfs2/linux-gfs2.git/commit/fs/gfs2?h=for-next&id=fd4c5748b8d3f7420e8932ed0bde3d53cc8acc9d

Regards,

Bob Peterson
Red Hat File Systems

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
