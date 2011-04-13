Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id AA12D900086
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 11:30:20 -0400 (EDT)
Received: by bwz17 with SMTP id 17so1004874bwz.14
        for <linux-mm@kvack.org>; Wed, 13 Apr 2011 08:30:17 -0700 (PDT)
Content-Type: text/plain; charset=utf-8; format=flowed; delsp=yes
Subject: Re: Regarding memory fragmentation using malloc....
References: <112566.51053.qm@web162019.mail.bf1.yahoo.com>
Date: Wed, 13 Apr 2011 17:25:08 +0200
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
From: "Michal Nazarewicz" <mina86@mina86.com>
Message-ID: <op.vtvuf5sk3l0zgt@mnazarewicz-glaptop>
In-Reply-To: <112566.51053.qm@web162019.mail.bf1.yahoo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?utf-8?Q?Am=C3=A9rico_Wang?= <xiyou.wangcong@gmail.com>, Pintu Agarwal <pintu_agarwal@yahoo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Eric Dumazet <eric.dumazet@gmail.com>, Changli Gao <xiaosuo@gmail.com>, Jiri Slaby <jslaby@suse.cz>, azurIt <azurit@pobox.sk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Jiri Slaby <jirislaby@gmail.com>

On Wed, 13 Apr 2011 15:56:00 +0200, Pintu Agarwal  
<pintu_agarwal@yahoo.com> wrote:
> My requirement is, I wanted to measure memory fragmentation level in  
> linux kernel2.6.29 (ARM cortex A8 without swap).
> How can I measure fragmentation level(percentage) from /proc/buddyinfo ?

[...]

> In my linux2.6.29 ARM machine, the initial /proc/buddyinfo shows the  
> following:
> Node 0, zone      DMA     17     22      1      1      0      1       
> 1      0      0      0      0      0
> Node 1, zone      DMA     15    320    423    225     97     26       
> 1      0      0      0      0      0
>
> After running my sample program (with 16 iterations) the buddyinfo  
> output is as follows:
> Requesting <16> blocks of memory of block size <262144>........
> Node 0, zone      DMA     17     22      1      1      0      1       
> 1      0      0      0      0      0
> Node 1, zone      DMA     15    301    419    224     96     27       
> 1      0      0      0      0      0
>     nr_free_pages 169
>     nr_free_pages 6545
> *****************************************
>
>
> Node 0, zone      DMA     17     22      1      1      0      1       
> 1      0      0      0      0      0
> Node 1, zone      DMA     18      2    305    226     96     27       
> 1      0      0      0      0      0
>     nr_free_pages 169
>     nr_free_pages 5514
> -----------------------------------------
>
> The requested block size is 64 pages (2^6) for each block.
> But if we see the output after 16 iterations the buddyinfo allocates  
> pages only from Node 1 , (2^0, 2^1, 2^2, 2^3).
> But the actual allocation should happen from (2^6) block in buddyinfo.

No.  When you call malloc() only virtual address space is allocated.  The
actual allocation of physical space occurs when user space accesses the
memory (either reads or writes) and it happens page at a time.

As a matter of fact, if you have limited number of 0-order pages and
allocates in user space block of 64 pages later accessing the memory,
what really happens is that kernel allocates the 0-order pages and when
it runs out of those, splits a 1-order page into two 0-order pages and
takes one of those.

Because of MMU, fragmentation of physical memory is not an issue for
normal user space programs.

It becomes an issue once you deal with hardware that does not have MMU
nor support for scatter-getter DMA or with some big kernel structures.

/proc/buddyinfo tells you how many free pages of given order there are
in the system.  You may interpret it in such a way that the bigger number
of the low order pages the bigger fragmentation of physical memory.  If
there was no fragmentation (for some definition of the term) you'd get only
the highest order pages and at most one page for each lower order.

Again though, this fragmentation is not an issue for user space programs.

-- 
Best regards,                                         _     _
.o. | Liege of Serenely Enlightened Majesty of      o' \,=./ `o
..o | Computer Science,  Michal "mina86" Nazarewicz    (o o)
ooo +-----<email/xmpp: mnazarewicz@google.com>-----ooO--(_)--Ooo--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
