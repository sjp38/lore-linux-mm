Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f43.google.com (mail-wg0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 7FC10900015
	for <linux-mm@kvack.org>; Thu, 19 Feb 2015 04:46:07 -0500 (EST)
Received: by mail-wg0-f43.google.com with SMTP id z12so6191925wgg.2
        for <linux-mm@kvack.org>; Thu, 19 Feb 2015 01:46:06 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n9si34825413wiw.72.2015.02.19.01.46.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 19 Feb 2015 01:46:05 -0800 (PST)
Date: Thu, 19 Feb 2015 10:46:04 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: How to controll Buffers to be dilligently reclaimed?
Message-ID: <20150219094604.GF28427@dhcp22.suse.cz>
References: <20150218142322.GD4680@dhcp22.suse.cz>
 <80963126.624722.1424288646764.JavaMail.yahoo@mail.yahoo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <80963126.624722.1424288646764.JavaMail.yahoo@mail.yahoo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cheng Rk <crquan@ymail.com>
Cc: Konstantin Khlebnikov <koct9i@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Wed 18-02-15 19:44:06, Cheng Rk wrote:
> 
> 
> On Wednesday, February 18, 2015 6:23 AM, Michal Hocko <mhocko@suse.cz> wrote:
> On Fri 13-02-15 09:52:16, Cheng Rk wrote:
> 
> > As per Documentation/sysctl/vm.txt the knob doesn't affect the page
> > cache reclaim but rather inode vs. dentry reclaim.
> 
> 
> So do you think is it worth to work on something to give pressure similar
> to vm.vfs_cache_pressure to vfs inode & dentry cache?
> 
> I am looking for an effect to let the kernel more aggressively reclaim
> memory from Buffers,

more aggressively than what? Anonymous memory, other types of caches?
To be honest I do not see why we should treat buffers any different from
any other cache. So far it is not clear what might be the issue you are
seeing but I would suspect that too many buffers is not the primary one.
It is hard to say anything more without any specific numbers, though.
 
> By reading fs/super.c:prune_super I've also realized taht, which is the
> only place referening sysctl_vfs_cache_pressure,
> that block_devices' inode are in "bdev" mount, its super_block just
> have nr_cached_objects as NULL,
> s_nr_dentry_unused and s_nr_inodes_unused both 0, get total_objects to be
> reclaimed is 0;
> 
> So is why sysctl_vfs_cache_pressure doesn't give pressure to Buffers,
> 
> 
>          if (sb->s_op && sb->s_op->nr_cached_objects)
>                    fs_objects = sb->s_op->nr_cached_objects(sb);
> 
>   total_objects = sb->s_nr_dentry_unused +
>                                          sb->s_nr_inodes_unused + fs_objects;
> 
>   total_objects = (total_objects / 100) * sysctl_vfs_cache_pressure;
>   drop_super(sb);
> 
> 
> In crash, I got to know this block_device (253:2, or /dev/dm-2)has
> 10536805 pages mapped, that is the 40GB memory in Buffers,

I still do not see why is that a problem. They should get reclaimed on
demand.

> I wonder is there a sysctl can controll this to be reclaimed earlier?

I do not know about any.

[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
