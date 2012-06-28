Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 6E3BE6B005A
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 02:03:49 -0400 (EDT)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <shangw@linux.vnet.ibm.com>;
	Thu, 28 Jun 2012 00:03:48 -0600
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id EE7C43E4005E
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 06:03:43 +0000 (WET)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5S63XXS225880
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 00:03:37 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5S63Xse029989
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 00:03:33 -0600
Date: Thu, 28 Jun 2012 14:03:30 +0800
From: Gavin Shan <shangw@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 2/3] mm/sparse: fix possible memory leak
Message-ID: <20120628060330.GA26576@shangw>
Reply-To: Gavin Shan <shangw@linux.vnet.ibm.com>
References: <1340814968-2948-1-git-send-email-shangw@linux.vnet.ibm.com>
 <1340814968-2948-2-git-send-email-shangw@linux.vnet.ibm.com>
 <4FEB3C67.6070604@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4FEB3C67.6070604@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Gavin Shan <shangw@linux.vnet.ibm.com>, linux-mm@kvack.org, mhocko@suse.cz, rientjes@google.com, hannes@cmpxchg.org, akpm@linux-foundation.org

>> With CONFIG_SPARSEMEM_EXTREME, the root memory section descriptors
>> are allocated by slab or bootmem allocator. Also, the descriptors
>> might have been allocated and initialized during the hotplug path.
>> However, the memory chunk allocated in current implementation wouldn't
>> be put into the available pool if that has been allocated. The situation
>> will lead to memory leak.
>
>I've read this changelog about ten times and I'm still not really clear
>what the bug is here.
>

yep, I need improve my written English definitely :-)

>--
>
>sparse_index_init() is designed to be safe if two copies of it race.  It
>uses "index_init_lock" to ensure that, even in the case of a race, only
>one CPU will manage to do:
>
>	mem_section[root] = section;
>
>However, in the case where two copies of sparse_index_init() _do_ race,
>the one that loses the race will leak the "section" that
>sparse_index_alloc() allocated for it.  This patch fixes that leak.
>
>--

Thank you very much, Dave. Let me merge your changelog into next version.

>
>Technically, I'm not sure that we can race during the time when we'd be
>using bootmem.  I think we do all those initializations single-threaded
>at the moment, and we'd finish them before we turn the slab on.  So,
>technically, we probably don't need the bootmem stuff in
>sparse_index_free().  But, I guess it doesn't hurt, and it's fine for
>completeness.
>
>Gavin, have you actually tested this in some way?  It looks OK to me,
>but I worry that you've just added a block of code that's exceedingly
>unlikely to get run.

I didn't test this and I just catch the point while reading the source
code. By the way, I would like to know the popular utilities used for
memory testing. If you can share some information regarding that, that
would be great.

	- memory related benchmark testing utility.
	- some documents on Linux memory testing.

Thanks,
Gavin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
