Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 21D346B000C
	for <linux-mm@kvack.org>; Mon, 15 Oct 2018 05:50:51 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id l51-v6so11762224edc.14
        for <linux-mm@kvack.org>; Mon, 15 Oct 2018 02:50:51 -0700 (PDT)
Received: from outbound-smtp25.blacknight.com (outbound-smtp25.blacknight.com. [81.17.249.193])
        by mx.google.com with ESMTPS id h1-v6si203250eds.194.2018.10.15.02.50.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 15 Oct 2018 02:50:49 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp25.blacknight.com (Postfix) with ESMTPS id 1545FB8BAB
	for <linux-mm@kvack.org>; Mon, 15 Oct 2018 10:50:48 +0100 (IST)
Date: Mon, 15 Oct 2018 10:50:48 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 0/2] mm/swap: Add locking for pagevec
Message-ID: <20181015095048.GG5819@techsingularity.net>
References: <20180914145924.22055-1-bigeasy@linutronix.de>
 <02dd6505-2ee5-c1c1-2603-b759bc90d479@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <02dd6505-2ee5-c1c1-2603-b759bc90d479@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Sebastian Andrzej Siewior <bigeasy@linutronix.de>, linux-mm@kvack.org, tglx@linutronix.de, frederic@kernel.org

On Fri, Oct 12, 2018 at 09:21:41AM +0200, Vlastimil Babka wrote:
> On 9/14/18 4:59 PM, Sebastian Andrzej Siewior wrote:
> I think this evaluation is missing the other side of the story, and
> that's the cost of using a spinlock (even uncontended) instead of
> disabling preemption. The expectation for LRU pagevec is that the local
> operations will be much more common than draining of other CPU's, so
> it's optimized for the former.
> 

Agreed, the drain operation should be extremely rare except under heavy
memory pressure, particularly if mixed with THP allocations. The overall
intent seems to be improving lockdep coverage but I don't think we
should take a hit in the common case just to get that coverage. Bear in
mind that the main point of the pagevec (whether it's true or not) is to
avoid the much heavier LRU lock.

-- 
Mel Gorman
SUSE Labs
