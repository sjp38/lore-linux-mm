Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-gg0-f182.google.com (mail-gg0-f182.google.com [209.85.161.182])
	by kanga.kvack.org (Postfix) with ESMTP id 21B476B0031
	for <linux-mm@kvack.org>; Tue, 14 Jan 2014 19:58:12 -0500 (EST)
Received: by mail-gg0-f182.google.com with SMTP id e27so322367gga.13
        for <linux-mm@kvack.org>; Tue, 14 Jan 2014 16:58:11 -0800 (PST)
Received: from mail-yh0-x235.google.com (mail-yh0-x235.google.com [2607:f8b0:4002:c01::235])
        by mx.google.com with ESMTPS id x47si2919557yhx.10.2014.01.14.16.58.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 14 Jan 2014 16:58:11 -0800 (PST)
Received: by mail-yh0-f53.google.com with SMTP id b20so61495yha.40
        for <linux-mm@kvack.org>; Tue, 14 Jan 2014 16:58:10 -0800 (PST)
Date: Tue, 14 Jan 2014 16:58:07 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC] hotplug, memory: move register_memory_resource out of the
 lock_memory_hotplug
In-Reply-To: <1389723874-32372-1-git-send-email-nzimmer@sgi.com>
Message-ID: <alpine.DEB.2.02.1401141656030.3375@chino.kir.corp.google.com>
References: <1389723874-32372-1-git-send-email-nzimmer@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nathan Zimmer <nzimmer@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tang Chen <tangchen@cn.fujitsu.com>, Wen Congyang <wency@cn.fujitsu.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Hedi <hedi@sgi.com>, Mike Travis <travis@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 14 Jan 2014, Nathan Zimmer wrote:

> We don't need to do register_memory_resource() since it has its own lock and
> doesn't make any callbacks.
> 

We need to do it, just not under lock_memory_hotplug() :).

> Also register_memory_resource return NULL on failure so we don't have anything
> to cleanup at this point.
> 
> 
> The reason for this rfc is I was doing some experiments with hotplugging of
> memory on some of our larger systems.  While it seems to work, it can be quite
> slow.  With some preliminary digging I found that lock_memory_hotplug is
> clearly ripe for breakup.
> 
> It could be broken up per nid or something but it also covers the
> online_page_callback.  The online_page_callback shouldn't be very hard to break
> out.
> 
> Also there is the issue of various structures(wmarks come to mind) that are
> only updated under the lock_memory_hotplug that would need to be dealt with.
> 
> 
> cc: Andrew Morton <akpm@linux-foundation.org>
> cc: Tang Chen <tangchen@cn.fujitsu.com>
> cc: Wen Congyang <wency@cn.fujitsu.com>
> cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
> cc: "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>
> cc: Hedi <hedi@sgi.com>
> cc: Mike Travis <travis@sgi.com>
> cc: linux-mm@kvack.org
> cc: linux-kernel@vger.kernel.org

Looks like you're modifying a pre-3.12 kernel version that doesn't have 
27356f54c8c3 ("mm/hotplug: verify hotplug memory range").

When your patch is signed off, feel free to add

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
