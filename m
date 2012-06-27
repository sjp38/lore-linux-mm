Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id 4C31C6B005A
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 13:01:56 -0400 (EDT)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Wed, 27 Jun 2012 13:01:55 -0400
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 2547B38C8024
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 13:01:51 -0400 (EDT)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5RH1kY835979464
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 13:01:47 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5RH1hhA008049
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 14:01:43 -0300
Message-ID: <4FEB3C67.6070604@linux.vnet.ibm.com>
Date: Wed, 27 Jun 2012 10:01:27 -0700
From: Dave Hansen <dave@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 2/3] mm/sparse: fix possible memory leak
References: <1340814968-2948-1-git-send-email-shangw@linux.vnet.ibm.com> <1340814968-2948-2-git-send-email-shangw@linux.vnet.ibm.com>
In-Reply-To: <1340814968-2948-2-git-send-email-shangw@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gavin Shan <shangw@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, mhocko@suse.cz, rientjes@google.com, hannes@cmpxchg.org, akpm@linux-foundation.org

On 06/27/2012 09:36 AM, Gavin Shan wrote:
> With CONFIG_SPARSEMEM_EXTREME, the root memory section descriptors
> are allocated by slab or bootmem allocator. Also, the descriptors
> might have been allocated and initialized during the hotplug path.
> However, the memory chunk allocated in current implementation wouldn't
> be put into the available pool if that has been allocated. The situation
> will lead to memory leak.

I've read this changelog about ten times and I'm still not really clear
what the bug is here.

--

sparse_index_init() is designed to be safe if two copies of it race.  It
uses "index_init_lock" to ensure that, even in the case of a race, only
one CPU will manage to do:

	mem_section[root] = section;

However, in the case where two copies of sparse_index_init() _do_ race,
the one that loses the race will leak the "section" that
sparse_index_alloc() allocated for it.  This patch fixes that leak.

--

Technically, I'm not sure that we can race during the time when we'd be
using bootmem.  I think we do all those initializations single-threaded
at the moment, and we'd finish them before we turn the slab on.  So,
technically, we probably don't need the bootmem stuff in
sparse_index_free().  But, I guess it doesn't hurt, and it's fine for
completeness.

Gavin, have you actually tested this in some way?  It looks OK to me,
but I worry that you've just added a block of code that's exceedingly
unlikely to get run.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
