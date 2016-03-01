Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f175.google.com (mail-pf0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 7FFA06B0005
	for <linux-mm@kvack.org>; Tue,  1 Mar 2016 11:56:42 -0500 (EST)
Received: by mail-pf0-f175.google.com with SMTP id w128so71238814pfb.2
        for <linux-mm@kvack.org>; Tue, 01 Mar 2016 08:56:42 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id z63si51512736pfi.63.2016.03.01.08.56.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Mar 2016 08:56:41 -0800 (PST)
Date: Tue, 1 Mar 2016 19:56:30 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH 2/2] cgroup: reset css on destruction
Message-ID: <20160301165630.GB2426@esperanza>
References: <69629961aefc48c021b895bb0c8297b56c11a577.1456830735.git.vdavydov@virtuozzo.com>
 <92b11b89791412df49e73597b87912e8f143a3f7.1456830735.git.vdavydov@virtuozzo.com>
 <20160301163018.GE3965@htj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20160301163018.GE3965@htj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Mar 01, 2016 at 11:30:18AM -0500, Tejun Heo wrote:
> On Tue, Mar 01, 2016 at 02:13:13PM +0300, Vladimir Davydov wrote:
> > @@ -5138,6 +5138,8 @@ static void kill_css(struct cgroup_subsys_state *css)
> >  	 * See seq_css() for details.
> >  	 */
> >  	css_clear_dir(css, NULL);
> > +	if (css->ss->css_reset)
> > +		css->ss->css_reset(css);
> 
> I think the better spot for this is in offline_css() right before
> ->css_offline() is called.

Okay, here it goes.
---
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: [PATCH] cgroup: reset css on destruction

An associated css can be around for quite a while after a cgroup
directory has been removed. In general, it makes sense to reset it to
defaults so as not to worry about any remnants. For instance, memory
cgroup needs to reset memory.low, otherwise pages charged to a dead
cgroup might never get reclaimed. There's ->css_reset callback, which
would fit perfectly for the purpose. Currently, it's only called when a
subsystem is disabled in the unified hierarchy and there are other
subsystems dependant on it. Let's call it on css destruction as well.

Suggested-by: Johannes Weiner <hannes@cmpxchg.org>
Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index cc40463e7b69..bb1900b70b01 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -4876,6 +4876,9 @@ static void offline_css(struct cgroup_subsys_state *css)
 	if (!(css->flags & CSS_ONLINE))
 		return;
 
+	if (ss->css_reset)
+		ss->css_reset(css);
+
 	if (ss->css_offline)
 		ss->css_offline(css);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
