Date: Fri, 9 May 2008 15:39:10 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] memory_hotplug: always initialize pageblock bitmap.
Message-Id: <20080509153910.6b074a30.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080509060609.GB9840@osiris.boeblingen.de.ibm.com>
References: <20080509060609.GB9840@osiris.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andy Whitcroft <apw@shadowen.org>, Dave Hansen <haveblue@us.ibm.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 9 May 2008 08:06:09 +0200
Heiko Carstens <heiko.carstens@de.ibm.com> wrote:

> From: Heiko Carstens <heiko.carstens@de.ibm.com>
> 
> Trying to online a new memory section that was added via memory hotplug
> sometimes results in crashes when the new pages are added via
> __free_page. Reason for that is that the pageblock bitmap isn't
> initialized and hence contains random stuff.

Hmm, curious. In my understanding, memmap_init_zone() initializes it.

 __add_pages()
	-> __add_section()
		-> sparse-add_one_section() // allocate usemap
		-> __add_zone()
			-> memmap_init_zone() // reset pageblock's bitmap 

Can't memmap_init_zone() does proper initialization ?
........................
Ah, ok. I see. grow_zone_span() is not called at __add_zone(), then,
memmap_init_zone() doesn't initialize usemap because memmap is not in zone's
range.

Recently, I added a check "zone's start_pfn < pfn < zone's end"
to memmap_init_zone()'s usemap initialization for !SPARSEMEM case bug FIX.
(and I think the fix itself is sane.)

How about calling grow_pgdat_span()/grow_zone_span() from __add_zone() ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
