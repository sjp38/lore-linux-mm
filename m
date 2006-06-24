Date: Sat, 24 Jun 2006 16:38:14 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC] Patch [3/4] x86_64 sparsmem add - acpi added pages are
 not reserved?
Message-Id: <20060624163814.a9032a49.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1151114763.7094.52.camel@keithlap>
References: <1151114763.7094.52.camel@keithlap>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kmannth@us.ibm.com
Cc: lhms-devel@lists.sourceforge.net, linux-mm@kvack.org, haveblue@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Fri, 23 Jun 2006 19:06:03 -0700
keith mannthey <kmannth@us.ibm.com> wrote:

>   The code is expecting the added but not on-lined code to be marked
> reserved. This isn't happening for my ACPI hot-add on x86_64. I am not
> sure who in this call path needs to reserve the pages or if the check
> for reserve is a valid with this new hot-add code.    
> 
> Any ideas?
> 
> Signed-off-by:  Keith Mannthey <kmannth@us.ibm.com>
> 
/*	if (action == MEM_ONLINE) {
 		for (i = 0; i < PAGES_PER_SECTION; i++) {
 			if (PageReserved(first_page+i))
 				continue;
@@ -176,6 +176,7 @@
 			return -EBUSY;
 		}
 	}
+*/
Pages are marked as Reserved before onlined. Then, all pages in the area
should be reserved.(and sparsemem allocates SECTION_SIZE aligned memmap.)
(see __add_zone() -> memmap_init_zone().)
newly initialized memmap are marked as reserved. 
Plz confirm your "currently unused memmap" is properly marked as reserved.

It's important to find "why" before doing this kind of workaround.

Hmm... at first, could you show your /proc/iomem before and after
hot-add event ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
