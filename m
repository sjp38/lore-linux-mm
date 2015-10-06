Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f172.google.com (mail-ig0-f172.google.com [209.85.213.172])
	by kanga.kvack.org (Postfix) with ESMTP id 027D482FAC
	for <linux-mm@kvack.org>; Tue,  6 Oct 2015 04:55:35 -0400 (EDT)
Received: by igcpb10 with SMTP id pb10so82171095igc.1
        for <linux-mm@kvack.org>; Tue, 06 Oct 2015 01:55:34 -0700 (PDT)
Received: from mail-io0-x22e.google.com (mail-io0-x22e.google.com. [2607:f8b0:4001:c06::22e])
        by mx.google.com with ESMTPS id e9si12236661igi.58.2015.10.06.01.55.34
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Oct 2015 01:55:34 -0700 (PDT)
Received: by ioii196 with SMTP id i196so213783726ioi.3
        for <linux-mm@kvack.org>; Tue, 06 Oct 2015 01:55:34 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CA+55aFxxfbCuTjnK_TpxrTftQOXeTi4PBawbv27P_Xqz4Y5ibw@mail.gmail.com>
References: <20150922160608.GA2716@redhat.com>
	<20150923205923.GB19054@dhcp22.suse.cz>
	<alpine.DEB.2.10.1509241359100.32488@chino.kir.corp.google.com>
	<20150925093556.GF16497@dhcp22.suse.cz>
	<201509260114.ADI35946.OtHOVFOMJQFLFS@I-love.SAKURA.ne.jp>
	<201509290118.BCJ43256.tSFFFMOLHVOJOQ@I-love.SAKURA.ne.jp>
	<20151002123639.GA13914@dhcp22.suse.cz>
	<CA+55aFw=OLSdh-5Ut2vjy=4Yf1fTXqpzoDHdF7XnT5gDHs6sYA@mail.gmail.com>
	<87k2r0ph21.fsf@x220.int.ebiederm.org>
	<CA+55aFxxfbCuTjnK_TpxrTftQOXeTi4PBawbv27P_Xqz4Y5ibw@mail.gmail.com>
Date: Tue, 6 Oct 2015 09:55:33 +0100
Message-ID: <CA+55aFz1HFLVNeAaOWK=-Wyq8FF5bhWpWk8Dnwpa-8vD2k+b+A@mail.gmail.com>
Subject: Re: can't oom-kill zap the victim's memory?
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Michal Hocko <mhocko@kernel.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, David Rientjes <rientjes@google.com>, Oleg Nesterov <oleg@redhat.com>, Kyle Walker <kwalker@redhat.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Stanislav Kozina <skozina@redhat.com>

On Tue, Oct 6, 2015 at 9:49 AM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> The basic fact remains: kernel allocations are so important that
> rather than fail, you should kill user space. Only kernel allocations
> that *explicitly* know that they have fallback code should fail, and
> they should just do the __GFP_NORETRY.

To be clear: "big" orders (I forget if the limit is at order-3 or
order-4) do fail much more aggressively. But no, we do not limit retry
to just order-0, because even small kmalloc sizes tend to often do
order-1 or order-2 just because of memory packing issues (ie trying to
pack into a single page wastes too much memory if the allocation sizes
don't come out right).

So no, order-0 isn't special. 1/2 are rather important too.

[ Checking /proc/slabinfo: it looks like several slabs are order-3,
for things like files_cache, signal_cache and sighand_cache for me at
least. So I think it's up to order-3 that we basically need to
consider "we'll need to shrink user space aggressively unless we have
an explicit fallback for the allocation" ]

            Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
