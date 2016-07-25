Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id A3D346B025E
	for <linux-mm@kvack.org>; Mon, 25 Jul 2016 15:23:48 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id p41so123484342lfi.0
        for <linux-mm@kvack.org>; Mon, 25 Jul 2016 12:23:48 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id ul8si16185583wjb.148.2016.07.25.12.23.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Jul 2016 12:23:47 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id q128so18103027wma.1
        for <linux-mm@kvack.org>; Mon, 25 Jul 2016 12:23:47 -0700 (PDT)
Date: Mon, 25 Jul 2016 21:23:45 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 2/2] mm, mempool: do not throttle PF_LESS_THROTTLE
 tasks
Message-ID: <20160725192344.GD2166@dhcp22.suse.cz>
References: <1468831164-26621-1-git-send-email-mhocko@kernel.org>
 <1468831285-27242-1-git-send-email-mhocko@kernel.org>
 <1468831285-27242-2-git-send-email-mhocko@kernel.org>
 <87oa5q5abi.fsf@notabene.neil.brown.name>
 <20160722091558.GF794@dhcp22.suse.cz>
 <878twt5i1j.fsf@notabene.neil.brown.name>
 <20160725083247.GD9401@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160725083247.GD9401@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: NeilBrown <neilb@suse.com>
Cc: linux-mm@kvack.org, Mikulas Patocka <mpatocka@redhat.com>, Ondrej Kozina <okozina@redhat.com>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, dm-devel@redhat.com, Marcelo Tosatti <mtosatti@redhat.com>

[CC Marcelo who might remember other details for the loads which made
 him to add this code - see the patch changelog for more context]

On Mon 25-07-16 10:32:47, Michal Hocko wrote:
> On Sat 23-07-16 10:12:24, NeilBrown wrote:
[...]
> > So I wonder what throttle_vm_writeout() really achieves these days.  Is
> > it just a bandaid that no-one is brave enough to remove?
> 
> Maybe yes. It is sitting there quietly and you do not know about it
> until it bites. Like in this particular case.

So I was playing with this today and tried to provoke throttle_vm_writeout
and couldn't hit that path with my pretty much default IO stack. I
probably need a more complex IO setup like dm-crypt or something that
basically have to double buffer every page in the writeout for some
time.

Anyway I believe that the throttle_vm_writeout is just a relict from the
past which just survived after many other changes in the reclaim path. I
fully realize my testing is quite poor and I would really appreciate if
Mikulas could try to retest with his more complex IO setups but let me
post a patch with the changelog so that we can at least reason about the
justification. In principle the reclaim path should have sufficient
throttling already and if that is not the case then we should
consolidate the remaining rather than have yet another one.

Thoughts?
---
