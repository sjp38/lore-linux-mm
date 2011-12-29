Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id B91276B004D
	for <linux-mm@kvack.org>; Thu, 29 Dec 2011 17:55:49 -0500 (EST)
Date: Thu, 29 Dec 2011 14:55:48 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 3/3] mm: take pagevecs off reclaim stack
Message-Id: <20111229145548.e34cb2f3.akpm@linux-foundation.org>
In-Reply-To: <alpine.LSU.2.00.1112282037000.1362@eggly.anvils>
References: <alpine.LSU.2.00.1112282028160.1362@eggly.anvils>
	<alpine.LSU.2.00.1112282037000.1362@eggly.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Konstantin Khlebnikov <khlebnikov@openvz.org>, linux-mm@kvack.org

On Wed, 28 Dec 2011 20:39:36 -0800 (PST)
Hugh Dickins <hughd@google.com> wrote:

> Replace pagevecs in putback_lru_pages() and move_active_pages_to_lru()
> by lists of pages_to_free

One effect of the pagevec handling was to limit lru_lock hold times and
interrupt-disabled times.

This patch removes that upper bound and has the potential to cause
various latency problems when processing large numbers of pages.

The affected functions have rather a lot of callers.  I don't think
that auditing all these callers and convincing ourselves that none of
them pass in 10,000 pages is sufficient, because that doesn't prevent us
from introducing such latency problems as the MM code evolves.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
