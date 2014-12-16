Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id C9C2B6B006C
	for <linux-mm@kvack.org>; Tue, 16 Dec 2014 03:35:51 -0500 (EST)
Received: by mail-pd0-f179.google.com with SMTP id fp1so13378618pdb.24
        for <linux-mm@kvack.org>; Tue, 16 Dec 2014 00:35:51 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id d6si114919pdm.104.2014.12.16.00.35.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Dec 2014 00:35:50 -0800 (PST)
Date: Tue, 16 Dec 2014 00:35:43 -0800
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 2/8] swap: lock i_mutex for swap_writepage direct_IO
Message-ID: <20141216083543.GA32425@infradead.org>
References: <cover.1418618044.git.osandov@osandov.com>
 <a59510f4552a5d3557958cdb0ce1b23b3abfc75b.1418618044.git.osandov@osandov.com>
 <20141215162705.GA23887@quack.suse.cz>
 <20141215165615.GA19041@infradead.org>
 <20141215221100.GA4637@mew>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141215221100.GA4637@mew>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Omar Sandoval <osandov@osandov.com>
Cc: Jan Kara <jack@suse.cz>, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Trond Myklebust <trond.myklebust@primarydata.com>, David Sterba <dsterba@suse.cz>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, Dec 15, 2014 at 02:11:00PM -0800, Omar Sandoval wrote:
> Ok, I got the swap code working with ->read_iter/->write_iter without
> too much trouble. I wanted to double check before I submit if there's
> any gotchas involved with adding the O_DIRECT flag to a file pointer
> after it has been opened -- swapon opens the swapfile before we know if
> we're using the SWP_FILE infrastructure, and we need to add O_DIRECT so
> ->{read,write}_iter use direct I/O, but we can't add O_DIRECT to the
> original open without excluding filesystems that support the old bmap
> path but not direct I/O.

In general just adding O_DIRECT is a problem.  However given that the
swap file is locked against any other access while in use it seems ok
in this particular case.  Just make sure to clear it on swapoff, and
write a detailed comment explaining the situation.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
