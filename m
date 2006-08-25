Date: Fri, 25 Aug 2006 16:56:59 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: ZVC: Support NR_SLAB_RECLAIM
Message-Id: <20060825165659.0d8c03d4.akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.64.0608251500560.11154@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0608251500560.11154@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: npiggin@suse.de, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 25 Aug 2006 15:16:19 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

> Remove the atomic counter for slab_reclaim_pages and replace
> with a ZVC counter. NR_SLAB will now only count the
> unreclaimable slab pages whereas NR_SLAB_RECLAIM will count
> the reclaimable slab pages.

That's misleading.  We should rename NR_SLAB to NR_SLAB_UNRECLAIMABLE.  And
NR_SLAB_RECLAIM should be NR_SLAB_RECLAIMABLE, no?

Naming matters.

> --- linux-2.6.18-rc4-mm2.orig/drivers/base/node.c	2006-08-23 12:36:56.875425210 -0700
> +++ linux-2.6.18-rc4-mm2/drivers/base/node.c	2006-08-25 14:42:05.130443045 -0700
> @@ -68,7 +68,8 @@ static ssize_t node_read_meminfo(struct 
>  		       "Node %d PageTables:   %8lu kB\n"
>  		       "Node %d NFS Unstable: %8lu kB\n"
>  		       "Node %d Bounce:       %8lu kB\n"
> -		       "Node %d Slab:         %8lu kB\n",
> +		       "Node %d SlabUnrecl:   %8lu kB\n"
> +		       "Node %d SlabReclaim:  %8lu kB\n",
>  		       nid, K(i.totalram),
>  		       nid, K(i.freeram),
>  		       nid, K(i.totalram - i.freeram),
> @@ -88,7 +89,8 @@ static ssize_t node_read_meminfo(struct 
>  		       nid, K(node_page_state(nid, NR_PAGETABLE)),
>  		       nid, K(node_page_state(nid, NR_UNSTABLE_NFS)),
>  		       nid, K(node_page_state(nid, NR_BOUNCE)),
> -		       nid, K(node_page_state(nid, NR_SLAB)));
> +		       nid, K(node_page_state(nid, NR_SLAB)),
> +		       nid, K(node_page_state(nid, NR_SLAB_RECLAIM)));
>  	n += hugetlb_report_node_meminfo(nid, buf + n);
>  	return n;

That breaks anything which uses the Slab: field.  OK, so it's NUMA geeks
only.  But still..


> Index: linux-2.6.18-rc4-mm2/fs/proc/proc_misc.c
> ===================================================================
> --- linux-2.6.18-rc4-mm2.orig/fs/proc/proc_misc.c	2006-08-23 12:36:59.772706994 -0700
> +++ linux-2.6.18-rc4-mm2/fs/proc/proc_misc.c	2006-08-25 14:23:03.848552529 -0700
> @@ -170,7 +170,8 @@ static int meminfo_read_proc(char *page,
>  		"Writeback:    %8lu kB\n"
>  		"AnonPages:    %8lu kB\n"
>  		"Mapped:       %8lu kB\n"
> -		"Slab:         %8lu kB\n"
> +		"SlabUnrecl:   %8lu kB\n"
> +		"SlabReclaim:  %8lu kB\n"
>  		"PageTables:   %8lu kB\n"
>  		"NFS Unstable: %8lu kB\n"
>  		"Bounce:       %8lu kB\n"
> @@ -199,6 +200,7 @@ static int meminfo_read_proc(char *page,
>  		K(global_page_state(NR_ANON_PAGES)),
>  		K(global_page_state(NR_FILE_MAPPED)),
>  		K(global_page_state(NR_SLAB)),
> +		K(global_page_state(NR_SLAB_RECLAIM)),
>  		K(global_page_state(NR_PAGETABLE)),
>  		K(global_page_state(NR_UNSTABLE_NFS)),
>  		K(global_page_state(NR_BOUNCE)),

But surely there are tools out there which look at /proc/meminfo:Slab:.  We
cannot just go and breezily break them.

We can add new fields though, so let's just have Slab:, SlabUnrecl: (ug)
and SlabReclaim: (ug).

I'll drop zone_reclaim-dynamic-zone-based-slab-reclaim.patch due to churn here.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
