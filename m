Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f197.google.com (mail-ua0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 21A8B28089F
	for <linux-mm@kvack.org>; Wed,  8 Feb 2017 22:17:39 -0500 (EST)
Received: by mail-ua0-f197.google.com with SMTP id d5so89575881uag.5
        for <linux-mm@kvack.org>; Wed, 08 Feb 2017 19:17:39 -0800 (PST)
Received: from resqmta-ch2-01v.sys.comcast.net (resqmta-ch2-01v.sys.comcast.net. [2001:558:fe21:29:69:252:207:33])
        by mx.google.com with ESMTPS id b1si2950275vkf.96.2017.02.08.19.17.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Feb 2017 19:17:38 -0800 (PST)
Date: Wed, 8 Feb 2017 21:15:03 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: mm: deadlock between get_online_cpus/pcpu_alloc
In-Reply-To: <alpine.DEB.2.20.1702081838560.3536@nanos>
Message-ID: <alpine.DEB.2.20.1702082109530.13608@east.gentwo.org>
References: <20170207123708.GO5065@dhcp22.suse.cz> <20170207135846.usfrn7e4znjhmogn@techsingularity.net> <20170207141911.GR5065@dhcp22.suse.cz> <20170207153459.GV5065@dhcp22.suse.cz> <20170207162224.elnrlgibjegswsgn@techsingularity.net> <20170207164130.GY5065@dhcp22.suse.cz>
 <alpine.DEB.2.20.1702071053380.16150@east.gentwo.org> <alpine.DEB.2.20.1702072319200.8117@nanos> <20170208073527.GA5686@dhcp22.suse.cz> <alpine.DEB.2.20.1702080906540.3955@east.gentwo.org> <20170208152106.GP5686@dhcp22.suse.cz> <alpine.DEB.2.20.1702081011460.4938@east.gentwo.org>
 <alpine.DEB.2.20.1702081838560.3536@nanos>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Dmitry Vyukov <dvyukov@google.com>, Tejun Heo <tj@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, syzkaller <syzkaller@googlegroups.com>, Andrew Morton <akpm@linux-foundation.org>

On Wed, 8 Feb 2017, Thomas Gleixner wrote:

> There is a world outside yours. Hotplug is actually used frequently for
> power purposes in some scenarios.

The usual case does not inolve hotplug.

> It will improve nothing. The stop machine context is extremly limited and
> you cannot do complex things there at all. Not to talk about the inability
> of taking a simple mutex which would immediately deadlock the machine.

You do not need to do complex things. Basically flipping some cpu mask
bits will do it. stop machine ensures that code is not
executing on the processors when the bits are flipped. That will ensure
that there is no need to do any get_online_cpu() nastiness in critical VM
paths since we are guaranteed not to be executing them.

> And everything complex needs to be done _before_ that in normal
> context. Hot unplug already uses stop machine for the final removal of the
> outgoing CPU, but that's definitely not the place where you can do anything
> complex like page management.

If it already does that then why do we still need get_online_cpu()? We do
not do anything like page management. Why would we? We just need to ensure
that nothing is executing when the bits are flipped. If that is the case
then the get_online_cpu(0 calls are unecessary because the bit flipping
simply cannot occur in these functions. There is nothing to serialize
against.

> If you can prepare the outgoing cpu work during the cpu offline phase and
> then just flip a bit in the stop machine part, then this might work, but
> anything else is just handwaving and proliferation of wet dreams.

Fine with that.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
