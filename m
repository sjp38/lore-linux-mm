Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f175.google.com (mail-ea0-f175.google.com [209.85.215.175])
	by kanga.kvack.org (Postfix) with ESMTP id B37B26B0035
	for <linux-mm@kvack.org>; Wed,  8 Jan 2014 05:47:16 -0500 (EST)
Received: by mail-ea0-f175.google.com with SMTP id z10so725452ead.20
        for <linux-mm@kvack.org>; Wed, 08 Jan 2014 02:47:16 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l44si92769803eem.187.2014.01.08.02.47.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 08 Jan 2014 02:47:15 -0800 (PST)
Date: Wed, 8 Jan 2014 11:47:13 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [RFC PATCH V3] mm readahead: Fix the readahead fail in case of
 empty numa node
Message-ID: <20140108104713.GB8256@quack.suse.cz>
References: <1389003715-29733-1-git-send-email-raghavendra.kt@linux.vnet.ibm.com>
 <20140106141300.4e1c950d45c614d6c29bdd8f@linux-foundation.org>
 <52CD1113.2070003@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52CD1113.2070003@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, David Cohen <david.a.cohen@linux.intel.com>, Al Viro <viro@zeniv.linux.org.uk>, Damien Ramonda <damien.ramonda@intel.com>, jack@suse.cz, Linus <torvalds@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 08-01-14 14:19:23, Raghavendra K T wrote:
> On 01/07/2014 03:43 AM, Andrew Morton wrote:
> >On Mon,  6 Jan 2014 15:51:55 +0530 Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com> wrote:
> >
> >>+	/*
> >>+	 * Readahead onto remote memory is better than no readahead when local
> >>+	 * numa node does not have memory. We sanitize readahead size depending
> >>+	 * on free memory in the local node but limiting to 4k pages.
> >>+	 */
> >>+	return local_free_page ? min(sane_nr, local_free_page / 2) : sane_nr;
> >>  }
> >
> >So if the local node has two free pages, we do just one page of
> >readahead.
> >
> >Then the local node has one free page and we do zero pages readahead.
> >
> >Assuming that bug(!) is fixed, the local node now has zero free pages
> >and we suddenly resume doing large readahead.
> >
> >This transition from large readahead to very small readahead then back
> >to large readahead is illogical, surely?
> >
> >
> 
> You are correct that there is a transition from small readahead to
> large once we have zero free pages.
> I am not sure I can defend well, but 'll give a try :).
> 
> Hoping that we have evenly distributed cpu/memory load, if we have very
> less free+inactive memory may be we are in really bad shape already.
> 
> But in the case where we have a situation like below [1] (cpu does
> not have any local memory node populated) I had mentioned
> earlier where we will have to depend on remote node always,
> is it not that sanitized readahead onto remote memory seems better?
> 
> But having said that I am not able to get an idea of sane implementation
> to solve this readahead failure bug overcoming the anomaly you pointed
> :(.  hints/ideas.. ?? please let me know.
  So if we would be happy with just fixing corner cases like this, we might
use total node memory size to detect them, can't we? If total node memory
size is 0, we can use 16 MB (or global number of free pages / 2 if we would
be uneasy with fixed 16 MB limit) as an upperbound...

								Honza
> 
> 
> [1]: IBM P730
> ----------------------------------
> # numactl -H
> available: 2 nodes (0-1)
> node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21
> 22 23 24 25 26 27 28 29 30 31
> node 0 size: 0 MB
> node 0 free: 0 MB
> node 1 cpus:
> node 1 size: 12288 MB
> node 1 free: 10440 MB
> node distances:
> node   0   1
> 0:  10  40
> 1:  40  10
> 
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
