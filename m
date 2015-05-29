From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v10 12/12] drivers/block/pmem: Map NVDIMM with
 ioremap_wt()
Date: Fri, 29 May 2015 11:11:30 +0200
Message-ID: <20150529091129.GC31435@pd.tnic>
References: <1432739944-22633-1-git-send-email-toshi.kani@hp.com>
 <1432739944-22633-13-git-send-email-toshi.kani@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1432739944-22633-13-git-send-email-toshi.kani@hp.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Toshi Kani <toshi.kani@hp.com>, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, akpm@linux-foundation.org, arnd@arndb.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, linux-nvdimm@lists.01.org, jgross@suse.com, stefan.bader@canonical.com, luto@amacapital.net, hmh@hmh.eng.br, yigal@plexistor.com, konrad.wilk@oracle.com, Elliott@hp.com, mcgrof@suse.com, hch@lst.de
List-Id: linux-mm.kvack.org

On Wed, May 27, 2015 at 09:19:04AM -0600, Toshi Kani wrote:
> The pmem driver maps NVDIMM with ioremap_nocache() as we cannot
> write back the contents of the CPU caches in case of a crash.
> 
> This patch changes to use ioremap_wt(), which provides uncached
> writes but cached reads, for improving read performance.
> 
> Signed-off-by: Toshi Kani <toshi.kani@hp.com>
> ---
>  drivers/block/pmem.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/block/pmem.c b/drivers/block/pmem.c
> index eabf4a8..095dfaa 100644
> --- a/drivers/block/pmem.c
> +++ b/drivers/block/pmem.c
> @@ -139,11 +139,11 @@ static struct pmem_device *pmem_alloc(struct device *dev, struct resource *res)
>  	}
>  
>  	/*
> -	 * Map the memory as non-cachable, as we can't write back the contents
> +	 * Map the memory as write-through, as we can't write back the contents
>  	 * of the CPU caches in case of a crash.
>  	 */
>  	err = -ENOMEM;
> -	pmem->virt_addr = ioremap_nocache(pmem->phys_addr, pmem->size);
> +	pmem->virt_addr = ioremap_wt(pmem->phys_addr, pmem->size);
>  	if (!pmem->virt_addr)
>  		goto out_release_region;

Dan, Ross, what about this one?

ACK to pick it up as a temporary solution?

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.
--
