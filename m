Content-class: urn:content-classes:message
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
Subject: RE: Which is the proper way to bring in the backing store behindan inode as an struct page?
Date: Wed, 7 Jul 2004 19:15:40 -0700
Message-ID: <F989B1573A3A644BAB3920FBECA4D25AE7B904@orsmsx407>
From: "Perez-Gonzalez, Inaky" <inaky.perez-gonzalez@intel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ram Pai <linuxram@us.ibm.com>
Cc: "Chen, Kenneth W" <kenneth.w.chen@intel.com>, linux-mm@kvack.org, Dave Hansen <haveblue@us.ibm.com>
List-ID: <linux-mm.kvack.org>

> From: Ram Pai [mailto:linuxram@us.ibm.com]
>
> I would like at the logic of do_generic_mapping_read(). The code below
> is perhaps roughly what you want.

Thanks Ram.

I tried to create a function page_cache_readpage() that would do it
properly. Would you guys give it a look and give me some feedback?

The assumptions that have me more worried are:

 - on line 63, filp is always NULL [I checked a few usages of
   the readpage as_op and none use it--used Ram's hint on that].

 - the error paths, for example, for "error_unlock", #77, leaving
   the page in the LRU cache [is this ok? will somebody else
   use it or will it drop automatically?]

01 
02 /**
03  * Make sure we have a page in the page cache for the given inode and
04  * offset.
05  *
06  * @ppage: where to store the pointer to the page for (@inode,@pgoff)
07  * @inode: inode where to get the page from
08  * @pgoff: offset of the page in the inode
09  * @returns: 0 if ok and the page in *ppage, < 0 on error.
10  *
11  * This function is just a wrapper over the real actor,
12  * __page_cache_readpage().
13  *
14  * Once used, release the page with page_cache_release(). Thanks.
15  */
16 #warning FIXME: move to pagemap.h
17 static inline
18 int page_cache_readpage (struct page **ppage, struct inode *inode,
19                          unsigned long pgoff) 
20 {
21         int result;
22         do
23                 result = __page_cache_readpage (ppage, inode, pgoff);
24         while (result == -EAGAIN);
25         return result;
26 }
27 
28 /**
29  * Grunt for page_cache_readpage() that does the lower level task of
30  * briging a page to the page cache from an inode and a offset.
31  * 
32  * I have been savaging stuff from do_generic_mapping_read(), but I am
33  * afraid it is still not all that right.
34  */
35 int __page_cache_readpage (struct page **ppage, struct inode *inode,
36                            unsigned long pgoff)
37 {
38         int result = -ENOMEM;
39         struct address_space *mapping = inode->i_mapping;
40         struct page *page;
41         
42         page = find_get_page (mapping, pgoff);
43         if (unlikely (page == NULL)) {
44                 page = page_cache_alloc_cold (mapping);
45                 if (!page)
46                         goto error_page_alloc;          
47                 if (add_to_page_cache_lru (page, mapping, pgoff, GFP_KERNEL))
48                         goto error_add_page;
49                 page_cache_get (page);
50         }
51         if (PageUptodate (page))
52                 goto out;
53         /* Need to update the page--has to be done with it locked */
54         lock_page (page);
55         result = -EAGAIN;
56         if (!page->mapping)        /* Was it unhashed before we got the lock? */
57                 goto error_unlock;      
58         if (PageUptodate (page)) { /* Was it updated before we got the lock? */
59                 unlock_page (page);
60                 goto out;
61         }
62         /* Need to read the page -- it will unlock the page */
63         result = mapping->a_ops->readpage (NULL, page);
64         if (result != 0)
65                 goto error_release;     
66         if (!PageUptodate (page))
67                 wait_on_page_locked (page);
68         result = -EIO;
69         if (!PageUptodate (page))
70                 goto error_release;
71 out:
72         return 0;
73 
74         /* In case of error at this point, we leave the page at the
75          * cache, so the retry can pick it up without having to
76          * reallocate. */
77 error_unlock:
78         unlock_page (page);
79 error_release:
80         page_cache_release (page);
81         return result;
82         
83 error_add_page:
84         __free_page (page);
85 error_page_alloc:
86         return result;
87 }
88 
89 EXPORT_SYMBOL_GPL (__page_cache_readpage);

Inaky Perez-Gonzalez -- Not speaking for Intel -- all opinions are my own (and my fault)
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
