Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 1641F6B0083
	for <linux-mm@kvack.org>; Fri, 15 Jul 2011 15:50:29 -0400 (EDT)
Received: from wpaz13.hot.corp.google.com (wpaz13.hot.corp.google.com [172.24.198.77])
	by smtp-out.google.com with ESMTP id p6FJoLqB019683
	for <linux-mm@kvack.org>; Fri, 15 Jul 2011 12:50:21 -0700
Received: from iyb39 (iyb39.prod.google.com [10.241.49.103])
	by wpaz13.hot.corp.google.com with ESMTP id p6FJnZV5003723
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 15 Jul 2011 12:50:20 -0700
Received: by iyb39 with SMTP id 39so299994iyb.32
        for <linux-mm@kvack.org>; Fri, 15 Jul 2011 12:50:16 -0700 (PDT)
Date: Fri, 15 Jul 2011 12:50:00 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: Hugepages for shm page cache (defrag)
In-Reply-To: <60ac3a8f762dcc7a6e8767753ad55736@rsmogura.net>
Message-ID: <alpine.LSU.2.00.1107151238390.7803@sister.anvils>
References: <201107062131.01717.mail@smogura.eu> <m2pqlmy7z8.fsf@firstfloor.org> <5be3df4081574f3d4e1e699f028549a7@rsmogura.net> <alpine.LSU.2.00.1107071643370.10165@sister.anvils> <60ac3a8f762dcc7a6e8767753ad55736@rsmogura.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mail@rsmogura.net
Cc: Andrea Arcangeli <aarcange@redhat.com>, Radislaw Smogura <mail@rsmogura.eu>, Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org

On Thu, 14 Jul 2011, mail@rsmogura.net wrote:
> I working to remove errors from patch, and I integrated it with current THP
> infrastructure a little bit,

Great, thank you.

> but I want ask if following I do following -
> it's about get_page, put_page, get_page_unless_zero, put_page_test_zero.
> 
> I want following logic I think it may be better (in x86):
> 1) Each THP page will start with 512 refcount (self + 511 tails)
> 2) Each get/put will increment usage count only on this page, same test
> variants will do (currently those do not make this, so split is broken)
> 3) On compounds put page will call put_page_test_zero, if true, it will do
> compound lock, ask again if it has 0, if yes it will decrease refcount of
> head, if it will fall to zero compound will be freed (double check lock).
> 4) Compound lock is this what caller will need to establish if it needs to
> operate on transparent huge page in whole.
> 
> Motivation:
> I operate on page cache, many assumptions about concurrent call of
> put/get_page are and plain using those causes memory leaks, faults, dangling
> pointers, etc when I'm going to split compound page.
> 
> Is this acceptable?

Sounds plausible, but I really don't know.

I do remember that refcounting compounds by head or by tail always raises
questions (and access via get_user_pages() is an easily-overlooked path
that needs to be kept in mind).  But where THP stands today, and how it
needs to be changed for this, I have no idea - whereas Andrea, perhaps,
will recognize some of your points above and have a more useful response.

It's clear that you have much more of a grip on these details than I
have at present, so just be guided by the principle of not slowing
down the common paths.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
