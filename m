Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id CE2E36B0044
	for <linux-mm@kvack.org>; Mon, 14 Dec 2009 20:09:15 -0500 (EST)
Received: by ywh3 with SMTP id 3so3778858ywh.22
        for <linux-mm@kvack.org>; Mon, 14 Dec 2009 17:09:14 -0800 (PST)
Date: Tue, 15 Dec 2009 10:03:42 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH 8/8] mm: Give up allocation if the task have fatal
 signal
Message-Id: <20091215100342.e77c8cbe.minchan.kim@barrios-desktop>
In-Reply-To: <20091215094659.CDB8.A69D9226@jp.fujitsu.com>
References: <20091214213224.BBC6.A69D9226@jp.fujitsu.com>
	<20091215085455.13eb65cc.minchan.kim@barrios-desktop>
	<20091215094659.CDB8.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Rik van Riel <riel@redhat.com>, lwoodman@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 15 Dec 2009 09:50:47 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> > >  	/*
> > > +	 * If the allocation is for userland page and we have fatal signal,
> > > +	 * there isn't any reason to continue allocation. instead, the task
> > > +	 * should exit soon.
> > > +	 */
> > > +	if (fatal_signal_pending(current) && (gfp_mask & __GFP_HIGHMEM))
> > > +		goto nopage;
> > 
> > If we jump nopage, we meets dump_stack and show_mem. 
> > Even, we can meet OOM which might kill innocent process.
> 
> Which point you oppose? noprint is better?
> 
> 

Sorry fot not clarity.
My point was following as. 

First,
I don't want to print.
Why do we print stack and mem when the process receives the SIGKILL?

Second, 
1) A process try to allocate anon page in do_anonymous_page.
2) A process receives SIGKILL.
3) kernel doesn't allocate page to A process by your patch.
4) do_anonymous_page returns VF_FAULT_OOM.
5) call mm_fault_error
6) call out_of_memory 
7) It migth kill innocent task. 

If I missed something, Pz, corret me. :)

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
