Subject: Re: [PATCH RFC] extent mapped page cache
From: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <20070724160032.7a7097db@think.oraclecorp.com>
References: <20070710210326.GA29963@think.oraclecorp.com>
	 <20070724160032.7a7097db@think.oraclecorp.com>
Content-Type: text/plain
Date: Tue, 24 Jul 2007 16:13:05 -0400
Message-Id: <1185307985.6586.50.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chris Mason <chris.mason@oracle.com>
Cc: Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 2007-07-24 at 16:00 -0400, Chris Mason wrote:
> On Tue, 10 Jul 2007 17:03:26 -0400
> Chris Mason <chris.mason@oracle.com> wrote:
> 
> > This patch aims to demonstrate one way to replace buffer heads with a
> > few extent trees.  Buffer heads provide a few different features:
> > 
> > 1) Mapping of logical file offset to blocks on disk
> > 2) Recording state (dirty, locked etc)
> > 3) Providing a mechanism to access sub-page sized blocks.
> > 
> > This patch covers #1 and #2, I'll start on #3 a little later next
> > week.
> > 
> Well, almost.  I decided to try out an rbtree instead of the radix,
> which turned out to be much faster.  Even though individual operations
> are slower, the rbtree was able to do many fewer ops to accomplish the
> same thing, especially for merging extents together.  It also uses much
> less ram.

The problem with an rbtree is that you can't use it together with RCU to
do lockless lookups. You can probably modify it to allocate nodes
dynamically (like the radix tree does) and thus make it RCU-compatible,
but then you risk losing the two main benefits that you list above.

Trond

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
