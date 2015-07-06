Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 513FF2802AF
	for <linux-mm@kvack.org>; Mon,  6 Jul 2015 10:06:25 -0400 (EDT)
Received: by pdbci14 with SMTP id ci14so106690667pdb.2
        for <linux-mm@kvack.org>; Mon, 06 Jul 2015 07:06:25 -0700 (PDT)
Received: from mailout1.samsung.com (mailout1.samsung.com. [203.254.224.24])
        by mx.google.com with ESMTPS id et9si29231228pac.230.2015.07.06.07.06.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 06 Jul 2015 07:06:24 -0700 (PDT)
Received: from epcpsbgr3.samsung.com
 (u143.gpu120.samsung.co.kr [203.254.230.143])
 by mailout1.samsung.com (Oracle Communications Messaging Server 7.0.5.31.0
 64bit (built May  5 2014))
 with ESMTP id <0NR200J2CKIM5580@mailout1.samsung.com> for linux-mm@kvack.org;
 Mon, 06 Jul 2015 23:06:22 +0900 (KST)
From: PINTU KUMAR <pintu.k@samsung.com>
References: <1435929607-3435-1-git-send-email-pintu.k@samsung.com>
 <559A56FD.6010701@huawei.com>
In-reply-to: <559A56FD.6010701@huawei.com>
Subject: RE: [PATCH 1/1] kernel/sysctl.c: Add /proc/sys/vm/shrink_memory feature
Date: Mon, 06 Jul 2015 19:33:36 +0530
Message-id: <0ffe01d0b7f4$dd2706d0$97751470$@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-transfer-encoding: 7bit
Content-language: en-us
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Xishi Qiu' <qiuxishi@huawei.com>
Cc: corbet@lwn.net, akpm@linux-foundation.org, vbabka@suse.cz, gorcunov@openvz.org, mhocko@suse.cz, emunson@akamai.com, kirill.shutemov@linux.intel.com, standby24x7@gmail.com, hannes@cmpxchg.org, vdavydov@parallels.com, hughd@google.com, minchan@kernel.org, tj@kernel.org, rientjes@google.com, xypron.glpk@gmx.de, dzickus@redhat.com, prarit@redhat.com, ebiederm@xmission.com, rostedt@goodmis.org, uobergfe@redhat.com, paulmck@linux.vnet.ibm.com, iamjoonsoo.kim@lge.com, ddstreet@ieee.org, sasha.levin@oracle.com, koct9i@gmail.com, mgorman@suse.de, cj@linux.com, opensource.ganesh@gmail.com, vinmenon@codeaurora.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-pm@vger.kernel.org, cpgs@samsung.com, pintu_agarwal@yahoo.com, vishnu.ps@samsung.com, rohit.kr@samsung.com, iqbal.ams@samsung.com

Hi,

> -----Original Message-----
> From: Xishi Qiu [mailto:qiuxishi@huawei.com]
> Sent: Monday, July 06, 2015 3:53 PM
> To: Pintu Kumar
> Cc: corbet@lwn.net; akpm@linux-foundation.org; vbabka@suse.cz;
> gorcunov@openvz.org; mhocko@suse.cz; emunson@akamai.com;
> kirill.shutemov@linux.intel.com; standby24x7@gmail.com;
> hannes@cmpxchg.org; vdavydov@parallels.com; hughd@google.com;
> minchan@kernel.org; tj@kernel.org; rientjes@google.com;
> xypron.glpk@gmx.de; dzickus@redhat.com; prarit@redhat.com;
> ebiederm@xmission.com; rostedt@goodmis.org; uobergfe@redhat.com;
> paulmck@linux.vnet.ibm.com; iamjoonsoo.kim@lge.com; ddstreet@ieee.org;
> sasha.levin@oracle.com; koct9i@gmail.com; mgorman@suse.de; cj@linux.com;
> opensource.ganesh@gmail.com; vinmenon@codeaurora.org; linux-
> doc@vger.kernel.org; linux-kernel@vger.kernel.org; linux-mm@kvack.org; linux-
> pm@vger.kernel.org; cpgs@samsung.com; pintu_agarwal@yahoo.com;
> vishnu.ps@samsung.com; rohit.kr@samsung.com; iqbal.ams@samsung.com
> Subject: Re: [PATCH 1/1] kernel/sysctl.c: Add /proc/sys/vm/shrink_memory
> feature
> 
> On 2015/7/3 21:20, Pintu Kumar wrote:
> 
> > This patch provides 2 things:
> > 1. Add new control called shrink_memory in /proc/sys/vm/.
> > This control can be used to aggressively reclaim memory system-wide in
> > one shot from the user space. A value of 1 will instruct the kernel to
> > reclaim as much as totalram_pages in the system.
> > Example: echo 1 > /proc/sys/vm/shrink_memory
> >
> > 2. Enable shrink_all_memory API in kernel with new
> CONFIG_SHRINK_MEMORY.
> > Currently, shrink_all_memory function is used only during hibernation.
> > With the new config we can make use of this API for non-hibernation
> > case also without disturbing the hibernation case.
> >
> > The detailed paper was presented in Embedded Linux Conference,
> > Mar-2015 http://events.linuxfoundation.org/sites/events/files/slides/
> > %5BELC-2015%5D-System-wide-Memory-Defragmenter.pdf
> >
> > Scenarios were this can be used and helpful are:
> > 1) Can be invoked just after system boot-up is finished.
> > 2) Can be invoked just before entering entire system suspend.
> > 3) Can be invoked from kernel when order-4 pages starts failing.
> > 4) Can be helpful to completely avoid or delay the kerenl OOM condition.
> > 5) Can be developed as a system-tool to quickly defragment entire system
> >    from user space, without the need to kill any application.
> >
> 
> Hi Pintu,
> 
> How about increase min_free_kbytes and Android lowmemorykiller's level?
> 
Thanks for the review.
Actually in Tizen, we don't use Android LMK and we wanted to delay the LMK with
aggressive direct_reclaim offline.
And increasing min_free value also may not help much.
Currently, in our case free memory never falls below 10MB, with 512MB RAM
configuration.


> Thanks,
> Xishi Qiu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
