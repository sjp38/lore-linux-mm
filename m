Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 29A9B6B0087
	for <linux-mm@kvack.org>; Thu,  9 Dec 2010 12:48:19 -0500 (EST)
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <19713.5738.653711.301814@quad.stoffel.home>
Date: Thu, 9 Dec 2010 12:48:26 -0500
From: "John Stoffel" <john@stoffel.org>
Subject: Re: [PATCH] fs/vfs/security: pass last path component to LSM on
 inode creation
In-Reply-To: <1291909941.3072.70.camel@localhost.localdomain>
References: <20101208194527.13537.77202.stgit@paris.rdu.redhat.com>
	<19712.61515.201226.938553@quad.stoffel.home>
	<1291909941.3072.70.camel@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
To: Eric Paris <eparis@redhat.com>
Cc: John Stoffel <john@stoffel.org>, xfs-masters@oss.sgi.com, linux-btrfs@vger.kernel.org, linux-kernel@vger.kernel.org, linux-ext4@vger.kernel.org, cluster-devel@redhat.com, linux-mtd@lists.infradead.org, jfs-discussion@lists.sourceforge.net, ocfs2-devel@oss.oracle.com, reiserfs-devel@vger.kernel.org, xfs@oss.sgi.com, linux-mm@kvack.org, linux-security-module@vger.kernel.org, chris.mason@oracle.com, jack@suse.cz, akpm@linux-foundation.org, adilger.kernel@dilger.ca, tytso@mit.edu, swhiteho@redhat.com, dwmw2@infradead.org, shaggy@linux.vnet.ibm.com, mfasheh@suse.com, joel.becker@oracle.com, aelder@sgi.com, hughd@google.com, jmorris@namei.org, sds@tycho.nsa.gov, eparis@parisplace.org, hch@lst.de, dchinner@redhat.com, viro@zeniv.linux.org.uk, tao.ma@oracle.com, shemminger@vyatta.com, jeffm@suse.com, paul.moore@hp.com, penguin-kernel@I-love.SAKURA.ne.jp, casey@schaufler-ca.com, kees.cook@canonical.com, dhowells@redhat.com
List-ID: <linux-mm.kvack.org>

>>>>> "Eric" == Eric Paris <eparis@redhat.com> writes:

Eric> On Thu, 2010-12-09 at 10:05 -0500, John Stoffel wrote:
>> >>>>> "Eric" == Eric Paris <eparis@redhat.com> writes:

>> So what happens when I create a file /home/john/shadow, does selinux
>> (or LSM in general) then run extra checks because the filename is
>> 'shadow' in your model?  

Eric> It's entirely a question of labeling and one that was discussed on the
Eric> LSM list in some detail:

Eric> http://marc.info/?t=129141308200002&r=1&w=2

Thank you for pointing me at this discussion.  I'm working my way
through it, but so far I'm not seeing any consensus that this is
really the proper thing to do.  I personally feel this should be in
userspace if at all possible.

Eric> The basic synopsis is that when a new inode is created SELinux
Eric> must apply some label.  It makes the decision for what label to
Eric> apply based on 3 pieces of information.

Eric> The label of the parent inode.
Eric> The label of the process creating the new inode.
Eric> The 'class' of the inode, S_ISREG, S_ISDIR, S_ISLNK, etc

These seem to be ok, if you're using label based security.  But since
I freely admit I'm not an expert or even a user, I'm just trying to
understand and push back to make sure we do what's good.  And which
doesn't impact non-SElinux users.  

Eric> This patch adds a 4th piece of information, the name of the
Eric> object being created.  An obvious situation where this will be
Eric> useful is devtmpfs (although you'll find other examples in the
Eric> above thread).  devtmpfs when it creates char/block devices is
Eric> unable to distinguish between kmem and console and so they are
Eric> created with a generic label.  hotplug/udev is then called which
Eric> does some pathname like matching and relabels them to something
Eric> more specific.  We've found that many people are able to race
Eric> against this particular updating and get spurious denials in
Eric> /dev.  With this patch devtmpfs will be able to get the labels
Eric> correct to begin with.

So your Label based access controls are *also* based on pathnames?
Right?  

Eric> I'm certainly willing to discuss the security implications of this
Eric> patch, but that would probably be best done with a significantly
Eric> shortened cc-list.  You'll see in the above mentioned thread that a
Eric> number of 'security' people (even those who are staunchly anti-SELinux)
Eric> recognize there is value in this and that it is certainly much better
Eric> than we have today.

>> I *think* the overhead shouldn't be there if SELINUX is disabled, but
>> have you confirmed this?  How you run performance tests before/after
>> this change when doing lots of creations of inodes to see what sort of
>> performance changes might be there?

Eric> I've actually recently done some perf testing on creating large
Eric> numbers of inodes using bonnie++, since SELinux was a noticeable
Eric> overhead in that operation.  Doing that same test with SELinux
Eric> disabled (or enabled) I do not see a noticeable difference when
Eric> this patch is applied or not.  It's just an extra argument to a
Eric> function that goes unused.

That answers alot of my concerns then.  Not having it impact users in
a non-SELinux context is vitally important to me.

Thanks,
John

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
