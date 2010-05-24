Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 460226B01B0
	for <linux-mm@kvack.org>; Mon, 24 May 2010 07:24:40 -0400 (EDT)
Message-ID: <4BFA61F4.1010203@cesarb.net>
Date: Mon, 24 May 2010 08:24:36 -0300
From: Cesar Eduardo Barros <cesarb@cesarb.net>
MIME-Version: 1.0
Subject: Re: [PATCH 3/3] mm: Swap checksum
References: <4BF81D87.6010506@cesarb.net> <1274551731-4534-3-git-send-email-cesarb@cesarb.net> <4BF94792.5030405@redhat.com> <4BF97AC2.1040505@cesarb.net> <4BFA1F92.2080802@redhat.com>
In-Reply-To: <4BFA1F92.2080802@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Em 24-05-2010 03:41, Avi Kivity escreveu:
> On 05/23/2010 09:58 PM, Cesar Eduardo Barros wrote:
>> One possibility could be to compare the full page against zero only if
>> its crc is a specific value (the crc32c of a page full of zeros). This
>> would not be too slow (we would be wasting time only when we have a
>> very high probability of saving much more time), and not need to touch
>> the crc32c code at all. I would only have to look at how this messes
>> up the state tracking (i.e. how to make it track the fact that,
>> instead of getting written out, this is now a zeroed page).
>
> Instead of returning a swap pte to be written to the page tables, return
> a zeroed pte.

Unfortunately, at this point in the code (swap_writepage) it is not a 
matter of simply returning a zeroed pte; it would have to go looking for 
the page tables.

If I am understanding things correctly, in some situations even looking 
for them via the struct page I have and its rmap stuff is not enough; 
you could have a pte still pointing to the swap instead of pointing to 
the page (which when faulted would go via the swap cache to get the page).

For instance, if the page was shared between several processes, got 
swapped out, swapped in but accessed only by some of the processes, and 
in the process of being swapped out again.

-- 
Cesar Eduardo Barros
cesarb@cesarb.net
cesar.barros@gmail.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
