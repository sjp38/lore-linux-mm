Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 261F76B0068
	for <linux-mm@kvack.org>; Thu, 23 Aug 2012 11:41:50 -0400 (EDT)
Received: from /spool/local
	by e1.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Thu, 23 Aug 2012 11:41:48 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 2824238C804F
	for <linux-mm@kvack.org>; Thu, 23 Aug 2012 11:33:15 -0400 (EDT)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q7NFXEOr131278
	for <linux-mm@kvack.org>; Thu, 23 Aug 2012 11:33:14 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q7NFXEnq004000
	for <linux-mm@kvack.org>; Thu, 23 Aug 2012 11:33:14 -0400
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: [PATCH 0/2] revert changes to zcache_do_preload()
Date: Thu, 23 Aug 2012 10:33:09 -0500
Message-Id: <1345735991-6995-1-git-send-email-sjenning@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

This patchset fixes a regression in 3.6 by reverting two dependent
commits that made changes to zcache_do_preload().

The commits undermine an assumption made by tmem_put() in
the cleancache path that preemption is disabled.  This change
introduces a race condition that can result in the wrong page
being returned by tmem_get(), causing assorted errors (segfaults,
apparent file corruption, etc) in userspace.

The corruption was discussed in this thread:
https://lkml.org/lkml/2012/8/17/494

Please apply this patchset to 3.6.  This problem didn't exist
in previous releases so nothing need be done for the stable trees.

Seth Jennings (2):
  Revert "staging: zcache: cleanup zcache_do_preload and
    zcache_put_page"
  Revert "staging: zcache: optimize zcache_do_preload"

 drivers/staging/zcache/zcache-main.c |   54 +++++++++++++++++++---------------
 1 file changed, 31 insertions(+), 23 deletions(-)

-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
