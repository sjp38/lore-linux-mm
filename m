Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id 11F476B004A
	for <linux-mm@kvack.org>; Thu, 12 Apr 2012 16:43:51 -0400 (EDT)
Date: Thu, 12 Apr 2012 16:37:19 -0400
From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [RFC] writeback and cgroup
Message-ID: <20120412203719.GL2207@redhat.com>
References: <20120403183655.GA23106@dhcp-172-17-108-109.mtv.corp.google.com>
 <20120404145134.GC12676@redhat.com>
 <20120407080027.GA2584@quack.suse.cz>
 <20120410180653.GJ21801@redhat.com>
 <20120410210505.GE4936@quack.suse.cz>
 <20120410212041.GP21801@redhat.com>
 <20120410222425.GF4936@quack.suse.cz>
 <20120411154005.GD16692@redhat.com>
 <20120411192231.GF16008@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120411192231.GF16008@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Tejun Heo <tj@kernel.org>, Fengguang Wu <fengguang.wu@intel.com>, Jens Axboe <axboe@kernel.dk>, linux-mm@kvack.org, sjayaraman@suse.com, andrea@betterlinux.com, jmoyer@redhat.com, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, lizefan@huawei.com, containers@lists.linux-foundation.org, cgroups@vger.kernel.org, ctalbott@google.com, rni@google.com, lsf@lists.linux-foundation.org

On Wed, Apr 11, 2012 at 09:22:31PM +0200, Jan Kara wrote:

[..]
> > >   Well, btrfs plays tricks with bdi's but there is a special bdi called
> > > "btrfs" which backs the whole filesystem and that is what's put in
> > > sb->s_bdi or in each inode's i_mapping->backing_dev_info. So we have a
> > > global bdi to work with.
> > 
> > Ok, that's good to know. How would we configure this special bdi? I am
> > assuming there is no backing device visible in /sys/block/<device>/queue/?
> > Same is true for network file systems.
>   Where should be the backing device visible? Now it's me who is lost :)

I mean how are we supposed to put cgroup throttling rules using cgroup
interface for network filesystems and for btrfs global bdi. Using "dev_t"
associated with bdi? I see that all the bdi's are showing up in
/sys/class/bdi, but how do I know which one I am intereste in or which
one belongs to filesystem I am interestd in putting throttling rule on.

For block devices, we simply use "major:min limit" format to write to
a cgroup file and this configuration will sit in one of the per queue
per cgroup data structure.

I am assuming that when you say throttling should happen at bdi, you
are thinking of maintaining per cgroup per bdi data structures and user
is somehow supposed to pass "bdi_maj:bdi_min  limit" through cgroup files?
If yes, how does one map a filesystem's bdi we want to put rules on?

Also, at request queue level we have bios and we throttle bios. At bdi
level, I think there are no bios yet. So somehow we got to deal with
pages. Not sure how exactly will throttling happen.

Thanks
Vivek

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
