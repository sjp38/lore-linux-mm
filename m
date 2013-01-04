Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 71A3C6B005D
	for <linux-mm@kvack.org>; Fri,  4 Jan 2013 10:55:44 -0500 (EST)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Fri, 4 Jan 2013 10:55:42 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 6405CC9003C
	for <linux-mm@kvack.org>; Fri,  4 Jan 2013 10:55:25 -0500 (EST)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r04FtPKT301570
	for <linux-mm@kvack.org>; Fri, 4 Jan 2013 10:55:25 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r04FtNoP031901
	for <linux-mm@kvack.org>; Fri, 4 Jan 2013 13:55:25 -0200
Message-ID: <50E6FB66.7020805@linux.vnet.ibm.com>
Date: Fri, 04 Jan 2013 09:55:18 -0600
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 7/8] zswap: add to mm/
References: <1355262966-15281-1-git-send-email-sjenning@linux.vnet.ibm.com> <1355262966-15281-8-git-send-email-sjenning@linux.vnet.ibm.com> <0e91c1e5-7a62-4b89-9473-09fff384a334@default> <50E32255.60901@linux.vnet.ibm.com> <50E4588E.6080001@linux.vnet.ibm.com> <28a63847-7659-44c4-9c33-87f5d50b2ea0@default> <50E479AD.9030502@linux.vnet.ibm.com> <9955b9e0-731b-4cbf-9db0-683fcd32f944@default> <20130103073339.GF3120@dastard> <ac37f7ce-b15a-40f8-9da7-858dea3651b9@default> <20130104023030.GK3120@dastard>
In-Reply-To: <20130104023030.GK3120@dastard>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Dan Magenheimer <dan.magenheimer@oracle.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Wilk <konrad.wilk@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On 01/03/2013 08:30 PM, Dave Chinner wrote:
>>> And so the two subsystems need different reclaim implementations.
>>> > > And, well, that's exactly what we have shrinkers for - implmenting
>>> > > subsystem specific reclaim policy. The shrinker infrastructure is
>>> > > responsible for them keeping balance between all the caches that
>>> > > have shrinkers and the size of the page cache...
>> > 
>> > Given the above, do you think either compressed-anonymous-pages or
>> > compressed-pagecache-pages are suitable candidates for the shrinker
>> > infrastructure?
> I don't know all the details of what you are trying to do, but you
> seem to be describing a two-level heirarchy - a pool of compressed
> data and a pool of uncompressed data, and under memory pressure are
> migrating data from the uncompressed pool to the compressed pool. On
> access, you are migrating back the other way.  Hence it seems to me
> that you could implement the process of migration from the
> uncompressed pool to the compressed pool as a shrinker so that it
> only happens as a result of memory pressure....

In our case, the mechanism for moving pages from the uncompressed pool
(anonymous memory) to the compressed pool is the swapping mechanism
itself.  The mechanism for moving pages the other way is the page
fault handler.

To summarize my ideas wrt to zswap and the shrinker interface, I don't
think there is a good use case here because all of the compressed
pages in zswap are conceptually dirty.  The writeback for these pages
is both slow (bio write) and requires memory allocation.  So zswap
isn't a cache in the usual sense, where cache contents are clean,
exist in RAM only for performance reasons, and can be freed in a
lightweight way at any time.

Thanks,
Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
