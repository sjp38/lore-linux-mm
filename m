Subject: Re: allowed pages in the block later, was Re: [Ext2-devel] [PATCH]
	ext3: avoid sending down non-refcounted pages
From: Arjan van de Ven <arjan@infradead.org>
In-Reply-To: <20051210164736.6e4eaa3f.akpm@osdl.org>
References: <20051208180900T.fujita.tomonori@lab.ntt.co.jp>
	 <20051208101833.GM14509@schatzie.adilger.int>
	 <20051208134239.GA13376@infradead.org>
	 <20051210164736.6e4eaa3f.akpm@osdl.org>
Content-Type: text/plain
Date: Sun, 11 Dec 2005 09:44:04 +0100
Message-Id: <1134290645.2878.4.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, open-iscsi@googlegroups.com, ext2-devel@lists.sourceforge.net, linux-fsdevel@vger.kernel.org, michaelc@cs.wisc.edu, fujita.tomonori@lab.ntt.co.jp, Christoph Hellwig <hch@infradead.org>
List-ID: <linux-mm.kvack.org>

On Sat, 2005-12-10 at 16:47 -0800, Andrew Morton wrote:
> Christoph Hellwig <hch@infradead.org> wrote:
> >
> > The problem we're trying to solve here is how do implement network block
> >  devices (nbd, iscsi) efficiently.  The zero copy codepath in the networking
> >  layer does need to grab additional references to pages.  So to use sendpage
> >  we need a refcountable page.  pages used by the slab allocator are not
> >  normally refcounted so try to do get_page/pub_page on them will break.
> 
> I don't get it.  Doing get_page/put_page on a slab-allocated page should do
> the right thing?

but it doesn't stop the kfree from freeing the memory; zero copy needs
the content of the memory to stay around afterwards, eg it wants to
delay the kfree until the data is over the wire, which is an
asynchronous event versus the actual send command in a zero-copy
situation. 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
