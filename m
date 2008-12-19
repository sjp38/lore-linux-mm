Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 89F0D6B0044
	for <linux-mm@kvack.org>; Fri, 19 Dec 2008 01:32:16 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mBJ6YL6L017795
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 19 Dec 2008 15:34:22 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id BB69345DD80
	for <linux-mm@kvack.org>; Fri, 19 Dec 2008 15:34:21 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 977FF45DD7E
	for <linux-mm@kvack.org>; Fri, 19 Dec 2008 15:34:21 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7AA1C1DB803C
	for <linux-mm@kvack.org>; Fri, 19 Dec 2008 15:34:21 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 325A51DB8038
	for <linux-mm@kvack.org>; Fri, 19 Dec 2008 15:34:21 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: Corruption with O_DIRECT and unaligned user buffers
In-Reply-To: <20081218152952.GW24856@random.random>
References: <20081119165819.GE19209@random.random> <20081218152952.GW24856@random.random>
Message-Id: <20081219151118.A0AC.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 19 Dec 2008 15:34:20 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Nick Piggin <nickpiggin@yahoo.com.au>, Tim LaBerge <tim.laberge@quantum.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi

I don't undestand your patch yet. just dumb question.


> Problem this only fixes it for rhel and other kernels that don't have
> get_user_pages_fast yet. You really have to think at some way to
> serialize get_user_pages_fast for this and ksm. get_user_pages_fast
> makes it a unfixable bug to mark any anon pte from readwrite to
> readonly when there could be O_DIRECT on it, this has to be solved
> sooner or later...

I'm confused.

I think gup_pte_range() doesn't change pte attribute.
Could you explain why get_user_pages_fast() is evil?


> So last detail, I take it as safe not to check if the pte is writeable
> after handle_mm_fault returns as the new address space is private and
> the page fault couldn't possibly race with anything (i.e. pte_same is
> guaranteed to succeed). For the mainline version we can remove the
> page lock and replace with smb_wmb in add_to_swap_cache and smp_rmb in
> the page_count/PG_swapcache read to remove that trylockpage. Given
> smp_wmb is barrier() it should worth it.

Why rhel can't use memory barrier?




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
