Date: Sun, 1 Jul 2001 22:20:11 +0200
From: bert hubert <ahu@ds9a.nl>
Subject: again, no dirty pages?
Message-ID: <20010701222011.A30171@home.ds9a.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is my local version of mincore_page in filemap.c:

static unsigned char mincore_page(struct vm_area_struct * vma,
		unsigned long pgoff)
{
		unsigned char present = 0;
	struct address_space * as = &vma->vm_file->f_dentry->d_inode->i_data;
	struct page * page, ** hash = page_hash(as, pgoff);

	spin_lock(&pagecache_lock);
	page = __find_page_nolock(as, pgoff, *hash);
	if (page) {
	 	if(Page_Uptodate(page))
	                present |= 1;
	        if(PageDirty(page))
	                present |= 2;
	}

 	spin_unlock(&pagecache_lock);
 
 	return present;
}

But it never sets any bits for DirtyPages, even when I think there should be
dirty pages, for example, when I run "cat /dev/zero > file" and
simultaneously cinfo (http://ds9a.nl/cinfo) on the generated file.

My version of cinfo also looks for the second bit, but it never finds any
dirty pages.

Any clues? Thanks!

-- 
http://www.PowerDNS.com      Versatile DNS Services  
Trilab                       The Technology People   
'SYN! .. SYN|ACK! .. ACK!' - the mating call of the internet
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
