Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id C12386B0006
	for <linux-mm@kvack.org>; Wed,  7 Mar 2018 16:18:25 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id 5so1963656wrb.15
        for <linux-mm@kvack.org>; Wed, 07 Mar 2018 13:18:25 -0800 (PST)
Received: from mail3-relais-sop.national.inria.fr (mail3-relais-sop.national.inria.fr. [192.134.164.104])
        by mx.google.com with ESMTPS id e7si8455195wme.245.2018.03.07.13.18.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Mar 2018 13:18:23 -0800 (PST)
Date: Wed, 7 Mar 2018 22:18:21 +0100 (CET)
From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [PATCH 2/2] mm: Add kvmalloc_ab_c and kvzalloc_struct
In-Reply-To: <CAGXu5jL9hqQGe672CmvFwqNbtTr=qu7WRwHuS4Vy7o5sX_UTgg@mail.gmail.com>
Message-ID: <alpine.DEB.2.20.1803072212160.2814@hadrien>
References: <20180214182618.14627-1-willy@infradead.org> <20180214182618.14627-3-willy@infradead.org> <CAGXu5jL9hqQGe672CmvFwqNbtTr=qu7WRwHuS4Vy7o5sX_UTgg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Matthew Wilcox <willy@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <mawilcox@microsoft.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>, cocci@systeme.lip6.fr, Himanshu Jha <himanshujha199640@gmail.com>



On Wed, 14 Feb 2018, Kees Cook wrote:

> On Wed, Feb 14, 2018 at 10:26 AM, Matthew Wilcox <willy@infradead.org> wrote:
> > From: Matthew Wilcox <mawilcox@microsoft.com>
> >
> > We have kvmalloc_array in order to safely allocate an array with a
> > number of elements specified by userspace (avoiding arithmetic overflow
> > leading to a buffer overrun).  But it's fairly common to have a header
> > in front of that array (eg specifying the length of the array), so we
> > need a helper function for that situation.
> >
> > kvmalloc_ab_c() is the workhorse that does the calculation, but in spite
> > of our best efforts to name the arguments, it's really hard to remember
> > which order to put the arguments in.  kvzalloc_struct() eliminates that
> > effort; you tell it about the struct you're allocating, and it puts the
> > arguments in the right order for you (and checks that the arguments
> > you've given are at least plausible).
> >
> > For comparison between the three schemes:
> >
> >         sev = kvzalloc(sizeof(*sev) + sizeof(struct v4l2_kevent) * elems,
> >                         GFP_KERNEL);
> >         sev = kvzalloc_ab_c(elems, sizeof(struct v4l2_kevent), sizeof(*sev),
> >                         GFP_KERNEL);
> >         sev = kvzalloc_struct(sev, events, elems, GFP_KERNEL);
> >
> > Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
> > ---
> >  include/linux/mm.h | 51 +++++++++++++++++++++++++++++++++++++++++++++++++++
> >  1 file changed, 51 insertions(+)
> >
> > diff --git a/include/linux/mm.h b/include/linux/mm.h
> > index 81bd7f0be286..ddf929c5aaee 100644
> > --- a/include/linux/mm.h
> > +++ b/include/linux/mm.h
> > @@ -557,6 +557,57 @@ static inline void *kvmalloc_array(size_t n, size_t size, gfp_t flags)
> >         return kvmalloc(n * size, flags);
> >  }
> >
> > +/**
> > + * kvmalloc_ab_c() - Allocate memory.
>
> Longer description, maybe? "Allocate a *b + c bytes of memory"?
>
> > + * @n: Number of elements.
> > + * @size: Size of each element (should be constant).
> > + * @c: Size of header (should be constant).
>
> If these should be constant, should we mark them as "const"? Or WARN
> if __builtin_constant_p() isn't true?
>
> > + * @gfp: Memory allocation flags.
> > + *
> > + * Use this function to allocate @n * @size + @c bytes of memory.  This
> > + * function is safe to use when @n is controlled from userspace; it will
> > + * return %NULL if the required amount of memory cannot be allocated.
> > + * Use kvfree() to free the allocated memory.
> > + *
> > + * The kvzalloc_hdr_arr() function is easier to use as it has typechecking
>
> renaming typo? Should this be "kvzalloc_struct()"?
>
> > + * and you do not need to remember which of the arguments should be constants.
> > + *
> > + * Context: Process context.  May sleep; the @gfp flags should be based on
> > + *         %GFP_KERNEL.
> > + * Return: A pointer to the allocated memory or %NULL.
> > + */
> > +static inline __must_check
> > +void *kvmalloc_ab_c(size_t n, size_t size, size_t c, gfp_t gfp)
> > +{
> > +       if (size != 0 && n > (SIZE_MAX - c) / size)
> > +               return NULL;
> > +
> > +       return kvmalloc(n * size + c, gfp);
> > +}
> > +#define kvzalloc_ab_c(a, b, c, gfp)    kvmalloc_ab_c(a, b, c, gfp | __GFP_ZERO)
>
> Nit: "(gfp) | __GFP_ZERO" just in case of insane usage.
>
> > +
> > +/**
> > + * kvzalloc_struct() - Allocate and zero-fill a structure containing a
> > + *                    variable length array.
> > + * @p: Pointer to the structure.
> > + * @member: Name of the array member.
> > + * @n: Number of elements in the array.
> > + * @gfp: Memory allocation flags.
> > + *
> > + * Allocate (and zero-fill) enough memory for a structure with an array
> > + * of @n elements.  This function is safe to use when @n is specified by
> > + * userspace as the arithmetic will not overflow.
> > + * Use kvfree() to free the allocated memory.
> > + *
> > + * Context: Process context.  May sleep; the @gfp flags should be based on
> > + *         %GFP_KERNEL.
> > + * Return: Zero-filled memory or a NULL pointer.
> > + */
> > +#define kvzalloc_struct(p, member, n, gfp)                             \
> > +       (typeof(p))kvzalloc_ab_c(n,                                     \
> > +               sizeof(*(p)->member) + __must_be_array((p)->member),    \
> > +               offsetof(typeof(*(p)), member), gfp)
> > +
> >  extern void kvfree(const void *addr);
> >
> >  static inline atomic_t *compound_mapcount_ptr(struct page *page)
>
> It might be nice to include another patch that replaces some of the
> existing/common uses of a*b+c with the new function...
>
> Otherwise, yes, please. We could build a coccinelle rule for
> additional replacements...

A potential semantic patch and the changes it generates are attached
below.  Himanshu Jha helped with its development.  Working on this
uncovered one bug, where the allocated array is too large, because the
size provided for it was a structure size, but actually only pointers to
that structure were to be stored in it.

Note that the rule changes both kmallocs and kzallocs to kvzalloc_struct.
If this is not wanted, it would be easy to change.

julia

------------

// Last field case

@r@
identifier i,idn;
struct i *buf;
expression e;
position p;
@@

\(kmalloc\|kzalloc\|kvmalloc\|kvzalloc\)
    (sizeof(*buf) + sizeof(*buf->idn) * e, <+...GFP_KERNEL...+>)@p

@s@
identifier r.i,r.idn;
type T1;
@@

struct i {
   ...
(
T1 idn[0];
|
T1 idn[];
)
}

@depends on s@
identifier r.idn;
expression buf, e, flag;
position r.p;
@@

(
- kmalloc(sizeof(*buf) + sizeof(*buf->idn) * e, flag)@p
+ kvzalloc_struct(buf, idn, e, flag)
|
- kzalloc(sizeof(*buf) + sizeof(*buf->idn) * e, flag)@p
+ kvzalloc_struct(buf, idn, e, flag)
|
- kvmalloc(sizeof(*buf) + sizeof(*buf->idn) * e, flag)@p
+ kvzalloc_struct(buf, idn, e, flag)
|
- kvzalloc(sizeof(*buf) + sizeof(*buf->idn) * e, flag)@p
+ kvzalloc_struct(buf, idn, e, flag)
)

// -------------------------------------------------------
// Type case

@r1@
identifier i;
struct i *buf;
type T;
T *exp;
expression e;
position p;
@@

\(kmalloc\|kzalloc\|kvmalloc\|kvzalloc\)
    (sizeof(*buf) + \(sizeof(T)\|sizeof(*exp)\) * e, <+...GFP_KERNEL...+>)@p


@s1@
identifier r1.i,fld;
type r1.T;
@@

struct i {
   ...
(
T fld[0];
|
T fld[];
)
}

@depends on s1@
identifier s1.fld;
type r1.T;
T *exp;
expression buf, e, flag;
position r1.p;
@@

(
- kmalloc(sizeof(*buf) + \(sizeof(T)\|sizeof(*exp)\) * e, flag)@p
+ kvzalloc_struct(buf, fld, e, flag)
|
- kzalloc(sizeof(*buf) + \(sizeof(T)\|sizeof(*exp)\) * e, flag)@p
+ kvzalloc_struct(buf, fld, e, flag)
|
- kvmalloc(sizeof(*buf) + \(sizeof(T)\|sizeof(*exp)\) * e, flag)@p
+ kvzalloc_struct(buf, fld, e, flag)
|
- kvzalloc(sizeof(*buf) + \(sizeof(T)\|sizeof(*exp)\) * e, flag)@p
+ kvzalloc_struct(buf, fld, e, flag)
)

----------------

diff -u -p a/drivers/irqchip/irq-bcm6345-l1.c b/drivers/irqchip/irq-bcm6345-l1.c
--- a/drivers/irqchip/irq-bcm6345-l1.c
+++ b/drivers/irqchip/irq-bcm6345-l1.c
@@ -255,8 +255,8 @@ static int __init bcm6345_l1_init_one(st
 	else if (intc->n_words != n_words)
 		return -EINVAL;

-	cpu = intc->cpus[idx] = kzalloc(sizeof(*cpu) + n_words * sizeof(u32),
-					GFP_KERNEL);
+	cpu = intc->cpus[idx] = kvzalloc_struct(cpu, enable_cache, n_words,
+						GFP_KERNEL);
 	if (!cpu)
 		return -ENOMEM;

diff -u -p a/drivers/irqchip/irq-bcm7038-l1.c b/drivers/irqchip/irq-bcm7038-l1.c
--- a/drivers/irqchip/irq-bcm7038-l1.c
+++ b/drivers/irqchip/irq-bcm7038-l1.c
@@ -263,8 +263,8 @@ static int __init bcm7038_l1_init_one(st
 	else if (intc->n_words != n_words)
 		return -EINVAL;

-	cpu = intc->cpus[idx] = kzalloc(sizeof(*cpu) + n_words * sizeof(u32),
-					GFP_KERNEL);
+	cpu = intc->cpus[idx] = kvzalloc_struct(cpu, mask_cache, n_words,
+						GFP_KERNEL);
 	if (!cpu)
 		return -ENOMEM;

diff -u -p a/drivers/clk/clk-efm32gg.c b/drivers/clk/clk-efm32gg.c
--- a/drivers/clk/clk-efm32gg.c
+++ b/drivers/clk/clk-efm32gg.c
@@ -25,8 +25,7 @@ static void __init efm32gg_cmu_init(stru
 	void __iomem *base;
 	struct clk_hw **hws;

-	clk_data = kzalloc(sizeof(*clk_data) +
-			   sizeof(*clk_data->hws) * CMU_MAX_CLKS, GFP_KERNEL);
+	clk_data = kvzalloc_struct(clk_data, hws, CMU_MAX_CLKS, GFP_KERNEL);

 	if (!clk_data)
 		return;
diff -u -p a/drivers/clk/clk-gemini.c b/drivers/clk/clk-gemini.c
--- a/drivers/clk/clk-gemini.c
+++ b/drivers/clk/clk-gemini.c
@@ -399,9 +399,8 @@ static void __init gemini_cc_init(struct
 	int ret;
 	int i;

-	gemini_clk_data = kzalloc(sizeof(*gemini_clk_data) +
-			sizeof(*gemini_clk_data->hws) * GEMINI_NUM_CLKS,
-			GFP_KERNEL);
+	gemini_clk_data = kvzalloc_struct(gemini_clk_data, hws,
+					  GEMINI_NUM_CLKS, GFP_KERNEL);
 	if (!gemini_clk_data)
 		return;

diff -u -p a/drivers/clk/clk-stm32h7.c b/drivers/clk/clk-stm32h7.c
--- a/drivers/clk/clk-stm32h7.c
+++ b/drivers/clk/clk-stm32h7.c
@@ -1201,9 +1201,8 @@ static void __init stm32h7_rcc_init(stru
 	const char *hse_clk, *lse_clk, *i2s_clk;
 	struct regmap *pdrm;

-	clk_data = kzalloc(sizeof(*clk_data) +
-			sizeof(*clk_data->hws) * STM32H7_MAX_CLKS,
-			GFP_KERNEL);
+	clk_data = kvzalloc_struct(clk_data, hws, STM32H7_MAX_CLKS,
+				   GFP_KERNEL);
 	if (!clk_data)
 		return;

diff -u -p a/drivers/clk/bcm/clk-iproc-asiu.c b/drivers/clk/bcm/clk-iproc-asiu.c
--- a/drivers/clk/bcm/clk-iproc-asiu.c
+++ b/drivers/clk/bcm/clk-iproc-asiu.c
@@ -197,8 +197,8 @@ void __init iproc_asiu_setup(struct devi
 	if (WARN_ON(!asiu))
 		return;

-	asiu->clk_data = kzalloc(sizeof(*asiu->clk_data->hws) * num_clks +
-				 sizeof(*asiu->clk_data), GFP_KERNEL);
+	asiu->clk_data = kvzalloc_struct(asiu->clk_data, hws, num_clks,
+					 GFP_KERNEL);
 	if (WARN_ON(!asiu->clk_data))
 		goto err_clks;
 	asiu->clk_data->num = num_clks;
diff -u -p a/drivers/clk/bcm/clk-iproc-pll.c b/drivers/clk/bcm/clk-iproc-pll.c
--- a/drivers/clk/bcm/clk-iproc-pll.c
+++ b/drivers/clk/bcm/clk-iproc-pll.c
@@ -744,8 +744,7 @@ void iproc_pll_clk_setup(struct device_n
 	if (WARN_ON(!pll))
 		return;

-	clk_data = kzalloc(sizeof(*clk_data->hws) * num_clks +
-				sizeof(*clk_data), GFP_KERNEL);
+	clk_data = kvzalloc_struct(clk_data, hws, num_clks, GFP_KERNEL);
 	if (WARN_ON(!clk_data))
 		goto err_clk_data;
 	clk_data->num = num_clks;
diff -u -p a/drivers/clk/clk-asm9260.c b/drivers/clk/clk-asm9260.c
--- a/drivers/clk/clk-asm9260.c
+++ b/drivers/clk/clk-asm9260.c
@@ -273,8 +273,7 @@ static void __init asm9260_acc_init(stru
 	int n;
 	u32 accuracy = 0;

-	clk_data = kzalloc(sizeof(*clk_data) +
-			   sizeof(*clk_data->hws) * MAX_CLKS, GFP_KERNEL);
+	clk_data = kvzalloc_struct(clk_data, hws, MAX_CLKS, GFP_KERNEL);
 	if (!clk_data)
 		return;
 	clk_data->num = MAX_CLKS;
diff -u -p a/drivers/clk/clk-aspeed.c b/drivers/clk/clk-aspeed.c
--- a/drivers/clk/clk-aspeed.c
+++ b/drivers/clk/clk-aspeed.c
@@ -621,9 +621,8 @@ static void __init aspeed_cc_init(struct
 	if (!scu_base)
 		return;

-	aspeed_clk_data = kzalloc(sizeof(*aspeed_clk_data) +
-			sizeof(*aspeed_clk_data->hws) * ASPEED_NUM_CLKS,
-			GFP_KERNEL);
+	aspeed_clk_data = kvzalloc_struct(aspeed_clk_data, hws,
+				          ASPEED_NUM_CLKS, GFP_KERNEL);
 	if (!aspeed_clk_data)
 		return;

diff -u -p a/drivers/clk/berlin/bg2.c b/drivers/clk/berlin/bg2.c
--- a/drivers/clk/berlin/bg2.c
+++ b/drivers/clk/berlin/bg2.c
@@ -509,8 +509,7 @@ static void __init berlin2_clock_setup(s
 	u8 avpll_flags = 0;
 	int n, ret;

-	clk_data = kzalloc(sizeof(*clk_data) +
-			   sizeof(*clk_data->hws) * MAX_CLKS, GFP_KERNEL);
+	clk_data = kvzalloc_struct(clk_data, hws, MAX_CLKS, GFP_KERNEL);
 	if (!clk_data)
 		return;
 	clk_data->num = MAX_CLKS;
diff -u -p a/drivers/clk/berlin/bg2q.c b/drivers/clk/berlin/bg2q.c
--- a/drivers/clk/berlin/bg2q.c
+++ b/drivers/clk/berlin/bg2q.c
@@ -295,8 +295,7 @@ static void __init berlin2q_clock_setup(
 	struct clk_hw **hws;
 	int n, ret;

-	clk_data = kzalloc(sizeof(*clk_data) +
-			   sizeof(*clk_data->hws) * MAX_CLKS, GFP_KERNEL);
+	clk_data = kvzalloc_struct(clk_data, hws, MAX_CLKS, GFP_KERNEL);
 	if (!clk_data)
 		return;
 	clk_data->num = MAX_CLKS;
diff -u -p a/drivers/input/input-leds.c b/drivers/input/input-leds.c
--- a/drivers/input/input-leds.c
+++ b/drivers/input/input-leds.c
@@ -97,8 +97,7 @@ static int input_leds_connect(struct inp
 	if (!num_leds)
 		return -ENXIO;

-	leds = kzalloc(sizeof(*leds) + num_leds * sizeof(*leds->leds),
-		       GFP_KERNEL);
+	leds = kvzalloc_struct(leds, leds, num_leds, GFP_KERNEL);
 	if (!leds)
 		return -ENOMEM;

diff -u -p a/drivers/input/input-mt.c b/drivers/input/input-mt.c
--- a/drivers/input/input-mt.c
+++ b/drivers/input/input-mt.c
@@ -49,7 +49,7 @@ int input_mt_init_slots(struct input_dev
 	if (mt)
 		return mt->num_slots != num_slots ? -EINVAL : 0;

-	mt = kzalloc(sizeof(*mt) + num_slots * sizeof(*mt->slots), GFP_KERNEL);
+	mt = kvzalloc_struct(mt, slots, num_slots, GFP_KERNEL);
 	if (!mt)
 		goto err_mem;

diff -u -p a/drivers/dax/device.c b/drivers/dax/device.c
--- a/drivers/dax/device.c
+++ b/drivers/dax/device.c
@@ -586,7 +586,7 @@ struct dev_dax *devm_create_dev_dax(stru
 	if (!count)
 		return ERR_PTR(-EINVAL);

-	dev_dax = kzalloc(sizeof(*dev_dax) + sizeof(*res) * count, GFP_KERNEL);
+	dev_dax = kvzalloc_struct(dev_dax, res, count, GFP_KERNEL);
 	if (!dev_dax)
 		return ERR_PTR(-ENOMEM);

diff -u -p a/drivers/usb/gadget/function/f_midi.c b/drivers/usb/gadget/function/f_midi.c
--- a/drivers/usb/gadget/function/f_midi.c
+++ b/drivers/usb/gadget/function/f_midi.c
@@ -1286,9 +1286,8 @@ static struct usb_function *f_midi_alloc
 	}

 	/* allocate and initialize one new instance */
-	midi = kzalloc(
-		sizeof(*midi) + opts->in_ports * sizeof(*midi->in_ports_array),
-		GFP_KERNEL);
+	midi = kvzalloc_struct(midi, in_ports_array, opts->in_ports,
+			       GFP_KERNEL);
 	if (!midi) {
 		status = -ENOMEM;
 		goto setup_fail;
diff -u -p a/drivers/usb/atm/usbatm.c b/drivers/usb/atm/usbatm.c
--- a/drivers/usb/atm/usbatm.c
+++ b/drivers/usb/atm/usbatm.c
@@ -1015,7 +1015,8 @@ int usbatm_usb_probe(struct usb_interfac
 	unsigned int maxpacket, num_packets;

 	/* instance init */
-	instance = kzalloc(sizeof(*instance) + sizeof(struct urb *) * (num_rcv_urbs + num_snd_urbs), GFP_KERNEL);
+	instance = kvzalloc_struct(instance, urbs,
+				   (num_rcv_urbs + num_snd_urbs), GFP_KERNEL);
 	if (!instance)
 		return -ENOMEM;

diff -u -p a/drivers/hwspinlock/omap_hwspinlock.c b/drivers/hwspinlock/omap_hwspinlock.c
--- a/drivers/hwspinlock/omap_hwspinlock.c
+++ b/drivers/hwspinlock/omap_hwspinlock.c
@@ -132,7 +132,7 @@ static int omap_hwspinlock_probe(struct

 	num_locks = i * 32; /* actual number of locks in this device */

-	bank = kzalloc(sizeof(*bank) + num_locks * sizeof(*hwlock), GFP_KERNEL);
+	bank = kvzalloc_struct(bank, lock, num_locks, GFP_KERNEL);
 	if (!bank) {
 		ret = -ENOMEM;
 		goto iounmap_base;
diff -u -p a/drivers/hwspinlock/u8500_hsem.c b/drivers/hwspinlock/u8500_hsem.c
--- a/drivers/hwspinlock/u8500_hsem.c
+++ b/drivers/hwspinlock/u8500_hsem.c
@@ -119,7 +119,7 @@ static int u8500_hsem_probe(struct platf
 	/* clear all interrupts */
 	writel(0xFFFF, io_base + HSEM_ICRALL);

-	bank = kzalloc(sizeof(*bank) + num_locks * sizeof(*hwlock), GFP_KERNEL);
+	bank = kvzalloc_struct(bank, lock, num_locks, GFP_KERNEL);
 	if (!bank) {
 		ret = -ENOMEM;
 		goto iounmap_base;
diff -u -p a/drivers/scsi/mvsas/mv_init.c b/drivers/scsi/mvsas/mv_init.c
--- a/drivers/scsi/mvsas/mv_init.c
+++ b/drivers/scsi/mvsas/mv_init.c
@@ -367,9 +367,9 @@ static struct mvs_info *mvs_pci_alloc(st
 	struct mvs_info *mvi = NULL;
 	struct sas_ha_struct *sha = SHOST_TO_SAS_HA(shost);

-	mvi = kzalloc(sizeof(*mvi) +
-		(1L << mvs_chips[ent->driver_data].slot_width) *
-		sizeof(struct mvs_slot_info), GFP_KERNEL);
+	mvi = kvzalloc_struct(mvi, slot_info,
+			      (1L << mvs_chips[ent->driver_data].slot_width),
+			      GFP_KERNEL);
 	if (!mvi)
 		return NULL;

diff -u -p a/drivers/md/dm-crypt.c b/drivers/md/dm-crypt.c
--- a/drivers/md/dm-crypt.c
+++ b/drivers/md/dm-crypt.c
@@ -2633,7 +2633,7 @@ static int crypt_ctr(struct dm_target *t
 		return -EINVAL;
 	}

-	cc = kzalloc(sizeof(*cc) + key_size * sizeof(u8), GFP_KERNEL);
+	cc = kvzalloc_struct(cc, key, key_size, GFP_KERNEL);
 	if (!cc) {
 		ti->error = "Cannot allocate encryption context";
 		return -ENOMEM;
diff -u -p a/drivers/md/md-linear.c b/drivers/md/md-linear.c
--- a/drivers/md/md-linear.c
+++ b/drivers/md/md-linear.c
@@ -96,8 +96,7 @@ static struct linear_conf *linear_conf(s
 	int i, cnt;
 	bool discard_supported = false;

-	conf = kzalloc (sizeof (*conf) + raid_disks*sizeof(struct dev_info),
-			GFP_KERNEL);
+	conf = kvzalloc_struct(conf, disks, raid_disks, GFP_KERNEL);
 	if (!conf)
 		return NULL;

diff -u -p a/drivers/gpu/drm/nouveau/nvkm/engine/pm/base.c b/drivers/gpu/drm/nouveau/nvkm/engine/pm/base.c
--- a/drivers/gpu/drm/nouveau/nvkm/engine/pm/base.c
+++ b/drivers/gpu/drm/nouveau/nvkm/engine/pm/base.c
@@ -779,8 +779,8 @@ nvkm_perfdom_new(struct nvkm_pm *pm, con

 		sdom = spec;
 		while (sdom->signal_nr) {
-			dom = kzalloc(sizeof(*dom) + sdom->signal_nr *
-				      sizeof(*dom->signal), GFP_KERNEL);
+			dom = kvzalloc_struct(dom, signal, sdom->signal_nr,
+					      GFP_KERNEL);
 			if (!dom)
 				return -ENOMEM;

diff -u -p a/drivers/gpu/drm/i915/selftests/mock_dmabuf.c b/drivers/gpu/drm/i915/selftests/mock_dmabuf.c
--- a/drivers/gpu/drm/i915/selftests/mock_dmabuf.c
+++ b/drivers/gpu/drm/i915/selftests/mock_dmabuf.c
@@ -145,8 +145,7 @@ static struct dma_buf *mock_dmabuf(int n
 	struct dma_buf *dmabuf;
 	int i;

-	mock = kmalloc(sizeof(*mock) + npages * sizeof(struct page *),
-		       GFP_KERNEL);
+	mock = kvzalloc_struct(mock, pages, npages, GFP_KERNEL);
 	if (!mock)
 		return ERR_PTR(-ENOMEM);

diff -u -p a/drivers/char/virtio_console.c b/drivers/char/virtio_console.c
--- a/drivers/char/virtio_console.c
+++ b/drivers/char/virtio_console.c
@@ -433,8 +433,7 @@ static struct port_buffer *alloc_buf(str
 	 * Allocate buffer and the sg list. The sg list array is allocated
 	 * directly after the port_buffer struct.
 	 */
-	buf = kmalloc(sizeof(*buf) + sizeof(struct scatterlist) * pages,
-		      GFP_KERNEL);
+	buf = kvzalloc_struct(buf, sg, pages, GFP_KERNEL);
 	if (!buf)
 		goto fail;

diff -u -p a/drivers/virtio/virtio_ring.c b/drivers/virtio/virtio_ring.c
--- a/drivers/virtio/virtio_ring.c
+++ b/drivers/virtio/virtio_ring.c
@@ -968,8 +968,7 @@ struct virtqueue *__vring_new_virtqueue(
 	unsigned int i;
 	struct vring_virtqueue *vq;

-	vq = kmalloc(sizeof(*vq) + vring.num * sizeof(struct vring_desc_state),
-		     GFP_KERNEL);
+	vq = kvzalloc_struct(vq, desc_state, vring.num, GFP_KERNEL);
 	if (!vq)
 		return NULL;

diff -u -p a/drivers/net/wireless/intel/iwlwifi/iwl-eeprom-parse.c b/drivers/net/wireless/intel/iwlwifi/iwl-eeprom-parse.c
--- a/drivers/net/wireless/intel/iwlwifi/iwl-eeprom-parse.c
+++ b/drivers/net/wireless/intel/iwlwifi/iwl-eeprom-parse.c
@@ -851,9 +851,7 @@ iwl_parse_eeprom_data(struct device *dev
 	if (WARN_ON(!cfg || !cfg->eeprom_params))
 		return NULL;

-	data = kzalloc(sizeof(*data) +
-		       sizeof(struct ieee80211_channel) * IWL_NUM_CHANNELS,
-		       GFP_KERNEL);
+	data = kvzalloc_struct(data, channels, IWL_NUM_CHANNELS, GFP_KERNEL);
 	if (!data)
 		return NULL;

diff -u -p a/drivers/net/ethernet/netronome/nfp/nfp_net_repr.c b/drivers/net/ethernet/netronome/nfp/nfp_net_repr.c
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_repr.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_repr.c
@@ -421,8 +421,7 @@ struct nfp_reprs *nfp_reprs_alloc(unsign
 {
 	struct nfp_reprs *reprs;

-	reprs = kzalloc(sizeof(*reprs) +
-			num_reprs * sizeof(struct net_device *), GFP_KERNEL);
+	reprs = kvzalloc_struct(reprs, reprs, num_reprs, GFP_KERNEL);
 	if (!reprs)
 		return NULL;
 	reprs->num_reprs = num_reprs;
diff -u -p a/include/rdma/ib_verbs.h b/include/rdma/ib_verbs.h
--- a/include/rdma/ib_verbs.h
+++ b/include/rdma/ib_verbs.h
@@ -505,8 +505,7 @@ static inline struct rdma_hw_stats *rdma
 {
 	struct rdma_hw_stats *stats;

-	stats = kzalloc(sizeof(*stats) + num_counters * sizeof(u64),
-			GFP_KERNEL);
+	stats = kvzalloc_struct(stats, value, num_counters, GFP_KERNEL);
 	if (!stats)
 		return NULL;
 	stats->names = names;
diff -u -p a/drivers/net/ethernet/chelsio/cxgb4/clip_tbl.c b/drivers/net/ethernet/chelsio/cxgb4/clip_tbl.c
--- a/drivers/net/ethernet/chelsio/cxgb4/clip_tbl.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/clip_tbl.c
@@ -289,8 +289,7 @@ struct clip_tbl *t4_init_clip_tbl(unsign
 	if (clipt_size < CLIPT_MIN_HASH_BUCKETS)
 		return NULL;

-	ctbl = kvzalloc(sizeof(*ctbl) +
-			    clipt_size*sizeof(struct list_head), GFP_KERNEL);
+	ctbl = kvzalloc_struct(ctbl, hash_list, clipt_size, GFP_KERNEL);
 	if (!ctbl)
 		return NULL;

diff -u -p a/drivers/net/ethernet/chelsio/cxgb4/l2t.c b/drivers/net/ethernet/chelsio/cxgb4/l2t.c
--- a/drivers/net/ethernet/chelsio/cxgb4/l2t.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/l2t.c
@@ -646,7 +646,7 @@ struct l2t_data *t4_init_l2t(unsigned in
 	if (l2t_size < L2T_MIN_HASH_BUCKETS)
 		return NULL;

-	d = kvzalloc(sizeof(*d) + l2t_size * sizeof(struct l2t_entry), GFP_KERNEL);
+	d = kvzalloc_struct(d, l2tab, l2t_size, GFP_KERNEL);
 	if (!d)
 		return NULL;

diff -u -p a/drivers/net/ethernet/chelsio/cxgb4/sched.c b/drivers/net/ethernet/chelsio/cxgb4/sched.c
--- a/drivers/net/ethernet/chelsio/cxgb4/sched.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/sched.c
@@ -512,7 +512,7 @@ struct sched_table *t4_init_sched(unsign
 	struct sched_table *s;
 	unsigned int i;

-	s = kvzalloc(sizeof(*s) + sched_size * sizeof(struct sched_class), GFP_KERNEL);
+	s = kvzalloc_struct(s, tab, sched_size, GFP_KERNEL);
 	if (!s)
 		return NULL;

diff -u -p a/drivers/net/ethernet/chelsio/cxgb4/smt.c b/drivers/net/ethernet/chelsio/cxgb4/smt.c
--- a/drivers/net/ethernet/chelsio/cxgb4/smt.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/smt.c
@@ -47,8 +47,7 @@ struct smt_data *t4_init_smt(void)

 	smt_size = SMT_SIZE;

-	s = kvzalloc(sizeof(*s) + smt_size * sizeof(struct smt_entry),
-		     GFP_KERNEL);
+	s = kvzalloc_struct(s, smtab, smt_size, GFP_KERNEL);
 	if (!s)
 		return NULL;
 	s->smt_size = smt_size;
diff -u -p a/include/rdma/ib_verbs.h b/include/rdma/ib_verbs.h
--- a/include/rdma/ib_verbs.h
+++ b/include/rdma/ib_verbs.h
@@ -505,8 +505,7 @@ static inline struct rdma_hw_stats *rdma
 {
 	struct rdma_hw_stats *stats;

-	stats = kzalloc(sizeof(*stats) + num_counters * sizeof(u64),
-			GFP_KERNEL);
+	stats = kvzalloc_struct(stats, value, num_counters, GFP_KERNEL);
 	if (!stats)
 		return NULL;
 	stats->names = names;
diff -u -p a/drivers/misc/vexpress-syscfg.c b/drivers/misc/vexpress-syscfg.c
--- a/drivers/misc/vexpress-syscfg.c
+++ b/drivers/misc/vexpress-syscfg.c
@@ -182,8 +182,7 @@ static struct regmap *vexpress_syscfg_re
 		val = energy_quirk;
 	}

-	func = kzalloc(sizeof(*func) + sizeof(*func->template) * num,
-			GFP_KERNEL);
+	func = kvzalloc_struct(func, template, num, GFP_KERNEL);
 	if (!func)
 		return ERR_PTR(-ENOMEM);

diff -u -p a/drivers/cpufreq/e_powersaver.c b/drivers/cpufreq/e_powersaver.c
--- a/drivers/cpufreq/e_powersaver.c
+++ b/drivers/cpufreq/e_powersaver.c
@@ -324,9 +324,8 @@ static int eps_cpu_init(struct cpufreq_p
 		states = 2;

 	/* Allocate private data and frequency table for current cpu */
-	centaur = kzalloc(sizeof(*centaur)
-		    + (states + 1) * sizeof(struct cpufreq_frequency_table),
-		    GFP_KERNEL);
+	centaur = kvzalloc_struct(centaur, freq_table, (states + 1),
+				  GFP_KERNEL);
 	if (!centaur)
 		return -ENOMEM;
 	eps_cpu[0] = centaur;
diff -u -p a/drivers/media/v4l2-core/v4l2-event.c b/drivers/media/v4l2-core/v4l2-event.c
--- a/drivers/media/v4l2-core/v4l2-event.c
+++ b/drivers/media/v4l2-core/v4l2-event.c
@@ -215,8 +215,7 @@ int v4l2_event_subscribe(struct v4l2_fh
 	if (elems < 1)
 		elems = 1;

-	sev = kvzalloc(sizeof(*sev) + sizeof(struct v4l2_kevent) * elems,
-		       GFP_KERNEL);
+	sev = kvzalloc_struct(sev, events, elems, GFP_KERNEL);
 	if (!sev)
 		return -ENOMEM;
 	for (i = 0; i < elems; i++)
diff -u -p a/drivers/infiniband/core/sa_query.c b/drivers/infiniband/core/sa_query.c
--- a/drivers/infiniband/core/sa_query.c
+++ b/drivers/infiniband/core/sa_query.c
@@ -2380,9 +2380,7 @@ static void ib_sa_add_one(struct ib_devi
 	s = rdma_start_port(device);
 	e = rdma_end_port(device);

-	sa_dev = kzalloc(sizeof *sa_dev +
-			 (e - s + 1) * sizeof (struct ib_sa_port),
-			 GFP_KERNEL);
+	sa_dev = kvzalloc_struct(sa_dev, port, (e - s + 1), GFP_KERNEL);
 	if (!sa_dev)
 		return;

diff -u -p a/drivers/infiniband/core/uverbs_ioctl_merge.c b/drivers/infiniband/core/uverbs_ioctl_merge.c
--- a/drivers/infiniband/core/uverbs_ioctl_merge.c
+++ b/drivers/infiniband/core/uverbs_ioctl_merge.c
@@ -297,9 +297,8 @@ static struct uverbs_method_spec *build_
 	if (max_attr_buckets >= 0)
 		num_attr_buckets = max_attr_buckets + 1;

-	method = kzalloc(sizeof(*method) +
-			 num_attr_buckets * sizeof(*method->attr_buckets),
-			 GFP_KERNEL);
+	method = kvzalloc_struct(method, attr_buckets, num_attr_buckets,
+				 GFP_KERNEL);
 	if (!method)
 		return ERR_PTR(-ENOMEM);

@@ -446,9 +445,8 @@ static struct uverbs_object_spec *build_
 	if (max_method_buckets >= 0)
 		num_method_buckets = max_method_buckets + 1;

-	object = kzalloc(sizeof(*object) +
-			 num_method_buckets *
-			 sizeof(*object->method_buckets), GFP_KERNEL);
+	object = kvzalloc_struct(object, method_buckets, num_method_buckets,
+				 GFP_KERNEL);
 	if (!object)
 		return ERR_PTR(-ENOMEM);

@@ -469,9 +467,8 @@ static struct uverbs_object_spec *build_
 		if (methods_max_bucket < 0)
 			continue;

-		hash = kzalloc(sizeof(*hash) +
-			       sizeof(*hash->methods) * (methods_max_bucket + 1),
-			       GFP_KERNEL);
+		hash = kvzalloc_struct(hash, methods,
+				       (methods_max_bucket + 1), GFP_KERNEL);
 		if (!hash) {
 			res = -ENOMEM;
 			goto free;
@@ -579,9 +576,8 @@ struct uverbs_root_spec *uverbs_alloc_sp
 	if (max_object_buckets >= 0)
 		num_objects_buckets = max_object_buckets + 1;

-	root_spec = kzalloc(sizeof(*root_spec) +
-			    num_objects_buckets * sizeof(*root_spec->object_buckets),
-			    GFP_KERNEL);
+	root_spec = kvzalloc_struct(root_spec, object_buckets,
+				    num_objects_buckets, GFP_KERNEL);
 	if (!root_spec)
 		return ERR_PTR(-ENOMEM);
 	root_spec->num_buckets = num_objects_buckets;
@@ -603,9 +599,8 @@ struct uverbs_root_spec *uverbs_alloc_sp
 		if (objects_max_bucket < 0)
 			continue;

-		hash = kzalloc(sizeof(*hash) +
-			       sizeof(*hash->objects) * (objects_max_bucket + 1),
-			       GFP_KERNEL);
+		hash = kvzalloc_struct(hash, objects,
+				       (objects_max_bucket + 1), GFP_KERNEL);
 		if (!hash) {
 			res = -ENOMEM;
 			goto free;
diff -u -p a/drivers/infiniband/core/multicast.c b/drivers/infiniband/core/multicast.c
--- a/drivers/infiniband/core/multicast.c
+++ b/drivers/infiniband/core/multicast.c
@@ -815,8 +815,7 @@ static void mcast_add_one(struct ib_devi
 	int i;
 	int count = 0;

-	dev = kmalloc(sizeof *dev + device->phys_port_cnt * sizeof *port,
-		      GFP_KERNEL);
+	dev = kvzalloc_struct(dev, port, device->phys_port_cnt, GFP_KERNEL);
 	if (!dev)
 		return;

diff -u -p a/include/rdma/ib_verbs.h b/include/rdma/ib_verbs.h
--- a/include/rdma/ib_verbs.h
+++ b/include/rdma/ib_verbs.h
@@ -505,8 +505,7 @@ static inline struct rdma_hw_stats *rdma
 {
 	struct rdma_hw_stats *stats;

-	stats = kzalloc(sizeof(*stats) + num_counters * sizeof(u64),
-			GFP_KERNEL);
+	stats = kvzalloc_struct(stats, value, num_counters, GFP_KERNEL);
 	if (!stats)
 		return NULL;
 	stats->names = names;
diff -u -p a/drivers/infiniband/core/cm.c b/drivers/infiniband/core/cm.c
--- a/drivers/infiniband/core/cm.c
+++ b/drivers/infiniband/core/cm.c
@@ -3951,8 +3951,7 @@ static void cm_recv_handler(struct ib_ma
 	atomic_long_inc(&port->counter_group[CM_RECV].
 			counter[attr_id - CM_ATTR_ID_OFFSET]);

-	work = kmalloc(sizeof(*work) + sizeof(struct sa_path_rec) * paths,
-		       GFP_KERNEL);
+	work = kvzalloc_struct(work, path, paths, GFP_KERNEL);
 	if (!work) {
 		ib_free_recv_mad(mad_recv_wc);
 		return;
diff -u -p a/drivers/infiniband/core/user_mad.c b/drivers/infiniband/core/user_mad.c
--- a/drivers/infiniband/core/user_mad.c
+++ b/drivers/infiniband/core/user_mad.c
@@ -1272,9 +1272,7 @@ static void ib_umad_add_one(struct ib_de
 	s = rdma_start_port(device);
 	e = rdma_end_port(device);

-	umad_dev = kzalloc(sizeof *umad_dev +
-			   (e - s + 1) * sizeof (struct ib_umad_port),
-			   GFP_KERNEL);
+	umad_dev = kvzalloc_struct(umad_dev, port, (e - s + 1), GFP_KERNEL);
 	if (!umad_dev)
 		return;

diff -u -p a/drivers/infiniband/core/cache.c b/drivers/infiniband/core/cache.c
--- a/drivers/infiniband/core/cache.c
+++ b/drivers/infiniband/core/cache.c
@@ -1065,16 +1065,16 @@ static void ib_cache_update(struct ib_de
 		goto err;
 	}

-	pkey_cache = kmalloc(sizeof *pkey_cache + tprops->pkey_tbl_len *
-			     sizeof *pkey_cache->table, GFP_KERNEL);
+	pkey_cache = kvzalloc_struct(pkey_cache, table, tprops->pkey_tbl_len,
+				     GFP_KERNEL);
 	if (!pkey_cache)
 		goto err;

 	pkey_cache->table_len = tprops->pkey_tbl_len;

 	if (!use_roce_gid_table) {
-		gid_cache = kmalloc(sizeof(*gid_cache) + tprops->gid_tbl_len *
-			    sizeof(*gid_cache->table), GFP_KERNEL);
+		gid_cache = kvzalloc_struct(gid_cache, table,
+					    tprops->gid_tbl_len, GFP_KERNEL);
 		if (!gid_cache)
 			goto err;

diff -u -p a/drivers/infiniband/hw/usnic/usnic_uiom.c b/drivers/infiniband/hw/usnic/usnic_uiom.c
--- a/drivers/infiniband/hw/usnic/usnic_uiom.c
+++ b/drivers/infiniband/hw/usnic/usnic_uiom.c
@@ -155,10 +155,9 @@ static int usnic_uiom_get_pages(unsigned
 		off = 0;

 		while (ret) {
-			chunk = kmalloc(sizeof(*chunk) +
-					sizeof(struct scatterlist) *
-					min_t(int, ret, USNIC_UIOM_PAGE_CHUNK),
-					GFP_KERNEL);
+			chunk = kvzalloc_struct(chunk, page_list,
+						min_t(int, ret, USNIC_UIOM_PAGE_CHUNK),
+						GFP_KERNEL);
 			if (!chunk) {
 				ret = -ENOMEM;
 				goto out;
diff -u -p a/drivers/infiniband/hw/mthca/mthca_memfree.c b/drivers/infiniband/hw/mthca/mthca_memfree.c
--- a/drivers/infiniband/hw/mthca/mthca_memfree.c
+++ b/drivers/infiniband/hw/mthca/mthca_memfree.c
@@ -367,7 +367,7 @@ struct mthca_icm_table *mthca_alloc_icm_
 	obj_per_chunk = MTHCA_TABLE_CHUNK_SIZE / obj_size;
 	num_icm = DIV_ROUND_UP(nobj, obj_per_chunk);

-	table = kmalloc(sizeof *table + num_icm * sizeof *table->icm, GFP_KERNEL);
+	table = kvzalloc_struct(table, icm, num_icm, GFP_KERNEL);
 	if (!table)
 		return NULL;

@@ -529,7 +529,7 @@ struct mthca_user_db_table *mthca_init_u
 		return NULL;

 	npages = dev->uar_table.uarc_size / MTHCA_ICM_PAGE_SIZE;
-	db_tab = kmalloc(sizeof *db_tab + npages * sizeof *db_tab->page, GFP_KERNEL);
+	db_tab = kvzalloc_struct(db_tab, page, npages, GFP_KERNEL);
 	if (!db_tab)
 		return ERR_PTR(-ENOMEM);

diff -u -p a/fs/aio.c b/fs/aio.c
--- a/fs/aio.c
+++ b/fs/aio.c
@@ -669,8 +669,7 @@ static int ioctx_add_table(struct kioctx
 		new_nr = (table ? table->nr : 1) * 4;
 		spin_unlock(&mm->ioctx_lock);

-		table = kzalloc(sizeof(*table) + sizeof(struct kioctx *) *
-				new_nr, GFP_KERNEL);
+		table = kvzalloc_struct(table, table, new_nr, GFP_KERNEL);
 		if (!table)
 			return -ENOMEM;

diff -u -p a/mm/memcontrol.c b/mm/memcontrol.c
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3558,8 +3558,7 @@ static int __mem_cgroup_usage_register_e
 	size = thresholds->primary ? thresholds->primary->size + 1 : 1;

 	/* Allocate memory for new array of thresholds */
-	new = kmalloc(sizeof(*new) + size * sizeof(struct mem_cgroup_threshold),
-			GFP_KERNEL);
+	new = kvzalloc_struct(new, entries, size, GFP_KERNEL);
 	if (!new) {
 		ret = -ENOMEM;
 		goto unlock;
diff -u -p a/include/rdma/ib_verbs.h b/include/rdma/ib_verbs.h
--- a/include/rdma/ib_verbs.h
+++ b/include/rdma/ib_verbs.h
@@ -505,8 +505,7 @@ static inline struct rdma_hw_stats *rdma
 {
 	struct rdma_hw_stats *stats;

-	stats = kzalloc(sizeof(*stats) + num_counters * sizeof(u64),
-			GFP_KERNEL);
+	stats = kvzalloc_struct(stats, value, num_counters, GFP_KERNEL);
 	if (!stats)
 		return NULL;
 	stats->names = names;
diff -u -p a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -850,9 +850,7 @@ static struct rpcrdma_sendctx *rpcrdma_s
 {
 	struct rpcrdma_sendctx *sc;

-	sc = kzalloc(sizeof(*sc) +
-		     ia->ri_max_send_sges * sizeof(struct ib_sge),
-		     GFP_KERNEL);
+	sc = kvzalloc_struct(sc, sc_sges, ia->ri_max_send_sges, GFP_KERNEL);
 	if (!sc)
 		return NULL;

diff -u -p a/net/sunrpc/xprtrdma/svc_rdma_rw.c b/net/sunrpc/xprtrdma/svc_rdma_rw.c
--- a/net/sunrpc/xprtrdma/svc_rdma_rw.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_rw.c
@@ -61,9 +61,8 @@ svc_rdma_get_rw_ctxt(struct svcxprt_rdma
 		spin_unlock(&rdma->sc_rw_ctxt_lock);
 	} else {
 		spin_unlock(&rdma->sc_rw_ctxt_lock);
-		ctxt = kmalloc(sizeof(*ctxt) +
-			       SG_CHUNK_SIZE * sizeof(struct scatterlist),
-			       GFP_KERNEL);
+		ctxt = kvzalloc_struct(ctxt, rw_first_sgl, SG_CHUNK_SIZE,
+				       GFP_KERNEL);
 		if (!ctxt)
 			goto out;
 		INIT_LIST_HEAD(&ctxt->rw_list);
diff -u -p a/net/openvswitch/meter.c b/net/openvswitch/meter.c
--- a/net/openvswitch/meter.c
+++ b/net/openvswitch/meter.c
@@ -206,8 +206,7 @@ static struct dp_meter *dp_meter_create(
 			return ERR_PTR(-EINVAL);

 	/* Allocate and set up the meter before locking anything. */
-	meter = kzalloc(n_bands * sizeof(struct dp_meter_band) +
-			sizeof(*meter), GFP_KERNEL);
+	meter = kvzalloc_struct(meter, bands, n_bands, GFP_KERNEL);
 	if (!meter)
 		return ERR_PTR(-ENOMEM);

diff -u -p a/sound/usb/usx2y/usbusx2yaudio.c b/sound/usb/usx2y/usbusx2yaudio.c
--- a/sound/usb/usx2y/usbusx2yaudio.c
+++ b/sound/usb/usx2y/usbusx2yaudio.c
@@ -657,7 +657,7 @@ static int usX2Y_rate_set(struct usX2Yde
 	struct s_c2		*ra = rate == 48000 ? SetRate48000 : SetRate44100;

 	if (usX2Y->rate != rate) {
-		us = kzalloc(sizeof(*us) + sizeof(struct urb*) * NOOF_SETRATE_URBS, GFP_KERNEL);
+		us = kvzalloc_struct(us, urb, NOOF_SETRATE_URBS, GFP_KERNEL);
 		if (NULL == us) {
 			err = -ENOMEM;
 			goto cleanup;
diff -u -p a/sound/pci/hda/hda_codec.c b/sound/pci/hda/hda_codec.c
--- a/sound/pci/hda/hda_codec.c
+++ b/sound/pci/hda/hda_codec.c
@@ -128,7 +128,7 @@ static int add_conn_list(struct hda_code
 {
 	struct hda_conn_list *p;

-	p = kmalloc(sizeof(*p) + len * sizeof(hda_nid_t), GFP_KERNEL);
+	p = kvzalloc_struct(p, conns, len, GFP_KERNEL);
 	if (!p)
 		return -ENOMEM;
 	p->len = len;
