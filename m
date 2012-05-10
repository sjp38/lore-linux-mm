Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id 564646B0044
	for <linux-mm@kvack.org>; Thu, 10 May 2012 12:13:26 -0400 (EDT)
Received: from ucsinet21.oracle.com (ucsinet21.oracle.com [156.151.31.93])
	by acsinet15.oracle.com (Sentrion-MTA-4.2.2/Sentrion-MTA-4.2.2) with ESMTP id q4AGDNnS017326
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-mm@kvack.org>; Thu, 10 May 2012 16:13:24 GMT
Received: from acsmt358.oracle.com (acsmt358.oracle.com [141.146.40.158])
	by ucsinet21.oracle.com (8.14.4+Sun/8.14.4) with ESMTP id q4AGDMQa010780
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-mm@kvack.org>; Thu, 10 May 2012 16:13:23 GMT
Received: from abhmt120.oracle.com (abhmt120.oracle.com [141.146.116.72])
	by acsmt358.oracle.com (8.12.11.20060308/8.12.11) with ESMTP id q4AGDMVH004452
	for <linux-mm@kvack.org>; Thu, 10 May 2012 11:13:22 -0500
MIME-Version: 1.0
Message-ID: <66ea94b0-2e40-44d1-9621-05f2a8257298@default>
Date: Thu, 10 May 2012 09:13:03 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: is there a "lru_cache_add_anon_tail"?
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

(Still working on allowing zcache to "evict" swap pages...)

Apologies if I got head/tail reversed as used by the
lru queues... the "directional sense" of the queues is
not obvious so I'll describe using different terminology...

If I have an anon page and I would like to add it to
the "reclaim soonest" end of the queue instead of the
"most recently used so don't reclaim it for a long time"
end of the queue, does an equivalent function similar to
lru_cache_add_anon(page) exist?

In other words, I want this dirty anon page to be
swapped out ASAP.

If no such function exists, can anyone more familiar
with the VM LRU queues suggest the code for
this function "lru_cache_add_anon_XXX(page)?
Also what would be the proper text for XXX?

I have some (experimental) code now to use it so
could iterate/debug with any suggested code.  The
calling snippet is:

=09__set_page_locked(new_page);
=09SetPageSwapBacked(new_page);
=09ret =3D __add_to_swap_cache(new_page, entry);
=09if (likely(!ret)) {
=09=09radix_tree_preload_end();
=09=09lru_cache_add_anon_XXX(new_page)
=09=09if (frontswap_get_page(new_page) =3D 0)
=09=09=09SetPageUptodate(new_page);
=09=09unlock_page(new_page);

This works using a call to the existing lru_cache_add_anon
but new_page doesn't get swapped out for a long time.

Thanks for any help/suggestions!
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
