Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1DCA66B0033
	for <linux-mm@kvack.org>; Wed,  8 Feb 2017 10:11:09 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id j13so147392807iod.6
        for <linux-mm@kvack.org>; Wed, 08 Feb 2017 07:11:09 -0800 (PST)
Received: from resqmta-ch2-04v.sys.comcast.net (resqmta-ch2-04v.sys.comcast.net. [2001:558:fe21:29:69:252:207:36])
        by mx.google.com with ESMTPS id b101si14935810ioj.150.2017.02.08.07.11.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Feb 2017 07:11:08 -0800 (PST)
Date: Wed, 8 Feb 2017 09:11:06 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: mm: deadlock between get_online_cpus/pcpu_alloc
In-Reply-To: <20170208073527.GA5686@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.20.1702080906540.3955@east.gentwo.org>
References: <20170207113435.6xthczxt2cx23r4t@techsingularity.net> <20170207114327.GI5065@dhcp22.suse.cz> <20170207123708.GO5065@dhcp22.suse.cz> <20170207135846.usfrn7e4znjhmogn@techsingularity.net> <20170207141911.GR5065@dhcp22.suse.cz> <20170207153459.GV5065@dhcp22.suse.cz>
 <20170207162224.elnrlgibjegswsgn@techsingularity.net> <20170207164130.GY5065@dhcp22.suse.cz> <alpine.DEB.2.20.1702071053380.16150@east.gentwo.org> <alpine.DEB.2.20.1702072319200.8117@nanos> <20170208073527.GA5686@dhcp22.suse.cz>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Dmitry Vyukov <dvyukov@google.com>, Tejun Heo <tj@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, syzkaller <syzkaller@googlegroups.com>, Andrew Morton <akpm@linux-foundation.org>

On Wed, 8 Feb 2017, Michal Hocko wrote:

> > Huch? stop_machine() is horrible and heavy weight. Don't go there, there
> > must be simpler solutions than that.
>
> Absolutely agreed. We are in the page allocator path so using the
> stop_machine* is just ridiculous. And, in fact, there is a much simpler
> solution [1]

That is nonsense. stop_machine would be used when adding removing a
processor. There would be no need to synchronize when looping over active
cpus anymore. get_online_cpus() etc would be removed from the hot
path since the cpu masks are guaranteed to be stable.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
