Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 1D4C16B004F
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 11:48:50 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n67FoKOK011818
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 8 Jul 2009 00:50:20 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1ED4D45DE53
	for <linux-mm@kvack.org>; Wed,  8 Jul 2009 00:50:20 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id F0EFC45DE52
	for <linux-mm@kvack.org>; Wed,  8 Jul 2009 00:50:19 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id BFBBF1DB803E
	for <linux-mm@kvack.org>; Wed,  8 Jul 2009 00:50:19 +0900 (JST)
Received: from ml11.s.css.fujitsu.com (ml11.s.css.fujitsu.com [10.249.87.101])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5AE90E08001
	for <linux-mm@kvack.org>; Wed,  8 Jul 2009 00:50:19 +0900 (JST)
Message-ID: <f3d6b9b393ab831bce368903008fdc13.squirrel@webmail-b.css.fujitsu.com>
Date: Wed, 8 Jul 2009 00:50:18 +0900 (JST)
Subject: Re: [RFC][PATCH 0/4] ZERO PAGE again v2
From: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;charset=iso-2022-jp
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, avi@redhat.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:
> On Tue, Jul 07, 2009 at 06:06:29PM +0900, KAMEZAWA Hiroyuki wrote:
>> 3. Considering save&restore application's data table, ZERO_PAGE is
>> useful.
>>    maybe.
>
> I just wouldn't like to re-add significant complexity back to
> the vm without good and concrete examples. OK I agree that
> just saying "rewrite your code" is not so good, but are there
> real significant problems? Is it inside just a particuar linear
> algebra library or something  that might be able to be updated?
>
As far as I can tell

I know 2 cases from my limited experience for user support.

1. A middlware maps /dev/zero with PRIVATE mapping and use copy-on-write
   intentionally. I think this is because their Solaris? apps required
   /dev/zero to use ZERO_PAGE or anon.
   I don't know much about solaris but
   "mapping /dev/zero eats up tons of memory" sounds strange for me.

2. A HPC middleware seems to make use of ZERO_PAGE to do checkpoint/restart
   of his job. (Maybe they can rewrite programs as you say.)

Maybe there are others. (I'm not afraid of famous OSS applications/library.
There will be enough technical support for such apps.)

To be honest, I'd like to support /dev/zero, at least.
"mmap(/dev/zero, PROT_READ) caues OOM" sounds like a crazy behavior as OS.

Is it ok to write fault handler for /dev/zero and use zero page even if
this request is rejected ?

It was a choice to advertise "ZERO PAGE is not available any more, plz
check and rewrite you applications" to all my customers. But I'm being
pessimistic about this issue. (So, trying this patch)
Users will not understand what is the change and I'll see some of OOM
report caused by this change.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
