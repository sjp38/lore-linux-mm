Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id B9EB96B0033
	for <linux-mm@kvack.org>; Wed, 19 Jun 2013 10:28:03 -0400 (EDT)
Date: Wed, 19 Jun 2013 16:28:01 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: linux-next: slab shrinkers: BUG at mm/list_lru.c:92
Message-ID: <20130619142801.GA21483@dhcp22.suse.cz>
References: <20130617141822.GF5018@dhcp22.suse.cz>
 <20130617151403.GA25172@localhost.localdomain>
 <20130617143508.7417f1ac9ecd15d8b2877f76@linux-foundation.org>
 <20130617223004.GB2538@localhost.localdomain>
 <20130618062623.GA20528@localhost.localdomain>
 <20130619071346.GA9545@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130619071346.GA9545@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed 19-06-13 09:13:46, Michal Hocko wrote:
> On Tue 18-06-13 10:26:24, Glauber Costa wrote:
> [...]
> > Michal, would you mind testing the following patch?
> >
> > diff --git a/fs/inode.c b/fs/inode.c
> > index 00b804e..48eafa6 100644
> > --- a/fs/inode.c
> > +++ b/fs/inode.c
> > @@ -419,6 +419,8 @@ void inode_add_lru(struct inode *inode)
> >  
> >  static void inode_lru_list_del(struct inode *inode)
> >  {
> > +	if (inode->i_state & I_FREEING)
> > +		return;
> >  
> >  	if (list_lru_del(&inode->i_sb->s_inode_lru, &inode->i_lru))
> >  		this_cpu_dec(nr_unused);
> > @@ -609,8 +611,8 @@ void evict_inodes(struct super_block *sb)
> >  			continue;
> >  		}
> >  
> > -		inode->i_state |= I_FREEING;
> >  		inode_lru_list_del(inode);
> > +		inode->i_state |= I_FREEING;
> >  		spin_unlock(&inode->i_lock);
> >  		list_add(&inode->i_lru, &dispose);
> >  	}
> > @@ -653,8 +655,8 @@ int invalidate_inodes(struct super_block *sb, bool kill_dirty)
> >  			continue;
> >  		}
> >  
> > -		inode->i_state |= I_FREEING;
> >  		inode_lru_list_del(inode);
> > +		inode->i_state |= I_FREEING;
> >  		spin_unlock(&inode->i_lock);
> >  		list_add(&inode->i_lru, &dispose);
> >  	}
> > @@ -1381,9 +1383,8 @@ static void iput_final(struct inode *inode)
> >  		inode->i_state &= ~I_WILL_FREE;
> >  	}
> >  
> > +	inode_lru_list_del(inode);
> >  	inode->i_state |= I_FREEING;
> > -	if (!list_empty(&inode->i_lru))
> > -		inode_lru_list_del(inode);
> >  	spin_unlock(&inode->i_lock);
> >  
> >  	evict(inode);
> 
> No luck. I have this on top of inode_lru_isolate one but still can see

And I was lucky enough to hit another BUG_ON with this kernel (the above
patch and inode_lru_isolate-fix):
[84091.219056] ------------[ cut here ]------------
[84091.220015] kernel BUG at mm/list_lru.c:42!
[84091.220015] invalid opcode: 0000 [#1] SMP 
[84091.220015] Modules linked in: edd nfsv3 nfs_acl nfs fscache lockd sunrpc af_packet bridge stp llc cpufreq_conservative cpufreq_userspace cpufreq_powersave fuse loop dm_mod powernow_k8 tg3 kvm_amd kvm ptp e1000 pps_core shpchp edac_core i2c_amd756 amd_rng pci_hotplug k8temp sg i2c_amd8111 edac_mce_amd serio_raw sr_mod pcspkr cdrom button ohci_hcd ehci_hcd usbcore usb_common processor thermal_sys scsi_dh_emc scsi_dh_rdac scsi_dh_hp_sw scsi_dh ata_generic sata_sil pata_amd
[84091.220015] CPU 1 
[84091.220015] Pid: 32545, comm: rm Not tainted 3.9.0mmotmdebugging1+ #1472 AMD A8440/WARTHOG
[84091.220015] RIP: 0010:[<ffffffff81127fff>]  [<ffffffff81127fff>] list_lru_del+0xcf/0xe0
[84091.220015] RSP: 0018:ffff88001de85df8  EFLAGS: 00010286
[84091.220015] RAX: ffffffffffffffff RBX: ffff88001e1ce2c0 RCX: 0000000000000002
[84091.220015] RDX: ffff88001e1ce2c8 RSI: ffff8800087f4220 RDI: ffff88001e1ce2c0
[84091.220015] RBP: ffff88001de85e18 R08: 0000000000000000 R09: 0000000000000000
[84091.220015] R10: ffff88001d539128 R11: ffff880018234882 R12: ffff8800087f4220
[84091.220015] R13: ffff88001c68bc40 R14: 0000000000000000 R15: ffff88001de85ea8
[84091.220015] FS:  00007f43adb30700(0000) GS:ffff88001f100000(0000) knlGS:0000000000000000
[84091.220015] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[84091.220015] CR2: 0000000001ffed30 CR3: 000000001e02e000 CR4: 00000000000007e0
[84091.220015] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[84091.220015] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[84091.220015] Process rm (pid: 32545, threadinfo ffff88001de84000, task ffff88001c22e5c0)
[84091.220015] Stack:
[84091.220015]  ffff8800087f4130 ffff8800087f41b8 ffff88001c68b800 0000000000000000
[84091.220015]  ffff88001de85e48 ffffffff81184357 ffff88001de85e48 ffff8800087f4130
[84091.220015]  ffff88001e005000 ffff880014e4eb40 ffff88001de85e68 ffffffff81184418
[84091.220015] Call Trace:
[84091.220015]  [<ffffffff81184357>] iput_final+0x117/0x190
[84091.220015]  [<ffffffff81184418>] iput+0x48/0x60
[84091.220015]  [<ffffffff8117a804>] do_unlinkat+0x214/0x240
[84091.220015]  [<ffffffff8117aa4d>] sys_unlinkat+0x1d/0x40
[84091.220015]  [<ffffffff81583129>] system_call_fastpath+0x16/0x1b
[84091.220015] Code: 5c 41 5d b8 01 00 00 00 41 5e c9 c3 49 8d 45 08 f0 45 0f b3 75 08 eb db 0f 1f 40 00 66 83 03 01 5b 41 5c 41 5d 31 c0 41 5e c9 c3 <0f> 0b eb fe 66 66 66 66 2e 0f 1f 84 00 00 00 00 00 55 ba 00 00 
[84091.220015] RIP  [<ffffffff81127fff>] list_lru_del+0xcf/0xe0
[84091.220015]  RSP <ffff88001de85df8>
[84091.470390] ---[ end trace e6915e8ee0f5f079 ]---

Which is BUG_ON(nlru->nr_items < 0) from iput_final path. So it seems
that there is still a race there.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
