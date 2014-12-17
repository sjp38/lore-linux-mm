Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f53.google.com (mail-wg0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 657516B0075
	for <linux-mm@kvack.org>; Wed, 17 Dec 2014 03:20:33 -0500 (EST)
Received: by mail-wg0-f53.google.com with SMTP id l18so19533356wgh.12
        for <linux-mm@kvack.org>; Wed, 17 Dec 2014 00:20:33 -0800 (PST)
Received: from ZenIV.linux.org.uk ([2002:c35c:fd02::1])
        by mx.google.com with ESMTPS id gs8si26082346wib.2.2014.12.17.00.20.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 17 Dec 2014 00:20:32 -0800 (PST)
Date: Wed, 17 Dec 2014 08:20:21 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH 2/8] swap: lock i_mutex for swap_writepage direct_IO
Message-ID: <20141217082020.GH22149@ZenIV.linux.org.uk>
References: <cover.1418618044.git.osandov@osandov.com>
 <a59510f4552a5d3557958cdb0ce1b23b3abfc75b.1418618044.git.osandov@osandov.com>
 <20141215162705.GA23887@quack.suse.cz>
 <20141215165615.GA19041@infradead.org>
 <20141215221100.GA4637@mew>
 <20141216083543.GA32425@infradead.org>
 <20141216085624.GA25256@mew>
 <20141217080610.GA20335@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141217080610.GA20335@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Omar Sandoval <osandov@osandov.com>, Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Trond Myklebust <trond.myklebust@primarydata.com>, David Sterba <dsterba@suse.cz>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Dec 17, 2014 at 12:06:10AM -0800, Christoph Hellwig wrote:

> > This seems to be more or less equivalent to doing a fcntl(F_SETFL) to
> > add the O_DIRECT flag to swap_file (which is a struct file *). Swapoff
> > calls filp_close on swap_file, so I don't see why it's necessary to
> > clear the flag.
> 
> filp_lose doesn't nessecarily destroy the file structure, there might be
> other reference to it, e.g. from dup() or descriptor passing.

Where the hell would those other references come from?  We open the damn
thing in sys_swapon(), never put it into descriptor tables, etc. and
the only reason why we use filp_close() instead of fput() is that we
would miss ->flush() otherwise.

Said that, why not simply *open* it with O_DIRECT to start with and be done
with that?  It's not as if those guys came preopened by caller - swapon(2)
gets a pathname and does opening itself.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
