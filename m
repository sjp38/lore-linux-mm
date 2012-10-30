Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 975106B0062
	for <linux-mm@kvack.org>; Tue, 30 Oct 2012 11:19:51 -0400 (EDT)
Received: from /spool/local
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Tue, 30 Oct 2012 09:19:50 -0600
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 4ECE83E4006D
	for <linux-mm@kvack.org>; Tue, 30 Oct 2012 09:19:45 -0600 (MDT)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q9UFJhuv152902
	for <linux-mm@kvack.org>; Tue, 30 Oct 2012 09:19:44 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q9UFJc0E010205
	for <linux-mm@kvack.org>; Tue, 30 Oct 2012 09:19:39 -0600
Message-ID: <508FEECE.2070402@linux.vnet.ibm.com>
Date: Tue, 30 Oct 2012 08:14:22 -0700
From: Dave Hansen <dave@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: memmap_init_zone() performance improvement
References: <1349276174-8398-1-git-send-email-mike.yoknis@hp.com> <20121008151656.GM29125@suse.de> <1349794597.29752.10.camel@MikesLinux.fc.hp.com> <1350676398.1169.6.camel@MikesLinux.fc.hp.com> <20121020082858.GA2698@suse.de>
In-Reply-To: <20121020082858.GA2698@suse.de>
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Mike Yoknis <mike.yoknis@hp.com>, mingo@redhat.com, akpm@linux-foundation.org, linux-arch@vger.kernel.org, mmarek@suse.cz, tglx@linutronix.de, hpa@zytor.com, arnd@arndb.de, sam@ravnborg.org, minchan@kernel.org, kamezawa.hiroyu@jp.fujitsu.com, mhocko@suse.cz, linux-kbuild@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 10/20/2012 01:29 AM, Mel Gorman wrote:
> I'm travelling at the moment so apologies that I have not followed up on
> this. My problem is still the same with the patch - it changes more
> headers than is necessary and it is sparsemem specific. At minimum, try
> the suggestion of 
> 
> if (!early_pfn_valid(pfn)) {
>       pfn = ALIGN(pfn + MAX_ORDER_NR_PAGES, MAX_ORDER_NR_PAGES) - 1;
>       continue;
> }

Sorry I didn't catch this until v2...

Is that ALIGN() correct?  If pfn=3, then it would expand to:

(3+MAX_ORDER_NR_PAGES+MAX_ORDER_NR_PAGES-1) & ~(MAX_ORDER_NR_PAGES-1)

You would end up skipping the current MAX_ORDER_NR_PAGES area, and then
one _extra_ because ALIGN() aligns up, and you're adding
MAX_ORDER_NR_PAGES too.  It doesn't matter unless you run in to a
!early_valid_pfn() in the middle of a MAX_ORDER area, I guess.

I think this would work, plus be a bit smaller:

	pfn = ALIGN(pfn + 1, MAX_ORDER_NR_PAGES) - 1;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
