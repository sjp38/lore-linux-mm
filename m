Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 54AA06B006A
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 03:09:57 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n677qk03016128
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 7 Jul 2009 16:52:47 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id C0E9E45DE65
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 16:52:46 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id B684E45DE63
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 16:52:45 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 72C851DB803F
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 16:52:45 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7796EE18001
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 16:52:44 +0900 (JST)
Date: Tue, 7 Jul 2009 16:51:01 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 0/4] ZERO PAGE again v2
Message-Id: <20090707165101.8c14b5ac.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: npiggin@suse.de, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, avi@redhat.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Hi, this is ZERO_PAGE mapping revival patch v2.

ZERO PAGE was removed in 2.6.24 (=> http://lkml.org/lkml/2007/10/9/112)
and I had no objections.

In these days, at user support jobs, I noticed a few of customers
are making use of ZERO_PAGE intentionally...brutal mmap and scan, etc. 
(For example, scanning big sparse table and save the contents.)

They are using RHEL4-5(before 2.6.18) then they don't notice that ZERO_PAGE
is gone, yet.
yes, I can say  "ZERO PAGE is gone" to them in next generation distro.

Recently, a question comes to lkml (http://lkml.org/lkml/2009/6/4/383

Maybe there are some users of ZERO_PAGE other than my customers.
So, can't we use ZERO_PAGE again ?

IIUC, the problem of ZERO_PAGE was
  - reference count cache ping-pong
  - complicated handling.
  - the behavior page-fault-twice can make applications slow.

This patch is a trial to de-refcounted ZERO_PAGE.

This includes 4 patches.
[1/4] introduce pte_zero() at el.
[2/4] use ZERO_PAGE for READ fault in anonymous mapping.
[3/4] corner cases, get_user_pages()
[4/4] introduce get_user_pages_nozero().

I feel these patches needs to be clearer but includes almost all
messes we have to handle at using ZERO_PAGE again.

What I feel now is
 a. technically, we can do because we did.
 b. Considering maintenance, code's beauty etc.. ZERO_PAGE adds messes.
 c. Very big benefits for some (a few?) users but no benefits to usual programs.
 
 There are trade-off between b. and c.
 
Any comments are welcome.
-Kame







--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
