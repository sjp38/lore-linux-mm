Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 601456B00F1
	for <linux-mm@kvack.org>; Mon, 16 Apr 2012 10:25:03 -0400 (EDT)
Date: Mon, 16 Apr 2012 22:19:44 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [Lsf] [RFC] writeback and cgroup
Message-ID: <20120416141944.GA5750@localhost>
References: <20120404145134.GC12676@redhat.com>
 <20120407080027.GA2584@quack.suse.cz>
 <20120410180653.GJ21801@redhat.com>
 <20120410210505.GE4936@quack.suse.cz>
 <20120410212041.GP21801@redhat.com>
 <20120410222425.GF4936@quack.suse.cz>
 <20120411154005.GD16692@redhat.com>
 <1334406314.2528.90.camel@twins>
 <20120416125432.GB12776@redhat.com>
 <20120416130707.GA10532@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120416130707.GA10532@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vivek Goyal <vgoyal@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>, ctalbott@google.com, rni@google.com, andrea@betterlinux.com, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, lsf@lists.linux-foundation.org, linux-mm@kvack.org, jmoyer@redhat.com, lizefan@huawei.com, linux-fsdevel@vger.kernel.org, cgroups@vger.kernel.org

On Mon, Apr 16, 2012 at 09:07:07PM +0800, Fengguang Wu wrote:
> On Mon, Apr 16, 2012 at 08:54:32AM -0400, Vivek Goyal wrote:
> > On Sat, Apr 14, 2012 at 02:25:14PM +0200, Peter Zijlstra wrote:
> > > On Wed, 2012-04-11 at 11:40 -0400, Vivek Goyal wrote:
> > > > 
> > > > Ok, that's good to know. How would we configure this special bdi? I am
> > > > assuming there is no backing device visible in /sys/block/<device>/queue/?
> > > > Same is true for network file systems. 
> > > 
> > > root@twins:/usr/src/linux-2.6# awk '/nfs/ {print $3}' /proc/self/mountinfo | while read bdi ; do ls -la /sys/class/bdi/${bdi}/ ; done
> > > ls: cannot access /sys/class/bdi/0:20/: No such file or directory
> > > total 0
> > > drwxr-xr-x  3 root root    0 2012-03-27 23:18 .
> > > drwxr-xr-x 35 root root    0 2012-03-27 23:02 ..
> > > -rw-r--r--  1 root root 4096 2012-04-14 14:22 max_ratio
> > > -rw-r--r--  1 root root 4096 2012-04-14 14:22 min_ratio
> > > drwxr-xr-x  2 root root    0 2012-04-14 14:22 power
> > > -rw-r--r--  1 root root 4096 2012-04-14 14:22 read_ahead_kb
> > > lrwxrwxrwx  1 root root    0 2012-03-27 23:18 subsystem -> ../../../../class/bdi
> > > -rw-r--r--  1 root root 4096 2012-03-27 23:18 uevent
> > 
> > Ok, got it. So /proc/self/mountinfo has the information about st_dev and
> > one can use that to reach to associated bdi. Thanks Peter.
> 
> Vivek, I noticed these lines in cfq code
> 
>                 sscanf(dev_name(bdi->dev), "%u:%u", &major, &minor);
> 
> Why not use bdi->dev->devt?  The problem is that dev_name() will
> return "btrfs-X" for btrfs rather than "major:minor".

Sorry it's not that simple. btrfs reports its faked btrfs_fs_info.bdi
to upper layer which is different from the bdi's for
btrfs_fs_info.fs_devices.devices saw by cfq.

It's the faked btrfs bdi that is named "btrfs-X" by this function:

setup_bdi():
        bdi_setup_and_register(bdi, "btrfs", BDI_CAP_MAP_COPY);

It does impose difficulties to interpret btrfs mountinfo, where you
cannot directly get the block device major/minor numbers:

35 16 0:26 / /fs/sda3 rw,relatime - btrfs /dev/sda3 rw,noacl

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
