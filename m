Received: from indyio.rz.uni-sb.de (indyio.rz.uni-sb.de [134.96.7.3])
	by kvack.org (8.8.7/8.8.7) with ESMTP id GAA31416
	for <linux-mm@kvack.org>; Wed, 12 May 1999 06:30:51 -0400
Message-ID: <003f01be9c62$75765550$c80c17ac@clmsdev.local>
From: "Manfred Spraul" <masp0008@stud.uni-sb.de>
Subject: Re: Swap Questions (includes possible bug) - swapfile.c / swap.c
Date: Wed, 12 May 1999 12:30:27 +0200
MIME-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@nl.linux.org>, Joseph Pranevich <knight@baltimore.wwaves.com>
Cc: Linux Kernel <linux-kernel@vger.rutgers.edu>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

>On Tue, 11 May 1999, Joseph Pranevich wrote:
> case 2:
>  error = -EINVAL;
>  if (swap_header->info.nr_badpages > MAX_SWAP_BADPAGES)
>  goto bad_swap;

MAX_SWAP_BADPAGES is a limitation of the swap format 2,
it's not a kernel limitation. (check include/linux/swap.h)
 
Rik wrote:
>On Tue, 11 May 1999, Joseph Pranevich wrote:
>> set_blocksize(p->swap_device, PAGE_SIZE);
>
>Hmm, haven't we seen this one before? Stephen?


There is another problem with this line:
set_blocksize() also means that the previous block size
doesn't work anymore:
if you accidentially enter 'swapon /dev/hda1' (my root drive)
instead of 'swapon /dev/hda3', then you have to fsck:
sys_swapon sets the blocksize, then it rejects the call
because there is no swap signature, but now ext2
can't access the partition (blocksize 4096, ext2 needs 1024).

I've posted a patch a few weeks ago, but I received no reply.

Are such problems ignored? (The super user can crash the
machine at will, one more crash doesn't matter)

Regards,
    Manfred

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
