Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 57C8E5F0001
	for <linux-mm@kvack.org>; Mon, 20 Apr 2009 01:05:01 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3K553n0019372
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 20 Apr 2009 14:05:03 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9941B45DD76
	for <linux-mm@kvack.org>; Mon, 20 Apr 2009 14:05:03 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 78FE145DD74
	for <linux-mm@kvack.org>; Mon, 20 Apr 2009 14:05:03 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 77D701DB8018
	for <linux-mm@kvack.org>; Mon, 20 Apr 2009 14:05:03 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 35D3F1DB8016
	for <linux-mm@kvack.org>; Mon, 20 Apr 2009 14:05:03 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: Does get_user_pages_fast lock the user pages in memory in my case?
In-Reply-To: <20090420135323.08015e32.minchan.kim@barrios-desktop>
References: <49EBEBC0.8090102@gmail.com> <20090420135323.08015e32.minchan.kim@barrios-desktop>
Message-Id: <20090420135748.2506.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon, 20 Apr 2009 14:05:02 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Huang Shijie <shijie8@gmail.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> It's rather awkward use case of get_user_pages. 
> 
> If you want to share one big buffer between kernel and user, 
> You can vmalloc and remap_pfn_range.
> You can refer cpia_mmap in drivers/media/video/cpia.c

Hm, good opinion. 

gup()ed page stay in lru, but remap_pfn_range() page doesn't.
it cause

gup() pinning:
	merit
		- Can processing any user process patch
		  (DirectIO need it)

	demerit
		- introduce reclaim slowdown

remap 
	merit
		- Don't cause any slowdown

	demerit
		- can be used on some special situation only.


Then, driver can use special memory and need long time pinning.
remap_pfn_range() is better.
but, DirectIO liked general pinning need gup() pinning.

I think.

but I'm not remap_pfn_range() specialist. perhaps I can talk about
incorrect thing ...


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
