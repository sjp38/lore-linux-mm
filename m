Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 6FDD36B0032
	for <linux-mm@kvack.org>; Mon, 15 Jul 2013 20:12:39 -0400 (EDT)
Message-ID: <1373933551.4622.12.camel@buesod1.americas.hpqcorp.net>
Subject: Re: [PATCH] mm/hugetlb: per-vma instantiation mutexes
From: Davidlohr Bueso <davidlohr.bueso@hp.com>
Date: Mon, 15 Jul 2013 17:12:31 -0700
In-Reply-To: <20130715160802.9d0cdc0ee012b5e119317a98@linux-foundation.org>
References: <1373671681.2448.10.camel@buesod1.americas.hpqcorp.net>
	 <alpine.LNX.2.00.1307121729590.3899@eggly.anvils>
	 <1373858204.13826.9.camel@buesod1.americas.hpqcorp.net>
	 <20130715072432.GA28053@voom.fritz.box>
	 <20130715160802.9d0cdc0ee012b5e119317a98@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Gibson <david@gibson.dropbear.id.au>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Mel Gorman <mgorman@suse.de>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Michal Hocko <mhocko@suse.cz>, "AneeshKumarK.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hillf Danton <dhillf@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Anton Blanchard <anton@samba.org>

On Mon, 2013-07-15 at 16:08 -0700, Andrew Morton wrote:
> On Mon, 15 Jul 2013 17:24:32 +1000 David Gibson <david@gibson.dropbear.id.au> wrote:
> 
> > I have previously proposed a correct method of improving scalability,
> > although it doesn't eliminate the lock.  That's to use a set of hashed
> > mutexes.
> 
> Yep - hashing the mutexes is an obvious and nicely localized way of
> improving this.  It's a tweak, not a design change.
> 
> The changelog should describe the choice of the hash key with great
> precision, please.  It's important and is the first thing which
> reviewers and readers will zoom in on.
> 
> Should the individual mutexes be cacheline aligned?  Depends on the
> acquisition frequency, I guess.  Please let's work through that.

In my test cases, involving different RDBMS, I'm getting around 114k
acquisitions.

> 
> Let's not damage uniprocesor kernels too much.  AFACIT the main offender
> here is fault_mutex_hash(), which is the world's most obfuscated "return
> 0;".

I guess we could add an ifndef CONFIG_SMP check to the function and
return 0 right away. That would eliminate any overhead in
fault_mutex_hash().

> 
> >  It wasn't merged before, but I don't recall the reasons
> > why. 

So I've forward ported the patch (will send once everyone agrees that
the matter is settled), including the changes Anton Blanchard added a
exactly two years ago:

https://lkml.org/lkml/2011/7/15/31

My tests show that the number of lock contentions drops from ~11k to
around 500. So this approach alleviates a lot of the bottleneck. I've
also ran it against libhugetlbfs without any regressions.

Thanks,
Davidlohr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
