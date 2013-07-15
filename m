Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 578D46B0032
	for <linux-mm@kvack.org>; Mon, 15 Jul 2013 19:08:04 -0400 (EDT)
Date: Mon, 15 Jul 2013 16:08:02 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/hugetlb: per-vma instantiation mutexes
Message-Id: <20130715160802.9d0cdc0ee012b5e119317a98@linux-foundation.org>
In-Reply-To: <20130715072432.GA28053@voom.fritz.box>
References: <1373671681.2448.10.camel@buesod1.americas.hpqcorp.net>
	<alpine.LNX.2.00.1307121729590.3899@eggly.anvils>
	<1373858204.13826.9.camel@buesod1.americas.hpqcorp.net>
	<20130715072432.GA28053@voom.fritz.box>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Gibson <david@gibson.dropbear.id.au>
Cc: Davidlohr Bueso <davidlohr.bueso@hp.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Mel Gorman <mgorman@suse.de>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Michal Hocko <mhocko@suse.cz>, "AneeshKumarK.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hillf Danton <dhillf@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Mon, 15 Jul 2013 17:24:32 +1000 David Gibson <david@gibson.dropbear.id.au> wrote:

> I have previously proposed a correct method of improving scalability,
> although it doesn't eliminate the lock.  That's to use a set of hashed
> mutexes.

Yep - hashing the mutexes is an obvious and nicely localized way of
improving this.  It's a tweak, not a design change.

The changelog should describe the choice of the hash key with great
precision, please.  It's important and is the first thing which
reviewers and readers will zoom in on.

Should the individual mutexes be cacheline aligned?  Depends on the
acquisition frequency, I guess.  Please let's work through that.

Let's not damage uniprocesor kernels too much.  AFACIT the main offender
here is fault_mutex_hash(), which is the world's most obfuscated "return
0;".

>  It wasn't merged before, but I don't recall the reasons
> why. 

Me either.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
