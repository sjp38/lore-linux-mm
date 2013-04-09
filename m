Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 5042F6B0005
	for <linux-mm@kvack.org>; Mon,  8 Apr 2013 20:36:52 -0400 (EDT)
Received: by mail-ob0-f178.google.com with SMTP id ni5so1809556obc.23
        for <linux-mm@kvack.org>; Mon, 08 Apr 2013 17:36:51 -0700 (PDT)
Message-ID: <5163629A.4070202@linaro.org>
Date: Mon, 08 Apr 2013 17:36:42 -0700
From: John Stultz <john.stultz@linaro.org>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 0/4] Support vranges on files
References: <1365033144-15156-1-git-send-email-john.stultz@linaro.org> <20130404065509.GE7675@blaptop> <515DBA70.8010606@linaro.org> <20130405075504.GA32126@blaptop> <20130408004638.GA6394@blaptop>
In-Reply-To: <20130408004638.GA6394@blaptop>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Kerrisk <mtk.manpages@gmail.com>, Arun Sharma <asharma@fb.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@sr71.net>, Rik van Riel <riel@redhat.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Jason Evans <je@fb.com>, sanjay@google.com, Paul Turner <pjt@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michel Lespinasse <walken@google.com>, Andrew Morton <akpm@linux-foundation.org>

On 04/07/2013 05:46 PM, Minchan Kim wrote:
> Hello John,
>
> As you know, userland people wanted to handle vrange with mmaped
> pointer rather than fd-based and see the SIGBUS so I thought more
> about semantic of vrange and want to make it very clear and easy.
> So I suggest below semantic(Of course, it's not rock solid).
>
>          mvrange(start_addr, lengh, mode, behavior)
>
> It's same with that I suggested lately but different name, just
> adding prefix "m". It's per-process model(ie, mm_struct vrange)
> so if process is exited, "volatility" isn't valid any more.
> It isn't a problem in anonymous but could be in file-vrange so let's
> introduce fvrange for covering the problem.
>
>          fvrange(int fd, start_offset, length, mode, behavior)
>
> First of all, let's see mvrange with anonymous and file page POV.
>
> 1) anon-mvrange
>
> The page in volaitle range will be purged only if all of processes
> marked the range as volatile.
>
> If A process calls mvrange and is forked, vrange could be copied
> from parent to child so not-yet-COWed pages could be purged
> unless either one of both processes marks NO_VOLATILE explicitly.
>
> Of course, COWed page could be purged easily because there is no link
> any more.

Ack. This seems reasonable.


> 2) file-mvrange
>
> A page in volatile range will be purged only if all of processes mapped
> the page marked it as volatile AND there is no process mapped the page
> as "private". IOW, all of the process mapped the page should map it
> with "shared" for purging.
>
> So, all of processes should mark each address range in own process
> context if they want to collaborate with shared mapped file and gaurantee
> there is no process mapped the range with "private".
>
> Of course, volatility state will be terminated as the process is gone.

This case doesn't seem ideal to me, but is sort of how the current code 
works to avoid the complexity of dealing with memory volatile ranges 
that cross page types (file/anonymous). Although the current code just 
doesn't purge file pages marked with mvrange().

I'd much prefer file-mvrange calls to behave identically to fvrange calls.

The important point here is that the kernel doesn't *have* to purge 
anything ever. Its the kernel's discretion as to which volatile pages to 
purge when. So its easier for now to simply not purge file pages marked 
volatile via mvolatile.

There however is the inconsistency that file pages marked volatile via 
fvrange, then are marked non-volatile via mvrange() might still be 
purged. That is broken in my mind, and still needs to be addressed. The 
easiest out is probably just to return an error if any of the mvrange 
calls cover file pages. But I'd really like a better fix.


> 3) fvrange
>
> It's same with 2) but volatility state could be persistent in address_space
> until someone calls fvrange(NO_VOLATILE).
> So it could remove the weakness of 2).
>   
> What do you think about above semantic?


I'd still like mvrange() calls on shared mapped files to be stored on 
the address_space.


> If you don't have any problem, we could implement it. I think 1) and 2) could
> be handled with my base code for anon-vrange handling with tweaking
> file-vrange and need your new patches in address_space for handling 3).

I think we can get it sorted out. It might just take a few iterations.

thanks
-john



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
