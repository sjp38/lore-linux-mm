Received: by py-out-1112.google.com with SMTP id f47so1907657pye.20
        for <linux-mm@kvack.org>; Sat, 22 Mar 2008 09:01:04 -0700 (PDT)
Message-ID: <2f11576a0803220901v10a7e3d2j1b7d450b8a100fd3@mail.gmail.com>
Date: Sun, 23 Mar 2008 01:01:04 +0900
From: "KOSAKI Motohiro" <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [for -mm][PATCH][1/2] page reclaim throttle take3
In-Reply-To: <20080322105531.23f2bfdf@bree.surriel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080322192928.B30B.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <20080322105531.23f2bfdf@bree.surriel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

Hi Rik,

> On Sat, 22 Mar 2008 19:45:54 +0900
>  KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
>
>  > +     wait_event(zone->reclaim_throttle_waitq,
>  > +                atomic_add_unless(&zone->nr_reclaimers, 1,
>  > +                                  CONFIG_NR_MAX_RECLAIM_TASKS_PER_ZONE));
>
>  I like your patch, but can see one potential problem.   Sometimes
>  tasks that go into page reclaim with GFP_HIGHUSER end up recursing
>  back into page reclaim without __GFP_FS and/or __GFP_IO.
>
>  In that scenario, a task could end up waiting on itself and
>  deadlocking.

interesting point out.
but unfortunately I don't understand yet, sorry ;)

I think recursing reclaim doesn't happend because call graph is maked
as the following at that time.

  __alloc_pages_internal  (turn on PF_MEMALLOC)
    +- try_to_free_pages
        +- (skip)
            +- pageout
                +- (skip)
                    +-  __alloc_pages_internal

in second __alloc_pages_internal, PF_MEMALLOC populated.
thus bypassed try_to_free_pages.

Am I misunderstanding anything?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
