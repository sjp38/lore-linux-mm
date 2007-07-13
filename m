Date: Fri, 13 Jul 2007 16:17:32 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 3/7] Generic Virtual Memmap support for SPARSEMEM
In-Reply-To: <20070714081210.1440db40.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0707131612530.26795@schroedinger.engr.sgi.com>
References: <exportbomb.1184333503@pinky> <E1I9LJY-00006o-GK@hellhawk.shadowen.org>
 <20070713235121.538ddcaf.kamezawa.hiroyu@jp.fujitsu.com>
 <Pine.LNX.4.64.0707131541540.26109@schroedinger.engr.sgi.com>
 <20070714081210.1440db40.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: apw@shadowen.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, npiggin@suse.de, mel@csn.ul.ie
List-ID: <linux-mm.kvack.org>

On Sat, 14 Jul 2007, KAMEZAWA Hiroyuki wrote:

> Just because this patch takes care of boot path. Maybe small problem.

Ahh. I just looked at it. Yes we did not modify the hotplug path. It needs
to call the new vmemmap alloc functions.

> Basically, I welcome this patch. I like this.

Yes you proposed the initial version of this last year. Thanks.

> If we can remove DISCONTIG+VMEMMAP after this is merged, we can say good-bye
> to terrible CONFIG_HOLES_IN_ZONE :)

Right. Horrible stuff. Lots of useless cachelines that have to be 
references in critical paths.

> Note
> >From memory hotplug development/enhancement view, I have following thinking now.
>  
>  1. memmap's section is *not* aligned to "big page size". We have to take care
>     of this at adding support for memory_hotplug/unplug.

You can call the functions for virtual memmap allocation directly. They 
are already generic and will call the page allocator instead of the 
bootmem allocator if the system is already. They will give you the 
properly aligned memory. Perhaps you can just change a few lines 
in sparse_add_one_section to call the vmemmap functions instead?

>  2. With an appropriate patch, we can allocate new section's memmap from
>     itself. This will reduce possibility of memory hotplug failure becasue of
>     large size kmalloc/vmalloc. And it guarantees locality of memmap.
>     But maybe need some amount of work for implementing this in clean way.
>     This will depend on vmemmap.

That is a good idea. Maybe do the simple approach first and then the other 
one?

> 
>  3. removin memmap code for memory unplug will be necessary. But there is no code
>     for removing memmap in usual SPARSEMEM. So this is not real problem of vmemmap
>     now. 

Right. It would have to be added later anyways.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
