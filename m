Received: from m2vwall5.wipro.com (m2vwall5.wipro.com [10.115.50.5])
	by wiprom2mx1.wipro.com (8.11.3/8.11.3) with SMTP id h3AI1hN24814
	for <linux-mm@kvack.org>; Thu, 10 Apr 2003 23:31:47 +0530 (IST)
content-class: urn:content-classes:message
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
Subject: Hang in filemap_fdatasync on SMP machine
Date: Thu, 10 Apr 2003 23:31:38 +0530
Message-ID: <52C85426D39B314381D76DDD480EEE0CAA1B6B@blr-m3-msg.wipro.com>
From: "Deepa Chacko Pillai" <deepa.chacko@wipro.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi

I have written a kernel API to flush data to the disk. Whenever I call this API on an SMP machine, it causes the system to hang. The code looks like:

		    down(&inode->i_sem);
                ret = filemap_fdatasync(inode->i_mapping);
                err = file->f_op->fsync(file, dentry, 0);
                if (err && !ret)
                        ret = err;
                err = filemap_fdatawait(inode->i_mapping);
                if (err && !ret)
                        ret = err;
                up(&inode->i_sem);

This code works perfectly fine on uniprocessor systems. But it hangs in filemap_fdatasync on SMP systems. It goes in an infinite loop in filemap_fdatasync (). Inside filemap_fdatasync (), it finds that the page is not dirty and keeps going in a loop.

	while (!list_empty(&mapping->dirty_pages)) {
                struct page *page = list_entry(mapping->dirty_pages.prev, struct page, list);

                list_del(&page->list);
                list_add(&page->list, &mapping->locked_pages);

                if (!PageDirty(page))
                        continue;

	....
	}

I am using Red Hat Linux with kernel version 2.4.19. Any help would be much appreciated.

Thanks
Deepa


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
