Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 630F58D0039
	for <linux-mm@kvack.org>; Tue,  1 Feb 2011 05:04:40 -0500 (EST)
Date: Tue, 1 Feb 2011 11:04:34 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [RFC][PATCH 2/6] pagewalk: only split huge pages when necessary
Message-ID: <20110201100433.GH19534@cmpxchg.org>
References: <20110201003357.D6F0BE0D@kernel>
 <20110201003359.8DDFF665@kernel>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110201003359.8DDFF665@kernel>
Sender: owner-linux-mm@kvack.org
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael J Wolf <mjwolf@us.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On Mon, Jan 31, 2011 at 04:33:59PM -0800, Dave Hansen wrote:
> 
> Right now, if a mm_walk has either ->pte_entry or ->pmd_entry
> set, it will unconditionally split and transparent huge pages
> it runs in to.  In practice, that means that anyone doing a
> 
> 	cat /proc/$pid/smaps
> 
> will unconditionally break down every huge page in the process
> and depend on khugepaged to re-collapse it later.  This is
> fairly suboptimal.
> 
> This patch changes that behavior.  It teaches each ->pmd_entry
> handler (there are three) that they must break down the THPs
> themselves.  Also, the _generic_ code will never break down
> a THP unless a ->pte_entry handler is actually set.
> 
> This means that the ->pmd_entry handlers can now choose to
> deal with THPs without breaking them down.

Makes perfect sense.  But you forgot to push down the splitting into
the two handlers in mm/memcontrol.c.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
