Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6E9ED6B02DD
	for <linux-mm@kvack.org>; Mon, 19 Dec 2016 21:26:37 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id 26so103478211pgy.6
        for <linux-mm@kvack.org>; Mon, 19 Dec 2016 18:26:37 -0800 (PST)
Received: from mail-pf0-x244.google.com (mail-pf0-x244.google.com. [2607:f8b0:400e:c00::244])
        by mx.google.com with ESMTPS id a3si20163147plc.19.2016.12.19.18.26.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Dec 2016 18:26:36 -0800 (PST)
Received: by mail-pf0-x244.google.com with SMTP id 144so8128387pfv.0
        for <linux-mm@kvack.org>; Mon, 19 Dec 2016 18:26:36 -0800 (PST)
Date: Tue, 20 Dec 2016 12:26:15 +1000
From: Nicholas Piggin <npiggin@gmail.com>
Subject: Re: [RFC][PATCH] make global bitlock waitqueues per-node
Message-ID: <20161220122615.1f4b494d@roar.ozlabs.ibm.com>
In-Reply-To: <20161219225826.F8CB356F@viggo.jf.intel.com>
References: <20161219225826.F8CB356F@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, agruenba@redhat.com, rpeterso@redhat.com, mgorman@techsingularity.net, peterz@infradead.org, luto@kernel.org, swhiteho@redhat.com, torvalds@linux-foundation.org

On Mon, 19 Dec 2016 14:58:26 -0800
Dave Hansen <dave.hansen@linux.intel.com> wrote:

> I saw a 4.8->4.9 regression (details below) that I attributed to:
> 
> 	9dcb8b685f mm: remove per-zone hashtable of bitlock waitqueues
> 
> That commit took the bitlock waitqueues from being dynamically-allocated
> per-zone to being statically allocated and global.  As suggested by
> Linus, this makes them per-node, but keeps them statically-allocated.
> 
> It leaves us with more waitqueues than the global approach, inherently
> scales it up as we gain nodes, and avoids generating code for
> page_zone() which was evidently quite ugly.  The patch is pretty darn
> tiny too.
> 
> This turns what was a ~40% 4.8->4.9 regression into a 17% gain over
> what on 4.8 did.  That gain is a _bit_ surprising, but not entirely
> unexpected since we now get much simpler code from no page_zone() and a
> fixed-size array for which we don't have to follow a pointer (and get to
> do power-of-2 math).

I'll have to respin the PageWaiters patch and resend it. There were
just a couple of small issues picked up in review. I've just got side
tracked with getting a few other things done and haven't had time to
benchmark it properly.

I'd still like to see what per-node waitqueues does on top of that. If
it's significant for realistic workloads then it could be done for the
page waitqueues as Linus said.

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
