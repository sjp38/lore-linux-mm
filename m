Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3FFC66B0005
	for <linux-mm@kvack.org>; Tue, 17 May 2016 16:16:09 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id u64so14691111lff.2
        for <linux-mm@kvack.org>; Tue, 17 May 2016 13:16:09 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id s73si28496601wmd.77.2016.05.17.13.16.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 May 2016 13:16:07 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id r12so7580368wme.0
        for <linux-mm@kvack.org>; Tue, 17 May 2016 13:16:07 -0700 (PDT)
Date: Tue, 17 May 2016 22:16:06 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: add config option to select the initial overcommit
 mode
Message-ID: <20160517201605.GC12220@dhcp22.suse.cz>
References: <5735AA0E.5060605@free.fr>
 <20160513114429.GJ20141@dhcp22.suse.cz>
 <5735C567.6030202@free.fr>
 <20160513140128.GQ20141@dhcp22.suse.cz>
 <20160513160410.10c6cea6@lxorguk.ukuu.org.uk>
 <5735F4B1.1010704@laposte.net>
 <20160513164357.5f565d3c@lxorguk.ukuu.org.uk>
 <573AD534.6050703@laposte.net>
 <20160517085724.GD14453@dhcp22.suse.cz>
 <573B43FA.7080503@laposte.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <573B43FA.7080503@laposte.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Frias <sf84@laposte.net>
Cc: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>, Mason <slash.tmp@free.fr>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, bsingharora@gmail.com

On Tue 17-05-16 18:16:58, Sebastian Frias wrote:
[...]
> From reading Documentation/cgroup-v1/memory.txt (and from a few
> replies here talking about cgroups), it looks like the OOM-killer is
> still being actively discussed, well, there's also "cgroup-v2".
> My understanding is that cgroup's memory control will pause processes
> in a given cgroup until the OOM situation is solved for that cgroup,
> right?

It will be blocked waiting either for some external action which would
result in OOM codition going away or any other charge release. You have
to configure memcg for that though. The default behavior is to invoke
the same OOM killer algorithm which is just reduced to tasks from the
memcg (hierarchy).

> If that is right, it means that there is indeed a way to deal
> with an OOM situation (stack expansion, COW failure, 'memory hog',
> etc.) in a better way than the OOM-killer, right?
> In which case, do you guys know if there is a way to make the whole
> system behave as if it was inside a cgroup? (*)

No it is not. You have to realize that the system wide and the memcg OOM
situations are quite different. There is usually quite some memory free
when you hit the memcg OOM so the administrator can actually do
something. The global OOM means there is _no_ memory at all. Many kernel
operations will need some memory to do something useful. Let's say you
would want to do an educated guess about who to kill - most proc APIs
will need to allocate. And this is just a beginning. Things are getting
really nasty when you get deeper and deeper. E.g. the OOM killer has to
give the oom victim access to memory reserves so that the task can exit
because that path needs to allocate as well. So even if you wanted to
give userspace some chance to resolve the OOM situation you would either
need some special API to tell "this process is really special and it can
access memory reserves and it has an absolute priority etc." or have a
in kernel fallback to do something or your system could lockup really
easily.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
