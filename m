Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 487EA6B005C
	for <linux-mm@kvack.org>; Wed,  4 Jan 2012 00:17:49 -0500 (EST)
Received: by iacb35 with SMTP id b35so38658923iac.14
        for <linux-mm@kvack.org>; Tue, 03 Jan 2012 21:17:48 -0800 (PST)
Date: Tue, 3 Jan 2012 21:17:30 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 2/2] sysvshm: SHM_LOCK use lru_add_drain_all_async()
In-Reply-To: <4F03B715.4080005@gmail.com>
Message-ID: <alpine.LSU.2.00.1201032103580.1522@eggly.anvils>
References: <CAHGf_=qA3Pnb00n_smhJVKDDCDDr0d-a3E03Rrhnb-S4xK8_fQ@mail.gmail.com> <1325403025-22688-2-git-send-email-kosaki.motohiro@gmail.com> <alpine.LSU.2.00.1201031724300.1254@eggly.anvils> <4F03B715.4080005@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Michel Lespinasse <walken@google.com>

On Tue, 3 Jan 2012, KOSAKI Motohiro wrote:
> (1/3/12 8:51 PM), Hugh Dickins wrote:
> > 
> > In testing my fix for that, I find that there has been no attempt to
> > keep the Unevictable count accurate on SysVShm: SHM_LOCK pages get
> > marked unevictable lazily later as memory pressure discovers them -
> > which perhaps mirrors the way in which SHM_LOCK makes no attempt to
> > instantiate pages, unlike mlock.
> 
> Ugh, you are right. I'm recovering my remember gradually. Lee implemented
> immediate lru off logic at first and I killed it
> to close a race. I completely forgot. So, yes, now SHM_LOCK has no attempt to
> instantiate pages. I'm ashamed.

Why ashamed?  The shmctl man-page documents "The caller must fault in any
pages that are required to be present after locking is enabled."  That's
just how it behaves.

> > (But in writing this, realize I still don't quite understand why
> > the Unevictable count takes a second or two to get back to 0 after
> > SHM_UNLOCK: perhaps I've more to discover.)
> 
> Interesting. I'm looking at this too.

In case you got distracted before you found it, mm/vmstat.c's

static DEFINE_PER_CPU(struct delayed_work, vmstat_work);
int sysctl_stat_interval __read_mostly = HZ;

static void vmstat_update(struct work_struct *w)
{
	refresh_cpu_vm_stats(smp_processor_id());
	schedule_delayed_work(&__get_cpu_var(vmstat_work),
		round_jiffies_relative(sysctl_stat_interval));
}

would be why, I think.  And that implies to me that your
lru_add_drain_all_async() is not necessary, you'd get just as good
an effect, more cheaply, by doing a local lru_add_drain() before the
refresh in vmstat_update().

But it would still require your changes to ____pagevec_lru_add_fn(),
if those turn out to help more than they hurt.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
