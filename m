Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5AE4E6B0005
	for <linux-mm@kvack.org>; Thu, 19 May 2016 03:14:29 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id m64so37004709lfd.1
        for <linux-mm@kvack.org>; Thu, 19 May 2016 00:14:29 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id e15si16489014wmi.67.2016.05.19.00.14.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 May 2016 00:14:27 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id w143so18428933wmw.3
        for <linux-mm@kvack.org>; Thu, 19 May 2016 00:14:27 -0700 (PDT)
Date: Thu, 19 May 2016 09:14:26 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: add config option to select the initial overcommit
 mode
Message-ID: <20160519071426.GC26110@dhcp22.suse.cz>
References: <5735C567.6030202@free.fr>
 <20160513140128.GQ20141@dhcp22.suse.cz>
 <20160513160410.10c6cea6@lxorguk.ukuu.org.uk>
 <5735F4B1.1010704@laposte.net>
 <20160513164357.5f565d3c@lxorguk.ukuu.org.uk>
 <573AD534.6050703@laposte.net>
 <20160517085724.GD14453@dhcp22.suse.cz>
 <573B43FA.7080503@laposte.net>
 <20160517201605.GC12220@dhcp22.suse.cz>
 <573C87D5.6070304@laposte.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <573C87D5.6070304@laposte.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Frias <sf84@laposte.net>
Cc: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>, Mason <slash.tmp@free.fr>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, bsingharora@gmail.com

On Wed 18-05-16 17:18:45, Sebastian Frias wrote:
> Hi Michal,
> 
> On 05/17/2016 10:16 PM, Michal Hocko wrote:
> > On Tue 17-05-16 18:16:58, Sebastian Frias wrote:
[...]
> > The global OOM means there is _no_ memory at all. Many kernel
> > operations will need some memory to do something useful. Let's say you
> > would want to do an educated guess about who to kill - most proc APIs
> > will need to allocate. And this is just a beginning. Things are getting
> > really nasty when you get deeper and deeper. E.g. the OOM killer has to
> > give the oom victim access to memory reserves so that the task can exit
> > because that path needs to allocate as well. 
> 
> Really? I would have thought that once that SIGKILL is sent, the
> victim process is not expected to do anything else and thus its
> memory could be claimed immediately.  Or the OOM-killer is more of a
> OOM-terminator? (i.e.: sends SIGTERM)

Well, the path to exit is not exactly trivial. Resources have to be
released and that requires memory sometimes. E.g. exit_robust_list
needs to access the futex and that in turn means a page fault if the
memory was swapped out...
 
> >So even if you wanted to
> > give userspace some chance to resolve the OOM situation you would either
> > need some special API to tell "this process is really special and it can
> > access memory reserves and it has an absolute priority etc." or have a
> > in kernel fallback to do something or your system could lockup really
> > easily.
> > 
> 
> I see, so basically at least two cgroups would be needed, one reserved
> for handling the OOM situation through some API and another for the
> "rest of the system".  Basically just like the 5% reserved for 'root'
> on filesystems.

If you want to handle memcg OOM then you can use memory.oom_control (see
Documentation/cgroup-v1/memory.txt for more information) and have the
oom handler outside of that memcg.

> Do you think that would work?

But handling the _global_ oom from userspace is just insane with the
current kernel implementation. It just cannot work reliably.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
