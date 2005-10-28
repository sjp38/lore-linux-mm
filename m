Received: by zproxy.gmail.com with SMTP id n29so477114nzf
        for <linux-mm@kvack.org>; Fri, 28 Oct 2005 09:33:57 -0700 (PDT)
Message-ID: <6934efce0510280933q20fe304cra10d7594c1104d20@mail.gmail.com>
Date: Fri, 28 Oct 2005 09:33:56 -0700
From: Jared Hulbert <jaredeh@gmail.com>
Subject: Re: Fwd: Re: VM_XIP Request for comments
In-Reply-To: <43621CFE.5080900@de.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
References: <200510281155.03466.christian@borntraeger.net>
	 <43621CFE.5080900@de.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: carsteno@de.ibm.com
Cc: Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, cotte@de.ibm.com
List-ID: <linux-mm.kvack.org>

On 10/28/05, Carsten Otte <cotte@de.ibm.com> wrote:
>  Jared Hulbert wrote:
> > I can't find CONFIG_XIP.  But I assume you are talking about
> > filemap_xip.c and Documentation/filesystems/xip.txt.
> Actually the thing consists of three parts:
> - a block device that does implement the direct_access method. so far
>   the only driver that does that is drivers/s390/block/dcssblk.c. We
>   are aware that this one needs cleanup ;-).
> - extension to good old ext2 filesystem that does implement get_xip_page
>   address space operation. Uses direct_access block device operation.
> - the stuff in mm/filemap_xip.c which actually does the job (read,write,
>   mmap etc.) by calling get_xip_page address space operation.
>
> > I don't know. The code and discussions about it looked very big-iron
> > DSCC specific but now on second pass it was meant to more generic.  If
> > I can learn this infrastructure then maybe this will work.
> The only part that is architecture specific is the block device driver.
> Both the ext2 extensions and filemap_xip are architecture independent.
>
> > So I'm supposed to create a function in the target fs that gets
> > plugged into get_xip_page().  Then I call that function to create an
> > proper XIP'ed page in my mmap() and fread() calls.  I could use the
> > first arg of get_xip_page() to pass in the start address of the cramfs
> > volume and the second the offset of the page in the file I want to
> > map.
> >
> > Is that about right?
> The first step would be to write a block device driver that allows to
> mount your memory backed storage thing [flash chip?]. The block device
> driver needs to implement the direct_access method. Now you can mount
> ext2 filesystems with -o xip.
>
> Ext2 does not support compression, and all files are xip once you
> select -o xip. Would be interresting to have a filesystem that can do
> both xip and compression on a per-file basis, but as far as I can tell
> the basic layering should also work fine with such filesystem: should
> work with any block device, file operations in filemap_xip.c can be
> used for those files that are xip [and not compressed].

I don't want to use EXT2.  I want to use linear cramfs (no block
device) or something brand new.  Under these circumstances I don't
need a block device driver right?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
