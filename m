Message-ID: <48F378C6.7030206@linux-foundation.org>
Date: Mon, 13 Oct 2008 09:35:18 -0700
From: Christoph Lameter <cl@linux-foundation.org>
MIME-Version: 1.0
Subject: Re: SLUB defrag pull request?
References: <1223883004.31587.15.camel@penberg-laptop> <1223883164.31587.16.camel@penberg-laptop> <Pine.LNX.4.64.0810131227120.20511@blonde.site> <200810132354.30789.nickpiggin@yahoo.com.au> <E1KpNwq-0003OW-8f@pomaz-ex.szeredi.hu> <E1KpOOL-0003Vf-9y@pomaz-ex.szeredi.hu>
In-Reply-To: <E1KpOOL-0003Vf-9y@pomaz-ex.szeredi.hu>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: penberg@cs.helsinki.fi, nickpiggin@yahoo.com.au, hugh@veritas.com, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Miklos Szeredi wrote:
> And the things kick_inodes() does without any sort of locking look
> even more dangerous.
>
> It should be the other way round: first make sure nothing is
> referencing the inode, and _then_ start cleaning it up with
> appropriate locks held.  See prune_icache().
>
>   
kick_inodes() only works on inodes that first have undergone 
get_inodes() where we establish a refcount under inode_lock(). The final 
cleanup in kick_inodes() is done under iprune_mutex. You are looking at 
the loop that does writeback and invalidates attached dentries. This can 
fail for various reasons.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
