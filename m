Date: Tue, 30 Oct 2007 18:58:40 -0400
From: Chris Mason <chris.mason@oracle.com>
Subject: Re: migratepage failures on reiserfs
Message-ID: <20071030185840.48f5a10b@think.oraclecorp.com>
In-Reply-To: <1193781245.8904.28.camel@dyn9047017100.beaverton.ibm.com>
References: <1193768824.8904.11.camel@dyn9047017100.beaverton.ibm.com>
	<20071030135442.5d33c61c@think.oraclecorp.com>
	<1193781245.8904.28.camel@dyn9047017100.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: reiserfs-devel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, 30 Oct 2007 13:54:05 -0800
Badari Pulavarty <pbadari@us.ibm.com> wrote:

> On Tue, 2007-10-30 at 13:54 -0400, Chris Mason wrote:
> > On Tue, 30 Oct 2007 10:27:04 -0800
> > Badari Pulavarty <pbadari@us.ibm.com> wrote:
> > 
> > > Hi,
> > > 
> > > While testing hotplug memory remove, I ran into this issue. Given
> > > a range of pages hotplug memory remove tries to migrate those
> > > pages.
> > > 
> > > migrate_pages() keeps failing to migrate pages containing
> > > pagecache pages for reiserfs files. I noticed that reiserfs
> > > doesn't have ->migratepage() ops. So, fallback_migrate_page()
> > > code tries to do try_to_release_page(). try_to_release_page()
> > > fails to drop_buffers() since b_count == 1. Here is what my debug
> > > shows:
> > > 
> > > 	migrate pages failed pfn 258111/flags 3f00000000801
> > > 	bh c00000000b53f6e0 flags 110029 count 1
> > > 	
> > > Any one know why the b_count == 1 and not getting dropped to
> > > zero ? 
> > 
> > If these are file data pages, the count is probably elevated as
> > part of the data=ordered tracking.  You can verify this via
> > b_private, or just mount data=writeback to double check.
> 
> 
> Chris,
> 
> That was my first assumption. But after looking at
> reiserfs_releasepage (), realized that it would do reiserfs_free_jh()
> and clears the b_private. I couldn't easily find out who has the ref.
> against this bh.
> 
> bh c00000000bdaaf00 flags 110029 count 1 private 0
> 

If I'm reading this correctly the buffer is BH_Lock | BH_Req, perhaps
it is currently under IO?

The page isn't locked, but data=ordered does IO directly on the buffer
heads, without taking the page lock.

The easy way to narrow our search is to try without data=ordered, it is
certainly complicating things.

-chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
