Date: Wed, 24 Feb 1999 12:36:11 -0500 (EST)
From: "Benjamin C.R. LaHaise" <blah@kvack.org>
Subject: Re: MM question
In-Reply-To: <ixdn2266t22.fsf@turbot.pdc.kth.se>
Message-ID: <Pine.LNX.3.95.990224120401.25235C-100000@as200.spellcast.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Magnus Ahltorp <map@stacken.kth.se>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 22 Feb 1999, Magnus Ahltorp wrote:

> Right now, an Arla inode has some extra information, containing a
> dentry for the cache file. The readpage() function just validates the
> cache information, fills in a struct file (with the ext2 inode) and
> calls ext2's readpage(). The struct page pointer is passed along to
> ext2's readpage() without any modifications.

Okay, you probably don't want to implement readpage, just read and write,
so your read will look like:

my_read(...)
{
	validate_cache();
	return cache_inode->read(cache_inode, ...)
}

The write operation should be something like:

my_write(...)
{
	validate_cache_for_write();
	down(&cache_inode->i_sem);
	cache_inode->write(cache_inode, ...)
	up(&cache_inode->i_sem);
}

This will make your inodes relatively lightweight, and avoid having in
memory pages attached to your inode which would be duplicates of those
attached to the ext2 inode.

> I don't really know what's supposed to happen during a readpage()
> call, and what I want is a way to make write() affect the pages that
> readpage() has read.

Readpage is called by generic_file_read and page fault handlers to pull
the page into the page cache.  In the case of writing, you need to update
the page cache, as well as commit the write to whatever backstore is used. 
Since you've got the entire file cached (right?), just making use of the
ext2 inode's read & write will keep the cache coherent and reduce the
amount work you need to do. 

> (I might sound somewhat disoriented, but that is because I am)

You're asking questions, so the hard part is over =)

		-ben

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
