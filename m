Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6EAA96B0038
	for <linux-mm@kvack.org>; Tue, 10 Jan 2017 04:22:43 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id s63so19966524wms.7
        for <linux-mm@kvack.org>; Tue, 10 Jan 2017 01:22:43 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a10si1137364wjv.8.2017.01.10.01.22.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 10 Jan 2017 01:22:42 -0800 (PST)
Date: Tue, 10 Jan 2017 10:22:41 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [BUG] How to crash 4.9.2 x86_64: vmscan: shrink_slab
Message-ID: <20170110092241.GA28032@dhcp22.suse.cz>
References: <20170109210210.2zgvw6nfs4qbgmjw@m.mifar.in>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170109210210.2zgvw6nfs4qbgmjw@m.mifar.in>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sami Farin <hvtaifwkbgefbaei@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon 09-01-17 23:02:10, Sami Farin wrote:
> # sysctl vm.vfs_cache_pressure=-100
> 
> kernel: vmscan: shrink_slab: super_cache_scan+0x0/0x1a0 negative objects to delete nr=-6640827866535449472
> kernel: vmscan: shrink_slab: super_cache_scan+0x0/0x1a0 negative objects to delete nr=-6640827866535450112
> kernel: vmscan: shrink_slab: super_cache_scan+0x0/0x1a0 negative objects to delete nr=-661702561611775889
> kernel: vmscan: shrink_slab: super_cache_scan+0x0/0x1a0 negative objects to delete nr=-6640827866535442432
> kernel: vmscan: shrink_slab: super_cache_scan+0x0/0x1a0 negative objects to delete nr=-6562613194205300197
> kernel: vmscan: shrink_slab: super_cache_scan+0x0/0x1a0 negative objects to delete nr=-6640827866535439872
> kernel: vmscan: shrink_slab: super_cache_scan+0x0/0x1a0 negative objects to delete nr=-659655090764208789
> kernel: vmscan: shrink_slab: super_cache_scan+0x0/0x1a0 negative objects to delete nr=-6564660665198832072
> kernel: vmscan: shrink_slab: super_cache_scan+0x0/0x1a0 negative objects to delete nr=-6562613194351275164
> kernel: vmscan: shrink_slab: super_cache_scan+0x0/0x1a0 negative objects to delete nr=-6562615996648922728
> kernel: vmscan: shrink_slab: super_cache_scan+0x0/0x1a0 negative objects to delete nr=-6564660665198832072
> kernel: vmscan: shrink_slab: super_cache_scan+0x0/0x1a0 negative objects to delete nr=-6562613194351264981
> kernel: vmscan: shrink_slab: super_cache_scan+0x0/0x1a0 negative objects to delete nr=-569296135781119076
> kernel: vmscan: shrink_slab: super_cache_scan+0x0/0x1a0 negative objects to delete nr=-565206492037048430
> kernel: vmscan: shrink_slab: super_cache_scan+0x0/0x1a0 negative objects to delete nr=-565212096665106188
> kernel: vmscan: shrink_slab: super_cache_scan+0x0/0x1a0 negative objects to delete nr=-569296135781119076
> kernel: vmscan: shrink_slab: super_cache_scan+0x0/0x1a0 negative objects to delete nr=-565206492037043196
> kernel: vmscan: shrink_slab: super_cache_scan+0x0/0x1a0 negative objects to delete nr=-659660388715270673
> 
> 
> Alternatively,
> # sysctl vm.vfs_cache_pressure=10000000

Both values are insane and admins do not do insane things to their
machines, do they?

I am not sure how much we want to check the input value. -100 is clearly
bogus and 

		.procname	= "vfs_cache_pressure",
		.data		= &sysctl_vfs_cache_pressure,
		.maxlen		= sizeof(sysctl_vfs_cache_pressure),
		.mode		= 0644,
		.proc_handler	= &proc_dointvec,
		.extra1		= &zero,

tries to enforce min (extra1) check except proc_dointvec doesn't care
about this... This is news to me. Only proc_dointvec_minmax does care
about extra*, it seems.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
