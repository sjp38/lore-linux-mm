Date: Mon, 15 Mar 1999 18:05:03 GMT
Message-Id: <199903151805.SAA01926@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: MM question
In-Reply-To: <ixdn2266t22.fsf@turbot.pdc.kth.se>
References: <Pine.LNX.3.95.990221161643.24011A-100000@as200.spellcast.com>
	<ixdn2266t22.fsf@turbot.pdc.kth.se>
Sender: owner-linux-mm@kvack.org
To: Magnus Ahltorp <map@stacken.kth.se>
Cc: "Benjamin C.R. LaHaise" <blah@kvack.org>, linux-mm@kvack.org, Stephen Tweedie <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

On 22 Feb 1999 22:13:09 +0100, Magnus Ahltorp <map@stacken.kth.se> said:

> Right now, an Arla inode has some extra information, containing a
> dentry for the cache file. The readpage() function just validates the
> cache information, fills in a struct file (with the ext2 inode) and
> calls ext2's readpage(). The struct page pointer is passed along to
> ext2's readpage() without any modifications.

This sounds like the source of the problem: the Arla inode's readpage
function will not be called if the page cache for the Arla page is
already present.  If you write to the underlying file, it will update
any ext2fs page cache present for the page, but will not touch the Arla
page itself.  You need to call update_vm_cache() against the appropriate
Arla inode for that to happen.  (Ext2 will already call
update_vm_cache() for the ext2fs inode, so the ext2 page cache will
remain consistent internally.)

Of course, you really want to take a step back at this point and work
out if this is really the best way forward, since you just end up
caching things twice if you are not careful...

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
