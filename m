Received: from spaceape12.eur.corp.google.com (spaceape12.eur.corp.google.com [172.28.16.146])
	by smtp-out.google.com with ESMTP id l3BGZiPd005993
	for <linux-mm@kvack.org>; Wed, 11 Apr 2007 17:35:44 +0100
Received: from an-out-0708.google.com (ancc2.prod.google.com [10.100.29.2])
	by spaceape12.eur.corp.google.com with ESMTP id l3BGY6pP021472
	for <linux-mm@kvack.org>; Wed, 11 Apr 2007 17:35:42 +0100
Received: by an-out-0708.google.com with SMTP id c2so272374anc
        for <linux-mm@kvack.org>; Wed, 11 Apr 2007 09:35:41 -0700 (PDT)
Message-ID: <b040c32a0704110935k1723c85ay4a862539bad56c05@mail.gmail.com>
Date: Wed, 11 Apr 2007 09:35:39 -0700
From: "Ken Chen" <kenchen@google.com>
Subject: Re: Why kmem_cache_free occupy CPU for more than 10 seconds?
In-Reply-To: <1176287911.6893.47.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <ac8af0be0704102317q50fe72b1m9e4825a769a63963@mail.gmail.com>
	 <84144f020704102353r7dcc3538u2e34237d3496630e@mail.gmail.com>
	 <ac8af0be0704110253p74de6197p1df6a5b99585709c@mail.gmail.com>
	 <1176287911.6893.47.camel@twins>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Zhao Forrest <forrest.zhao@gmail.com>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 4/11/07, Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> On Wed, 2007-04-11 at 17:53 +0800, Zhao Forrest wrote:
> > I got some new information:
> > Before soft lockup message is out, we have:
> > [root@nsgsh-dhcp-149 home]# cat /proc/slabinfo |grep buffer_head
> > buffer_head       10927942 10942560    120   32    1 : tunables   32
> > 16    8 : slabdata 341955 341955      6 : globalstat 37602996 11589379
> > 1174373    6                              0    1 6918 12166031 1013708
> > : cpustat 35254590 2350698 13610965 907286
> >
> > Then after buffer_head is freed, we have:
> > [root@nsgsh-dhcp-149 home]# cat /proc/slabinfo |grep buffer_head
> > buffer_head         9542  36384    120   32    1 : tunables   32   16
> >   8 : slabdata   1137   1137    245 : globalstat 37602996 11589379
> > 1174373    6                                  0    1 6983 20507478
> > 1708818 : cpustat 35254625 2350704 16027174 1068367
> >
> > Does this huge number of buffer_head cause the soft lockup?
>
> __blkdev_put() takes the BKL and bd_mutex
> invalidate_mapping_pages() tries to take the PageLock
>
> But no other looks seem held while free_buffer_head() is called
>
> All these locks are preemptible (CONFIG_PREEMPT_BKL?=y) and should not
> hog the cpu like that, what preemption mode have you got selected?
> (CONFIG_PREEMPT_VOLUNTARY?=y)

also, you can try this patch:

http://groups.google.com/group/linux.kernel/browse_thread/thread/7086e4b9d5504dc9/c608bfea4614b07e?lnk=gst&q=+Big+kernel+lock+contention+in+do_open&rnum=1#c608bfea4614b07e

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
