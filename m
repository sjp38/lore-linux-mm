Subject: Re: [PATCH/RFC 0/14] Page Reclaim Scalability
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20070914205359.6536.98017.sendpatchset@localhost>
References: <20070914205359.6536.98017.sendpatchset@localhost>
Content-Type: text/plain
Date: Fri, 14 Sep 2007 23:11:03 +0200
Message-Id: <1189804264.5826.5.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, mel@csn.ul.ie, clameter@sgi.com, riel@redhat.com, balbir@linux.vnet.ibm.com, andrea@suse.de, eric.whitney@hp.com, npiggin@suse.de, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, 2007-09-14 at 16:53 -0400, Lee Schermerhorn wrote:

> 1) make-anon_vma-lock-rw
> 2) make-i_mmap_lock-rw
> 
> The first two patches are not part of the noreclaim infrastructure.
> Rather, these patches improve parallelism in shrink_page_list()--
> specifically in page_referenced() and try_to_unmap()--by making the
> anon_vma lock and the i_mmap_lock reader/writer spinlocks.  

Also at Cambridge, Linus said that rw-spinlocks are usually a mistake.

Their spinning nature can cause a lot of cacheline bouncing. If it turns
out these locks still benefit, it might make sense to just turn them
into sleeping locks.

That said, even sleeping rw locks have issues on large boxen, but they
sure give a little more breathing room than mutal exclusive locks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
