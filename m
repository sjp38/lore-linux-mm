Date: Sat, 6 May 2000 15:15:44 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: Updates to /bin/bash
In-Reply-To: <14610.29880.728540.947675@charged.uio.no>
Message-ID: <Pine.LNX.4.21.0005060519310.2332-100000@alpha.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: Matthew Vanecek <linuxguy@directlink.net>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 5 May 2000, Trond Myklebust wrote:

>NO. This behaviour is exactly what Andreas patch would break. New

My patch won't hurt the bash update as far I can tell.

In clean 2.2.15 and clean 2.3.99-pre7-pre6 you don't unmap the page from
the ptes, so if nfs doesn't keep to do the pageins from the inode pointed
by the nfsfilehandle, then you'll get a mixture anyway even if you drop
the mapped pages from the cache (and nfs probably can't keep do to the
pageins from the old file if somebody replaced bash on the real fs but in
the worst case nfs should notice that and it should abort the `bash`
execution and to never do the silent mixture).

New executed bash are not an issue since they will get a new inode present
on the server and so they won't risk to do the mixture.

All above thoughts assumes the admin correctly uses remove(2) to upgrade
bash (otherwise the mixture would happen also on top of ext2).

About the stability issue I looked some more and maybe the VM is not
subject to stability issues by dropping a mapped cache-page from the cache
(however the thing keeps to look not robust to me). Everything depends on
the page->index that have to be not clobbered after dropping the page from
the cache (while page->index is supposed to have a meaning only on
pagecache or swapcache).

Andrea


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
