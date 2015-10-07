Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 68ABB6B0038
	for <linux-mm@kvack.org>; Wed,  7 Oct 2015 01:16:54 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so196011331wic.0
        for <linux-mm@kvack.org>; Tue, 06 Oct 2015 22:16:53 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p5si43128933wje.126.2015.10.06.22.16.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 06 Oct 2015 22:16:52 -0700 (PDT)
Subject: Re: can't oom-kill zap the victim's memory?
References: <20150922160608.GA2716@redhat.com>
 <20150923205923.GB19054@dhcp22.suse.cz>
 <alpine.DEB.2.10.1509241359100.32488@chino.kir.corp.google.com>
 <20150925093556.GF16497@dhcp22.suse.cz>
 <201509260114.ADI35946.OtHOVFOMJQFLFS@I-love.SAKURA.ne.jp>
 <201509290118.BCJ43256.tSFFFMOLHVOJOQ@I-love.SAKURA.ne.jp>
 <20151002123639.GA13914@dhcp22.suse.cz>
 <CA+55aFw=OLSdh-5Ut2vjy=4Yf1fTXqpzoDHdF7XnT5gDHs6sYA@mail.gmail.com>
 <20151005144404.GD7023@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <5614AAC0.60002@suse.cz>
Date: Wed, 7 Oct 2015 07:16:48 +0200
MIME-Version: 1.0
In-Reply-To: <20151005144404.GD7023@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, David Rientjes <rientjes@google.com>, Oleg Nesterov <oleg@redhat.com>, Kyle Walker <kwalker@redhat.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Stanislav Kozina <skozina@redhat.com>

On 5.10.2015 16:44, Michal Hocko wrote:
> So I can see basically only few ways out of this deadlock situation.
> Either we face the reality and allow small allocations (withtout
> __GFP_NOFAIL) to fail after all attempts to reclaim memory have failed
> (so after even OOM killer hasn't made any progress).

Note that small allocations already *can* fail if they are done in the context
of a task selected as OOM victim (i.e. TIF_MEMDIE). And yeah I've seen a case
when they failed in a code that "handled" the allocation failure with a
BUG_ON(!page).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
