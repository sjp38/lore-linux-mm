Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id D1F6B6B06DA
	for <linux-mm@kvack.org>; Fri,  9 Nov 2018 05:29:02 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id x1-v6so926572edh.8
        for <linux-mm@kvack.org>; Fri, 09 Nov 2018 02:29:02 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g5-v6si2552397ede.42.2018.11.09.02.29.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Nov 2018 02:29:01 -0800 (PST)
Date: Fri, 9 Nov 2018 11:28:55 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: UBSAN: Undefined behaviour in mm/page_alloc.c
Message-ID: <20181109102855.GF5321@dhcp22.suse.cz>
References: <CAEAjamseRRHu+TaTkd1TwpLNm8mtDGP=2K0WKLF0wH-3iLcW_w@mail.gmail.com>
 <20181109084353.GA5321@dhcp22.suse.cz>
 <b51aae15-eb5d-47f0-1222-bfc1ef21e06c@I-love.SAKURA.ne.jp>
 <20181109095604.GC5321@dhcp22.suse.cz>
 <d8757554-45f4-1240-dc8a-0f918ae0e5f3@suse.cz>
 <9e17d033-b2ab-3edb-ae0b-90d4f713e55b@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <9e17d033-b2ab-3edb-ae0b-90d4f713e55b@i-love.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Vlastimil Babka <vbabka@suse.cz>, Kyungtae Kim <kt0755@gmail.com>, akpm@linux-foundation.org, pavel.tatashin@microsoft.com, osalvador@suse.de, rppt@linux.vnet.ibm.com, aaron.lu@intel.com, iamjoonsoo.kim@lge.com, alexander.h.duyck@linux.intel.com, mgorman@techsingularity.net, lifeasageek@gmail.com, threeearcat@gmail.com, syzkaller@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>

On Fri 09-11-18 19:24:48, Tetsuo Handa wrote:
> On 2018/11/09 19:10, Vlastimil Babka wrote:>>>> +	 * reclaim >= MAX_ORDER areas which will never succeed. Callers may
> >>>> +	 * be using allocators in order of preference for an area that is
> >>>> +	 * too large.
> >>>> +	 */
> >>>> +	if (order >= MAX_ORDER) {
> >>>
> >>> Also, why not to add BUG_ON(gfp_mask & __GFP_NOFAIL); here?
> >>
> >> Because we do not want to blow up the kernel just because of a stupid
> >> usage of the allocator. Can you think of an example where it would
> >> actually make any sense?
> >>
> >> I would argue that such a theoretical abuse would blow up on an
> >> unchecked NULL ptr access. Isn't that enough?
> > 
> > Agreed.
> > 
> 
> If someone has written a module with __GFP_NOFAIL for an architecture
> where PAGE_SIZE == 2048KB, and someone else tried to use that module on
> another architecture where PAGE_SIZE == 4KB. You are saying that
> triggering NULL pointer dereference is a fault of that user's ignorance
> about MM. You are saying that everyone knows internal of MM. Sad...

What kind of argument is this? Seriously! We do consider GFP_NOFAIL
problematic even for !order-0 requests and warn appropriately. Talking
about anything getting close to MAX_ORDER is just a crazy talk. In any
case this is largely tangential to the issue reported here.
-- 
Michal Hocko
SUSE Labs
