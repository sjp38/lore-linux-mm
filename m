Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id D965D6B0098
	for <linux-mm@kvack.org>; Tue,  2 Feb 2010 13:41:23 -0500 (EST)
Date: Tue, 2 Feb 2010 10:40:41 -0800 (PST)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH 10/11] readahead: dont do start-of-file readahead after
 lseek()
In-Reply-To: <20100202181321.GB75577@dspnet.fr.eu.org>
Message-ID: <alpine.LFD.2.00.1002021037110.3664@localhost.localdomain>
References: <20100202152835.683907822@intel.com> <20100202153317.644170708@intel.com> <20100202181321.GB75577@dspnet.fr.eu.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Olivier Galibert <galibert@pobox.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <jens.axboe@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>



On Tue, 2 Feb 2010, Olivier Galibert wrote:
> 
> Wouldn't that trigger on lseeks to end of file to get the size?

Well, you'd only ever do that with a raw block device, no (if even that: 
more "raw block device" tools just use the BLKSIZE64 ioctl etc)? Any sane 
regular file accessor will do 'fstat()' instead.

And do we care about startup speed of ramping up read-ahead from the 
beginning? In fact, the problem case that caused this was literally 
'blkid' on a block device - and the fact that the kernel tried to 
read-ahead TOO MUCh rather than too little.

If somebody is really doing lots of serial reading, the read-ahead code 
will figure it out very quickly. The case this worries about is just the 
_first_ read, where the question is one of "do we think it might be 
seeking around, or does it look like the user is going to just read the 
whole thing"?

IOW, if you start off with a SEEK_END, I think it's reasonable to expect 
it to _not_ read the whole thing.

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
