Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 0BA6C8D0040
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 00:57:54 -0400 (EDT)
Message-ID: <4D940985.7020609@snapgear.com>
Date: Thu, 31 Mar 2011 14:56:37 +1000
From: Greg Ungerer <gerg@snapgear.com>
MIME-Version: 1.0
Subject: Re: [RFC/RFT 0/6] nommu: improve the vma list handling
References: <1301320607-7259-1-git-send-email-namhyung@gmail.com> <20110328150102.11bcfca8.akpm@linux-foundation.org>
In-Reply-To: <20110328150102.11bcfca8.akpm@linux-foundation.org>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Namhyung Kim <namhyung@gmail.com>, Paul Mundt <lethal@linux-sh.org>, David Howells <dhowells@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 29/03/11 08:01, Andrew Morton wrote:
> On Mon, 28 Mar 2011 22:56:41 +0900
> Namhyung Kim<namhyung@gmail.com>  wrote:
>
>> When I was reading nommu code, I found that it handles the vma list/tree in
>> an unusual way. IIUC, because there can be more than one identical/overrapped
>> vmas in the list/tree, it sorts the tree more strictly and does a linear
>> search on the tree. But it doesn't applied to the list (i.e. the list could
>> be constructed in a different order than the tree so that we can't use the
>> list when finding the first vma in that order).
>>
>> Since inserting/sorting a vma in the tree and link is done at the same time,
>> we can easily construct both of them in the same order. And linear searching
>> on the tree could be more costly than doing it on the list, it can be
>> converted to use the list.
>>
>> Also, after the commit 297c5eee3724 ("mm: make the vma list be doubly linked")
>> made the list be doubly linked, there were a couple of code need to be fixed
>> to construct the list properly.
>>
>> Patch 1/6 is a preparation. It maintains the list sorted same as the tree and
>> construct doubly-linked list properly. Patch 2/6 is a simple optimization for
>> the vma deletion. Patch 3/6 and 4/6 convert tree traversal to list traversal
>> and the rest are simple fixes and cleanups.
>>
>> Note that I don't have a system to test on, so these are *totally untested*
>> patches. There could be some basic errors in the code. In that case, please
>> kindly let me know. :)
>>
>> Anyway, I just compiled them on my x86_64 desktop using this command:
>>
>>    make mm/nommu.o
>>
>> (Of course this required few of dirty-fixes to proceed)
>>
>> Also note that these are on top of v2.6.38.
>>
>> Any comments are welcome.
>
> That seems like a nice set of changes.  There isn't much I can do with
> them at this tims - hopefully some of the nommu people will be able to
> find time to review and test the patches.

That does seem like a nice set of changes. I have compiled and run
tested on my ColdFire non-mmu targets, and it looks good.

So for the whole series from me that is:

Acked-by: Greg Ungerer <gerg@uclinux>


> (Is there a way in which one can run a nommu kernel on a regular PC?  Under
> an emulator?)

There is some around. Though none I have used I could recommend
off hand. I have used Skyeye for emulating non-mmu ARM on a PC,
but the mainline kernel lacks a serial driver for console on that
(limiting its current usefullnedd quite a bit).

I ran the freely available ColdFire one many years ago, bu I haven't
tried it recently.

Regards
Greg


------------------------------------------------------------------------
Greg Ungerer  --  Principal Engineer        EMAIL:     gerg@snapgear.com
SnapGear Group, McAfee                      PHONE:       +61 7 3435 2888
8 Gardner Close                             FAX:         +61 7 3217 5323
Milton, QLD, 4064, Australia                WEB: http://www.SnapGear.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
