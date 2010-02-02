Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 0AA956B0093
	for <linux-mm@kvack.org>; Tue,  2 Feb 2010 14:18:22 -0500 (EST)
Date: Tue, 2 Feb 2010 11:14:00 -0800 (PST)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH 10/11] readahead: dont do start-of-file readahead after
 lseek()
In-Reply-To: <20100202184831.GD75577@dspnet.fr.eu.org>
Message-ID: <alpine.LFD.2.00.1002021111240.3664@localhost.localdomain>
References: <20100202152835.683907822@intel.com> <20100202153317.644170708@intel.com> <20100202181321.GB75577@dspnet.fr.eu.org> <alpine.LFD.2.00.1002021037110.3664@localhost.localdomain> <20100202184831.GD75577@dspnet.fr.eu.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Olivier Galibert <galibert@pobox.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <jens.axboe@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>



On Tue, 2 Feb 2010, Olivier Galibert wrote:
>
> On Tue, Feb 02, 2010 at 10:40:41AM -0800, Linus Torvalds wrote:
> > IOW, if you start off with a SEEK_END, I think it's reasonable to expect 
> > it to _not_ read the whole thing.
> 
> I've seen a lot of:
>   int fd = open(...);
>   size = lseek(fd, 0, SEEK_END);
>   lseek(fd, 0, SEEK_SET);
> 
>   data = malloc(size);
>   read(fd, data, size);
>   close(fd);
> 
> Why not fstat?  I don't know.

Well, the above will work perfectly with or without the patch, since it 
does the read of the full size. There is no read-ahead hint necessary for 
that kind of single read behavior.

Rememebr: read-ahead is about filling the empty IO spaces _between_ reads, 
and turning many smaller reads into one bigger one. If you only have a 
single big read, read-ahead cannot help.

Also, keep in mind that read-ahead is not always a win. It can be a huge 
loss too. Which is why we have _heuristics_. They fundamentally cannot 
catch every case, but what they aim for is to do a good job on average.

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
