Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 17B536B0044
	for <linux-mm@kvack.org>; Thu,  8 Jan 2009 15:01:04 -0500 (EST)
Date: Thu, 08 Jan 2009 12:01:01 -0800 (PST)
Message-Id: <20090108.120101.182003946.davem@davemloft.net>
Subject: Re: Increase dirty_ratio and dirty_background_ratio?
From: David Miller <davem@davemloft.net>
In-Reply-To: <20090108195728.GC14560@duck.suse.cz>
References: <1231433701.14304.24.camel@think.oraclecorp.com>
	<alpine.LFD.2.00.0901080858500.3283@localhost.localdomain>
	<20090108195728.GC14560@duck.suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: jack@suse.cz
Cc: torvalds@linux-foundation.org, chris.mason@oracle.com, akpm@linux-foundation.org, peterz@infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

From: Jan Kara <jack@suse.cz>
Date: Thu, 8 Jan 2009 20:57:28 +0100

>   But I think there are workloads for which this is suboptimal to say the
> least. Imagine you do some crazy LDAP database crunching or other similar load
> which randomly writes to a big file (big means it's size is rougly
> comparable to your available memory). Kernel finds pdflush isn't able to
> flush the data fast enough so we decrease dirty limits. This results in
> even more agressive flushing but that makes things even worse (in a sence
> that your application runs slower and the disk is busy all the time anyway).
> This is the kind of load where we observe problems currently.

I'm pretty sure this is what I see as well.

If you just barely fit your working GIT state into memory, and you are
not using "noatime" on that partition, doing a bunch of git operations
is just going to trigger all of this forced and blocking writeback on
the atime dirtying of the inodes, and this will subsequently grind
your machine to a halt if your disk is slow.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
