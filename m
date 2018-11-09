Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id D1ADC6B06CA
	for <linux-mm@kvack.org>; Fri,  9 Nov 2018 04:56:12 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id z72-v6so901268ede.14
        for <linux-mm@kvack.org>; Fri, 09 Nov 2018 01:56:12 -0800 (PST)
Received: from outbound-smtp27.blacknight.com (outbound-smtp27.blacknight.com. [81.17.249.195])
        by mx.google.com with ESMTPS id t9-v6si2771969edd.398.2018.11.09.01.56.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 09 Nov 2018 01:56:11 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp27.blacknight.com (Postfix) with ESMTPS id 58587B8B71
	for <linux-mm@kvack.org>; Fri,  9 Nov 2018 09:56:11 +0000 (GMT)
Date: Fri, 9 Nov 2018 09:56:09 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: UBSAN: Undefined behaviour in mm/page_alloc.c
Message-ID: <20181109095609.GC23260@techsingularity.net>
References: <CAEAjamseRRHu+TaTkd1TwpLNm8mtDGP=2K0WKLF0wH-3iLcW_w@mail.gmail.com>
 <20181109084353.GA5321@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20181109084353.GA5321@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Kyungtae Kim <kt0755@gmail.com>, akpm@linux-foundation.org, pavel.tatashin@microsoft.com, vbabka@suse.cz, osalvador@suse.de, rppt@linux.vnet.ibm.com, aaron.lu@intel.com, iamjoonsoo.kim@lge.com, alexander.h.duyck@linux.intel.com, lifeasageek@gmail.com, threeearcat@gmail.com, syzkaller@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>

On Fri, Nov 09, 2018 at 09:43:53AM +0100, Michal Hocko wrote:
> On Thu 08-11-18 23:09:23, Kyungtae Kim wrote:
> > We report a bug in v4.19-rc2 (4.20-rc1 as well, I guess):
> > 
> > kernel config: https://kt0755.github.io/etc/config_v2-4.19
> > repro: https://kt0755.github.io/etc/repro.c4074.c
> > 
> > In the middle of page request, this arose because order is too large to handle
> >  (mm/page_alloc.c:3119). It actually comes from that order is
> > controllable by user input
> > via raw_cmd_ioctl without its sanity check, thereby causing memory problem.
> > To stop it, we can use like MAX_ORDER for bounds check before using it.
> 
> Yes, we do only check the max order in the slow path. We have already
> discussed something similar with Konstantin [1][2]. Basically kvmalloc
> for a large size might get to the page allocator with an out of bound
> order and warn during direct reclaim.
> 
> I am wondering whether really want to check for the order in the fast
> path instead. I have hard time to imagine this could cause a measurable
> impact.
> 
> The full patch is below
> 
> [1] http://lkml.kernel.org/r/154109387197.925352.10499549042420271600.stgit@buzz
> [2] http://lkml.kernel.org/r/154106356066.887821.4649178319705436373.stgit@buzz
> 

I'm ok with such changes under the policy "there is no point being fast if
we're broken". It's unfortunate and I know the original microoptimisation
was mine but if the fast-path check ends up being a problem then I/we go
back to finding ways of making the page allocator faster from a fundamental
algorithmic point of view and not a microoptimisation approach. There is
potential fruit there, just none that is low-hanging.

-- 
Mel Gorman
SUSE Labs
