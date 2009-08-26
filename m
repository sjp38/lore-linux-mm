Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id DDDEC6B004F
	for <linux-mm@kvack.org>; Wed, 26 Aug 2009 14:17:08 -0400 (EDT)
Date: Wed, 26 Aug 2009 11:17:18 -0700 (PDT)
From: Vincent Li <macli@brc.ubc.ca>
Subject: Re: [PATCH] mm/vmscan: change generic_file_write() comment to
 do_sync_write()
In-Reply-To: <8acda98c0908260507s7b813292i54b2d782cbfaadfe@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.0908261110220.3689@kernelhack.brc.ubc.ca>
References: <8acda98c0908260507s7b813292i54b2d782cbfaadfe@mail.gmail.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="1384710402-1129779627-1251310639=:3689"
Sender: owner-linux-mm@kvack.org
To: Nikita Danilov <danilov@gmail.com>
Cc: Christoph Hellwig <hch@lst.de>, linux-mm@kvack.org, Vincent Li <macli@brc.ubc.ca>, Badari Pulavarty <pbadari@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--1384710402-1129779627-1251310639=:3689
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Wed, 26 Aug 2009, Nikita Danilov wrote:

> Vincent Li <macli@brc.ubc.ca> writes:
> 
> > On Wed, 26 Aug 2009, Christoph Hellwig wrote:
> >
> >> On Tue, Aug 25, 2009 at 03:18:08PM -0700, Vincent Li wrote:
> >> > Commit 543ade1fc9 (Streamline generic_file_* interfaces and filemap cleanups)
> >> > removed generic_file_write() in filemap. For consistency, change the comment in
> >> > vmscan pageout() to do_sync_write().
> >>
> >> I think the right replacement would be __generic_file_aio_write.  But
> >
> > There is no __generic_file_aio_write, but __generic_file_aio_write_nolock,
> > generic_file_aio_write and generic_file_aio_write_nolock.
> >
> > I read the commit 543ade1fc9, it seems it replaced all .write = generic_file_write to
> > .write = do_sync_write. I thought they are the same.
> >
> >> from a quick glance over the code don't have the slightest idea what it
> >> is referring to.
> >
> > I read the code  over and over again, still no clue about the comment :-(.
> 
> This comment is about (bdi == current->backing_dev_info) condition in may_write_to_queue(),
> checking against
> 
>     /* We can write back this queue in page reclaim */
>     current->backing_dev_info = mapping->backing_dev_info;
> 
> bit (that used to be?) in __generic_file_aio_write_nolock()
> 
> Thank you,
> Nikita.

Thank you for the explaintion!

	* If this process is currently in generic_file_write() against
	* this page's queue, we can perform writeback even if that
	* will block.

So my interpretation for the comment is that if the current process is 
already in __generic_file_aio_write against the page's queue, The page 
claim path code can still perfom writeback even if the __generic_file_aio_write 
will block. Am I right?


Vincent Li
Biomedical Research Center
University of British Columbia
--1384710402-1129779627-1251310639=:3689--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
