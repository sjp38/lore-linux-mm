Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f180.google.com (mail-lb0-f180.google.com [209.85.217.180])
	by kanga.kvack.org (Postfix) with ESMTP id 03DA36B0075
	for <linux-mm@kvack.org>; Tue,  4 Nov 2014 09:50:08 -0500 (EST)
Received: by mail-lb0-f180.google.com with SMTP id u10so2777452lbd.25
        for <linux-mm@kvack.org>; Tue, 04 Nov 2014 06:50:07 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w8si1214970lbb.16.2014.11.04.06.50.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 04 Nov 2014 06:50:06 -0800 (PST)
Date: Tue, 4 Nov 2014 15:50:02 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 1/3] mm: embed the memcg pointer directly into struct page
Message-ID: <20141104145002.GE22207@dhcp22.suse.cz>
References: <20141103210607.GA24091@node.dhcp.inet.fi>
 <20141103213628.GA11428@phnom.home.cmpxchg.org>
 <20141103215206.GB24091@node.dhcp.inet.fi>
 <20141103.165807.2039166055692354811.davem@davemloft.net>
 <20141103223626.GA12006@phnom.home.cmpxchg.org>
 <20141104130652.GC22207@dhcp22.suse.cz>
 <20141104134841.GB18441@phnom.home.cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141104134841.GB18441@phnom.home.cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: David Miller <davem@davemloft.net>, kirill@shutemov.name, akpm@linux-foundation.org, vdavydov@parallels.com, tj@kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue 04-11-14 08:48:41, Johannes Weiner wrote:
> On Tue, Nov 04, 2014 at 02:06:52PM +0100, Michal Hocko wrote:
> > The code size grows (~1.5k) most probably due to struct page pointer
> > arithmetic (but I haven't checked that) but the data section shrinks
> > for SLAB. So we have additional 1.6k for SLUB. I guess this is
> > acceptable.
> > 
> >    text    data     bss     dec     hex filename
> > 8427489  887684 3186688 12501861         bec365 mmotm/vmlinux.slab
> > 8429060  883588 3186688 12499336         beb988 page_cgroup/vmlinux.slab
> > 
> > 8438894  883428 3186688 12509010         bedf52 mmotm/vmlinux.slub
> > 8440529  883428 3186688 12510645         bee5b5 page_cgroup/vmlinux.slub
> 
> That's unexpected.  It's not much, but how could the object size grow
> at all when that much code is removed and we replace the lookups with
> simple struct member accesses?  Are you positive these are the right
> object files, in the right order?

Double checked (the base is [1] and page_cgroup refers to these 3
patches). Please note that this is a distribution config (OpenSUSE
13.2) so it enables a lot of things. And I would really expect that 36B
resp. 40B pointer arithmetic will do more instructions than 32B and this
piles up when it is used all over the place.

memcontrol.o shrinks 0.2k
$ size {mmotm,page_cgroup}/mm/memcontrol.o
   text    data     bss     dec     hex filename
  25337    3095       2   28434    6f12 mmotm/mm/memcontrol.o
  25123    3095       2   28220    6e3c page_cgroup/mm/memcontrol.o

and page_cgroup.o saves 0.5k
$ size mmotm/mm/page_cgroup.o page_cgroup/mm/swap_cgroup.o 
   text    data     bss     dec     hex filename
   1419      24     352    1795     703 mmotm/mm/page_cgroup.o
    849      24     348    1221     4c5 page_cgroup/mm/swap_cgroup.o

But built-in.o files grow or keep the same size (this is with
CONFIG_SLAB and gcc 4.8.2)
$ size {mmotm,page_cgroup}/*/built-in.o | sort -k1 -n | awk '!/text/{new = (i++ % 2); if (!new) {val = $1; last_line=$0} else if ($1-val != 0) {diff = $1 - val; printf("%s\n%s diff %d\n", last_line, $0, diff); sum+=diff}}END{printf("Sum diff %d\n", sum)}'
  14481   19586      81   34148    8564 mmotm/init/built-in.o
  14483   19586      81   34150    8566 page_cgroup/init/built-in.o diff 2
  68679    2082      12   70773   11475 mmotm/crypto/built-in.o
  68711    2082      12   70805   11495 page_cgroup/crypto/built-in.o diff 32
 131583   26496    2376  160455   272c7 mmotm/lib/built-in.o
 131631   26496    2376  160503   272f7 page_cgroup/lib/built-in.o diff 48
 229809   12346    1548  243703   3b7f7 mmotm/block/built-in.o
 229937   12346    1548  243831   3b877 page_cgroup/block/built-in.o diff 128
 308015   20442   16280  344737   542a1 mmotm/security/built-in.o
 308031   20442   16280  344753   542b1 page_cgroup/security/built-in.o diff 16
 507979   47110   27236  582325   8e2b5 mmotm/mm/built-in.o
 508540   47110   27236  582886   8e4e6 page_cgroup/mm/built-in.o diff 561
1033752   77064   13212 1124028  1126bc mmotm/fs/built-in.o
1033784   77064   13212 1124060  1126dc page_cgroup/fs/built-in.o diff 32
1099218   51979   33512 1184709  1213c5 mmotm/net/built-in.o
1099282   51979   33512 1184773  121405 page_cgroup/net/built-in.o diff 64
1180475  127020  705068 2012563  1eb593 mmotm/kernel/built-in.o
1180683  127020  705068 2012771  1eb663 page_cgroup/kernel/built-in.o diff 208
2193400  152698   34856 2380954  24549a mmotm/drivers/built-in.o
2193528  152698   34856 2381082  24551a page_cgroup/drivers/built-in.o diff 128
Sum diff 1219

this is not a complete list but mm part eats only 0.5k the rest is small
but it adds up.

> > So to me it sounds like the savings for 64b are worth minor inconvenience
> > for 32b which is clearly on decline and I would definitely not encourage
> > people to use PAE kernels with a lot of memory where the difference
> > might matter. For the most x86 32b deployments (laptops with 4G) the
> > difference shouldn't be noticeable. I am not familiar with other archs
> > so the situation might be different there.
> 
> On 32 bit, the overhead is 0.098% of memory, so 4MB on a 4G machine.
> This should be acceptable, even for the three people that run on the
> cutting edge of 3.18-based PAE distribution kernels. :-)
> 
> > This should probably go into the changelog, I guess.
> 
> Which part?

About potential increased memory footprint on 32b systems (aka don't
sell it as a full win ;))

---
[1] https://git.kernel.org/cgit/linux/kernel/git/mhocko/mm.git/tag/?h=since-3.17&id=mmotm-2014-10-29-14-19
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
