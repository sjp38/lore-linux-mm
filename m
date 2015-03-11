Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f173.google.com (mail-lb0-f173.google.com [209.85.217.173])
	by kanga.kvack.org (Postfix) with ESMTP id 9C7F890002E
	for <linux-mm@kvack.org>; Wed, 11 Mar 2015 01:40:12 -0400 (EDT)
Received: by lbiw7 with SMTP id w7so6488173lbi.7
        for <linux-mm@kvack.org>; Tue, 10 Mar 2015 22:40:12 -0700 (PDT)
Received: from plane.gmane.org (plane.gmane.org. [80.91.229.3])
        by mx.google.com with ESMTPS id c6si557607lbo.127.2015.03.10.22.40.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 10 Mar 2015 22:40:10 -0700 (PDT)
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glkm-linux-mm-2@m.gmane.org>)
	id 1YVZNI-0001Ky-1Z
	for linux-mm@kvack.org; Wed, 11 Mar 2015 06:40:08 +0100
Received: from 73.202.97.95 ([73.202.97.95])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Wed, 11 Mar 2015 06:40:08 +0100
Received: from atomiclong64 by 73.202.97.95 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Wed, 11 Mar 2015 06:40:08 +0100
From: Lock Free <atomiclong64@gmail.com>
Subject: Re: Greedy kswapd reclaim behavior
Date: Wed, 11 Mar 2015 05:39:55 +0000 (UTC)
Message-ID: <loom.20150311T063736-490@post.gmane.org>
References: <CAN3bvwucTo41Kk+NdUf8Fa_bkVWyeMcRo2ttAJeDM0G9bHjLiw@mail.gmail.com> <loom.20150310T211234-554@post.gmane.org> <fe129e5a96d84f279693d0d4d764425c@HQMAIL108.nvidia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

Thanks for the response Krishna,

>> Caches shrinking doesn't necessarily release the pages of a particular zone.

I thought kswap will try and reclaim fs cache first, before trying to page and
potentially swap out pages...

We have 2 numa nodes with the following zones (see below).  Every two hours our
available free space reported by /proc/meminfo drops down to ~180MB and then we
see fs cache flushed followed by anonymous pages reclaimed.  The total is
~2-3GB.  The fs cache accounted for ~2GB.  My understanding is kswapd should
stop reclaiming once free pages is above the high water mark, however we see
excessive swapping out freeing pages beyond the high water mark and impacting
the performance of a memory latency sensitive application.

The /proc/zoneinfo below doesn't correspond to the time the issue occurred, just
a example of what our host looks like.  Unfortunately we don't have zoneinfo
persisted.  We do have the buddyinfo persisted not sure if that would help.

Node 0, zone   Normal
  pages free     163947
        min      11275
        low      14093
        high     16912
        scanned  0
        spanned  3145728
        present  3102720
Node 1, zone      DMA
  pages free     3935
        min      13
        low      16
        high     19
        scanned  0
        spanned  4095
        present  3840
Node 1, zone    DMA32
  pages free     19524
        min      3017
        low      3771
        high     4525
        scanned  0
        spanned  1044480
        present  830385
Node 1, zone   Normal
  pages free     294707
        min      8221
        low      10276
        high     12331
        scanned  0
        spanned  2293760
        present  2262400

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
