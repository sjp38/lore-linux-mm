Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 8AB306B002C
	for <linux-mm@kvack.org>; Thu, 13 Oct 2011 00:35:54 -0400 (EDT)
Message-ID: <4E966564.5030902@redhat.com>
Date: Thu, 13 Oct 2011 00:13:24 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH -v2 -mm] add extra free kbytes tunable
References: <20110901105208.3849a8ff@annuminas.surriel.com> <20110901100650.6d884589.rdunlap@xenotime.net> <20110901152650.7a63cb8b@annuminas.surriel.com> <alpine.DEB.2.00.1110072001070.13992@chino.kir.corp.google.com> <65795E11DBF1E645A09CEC7EAEE94B9CB516CBBC@USINDEVS02.corp.hds.com> <alpine.DEB.2.00.1110111343070.29761@chino.kir.corp.google.com> <4E959292.9060301@redhat.com> <alpine.DEB.2.00.1110121316590.7646@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1110121316590.7646@chino.kir.corp.google.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Satoru Moriya <satoru.moriya@hds.com>, Randy Dunlap <rdunlap@xenotime.net>, Satoru Moriya <smoriya@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "lwoodman@redhat.com" <lwoodman@redhat.com>, Seiji Aguchi <saguchi@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>

On 10/12/2011 04:21 PM, David Rientjes wrote:
> On Wed, 12 Oct 2011, Rik van Riel wrote:
>
>> How would this scheme work?
>>
>
> I suggested a patch from BFS that would raise kswapd to the same priority
> of the task that triggered it (not completely up to rt, but the highest
> possible in that case) and I'm waiting to hear if that helps for Satoru's
> test case before looking at alternatives.  We could also extend the patch
> to raise the priority of an already running kswapd if a higher priority
> task calls into the page allocator's slowpath.

This has the distinct benefit of making kswapd most active right
at the same time the application is most active, which returns
us to your first objection to the extra free kbytes patch (apps
will suffer from kswapd cpu use).

Furthermore, I am not sure that giving kswapd more CPU time is
going to help, because kswapd could be stuck on some lock, held
by a lower priority (or sleeping) context.

I agree that the BFS patch would be worth a try, and would be
very pleasantly surprised if it worked, but I am not very
optimistic about it...

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
