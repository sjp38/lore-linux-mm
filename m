Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id ADC8D900194
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 18:57:48 -0400 (EDT)
Received: from wpaz9.hot.corp.google.com (wpaz9.hot.corp.google.com [172.24.198.73])
	by smtp-out.google.com with ESMTP id p5MMvk6t023632
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 15:57:46 -0700
Received: from pwi4 (pwi4.prod.google.com [10.241.219.4])
	by wpaz9.hot.corp.google.com with ESMTP id p5MMveaO023237
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 15:57:45 -0700
Received: by pwi4 with SMTP id 4so1880721pwi.1
        for <linux-mm@kvack.org>; Wed, 22 Jun 2011 15:57:40 -0700 (PDT)
Date: Wed, 22 Jun 2011 15:57:38 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/6] oom: use euid instead of CAP_SYS_ADMIN for protection
 root process
In-Reply-To: <4E01C809.9020508@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1106221552310.11759@chino.kir.corp.google.com>
References: <4E01C7D5.3060603@jp.fujitsu.com> <4E01C809.9020508@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, caiqian@redhat.com, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Oleg Nesterov <oleg@redhat.com>

On Wed, 22 Jun 2011, KOSAKI Motohiro wrote:

> Recently, many userland daemon prefer to use libcap-ng and drop
> all privilege just after startup. Because of (1) Almost privilege
> are necessary only when special file open, and aren't necessary
> read and write. (2) In general, privilege dropping brings better
> protection from exploit when bugs are found in the daemon.
> 

You could also say that dropping the capability drops the bonus it is 
given in the oom killer.  We've never promised any benefit in the oom 
killer badness scoring without the capability.

> But, it makes suboptimal oom-killer behavior. CAI Qian reported
> oom killer killed some important daemon at first on his fedora
> like distro. Because they've lost CAP_SYS_ADMIN.
> 

I disagree that we should be identifying "important daemons" by tying it 
the effective uid of the process and thus making some sort of inference 
because a thread was forked by root.  I think it is more clear to tie that 
to an actual capability that is present, such as CAP_SYS_ADMIN, or suggest 
that the user give the "important daemon" it's own bonus by tuning 
/proc/pid/oom_score_adj.

We already know that the kernel will not be able to identify critical 
processes perfectly, that's an assumption that we can live with.  We must 
rely on userspace to influence that decision by using the tunable.

If this patch were merged, I could easily imagine an argument in the 
reverse that would just simply revert it: it would be very easy to say 
that CAP_SYS_ADMIN has always given this bonus in recent memory so 
changing it would be a regression over the previous behavior and/or that 
giving the capability to a thread as it runs implies that it should have 
the bonus when the euid may not be 0.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
