Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f182.google.com (mail-ie0-f182.google.com [209.85.223.182])
	by kanga.kvack.org (Postfix) with ESMTP id A26E66B0038
	for <linux-mm@kvack.org>; Tue,  6 Jan 2015 18:27:31 -0500 (EST)
Received: by mail-ie0-f182.google.com with SMTP id x19so737305ier.13
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 15:27:31 -0800 (PST)
Received: from mail-ie0-x232.google.com (mail-ie0-x232.google.com. [2607:f8b0:4001:c03::232])
        by mx.google.com with ESMTPS id 12si41732900iot.89.2015.01.06.15.27.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 06 Jan 2015 15:27:30 -0800 (PST)
Received: by mail-ie0-f178.google.com with SMTP id vy18so763786iec.9
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 15:27:29 -0800 (PST)
References: <20150106161435.GF20860@dhcp22.suse.cz>
From: Greg Thelen <gthelen@google.com>
Subject: Re: [LSF/MM TOPIC ATTEND]
In-reply-to: <20150106161435.GF20860@dhcp22.suse.cz>
Date: Tue, 06 Jan 2015 15:27:27 -0800
Message-ID: <xr93k30zij6o.fsf@gthelen.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org

On Tue, Jan 06 2015, Michal Hocko wrote:

> - As it turned out recently GFP_KERNEL mimicing GFP_NOFAIL for !costly
>   allocation is sometimes kicking us back because we are basically
>   creating an invisible lock dependencies which might livelock the whole
>   system under OOM conditions.
>   That leads to attempts to add more hacks into the OOM killer
>   which is tricky enough as is. Changing the current state is
>   quite risky because we do not really know how many places in the
>   kernel silently depend on this behavior. As per Johannes attempt
>   (http://marc.info/?l=linux-mm&m=141932770811346) it is clear that
>   we are not yet there! I do not have very good ideas how to deal with
>   this unfortunatelly...

We've internally been fighting similar deadlocks between memcg kmem
accounting and memcg oom killer.  I wouldn't call it a very good idea,
because it falls in the realm of further complicating the oom killer,
but what about introducing an async oom killer which runs outside of the
context of the current task.  An async killer won't hold any locks so it
won't block the indented oom victim from terminating.  After queuing a
deferred oom kill the allocating thread would then be able to dip into
memory reserves to satisfy its too-small-to-fail allocation.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
