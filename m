Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 5FDDC6B006A
	for <linux-mm@kvack.org>; Mon,  2 Nov 2009 01:59:36 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nA26xXF1024435
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 2 Nov 2009 15:59:33 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 10A1A45DE54
	for <linux-mm@kvack.org>; Mon,  2 Nov 2009 15:59:33 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id DBC9D45DE52
	for <linux-mm@kvack.org>; Mon,  2 Nov 2009 15:59:32 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id C12361DB805B
	for <linux-mm@kvack.org>; Mon,  2 Nov 2009 15:59:32 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 6B9CF1DB8061
	for <linux-mm@kvack.org>; Mon,  2 Nov 2009 15:59:29 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: OOM killer, page fault
In-Reply-To: <20091102135640.93de7c2a.minchan.kim@barrios-desktop>
References: <20091102005218.8352.A69D9226@jp.fujitsu.com> <20091102135640.93de7c2a.minchan.kim@barrios-desktop>
Message-Id: <20091102155543.E60E.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon,  2 Nov 2009 15:59:28 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Norbert Preining <preining@logic.at>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> On Mon,  2 Nov 2009 13:24:06 +0900 (JST)
> KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> 
> > Hi,
> > 
> > (Cc to linux-mm)
> > 
> > Wow, this is very strange log.
> > 
> > > Dear all,
> > > 
> > > (please Cc)
> > > 
> > > With 2.6.32-rc5 I got that one:
> > > [13832.210068] Xorg invoked oom-killer: gfp_mask=0x0, order=0, oom_adj=0
> > 
> > order = 0
> 
> I think this problem results from 'gfp_mask = 0x0'.
> Is it possible?
> 
> If it isn't H/W problem, Who passes gfp_mask with 0x0?
> It's culpit. 
> 
> Could you add BUG_ON(gfp_mask == 0x0) in __alloc_pages_nodemask's head?

No.
In page fault case, gfp_mask show meaningless value. Please ignore it.
pagefault_out_of_memory() always pass gfp_mask==0 to oom.


mm/oom_kill.c
====================================
void pagefault_out_of_memory(void)
{
        unsigned long freed = 0;

        blocking_notifier_call_chain(&oom_notify_list, 0, &freed);
        if (freed > 0)
                /* Got some memory back in the last second. */
                return;

        /*
         * If this is from memcg, oom-killer is already invoked.
         * and not worth to go system-wide-oom.
         */
        if (mem_cgroup_oom_called(current))
                goto rest_and_return;

        if (sysctl_panic_on_oom)
                panic("out of memory from page fault. panic_on_oom is selected.\n");

        read_lock(&tasklist_lock);
        __out_of_memory(0, 0);       <---- here! 
        read_unlock(&tasklist_lock);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
