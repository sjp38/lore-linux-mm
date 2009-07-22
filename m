Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 542A06B004D
	for <linux-mm@kvack.org>; Tue, 21 Jul 2009 20:40:33 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n6M0eYnS020637
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 22 Jul 2009 09:40:34 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5854045DE6E
	for <linux-mm@kvack.org>; Wed, 22 Jul 2009 09:40:34 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3412345DE60
	for <linux-mm@kvack.org>; Wed, 22 Jul 2009 09:40:34 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1839D1DB803B
	for <linux-mm@kvack.org>; Wed, 22 Jul 2009 09:40:34 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id C5C1B1DB803A
	for <linux-mm@kvack.org>; Wed, 22 Jul 2009 09:40:33 +0900 (JST)
Date: Wed, 22 Jul 2009 09:38:47 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] hibernate / memory hotplug: always use
 for_each_populated_zone()
Message-Id: <20090722093847.61f0e4ee.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090722092535.5eac1ff6.kamezawa.hiroyu@jp.fujitsu.com>
References: <1248103551.23961.0.camel@localhost.localdomain>
	<20090721071508.GB12734@osiris.boeblingen.de.ibm.com>
	<20090721163846.2a8001c1.kamezawa.hiroyu@jp.fujitsu.com>
	<200907211611.09525.rjw@sisk.pl>
	<20090722092535.5eac1ff6.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, Heiko Carstens <heiko.carstens@de.ibm.com>, Nigel Cunningham <ncunningham@crca.org.au>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Yasunori Goto <y-goto@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 22 Jul 2009 09:25:35 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> See ia64's ia64_pfn_valid(). It uses get_user() very effectively.
> (I think this cost cost is small in any arch...)
> 
>  523 ia64_pfn_valid (unsigned long pfn)
>  524 {
>  525         char byte;
>  526         struct page *pg = pfn_to_page(pfn);
>  527 
>  528         return     (__get_user(byte, (char __user *) pg) == 0)
>  529                 && ((((u64)pg & PAGE_MASK) == (((u64)(pg + 1) - 1) & PAGE_MASK))
>  530                         || (__get_user(byte, (char __user *) (pg + 1) - 1) == 0));
>  531 }
> 
Just an explanation. This code is for checking "there is memmap or not" for 
CONFIG_VIRTUAL_MEMMAP+CONFIG_DISCONTIGMEM, which allocates memmap in virtually
contiguous area. Because ia64 tends to have very sparse memory map,
memmap cannot be allocated in continuous area and memmap has holes.

This code checkes first byte and last byte of "struct page" is valid.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
