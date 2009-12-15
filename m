Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 997776B0044
	for <linux-mm@kvack.org>; Mon, 14 Dec 2009 20:16:58 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBF1Gts0025966
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 15 Dec 2009 10:16:55 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id AB24645DE70
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 10:16:55 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6BC3345DE60
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 10:16:55 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 164B61DB803B
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 10:16:55 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7FB0E1DB803A
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 10:16:54 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 8/8] mm: Give up allocation if the task have fatal signal
In-Reply-To: <20091215100342.e77c8cbe.minchan.kim@barrios-desktop>
References: <20091215094659.CDB8.A69D9226@jp.fujitsu.com> <20091215100342.e77c8cbe.minchan.kim@barrios-desktop>
Message-Id: <20091215101512.CDC4.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 15 Dec 2009 10:16:53 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Rik van Riel <riel@redhat.com>, lwoodman@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> On Tue, 15 Dec 2009 09:50:47 +0900 (JST)
> KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> 
> > > >  	/*
> > > > +	 * If the allocation is for userland page and we have fatal signal,
> > > > +	 * there isn't any reason to continue allocation. instead, the task
> > > > +	 * should exit soon.
> > > > +	 */
> > > > +	if (fatal_signal_pending(current) && (gfp_mask & __GFP_HIGHMEM))
> > > > +		goto nopage;
> > > 
> > > If we jump nopage, we meets dump_stack and show_mem. 
> > > Even, we can meet OOM which might kill innocent process.
> > 
> > Which point you oppose? noprint is better?
> > 
> > 
> 
> Sorry fot not clarity.
> My point was following as. 
> 
> First,
> I don't want to print.
> Why do we print stack and mem when the process receives the SIGKILL?
> 
> Second, 
> 1) A process try to allocate anon page in do_anonymous_page.
> 2) A process receives SIGKILL.
> 3) kernel doesn't allocate page to A process by your patch.
> 4) do_anonymous_page returns VF_FAULT_OOM.
> 5) call mm_fault_error
> 6) call out_of_memory 
> 7) It migth kill innocent task. 
> 
> If I missed something, Pz, corret me. :)

Doh, you are complely right. I had forgot recent meaning change of VM_FAULT_OOM.
yes, this patch is crap. I need to remake it.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
