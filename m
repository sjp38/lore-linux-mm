Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id C63C26B006C
	for <linux-mm@kvack.org>; Wed, 17 Dec 2014 09:58:38 -0500 (EST)
Received: by mail-pd0-f179.google.com with SMTP id fp1so16357222pdb.38
        for <linux-mm@kvack.org>; Wed, 17 Dec 2014 06:58:38 -0800 (PST)
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com. [209.85.192.176])
        by mx.google.com with ESMTPS id iz2si5840837pbd.196.2014.12.17.06.58.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 17 Dec 2014 06:58:37 -0800 (PST)
Received: by mail-pd0-f176.google.com with SMTP id r10so14313450pdi.35
        for <linux-mm@kvack.org>; Wed, 17 Dec 2014 06:58:36 -0800 (PST)
Date: Wed, 17 Dec 2014 06:58:32 -0800
From: Omar Sandoval <osandov@osandov.com>
Subject: Re: [PATCH 2/8] swap: lock i_mutex for swap_writepage direct_IO
Message-ID: <20141217145832.GA3497@mew>
References: <cover.1418618044.git.osandov@osandov.com>
 <a59510f4552a5d3557958cdb0ce1b23b3abfc75b.1418618044.git.osandov@osandov.com>
 <20141215162705.GA23887@quack.suse.cz>
 <20141215165615.GA19041@infradead.org>
 <20141215221100.GA4637@mew>
 <20141216083543.GA32425@infradead.org>
 <20141216085624.GA25256@mew>
 <20141217080610.GA20335@infradead.org>
 <20141217082020.GH22149@ZenIV.linux.org.uk>
 <20141217082437.GA9301@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141217082437.GA9301@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>, Al Viro <viro@ZenIV.linux.org.uk>
Cc: Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Trond Myklebust <trond.myklebust@primarydata.com>, David Sterba <dsterba@suse.cz>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Dec 17, 2014 at 12:24:37AM -0800, Christoph Hellwig wrote:
> On Wed, Dec 17, 2014 at 08:20:21AM +0000, Al Viro wrote:
> > Where the hell would those other references come from?  We open the damn
> > thing in sys_swapon(), never put it into descriptor tables, etc. and
> > the only reason why we use filp_close() instead of fput() is that we
> > would miss ->flush() otherwise.
> > 
> > Said that, why not simply *open* it with O_DIRECT to start with and be done
> > with that?  It's not as if those guys came preopened by caller - swapon(2)
> > gets a pathname and does opening itself.
> 
> Oops, should have dug deeper into the code.  For some reason I assumed
> the fd is passed in from userspace.
> 
> The suggestion from Al is much better, given that we never do normal
> I/O on the swapfile, just the bmap + direct bio submission which I hope
> could go away in favor of the direct I/O variant in the long run.

See my previous message. If we use O_DIRECT on the original open, then
filesystems that implement bmap but not direct_IO will no longer work.
These are the ones that I found in my tree:

adfs
befs
bfs
ecryptfs
efs
freevxfs
hpfs
isofs
minix
ntfs
omfs
qnx4
qnx6
sysv
ufs

Several of these are read only, and I can't imagine that anyone is using
a swapfile on any of the rest, but if someone is, this would be a
regression, wouldn't it?

-- 
Omar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
