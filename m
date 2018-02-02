Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f200.google.com (mail-yw0-f200.google.com [209.85.161.200])
	by kanga.kvack.org (Postfix) with ESMTP id B1DBB6B0007
	for <linux-mm@kvack.org>; Fri,  2 Feb 2018 09:16:53 -0500 (EST)
Received: by mail-yw0-f200.google.com with SMTP id r133so22435526ywe.17
        for <linux-mm@kvack.org>; Fri, 02 Feb 2018 06:16:53 -0800 (PST)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id s2si445097ybj.380.2018.02.02.06.16.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Feb 2018 06:16:52 -0800 (PST)
From: Robert Harris <robert.m.harris@oracle.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Subject: [Resend] Possible bug in __fragmentation_index()
Date: Fri, 2 Feb 2018 14:16:39 +0000
Message-Id: <83AECC32-77A4-427D-9043-DE6FC48AD3FC@oracle.com>
Mime-Version: 1.0 (Apple Message framework v1085)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Kemi Wang <kemi.wang@intel.com>, ying.huang@intel.com, David Rientjes <rientjes@google.com>, Vinayak Menon <vinmenon@codeaurora.org>, Mel Gorman <mgorman@suse.de>

I was planning to annotate the opaque calculation in
__fragmentation_index() but on closer inspection I think there may be a
bug.  I could use some feedback.

Firstly, for the case of fragmentation and ignoring the scaling,
__fragmentation_index() purports to return a value in the range 0 to 1.
Generally, however, the lower bound is actually 0.5.  Here's an
illustration using a zone that I fragmented with selective calls to
__alloc_pages() and __free_pages --- the fragmentation for order-1 could
not be minimised further yet is reported as 0.5:

# head -1 /proc/buddyinfo
Node 0, zone      DMA   1983      0      0      0      0      0      0   =
   0      0      0      0=20
# head -1 /sys/kernel/debug/extfrag/extfrag_index=20
Node 0, zone      DMA -1.000 0.500 0.750 0.875 0.937 0.969 0.984 0.992 =
0.996 0.998 0.999=20
#

This is significant because 0.5 is the default value of
sysctl_extfrag_threshold, meaning that compaction will not be suppressed
for larger blocks when memory is scarce rather than fragmented.  Of
course, sysctl_extfrag_threshold is a tuneable so the first question is:
does this even matter?

The calculation in __fragmentation_index() isn't documented but the
apparent error in the lower bound may be explained by showing that the
index is approximated by

F ~ 1 - 1/N

where N is (conceptually) the number of free blocks into which each
potential requested-size block has been split.  I.e. if all free space
were compacted then there would be B free blocks of the requested size
where

B =3D info->free_pages/requested

and thus

N =3D info->free_blocks_total/B

The case of least fragmentation must be when all of the requested-size
blocks have been split just once to form twice as many blocks in the
next lowest free list.  Thus the lowest value of N is 2 and the lowest
vale of F is 0.5.  I readied a patch that, in essence, defined
F =3D 1 - 2/N and thereby set the bounds of __fragmentation_index() as
0 <=3D F < 1.  Before sending it, I realised that, during testing, I =
*had* seen
the occasional instance of F < 0.5, e.g. F =3D 0.499.  Revisting the
calculation, I see that the actual implementation is

F =3D 1 - [1/N + 1/info->free_blocks_total]

meaning that a very severe shortage of free memory *could* tip the
balance in favour of "low fragmentation".  Although this seems highly
unlikely to occur outside testing, it does reflect the directive in the
comment above the function, i.e. favour page reclaim when fragmentation
is low.  My second question: is the current implementation of F is
intentional and, if not, what is the actual intent?

The comments in compaction_suitable() suggest that the compaction/page
reclaim decision is one of cost but, as compaction is linear, this isn't
what __fragmentation_index() is calculating.  A more reasonable argument
is that there's generally some lower limit on the fragmentation
achievable through compaction, given the inevitable presence of
non-migratable pages.  Is there anything else going on?

Robert Harris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
