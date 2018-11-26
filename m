Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5A2E96B418F
	for <linux-mm@kvack.org>; Mon, 26 Nov 2018 05:03:36 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id k58so8951590eda.20
        for <linux-mm@kvack.org>; Mon, 26 Nov 2018 02:03:36 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b56si131317eda.336.2018.11.26.02.03.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Nov 2018 02:03:34 -0800 (PST)
Date: Mon, 26 Nov 2018 11:03:30 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm, hotplug: protect nr_zones with pgdat_resize_lock()
Message-ID: <20181126100330.GF12455@dhcp22.suse.cz>
References: <20181120014822.27968-1-richard.weiyang@gmail.com>
 <20181120073141.GY22247@dhcp22.suse.cz>
 <3ba8d8c524d86af52e4c1fddc2d45734@suse.de>
 <20181121025231.ggk7zgq53nmqsqds@master>
 <20181121071549.GG12932@dhcp22.suse.cz>
 <CADZGycYghU=_vXR759mwFhvV=7KKu3z3h1FyWb4OeEMeOY5isg@mail.gmail.com>
 <20181126081608.GE12455@dhcp22.suse.cz>
 <20181126090654.hgazohtksychaaf3@master>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181126090654.hgazohtksychaaf3@master>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: Oscar Salvador <osalvador@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>

On Mon 26-11-18 09:06:54, Wei Yang wrote:
> On Mon, Nov 26, 2018 at 09:16:08AM +0100, Michal Hocko wrote:
> >On Mon 26-11-18 10:28:40, Wei Yang wrote:
> >[...]
> >> But I get some difficulty to understand this TODO. You want to get rid of
> >> these lock? While these locks seem necessary to protect those data of
> >> pgdat/zone. Would you mind sharing more on this statement?
> >
> >Why do we need this lock to be irqsave? Is there any caller that uses
> >the lock from the IRQ context?
> 
> I see you put the comment 'irqsave' in code, I thought this is the
> requirement bringing in by this commit. So this is copyed from somewhere
> else?

No, the irqsave lock has been there for a long time but it was not clear
to me whether it is still required. Maybe it never was. I just didn't
have time to look into that and put a TODO there. The code wouldn't be
less correct if I kept it.

> >From my understanding, we don't access pgdat from interrupt context.
> 
> BTW, one more confirmation. One irqsave lock means we can't do something
> during holding the lock, like sleep. Is my understanding correct?

You cannot sleep in any atomic context. IRQ safe lock only means that
IRQs are disabled along with the lock. The irqsave variant should be
taken when an IRQ context itself can take the lock. There is a lot of
documentation to clarify this e.g. Linux Device Drivers. I would
recommend to read through that.

-- 
Michal Hocko
SUSE Labs
