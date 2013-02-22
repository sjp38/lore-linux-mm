Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id DD0B56B0002
	for <linux-mm@kvack.org>; Fri, 22 Feb 2013 06:16:12 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 054F53EE0BC
	for <linux-mm@kvack.org>; Fri, 22 Feb 2013 20:16:11 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id E1A9B45DEB6
	for <linux-mm@kvack.org>; Fri, 22 Feb 2013 20:16:10 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id CB6D345DEB5
	for <linux-mm@kvack.org>; Fri, 22 Feb 2013 20:16:10 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id B3FBB1DB803F
	for <linux-mm@kvack.org>; Fri, 22 Feb 2013 20:16:10 +0900 (JST)
Received: from m1000.s.css.fujitsu.com (m1000.s.css.fujitsu.com [10.240.81.136])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6D15C1DB803B
	for <linux-mm@kvack.org>; Fri, 22 Feb 2013 20:16:10 +0900 (JST)
Message-ID: <51275364.3010908@jp.fujitsu.com>
Date: Fri, 22 Feb 2013 20:15:48 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] slub: correctly bootstrap boot caches
References: <1361529030-17462-1-git-send-email-glommer@parallels.com>
In-Reply-To: <1361529030-17462-1-git-send-email-glommer@parallels.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Pekka Enberg <penberg@kernel.org>

(2013/02/22 19:30), Glauber Costa wrote:
> After we create a boot cache, we may allocate from it until it is bootstraped.
> This will move the page from the partial list to the cpu slab list. If this
> happens, the loop:
> 
> 	list_for_each_entry(p, &n->partial, lru)
> 
> that we use to scan for all partial pages will yield nothing, and the pages
> will keep pointing to the boot cpu cache, which is of course, invalid. To do
> that, we should flush the cache to make sure that the cpu slab is back to the
> partial list.
> 
> Although not verified in practice, I also point out that it is not safe to scan
> the full list only when debugging is on in this case. As unlikely as it is, it
> is theoretically possible for the pages to be full. If they are, they will
> become unreachable. Aside from scanning the full list, we also need to make
> sure that the pages indeed sit in there: the easiest way to do it is to make
> sure the boot caches have the SLAB_STORE_USER debug flag set.
> 
> Signed-off-by: Glauber Costa <glommer@parallels.com>
> Reported-by:  Steffen Michalke <StMichalke@web.de>
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Tejun Heo <tj@kernel.org>
> Cc: Pekka Enberg <penberg@kernel.org>
> Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
You're quick :) the issue is fixed in my environ.

Tested-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu,com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
