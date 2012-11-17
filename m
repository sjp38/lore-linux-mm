Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id 57FCE6B004D
	for <linux-mm@kvack.org>; Sat, 17 Nov 2012 18:08:56 -0500 (EST)
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Sat, 17 Nov 2012 18:08:55 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id A73B838C8039
	for <linux-mm@kvack.org>; Sat, 17 Nov 2012 18:08:51 -0500 (EST)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id qAHN8oxl295424
	for <linux-mm@kvack.org>; Sat, 17 Nov 2012 18:08:51 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id qAHN8oO1018112
	for <linux-mm@kvack.org>; Sat, 17 Nov 2012 21:08:50 -0200
Message-ID: <50A81900.8000801@linux.vnet.ibm.com>
Date: Sat, 17 Nov 2012 15:08:48 -0800
From: Dave Hansen <dave@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: 3.7-rc6 memory accounting problem (manifests like a memory leak)
References: <bug-50181-27@https.bugzilla.kernel.org/> <20121113140352.4d2db9e8.akpm@linux-foundation.org> <1352988349.6409.4.camel@c2d-desktop.mypicture.info> <20121115141258.8e5cc669.akpm@linux-foundation.org> <1353021103.6409.31.camel@c2d-desktop.mypicture.info> <50A68718.3070002@linux.vnet.ibm.com> <20121116111559.63ec1622.akpm@linux-foundation.org> <50A6D357.3070103@linux.vnet.ibm.com>
In-Reply-To: <50A6D357.3070103@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Milos Jakovljevic <sukijaki@gmail.com>, bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>

page_owner didn't help, at least not directly.  As the pages "leak",
they stop showing up in page_owner, which means they're in the
allocator.  Check out buddyinfo/meminfo:

> dave@nimitz:~/ltc/linux.git$ cat /proc/buddyinfo /proc/meminfo 
> Node 0, zone      DMA      0      0      0      1      2      1      1      0      1      1      3 
> Node 0, zone    DMA32  25450  13645  11665   2994   1242    665    234     50     12      1      1 
> Node 0, zone   Normal   6494  28630  16790   5872   3524   1666    844    238    146     60    398 
> MemTotal:        7825604 kB
> MemFree:         1285260 kB
...

Just the 398 order-10 zone Normal pages account for ~1.6GB of free
memory, yet the MemFree is ~1.3GB, and that's a *SINGLE* bucket in the
buddy allocator.  Adding them all up, it's fairly close to the amount of
memory that I'm missing at the moment.

Rather than being a real leak, it looks like this might just be an
accounting problem:

$ cat /proc/zoneinfo  | egrep 'free_pages|Node'
Node 0, zone      DMA
    nr_free_pages 3976
Node 0, zone    DMA32
    nr_free_pages 177041
Node 0, zone   Normal
    nr_free_pages 16148

That 16148 pages for ZONE_NORMAL is obviously bogus compared to what
buddyinfo is saying.

Commit d1ce749a0d did mess with NR_FREE_PAGES accounting quite a bit.
Guess I'll try a revert and see where I end up.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
