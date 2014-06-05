Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f44.google.com (mail-la0-f44.google.com [209.85.215.44])
	by kanga.kvack.org (Postfix) with ESMTP id 1B9766B0037
	for <linux-mm@kvack.org>; Thu,  5 Jun 2014 12:18:17 -0400 (EDT)
Received: by mail-la0-f44.google.com with SMTP id hr17so755680lab.31
        for <linux-mm@kvack.org>; Thu, 05 Jun 2014 09:18:17 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bk5si12154970wjb.142.2014.06.05.09.18.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 05 Jun 2014 09:18:13 -0700 (PDT)
Date: Thu, 5 Jun 2014 18:18:07 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC][PATCH] oom: Be less verbose if the oom_control event fd
 has listeners
Message-ID: <20140605161807.GD15939@dhcp22.suse.cz>
References: <1401976841-3899-1-git-send-email-richard@nod.at>
 <1401976841-3899-2-git-send-email-richard@nod.at>
 <20140605150025.GB15939@dhcp22.suse.cz>
 <5390930A.8050504@nod.at>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5390930A.8050504@nod.at>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Richard Weinberger <richard@nod.at>
Cc: hannes@cmpxchg.org, bsingharora@gmail.com, kamezawa.hiroyu@jp.fujitsu.com, akpm@linux-foundation.org, vdavydov@parallels.com, tj@kernel.org, handai.szj@taobao.com, rientjes@google.com, oleg@redhat.com, rusty@rustcorp.com.au, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org

On Thu 05-06-14 17:55:54, Richard Weinberger wrote:
> Am 05.06.2014 17:00, schrieb Michal Hocko:
> > On Thu 05-06-14 16:00:41, Richard Weinberger wrote:
> >> Don't spam the kernel logs if the oom_control event fd has listeners.
> >> In this case there is no need to print that much lines as user space
> >> will anyway notice that the memory cgroup has reached its limit.
> > 
> > But how do you debug why it is reaching the limit and why a particular
> > process has been killed?
> 
> In my case it's always because customer's Java application gone nuts.
> So I don't really have to debug a lot. ;-)
> But I can understand your point.

If you know that handling memcg-OOM condition is easy then maybe you can
not only listen for the OOM notifications but also handle OOM conditions
and kill the offender. This would mean that kernel doesn't try to kill
anything and so wouldn't dump anything to the log.
 
> > If we are printing too much then OK, let's remove those parts which are
> > not that useful but hiding information which tells us more about the oom
> > decision doesn't sound right to me.
> 
> What about adding a sysctl like "vm.oom_verbose"?
> By default it would be 1.
> If set to 0 the full OOM information is only printed out if nobody listens
> to the event fd.

If we have a knob then I guess it should be global and shared by memcg
as well. I can imagine that somebody might be interested only in the
tasks dump, while somebody would like to see LRU states and other memory
counters. So it would be ideally a bitmask of things to output. I do not
think that a memcg specific solution is good, though.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
