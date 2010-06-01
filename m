Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 341236B01CD
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 16:39:45 -0400 (EDT)
Received: from hpaq14.eem.corp.google.com (hpaq14.eem.corp.google.com [172.25.149.14])
	by smtp-out.google.com with ESMTP id o51Kdf41010507
	for <linux-mm@kvack.org>; Tue, 1 Jun 2010 13:39:41 -0700
Received: from pvg4 (pvg4.prod.google.com [10.241.210.132])
	by hpaq14.eem.corp.google.com with ESMTP id o51KdYmD025431
	for <linux-mm@kvack.org>; Tue, 1 Jun 2010 13:39:40 -0700
Received: by pvg4 with SMTP id 4so1258298pvg.0
        for <linux-mm@kvack.org>; Tue, 01 Jun 2010 13:39:39 -0700 (PDT)
Date: Tue, 1 Jun 2010 13:39:37 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2/5] oom: select_bad_process: PF_EXITING check should
 take ->mm into account
In-Reply-To: <20100531183335.1846.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1006011337590.13136@chino.kir.corp.google.com>
References: <20100531182526.1843.A69D9226@jp.fujitsu.com> <20100531183335.1846.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Mon, 31 May 2010, KOSAKI Motohiro wrote:

> From: Oleg Nesterov <oleg@redhat.com>
> Subject: oom: select_bad_process: PF_EXITING check should take ->mm into account
> 
> select_bad_process() checks PF_EXITING to detect the task which is going
> to release its memory, but the logic is very wrong.
> 
> 	- a single process P with the dead group leader disables
> 	  select_bad_process() completely, it will always return
> 	  ERR_PTR() while P can live forever
> 
> 	- if the PF_EXITING task has already released its ->mm
> 	  it doesn't make sense to expect it is goiing to free
> 	  more memory (except task_struct/etc)
> 
> Change the code to ignore the PF_EXITING tasks without ->mm.
> 
> Signed-off-by: Oleg Nesterov <oleg@redhat.com>
> Acked-by: David Rientjes <rientjes@google.com>
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> [rebase to latest -mm]

This is already pushed in my oom killer rewrite as patch 13/18 "oom: avoid 
race for oom killed tasks detaching mm prior to exit".

It's not vital to merge now because causing the oom killer to temporarily 
become a no-op before it can fully exit even though it has already 
detached its memory only delays killing another task until it exits and 
there's nothing in the way of that exiting while it's still under 
PF_EXITING.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
