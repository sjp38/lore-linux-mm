From: Guo Ren <ren_guo-Y+KPrCd2zL4AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] mm: convert totalram_pages, totalhigh_pages and
 managed_pages to atomic.
Date: Thu, 22 Nov 2018 09:33:10 +0800
Message-ID: <20181122013310.GA20480@guoren-Inspiron-7460>
References: <1540229092-25207-1-git-send-email-arunks@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <linux-mediatek-bounces+glpam-linux-mediatek=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1540229092-25207-1-git-send-email-arunks-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-mediatek>,
 <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-mediatek/>
List-Post: <mailto:linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-mediatek>,
 <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: "Linux-mediatek" <linux-mediatek-bounces-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Errors-To: linux-mediatek-bounces+glpam-linux-mediatek=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: Arun KS <arunks-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Cc: Mike Snitzer <snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Benjamin Herrenschmidt <benh-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>, Kemi Wang <kemi.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, dri-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org, "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>, linux-sctp-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>, Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>, Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>, "K. Y. Srinivasan" <kys-0li6OtcxBFHby3iVrkZq2A@public.gmane.org>, Sumit Semwal <sumit.semwal-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, "David (ChunMing) Zhou" <David1.Zhou-5C7GfCeVMHo@public.gmane.org>, Petr Tesarik <ptesarik-IBi9RG/b67k@public.gmane.org>, Michael Ellerman <mpe-Gsx/Oe8HsFggBc27wqDAHg@public.gmane.org>, ceph-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, James Morris <jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org>, kasan-dev-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org, Marcos Paulo de Souza <marcos.souza.org-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, "Steven J. Hill" <steven.hill-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>, David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Anthony Yznaga <anthony.yznaga-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>, Daniel Vacek <neelx-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Roman Gushchin <guro-b10kYP2dOMg@public.gmane.org>, Len Brown <len.brown-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
List-Id: linux-mm.kvack.org

On Mon, Oct 22, 2018 at 10:53:22PM +0530, Arun KS wrote:
> Remove managed_page_count_lock spinlock and instead use atomic
> variables.
> 
> Suggested-by: Michal Hocko <mhocko-IBi9RG/b67k@public.gmane.org>
> Suggested-by: Vlastimil Babka <vbabka-AlSwsSmVLrQ@public.gmane.org>
> Signed-off-by: Arun KS <arunks-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
> 
> ---
> As discussed here,
> https://patchwork.kernel.org/patch/10627521/#22261253
> ---
> ---
>  arch/csky/mm/init.c                           |  4 +-
>  arch/powerpc/platforms/pseries/cmm.c          | 11 ++--
>  arch/s390/mm/init.c                           |  2 +-
>  arch/um/kernel/mem.c                          |  4 +-
>  arch/x86/kernel/cpu/microcode/core.c          |  5 +-
>  drivers/char/agp/backend.c                    |  4 +-
>  drivers/gpu/drm/amd/amdkfd/kfd_crat.c         |  2 +-
>  drivers/gpu/drm/i915/i915_gem.c               |  2 +-
>  drivers/gpu/drm/i915/selftests/i915_gem_gtt.c |  4 +-
>  drivers/hv/hv_balloon.c                       | 19 +++----
>  drivers/md/dm-bufio.c                         |  5 +-
>  drivers/md/dm-crypt.c                         |  4 +-
>  drivers/md/dm-integrity.c                     |  4 +-
>  drivers/md/dm-stats.c                         |  3 +-
>  drivers/media/platform/mtk-vpu/mtk_vpu.c      |  3 +-
>  drivers/misc/vmw_balloon.c                    |  2 +-
>  drivers/parisc/ccio-dma.c                     |  5 +-
>  drivers/parisc/sba_iommu.c                    |  5 +-
>  drivers/staging/android/ion/ion_system_heap.c |  2 +-
>  drivers/xen/xen-selfballoon.c                 |  7 +--
>  fs/ceph/super.h                               |  3 +-
>  fs/file_table.c                               |  9 ++--
>  fs/fuse/inode.c                               |  4 +-
>  fs/nfs/write.c                                |  3 +-
>  fs/nfsd/nfscache.c                            |  3 +-
>  fs/ntfs/malloc.h                              |  2 +-
>  fs/proc/base.c                                |  3 +-
>  include/linux/highmem.h                       |  2 +-
>  include/linux/mm.h                            |  2 +-
>  include/linux/mmzone.h                        | 10 +---
>  include/linux/swap.h                          |  2 +-
>  kernel/fork.c                                 |  6 +--
>  kernel/kexec_core.c                           |  5 +-
>  kernel/power/snapshot.c                       |  2 +-
>  lib/show_mem.c                                |  3 +-
>  mm/highmem.c                                  |  2 +-
>  mm/huge_memory.c                              |  2 +-
>  mm/kasan/quarantine.c                         |  4 +-
>  mm/memblock.c                                 |  6 +--
>  mm/memory_hotplug.c                           |  4 +-
>  mm/mm_init.c                                  |  3 +-
>  mm/oom_kill.c                                 |  2 +-
>  mm/page_alloc.c                               | 75 ++++++++++++++-------------
>  mm/shmem.c                                    | 12 +++--
>  mm/slab.c                                     |  3 +-
>  mm/swap.c                                     |  3 +-
>  mm/util.c                                     |  2 +-
>  mm/vmalloc.c                                  |  4 +-
>  mm/vmstat.c                                   |  4 +-
>  mm/workingset.c                               |  2 +-
>  mm/zswap.c                                    |  2 +-
>  net/dccp/proto.c                              |  6 +--
>  net/decnet/dn_route.c                         |  2 +-
>  net/ipv4/tcp_metrics.c                        |  2 +-
>  net/netfilter/nf_conntrack_core.c             |  6 +--
>  net/netfilter/xt_hashlimit.c                  |  4 +-
>  net/sctp/protocol.c                           |  6 +--
>  security/integrity/ima/ima_kexec.c            |  2 +-
>  58 files changed, 171 insertions(+), 143 deletions(-)
> 
> diff --git a/arch/csky/mm/init.c b/arch/csky/mm/init.c
> index dc07c07..3f4d35e 100644
> --- a/arch/csky/mm/init.c
> +++ b/arch/csky/mm/init.c
> @@ -71,7 +71,7 @@ void free_initrd_mem(unsigned long start, unsigned long end)
>  		ClearPageReserved(virt_to_page(start));
>  		init_page_count(virt_to_page(start));
>  		free_page(start);
> -		totalram_pages++;
> +		atomic_long_inc(&totalram_pages);
>  	}
>  }
>  #endif
> @@ -88,7 +88,7 @@ void free_initmem(void)
>  		ClearPageReserved(virt_to_page(addr));
>  		init_page_count(virt_to_page(addr));
>  		free_page(addr);
> -		totalram_pages++;
> +		atomic_long_inc(&totalram_pages);
>  		addr += PAGE_SIZE;
>  	}
For csky part, it's OK.

 Guo Ren
