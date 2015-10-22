Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f174.google.com (mail-ob0-f174.google.com [209.85.214.174])
	by kanga.kvack.org (Postfix) with ESMTP id E81F66B0038
	for <linux-mm@kvack.org>; Thu, 22 Oct 2015 10:09:52 -0400 (EDT)
Received: by obcqt19 with SMTP id qt19so68162493obc.3
        for <linux-mm@kvack.org>; Thu, 22 Oct 2015 07:09:52 -0700 (PDT)
Received: from mail-pa0-x22f.google.com (mail-pa0-x22f.google.com. [2607:f8b0:400e:c03::22f])
        by mx.google.com with ESMTPS id h77si8893214oib.19.2015.10.22.07.09.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Oct 2015 07:09:52 -0700 (PDT)
Received: by pacfv9 with SMTP id fv9so91953797pac.3
        for <linux-mm@kvack.org>; Thu, 22 Oct 2015 07:09:51 -0700 (PDT)
Date: Thu, 22 Oct 2015 23:09:44 +0900
From: Tejun Heo <htejun@gmail.com>
Subject: Re: [PATCH] mm,vmscan: Use accurate values for zone_reclaimable()
 checks
Message-ID: <20151022140944.GA30579@mtj.duckdns.org>
References: <alpine.DEB.2.20.1510210920200.5611@east.gentwo.org>
 <20151021143337.GD8805@dhcp22.suse.cz>
 <alpine.DEB.2.20.1510210948460.6898@east.gentwo.org>
 <20151021145505.GE8805@dhcp22.suse.cz>
 <alpine.DEB.2.20.1510211214480.10364@east.gentwo.org>
 <201510222037.ACH86458.OFOLFtQFOHJSVM@I-love.SAKURA.ne.jp>
 <alpine.DEB.2.20.1510220836430.18486@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1510220836430.18486@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, mhocko@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, David Rientjes <rientjes@google.com>, oleg@redhat.com, kwalker@redhat.com, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@parallels.com, skozina@redhat.com, mgorman@suse.de, riel@redhat.com

On Thu, Oct 22, 2015 at 08:39:11AM -0500, Christoph Lameter wrote:
> On Thu, 22 Oct 2015, Tetsuo Handa wrote:
> 
> > The problem would be that the "struct task_struct" to execute vmstat_update
> > job does not exist, and will not be able to create one on demand because we
> > are stuck at __GFP_WAIT allocation. Therefore adding a dedicated kernel
> > thread for vmstat_update job would work. But ...
> 
> Yuck. Can someone please get this major screwup out of the work queue
> subsystem? Tejun?

Hmmm?  Just use a dedicated workqueue with WQ_MEM_RECLAIM.  If
concurrency management is a problem and there's something live-locking
for that work item (really?), WQ_CPU_INTENSIVE escapes it.  If this is
a common occurrence that it makes sense to give vmstat higher
priority, set WQ_HIGHPRI.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
