Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f173.google.com (mail-ig0-f173.google.com [209.85.213.173])
	by kanga.kvack.org (Postfix) with ESMTP id E9BD16B006C
	for <linux-mm@kvack.org>; Fri, 24 Oct 2014 13:08:55 -0400 (EDT)
Received: by mail-ig0-f173.google.com with SMTP id h18so742058igc.6
        for <linux-mm@kvack.org>; Fri, 24 Oct 2014 10:08:55 -0700 (PDT)
Received: from resqmta-po-09v.sys.comcast.net (resqmta-po-09v.sys.comcast.net. [2001:558:fe16:19:96:114:154:168])
        by mx.google.com with ESMTPS id pz4si7211602icb.95.2014.10.24.10.08.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 24 Oct 2014 10:08:54 -0700 (PDT)
Date: Fri, 24 Oct 2014 12:08:50 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC][PATCH 4/6] SRCU free VMAs
In-Reply-To: <20141024155101.GE21513@worktop.programming.kicks-ass.net>
Message-ID: <alpine.DEB.2.11.1410241206001.30305@gentwo.org>
References: <20141020215633.717315139@infradead.org> <20141020222841.419869904@infradead.org> <CA+55aFwd04q+O5ejbmDL-H7_GB6DEBMiiHkn+2R1u4uWxfDO9w@mail.gmail.com> <20141021080740.GJ23531@worktop.programming.kicks-ass.net> <alpine.DEB.2.11.1410241003430.29419@gentwo.org>
 <20141024155101.GE21513@worktop.programming.kicks-ass.net>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@redhat.com>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Al Viro <viro@zeniv.linux.org.uk>, Lai Jiangshan <laijs@cn.fujitsu.com>, Davidlohr Bueso <dave@stgolabs.net>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

On Fri, 24 Oct 2014, Peter Zijlstra wrote:

> The hold time isn't relevant, in fact breaking up the mmap_sem such that
> we require multiple acquisitions will just increase the cacheline
> bouncing.

Well this wont be happening anymore once you RCUify the stuff. If you go
to sleep then its best to release mmap_sem and then the bouncing wont
matter.

Dropping mmap_sem there will also expose you to races you will see later
too when you RCUify the code paths. That way those can be deal with
beforehand.

> Also I think it makes more sense to continue an entire fault operation,
> including blocking, if at all possible. Every retry will just waste more
> time.

Ok then dont retry. Just drop mmap_sem before going to sleep. When you
come back evaluate the situation and if we can proceed do so otherwise
retry.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
