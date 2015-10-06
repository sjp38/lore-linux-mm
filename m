Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f181.google.com (mail-io0-f181.google.com [209.85.223.181])
	by kanga.kvack.org (Postfix) with ESMTP id 41B896B029B
	for <linux-mm@kvack.org>; Tue,  6 Oct 2015 04:49:20 -0400 (EDT)
Received: by ioiz6 with SMTP id z6so213732188ioi.2
        for <linux-mm@kvack.org>; Tue, 06 Oct 2015 01:49:20 -0700 (PDT)
Received: from mail-ig0-x22c.google.com (mail-ig0-x22c.google.com. [2607:f8b0:4001:c05::22c])
        by mx.google.com with ESMTPS id g12si21713336iod.92.2015.10.06.01.49.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Oct 2015 01:49:19 -0700 (PDT)
Received: by igbkq10 with SMTP id kq10so82046157igb.0
        for <linux-mm@kvack.org>; Tue, 06 Oct 2015 01:49:19 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <87k2r0ph21.fsf@x220.int.ebiederm.org>
References: <20150922160608.GA2716@redhat.com>
	<20150923205923.GB19054@dhcp22.suse.cz>
	<alpine.DEB.2.10.1509241359100.32488@chino.kir.corp.google.com>
	<20150925093556.GF16497@dhcp22.suse.cz>
	<201509260114.ADI35946.OtHOVFOMJQFLFS@I-love.SAKURA.ne.jp>
	<201509290118.BCJ43256.tSFFFMOLHVOJOQ@I-love.SAKURA.ne.jp>
	<20151002123639.GA13914@dhcp22.suse.cz>
	<CA+55aFw=OLSdh-5Ut2vjy=4Yf1fTXqpzoDHdF7XnT5gDHs6sYA@mail.gmail.com>
	<87k2r0ph21.fsf@x220.int.ebiederm.org>
Date: Tue, 6 Oct 2015 09:49:19 +0100
Message-ID: <CA+55aFxxfbCuTjnK_TpxrTftQOXeTi4PBawbv27P_Xqz4Y5ibw@mail.gmail.com>
Subject: Re: can't oom-kill zap the victim's memory?
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Michal Hocko <mhocko@kernel.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, David Rientjes <rientjes@google.com>, Oleg Nesterov <oleg@redhat.com>, Kyle Walker <kwalker@redhat.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Stanislav Kozina <skozina@redhat.com>

On Tue, Oct 6, 2015 at 8:55 AM, Eric W. Biederman <ebiederm@xmission.com> wrote:
>
> Not to take away from your point about very small allocations.  However
> assuming allocations larger than a page will always succeed is down
> right dangerous.

We've required retrying for *at least* order-1 allocations. Exactly
because things like fork() etc have wanted them, and:

 - as you say, you can be unlucky even with reasonable amounts of free memory

 - the page-out code is approximate and doesn't guarantee that you get
buddy coalescing

 - just failing after a couple of loops has been known to result in
fork() and similar friends returning -EAGAIN and breaking user space.

Really. Stop this idiocy. We have gone through this before. It's a disaster.

The basic fact remains: kernel allocations are so important that
rather than fail, you should kill user space. Only kernel allocations
that *explicitly* know that they have fallback code should fail, and
they should just do the __GFP_NORETRY.

So the rule ends up being that we retry the memory freeing loop for
small allocations (where "small" is something like "order 2 or less")

So really. If you find some particular case that is painful because it
wants an order-1 or order-2 allocation, then you do this:

 - do the allocation with GFP_NORETRY

 - have a fallback that uses vmalloc or just is able to make the
buffer even smaller.

But by default we will continue to make small orders retry. As
mentioned, we have tried the alternatives. It doesn't work.

            Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
