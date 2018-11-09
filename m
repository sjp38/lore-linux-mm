Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 706236B06D6
	for <linux-mm@kvack.org>; Fri,  9 Nov 2018 05:25:38 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id r21-v6so952143edp.5
        for <linux-mm@kvack.org>; Fri, 09 Nov 2018 02:25:38 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z30-v6si337065edb.342.2018.11.09.02.25.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Nov 2018 02:25:37 -0800 (PST)
Date: Fri, 9 Nov 2018 11:25:36 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: UBSAN: Undefined behaviour in mm/page_alloc.c
Message-ID: <20181109102536.GE5321@dhcp22.suse.cz>
References: <CAEAjamseRRHu+TaTkd1TwpLNm8mtDGP=2K0WKLF0wH-3iLcW_w@mail.gmail.com>
 <20181109084353.GA5321@dhcp22.suse.cz>
 <b51aae15-eb5d-47f0-1222-bfc1ef21e06c@I-love.SAKURA.ne.jp>
 <20181109095604.GC5321@dhcp22.suse.cz>
 <a74e6a5d-d4c1-9006-60af-de52afafebb2@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a74e6a5d-d4c1-9006-60af-de52afafebb2@i-love.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Kyungtae Kim <kt0755@gmail.com>, akpm@linux-foundation.org, pavel.tatashin@microsoft.com, vbabka@suse.cz, osalvador@suse.de, rppt@linux.vnet.ibm.com, aaron.lu@intel.com, iamjoonsoo.kim@lge.com, alexander.h.duyck@linux.intel.com, mgorman@techsingularity.net, lifeasageek@gmail.com, threeearcat@gmail.com, syzkaller@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>

On Fri 09-11-18 19:07:49, Tetsuo Handa wrote:
> On 2018/11/09 18:56, Michal Hocko wrote:
> > Does this following look better?
> 
> Yes.
> 
> >> Also, why not to add BUG_ON(gfp_mask & __GFP_NOFAIL); here?
> > 
> > Because we do not want to blow up the kernel just because of a stupid
> > usage of the allocator. Can you think of an example where it would
> > actually make any sense?
> > 
> > I would argue that such a theoretical abuse would blow up on an
> > unchecked NULL ptr access. Isn't that enough?
> 
> We after all can't avoid blowing up the kernel even if we don't add BUG_ON().
> Stopping with BUG_ON() is saner than NULL pointer dereference messages.

I disagree (strongly to be more explicit). You never know the context
the allocator is called from. We do not want to oops with a random state
(locks heled etc). If the access blows up in the user then be it, the
bug will be clear and to be fixed but BUG_ON on an invalid core kernel
function is just a bad idea. I believe Linus was quite explicit about it
and I fully agree with him.

Besides that this is really off-topic to the issue at hands. Don't you
think?
-- 
Michal Hocko
SUSE Labs
