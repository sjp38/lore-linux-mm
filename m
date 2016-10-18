Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id D07276B0038
	for <linux-mm@kvack.org>; Mon, 17 Oct 2016 20:10:39 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id u84so211886664pfj.6
        for <linux-mm@kvack.org>; Mon, 17 Oct 2016 17:10:39 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id y7si27304282par.279.2016.10.17.17.10.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Oct 2016 17:10:39 -0700 (PDT)
Date: Mon, 17 Oct 2016 17:10:38 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bug 177821] New: NULL pointer dereference in list_rcu
Message-Id: <20161017171038.924cbbcfc0a23652d2d2b8b4@linux-foundation.org>
In-Reply-To: <bug-177821-27@https.bugzilla.kernel.org/>
References: <bug-177821-27@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Polakov <apolyakov@beget.ru>
Cc: bugzilla-daemon@bugzilla.kernel.org, Al Viro <viro@zeniv.linux.org.uk>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>


(resend due to "vdavydov@virtuozzo.com Unrouteable address")

(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Mon, 17 Oct 2016 13:08:17 +0000 bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=177821
> 
>             Bug ID: 177821
>            Summary: NULL pointer dereference in list_rcu

Fair enough, I suppose.

Please don't submit patches via bugzilla - it is quite
painful.  Documentation/SubmittingPatches explains the
way to do it.

Here's what I put together.  Note that we do not have your
signed-off-by: for this.  Please send it?



From: Alexander Polakov <apolyakov@beget.ru>
Subject: mm/list_lru.c: avoid error-path NULL pointer deref

As described in https://bugzilla.kernel.org/show_bug.cgi?id=177821:

After some analysis it seems to be that the problem is in alloc_super(). 
In case list_lru_init_memcg() fails it goes into destroy_super(), which
calls list_lru_destroy().

And in list_lru_init() we see that in case memcg_init_list_lru() fails,
lru->node is freed, but not set NULL, which then leads list_lru_destroy()
to believe it is initialized and call memcg_destroy_list_lru(). 
memcg_destroy_list_lru() in turn can access lru->node[i].memcg_lrus, which
is NULL.

[akpm@linux-foundation.org: add comment]
Cc: Vladimir Davydov <vdavydov@parallels.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/list_lru.c |    2 ++
 1 file changed, 2 insertions(+)

diff -puN mm/list_lru.c~a mm/list_lru.c
--- a/mm/list_lru.c~a
+++ a/mm/list_lru.c
@@ -554,6 +554,8 @@ int __list_lru_init(struct list_lru *lru
 	err = memcg_init_list_lru(lru, memcg_aware);
 	if (err) {
 		kfree(lru->node);
+		/* Do this so a list_lru_destroy() doesn't crash: */
+		lru->node = NULL;
 		goto out;
 	}
 
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
