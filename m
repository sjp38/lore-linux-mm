Subject: RE: Which is the proper way to bring in the backing store behindan
	inode as an struct page?
From: Ram Pai <linuxram@us.ibm.com>
In-Reply-To: <F989B1573A3A644BAB3920FBECA4D25AE7B904@orsmsx407>
References: <F989B1573A3A644BAB3920FBECA4D25AE7B904@orsmsx407>
Content-Type: text/plain
Message-Id: <1089330999.4957.36.camel@dyn319048bld.beaverton.ibm.com>
Mime-Version: 1.0
Date: 08 Jul 2004 16:56:40 -0700
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Perez-Gonzalez, Inaky" <inaky.perez-gonzalez@intel.com>
Cc: "Chen, Kenneth W" <kenneth.w.chen@intel.com>, linux-mm@kvack.org, Dave Hansen <haveblue@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2004-07-07 at 19:15, Perez-Gonzalez, Inaky wrote:
> > From: Ram Pai [mailto:linuxram@us.ibm.com]
> >
> > I would like at the logic of do_generic_mapping_read(). The code below
> > is perhaps roughly what you want.
> 
> Thanks Ram.
> 
> I tried to create a function page_cache_readpage() that would do it
> properly. Would you guys give it a look and give me some feedback?
> 
> The assumptions that have me more worried are:
> 
>  - on line 63, filp is always NULL [I checked a few usages of
>    the readpage as_op and none use it--used Ram's hint on that].

I dont' see why any of the readpage() methods need the filp information.
A quick scan shows that  zisofs_readpage() deferences filp.
zisofs_readpage() uses the filp to get to the inode, which it can always
get through  page->mapping->host 

 

> 
>  - the error paths, for example, for "error_unlock", #77, leaving
>    the page in the LRU cache [is this ok? will somebody else
>    use it or will it drop automatically?]

page_cache_release() takes care of that. So this should be ok. 


RP

 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
