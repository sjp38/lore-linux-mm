Date: Fri, 28 Dec 2007 09:38:41 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC][patch 1/2] mem notifications v3 improvement for large system
In-Reply-To: <20071227210456.GB14823@dmt>
References: <20071225182144.D26D.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20071227210456.GB14823@dmt>
Message-Id: <20071228092123.7F1D.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@kvack.org>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, Daniel =?ISO-2022-JP?B?U3AbJEJpTxsoQmc=?= <daniel.spang@gmail.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi Marcelo-san

thank you for your advice.

> So something like the following sounds better:
> 
> - have your poll_wait_exclusive() patch in place
> - pass a "status" parameter to mem_notify_userspace() and have it clear
> mem_notify_status in case status is zero, so to stop sending POLLIN to processes.
> - call mem_notify_userspace(0) from mm/vmscan.c when ZONE_NORMAL reclaim_mapped 
> is false (that seems a good indication that VM is out of trouble).
> - test for mem_notify_status in mem_notify_poll(), but do not clear it.
> - at mem_notify_userspace(), use wake_up_nr(number of mem_notify users/10) (10
> meaning a small percentage of registered users).

feel nice idea.
OK. I will try it about new year.


> > +        if (file_info->last_event == atomic_read(&mem_notify_event))
> > +                goto out;
> 
> What exactly are you trying to deal with by using last_event?

to be honest, read() and last_event is daniel-san's idea.
it is part of sysfs code in his patch.
my patch intent the same behavior as his.

1. read() method is deletable if you dislike.
   I will delete at next post :)
2. last_event is not deletable, it is important.
   when storong and long memory pressure,
   notification received process call poll() again after own cache freed
   but before out of trouble.
   at that point, the process shold not wakeup because already memory freed.
   (in other word, poll shold return 0.)



- kosaki


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
