Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 6CB7B6B0005
	for <linux-mm@kvack.org>; Wed,  3 Apr 2013 19:31:45 -0400 (EDT)
Date: Thu, 4 Apr 2013 08:31:42 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC 1/4] mm: Per process reclaim
Message-ID: <20130403233142.GB7675@blaptop>
References: <1364192494-22185-1-git-send-email-minchan@kernel.org>
 <CAHO5Pa0jNZ0y8CEAuAxqs5DtG_60WKJmQa2QPcfZDmWz5uts2g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAHO5Pa0jNZ0y8CEAuAxqs5DtG_60WKJmQa2QPcfZDmWz5uts2g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Kerrisk <mtk.manpages@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Sangseok Lee <sangseok.lee@lge.com>

Hi Michael,

On Wed, Apr 03, 2013 at 11:17:58AM +0200, Michael Kerrisk wrote:
> Hello Minchan,
> 
> On Mon, Mar 25, 2013 at 7:21 AM, Minchan Kim <minchan@kernel.org> wrote:
> > These day, there are many platforms avaiable in the embedded market
> > and they are smarter than kernel which has very limited information
> > about working set so they want to involve memory management more heavily
> > like android's lowmemory killer and ashmem or recent many lowmemory
> > notifier(there was several trial for various company NOKIA, SAMSUNG,
> > Linaro, Google ChromeOS, Redhat).
> >
> > One of the simple imagine scenario about userspace's intelligence is that
> > platform can manage tasks as forground and backgroud so it would be
> > better to reclaim background's task pages for end-user's *responsibility*
> > although it has frequent referenced pages.
> >
> > This patch adds new knob "reclaim under proc/<pid>/" so task manager
> > can reclaim any target process anytime, anywhere. It could give another
> > method to platform for using memory efficiently.
> >
> > It can avoid process killing for getting free memory, which was really
> > terrible experience because I lost my best score of game I had ever
> > after I switch the phone call while I enjoyed the game.
> >
> > Writing 1 to /proc/pid/reclaim reclaims only file pages.
> > Writing 2 to /proc/pid/reclaim reclaims only anonymous pages.
> > Writing 3 to /proc/pid/reclaim reclaims all pages from target process.
> >
> > Signed-off-by: Minchan Kim <minchan@kernel.org>
> > ---
> >  fs/proc/base.c       |   3 ++
> >  fs/proc/internal.h   |   1 +
> >  fs/proc/task_mmu.c   | 115 +++++++++++++++++++++++++++++++++++++++++++++++++++
> >  include/linux/rmap.h |   4 ++
> >  mm/Kconfig           |  13 ++++++
> >  mm/internal.h        |   7 +---
> >  mm/vmscan.c          |  59 ++++++++++++++++++++++++++
> >  7 files changed, 196 insertions(+), 6 deletions(-)
> >
> > diff --git a/fs/proc/base.c b/fs/proc/base.c
> > index 9b43ff77..ed83e85 100644
> 
> [...]
> 
> > +#define RECLAIM_FILE (1 << 0)
> > +#define RECLAIM_ANON (1 << 1)
> > +#define RECLAIM_ALL (RECLAIM_FILE | RECLAIM_ANON)
> > +
> > +static ssize_t reclaim_write(struct file *file, const char __user *buf,
> > +                               size_t count, loff_t *ppos)
> > +{
> > +       struct task_struct *task;
> > +       char buffer[PROC_NUMBUF];
> > +       struct mm_struct *mm;
> > +       struct vm_area_struct *vma;
> > +       int type;
> > +       int rv;
> > +
> > +       memset(buffer, 0, sizeof(buffer));
> > +       if (count > sizeof(buffer) - 1)
> > +               count = sizeof(buffer) - 1;
> > +       if (copy_from_user(buffer, buf, count))
> > +               return -EFAULT;
> > +       rv = kstrtoint(strstrip(buffer), 10, &type);
> > +       if (rv < 0)
> > +               return rv
> > +       if (type < RECLAIM_ALL || type > RECLAIM_FILE)
> > +               return -EINVAL;> +       task = get_proc_task(file->f_path.dentry->d_inode);
> 
> The check here is the wrong way round. Should be
> 
>        if (type < RECLAIM_FILE || type > RECLAIM_ALL)
> 
> Thanks,

You give me a chance to remember "last minute change is really evil"
Thanks!

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
