Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f177.google.com (mail-pf0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id A046B6B0254
	for <linux-mm@kvack.org>; Wed,  9 Dec 2015 20:21:58 -0500 (EST)
Received: by pfnn128 with SMTP id n128so38803126pfn.0
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 17:21:58 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id oj5si15349655pab.184.2015.12.09.17.21.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Dec 2015 17:21:57 -0800 (PST)
Date: Wed, 9 Dec 2015 17:21:30 -0800
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v5] fs: clear file privilege bits when mmap writing
Message-ID: <20151210012130.GA17673@infradead.org>
References: <20151209225148.GA14794@www.outflux.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151209225148.GA14794@www.outflux.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, yalin wang <yalin.wang2010@gmail.com>, Willy Tarreau <w@1wt.eu>, "Eric W. Biederman" <ebiederm@xmission.com>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

> Changing the bits requires holding inode->i_mutex, so it cannot be done
> during the page fault (due to mmap_sem being held during the fault). We
> could do this during vm_mmap_pgoff, but that would need coverage in
> mprotect as well, but to check for MAP_SHARED, we'd need to hold mmap_sem
> again. We could clear at open() time, but it's possible things are
> accidentally opening with O_RDWR and only reading. Better to clear on
> close and error failures (i.e. an improvement over now, which is not
> clearing at all).
> 
> Instead, detect the need to clear the bits during the page fault, and
> actually remove the bits during final fput. Since the file was open for
> writing, it wouldn't have been possible to execute it yet.


> 
> Signed-off-by: Kees Cook <keescook@chromium.org>
> ---
> I think this is the best we can do; everything else is blocked by mmap_sem.

It should be done at mmap time, before even taking mmap_sem.

Adding a new field for this to strut file isn't really acceptable.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
