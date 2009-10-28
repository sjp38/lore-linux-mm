Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 795206B0073
	for <linux-mm@kvack.org>; Tue, 27 Oct 2009 20:08:52 -0400 (EDT)
Received: by bwz7 with SMTP id 7so375030bwz.6
        for <linux-mm@kvack.org>; Tue, 27 Oct 2009 17:08:50 -0700 (PDT)
Message-ID: <4AE78B8F.9050201@gmail.com>
Date: Wed, 28 Oct 2009 01:08:47 +0100
From: =?UTF-8?B?VmVkcmFuIEZ1cmHEjQ==?= <vedran.furac@gmail.com>
Reply-To: vedran.furac@gmail.com
MIME-Version: 1.0
Subject: Re: Memory overcommit
References: <hav57c$rso$1@ger.gmane.org> <20091013120840.a844052d.kamezawa.hiroyu@jp.fujitsu.com> <hb2cfu$r08$2@ger.gmane.org> <20091014135119.e1baa07f.kamezawa.hiroyu@jp.fujitsu.com> <4ADE3121.6090407@gmail.com> <20091026105509.f08eb6a3.kamezawa.hiroyu@jp.fujitsu.com> <4AE5CB4E.4090504@gmail.com> <20091027122213.f3d582b2.kamezawa.hiroyu@jp.fujitsu.com> <Pine.LNX.4.64.0910271843510.11372@sister.anvils> <alpine.DEB.2.00.0910271351140.9183@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.0910271351140.9183@chino.kir.corp.google.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, minchan.kim@gmail.com, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

David Rientjes wrote:

> There's advantages to either approach, but it depends on the contextual 
> goal of the oom killer when it's called: kill a rogue task that is 
> allocating more memory than expected,

But it is wrong at counting allocated memory!
Come on, it kills /usr/lib/icedove/run-mozilla.sh. Parent, a shell
script, instead of its child(s) which allocated memory. Look, "test"
allocates some (0.1GB) memory, and you have:

% cat test.sh

#!/bin/sh
./test&
./test&
./test&
./test

% perl check_badness.pl|sort -n|g test

26511   7884    test
26511   7885    test
26511   7886    test
26511   7887    test
53994   7883    test.sh

// great, so test.sh "is" the bad ass, ok, emulate OOMK:

% kill -9 7883

// did we kill "a rogue task"

% perl check_badness.pl|sort -n|g test

26511   7884    test
26511   7885    test
26511   7886    test
26511   7887    test

// nooo, they are still alive and eating our memory!

QED by newbie. ;)

> or kill a task that will free the most memory.

.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
