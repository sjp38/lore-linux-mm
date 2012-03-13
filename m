Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id B73786B00E7
	for <linux-mm@kvack.org>; Tue, 13 Mar 2012 18:16:52 -0400 (EDT)
Received: by yenm8 with SMTP id m8so1451828yen.14
        for <linux-mm@kvack.org>; Tue, 13 Mar 2012 15:16:51 -0700 (PDT)
Date: Tue, 13 Mar 2012 15:16:47 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC] cgroup: removing css reference drain wait during cgroup
 removal
Message-ID: <20120313221647.GG7349@google.com>
References: <20120312213155.GE23255@google.com>
 <20120313214526.GG19584@count0.beaverton.ibm.com>
 <20120313220551.GF7349@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120313220551.GF7349@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matt Helsley <matthltc@us.ibm.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, gthelen@google.com, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vivek Goyal <vgoyal@redhat.com>, Jens Axboe <axboe@kernel.dk>, Li Zefan <lizf@cn.fujitsu.com>, containers@lists.linux-foundation.org, cgroups@vger.kernel.org

(fixed up mailing list addresses)

On Tue, Mar 13, 2012 at 03:05:51PM -0700, Tejun Heo wrote:
> Hey, Matt.
> 
> On Tue, Mar 13, 2012 at 02:45:26PM -0700, Matt Helsley wrote:
> > If you want to spend your time doing archaeology there are some old threads
> > that touch on this idea (roughly around 2003-2005). One point against the
> > idea that I distinctly recall:
> > 
> > Somewhat like configfs, object lifetimes in cgroups are determined
> > primarily by the user whereas sysfs object lifetimes are primarily
> > determined by the kernel. I think the closest we come to user-determined
> > objects in sysfs occur through debugfs, and module loading/unloading.
> > However those involve mount/umount and modprobe/rmmod rather than
> > mkdir/rmdir to create and remove the objects.
> 
> The thing is that sysfs itself has been almost completely rewritten
> since that time to 1. decouple internal representation from vfs
> objects and 2. provide proper isolation between the userland and
> kernel code exposing data through sysfs.
> 
> #1 began mostly due to the large size of dentries and inodes but, with
> the benefit of hindsight, I think it just was a bad idea to piggyback
> on vfs objects for object life-cycle management and locking for stuff
> which is wholely described in memory with simplistic locking.
> 
> #2 was necessary to avoid hanging device detach due to open sysfs file
> from userland.  sysfs now has notion of "active access" encompassing
> only each show/store op invocation and it only guarantees that the
> associated device doesn't go away while active accesses are in
> progress.
> 
> The sysfs heritage is almost recognizable and unfortunately almost the
> same set of problems (nobody wants show/store ops to be called on
> unlinked css waiting for references to be drained).  As refactoring
> and sharing sysfs won't be a trivial task, my plan is to first augment
> cgroupfs as necessary with longer term goal of converging and later
> sharing the same code with sysfs.

Sorry, forgot to reply to the userland-determined object
creation/deletion part.

I don't think there are direct creation cases in sysfs but there are
plenty of deletion going on, especially the kind where a file requests
to delete its parent directly (*/device/delete).  While using
mkdir/rmdir indeed is different for cgroupfs, I don't think that would
make too much of difference.  Both calls are essentially unused by
sysfs currently and there's nothing preventing addition of callbacks
there.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
