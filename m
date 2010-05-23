Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0842F6B01B1
	for <linux-mm@kvack.org>; Sun, 23 May 2010 14:58:14 -0400 (EDT)
Message-ID: <4BF97AC2.1040505@cesarb.net>
Date: Sun, 23 May 2010 15:58:10 -0300
From: Cesar Eduardo Barros <cesarb@cesarb.net>
MIME-Version: 1.0
Subject: Re: [PATCH 3/3] mm: Swap checksum
References: <4BF81D87.6010506@cesarb.net> <1274551731-4534-3-git-send-email-cesarb@cesarb.net> <4BF94792.5030405@redhat.com>
In-Reply-To: <4BF94792.5030405@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Em 23-05-2010 12:19, Avi Kivity escreveu:
> On 64-bit, we may be able to store the checksum in the pte, if the swap
> device is small enough.

Which pte? Correct me if I am wrong, but I do not think all pages 
written to the swap have exactly one pte pointing to them. And I have 
not looked at the shmem.c code yet, but does it even use ptes?

It might be possible (find all ptes and write the 32-bit checksum to 
them, do something else for shmem, have two different code paths for 
small/large swapfiles), but I do not know if the memory savings are 
worth the extra complexity (especially the need for two separate code 
paths).

> If we take the trouble to touch the page, we may as well compare it
> against zero, and if so drop it instead of swapping it out.

The problem with this is that the page is touched deep inside the crc32c 
code, which might even be using hardware instructions (crc32c-intel). So 
we would need to read it two times to compare against zero.

One possibility could be to compare the full page against zero only if 
its crc is a specific value (the crc32c of a page full of zeros). This 
would not be too slow (we would be wasting time only when we have a very 
high probability of saving much more time), and not need to touch the 
crc32c code at all. I would only have to look at how this messes up the 
state tracking (i.e. how to make it track the fact that, instead of 
getting written out, this is now a zeroed page). Other than that, it 
seems a good idea.

-- 
Cesar Eduardo Barros
cesarb@cesarb.net
cesar.barros@gmail.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
