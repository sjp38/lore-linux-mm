Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id AAA06275
	for <linux-mm@kvack.org>; Tue, 26 Nov 2002 00:40:30 -0800 (PST)
Message-ID: <3DE3337C.5814C370@digeo.com>
Date: Tue, 26 Nov 2002 00:40:28 -0800
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: [PATCH] Really start using the page walking API
References: <20021124233449.F5263@nightmaster.csn.tu-chemnitz.de> <20021125131004.GA5725@bytesex.org>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Gerd Knorr <kraxel@bytesex.org>
Cc: Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>, Kai Makisara <Kai.Makisara@kolumbus.fi>, Douglas Gilbert <dougg@torque.net>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Gerd Knorr wrote:
> 
> ...
> videobuf_dma_pci_map():
>         lock pages for DMA      [videobuf_lock()]
>         build scatter list      [videobuf_pages_to_sg()]
>         pci_map_sg()
> 

There is no need to lock these pages.   None of the other direct-IO
code will lock them, and you don't need to either.

The pages are pinned in place via elevated ->count and that is
sufficient.

What you _do_ need to do is to run set_page_dirty() against each
page, before running page_cache_release().  This is only needed
for a read (writing to userspace memory) to tell the VM that the
contents of the page have been altered.

If you don't do this, the VM may steal the page away without writing
it anywhere, and it will be subsequently restored from swap, minus
the changes which are supposed to be there.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
