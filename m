Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id DC1C76B007E
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 04:43:11 -0500 (EST)
Date: Thu, 8 Mar 2012 12:35:10 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] memcg: Free spare array to avoid memory leak
Message-ID: <20120308103510.GA12897@shutemov.name>
References: <1331036004-7550-1-git-send-email-handai.szj@taobao.com>
 <20120307230819.GA10238@shutemov.name>
 <4F581554.6020801@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4F581554.6020801@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sha Zhengju <handai.szj@gmail.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Sha Zhengju <handai.szj@taobao.com>

On Thu, Mar 08, 2012 at 10:11:32AM +0800, Sha Zhengju wrote:
> On 03/08/2012 07:08 AM, Kirill A. Shutemov wrote:
> >On Tue, Mar 06, 2012 at 08:13:24PM +0800, Sha Zhengju wrote:
> >>From: Sha Zhengju<handai.szj@taobao.com>
> >>
> >>When the last event is unregistered, there is no need to keep the spare
> >>array anymore. So free it to avoid memory leak.
> >It's not a leak. It will be freed on next event register.
> 
> 
> Yeah, I noticed that. But what if it is just the last one and no more
> event registering ?

See my question below. ;)

> >Yeah, we don't have to keep spare if primary is empty. But is it worth to
> >make code more complicated to save few bytes of memory?
> >
> >>Signed-off-by: Sha Zhengju<handai.szj@taobao.com>
> >>
> >>---
> >>  mm/memcontrol.c |    6 ++++++
> >>  1 files changed, 6 insertions(+), 0 deletions(-)
> >>
> >>diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> >>index 22d94f5..3c09a84 100644
> >>--- a/mm/memcontrol.c
> >>+++ b/mm/memcontrol.c
> >>@@ -4412,6 +4412,12 @@ static void mem_cgroup_usage_unregister_event(struct cgroup *cgrp,
> >>  swap_buffers:
> >>  	/* Swap primary and spare array */
> >>  	thresholds->spare = thresholds->primary;
> >>+	/* If all events are unregistered, free the spare array */
> >>+	if (!new) {
> >>+		kfree(thresholds->spare);
> >>+		thresholds->spare = NULL;
> >>+	}
> >>+
> >>  	rcu_assign_pointer(thresholds->primary, new);
> >>
> >>  	/* To be sure that nobody uses thresholds */
> >>-- 
> >>1.7.4.1
> >>
> 

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
