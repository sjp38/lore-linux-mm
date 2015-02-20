Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f177.google.com (mail-ie0-f177.google.com [209.85.223.177])
	by kanga.kvack.org (Postfix) with ESMTP id 404F16B0032
	for <linux-mm@kvack.org>; Fri, 20 Feb 2015 15:36:23 -0500 (EST)
Received: by iecar1 with SMTP id ar1so10823201iec.0
        for <linux-mm@kvack.org>; Fri, 20 Feb 2015 12:36:23 -0800 (PST)
Received: from nm47-vm5.bullet.mail.ne1.yahoo.com (nm47-vm5.bullet.mail.ne1.yahoo.com. [98.138.121.101])
        by mx.google.com with ESMTPS id j76si7931417ioj.47.2015.02.20.12.36.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 20 Feb 2015 12:36:22 -0800 (PST)
Date: Fri, 20 Feb 2015 20:33:27 +0000 (UTC)
From: Cheng Rk <crquan@ymail.com>
Reply-To: Cheng Rk <crquan@ymail.com>
Message-ID: <1959255055.1630546.1424464407401.JavaMail.yahoo@mail.yahoo.com>
In-Reply-To: <20150219094604.GF28427@dhcp22.suse.cz>
References: <20150219094604.GF28427@dhcp22.suse.cz>
Subject: Re: How to controll Buffers to be dilligently reclaimed?
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Konstantin Khlebnikov <koct9i@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>


On Thursday, February 19, 2015 2:03 AM, Michal Hocko <mhocko@suse.cz> wrote:
>> So do you think is it worth to work on something to give pressure similar
>> to vm.vfs_cache_pressure to vfs inode & dentry cache?
>> 
>> I am looking for an effect to let the kernel more aggressively reclaim
>> memory from Buffers,

> more aggressively than what? Anonymous memory, other types of caches?
> To be honest I do not see why we should treat buffers any different from
> any other cache. So far it is not clear what might be the issue you are
> seeing but I would suspect that too many buffers is not the primary one.
> It is hard to say anything more without any specific numbers, though.


to get Buffers more aggresively, or ealier reclaimed than lazy on demand.

Suppose if someone can do a similar sysctl (say vm.vfs_buffers_pressure, or reuse vm.vfs_cache_presssure), do you think is that worth to do and useful?


I think what makes sense to vm.vfs_cache_presssure would also make sense
to controll Buffers, right?


So far I see people adjust vm.vfs_cache_pressure for various purposes;
from default 100 they set it to 50 for more conservatively reclaim
memory from cache, or set to a larger value (like 10000) to reclaim
the Cached memory earlier, or more aggresively, for Build farms,
or in any scenarios that files are all temporary and accessed only in a short time;

If those temporary files are finally removed, the Cached memory can be reclaimed,
but some cases they may be never removed,

For file backup applications, they can do madvise MADV_DONTNEED, but for
other applications unaware of MADV_DONTNEED, the kernel may never that
Cached memory is not used anymore, keep them for long time, and reclaimed on demand;


To reclaim early also has a benefit to save time of reclaim on demand; when in future application really need memory; I'm not sure if any applications are sensitive on time of allocation,,

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
