Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 248D46B007E
	for <linux-mm@kvack.org>; Sun, 14 Feb 2010 16:37:56 -0500 (EST)
Date: Mon, 15 Feb 2010 08:37:24 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v2] Make VM_MAX_READAHEAD a kernel parameter
Message-ID: <20100214213724.GA28392@discord.disaster>
References: <201002091659.27037.knikanth@suse.de> <201002111546.35036.knikanth@suse.de> <d24465cb1002110315x4af18888na55aa8d61478e094@mail.gmail.com> <201002111715.04411.knikanth@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201002111715.04411.knikanth@suse.de>
Sender: owner-linux-mm@kvack.org
To: Nikanth Karthikesan <knikanth@suse.de>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Ankit Jain <radical@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, Jens Axboe <jens.axboe@oracle.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Thu, Feb 11, 2010 at 05:15:03PM +0530, Nikanth Karthikesan wrote:
> On Thursday 11 February 2010 16:45:24 Ankit Jain wrote:
> > > +static int __init readahead(char *str)
> > > +{
> > > +       if (!str)
> > > +               return -EINVAL;
> > > +       vm_max_readahead_kb = memparse(str, &str) / 1024ULL;
> > 
> > Just wondering, shouldn't you check whether the str had a valid value
> > [memparse (str, &next); next > str ..] and if it didn't, then use the
> > DEFAULT_VM_MAX_READAHEAD ? Otherwise, incase of a invalid
> > value, the readahead value will become zero.
> > 
> 
> Thanks for the review. Here is the fixed patch that checks whether all of the
> parameters value is consumed.
> 
> Thanks
> Nikanth
> 
> From: Nikanth Karthikesan <knikanth@suse.de>
> 
> Add new kernel parameter "readahead", which would be used instead of the
> value of VM_MAX_READAHEAD. If the parameter is not specified, the default
> of 128kb would be used.
> 
> Signed-off-by: Nikanth Karthikesan <knikanth@suse.de>
> 
> ---
> 
> diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
> index 736d456..354e6f1 100644
> --- a/Documentation/kernel-parameters.txt
> +++ b/Documentation/kernel-parameters.txt
> @@ -2148,6 +2148,8 @@ and is between 256 and 4096 characters. It is defined in the file
>  			Format: <reboot_mode>[,<reboot_mode2>[,...]]
>  			See arch/*/kernel/reboot.c or arch/*/kernel/process.c
>  
> +	readahead=	Default readahead value for block devices.
> +

I think the description should define the units (kb) and valid value
ranges e.g. page size to something not excessive - say 65536kb.  The
above description is, IMO, useless without refering to the source to
find out this information....

[snip]

> @@ -249,6 +250,24 @@ static int __init loglevel(char *str)
>  
>  early_param("loglevel", loglevel);
>  
> +static int __init readahead(char *str)
> +{
> +	unsigned long readahead_kb;
> +
> +	if (!str)
> +		return -EINVAL;
> +	readahead_kb = memparse(str, &str) / 1024ULL;
> +	if (*str != '\0')
> +		return -EINVAL;

And readahead_kb needs to be validated against the range of
valid values here.

> +
> +	vm_max_readahead_kb = readahead_kb;
> +	default_backing_dev_info.ra_pages = vm_max_readahead_kb
> +						* 1024 / PAGE_CACHE_SIZE;
> +	return 0;
> +}
> +
> +early_param("readahead", readahead);
> +

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
