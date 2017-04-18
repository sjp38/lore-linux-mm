Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 990526B03A2
	for <linux-mm@kvack.org>; Tue, 18 Apr 2017 18:46:51 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id z185so4092906pgz.11
        for <linux-mm@kvack.org>; Tue, 18 Apr 2017 15:46:51 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id a8si438813pgk.365.2017.04.18.15.46.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Apr 2017 15:46:50 -0700 (PDT)
Date: Tue, 18 Apr 2017 15:46:47 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/4] fs: fix data invalidation in the cleancache during
 direct IO
Message-Id: <20170418154647.9583bfa06705c614a2640a15@linux-foundation.org>
In-Reply-To: <20170414140753.16108-2-aryabinin@virtuozzo.com>
References: <20170414140753.16108-1-aryabinin@virtuozzo.com>
	<20170414140753.16108-2-aryabinin@virtuozzo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Eric Van Hensbergen <ericvh@gmail.com>, Ron Minnich <rminnich@sandia.gov>, Latchesar Ionkov <lucho@ionkov.net>, Steve French <sfrench@samba.org>, Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Trond Myklebust <trond.myklebust@primarydata.com>, Anna Schumaker <anna.schumaker@netapp.com>, Jan Kara <jack@suse.cz>, Jens Axboe <axboe@kernel.dk>, Johannes Weiner <hannes@cmpxchg.org>, Alexey Kuznetsov <kuznet@virtuozzo.com>, Christoph Hellwig <hch@lst.de>, v9fs-developer@lists.sourceforge.net, linux-kernel@vger.kernel.org, linux-cifs@vger.kernel.org, samba-technical@lists.samba.org, linux-nfs@vger.kernel.org, linux-mm@kvack.org

On Fri, 14 Apr 2017 17:07:50 +0300 Andrey Ryabinin <aryabinin@virtuozzo.com> wrote:

> Some direct write fs hooks call invalidate_inode_pages2[_range]()
> conditionally iff mapping->nrpages is not zero. If page cache is empty,
> buffered read following after direct IO write would get stale data from
> the cleancache.
> 
> Also it doesn't feel right to check only for ->nrpages because
> invalidate_inode_pages2[_range] invalidates exceptional entries as well.
> 
> Fix this by calling invalidate_inode_pages2[_range]() regardless of nrpages
> state.

I'm not understanding this.  I can buy the argument about
nrexceptional, but why does cleancache require the
invalidate_inode_pages2_range) call even when ->nrpages is zero?

I *assume* it's because invalidate_inode_pages2_range() calls
cleancache_invalidate_inode(), yes?  If so, can we please add this to
the changelog?  If not then please explain further.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
