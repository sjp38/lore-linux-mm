Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id B13D4440313
	for <linux-mm@kvack.org>; Mon,  5 Oct 2015 02:19:02 -0400 (EDT)
Received: by pacfv12 with SMTP id fv12so170239608pac.2
        for <linux-mm@kvack.org>; Sun, 04 Oct 2015 23:19:02 -0700 (PDT)
Received: from mailout1.samsung.com (mailout1.samsung.com. [203.254.224.24])
        by mx.google.com with ESMTPS id w5si14119090pbt.36.2015.10.04.23.19.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 04 Oct 2015 23:19:01 -0700 (PDT)
Received: from epcpsbgr1.samsung.com
 (u141.gpu120.samsung.co.kr [203.254.230.141])
 by mailout1.samsung.com (Oracle Communications Messaging Server 7.0.5.31.0
 64bit (built May  5 2014))
 with ESMTP id <0NVQ01Q2OHJOX360@mailout1.samsung.com> for linux-mm@kvack.org;
 Mon, 05 Oct 2015 15:19:00 +0900 (KST)
From: PINTU KUMAR <pintu.k@samsung.com>
References: <1443696523-27262-1-git-send-email-pintu.k@samsung.com>
 <560D3542.6060903@linux.vnet.ibm.com>
In-reply-to: <560D3542.6060903@linux.vnet.ibm.com>
Subject: RE: [PATCH 1/1] mm: vmstat: Add OOM kill count in vmstat counter
Date: Mon, 05 Oct 2015 11:49:13 +0530
Message-id: <010501d0ff35$def59390$9ce0bab0$@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=US-ASCII
Content-transfer-encoding: 7bit
Content-language: en-us
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Anshuman Khandual' <khandual@linux.vnet.ibm.com>, akpm@linux-foundation.org, minchan@kernel.org, dave@stgolabs.net, mhocko@suse.cz, koct9i@gmail.com, rientjes@google.com, hannes@cmpxchg.org, penguin-kernel@i-love.sakura.ne.jp, bywxiaobai@163.com, mgorman@suse.de, vbabka@suse.cz, js1304@gmail.com, kirill.shutemov@linux.intel.com, alexander.h.duyck@redhat.com, sasha.levin@oracle.com, cl@linux.com, fengguang.wu@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: cpgs@samsung.com, pintu_agarwal@yahoo.com, pintu.ping@gmail.com, vishnu.ps@samsung.com, rohit.kr@samsung.com, c.rajkumar@samsung.com, sreenathd@samsung.com

Hi,

> -----Original Message-----
> From: Anshuman Khandual [mailto:khandual@linux.vnet.ibm.com]
> Sent: Thursday, October 01, 2015 7:00 PM
> To: Pintu Kumar; akpm@linux-foundation.org; minchan@kernel.org;
> dave@stgolabs.net; mhocko@suse.cz; koct9i@gmail.com; rientjes@google.com;
> hannes@cmpxchg.org; penguin-kernel@i-love.sakura.ne.jp;
> bywxiaobai@163.com; mgorman@suse.de; vbabka@suse.cz; js1304@gmail.com;
> kirill.shutemov@linux.intel.com; alexander.h.duyck@redhat.com;
> sasha.levin@oracle.com; cl@linux.com; fengguang.wu@intel.com; linux-
> kernel@vger.kernel.org; linux-mm@kvack.org
> Cc: cpgs@samsung.com; pintu_agarwal@yahoo.com; pintu.ping@gmail.com;
> vishnu.ps@samsung.com; rohit.kr@samsung.com; c.rajkumar@samsung.com;
> sreenathd@samsung.com
> Subject: Re: [PATCH 1/1] mm: vmstat: Add OOM kill count in vmstat counter
> 
> On 10/01/2015 04:18 PM, Pintu Kumar wrote:
> > This patch maintains number of oom calls and number of oom kill count
> > in /proc/vmstat.
> > It is helpful during sluggish, aging or long duration tests.
> > Currently if the OOM happens, it can be only seen in kernel ring buffer.
> > But during long duration tests, all the dmesg and /var/log/messages*
> > could be overwritten.
> > So, just like other counters, the oom can also be maintained in
> > /proc/vmstat.
> > It can be also seen if all logs are disabled in kernel.
> 
> Makes sense.
> 
> >
> > A snapshot of the result of over night test is shown below:
> > $ cat /proc/vmstat
> > oom_stall 610
> > oom_kill_count 1763
> >
> > Here, oom_stall indicates that there are 610 times, kernel entered
> > into OOM cases. However, there were around 1763 oom killing happens.
> > The OOM is bad for the any system. So, this counter can help the
> > developer in tuning the memory requirement at least during initial bringup.
> 
> Can you please fix the formatting of the commit message above ?
> 
Not sure if there is any formatting issue here. I cannot see it.
The checkpatch returns no error/warnings.
Please point me out exactly, if there is any issue.

> >
> > Signed-off-by: Pintu Kumar <pintu.k@samsung.com>
> > ---
> >  include/linux/vm_event_item.h |    2 ++
> >  mm/oom_kill.c                 |    2 ++
> >  mm/page_alloc.c               |    2 +-
> >  mm/vmstat.c                   |    2 ++
> >  4 files changed, 7 insertions(+), 1 deletion(-)
> >
> > diff --git a/include/linux/vm_event_item.h
> > b/include/linux/vm_event_item.h index 2b1cef8..ade0851 100644
> > --- a/include/linux/vm_event_item.h
> > +++ b/include/linux/vm_event_item.h
> > @@ -57,6 +57,8 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN,
> > PSWPOUT,  #ifdef CONFIG_HUGETLB_PAGE
> >  		HTLB_BUDDY_PGALLOC, HTLB_BUDDY_PGALLOC_FAIL,  #endif
> > +		OOM_STALL,
> > +		OOM_KILL_COUNT,
> 
> Removing the COUNT will be better and in sync with others.

Ok, even suggested by Michal Hocko and being discussed in another thread.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
