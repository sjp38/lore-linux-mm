Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id AC31E6B0005
	for <linux-mm@kvack.org>; Sun,  7 Apr 2013 11:39:01 -0400 (EDT)
Received: by mail-vc0-f174.google.com with SMTP id kw10so2084165vcb.33
        for <linux-mm@kvack.org>; Sun, 07 Apr 2013 08:39:00 -0700 (PDT)
Message-ID: <5161931A.8060501@gmail.com>
Date: Sun, 07 Apr 2013 11:39:06 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/3] mm/page_alloc: convert zone_pcp_update() to use on_each_cpu()
 instead of stop_machine()
References: <1365194030-28939-1-git-send-email-cody@linux.vnet.ibm.com> <1365194030-28939-3-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1365194030-28939-3-git-send-email-cody@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cody P Schafer <cody@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, kosaki.motohiro@gmail.com

(4/5/13 4:33 PM), Cody P Schafer wrote:
> No off-cpu users of the percpu pagesets exist.
> 
> zone_pcp_update()'s goal is to adjust the ->high and ->mark members of a
> percpu pageset based on a zone's ->managed_pages. We don't need to drain
> the entire percpu pageset just to modify these fields. Avoid calling
> setup_pageset() (and the draining required to call it) and instead just
> set the fields' values.
> 
> This does change the behavior of zone_pcp_update() as the percpu
> pagesets will not be drained when zone_pcp_update() is called (they will
> end up being shrunk, not completely drained, later when a 0-order page
> is freed in free_hot_cold_page()).
> 
> Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>

NAK.

1) zone_pcp_update() is only used from memory hotplug and it require page drain.
2) stop_machin is used for avoiding race. just removing it is insane.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
