Received: from turbot.pdc.kth.se (turbot.pdc.kth.se [130.237.221.42])
	by kvack.org (8.8.7/8.8.7) with ESMTP id OAA23291
	for <linux-mm@kvack.org>; Sun, 21 Feb 1999 14:53:48 -0500
Subject: MM question
From: Magnus Ahltorp <map@stacken.kth.se>
Date: 21 Feb 1999 20:53:37 +0100
Message-ID: <ixdpv73a5z2.fsf@turbot.pdc.kth.se>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I'm working on a Linux port of Arla, a free AFS (a distributed file
system) client. Arla caches whole files, which means that the read and
write file system calls are tunneled through to the cache file system
(usually ext2).

I implement the inode operation readpage for reads and the file
operation write for writes. readpage gets tunneled by creating a new
struct file and filling in the cache inode. write gets tunneled in
much the same way. Though, I have been seeing problems when a file
gets written to. The written data weren't always seen when doing
reads. Someone then suggested that the folloing code be added to
write:

	page = get_free_page(GFP_KERNEL);
	if (!page)
	    invalidate_inode_pages(inode);
	else {
	    int pos = file->f_pos;
	    int cnt = count;
	    int blk;
	    char *data=(char *)page;

	    while (cnt > 0) {
		blk = cnt;
		if (blk > PAGE_SIZE)
		    blk = PAGE_SIZE;
		copy_from_user(data, buf, blk);
		update_vm_cache(inode, pos, data, blk);
		pos += blk;
		cnt -= blk;
	    }
	    free_page(page);
	}

I inserted this piece of code, and things worked quite well. After a
while, I was seeing new problems. Writes were not propagating properly
to the cache file.

Does anyone have any suggestions on how this really should be done?

/Magnus
map@stacken.kth.se
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
