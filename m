Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 463786B011B
	for <linux-mm@kvack.org>; Wed, 22 Jul 2009 13:49:45 -0400 (EDT)
From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [PATCH] hibernate / memory hotplug: always use for_each_populated_zone()
Date: Wed, 22 Jul 2009 19:49:55 +0200
References: <1248103551.23961.0.camel@localhost.localdomain> <200907211611.09525.rjw@sisk.pl> <20090722092535.5eac1ff6.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090722092535.5eac1ff6.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200907221949.56211.rjw@sisk.pl>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>, Nigel Cunningham <ncunningham@crca.org.au>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Yasunori Goto <y-goto@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wednesday 22 July 2009, KAMEZAWA Hiroyuki wrote:
> On Tue, 21 Jul 2009 16:11:08 +0200
> "Rafael J. Wysocki" <rjw@sisk.pl> wrote:
[...]
> Adding function like this is not very hard.
> 
> bool can_access_physmem(unsigned long pfn)
> {
> 	 char byte;
> 	 char *pg = __va(pfn << PAGE_SHIFT);
> 	 return (__get_user(byte, pg) == 0)
> }

Unfortunately we can't use __get_user() for hibernation, because it may sleep.
Some other mechanism would be necessary, it seems.

> and enough simple. But this may allow you to access remapped device's memory...
> Then, some range check will be required anyway.
> Can we detect io-remapped range from memmap or any ?
> (I think we'll have to skip PG_reserved page...)
> 
> > > Alternative is making use of walk_memory_resource() as memory hotplug does.
> > > It checks resource information registered.
> > 
> > I'd be fine with any _simple_ mechanism allowing us to check whether there's
> > a physical page frame for given page (or given PFN).
> > 
> 
> walk_memory_resource() is enough _simple_,  IMHO.
> Now, I'm removing #ifdef CONFIG_MEMORY_HOTPLUG for walk_memory_resource() to
> rewrite /proc/kcore. 

Hmm.  Which architectures set CONFIG_ARCH_HAS_WALK_MEMORY ?

Best,
Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
