Received: from petasus.jf.intel.com (petasus.jf.intel.com [10.7.209.6])
	by orsfmr001.jf.intel.com (8.12.9-20030918-01/8.12.9/d: major-outer.mc,v 1.15 2004/01/30 18:16:28 root Exp $) with ESMTP id i6RJW5Ge024837
	for <linux-mm@kvack.org>; Tue, 27 Jul 2004 19:32:10 GMT
Received: from orsmsxvs041.jf.intel.com (orsmsxvs041.jf.intel.com [192.168.65.54])
	by petasus.jf.intel.com (8.12.9-20030918-01/8.12.9/d: major-inner.mc,v 1.10 2004/03/01 19:21:36 root Exp $) with SMTP id i6S2XEFP013811
	for <linux-mm@kvack.org>; Wed, 28 Jul 2004 02:33:14 GMT
Received: from orsmsx332.amr.corp.intel.com ([192.168.65.60])
 by orsmsxvs041.jf.intel.com (SAVSMTP 3.1.2.35) with SMTP id M2004072719311123243
 for <linux-mm@kvack.org>; Tue, 27 Jul 2004 19:31:11 -0700
Content-class: urn:content-classes:message
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
Subject: Protection of 'struct address_space'?
Date: Tue, 27 Jul 2004 19:30:57 -0700
Message-ID: <F989B1573A3A644BAB3920FBECA4D25A6EBFE6@orsmsx407>
From: "Perez-Gonzalez, Inaky" <inaky.perez-gonzalez@intel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi All

Some days ago I came around with a question on how to get 
a 'struct page *' backed up by a 'struct inode *' and an offset.
Came up with:

01 int __vl_key_page_get_shared (struct page **ppage,
02                               struct inode *inode, unsigned pgoff)
03 {
04         int result;
05         struct page *page;
06         struct address_space *mapping = inode->i_mapping;
07 
08 #warning: FIXME: block/lock the mapping...I am not that sure of this
09         down (&mapping->i_shared_sem);
10         page = read_cache_page (mapping, pgoff, 
11                                 (filler_t *) mapping->a_ops->readpage, NULL);
12         result = PTR_ERR (page);
13         if (IS_ERR (page))
14                 goto out_up;
15         
16         wait_on_page_locked (page);
17         if (!PageUptodate (page)) {
18                 page_cache_release (page);
19                 page = ERR_PTR (-EIO);
20         }
21         *ppage = page;
22         return 0;
23 
24 out_up:
25         up (&mapping->i_shared_sem);
26         return result;
27 }

[this followed a put() kind of function that would release 
the page and the i_shared_sem semaphore].

Now in 2.6.7, i_shared_sem is gone and replaced by a i_mmap_lock,
what makes it impossible to use for this case as read_cache_page()
will sleep and so might wait_on_page_locked().

Then I realized I probably don't need to lock the struct 
address_space, but it strikes me as odd--it's a shared struct.
I need to maintain the address space in tight control while I am
accessing it. So the question is: what is the proper way? can't 
find any good examples in the kernel code that show it.

Thanks,

Inaky Perez-Gonzalez -- Not speaking for Intel -- all opinions are my own (and my fault)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
