Subject: Re: Status of buffered write path (deadlock fixes)
From: Steven Whitehouse <swhiteho@redhat.com>
In-Reply-To: <457D89DA.5010705@yahoo.com.au>
References: <45751712.80301@yahoo.com.au>
	 <20061207195518.GG4497@ca-server1.us.oracle.com>
	 <4578DBCA.30604@yahoo.com.au>
	 <20061208234852.GI4497@ca-server1.us.oracle.com>
	 <457D20AE.6040107@yahoo.com.au>  <457D7EBA.7070005@yahoo.com.au>
	 <1165853552.3752.1015.camel@quoit.chygwyn.com>
	 <457D89DA.5010705@yahoo.com.au>
Content-Type: text/plain
Date: Mon, 11 Dec 2006 17:18:32 +0000
Message-Id: <1165857512.3752.1032.camel@quoit.chygwyn.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andrew Morton <akpm@google.com>, OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>, linux-kernel <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org, Linux Memory Management <linux-mm@kvack.org>, Mark Fasheh <mark.fasheh@oracle.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, 2006-12-12 at 03:39 +1100, Nick Piggin wrote:
> Steven Whitehouse wrote:
> 
> >>Hmm, doesn't look like we can do this either because at least GFS2
> >>uses BH_New for its own special things.
> >>
> > 
> > What makes you say that? As far as I know we are not doing anything we
> > shouldn't with this flag, and if we are, then I'm quite happy to
> > consider fixing it up so that we don't,
> 
> Bad wording. Many other filesystems seem to only make use of buffer_new
> between prepare and commit_write.
> 
> gfs2 seems to at least test it in a lot of places, so it is hard to know
> whether we can change the current semantics or not. I didn't mean that
> gfs2 is doing anything wrong.
> 
> So can we clear it in commit_write?
> 
Are you perhaps looking at an older copy of the GFS2 code? We set it (or
clear it) in bmap.c:gfs2_block_map() as appropriate. It also seems to be
cleared when we release buffers (which may or may not be actually
required. I suspect not, but its harmless anyway). There is only one
test that I can find for it which is in bmap.c:gfs2_extent_map() where
its value is then later ignored in the only caller relevant to "normal"
files, which is ops_vm.c:alloc_page_backing(). So I think you should be
quite safe to clear it in commit_write().

Steve.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
