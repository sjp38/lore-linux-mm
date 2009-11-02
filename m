Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id F39F26B004D
	for <linux-mm@kvack.org>; Mon,  2 Nov 2009 18:11:33 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nA2NBVWb001766
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 3 Nov 2009 08:11:31 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 0DA6345DE50
	for <linux-mm@kvack.org>; Tue,  3 Nov 2009 08:11:31 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id DCB6145DE4E
	for <linux-mm@kvack.org>; Tue,  3 Nov 2009 08:11:30 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id C4B5D1DB8040
	for <linux-mm@kvack.org>; Tue,  3 Nov 2009 08:11:30 +0900 (JST)
Received: from ml12.s.css.fujitsu.com (ml12.s.css.fujitsu.com [10.249.87.102])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 7DE231DB803E
	for <linux-mm@kvack.org>; Tue,  3 Nov 2009 08:11:30 +0900 (JST)
Message-ID: <244dc9813cd8dbb5e1ce1eafa61e9e2b.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <alpine.DEB.1.10.0911021209180.2028@V090114053VZO-1>
References: <20091102162244.9425e49b.kamezawa.hiroyu@jp.fujitsu.com>
    <20091102162617.9d07e05f.kamezawa.hiroyu@jp.fujitsu.com>
    <alpine.DEB.1.10.0911021209180.2028@V090114053VZO-1>
Date: Tue, 3 Nov 2009 08:11:29 +0900 (JST)
Subject: Re: [RFC][-mm][PATCH 3/6] oom-killer: count lowmem rss
From: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;charset=iso-2022-jp
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, aarcange@redhat.com, akpm@linux-foundation.org, minchan.kim@gmail.com, rientjes@google.com, vedran.furac@gmail.com, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
>
> I dont think this patch will work in !NUMA but its useful there too. Can
> you make this work in general?
>
for NUMA
==
+static inline int is_lowmem_page(struct page *page)
+{
+	if (unlikely(page_zonenum(page) < policy_zone))
+		return 1;
+	return 0;
+}
==

is used. Doesn't this work well ?
This check means
It enough memory:
   On my ia64 box ZONE_DMA(<4G), x86-64 box(GFP_DMA32) is caught
If small memory (typically < 4G)
   ia64 box no lowmem, x86-64 box GPF_DMA is caught
If all zones are policy zone (ppc)
   no lowmem zone.

Because "amount of memory" changes the situation "which is lowmem?",
I used policy zone. If this usage is not appropriate, I'll add some new.

BTW, is it better to export this value from somewhere ?

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
