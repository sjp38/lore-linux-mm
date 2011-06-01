Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 954AC6B0011
	for <linux-mm@kvack.org>; Tue, 31 May 2011 23:33:10 -0400 (EDT)
Received: by pvc12 with SMTP id 12so2905230pvc.14
        for <linux-mm@kvack.org>; Tue, 31 May 2011 20:33:07 -0700 (PDT)
Date: Wed, 1 Jun 2011 12:32:58 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH v2 0/5] Fix oom killer doesn't work at all if system
 have > gigabytes memory  (aka CAI founded issue)
Message-ID: <20110601033258.GA12653@barrios-laptop>
References: <348391538.318712.1306828778575.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
 <4DE4A2A0.6090704@jp.fujitsu.com>
 <4DE4BC64.3040807@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4DE4BC64.3040807@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: caiqian@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, rientjes@google.com, hughd@google.com, kamezawa.hiroyu@jp.fujitsu.com, oleg@redhat.com

Hi KOSAKI,

On Tue, May 31, 2011 at 07:01:08PM +0900, KOSAKI Motohiro wrote:
> (2011/05/31 17:11), KOSAKI Motohiro wrote:
> >>> Then, I believe your distro applying distro specific patch to ssh.
> >>> Which distro are you using now?
> >> It is a Fedora-like distro.
> 
> So, Does this makes sense?
> 
> 
> 
> From e47fedaa546499fa3d4196753194db0609cfa2e5 Mon Sep 17 00:00:00 2001
> From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Date: Tue, 31 May 2011 18:28:30 +0900
> Subject: [PATCH] oom: use euid instead of CAP_SYS_ADMIN for protection root process
> 
> Recently, many userland daemon prefer to use libcap-ng and drop
> all privilege just after startup. Because of (1) Almost privilege
> are necessary only when special file open, and aren't necessary
> read and write. (2) In general, privilege dropping brings better
> protection from exploit when bugs are found in the daemon.
> 
> But, it makes suboptimal oom-killer behavior. CAI Qian reported
> oom killer killed some important daemon at first on his fedora
> like distro. Because they've lost CAP_SYS_ADMIN.
> 
> Of course, we recommend to drop privileges as far as possible
> instead of keeping them. Thus, oom killer don't have to check
> any capability. It implicitly suggest wrong programming style.
> 
> This patch change root process check way from CAP_SYS_ADMIN to
> just euid==0.

I like this but I have some comments.
Firstly, it's not dependent with your series so I think this could
be merged firstly.
Before that, I would like to make clear my concern.
As I look below comment, 3% bonus is dependent with __vm_enough_memory's logic?
If it isn't, we can remove the comment. It would be another patch.
If is is, could we change __vm_enough_memory for euid instead of cap?

        * Root processes get 3% bonus, just like the __vm_enough_memory()
	* implementation used by LSMs.

-- 
Kind regards
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
