Subject: RE: Which is the proper way to bring in the backing store behind
	an inode as an struct page?
From: Ram Pai <linuxram@us.ibm.com>
In-Reply-To: <F989B1573A3A644BAB3920FBECA4D25A6EBEEE@orsmsx407>
References: <F989B1573A3A644BAB3920FBECA4D25A6EBEEE@orsmsx407>
Content-Type: text/plain; charset=UTF-8
Message-Id: <1088833923.727.84.camel@dyn319048bld.beaverton.ibm.com>
Mime-Version: 1.0
Date: 02 Jul 2004 22:52:04 -0700
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Perez-Gonzalez, Inaky" <inaky.perez-gonzalez@intel.com>
Cc: "Chen, Kenneth W" <kenneth.w.chen@intel.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2004-07-02 at 17:37, Perez-Gonzalez, Inaky wrote:
> Hi Ken
> 
> > From: Chen, Kenneth W [mailto:kenneth.w.chen@intel.com]
> > 
> > Perez-Gonzalez, Inaky wrote on Thursday, July 01, 2004 11:35 PM
> > > Dummy question that has been evading me for the last hours. Can you
> > > help? Please bear with me here, I am a little lost in how to deal
> > > with inodes and the cache.
> > >
> > > ....
> > >
> > > Thus, what I need is a way that given the pair (inode,pgoff)
> > > returns to me the 'struct page *' if the thing is cached in memory or
> > > pulls it up from swap/file into memory and gets me a 'struct page *'.
> > >
> > > Is there a way to do this?
> > 
> > find_get_page() might be the one you are looking for.
> 
> Something like this? [I am trying blindly]

> page = find_get_page (inode->i_mapping, pgoff)

I would like at the logic of do_generic_mapping_read(). The code below
is perhaps roughly what you want.

page = find_get_page(inode->i_mapping, pgoff);
if(unlikely(page==NULL)) {

	page = page_cache_alloc_cold(mapping);
	if (!page) {
                /* NO LUCK SORRY :-( */
        }

        if(add_to_page_cache_lru(page, mapping, pgoff, GFP_KERNEL)) {
                /* NO LUCK SORRY :-( */
        }
}
if (!PageUptodate(page)) { 
     lock_page(page);
     mapping->a_ops->readpage(filp /*i guess this can be null */,
			 page);
}
	
	


	

> 
> Under which circumstances will this fail? [I am guessing the only ones
> are if the page offset is out of the limits of the map]. What about 
> i_mapping? When is it not defined? [ie: NULL].
> 
> Thanks
> 
> IA+-aky PA(C)rez-GonzA!lez -- Not speaking for Intel -- all opinions are my own (and my fault)
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
