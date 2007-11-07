Date: Wed, 7 Nov 2007 11:31:24 +0100
From: =?utf-8?B?SsO2cm4=?= Engel <joern@logfs.org>
Subject: Re: [patch 14/23] inodes: Support generic defragmentation
Message-ID: <20071107103124.GD7374@lazybastard.org>
References: <20071107011130.382244340@sgi.com> <20071107011229.893091119@sgi.com> <20071107101748.GC7374@lazybastard.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20071107101748.GC7374@lazybastard.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: =?utf-8?B?SsO2cm4=?= Engel <joern@logfs.org>
Cc: Christoph Lameter <clameter@sgi.com>, akpm@linux-foundatin.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mel@skynet.ie>
List-ID: <linux-mm.kvack.org>

On Wed, 7 November 2007 11:17:48 +0100, JA?rn Engel wrote:
> > +/*
> > + * Function for filesystems that embedd struct inode into their own
> > + * structures. The offset is the offset of the struct inode in the fs inode.
> > + */
> > +void *fs_get_inodes(struct kmem_cache *s, int nr, void **v,
> > +						unsigned long offset)
> > +{
> > +	int i;
> > +
> > +	for (i = 0; i < nr; i++)
> > +		v[i] += offset;
> > +
> > +	return get_inodes(s, nr, v);
> > +}
> > +EXPORT_SYMBOL(fs_get_inodes);
> 
> The fact that all pointers get changed makes me a bit uneasy:
> 	struct foo_inode v[20];
> 	...
> 	fs_get_inodes(..., v, ...);
> 	...
> 	v[0].foo_field = bar;
> 	
> No warning, but spectacular fireworks.
> 
> > +void kick_inodes(struct kmem_cache *s, int nr, void **v, void *private)
> > +{
> > +	struct inode *inode;
> > +	int i;
> > +	int abort = 0;
> > +	LIST_HEAD(freeable);
> > +	struct super_block *sb;
> > +
> > +	for (i = 0; i < nr; i++) {
> > +		inode = v[i];
> > +		if (!inode)
> > +			continue;
> 
> NULL is legal here?  Then fs_get_inodes should check for NULL as well
> and not add the offset to NULL pointers, I guess.

Ignore these two comments.  Reading further before making them would
have helped. ;)

JA?rn

-- 
Fancy algorithms are slow when n is small, and n is usually small.
Fancy algorithms have big constants. Until you know that n is
frequently going to be big, don't get fancy.
-- Rob Pike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
