Date: Mon, 25 Mar 2002 19:43:18 +0100
From: Christoph Hellwig <hch@caldera.de>
Subject: Re: [PATCH] latest radix-tree pagecache patch and 2.4.19-pre3-ac6
Message-ID: <20020325194317.A31878@caldera.de>
References: <20020325114947.A606@debian>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20020325114947.A606@debian>; from ahaas@neosoft.com on Mon, Mar 25, 2002 at 11:49:47AM -0600
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Art Haas <ahaas@neosoft.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 25, 2002 at 11:49:47AM -0600, Art Haas wrote:
> Hi.
> 
> The original radix-tree patch applies fairly cleanly to the
> -ac6 tree, but there are a few files that need touching up. The
> mm/vmscan.c, mm/filemap.c, and mm/shmem.c files needed the
> most attention. For vmscan.c, a couple of pieces in the original
> patch were dropped, as it looks like they'll only apply (or
> make sense) with the non-rmap code. As for filemap.c, a few
> changes seemed to conflict with the rmap code, so my efforts
> to make a compilable file may have broken the code. But hey,
> I got a `.o' file from the compiler, so it must work, right? :-)

I think I have found at least once obvious bug:

 a) this cannot actually compile, pagecache_lock is gone..
 b) find_get_page already does locking internally AND also
    grabs a reference to the page.

This should probably be just a radix_tree_lookup()

@@ -1064,7 +999,7 @@
 	spin_lock(&pagemap_lru_lock);
 	while (--index >= start) {
 		spin_lock(&pagecache_lock);
-		page = __find_page(mapping, index);
+		page = find_get_page(mapping, index);
 		spin_unlock(&pagecache_lock);
 		if (!page || !PageActive(page))
 			break;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
