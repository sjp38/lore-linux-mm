Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 0A2096B01CD
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 16:36:56 -0400 (EDT)
Received: from hpaq11.eem.corp.google.com (hpaq11.eem.corp.google.com [172.25.149.11])
	by smtp-out.google.com with ESMTP id o51KarZR025012
	for <linux-mm@kvack.org>; Tue, 1 Jun 2010 13:36:53 -0700
Received: from pxi10 (pxi10.prod.google.com [10.243.27.10])
	by hpaq11.eem.corp.google.com with ESMTP id o51KapDP001908
	for <linux-mm@kvack.org>; Tue, 1 Jun 2010 13:36:51 -0700
Received: by pxi10 with SMTP id 10so2823931pxi.7
        for <linux-mm@kvack.org>; Tue, 01 Jun 2010 13:36:50 -0700 (PDT)
Date: Tue, 1 Jun 2010 13:36:45 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/5] oom: select_bad_process: check PF_KTHREAD instead
 of !mm to skip kthreads
In-Reply-To: <20100531182526.1843.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1006011333470.13136@chino.kir.corp.google.com>
References: <20100531182526.1843.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Mon, 31 May 2010, KOSAKI Motohiro wrote:

> From: Oleg Nesterov <oleg@redhat.com>
> Subject: oom: select_bad_process: check PF_KTHREAD instead of !mm to skip kthreads
> 
> select_bad_process() thinks a kernel thread can't have ->mm != NULL, this
> is not true due to use_mm().
> 
> Change the code to check PF_KTHREAD.
> 
> Signed-off-by: Oleg Nesterov <oleg@redhat.com>
> Acked-by: David Rientjes <rientjes@google.com>
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

This is already pushed in my oom killer rewrite as patch 14/18 "check 
PF_KTHREAD instead of !mm to skip kthreads".

This does not need to be merged immediately since it's not vital: use_mm() 
is only temporary state and these kthreads will once again be excluded 
when they call unuse_mm().  The worst case scenario here is that the oom 
killer will erroneously select one of these kthreads which cannot die and 
will need to reselect another task on its next call.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
