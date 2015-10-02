Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f170.google.com (mail-io0-f170.google.com [209.85.223.170])
	by kanga.kvack.org (Postfix) with ESMTP id 7D48A4402F8
	for <linux-mm@kvack.org>; Fri,  2 Oct 2015 15:01:08 -0400 (EDT)
Received: by ioii196 with SMTP id i196so129900968ioi.3
        for <linux-mm@kvack.org>; Fri, 02 Oct 2015 12:01:08 -0700 (PDT)
Received: from mail-io0-x234.google.com (mail-io0-x234.google.com. [2607:f8b0:4001:c06::234])
        by mx.google.com with ESMTPS id r9si290942igh.88.2015.10.02.12.01.07
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Oct 2015 12:01:07 -0700 (PDT)
Received: by ioiz6 with SMTP id z6so130002068ioi.2
        for <linux-mm@kvack.org>; Fri, 02 Oct 2015 12:01:07 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20151002123639.GA13914@dhcp22.suse.cz>
References: <20150922160608.GA2716@redhat.com>
	<20150923205923.GB19054@dhcp22.suse.cz>
	<alpine.DEB.2.10.1509241359100.32488@chino.kir.corp.google.com>
	<20150925093556.GF16497@dhcp22.suse.cz>
	<201509260114.ADI35946.OtHOVFOMJQFLFS@I-love.SAKURA.ne.jp>
	<201509290118.BCJ43256.tSFFFMOLHVOJOQ@I-love.SAKURA.ne.jp>
	<20151002123639.GA13914@dhcp22.suse.cz>
Date: Fri, 2 Oct 2015 15:01:06 -0400
Message-ID: <CA+55aFw=OLSdh-5Ut2vjy=4Yf1fTXqpzoDHdF7XnT5gDHs6sYA@mail.gmail.com>
Subject: Re: can't oom-kill zap the victim's memory?
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, David Rientjes <rientjes@google.com>, Oleg Nesterov <oleg@redhat.com>, Kyle Walker <kwalker@redhat.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Stanislav Kozina <skozina@redhat.com>

On Fri, Oct 2, 2015 at 8:36 AM, Michal Hocko <mhocko@kernel.org> wrote:
>
> Have they been reported/fixed? All kernel paths doing an allocation are
> _supposed_ to check and handle ENOMEM. If they are not then they are
> buggy and should be fixed.

No. Stop this theoretical idiocy.

We've tried it. I objected before people tried it, and it turns out
that it was a horrible idea.

Small kernel allocations should basically never fail, because we end
up needing memory for random things, and if a kmalloc() fails it's
because some application is using too much memory, and the application
should be killed. Never should the kernel allocation fail. It really
is that simple. If we are out of memory, that does not mean that we
should start failing random kernel things.

So this "people should check for allocation failures" is bullshit.
It's a computer science myth. It's simply not true in all cases.

Kernel allocators that know that they do large allocations (ie bigger
than a few pages) need to be able to handle the failure, but not the
general case. Also, kernel allocators that know they have a good
fallback (eg they try a large allocation first but can fall back to a
smaller one) should use __GFP_NORETRY, but again, that does *not* in
any way mean that general kernel allocations should randomly fail.

So no. The answer is ABSOLUTELY NOT "everybody should check allocation
failure". Get over it. I refuse to go through that circus again. It's
stupid.

             Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
