Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 196936B004A
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 16:26:00 -0500 (EST)
Received: from wpaz9.hot.corp.google.com (wpaz9.hot.corp.google.com [172.24.198.73])
	by smtp-out.google.com with ESMTP id oA9LPpEY008333
	for <linux-mm@kvack.org>; Tue, 9 Nov 2010 13:25:51 -0800
Received: from pwi4 (pwi4.prod.google.com [10.241.219.4])
	by wpaz9.hot.corp.google.com with ESMTP id oA9LPMpC009856
	for <linux-mm@kvack.org>; Tue, 9 Nov 2010 13:25:50 -0800
Received: by pwi4 with SMTP id 4so31993pwi.37
        for <linux-mm@kvack.org>; Tue, 09 Nov 2010 13:25:50 -0800 (PST)
Date: Tue, 9 Nov 2010 13:25:47 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2]oom-kill: CAP_SYS_RESOURCE should get bonus
In-Reply-To: <alpine.DEB.2.00.1011091300510.7730@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1011091319300.7730@chino.kir.corp.google.com>
References: <1288834737.2124.11.camel@myhost> <alpine.DEB.2.00.1011031847450.21550@chino.kir.corp.google.com> <20101109195726.BC9E.A69D9226@jp.fujitsu.com> <20101109122437.2e0d71fd@lxorguk.ukuu.org.uk>
 <alpine.DEB.2.00.1011091300510.7730@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "Figo.zhang" <zhangtianfei@leadcoretech.com>, figo zhang <figo1802@gmail.com>, lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

On Tue, 9 Nov 2010, David Rientjes wrote:

> I didn't check earlier, but CAP_SYS_RESOURCE hasn't had a place in the oom 
> killer's heuristic in over five years, so what regression are we referring 
> to in this thread?  These tasks already have full control over 
> oom_score_adj to modify its oom killing priority in either direction.
> 

Yes, CAP_SYS_RESOURCE was a part of the heuristic in 2.6.25 along with 
CAP_SYS_ADMIN and was removed with the rewrite; when I said it "hasn't had 
a place in the oom killer's heuristic," I meant it's an unnecessary 
extention to CAP_SYS_ADMIN and allows for killing innocent tasks when a 
CAP_SYS_RESOURCE task is using too much memory.

The fundamental issue here is whether or not we should give a bonus to 
CAP_SYS_RESOURCE tasks because they are, by definition, allowed to access 
extra resources and we're willing to sacrifice other tasks for that.  This 
is antagonist to the oom killer's sole goal, however, which is to kill the 
task consuming the largest amount of memory unless protected by userspace 
(which CAP_SYS_RESOURCE has completely control in doing).

Since these threads have complete ability to give themselves this bonus 
(echo -30 > /proc/self/oom_score_adj), I don't think this needs to be a 
part of the core heuristic nor with such an arbitrary value of 3% (the old 
heuristic divided its badness score by 4, another arbitrary value).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
