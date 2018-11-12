Return-Path: <linux-kernel-owner@vger.kernel.org>
MIME-Version: 1.0
Message-ID: <trinity-1cb5fd22-242b-44e5-91dc-fabf1f276bdf-1542024854775@msvc-mesg-gmx024>
From: "Qian Cai" <cai@gmx.us>
Subject: Re: [PATCH] efi: permit calling efi_mem_reserve_persistent from
 atomic context
Content-Type: text/plain; charset=UTF-8
Date: Mon, 12 Nov 2018 13:14:14 +0100
In-Reply-To: <86muqeelvt.wl-marc.zyngier@arm.com>
References: <20181108180511.30239-1-ard.biesheuvel@linaro.org>
 <trinity-d366cf7f-4a38-4193-a636-b695d34d6c47-1541817914119@msvc-mesg-gmx024>
 <E591C777-E2A6-4624-ABCE-C08251F7484A@gmx.us>
 <86muqeelvt.wl-marc.zyngier@arm.com>
Content-Transfer-Encoding: 8BIT
Sender: linux-kernel-owner@vger.kernel.org
To: Marc Zyngier <marc.zyngier@arm.com>
Cc: linux kernel <linux-kernel@vger.kernel.org>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, will.deacon@arm.com, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, linux-efi@vger.kernel.org
List-ID: <linux-mm.kvack.org>


On 11/12/18 at 3:32 AM, Marc Zyngier wrote:

> On Mon, 12 Nov 2018 02:45:48 +0000,
> Qian Cai <cai@gmx.us> wrote:
> > 
> > 
> > 
> > > On Nov 9, 2018, at 9:45 PM, Qian Cai <cai@gmx.us> wrote:
> > > 
> > > 
> > > On 11/8/18 at 1:05 PM, Ard Biesheuvel wrote:
> > > 
> > >> Currently, efi_mem_reserve_persistent() may not be called from atomic
> > >> context, since both the kmalloc() call and the memremap() call may
> > >> sleep.
> > >> 
> > >> The kmalloc() call is easy enough to fix, but the memremap() call
> > >> needs to be moved into an init hook since we cannot control the
> > >> memory allocation behavior of memremap() at the call site.
> > >> 
> > >> Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
> > >> ---
> > >> drivers/firmware/efi/efi.c | 31 +++++++++++++++++++------------
> > >> 1 file changed, 19 insertions(+), 12 deletions(-)
> > >> 
> > >> diff --git a/drivers/firmware/efi/efi.c b/drivers/firmware/efi/efi.c
> > >> index 249eb70691b0..cfc876e0b67b 100644
> > >> --- a/drivers/firmware/efi/efi.c
> > >> +++ b/drivers/firmware/efi/efi.c
> > >> @@ -963,36 +963,43 @@ bool efi_is_table_address(unsigned long phys_addr)
> > >> }
> > >> 
> > >> static DEFINE_SPINLOCK(efi_mem_reserve_persistent_lock);
> > >> +static struct linux_efi_memreserve *efi_memreserve_root __ro_after_init;
> > >> 
> > >> int efi_mem_reserve_persistent(phys_addr_t addr, u64 size)
> > >> {
> > >> -	struct linux_efi_memreserve *rsv, *parent;
> > >> +	struct linux_efi_memreserve *rsv;
> > >> 
> > >> -	if (efi.mem_reserve == EFI_INVALID_TABLE_ADDR)
> > >> +	if (!efi_memreserve_root)
> > >> 		return -ENODEV;
> > >> 
> > >> -	rsv = kmalloc(sizeof(*rsv), GFP_KERNEL);
> > >> +	rsv = kmalloc(sizeof(*rsv), GFP_ATOMIC);
> > >> 	if (!rsv)
> > >> 		return -ENOMEM;
> > >> 
> > >> -	parent = memremap(efi.mem_reserve, sizeof(*rsv), MEMREMAP_WB);
> > >> -	if (!parent) {
> > >> -		kfree(rsv);
> > >> -		return -ENOMEM;
> > >> -	}
> > >> -
> > >> 	rsv->base = addr;
> > >> 	rsv->size = size;
> > >> 
> > >> 	spin_lock(&efi_mem_reserve_persistent_lock);
> > >> -	rsv->next = parent->next;
> > >> -	parent->next = __pa(rsv);
> > >> +	rsv->next = efi_memreserve_root->next;
> > >> +	efi_memreserve_root->next = __pa(rsv);
> > >> 	spin_unlock(&efi_mem_reserve_persistent_lock);
> > >> 
> > >> -	memunmap(parent);
> > >> +	return 0;
> > >> +}
> > >> 
> > >> +static int __init efi_memreserve_root_init(void)
> > >> +{
> > >> +	if (efi.mem_reserve == EFI_INVALID_TABLE_ADDR)
> > >> +		return -ENODEV;
> > >> +
> > >> +	efi_memreserve_root = memremap(efi.mem_reserve,
> > >> +				       sizeof(*efi_memreserve_root),
> > >> +				       MEMREMAP_WB);
> > >> +	if (!efi_memreserve_root)
> > >> +		return -ENOMEM;
> > >> 	return 0;
> > >> }
> > >> +early_initcall(efi_memreserve_root_init);
> > >> 
> > >> #ifdef CONFIG_KEXEC
> > >> static int update_efi_random_seed(struct notifier_block *nb,
> > >> -- 
> > >> 2.19.1
> > > BTW, I won’t be able to apply this patch on top of this series [1]. After applied that series, the original BUG sleep from atomic is gone as well as two other GIC warnings. Do you think a new patch is needed here?
> > > 
> > > [1] https://www.spinics.net/lists/arm-kernel/msg685751.html
> > OK, I was able to apply this patch on top of latest mainline (ccda4af0f4b9)
> > which also include one patch (1/6) from the above series,
> > 
> > However, the efi-related patches from the series (4/6, 5/6, and 6/6) are no
> > longer able to be cleanly applied. 
> > 
> > As the results, the above patch did fix the original BUG: sleep from atomic,
> > but it introduces 2 new warnings.
> 
> [...]
> 
> These are the warnings you've already reported, aren't they? And we've
> established that if you apply the whole series, everything work as
> intended at least on the GIC side (the timer issue is a different
> story altogether).
> 
> Or am I missing something?
The problem is that I am not able to apply the whole  
series alone on top of the latest mainline (rc2) now to 
verify  it. Also, I won’t be able to apply the series and 
this patch together on top of rc1. There are conflicts 
between this patch and 4-6 of the series.

Originally, I said those GIC warnings are gone when
testing rc1 + the series, but I am not sure if it is just
dumb luck that also fix BUG: sleep from atomic. Make
sense?
