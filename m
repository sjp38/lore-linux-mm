Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id D91926B4EAA
	for <linux-mm@kvack.org>; Wed, 29 Aug 2018 21:44:11 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id 90-v6so3037881pla.18
        for <linux-mm@kvack.org>; Wed, 29 Aug 2018 18:44:11 -0700 (PDT)
Received: from ipmail03.adl2.internode.on.net (ipmail03.adl2.internode.on.net. [150.101.137.141])
        by mx.google.com with ESMTP id 1-v6si5628941pfu.79.2018.08.29.18.44.09
        for <linux-mm@kvack.org>;
        Wed, 29 Aug 2018 18:44:10 -0700 (PDT)
Date: Thu, 30 Aug 2018 11:43:04 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 1/2] fs/dcache: Track & report number of negative dentries
Message-ID: <20180830014304.GD5631@dastard>
References: <1535476780-5773-1-git-send-email-longman@redhat.com>
 <1535476780-5773-2-git-send-email-longman@redhat.com>
 <20180829001153.GD1572@dastard>
 <e084f670-b279-0f85-404c-9506e329f633@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e084f670-b279-0f85-404c-9506e329f633@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Waiman Long <longman@redhat.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, "Luis R. Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Miklos Szeredi <mszeredi@redhat.com>, Matthew Wilcox <willy@infradead.org>, Larry Woodman <lwoodman@redhat.com>, James Bottomley <James.Bottomley@HansenPartnership.com>, "Wangkai (Kevin C)" <wangkai86@huawei.com>, Michal Hocko <mhocko@kernel.org>

On Wed, Aug 29, 2018 at 01:11:08PM -0400, Waiman Long wrote:
> On 08/28/2018 08:11 PM, Dave Chinner wrote:
> > On Tue, Aug 28, 2018 at 01:19:39PM -0400, Waiman Long wrote:
> >> The current dentry number tracking code doesn't distinguish between
> >> positive & negative dentries. It just reports the total number of
> >> dentries in the LRU lists.
> >>
> >> As excessive number of negative dentries can have an impact on system
> >> performance, it will be wise to track the number of positive and
> >> negative dentries separately.
> >>
> >> This patch adds tracking for the total number of negative dentries in
> >> the system LRU lists and reports it in the /proc/sys/fs/dentry-state
> >> file. The number, however, does not include negative dentries that are
> >> in flight but not in the LRU yet.
> >>
> >> The number of positive dentries in the LRU lists can be roughly found
> >> by subtracting the number of negative dentries from the total.
> >>
> >> Signed-off-by: Waiman Long <longman@redhat.com>
> >> ---
> >>  Documentation/sysctl/fs.txt | 19 +++++++++++++------
> >>  fs/dcache.c                 | 45 +++++++++++++++++++++++++++++++++++++++++++++
> >>  include/linux/dcache.h      |  7 ++++---
> >>  3 files changed, 62 insertions(+), 9 deletions(-)
> >>
> >> diff --git a/Documentation/sysctl/fs.txt b/Documentation/sysctl/fs.txt
> >> index 819caf8..118bb93 100644
> >> --- a/Documentation/sysctl/fs.txt
> >> +++ b/Documentation/sysctl/fs.txt
> >> @@ -63,19 +63,26 @@ struct {
> >>          int nr_unused;
> >>          int age_limit;         /* age in seconds */
> >>          int want_pages;        /* pages requested by system */
> >> -        int dummy[2];
> >> +        int nr_negative;       /* # of unused negative dentries */
> >> +        int dummy;
> >>  } dentry_stat = {0, 0, 45, 0,};
> > That's not a backwards compatible ABI change. Those dummy fields
> > used to represent some metric we no longer calculate, and there are
> > probably still monitoring apps out there that think they still have
> > the old meaning. i.e. they are still visible to userspace:
> >
> > $ cat /proc/sys/fs/dentry-state 
> > 83090	67661	45	0	0	0
> > $
> >
> > IOWs, you can add new fields for new metrics to the end of the
> > structure, but you can't re-use existing fields even if they
> > aren't calculated anymore.
> >
> > [....]
> 
> I looked up the git history and the state of the dentry_stat structure
> hadn't changed since it was first put into git in 2.6.12-rc2 on Apr 16,
> 2005. That was over 13 years ago. Even adding an extra argument can have
> the potential of breaking old applications depending on how the parsing
> code was written.

I'm pretty we've had this discussion many times before  w.r.t.
/proc/self/mount* and other multi-field proc files. 

IIRC, The answer has always been that it's OK to extend lines with
new fields as existing apps /should/ ignore them, but it's not OK to
remove or redefine existing fields in the line because existing apps
/will/ misinterpret what that field means.

> Given that systems that are still using some very old tools are not
> likely to upgrade to the latest kernel anyway. I don't see that as a big
> problem.

I don't think that matters when it comes to changing what
information we expose in proc files.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
