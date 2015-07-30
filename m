Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f49.google.com (mail-la0-f49.google.com [209.85.215.49])
	by kanga.kvack.org (Postfix) with ESMTP id 5B3D99003C7
	for <linux-mm@kvack.org>; Thu, 30 Jul 2015 11:23:00 -0400 (EDT)
Received: by lagw2 with SMTP id w2so27279196lag.3
        for <linux-mm@kvack.org>; Thu, 30 Jul 2015 08:22:59 -0700 (PDT)
Received: from mail-wi0-x233.google.com (mail-wi0-x233.google.com. [2a00:1450:400c:c05::233])
        by mx.google.com with ESMTPS id o5si3948783wiz.39.2015.07.30.08.22.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Jul 2015 08:22:58 -0700 (PDT)
Received: by wibxm9 with SMTP id xm9so249597709wib.0
        for <linux-mm@kvack.org>; Thu, 30 Jul 2015 08:22:58 -0700 (PDT)
Message-ID: <1438269775.23663.58.camel@gmail.com>
Subject: Re: [PATCH] mm: add resched points to
 remap_pmd_range/ioremap_pmd_range
From: Mike Galbraith <umgwanakikbuti@gmail.com>
Date: Thu, 30 Jul 2015 17:22:55 +0200
In-Reply-To: <20150729095439.GD15801@dhcp22.suse.cz>
References: <1437688476-3399-3-git-send-email-sbaugh@catern.com>
	 <20150724070420.GF4103@dhcp22.suse.cz>
	 <20150724165627.GA3458@Sligo.logfs.org>
	 <20150727070840.GB11317@dhcp22.suse.cz>
	 <20150727151814.GR9641@Sligo.logfs.org>
	 <20150728133254.GI24972@dhcp22.suse.cz>
	 <20150728170844.GY9641@Sligo.logfs.org>
	 <20150729095439.GD15801@dhcp22.suse.cz>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: =?ISO-8859-1?Q?J=F6rn?= Engel <joern@purestorage.com>, Spencer Baugh <sbaugh@catern.com>, Toshi Kani <toshi.kani@hp.com>, Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, Joern Engel <joern@logfs.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Shachar Raindel <raindel@mellanox.com>, Boaz Harrosh <boaz@plexistor.com>, Andy Lutomirski <luto@amacapital.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrey Ryabinin <a.ryabinin@samsung.com>, Roman Pen <r.peniaev@gmail.com>, Andrey Konovalov <adech.fo@gmail.com>, Eric Dumazet <edumazet@google.com>, Dmitry Vyukov <dvyukov@google.com>, Rob Jones <rob.jones@codethink.co.uk>, WANG Chao <chaowang@redhat.com>, open list <linux-kernel@vger.kernel.org>, "open
 list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, Spencer Baugh <Spencer.baugh@purestorage.com>

On Wed, 2015-07-29 at 11:54 +0200, Michal Hocko wrote:
> On Tue 28-07-15 10:08:44, JA?rn Engel wrote:
> > On Tue, Jul 28, 2015 at 03:32:55PM +0200, Michal Hocko wrote:
> > > > 
> > > > We have kernel preemption disabled.  A lower-priority task in a system
> > > > call will block higher-priority tasks.
> > > 
> > > This is an inherent problem of !PREEMPT, though. There are many
> > > loops which can take quite some time but we do not want to sprinkle
> > > cond_resched all over the kernel. On the other hand these io/remap resp.
> > > vunmap page table walks do not have any cond_resched points AFAICS so we
> > > can at least mimic zap_pmd_range which does cond_resched.
> > 
> > Even for !PREEMPT we don't want infinite scheduler latencies.  Real
> > question is how much we are willing to accept and at what point we
> > should start sprinkling cond_resched.  I would pick 100ms, but that is
> > just a personal choice.  If we decide on 200ms or 500ms, I can live with
> > that too.
> 
> I do not thing this is about a magic value. It is more about natural
> places for scheduling point. As I've written above cond_resched at pmd
> level of the page table walk sounds reasonable to me as we do that
> already for zap_pmd_range and consistency would make sense to me.

I piddled about with the thought that it might be nice to be able to
sprinkle cond_resched() about to cut rt latencies without wrecking
normal load throughput, cobbled together a cond_resched_rt().

On my little box that was a waste of time, as the biggest hits are block
softirq and free_hot_cold_page_list().

	-Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
