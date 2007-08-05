Date: Sun, 5 Aug 2007 20:29:30 +0100
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH 00/23] per device dirty throttling -v8
Message-ID: <20070805202930.4ce62542@the-village.bc.nu>
In-Reply-To: <20070805190928.GA17433@elte.hu>
References: <20070804103347.GA1956@elte.hu>
	<alpine.LFD.0.999.0708040915360.5037@woody.linux-foundation.org>
	<20070804163733.GA31001@elte.hu>
	<alpine.LFD.0.999.0708041030040.5037@woody.linux-foundation.org>
	<46B4C0A8.1000902@garzik.org>
	<20070805102021.GA4246@unthought.net>
	<46B5A996.5060006@garzik.org>
	<20070805105850.GC4246@unthought.net>
	<20070805124648.GA21173@elte.hu>
	<alpine.LFD.0.999.0708050944470.5037@woody.linux-foundation.org>
	<20070805190928.GA17433@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Jakob Oestergaard <jakob@unthought.net>, Jeff Garzik <jeff@garzik.org>, miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, richard@rsk.demon.co.uk, david@lang.hm
List-ID: <linux-mm.kvack.org>

> change relatime updates to be performed once per day. This makes
> relatime a compatible solution for HSM, mailer-notification and
> tmpwatch applications too.

Sweet
> 

> also add the CONFIG_DEFAULT_RELATIME kernel option, which makes
> "norelatime" the default for all mounts without an extra kernel
> boot option.

Should be a mount option.


> +	relatime        [FS] default to enabled relatime updates on all
> +			filesystems.
> +
> +	relatime=       [FS] default to enabled/disabled relatime updates on
> +			all filesystems.
> +

Double patch

>  	atkbd.extra=	[HW] Enable extra LEDs and keys on IBM RapidAccess,
>  			EzKey and similar keyboards
>  
> @@ -1100,6 +1106,12 @@ and is between 256 and 4096 characters. 
>  	noasync		[HW,M68K] Disables async and sync negotiation for
>  			all devices.
>  
> +	norelatime      [FS] default to disabled relatime updates on all
> +			filesystems.
> +
> +	norelatime=     [FS] default to disabled/enabled relatime updates
> +			on all filesystems.
> +

Double patch

> +config DEFAULT_RELATIME
> +	bool "Mount all filesystems with relatime by default"
> +	default y

Changes behaviour so probably should default n. Better yet it should be
the mount option so its flexible and strongly encouraged for vendors.

>  /*
> + * Allow users to disable (or enable) atime updates via a .config
> + * option or via the boot line, or via /proc/sys/fs/mount_with_relatime:
> + */
> +int mount_with_relatime __read_mostly =
> +#ifdef CONFIG_DEFAULT_RELATIME
> +1
> +#else
> +0
> +#endif
> +;

This ifdef mess would go away for a mount option

> +/*
> + * The "norelatime=", "atime=", "norelatime" and "relatime" boot parameters:
> + */
> +static int toggle_relatime_updates(int val)
> +{
> +	mount_with_relatime = val;
> +
> +	printk("Relative atime updates are: %s\n", val ? "on" : "off");
> +
> +	return 1;
> +}
> +
> +static int __init set_relatime_setup(char *str)
> +{
> +	int val;
> +
> +	get_option(&str, &val);
> +	return toggle_relatime_updates(val);
> +}
> +__setup("relatime=", set_relatime_setup);
> +
> +static int __init set_norelatime_setup(char *str)
> +{
> +	int val;
> +
> +	get_option(&str, &val);
> +	return toggle_relatime_updates(!val);
> +}
> +__setup("norelatime=", set_norelatime_setup);
> +
> +static int __init set_relatime(char *str)
> +{
> +	return toggle_relatime_updates(1);
> +}
> +__setup("relatime", set_relatime);
> +
> +static int __init set_norelatime(char *str)
> +{
> +	return toggle_relatime_updates(0);
> +}
> +__setup("norelatime", set_norelatime);


All the above chunk is unneccessary as it can be a mount option. That
avoids tons of messy extra code and complication. Users are far safer
editing fstab than grub.conf.

> +	{
> +		.ctl_name	= CTL_UNNUMBERED,
> +		.procname	= "mount_with_relatime",
> +		.data		= &mount_with_relatime,
> +		.maxlen		= sizeof(int),
> +		.mode		= 0644,
> +		.proc_handler	= &proc_dointvec,
> +	},

More code you don't need if you just leave it as a mount option.

I'd much rather see the small clean patch for this as a mount option.
Leave the rest to users/distros/lwn and it'll just happen now you've
sorted the compabitility problems.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
