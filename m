Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id D646B9003C7
	for <linux-mm@kvack.org>; Thu, 30 Jul 2015 12:58:08 -0400 (EDT)
Received: by padck2 with SMTP id ck2so26316842pad.0
        for <linux-mm@kvack.org>; Thu, 30 Jul 2015 09:58:08 -0700 (PDT)
Received: from mail-pa0-x229.google.com (mail-pa0-x229.google.com. [2607:f8b0:400e:c03::229])
        by mx.google.com with ESMTPS id wd7si3512224pab.205.2015.07.30.09.58.07
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Jul 2015 09:58:08 -0700 (PDT)
Received: by pacan13 with SMTP id an13so26724054pac.1
        for <linux-mm@kvack.org>; Thu, 30 Jul 2015 09:58:07 -0700 (PDT)
Date: Thu, 30 Jul 2015 09:58:03 -0700
From: =?iso-8859-1?Q?J=F6rn?= Engel <joern@purestorage.com>
Subject: Re: [PATCH] mm: add resched points to
 remap_pmd_range/ioremap_pmd_range
Message-ID: <20150730165803.GA17882@Sligo.logfs.org>
References: <1437688476-3399-3-git-send-email-sbaugh@catern.com>
 <20150724070420.GF4103@dhcp22.suse.cz>
 <20150724165627.GA3458@Sligo.logfs.org>
 <20150727070840.GB11317@dhcp22.suse.cz>
 <20150727151814.GR9641@Sligo.logfs.org>
 <20150728133254.GI24972@dhcp22.suse.cz>
 <20150728170844.GY9641@Sligo.logfs.org>
 <20150729095439.GD15801@dhcp22.suse.cz>
 <1438269775.23663.58.camel@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1438269775.23663.58.camel@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Galbraith <umgwanakikbuti@gmail.com>
Cc: Michal Hocko <mhocko@kernel.org>, Spencer Baugh <sbaugh@catern.com>, Toshi Kani <toshi.kani@hp.com>, Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, Joern Engel <joern@logfs.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Shachar Raindel <raindel@mellanox.com>, Boaz Harrosh <boaz@plexistor.com>, Andy Lutomirski <luto@amacapital.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrey Ryabinin <a.ryabinin@samsung.com>, Roman Pen <r.peniaev@gmail.com>, Andrey Konovalov <adech.fo@gmail.com>, Eric Dumazet <edumazet@google.com>, Dmitry Vyukov <dvyukov@google.com>, Rob Jones <rob.jones@codethink.co.uk>, WANG Chao <chaowang@redhat.com>, open list <linux-kernel@vger.kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, Spencer Baugh <Spencer.baugh@purestorage.com>

On Thu, Jul 30, 2015 at 05:22:55PM +0200, Mike Galbraith wrote:
> 
> I piddled about with the thought that it might be nice to be able to
> sprinkle cond_resched() about to cut rt latencies without wrecking
> normal load throughput, cobbled together a cond_resched_rt().
> 
> On my little box that was a waste of time, as the biggest hits are block
> softirq and free_hot_cold_page_list().

Block softirq is one of our problems as well.  It is a bit of a joke
that __do_softirq() moves work to ksoftirqd after 2ms, but block softirq
can take several 100ms in bad cases.

We could give individual softirqs a time budget.  If they exceed the
budget they should complete, but reassert themselves.  Not sure about
the rest, but that would be pretty simple to implement for block
softirq.

Jorn

--
Happiness isn't having what you want, it's wanting what you have.
-- unknown

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
