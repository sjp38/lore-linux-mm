Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 401F46B0119
	for <linux-mm@kvack.org>; Fri,  5 Apr 2013 16:34:22 -0400 (EDT)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Fri, 5 Apr 2013 16:34:21 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id A4BCA6E803C
	for <linux-mm@kvack.org>; Fri,  5 Apr 2013 16:34:11 -0400 (EDT)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r35KYCn8292858
	for <linux-mm@kvack.org>; Fri, 5 Apr 2013 16:34:13 -0400
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r35KYAjP004527
	for <linux-mm@kvack.org>; Fri, 5 Apr 2013 14:34:10 -0600
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [PATCH 0/3] mm: fixup changers of per cpu pageset's ->high and ->batch
Date: Fri,  5 Apr 2013 13:33:47 -0700
Message-Id: <1365194030-28939-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

In one case while modifying the ->high and ->batch fields of per cpu pagesets
we're unneededly using stop_machine() (patches 1 & 2), and in another we don't have any
syncronization at all (patch 3).

This patchset fixes both of them.

Note that it results in a change to the behavior of zone_pcp_update(), which is
used by memory_hotplug. I _think_ that I've diserned (and preserved) the
essential behavior (changing ->high and ->batch), and only eliminated unneeded
actions (draining the per cpu pages), but this may not be the case.

--
 mm/page_alloc.c | 63 +++++++++++++++++++++++++++------------------------------
 1 file changed, 30 insertions(+), 33 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
