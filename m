Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f174.google.com (mail-ve0-f174.google.com [209.85.128.174])
	by kanga.kvack.org (Postfix) with ESMTP id E18406B0031
	for <linux-mm@kvack.org>; Thu, 13 Feb 2014 19:37:54 -0500 (EST)
Received: by mail-ve0-f174.google.com with SMTP id pa12so9049972veb.19
        for <linux-mm@kvack.org>; Thu, 13 Feb 2014 16:37:54 -0800 (PST)
Received: from mail-ve0-x236.google.com (mail-ve0-x236.google.com [2607:f8b0:400c:c01::236])
        by mx.google.com with ESMTPS id p9si1299696vdv.70.2014.02.13.16.37.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 13 Feb 2014 16:37:54 -0800 (PST)
Received: by mail-ve0-f182.google.com with SMTP id jy13so9296763veb.13
        for <linux-mm@kvack.org>; Thu, 13 Feb 2014 16:37:53 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20140214001438.GB1651@linux.vnet.ibm.com>
References: <52F4B8A4.70405@linux.vnet.ibm.com>
	<alpine.DEB.2.02.1402071239301.4212@chino.kir.corp.google.com>
	<52F88C16.70204@linux.vnet.ibm.com>
	<alpine.DEB.2.02.1402100200420.30650@chino.kir.corp.google.com>
	<52F8C556.6090006@linux.vnet.ibm.com>
	<alpine.DEB.2.02.1402101333160.15624@chino.kir.corp.google.com>
	<52FC6F2A.30905@linux.vnet.ibm.com>
	<alpine.DEB.2.02.1402130003320.11689@chino.kir.corp.google.com>
	<52FC98A6.1000701@linux.vnet.ibm.com>
	<alpine.DEB.2.02.1402131416430.13899@chino.kir.corp.google.com>
	<20140214001438.GB1651@linux.vnet.ibm.com>
Date: Thu, 13 Feb 2014 16:37:53 -0800
Message-ID: <CA+55aFwH8BqyLSqyLL7g-08nOtnOrJ9vKj4ebiSqrxc5ooEjLw@mail.gmail.com>
Subject: Re: [RFC PATCH V5] mm readahead: Fix readahead fail for no local
 memory and limit readahead pages
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Cc: David Rientjes <rientjes@google.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, David Cohen <david.a.cohen@linux.intel.com>, Al Viro <viro@zeniv.linux.org.uk>, Damien Ramonda <damien.ramonda@intel.com>, Jan Kara <jack@suse.cz>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

Is this whole thread still just for the crazy and pointless
"max_sane_readahead()"?

Or is there some *real* reason we should care?

Because if it really is just for max_sane_readahead(), then for the
love of God, let us just do this

 unsigned long max_sane_readahead(unsigned long nr)
 {
        return min(nr, 128);
 }

and bury this whole idiotic thread.

Seriously, if your IO subsystem needs more than 512kB of read-ahead to
get full performance, your IO subsystem is just bad, and has latencies
that are long enough that you should just replace it. There's no real
reason to bend over backwards for that, and the whole complexity and
fragility of the insane "let's try to figure out how much memory this
node has" is just not worth it. The read-ahead should be small enough
that we should never need to care, and large enough that you get
reasonable IO throughput. The above does that.

Goddammit, there's a reason the whole "Gordian knot" parable is
famous. We're making this all too damn complicated FOR NO GOOD REASON.

Just cut the rope, people. Our aim is not to generate some kind of job
security by making things as complicated as possible.

                 Linus

On Thu, Feb 13, 2014 at 4:14 PM, Nishanth Aravamudan
<nacc@linux.vnet.ibm.com> wrote:
>
> I'm working on this latter bit now. I tried to mirror ia64, but it looks
> like they have CONFIG_USER_PERCPU_NUMA_NODE_ID, which powerpc doesn't.
> It seems like CONFIG_USER_PERCPU_NUMA_NODE_ID and
> CONFIG_HAVE_MEMORYLESS_NODES should be tied together in Kconfig?
>
> I'll keep working, but would appreciate any further insight.
>
> -Nish
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
