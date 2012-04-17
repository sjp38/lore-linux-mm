Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 126BA6B004A
	for <linux-mm@kvack.org>; Tue, 17 Apr 2012 17:48:37 -0400 (EDT)
Received: by pbcup15 with SMTP id up15so10253055pbc.14
        for <linux-mm@kvack.org>; Tue, 17 Apr 2012 14:48:36 -0700 (PDT)
Date: Tue, 17 Apr 2012 14:48:31 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC] writeback and cgroup
Message-ID: <20120417214831.GE19975@google.com>
References: <20120403183655.GA23106@dhcp-172-17-108-109.mtv.corp.google.com>
 <20120404145134.GC12676@redhat.com>
 <20120407080027.GA2584@quack.suse.cz>
 <20120410180653.GJ21801@redhat.com>
 <20120410210505.GE4936@quack.suse.cz>
 <20120410212041.GP21801@redhat.com>
 <20120410222425.GF4936@quack.suse.cz>
 <20120411154005.GD16692@redhat.com>
 <20120411154531.GE16692@redhat.com>
 <20120411170542.GB16008@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120411170542.GB16008@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Vivek Goyal <vgoyal@redhat.com>, Fengguang Wu <fengguang.wu@intel.com>, Jens Axboe <axboe@kernel.dk>, linux-mm@kvack.org, sjayaraman@suse.com, andrea@betterlinux.com, jmoyer@redhat.com, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, lizefan@huawei.com, containers@lists.linux-foundation.org, cgroups@vger.kernel.org, ctalbott@google.com, rni@google.com, lsf@lists.linux-foundation.org

Hello,

On Wed, Apr 11, 2012 at 07:05:42PM +0200, Jan Kara wrote:
> > The additional feature for buffered throttle (which never went upstream),
> > was synchronous in nature. That is we were actively putting writer to
> > sleep on a per cgroup wait queue in the request queue and wake it up when
> > it can do further IO based on cgroup limits.
>
>   Hmm, but then there would be similar starvation issues as with my simple
> scheme because async IO could always use the whole available bandwidth.
> Mixing of sync & async throttling is really problematic... I'm wondering
> how useful the async throttling is. Because we will block on request
> allocation once there are more than nr_requests pending requests so at that
> point throttling becomes sync anyway.

I haven't thought about the interface too much yet but, with the
synchronous wait at transaction start, we have information both ways -
ie. lower layer also knows that there are synchrnous waiters.  At the
simplest, not allowing any more async IOs when sync writers exist
should solve the starvation issue.

As for priority inversion through shared request pool, it is a problem
which needs to be solved regardless of how async IOs are throttled.
I'm not determined to which extent yet tho.  Different cgroups
definitely need to be on separate pools but do we also want
distinguish sync and async and what about ioprio?  Maybe we need a
bybrid approach with larger common pool and reserved ones for each
class?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
