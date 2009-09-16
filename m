Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id EA7086B004F
	for <linux-mm@kvack.org>; Wed, 16 Sep 2009 11:00:12 -0400 (EDT)
From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Subject: Re: 2.6.32 -mm merge plans
Date: Wed, 16 Sep 2009 09:00:09 -0600
References: <20090915161535.db0a6904.akpm@linux-foundation.org> <20090916034650.GD2756@core.coreip.homeip.net> <20090915211408.bb614be5.akpm@linux-foundation.org>
In-Reply-To: <20090915211408.bb614be5.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200909160900.10057.bjorn.helgaas@hp.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dmitry Torokhov <dmitry.torokhov@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, David =?iso-8859-1?q?H=E4rdeman?= <david@hardeman.nu>, Len Brown <lenb@kernel.org>
List-ID: <linux-mm.kvack.org>

On Tuesday 15 September 2009 10:14:08 pm Andrew Morton wrote:
> On Tue, 15 Sep 2009 20:46:50 -0700 Dmitry Torokhov <dmitry.torokhov@gmail.com> wrote:
> > > input-add-a-shutdown-method-to-pnp-drivers.patch
> > 
> > This should go through PNP tree (do we have one?).
> 
> Not really.  Bjorn heeps an eye on pnp.  Sometimes merges through acpi,
> sometimes through -mm.
> 
> I'll merge it I guess, but where is the corresponding change to the
> winbond driver?

I think this change looks good, and I think the winbond driver uses it.
I don't object to it going in via -mm so it stays together with the
winbond driver itself.

Bjorn

> From: David H_rdeman <david@hardeman.nu>
> 
> The shutdown method is used by the winbond cir driver to setup the
> hardware for wake-from-S5.
> 
> Signed-off-by: Bjorn Helgaas <bjorn.helgaas@hp.com>
> Signed-off-by: David H_rdeman <david@hardeman.nu>
> Cc: Dmitry Torokhov <dtor@mail.ru>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  drivers/pnp/driver.c |   10 ++++++++++
>  include/linux/pnp.h  |    1 +
>  2 files changed, 11 insertions(+)
> 
> diff -puN drivers/pnp/driver.c~input-add-a-shutdown-method-to-pnp-drivers drivers/pnp/driver.c
> --- a/drivers/pnp/driver.c~input-add-a-shutdown-method-to-pnp-drivers
> +++ a/drivers/pnp/driver.c
> @@ -135,6 +135,15 @@ static int pnp_device_remove(struct devi
>  	return 0;
>  }
>  
> +static void pnp_device_shutdown(struct device *dev)
> +{
> +	struct pnp_dev *pnp_dev = to_pnp_dev(dev);
> +	struct pnp_driver *drv = pnp_dev->driver;
> +
> +	if (drv && drv->shutdown)
> +		drv->shutdown(pnp_dev);
> +}
> +
>  static int pnp_bus_match(struct device *dev, struct device_driver *drv)
>  {
>  	struct pnp_dev *pnp_dev = to_pnp_dev(dev);
> @@ -203,6 +212,7 @@ struct bus_type pnp_bus_type = {
>  	.match   = pnp_bus_match,
>  	.probe   = pnp_device_probe,
>  	.remove  = pnp_device_remove,
> +	.shutdown = pnp_device_shutdown,
>  	.suspend = pnp_bus_suspend,
>  	.resume  = pnp_bus_resume,
>  	.dev_attrs = pnp_interface_attrs,
> diff -puN include/linux/pnp.h~input-add-a-shutdown-method-to-pnp-drivers include/linux/pnp.h
> --- a/include/linux/pnp.h~input-add-a-shutdown-method-to-pnp-drivers
> +++ a/include/linux/pnp.h
> @@ -360,6 +360,7 @@ struct pnp_driver {
>  	unsigned int flags;
>  	int (*probe) (struct pnp_dev *dev, const struct pnp_device_id *dev_id);
>  	void (*remove) (struct pnp_dev *dev);
> +	void (*shutdown) (struct pnp_dev *dev);
>  	int (*suspend) (struct pnp_dev *dev, pm_message_t state);
>  	int (*resume) (struct pnp_dev *dev);
>  	struct device_driver driver;
> _
> 
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
