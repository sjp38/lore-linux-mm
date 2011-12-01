Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id F07036B008A
	for <linux-mm@kvack.org>; Thu,  1 Dec 2011 11:10:28 -0500 (EST)
Received: by bke17 with SMTP id 17so3219743bke.14
        for <linux-mm@kvack.org>; Thu, 01 Dec 2011 08:10:26 -0800 (PST)
Message-ID: <4ED7A6EF.1000705@the2masters.de>
Date: Thu, 01 Dec 2011 17:10:23 +0100
From: Stefan Hellermann <stefan@the2masters.de>
MIME-Version: 1.0
Subject: Re: flatmem broken for nommu? [Was: Re: does non-continuous RAM means
 I need to select the sparse memory model?]
References: <20111129203010.GA26618@pengutronix.de> <CAOMZO5DX_ZvCOu+pqZpJ7Ni2B=qmSFCZTHnuzKt==OsBsJZH=Q@mail.gmail.com> <20111201105718.GJ26618@pengutronix.de> <20111201153933.GL26618@pengutronix.de>
In-Reply-To: <20111201153933.GL26618@pengutronix.de>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?ISO-8859-1?Q?Uwe_Kleine-K=F6nig?= <u.kleine-koenig@pengutronix.de>
Cc: linux-mm@kvack.org, Yinghai Lu <yinghai@kernel.org>, akpm@linux-foundation.org, linux-arm-kernel@lists.infradead.org

Am 01.12.2011 16:39, schrieb Uwe Kleine-Konig:
> Hello,
> 
> On Thu, Dec 01, 2011 at 11:57:18AM +0100, Uwe Kleine-Konig wrote:
>> On Tue, Nov 29, 2011 at 10:39:10PM -0200, Fabio Estevam wrote:
>>> 2011/11/29 Uwe Kleine-Konig <u.kleine-koenig@pengutronix.de>:
>>>> Hello,
>>>>
>>>> I'm currently working on a new arch port and my current machine has RAM
>>>> at 0x10000000 and 0x80000000. So there is a big hole between the two
>>>> banks. When selecting the sparse memory model it works, but when
>>>> selecting flat the machine runs into a BUG in mark_bootmem() called by
>>>> free_unused_memmap() to free the space between the two banks.
>>>
>>> My understanding is that you have to select ARCH_HAS_HOLES_MEMORYMODEL.
>> I think that is not necessary.
>>  
>>>> Is that expected (meaning I cannot use the flat model)? I currently
>>>> don't have another machine handy that has >1 memory back to test that.
>>>
>>> In case you have access to a MX35PDK you can try on this board as it does have
>>> the memory hole.
>> No I havn't, but I just used a 128MB machine and changed that in the
>> .fixup callback to 64MB + 32MB with a 32MB hole in between and it works
>> fine without ARCH_HAS_HOLES_MEMORYMODEL.
>>
>> I debugged the problem a bit further and one symptom is that
>>
>> 	struct page *mem_map
>>
>> is NULL for me. That looks wrong. I guess this is just broken for nommu.
>> I will dig into that later today.
> The problem is that the memory for mem_map is allocated using:
> 
> 	map = alloc_bootmem_node_nopanic(pgdat, size);
> 
> without any error checking. The _nopanic was introduced by commit
> 
> 	8f389a99 (mm: use alloc_bootmem_node_nopanic() on really needed path)
> 
> I don't understand the commit's log and don't really see why it should
> be allowed to not panic if the allocation failes here but use a NULL
> pointer instead.
> I put the people involved in 8f389a99 on Cc, maybe someone can comment?
> 
> Apart from that it seems I cannot use flatmem as is on my machine. It
> has only 128kiB@0x10000000 + 1MiB@0x80000000 and needs 14MiB to hold the
> table of "struct page"s. :-(
> 
> Best regards
> Uwe
> 
The commit was made after an bug report from me. I have an old x86
tablet pc with only 8Mb Ram. This machine fails early on bootup without
this commit. I found an archived message of the bug report here:
http://comments.gmane.org/gmane.linux.kernel/1135909

Regards,
Stefan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
