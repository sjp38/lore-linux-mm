Date: Mon, 25 Sep 2000 02:17:14 -0400 (EDT)
From: Alexander Viro <aviro@redhat.com>
Subject: Re: [patch] vmfixes-2.4.0-test9-B2
In-Reply-To: <Pine.LNX.4.10.10009242301230.1293-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.10.10009250208400.5723-100000@aviro.devel.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Alexander Viro <viro@math.psu.edu>, Ingo Molnar <mingo@elte.hu>, Andrea Arcangeli <andrea@suse.de>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, Alexander Viro <aviro@redhat.com>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>



On Sun, 24 Sep 2000, Linus Torvalds wrote:

> I'm not claiming that the buffer cache accesses would go away - I'm just
> saying that the unbalanced "only buffer cache" case should go away,
> because things like "find" and friends will still cause mostly page cache
> activity.
> 
> (Considering the size of the inode on ext2, I don't know how true this is,
> I have to admit. It might still be quite biased towards the buffer cache,
> and as such the additional page cache pressure might not be enough to
> really cause any major shift in balancing).

Hrrrmmm... You know, since we don't have to associate struct inode with every
address space and inode table _is_ a linear array, after all... We
might put it into pagecache too. Very few places access the on-disk
inode, so it's not too horrible. All we need is readpage() and that's
very easy, considering the fact that allocation is static. prepare_write()
and commit_write() may be NULL for all I care and writepage() will
be easy too - no holes, no allocation, no nothing. Looks like we need to deal
with ext2_update_inode(), ext2_read_inode() and that's it. Even less
intrusive than directory stuff...

Comments?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
