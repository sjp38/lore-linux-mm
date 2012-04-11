Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id BF7386B004A
	for <linux-mm@kvack.org>; Wed, 11 Apr 2012 11:40:55 -0400 (EDT)
Date: Wed, 11 Apr 2012 11:40:05 -0400
From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [RFC] writeback and cgroup
Message-ID: <20120411154005.GD16692@redhat.com>
References: <20120403183655.GA23106@dhcp-172-17-108-109.mtv.corp.google.com>
 <20120404145134.GC12676@redhat.com>
 <20120407080027.GA2584@quack.suse.cz>
 <20120410180653.GJ21801@redhat.com>
 <20120410210505.GE4936@quack.suse.cz>
 <20120410212041.GP21801@redhat.com>
 <20120410222425.GF4936@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120410222425.GF4936@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Tejun Heo <tj@kernel.org>, Fengguang Wu <fengguang.wu@intel.com>, Jens Axboe <axboe@kernel.dk>, linux-mm@kvack.org, sjayaraman@suse.com, andrea@betterlinux.com, jmoyer@redhat.com, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, lizefan@huawei.com, containers@lists.linux-foundation.org, cgroups@vger.kernel.org, ctalbott@google.com, rni@google.com, lsf@lists.linux-foundation.org

On Wed, Apr 11, 2012 at 12:24:25AM +0200, Jan Kara wrote:

[..]
> > I have implemented and posted patches for per bdi per cgroup congestion
> > flag. The only problem I see with that is that a group might be congested
> > for a long time because of lots of other IO happening (say direct IO) and
> > if you keep on backing off and never submit the metadata IO (transaction),
> > you get starved. And if you go ahead and submit IO in a congested group,
> > we are back to serialization issue.
>   Clearly, we mustn't throttle metadata IO once it gets to the block layer.
> That's why we discuss throttling of processes at transaction start after
> all. But I agree starvation is an issue - I originally thought blk-throttle
> throttles synchronously which wouldn't have starvation issues. But when
> that's not the case things are a bit more tricky. We could treat
> transaction start as an IO of some size (since we already have some
> estimation how large a transaction will be when we are starting it) and let
> the transaction start only when our "virtual" IO would be submitted but
> I feel that gets maybe too complicated... Maybe we could just delay the
> transaction start by the amount reported from blk-throttle layer? Something
> along your callback for throttling you implemented?

I think now I have lost you. It probably stems from the fact that I don't
know much about transactions and filesystem.
 
So all the metadata IO will happen thorough journaling thread and that
will be in root group which should remain unthrottled. So any journal
IO going to disk should remain unthrottled.

Now, IIRC, fsync problem with throttling was that we had opened a
transaction but could not write it back to disk because we had to
wait for all the cached data to go to disk (which is throttled). So
my question is, can't we first wait for all the data to be flushed
to disk and then open a transaction for metadata. metadata will be
unthrottled so filesystem will not have to do any tricks like bdi is
congested or not.

IOW, can't we first wait for dependent operation to finish before we
throw anything into metada stream.

[..]
> > I guess throttling at bdi layer will take care of network filesystem
> > case too?
>   Yes. At least for client side. On sever side Steve wants server to have
> insight into how much IO we could push in future so that it can limit
> number of outstanding requests if I understand him right. I'm not sure we
> really want / are able to provide this amount of knowledge to filesystems
> even less userspace...

I am not sure what does it mean but server could simply query the bdi
and read configured rate and then it knows at what rate IO will go to
disk and make predictions about future?

> 
> > But isn't the notion of "bdi" internal to kernel and user does
> > not really program thing in terms of bdi.
>   Well, it is. But we already have per-bdi tunables (e.g.  readahead) that
> are exported in /sys/block/<device>/queue/ so we have some precedens.

ok, so they are exposed as if they are queue/device tunables but
internally stored in bdi and work accordingly.

>  
> > Also per bdi limit mechanism will not solve the issue of global throttling
> > where in case of btrfs an IO might go to multiple bdi's. So throttling limits
> > are not total but per bdi.
>   Well, btrfs plays tricks with bdi's but there is a special bdi called
> "btrfs" which backs the whole filesystem and that is what's put in
> sb->s_bdi or in each inode's i_mapping->backing_dev_info. So we have a
> global bdi to work with.

Ok, that's good to know. How would we configure this special bdi? I am
assuming there is no backing device visible in /sys/block/<device>/queue/?
Same is true for network file systems.

Thanks
Vivek

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
