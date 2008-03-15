Date: Sat, 15 Mar 2008 13:12:21 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: Re: [PATCH 3/3 (RFC)](memory hotplug) align maps for easy removing
In-Reply-To: <86802c440803140926n2ec2bd2fscf0f3e9a6e2e4d2e@mail.gmail.com>
References: <20080314234205.20DD.E1E9C6FF@jp.fujitsu.com> <86802c440803140926n2ec2bd2fscf0f3e9a6e2e4d2e@mail.gmail.com>
Message-Id: <20080315121118.E4BC.E1E9C6FF@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yinghai Lu <yhlu.kernel@gmail.com>
Cc: Badari Pulavarty <pbadari@us.ibm.com>, Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

> >  Index: current/mm/sparse.c
> >  ===================================================================
> >  --- current.orig/mm/sparse.c    2008-03-11 20:15:41.000000000 +0900
> >  +++ current/mm/sparse.c 2008-03-11 20:58:18.000000000 +0900
> >  @@ -244,7 +244,8 @@
> >         struct mem_section *ms = __nr_to_section(pnum);
> >         int nid = sparse_early_nid(ms);
> >
> >  -       usemap = alloc_bootmem_node(NODE_DATA(nid), usemap_size());
> >  +       usemap = alloc_bootmem_pages_node(NODE_DATA(nid),
> >  +                                         PAGE_ALIGN(usemap_size()));
> 
> if we allocate usemap continuously,
> old way could make different usermap share one page. usermap size is
> only about 24bytes. align to 128bytes ( the SMP cache lines)
> 
> sparse_early_usemap_alloc: usemap = ffff810024e00000 size = 24
> sparse_early_usemap_alloc: usemap = ffff810024e00080 size = 24
> sparse_early_usemap_alloc: usemap = ffff810024e00100 size = 24
> sparse_early_usemap_alloc: usemap = ffff810024e00180 size = 24


Yes, they can share one page. 

I was afraid its page will be hard to remove yesterday.
If all sections' usemaps are allocated on section A,
the other sections (from B to Z) must be removed before section A.
If only one of them are busy, section A can't be removed.
So, I disliked its dependency.

But, I reconsidered it after reading your mail.
The node structures like pgdat has same feature.
If a section has pgdat for the node, it must wait for other section's
removing on the node. So, I'll try to keep same section about pgdat
and shared usemap page.

Anyway, thanks for your comments. 

Bye.

-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
