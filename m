Date: Sat, 12 Aug 2000 11:18:12 +0200 (MET DST)
From: Bjorn Wesen <bjorn@sparta.lu.se>
Subject: Re: pte_pagenr/MAP_NR deleted in pre6
In-Reply-To: <3994141A.D98D6DE@augan.com>
Message-ID: <Pine.LNX.3.96.1000812105919.30982B-100000@medusa.sparta.lu.se>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Roman Zippel <roman@augan.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

On Fri, 11 Aug 2000, Roman Zippel wrote:
> The problem here is that the relation between virtual address / physical
> address / page struct / memmap+index is hardly documented and it gets
> more interesting when a page struct might also represent an i/o area

Amen to that - I'm doing a 2.4 port currently and our architecture has all
DRAM at a pseudo-physical address 0xc0000000. Figuring out how to not make
mem_map start at 0 and waste a lot of struct page's to cover everything up
to 0xc0000000 and beyond, and what the __pa/__va things should do wrgds to
the pseudo-0xc0000000 took some hours of groping around the archs and
bootmem/zone code :) then it suddenly worked.. and like, "wow, don't touch
it again!" :) 

(luckily I found a comment in mm/numa.c about exactly that and that m68k
and arm used it - you could never have been led to believe that looking
through the non-commented source :) 

The relationships between virtual/logical/physical etc. can be extremely
confusing - our CPU has physical DRAM at 0x40000000 but it is segmented
into 0xc0000000 in kernel-mode, while the paged virtual memory is at 0.
Heh. Fortunately the 0x40000000 business can be largely ignored since it
is only visible inside the TLB - for all other purposes the DRAM is at
0xc... 

So what I ended up doing was to make __pa/__va convert between 0xc.. and
0x4.., put PAGE_OFFSET == 0xc.., max/min_low_pfn's at 0xc..., mem_map
indexes start at 0 (corresponding to 0xc).. seems to work so far :) 

It does not help of course that all archs do the bootmem and zone
initialization in their own ways :) 

-Bjorn


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
