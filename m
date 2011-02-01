Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 719FF8D0041
	for <linux-mm@kvack.org>; Tue,  1 Feb 2011 10:04:42 -0500 (EST)
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by e33.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p11EvlXN030346
	for <linux-mm@kvack.org>; Tue, 1 Feb 2011 07:57:47 -0700
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p11F3wTQ123364
	for <linux-mm@kvack.org>; Tue, 1 Feb 2011 08:03:58 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p11F3vN4030894
	for <linux-mm@kvack.org>; Tue, 1 Feb 2011 08:03:57 -0700
Subject: Re: [RFC][PATCH 2/6] pagewalk: only split huge pages when necessary
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20110201100433.GH19534@cmpxchg.org>
References: <20110201003357.D6F0BE0D@kernel>
	 <20110201003359.8DDFF665@kernel>  <20110201100433.GH19534@cmpxchg.org>
Content-Type: text/plain; charset="ANSI_X3.4-1968"
Date: Tue, 01 Feb 2011 07:03:56 -0800
Message-ID: <1296572636.27022.2870.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael J Wolf <mjwolf@us.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, 2011-02-01 at 11:04 +0100, Johannes Weiner wrote:
> On Mon, Jan 31, 2011 at 04:33:59PM -0800, Dave Hansen wrote:
> > Right now, if a mm_walk has either ->pte_entry or ->pmd_entry
> > set, it will unconditionally split and transparent huge pages
> > it runs in to.  In practice, that means that anyone doing a
> > 
> >       cat /proc/$pid/smaps
> > 
> > will unconditionally break down every huge page in the process
> > and depend on khugepaged to re-collapse it later.  This is
> > fairly suboptimal.
> > 
> > This patch changes that behavior.  It teaches each ->pmd_entry
> > handler (there are three) that they must break down the THPs
> > themselves.  Also, the _generic_ code will never break down
> > a THP unless a ->pte_entry handler is actually set.
> > 
> > This means that the ->pmd_entry handlers can now choose to
> > deal with THPs without breaking them down.
> 
> Makes perfect sense.  But you forgot to push down the splitting into
> the two handlers in mm/memcontrol.c. 

I did indeed.  I'll go fix those up.  Thanks for the review!

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
