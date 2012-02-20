Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 1E3D76B004D
	for <linux-mm@kvack.org>; Sun, 19 Feb 2012 22:05:13 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 5E4AE3EE0BD
	for <linux-mm@kvack.org>; Mon, 20 Feb 2012 12:05:11 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 26E0545DEB6
	for <linux-mm@kvack.org>; Mon, 20 Feb 2012 12:05:11 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0DD4B45DEB2
	for <linux-mm@kvack.org>; Mon, 20 Feb 2012 12:05:11 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id ECD1DE08005
	for <linux-mm@kvack.org>; Mon, 20 Feb 2012 12:05:10 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9DC861DB803B
	for <linux-mm@kvack.org>; Mon, 20 Feb 2012 12:05:10 +0900 (JST)
Date: Mon, 20 Feb 2012 12:03:46 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/2 v2] rmap: Make page_referenced_file and
 page_referenced_anon inline
Message-Id: <20120220120346.9cc5b7b6.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1329492398-7631-1-git-send-email-consul.kautuk@gmail.com>
References: <1329492398-7631-1-git-send-email-consul.kautuk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kautuk Consul <consul.kautuk@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 17 Feb 2012 10:26:38 -0500
Kautuk Consul <consul.kautuk@gmail.com> wrote:

> Inline the page_referenced_anon and page_referenced_file
> functions.
> These functions are called only from page_referenced.
> 
> Signed-off-by: Kautuk Consul <consul.kautuk@gmail.com>

Hmm ? In my environ,
 
before patch.

[kamezawa@bluextal linux]$ size mm/rmap.o
   text    data     bss     dec     hex filename
  11474       0      24   11498    2cea mm/rmap.o
   (8833) (optimize-for-size=y)
After patch.

[kamezawa@bluextal linux]$ size mm/rmap.o
   text    data     bss     dec     hex filename
  11422       0      24   11446    2cb6 mm/rmap.o
   (8775) (optimize-for-size=y)

text size is 50bytes decreased. But I wonder page_referenced_anon/file
is enough large function which is not inlined by hand in usual...

>From Documentation/CodingStyle Chapter15:  The inline disease
==
A reasonable rule of thumb is to not put inline at functions that have more
than 3 lines of code in them. An exception to this rule are the cases where
a parameter is known to be a compiletime constant, and as a result of this
constantness you *know* the compiler will be able to optimize most of your
function away at compile time. For a good example of this later case, see
the kmalloc() inline function.

Often people argue that adding inline to functions that are static and used
only once is always a win since there is no space tradeoff. While this is
technically correct, gcc is capable of inlining these automatically without
help, and the maintenance issue of removing the inline when a second user
appears outweighs the potential value of the hint that tells gcc to do
something it would have done anyway.
==

I'm sorry but I don't Ack this.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
