Date: Thu, 19 Dec 2002 07:22:15 -0800
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: 2.5.52-mm2
Message-ID: <10930000.1040311334@titus>
In-Reply-To: <3E01A004.58F2B880@digeo.com>
References: <3E015ECE.9E3BD19@digeo.com>
 <20021219085426.GJ1922@holomorphy.com>
 <20021219092853.GK1922@holomorphy.com>
 <20021219101219.GS31800@holomorphy.com> <3E01A004.58F2B880@digeo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>, William Lee Irwin III <wli@holomorphy.com>
Cc: lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Actually, just looking at mmzone.h, I have to say "ick".  The
> non-NUMA case seems unnecessarily overdone.  eg:
>
># define page_to_pfn(page)
> 	((page - page_zone(page)->zone_mem_map) +
> page_zone(page)->zone_start_pfn)
>
> Ouch.  Why can't we have the good old `page - mem_map' here?

Ummm .... mmzone.h:

#ifdef CONFIG_DISCONTIGMEM
....
#define page_to_pfn(page)       ((page - page_zone(page)->zone_mem_map) + 
page_zone(page)->zone_start_pfn)
....
#endif /* CONFIG_DISCONTIGMEM */

page.h:

#ifndef CONFIG_DISCONTIGMEM
#define page_to_pfn(page)       ((unsigned long)((page) - mem_map))
#endif /* !CONFIG_DISCONTIGMEM */


I'll admit the file obfuscation hides this from being easy to read, but
i'm not stupid enough to screw things up *that* badly. Well, not most
of the time ;-) Want me to reshuffle things around so that the same defines
end up in the same file, and people have a hope in hell of reading it?
If I do that, it'll probably be based on the struct page breakout patch,
and making these things all static inlines, so people stop blowing their
own feet off.

M.

PS. cscope is cool ;-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
