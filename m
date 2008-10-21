Received: from zps35.corp.google.com (zps35.corp.google.com [172.25.146.35])
	by smtp-out.google.com with ESMTP id m9L2Fdo2022972
	for <linux-mm@kvack.org>; Mon, 20 Oct 2008 19:15:39 -0700
Received: from qw-out-2122.google.com (qwb9.prod.google.com [10.241.193.73])
	by zps35.corp.google.com with ESMTP id m9L2Fbd2013230
	for <linux-mm@kvack.org>; Mon, 20 Oct 2008 19:15:38 -0700
Received: by qw-out-2122.google.com with SMTP id 9so709519qwb.17
        for <linux-mm@kvack.org>; Mon, 20 Oct 2008 19:15:37 -0700 (PDT)
Message-ID: <6599ad830810201915g8af14fbg3de7a23a1409ef68@mail.gmail.com>
Date: Mon, 20 Oct 2008 19:15:37 -0700
From: "Paul Menage" <menage@google.com>
Subject: Re: [PATCH -mm 1/5] memcg: replace res_counter
In-Reply-To: <20081021104932.5115a077.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20081017194804.fce28258.nishimura@mxp.nes.nec.co.jp>
	 <20081017195601.0b9abda1.nishimura@mxp.nes.nec.co.jp>
	 <6599ad830810201253u3bca41d4rabe48eb1ec1d529f@mail.gmail.com>
	 <20081021101430.d2629a81.kamezawa.hiroyu@jp.fujitsu.com>
	 <6599ad830810201829o5483ef48g633e920cce9cc015@mail.gmail.com>
	 <20081021104932.5115a077.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm@kvack.org, balbir@linux.vnet.ibm.com
List-ID: <linux-mm.kvack.org>

On Mon, Oct 20, 2008 at 6:49 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
>
> res_counter's operation is very short.
>  take a lock => add and compare. => unlock.
>
> So, I wonder there is not enough runway to do prefetch.

Sorry, let me be clearer. I'm assuming that since a write operation on
the base counter will generally be accompanied by a write operation on
the aggregate counter, that one of the following is true:

- neither cache line is in a M or E state in our cache. So the
prefetchw on the aggregate counter proceeds in parallel to the stall
on fetching the base counter, and there's no additional delay to
access the aggregate counter.

- both cache lines are in a M or E state in our cache, so there are no
misses on either counter.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
