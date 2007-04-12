Received: by ug-out-1314.google.com with SMTP id s2so244953uge
        for <linux-mm@kvack.org>; Wed, 11 Apr 2007 23:17:42 -0700 (PDT)
Message-ID: <ac8af0be0704112317o4779bbb5sb87a80f684160970@mail.gmail.com>
Date: Thu, 12 Apr 2007 14:17:37 +0800
From: "Zhao Forrest" <forrest.zhao@gmail.com>
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
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
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
>
> __blkdev_put() takes the BKL and bd_mutex
> invalidate_mapping_pages() tries to take the PageLock
>
> But no other looks seem held while free_buffer_head() is called
>
> All these locks are preemptible (CONFIG_PREEMPT_BKL?=y) and should not
> hog the cpu like that, what preemption mode have you got selected?
> (CONFIG_PREEMPT_VOLUNTARY?=y)
These 2 kernel options are turned on by default in my kernel. Here's
snip from .config
# CONFIG_PREEMPT_NONE is not set
CONFIG_PREEMPT_VOLUNTARY=y
# CONFIG_PREEMPT is not set
CONFIG_PREEMPT_BKL=y
CONFIG_NUMA=y
CONFIG_K8_NUMA=y

>
> Does this fix it?
>
> --- fs/buffer.c~        2007-02-01 12:00:34.000000000 +0100
> +++ fs/buffer.c 2007-04-11 12:35:48.000000000 +0200
> @@ -3029,6 +3029,8 @@ out:
>                         struct buffer_head *next = bh->b_this_page;
>                         free_buffer_head(bh);
>                         bh = next;
> +
> +                       cond_resched();
>                 } while (bh != buffers_to_free);
>         }
>         return ret;
>
So far I have run the test with patched kernel for 6 rounds, and
didn't see the soft lockup. I think this patch should fix the problem.
But what still confused me is that why do we need to invoke
cond_resched() voluntarily since CONFIG_PREEMPT_VOLUNTARY and
CONFIG_PREEMPT_BKL are both turned on? From my understanding these 2
options should make schedule happen even if CPU is under heavy
load......

Thanks,
Forrest

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
