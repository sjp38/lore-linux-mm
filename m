Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 0EA6C6B002B
	for <linux-mm@kvack.org>; Mon, 10 Dec 2012 14:13:46 -0500 (EST)
Received: by mail-wi0-f169.google.com with SMTP id hq12so1361869wib.2
        for <linux-mm@kvack.org>; Mon, 10 Dec 2012 11:13:45 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <50C62AE6.3030000@iskon.hr>
References: <20121203194208.GZ24381@cmpxchg.org> <20121204214210.GB20253@cmpxchg.org>
 <20121205030133.GA17438@wolff.to> <20121206173742.GA27297@wolff.to>
 <CA+55aFzZsCUk6snrsopWQJQTXLO__G7=SjrGNyK3ePCEtZo7Sw@mail.gmail.com>
 <50C32D32.6040800@iskon.hr> <50C3AF80.8040700@iskon.hr> <alpine.LFD.2.02.1212081651270.4593@air.linux-foundation.org>
 <20121210110337.GH1009@suse.de> <20121210163904.GA22101@cmpxchg.org>
 <20121210180141.GK1009@suse.de> <50C62AE6.3030000@iskon.hr>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 10 Dec 2012 11:13:25 -0800
Message-ID: <CA+55aFwNE2y5t2uP3esCnHsaNo0NTDnGvzN6KF0qTw_y+QbtFA@mail.gmail.com>
Subject: Re: kswapd craziness in 3.7
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zlatko Calusic <zlatko.calusic@iskon.hr>, Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Mon, Dec 10, 2012 at 10:33 AM, Zlatko Calusic
<zlatko.calusic@iskon.hr> wrote:
>
> I was about to apply the patch that you sent, and reboot the server, but it
> seems there's no point because the patch is flawed?
>
> Anyway, if and when you have a proper one, I'll be glad to test it for you
> and report results.

I have reverted (again) the __GFP_NO_KSWAPD removal, and considering
that it really looks like there are overwhelming reasons to have that
flag, I will *not* take some new patch to revert it. I'm getting
convinced that the original removal really was bogus, and had no
actual valid reason for it.

Part of that is that I noticed that non-THP allocations wanted to use
it too. The i915 driver had wanted to use __GFP_NO_KSWAPD because it
too didn't want to start some cleaning thread. The whole mindset
kswapd is somehow better than direct reclaim or needed when it fails
is broken. Some allocations simply *will* fail, without necessarily
wanting kswapd to be started. THP - where the high order of the
allocation means that failure is inevitable under some fragmentation
circumstances - is just one such case.

I also reverted one of the "fix up the mess from removing
__GFP_NO_KSWAPD" patch, because that one was an obvious workaround
that tried to re-introduce the "let's not wake up kswapd after all for
that case". It clashed with a clean revert, and it was pointless in
the presense of __GFP_NO_KSWAPD anyway.

I did *not* revert some of the other fixup patches that tried to help
kswapd balancing decisions and avoid excessive CPU use other ways. So
some remains of this whole saga do still remain, but they look fairly
minimal.

It's worth giving this as much testing as is at all possible, but at
the same time I really don't think I can delay 3.7 any more without
messing up the holiday season too much. So unless something obvious
pops up, I will do the release tonight. So testing will be minimal -
but it's not like we haven't gone back-and-forth on this several times
already, and we revert to *mostly* the same old state as 3.6 anyway,
so it should be fairly safe.

                       Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
