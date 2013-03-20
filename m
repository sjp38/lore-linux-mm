Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 2CDF16B0002
	for <linux-mm@kvack.org>; Wed, 20 Mar 2013 01:48:14 -0400 (EDT)
Date: Wed, 20 Mar 2013 16:17:53 +1030
From: Jonathan Woithe <jwoithe@atrad.com.au>
Subject: Re: OOM triggered with plenty of memory free
Message-ID: <20130320054753.GN12411@marvin.atrad.com.au>
References: <CAJd=RBDHwgtm=to3WUj73d7q6cjJ7oG6capjUxvcpVk0wH-fbQ@mail.gmail.com>
 <CAGDaZ_ryxdMBm44kotjKyCeFEFk3OURjHav3zVOcQNGwP_ZwAQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGDaZ_ryxdMBm44kotjKyCeFEFk3OURjHav3zVOcQNGwP_ZwAQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Raymond Jennings <shentino@gmail.com>
Cc: Hillf Danton <dhillf@gmail.com>, David Rientjes <rientjes@google.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Jonathan Woithe <jwoithe@atrad.com.au>

On Sat, Mar 16, 2013 at 02:33:23AM -0700, Raymond Jennings wrote:
> On Sat, Mar 16, 2013 at 2:25 AM, Hillf Danton <dhillf@gmail.com> wrote:
> >> Some system specifications:
> >> - CPU: i7 860 at 2.8 GHz
> >> - Mainboard: Advantech AIMB-780
> >> - RAM: 4 GB
> >> - Kernel: 2.6.35.11 SMP, 32 bit (kernel.org kernel, no patches applied)
> 
> > The highmem no longer holds memory with 64-bit kernel.
> 
> I don't really think that's a valid reason to dismiss problems with
> 32-bit though, as I still use it myself.
> 
> Anyway, to the parent poster, could you tell us more, such as how much
> ram you had left free?

Following up on my previous response, I have now done a git bisect and it
seems the leak was introduced by commit
cab9e9848b9a8283b0504a2d7c435a9f5ba026de.  This was applied in the leadup to
2.6.35.11, so 2.6.35.10 and earlier were all free of the problem.  As far as
I can tell, 2.6.36 and later are also unaffected.  I don't know whether this
is because the offending code in mainline is different to that applied to
2.6.35.x, or that due to other changes we're just not hitting the problem in
later kernels.

I should add that the above commit forms part of a series which appears to
have been applied out of order; to get it to compile it was necessary to
apply afa01a2cc021a5f03f02364bb867af3114395304 due to cab9...26de using a
function which was only added in afa0...5304.  As a result, while I think
the root cause is cab9...26de I may have misinterpreted things such that
one of the other patches in the series is the trigger.

I'll continue testing to try to identify which commit fixed the problem and
to confirm that 2.6.36 was indeed free of the leak.

Regards
  jonathan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
