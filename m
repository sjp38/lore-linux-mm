Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 906766B0062
	for <linux-mm@kvack.org>; Tue,  8 Jan 2013 12:15:42 -0500 (EST)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Tue, 8 Jan 2013 12:15:41 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id DC769C9003C
	for <linux-mm@kvack.org>; Tue,  8 Jan 2013 12:15:34 -0500 (EST)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r08HFVps103570
	for <linux-mm@kvack.org>; Tue, 8 Jan 2013 12:15:32 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r08HFLvK009658
	for <linux-mm@kvack.org>; Tue, 8 Jan 2013 15:15:21 -0200
Message-ID: <50EC541B.5000905@linux.vnet.ibm.com>
Date: Tue, 08 Jan 2013 09:15:07 -0800
From: Dave Hansen <dave@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCHv2 8/9] zswap: add to mm/
References: <1357590280-31535-1-git-send-email-sjenning@linux.vnet.ibm.com> <1357590280-31535-9-git-send-email-sjenning@linux.vnet.ibm.com>
In-Reply-To: <1357590280-31535-9-git-send-email-sjenning@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On 01/07/2013 12:24 PM, Seth Jennings wrote:
> +struct zswap_tree {
> +	struct rb_root rbroot;
> +	struct list_head lru;
> +	spinlock_t lock;
> +	struct zs_pool *pool;
> +};

BTW, I spent some time trying to get this lock contended.  You thought
the anon_vma locks would dominate and this spinlock would not end up
very contended.

I figured that if I hit zswap from a bunch of CPUs that _didn't_ use
anonymous memory (and thus the anon_vma locks) that some more contention
would pop up.  I did that with a bunch of CPUs writing to tmpfs, and
this lock was still well down below anon_vma.  The anon_vma contention
was obviously coming from _other_ anonymous memory around.

IOW, I feel a bit better about this lock.  I only tested on 16 cores on
a system with relatively light NUMA characteristics, and it might be the
bottleneck if all the anonymous memory on the system is mlock()'d and
you're pounding on tmpfs, but that's pretty contrived.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
