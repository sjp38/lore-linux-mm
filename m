Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id EF67D6B0062
	for <linux-mm@kvack.org>; Mon,  7 Jan 2013 17:31:33 -0500 (EST)
Message-ID: <50EB4CB9.9010104@zytor.com>
Date: Mon, 07 Jan 2013 14:31:21 -0800
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [RFC]x86: clearing access bit don't flush tlb
References: <20130107081213.GA21779@kernel.org> <50EAE66B.1020804@redhat.com>
In-Reply-To: <50EAE66B.1020804@redhat.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Shaohua Li <shli@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, mingo@redhat.com

On 01/07/2013 07:14 AM, Rik van Riel wrote:
> On 01/07/2013 03:12 AM, Shaohua Li wrote:
>>
>> We use access bit to age a page at page reclaim. When clearing pte
>> access bit,
>> we could skip tlb flush for the virtual address. The side effect is if
>> the pte
>> is in tlb and pte access bit is unset, when cpu access the page again,
>> cpu will
>> not set pte's access bit. So next time page reclaim can reclaim hot pages
>> wrongly, but this doesn't corrupt anything. And according to intel
>> manual, tlb
>> has less than 1k entries, which coverers < 4M memory. In today's system,
>> several giga byte memory is normal. After page reclaim clears pte
>> access bit
>> and before cpu access the page again, it's quite unlikely this page's
>> pte is
>> still in TLB. Skiping the tlb flush for this case sounds ok to me.
> 
> Agreed. In current systems, it can take a minute to write
> all of memory to disk, while context switch (natural TLB
> flush) times are in the dozens-of-millisecond timeframes.
> 

I'm confused.  We used to do this since time immemorial, so if we aren't
doing that now, that meant something changed somewhere along the line.
It would be good to figure out if that was an intentional change or
accidental.

	-hpa


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
