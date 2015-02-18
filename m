Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f181.google.com (mail-ie0-f181.google.com [209.85.223.181])
	by kanga.kvack.org (Postfix) with ESMTP id 73C646B00A0
	for <linux-mm@kvack.org>; Wed, 18 Feb 2015 14:46:56 -0500 (EST)
Received: by iebtr6 with SMTP id tr6so3960351ieb.10
        for <linux-mm@kvack.org>; Wed, 18 Feb 2015 11:46:56 -0800 (PST)
Received: from nm45-vm6.bullet.mail.ne1.yahoo.com (nm45-vm6.bullet.mail.ne1.yahoo.com. [98.138.121.70])
        by mx.google.com with ESMTPS id i136si17693686ioe.103.2015.02.18.11.46.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 18 Feb 2015 11:46:55 -0800 (PST)
Date: Wed, 18 Feb 2015 19:44:06 +0000 (UTC)
From: Cheng Rk <crquan@ymail.com>
Reply-To: Cheng Rk <crquan@ymail.com>
Message-ID: <80963126.624722.1424288646764.JavaMail.yahoo@mail.yahoo.com>
In-Reply-To: <20150218142322.GD4680@dhcp22.suse.cz>
References: <20150218142322.GD4680@dhcp22.suse.cz>
Subject: Re: How to controll Buffers to be dilligently reclaimed?
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Konstantin Khlebnikov <koct9i@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>



On Wednesday, February 18, 2015 6:23 AM, Michal Hocko <mhocko@suse.cz> wrote:
On Fri 13-02-15 09:52:16, Cheng Rk wrote:

> As per Documentation/sysctl/vm.txt the knob doesn't affect the page
> cache reclaim but rather inode vs. dentry reclaim.


So do you think is it worth to work on something to give pressure similar
to vm.vfs_cache_pressure to vfs inode & dentry cache?

I am looking for an effect to let the kernel more aggressively reclaim
memory from Buffers,


By reading fs/super.c:prune_super I've also realized taht, which is the
only place referening sysctl_vfs_cache_pressure,
that block_devices' inode are in "bdev" mount, its super_block just
have nr_cached_objects as NULL,
s_nr_dentry_unused and s_nr_inodes_unused both 0, get total_objects to be
reclaimed is 0;

So is why sysctl_vfs_cache_pressure doesn't give pressure to Buffers,


         if (sb->s_op && sb->s_op->nr_cached_objects)
                   fs_objects = sb->s_op->nr_cached_objects(sb);

  total_objects = sb->s_nr_dentry_unused +
                                         sb->s_nr_inodes_unused + fs_objects;

  total_objects = (total_objects / 100) * sysctl_vfs_cache_pressure;
  drop_super(sb);


In crash, I got to know this block_device (253:2, or /dev/dm-2)has 10536805 pages mapped, that is the 40GB memory in Buffers, I wonder is there a sysctl can controll this to be reclaimed earlier?


crash> block_device.bd_dev,bd_inode -x ffff880619c78000
bd_dev = 0xfd00002
bd_inode = 0xffff880619c780f0
crash> inode.i_mapping 0xffff880619c780f0
i_mapping = 0xffff880619c78240
crash> address_space.nrpages 0xffff880619c78240
nrpages = 10536805


>> I have some oom-killer msgs but were with older kernels, after set>> vm.overcommit_memory=2, it simply returns -ENOMEM, unable to spawn any
>> new container, why doesn't it even try to reclaim some memory from

>> those 40GB Buffers,> overcommit_memory controls behavior of the _virtual_ memory
> reservations. OVERCOMMIT_NEVER (2) means that even virtual memory cannot
> be overcommit outside of the configured value (RAM + swap basically -
> see Documentation/vm/overcommit-accounting for more information). So
> your application most probably consumes a lot of virtual memory (mmaps
> etc.) and that is why it gets ENOMEM.


I have read that Doc as well, will post again when I get a more concrete example

> OOM report would tell us what was the memory state at the time when you
> were short of memory and why the cache (buffers in your case) were not
> reclaimed properly.


Thanks,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
