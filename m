Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 49775800D8
	for <linux-mm@kvack.org>; Mon, 22 Jan 2018 07:08:18 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id h200so9935861itb.3
        for <linux-mm@kvack.org>; Mon, 22 Jan 2018 04:08:18 -0800 (PST)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id n7si5844814ith.6.2018.01.22.04.08.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Jan 2018 04:08:17 -0800 (PST)
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w0MC6ous161542
	for <linux-mm@kvack.org>; Mon, 22 Jan 2018 12:08:16 GMT
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
	by userp2120.oracle.com with ESMTP id 2fnf9fr39b-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Mon, 22 Jan 2018 12:08:16 +0000
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by userv0022.oracle.com (8.14.4/8.14.4) with ESMTP id w0MC8FGH015707
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-mm@kvack.org>; Mon, 22 Jan 2018 12:08:15 GMT
Received: from abhmp0017.oracle.com (abhmp0017.oracle.com [141.146.116.23])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id w0MC8Fuj024268
	for <linux-mm@kvack.org>; Mon, 22 Jan 2018 12:08:15 GMT
From: Robert Harris <robert.m.harris@oracle.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Subject: Possible bug in __fragmentation_index()
Date: Mon, 22 Jan 2018 12:08:18 +0000
Message-Id: <EB1CE962-46D5-4773-A2D5-51F83B713CA9@oracle.com>
Mime-Version: 1.0 (Apple Message framework v1085)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

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
