Received: by wr-out-0506.google.com with SMTP id c37so438789wra.26
        for <linux-mm@kvack.org>; Fri, 14 Mar 2008 09:26:08 -0700 (PDT)
Message-ID: <86802c440803140926n2ec2bd2fscf0f3e9a6e2e4d2e@mail.gmail.com>
Date: Fri, 14 Mar 2008 09:26:07 -0700
From: "Yinghai Lu" <yhlu.kernel@gmail.com>
Subject: Re: [PATCH 3/3 (RFC)](memory hotplug) align maps for easy removing
In-Reply-To: <20080314234205.20DD.E1E9C6FF@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080314231112.20D7.E1E9C6FF@jp.fujitsu.com>
	 <20080314234205.20DD.E1E9C6FF@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: Badari Pulavarty <pbadari@us.ibm.com>, Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

On Fri, Mar 14, 2008 at 7:44 AM, Yasunori Goto <y-goto@jp.fujitsu.com> wrote:
>
>  To free memmap and usemap easier, this patch aligns these maps to page size.
>
>  I know usemap size is too small to align page size.
>  It will be waste of area. So, there may be better way than this.
>
>  Followings are pros. and cons with other my ideas.
>  But I'm not sure which is better way.
>
>  a) Packing many section's usemap on one page. Count how many sections use
>    it in page_count.
>   Pros.
>     - Avoid waisting area.
>   Cons.
>     - This usemap's page will be hard(or impossible) to remove due to
>       dependency.
>       It should be allocated on un-movable zone/node.
>       (I'm not sure it's impact of performance.)
>     - Nodes' structures may have to be packed like usemap???
>
>  b) Pack memmap and usemap in one allocation.
>   Pros.
>     - May avoid wasting area if its size is suitable.
>   Cons.
>     - If size is not suitable, it will be same as this patch.
>     - This way is not good for VMEMMAP_SPARSEMEM.
>       At least, it is reverse way against Yinghai-san's fix.
>
>  c) This way.
>   Pros.
>     - Very easy to remove.
>   Cons.
>     - Waist of area.
>
>  Any other idea is welcome.
>
>
>  Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>
>
>  ---
>   mm/sparse.c |    7 ++++---
>   1 file changed, 4 insertions(+), 3 deletions(-)
>
>  Index: current/mm/sparse.c
>  ===================================================================
>  --- current.orig/mm/sparse.c    2008-03-11 20:15:41.000000000 +0900
>  +++ current/mm/sparse.c 2008-03-11 20:58:18.000000000 +0900
>  @@ -244,7 +244,8 @@
>         struct mem_section *ms = __nr_to_section(pnum);
>         int nid = sparse_early_nid(ms);
>
>  -       usemap = alloc_bootmem_node(NODE_DATA(nid), usemap_size());
>  +       usemap = alloc_bootmem_pages_node(NODE_DATA(nid),
>  +                                         PAGE_ALIGN(usemap_size()));

if we allocate usemap continuously,
old way could make different usermap share one page. usermap size is
only about 24bytes. align to 128bytes ( the SMP cache lines)

sparse_early_usemap_alloc: usemap = ffff810024e00000 size = 24
sparse_early_usemap_alloc: usemap = ffff810024e00080 size = 24
sparse_early_usemap_alloc: usemap = ffff810024e00100 size = 24
sparse_early_usemap_alloc: usemap = ffff810024e00180 size = 24


YH

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
