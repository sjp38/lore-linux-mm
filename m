Received: by wa-out-1112.google.com with SMTP id m28so609973wag.8
        for <linux-mm@kvack.org>; Mon, 05 May 2008 15:23:18 -0700 (PDT)
Message-ID: <2f11576a0805051523h730fce0foa51f1fdbf9c46cbe@mail.gmail.com>
Date: Tue, 6 May 2008 07:23:18 +0900
From: "KOSAKI Motohiro" <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [-mm][PATCH 4/5] core of reclaim throttle
In-Reply-To: <20080505175142.7de3f27b@cuia.bos.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080504201343.8F52.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <20080504215819.8F5E.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <20080504221043.8F64.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <20080505175142.7de3f27b@cuia.bos.redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

>  > +     throttle_on = 1;
>  > +     current->flags |= PF_RECLAIMING;
>  > +     wait_event(zone->reclaim_throttle_waitq,
>  > +              atomic_add_unless(&zone->nr_reclaimers, 1, MAX_RECLAIM_TASKS));
>
>  This is a problem.  Processes without __GFP_FS or __GFP_IO cannot wait on
>  processes that have those flags set in their gfp_mask, and tasks that do
>  not have __GFP_IO set cannot wait for tasks with it.  This is because the
>  tasks that have those flags set may grab locks that the tasks without the
>  flag are holding, causing a deadlock.

hmmm, AFAIK,
on current kernel, sometimes __GFP_IO task wait for non __GFP_IO task
by lock_page().
Is this wrong?

therefore my patch care only recursive reclaim situation.
I don't object to your opinion. but I hope understand exactly your opinion.

>  The easiest fix would be to only make tasks with both __GFP_FS and __GFP_IO
>  sleep.  Tasks that call try_to_free_pages without those flags are relatively
>  rare and should hopefully not cause any issues.

Agreed it's easy.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
