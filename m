Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f42.google.com (mail-qa0-f42.google.com [209.85.216.42])
	by kanga.kvack.org (Postfix) with ESMTP id BE4B86B00D1
	for <linux-mm@kvack.org>; Fri, 14 Nov 2014 15:14:25 -0500 (EST)
Received: by mail-qa0-f42.google.com with SMTP id j7so1205542qaq.15
        for <linux-mm@kvack.org>; Fri, 14 Nov 2014 12:14:24 -0800 (PST)
Received: from mail-qa0-x229.google.com (mail-qa0-x229.google.com. [2607:f8b0:400d:c00::229])
        by mx.google.com with ESMTPS id f5si4794333qgf.125.2014.11.14.12.14.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 14 Nov 2014 12:14:23 -0800 (PST)
Received: by mail-qa0-f41.google.com with SMTP id s7so12208785qap.14
        for <linux-mm@kvack.org>; Fri, 14 Nov 2014 12:14:22 -0800 (PST)
Date: Fri, 14 Nov 2014 15:14:19 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC 0/4] OOM vs PM freezer fixes
Message-ID: <20141114201419.GI25889@htj.dyndns.org>
References: <20141110163055.GC18373@dhcp22.suse.cz>
 <1415818732-27712-1-git-send-email-mhocko@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1415818732-27712-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, linux-pm@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, "\\\"Rafael J. Wysocki\\\"" <rjw@rjwysocki.net>, David Rientjes <rientjes@google.com>, Oleg Nesterov <oleg@redhat.com>, Cong Wang <xiyou.wangcong@gmail.com>

On Wed, Nov 12, 2014 at 07:58:48PM +0100, Michal Hocko wrote:
> Hi,
> here is another take at OOM vs. PM freezer interaction fixes/cleanups.
> First three patches are fixes for an unlikely cases when OOM races with
> the PM freezer which should be closed completely finally. The last patch
> is a simple code enhancement which is not needed strictly speaking but
> it is nice to have IMO.
> 
> Both OOM killer and PM freezer are quite subtle so I hope I haven't
> missing anything. Any feedback is highly appreciated. I am also
> interested about feedback for the used approach. To be honest I am not
> really happy about spreading TIF_MEMDIE checks into freezer (patch 1)
> but I didn't find any other way for detecting OOM killed tasks.

I really don't get why this is structured this way.  Can't you just do
the following?

1. Freeze all freezables.  Don't worry about PF_MEMDIE.

2. Disable OOM killer.  This should be contained in the OOM killer
   proper.  Lock out the OOM killer and disable it.

3. At this point, we know that no one will create more freezable
   threads and no new process will be OOM kliled.  Wait till there's
   no process w/ PF_MEMDIE set.

There's no reason to lock out or disable OOM killer while the system
is not in the quiescent state, which is a big can of worms.  Bring
down the system to the quiescent state, disable the OOM killer and
then drain PF_MEMDIEs.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
