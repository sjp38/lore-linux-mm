From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14516.11124.729025.321352@dukat.scot.redhat.com>
Date: Wed, 23 Feb 2000 18:48:20 +0000 (GMT)
Subject: Re: mmap/munmap semantics
In-Reply-To: <Pine.LNX.4.10.10002221702370.20791-100000@linux14.zdv.uni-tuebingen.de>
References: <Pine.LNX.4.10.10002221702370.20791-100000@linux14.zdv.uni-tuebingen.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Richard Guenther <richard.guenther@student.uni-tuebingen.de>
Cc: Linux Kernel List <linux-kernel@vger.rutgers.edu>, glame-devel@lists.sourceforge.net, Linux-MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, 22 Feb 2000 18:46:02 +0100 (MET), Richard Guenther
<richard.guenther@student.uni-tuebingen.de> said:

> With the ongoing development of GLAME there arise the following
> problems with the backing-store management, which is a mmaped
> file and does "userspace virtual memory management":
> - I cannot see a way to mmap a part of the file but set the
>   contents initially to zero, 

All file contents default to zero anyway, so just ftruncate() the file
to create as much demand-zeroed mmapable memory as you want.

> - I need to "drop" a mapping sometimes without writing the contents
>   back to disk - I cannot see a way to do this with linux currently.

The only way is to use Chuck Lever's madvise() patches:
madvise(MADV_DONTNEED) is exactly what you need there.  It's not yet in
Linus's 2.3 tree, but the API is pretty standard.

>   Ideally a hole could be created in the mmapped file on drop time -

No, if the mmaped area has already been flushed to disk then there is no
way at all to recreate the hole except by truncating and then
re-extending the file (which destroys everything until EOF, of course).


--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
