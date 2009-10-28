Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 065C86B0083
	for <linux-mm@kvack.org>; Tue, 27 Oct 2009 20:25:57 -0400 (EDT)
Received: from spaceape10.eur.corp.google.com (spaceape10.eur.corp.google.com [172.28.16.144])
	by smtp-out.google.com with ESMTP id n9S0PrA7015032
	for <linux-mm@kvack.org>; Wed, 28 Oct 2009 00:25:53 GMT
Received: from pwi12 (pwi12.prod.google.com [10.241.219.12])
	by spaceape10.eur.corp.google.com with ESMTP id n9S0Pofs014777
	for <linux-mm@kvack.org>; Tue, 27 Oct 2009 17:25:51 -0700
Received: by pwi12 with SMTP id 12so524413pwi.25
        for <linux-mm@kvack.org>; Tue, 27 Oct 2009 17:25:50 -0700 (PDT)
Date: Tue, 27 Oct 2009 17:25:47 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: Memory overcommit
In-Reply-To: <4AE78B8F.9050201@gmail.com>
Message-ID: <alpine.DEB.2.00.0910271723180.17615@chino.kir.corp.google.com>
References: <hav57c$rso$1@ger.gmane.org> <20091013120840.a844052d.kamezawa.hiroyu@jp.fujitsu.com> <hb2cfu$r08$2@ger.gmane.org> <20091014135119.e1baa07f.kamezawa.hiroyu@jp.fujitsu.com> <4ADE3121.6090407@gmail.com> <20091026105509.f08eb6a3.kamezawa.hiroyu@jp.fujitsu.com>
 <4AE5CB4E.4090504@gmail.com> <20091027122213.f3d582b2.kamezawa.hiroyu@jp.fujitsu.com> <Pine.LNX.4.64.0910271843510.11372@sister.anvils> <alpine.DEB.2.00.0910271351140.9183@chino.kir.corp.google.com> <4AE78B8F.9050201@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII
Content-ID: <alpine.DEB.2.00.0910271723231.17615@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: vedran.furac@gmail.com
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, minchan.kim@gmail.com, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On Wed, 28 Oct 2009, Vedran Fura wrote:

> But it is wrong at counting allocated memory!
> Come on, it kills /usr/lib/icedove/run-mozilla.sh. Parent, a shell
> script, instead of its child(s) which allocated memory. Look, "test"
> allocates some (0.1GB) memory, and you have:
> 
> % cat test.sh
> 
> #!/bin/sh
> ./test&
> ./test&
> ./test&
> ./test
> 
> % perl check_badness.pl|sort -n|g test
> 
> 26511   7884    test
> 26511   7885    test
> 26511   7886    test
> 26511   7887    test
> 53994   7883    test.sh
> 
> // great, so test.sh "is" the bad ass, ok, emulate OOMK:
> 
> % kill -9 7883
> 
> // did we kill "a rogue task"
> 
> % perl check_badness.pl|sort -n|g test
> 
> 26511   7884    test
> 26511   7885    test
> 26511   7886    test
> 26511   7887    test
> 
> // nooo, they are still alive and eating our memory!
> 

This is wrong; it doesn't "emulate oom" since oom_kill_process() always 
kills a child of the selected process instead if they do not share the 
same memory.  The chosen task in that case is untouched.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
