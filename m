Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 83E236B02D1
	for <linux-mm@kvack.org>; Mon, 24 Apr 2017 09:06:42 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id k46so40360145qtf.21
        for <linux-mm@kvack.org>; Mon, 24 Apr 2017 06:06:42 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d77si5784795qkc.148.2017.04.24.06.06.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Apr 2017 06:06:41 -0700 (PDT)
Date: Mon, 24 Apr 2017 15:06:38 +0200
From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: Re: [PATCH] mm,page_alloc: Split stall warning and failure warning.
Message-ID: <20170424130634.GA6267@redhat.com>
References: <1491825493-8859-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20170410150308.c6e1a0213c32e6d587b33816@linux-foundation.org>
 <alpine.DEB.2.10.1704171539190.46404@chino.kir.corp.google.com>
 <201704182049.BIE34837.FJOFOMFOQSLHVt@I-love.SAKURA.ne.jp>
 <alpine.DEB.2.10.1704181435560.112481@chino.kir.corp.google.com>
 <20170419111342.GF29789@dhcp22.suse.cz>
 <20170419132212.GA3514@redhat.com>
 <20170419133339.GI29789@dhcp22.suse.cz>
 <20170422081030.GA5476@redhat.com>
 <20170424084216.GB1739@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170424084216.GB1739@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, akpm@linux-foundation.org, linux-mm@kvack.org, hannes@cmpxchg.org

On Mon, Apr 24, 2017 at 10:42:17AM +0200, Michal Hocko wrote:
> On Sat 22-04-17 10:10:34, Stanislaw Gruszka wrote:
> [...]
> > > This whole special casing
> > > of debug_guardpage_minorder is just too strange to me. We do have a rate
> > > limit to not flood the log.
> > 
> > I added this check to skip warning if buddy allocator fail, what I
> > considered likely scenario taking the conditions. The check remove
> > warning completely, rate limit only limit the speed warnings shows in
> > logs.
> 
> Yes and this is what I argue against. The feature limits the amount of
> _usable_ memory and as such it changes the behavior of the allocator
> which can lead to all sorts of problems (including high memory pressure,
> stalls, OOM etc.). The warning is there to help debug all those
> problems and removing it just changes that behavior in an unexpected
> way. This is just wrong thing to do IMHO. Even worse so when it
> motivates to make other code in the allocator more complicated.

Allocation problems when using debug_guardpage_minorder should not be
motivation to any mm change. This option is debug only (as name should
suggest already). It purpose is to debug drivers/code that corrupt
memory at random places, it is expected it will cause allocations
problems.

> If there
> is really a problem logs flooded by the allocation failures while using
> the guard page we should address it by a more strict ratelimiting.

Ok, make sense.

Stanislaw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
