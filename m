Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 017CE6B0078
	for <linux-mm@kvack.org>; Wed, 17 Dec 2014 03:24:46 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id kq14so15967428pab.40
        for <linux-mm@kvack.org>; Wed, 17 Dec 2014 00:24:45 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id q3si4337992pda.251.2014.12.17.00.24.43
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Dec 2014 00:24:44 -0800 (PST)
Date: Wed, 17 Dec 2014 00:24:37 -0800
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 2/8] swap: lock i_mutex for swap_writepage direct_IO
Message-ID: <20141217082437.GA9301@infradead.org>
References: <cover.1418618044.git.osandov@osandov.com>
 <a59510f4552a5d3557958cdb0ce1b23b3abfc75b.1418618044.git.osandov@osandov.com>
 <20141215162705.GA23887@quack.suse.cz>
 <20141215165615.GA19041@infradead.org>
 <20141215221100.GA4637@mew>
 <20141216083543.GA32425@infradead.org>
 <20141216085624.GA25256@mew>
 <20141217080610.GA20335@infradead.org>
 <20141217082020.GH22149@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141217082020.GH22149@ZenIV.linux.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Omar Sandoval <osandov@osandov.com>, Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Trond Myklebust <trond.myklebust@primarydata.com>, David Sterba <dsterba@suse.cz>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Dec 17, 2014 at 08:20:21AM +0000, Al Viro wrote:
> Where the hell would those other references come from?  We open the damn
> thing in sys_swapon(), never put it into descriptor tables, etc. and
> the only reason why we use filp_close() instead of fput() is that we
> would miss ->flush() otherwise.
> 
> Said that, why not simply *open* it with O_DIRECT to start with and be done
> with that?  It's not as if those guys came preopened by caller - swapon(2)
> gets a pathname and does opening itself.

Oops, should have dug deeper into the code.  For some reason I assumed
the fd is passed in from userspace.

The suggestion from Al is much better, given that we never do normal
I/O on the swapfile, just the bmap + direct bio submission which I hope
could go away in favor of the direct I/O variant in the long run.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
