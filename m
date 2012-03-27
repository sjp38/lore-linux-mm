Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id AC72A6B00FD
	for <linux-mm@kvack.org>; Tue, 27 Mar 2012 11:57:08 -0400 (EDT)
Received: by ghrr18 with SMTP id r18so89011ghr.14
        for <linux-mm@kvack.org>; Tue, 27 Mar 2012 08:57:07 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1332855768-32583-7-git-send-email-m.szyprowski@samsung.com>
References: <1332855768-32583-1-git-send-email-m.szyprowski@samsung.com> <1332855768-32583-7-git-send-email-m.szyprowski@samsung.com>
From: Matt Turner <mattst88@gmail.com>
Date: Tue, 27 Mar 2012 11:56:43 -0400
Message-ID: <CAEdQ38H6xJsHDZh2LJA4NZOQJ0AEtYLKK2i7w=+98TXCCRxEQw@mail.gmail.com>
Subject: Re: [PATCHv2 06/14] Alpha: adapt for dma_map_ops changes
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-kernel@vger.kernel.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Stephen Rothwell <sfr@canb.auug.org.au>, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, microblaze-uclinux@itee.uq.edu.au, linux-arch@vger.kernel.org, x86@kernel.org, linux-sh@vger.kernel.org, linux-alpha@vger.kernel.org, sparclinux@vger.kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mips@linux-mips.org, discuss@x86-64.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Jonathan Corbet <corbet@lwn.net>, Kyungmin Park <kyungmin.park@samsung.com>, Andrzej Pietrasiewicz <andrzej.p@samsung.com>, Kevin Cernekee <cernekee@gmail.com>, Dezhong Diao <dediao@cisco.com>, Richard Kuo <rkuo@codeaurora.org>, "David S. Miller" <davem@davemloft.net>, Michal Simek <monstr@monstr.eu>, Guan Xuetao <gxt@mprc.pku.edu.cn>, Paul Mundt <lethal@linux-sh.org>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>

On Tue, Mar 27, 2012 at 9:42 AM, Marek Szyprowski
<m.szyprowski@samsung.com> wrote:
> From: Andrzej Pietrasiewicz <andrzej.p@samsung.com>
>
> Adapt core Alpha architecture code for dma_map_ops changes: replace
> alloc/free_coherent with generic alloc/free methods.
>
> Signed-off-by: Andrzej Pietrasiewicz <andrzej.p@samsung.com>
> Acked-by: Kyungmin Park <kyungmin.park@samsung.com>
> Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
> Reviewed-by: Arnd Bergmann <arnd@arndb.de>
> ---
> =A0arch/alpha/include/asm/dma-mapping.h | =A0 18 ++++++++++++------
> =A0arch/alpha/kernel/pci-noop.c =A0 =A0 =A0 =A0 | =A0 10 ++++++----
> =A0arch/alpha/kernel/pci_iommu.c =A0 =A0 =A0 =A0| =A0 10 ++++++----
> =A03 files changed, 24 insertions(+), 14 deletions(-)
>
> diff --git a/arch/alpha/include/asm/dma-mapping.h b/arch/alpha/include/as=
m/dma-mapping.h
> index 4567aca..dfa32f0 100644
> --- a/arch/alpha/include/asm/dma-mapping.h
> +++ b/arch/alpha/include/asm/dma-mapping.h
> @@ -12,16 +12,22 @@ static inline struct dma_map_ops *get_dma_ops(struct =
device *dev)
>
> =A0#include <asm-generic/dma-mapping-common.h>
>
> -static inline void *dma_alloc_coherent(struct device *dev, size_t size,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0dma_addr_t *dma_handle, gfp_t gfp)
> +#define dma_alloc_coherent(d,s,h,f) =A0 =A0dma_alloc_attrs(d,s,h,f,NULL)
> +
> +static inline void *dma_alloc_attrs(struct device *dev, size_t size,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dma=
_addr_t *dma_handle, gfp_t gfp,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 str=
uct dma_attrs *attrs)
> =A0{
> - =A0 =A0 =A0 return get_dma_ops(dev)->alloc_coherent(dev, size, dma_hand=
le, gfp);
> + =A0 =A0 =A0 return get_dma_ops(dev)->alloc(dev, size, dma_handle, gfp, =
attrs);
> =A0}
>
> -static inline void dma_free_coherent(struct device *dev, size_t size,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
void *vaddr, dma_addr_t dma_handle)
> +#define dma_free_coherent(d,s,c,h) dma_free_attrs(d,s,c,h,NULL)
> +
> +static inline void dma_free_attrs(struct device *dev, size_t size,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 void *v=
addr, dma_addr_t dma_handle,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct =
dma_attrs *attrs)
> =A0{
> - =A0 =A0 =A0 get_dma_ops(dev)->free_coherent(dev, size, vaddr, dma_handl=
e);
> + =A0 =A0 =A0 get_dma_ops(dev)->free(dev, size, vaddr, dma_handle, attrs)=
;
> =A0}
>
> =A0static inline int dma_mapping_error(struct device *dev, dma_addr_t dma=
_addr)
> diff --git a/arch/alpha/kernel/pci-noop.c b/arch/alpha/kernel/pci-noop.c
> index 04eea48..df24b76 100644
> --- a/arch/alpha/kernel/pci-noop.c
> +++ b/arch/alpha/kernel/pci-noop.c
> @@ -108,7 +108,8 @@ sys_pciconfig_write(unsigned long bus, unsigned long =
dfn,
> =A0}
>
> =A0static void *alpha_noop_alloc_coherent(struct device *dev, size_t size=
,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0dma_addr_t *dma_handle, gfp_t gfp)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0dma_addr_t *dma_handle, gfp_t gfp,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0struct dma_attrs *attrs)
> =A0{
> =A0 =A0 =A0 =A0void *ret;
>
> @@ -123,7 +124,8 @@ static void *alpha_noop_alloc_coherent(struct device =
*dev, size_t size,
> =A0}
>
> =A0static void alpha_noop_free_coherent(struct device *dev, size_t size,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
void *cpu_addr, dma_addr_t dma_addr)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
void *cpu_addr, dma_addr_t dma_addr,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
struct dma_attrs *attrs)
> =A0{
> =A0 =A0 =A0 =A0free_pages((unsigned long)cpu_addr, get_order(size));
> =A0}
> @@ -174,8 +176,8 @@ static int alpha_noop_set_mask(struct device *dev, u6=
4 mask)
> =A0}
>
> =A0struct dma_map_ops alpha_noop_ops =3D {
> - =A0 =A0 =A0 .alloc_coherent =A0 =A0 =A0 =A0 =3D alpha_noop_alloc_cohere=
nt,
> - =A0 =A0 =A0 .free_coherent =A0 =A0 =A0 =A0 =A0=3D alpha_noop_free_coher=
ent,
> + =A0 =A0 =A0 .alloc =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=3D alpha_noop_al=
loc_coherent,
> + =A0 =A0 =A0 .free =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =3D alpha_noop_fr=
ee_coherent,
> =A0 =A0 =A0 =A0.map_page =A0 =A0 =A0 =A0 =A0 =A0 =A0 =3D alpha_noop_map_p=
age,
> =A0 =A0 =A0 =A0.map_sg =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =3D alpha_noop_map=
_sg,
> =A0 =A0 =A0 =A0.mapping_error =A0 =A0 =A0 =A0 =A0=3D alpha_noop_mapping_e=
rror,
> diff --git a/arch/alpha/kernel/pci_iommu.c b/arch/alpha/kernel/pci_iommu.=
c
> index 4361080..cd63479 100644
> --- a/arch/alpha/kernel/pci_iommu.c
> +++ b/arch/alpha/kernel/pci_iommu.c
> @@ -434,7 +434,8 @@ static void alpha_pci_unmap_page(struct device *dev, =
dma_addr_t dma_addr,
> =A0 =A0else DMA_ADDRP is undefined. =A0*/
>
> =A0static void *alpha_pci_alloc_coherent(struct device *dev, size_t size,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 dma_addr_t *dma_addrp, gfp_t gfp)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 dma_addr_t *dma_addrp, gfp_t gfp,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 struct dma_attrs *attrs)
> =A0{
> =A0 =A0 =A0 =A0struct pci_dev *pdev =3D alpha_gendev_to_pci(dev);
> =A0 =A0 =A0 =A0void *cpu_addr;
> @@ -478,7 +479,8 @@ try_again:
> =A0 =A0DMA_ADDR past this call are illegal. =A0*/
>
> =A0static void alpha_pci_free_coherent(struct device *dev, size_t size,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 voi=
d *cpu_addr, dma_addr_t dma_addr)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 voi=
d *cpu_addr, dma_addr_t dma_addr,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 str=
uct dma_attrs *attrs)
> =A0{
> =A0 =A0 =A0 =A0struct pci_dev *pdev =3D alpha_gendev_to_pci(dev);
> =A0 =A0 =A0 =A0pci_unmap_single(pdev, dma_addr, size, PCI_DMA_BIDIRECTION=
AL);
> @@ -952,8 +954,8 @@ static int alpha_pci_set_mask(struct device *dev, u64=
 mask)
> =A0}
>
> =A0struct dma_map_ops alpha_pci_ops =3D {
> - =A0 =A0 =A0 .alloc_coherent =A0 =A0 =A0 =A0 =3D alpha_pci_alloc_coheren=
t,
> - =A0 =A0 =A0 .free_coherent =A0 =A0 =A0 =A0 =A0=3D alpha_pci_free_cohere=
nt,
> + =A0 =A0 =A0 .alloc =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=3D alpha_pci_all=
oc_coherent,
> + =A0 =A0 =A0 .free =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =3D alpha_pci_fre=
e_coherent,
> =A0 =A0 =A0 =A0.map_page =A0 =A0 =A0 =A0 =A0 =A0 =A0 =3D alpha_pci_map_pa=
ge,
> =A0 =A0 =A0 =A0.unmap_page =A0 =A0 =A0 =A0 =A0 =A0 =3D alpha_pci_unmap_pa=
ge,
> =A0 =A0 =A0 =A0.map_sg =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =3D alpha_pci_map_=
sg,
> --
> 1.7.1.569.g6f426
>

Acked-by: Matt Turner <mattst88@gmail.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
