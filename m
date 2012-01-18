Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id 345CC6B004D
	for <linux-mm@kvack.org>; Wed, 18 Jan 2012 02:17:04 -0500 (EST)
Received: by lagw12 with SMTP id w12so1167327lag.14
        for <linux-mm@kvack.org>; Tue, 17 Jan 2012 23:17:02 -0800 (PST)
Date: Wed, 18 Jan 2012 09:16:49 +0200 (EET)
From: Pekka Enberg <penberg@kernel.org>
Subject: Re: [RFC 1/3] /dev/low_mem_notify
In-Reply-To: <20120117232025.GB903@barrios-desktop.redhat.com>
Message-ID: <alpine.LFD.2.02.1201180905040.2488@tux.localdomain>
References: <1326788038-29141-1-git-send-email-minchan@kernel.org> <1326788038-29141-2-git-send-email-minchan@kernel.org> <CAOJsxLHGYmVNk7D9NyhRuqQDwquDuA7LtUtp-1huSn5F-GvtAg@mail.gmail.com> <4F15A34F.40808@redhat.com> <alpine.LFD.2.02.1201172044310.15303@tux.localdomain>
 <20120117232025.GB903@barrios-desktop.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, leonid.moiseichuk@nokia.com, kamezawa.hiroyu@jp.fujitsu.com, mel@csn.ul.ie, rientjes@google.com, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Marcelo Tosatti <mtosatti@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Ronen Hod <rhod@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

On Wed, 18 Jan 2012, Minchan Kim wrote:
> I didn't look into your code(will do) but as I read description,
> still I don't convince we need really some process specific threshold like 99%
> I think application can know it by polling /proc/meminfo without this mechanism
> if they really want.

I'm not sure if we need arbitrary threshold either. However, we need to 
support the following cases:

   - We're about to swap

   - We're about to run out of memory

   - We're about to start OOM killing

and I don't think your patch solves that. One possibility is to implement:

   VMNOTIFY_TYPE_ABOUT_TO_SWAP
   VMNOTIFY_TYPE_ABOUT_TO_OOM
   VMNOTIFY_TYPE_ABOUT_TO_OOM_KILL

and maybe rip out support for arbitrary thresholds. Does that more 
reasonable?

As for polling /proc/meminfo, I'd much rather deliver stats as part of 
vmnotify_read() because it's easier to extend the ABI rather than adding 
new fields to /proc/meminfo.

On Wed, 18 Jan 2012, Minchan Kim wrote:
> I would like to notify when system has a trobule with memory pressure without
> some process specific threshold. Of course, applicatoin can't expect it.(ie,
> application can know system memory pressure by /proc/meminfo but it can't know
> when swapout really happens). Kernel low mem notify have to give such notification
> to user space, I think.

It should be simple to add support for VMNOTIFY_TYPE_MEM_PRESSURE that 
uses your hooks.

 			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
