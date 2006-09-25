Date: Mon, 25 Sep 2006 15:53:23 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: Checking page_count(page) in invalidate_complete_page
Message-Id: <20060925155323.87c796fd.akpm@osdl.org>
In-Reply-To: <4518589E.1070705@oracle.com>
References: <4518333E.2060101@oracle.com>
	<20060925141036.73f1e2b3.akpm@osdl.org>
	<4518589E.1070705@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: chuck.lever@oracle.com
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>, Steve Dickson <steved@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 25 Sep 2006 18:30:54 -0400
Chuck Lever <chuck.lever@oracle.com> wrote:

> It seems that the NFS client could now safely use a page cache 
> invalidator that would wait for other page users to ensure that every 
> page is invalidated properly, instead of skipping the pages that can't 
> be immediately invalidated.
> 
> In my opinion that would be the correct fix here for NFS.

OK.  But unfortunately there isn't anything to wait *on*.  It would require
a sleep-a-bit-then-retry loop, with something in there to prevent infinite
looping, and something else to handle the case where the
infinite-loop-preventor prevented an infinite loop.  Which gets rather
nasty.


And block-backed direct-io needs the stronger invalidate_inode_pages2() as
well - right now it's subtly broken, only nobody has noticed yet.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
