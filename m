Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 6D0188D0039
	for <linux-mm@kvack.org>; Tue,  8 Feb 2011 03:46:00 -0500 (EST)
Date: Tue, 8 Feb 2011 09:45:57 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: khugepaged eating 100%CPU
Message-ID: <20110208084557.GC28138@tiehlicka.suse.cz>
References: <20110207210517.GA24837@tiehlicka.suse.cz>
 <20110207211601.GA25665@tiehlicka.suse.cz>
 <20110207231228.GI3347@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110207231228.GI3347@random.random>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Tue 08-02-11 00:12:28, Andrea Arcangeli wrote:
> Hello Michal,
> 
> On Mon, Feb 07, 2011 at 10:16:01PM +0100, Michal Hocko wrote:
> > On Mon 07-02-11 22:06:54, Michal Hocko wrote:
> > > Hi Andrea,
> > > 
> > > I am currently running into an issue when khugepaged is running 100% on
> > > one of my CPUs for a long time (at least one hour as I am writing the
> > > email). The kernel is the clean 2.6.38-rc3 (i386) vanilla kernel.
> > > 
> > > I have tried to disable defrag but it didn't help (I haven't rebooted
> > > after setting the value). I am not sure what information is helpful and
> > > also not sure whether I am able to reproduce it after restart (it is the
> > > first time I can see this problem) so sorry for the poor report.
> > > 
> > > Here is some basic info which might be useful (config and sysrq+t are
> > > attached):
> > > =========
> > 
> > And I have just realized that I forgot about the daemon stack:
> > # cat /proc/573/stack 
> > [<c019c981>] shrink_zone+0x1b9/0x455
> > [<c019d462>] do_try_to_free_pages+0x9d/0x301
> > [<c019d803>] try_to_free_pages+0xb3/0x104
> > [<c01966d7>] __alloc_pages_nodemask+0x358/0x589
> > [<c01bf314>] khugepaged+0x13f/0xc60
> > [<c014c301>] kthread+0x67/0x6c
> > [<c0102db6>] kernel_thread_helper+0x6/0x10
> > [<ffffffff>] 0xffffffff
> 
> It would be great to know if __alloc_pages_nodemask returned or if it
> was calling it in a loop.
> 
> When __alloc_pages_nodemask fails in collapse_huge_page, hpage is set
> to ERR_PTR(-ENOMEM), then khugepaged_scan_pmd returns 1, then
> khugepaged_scan_mm_slot goto breakouterloop_mmap_sem and return
> progress, then the khugepaged_do_scan main loop should notice that
> IS_ERR(*hpage) is set and break out of the loop and return void, then
> khugepaged_loop should notice that IS_ERR(hpage) is set and it should
> throttle for alloc_sleep_millisecs inside khugepaged_alloc_sleep
> before setting hpage to NULL and trying again to allocate. I wonder
> what could be going wrong in khugepaged.. I wonder if it's a bug inside
> __alloc_pages_nodemask and not a khugepaged issue. Best would be if
> you run SYSRQ+l several times.

OK, I will try if I see it again.

> 
> I hope you can reproduce, if it's an allocator issue you should notice
> it again by keeping the same workload on that same system. I doubt I
> can reproduce at the moment as I don't know what's going on to
> simulate your load.

My workload is rather "normal", I would say. Firefox with couple of
tabs, skype, mutt, xine (wathing the stream television), kernel builds)
and repeated suspend/wakeup cycles (I am rebooting only when installing
a new kernel - aka new rc is released or I need to test something). So
it is hard to find out what triggered this situation.

I will let you know when I get into the same situation and provide the
sysrq+l.

Thanks
-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
