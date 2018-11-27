Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 08A676B44A6
	for <linux-mm@kvack.org>; Mon, 26 Nov 2018 19:18:30 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id q8so4694105edd.8
        for <linux-mm@kvack.org>; Mon, 26 Nov 2018 16:18:29 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n56sor1548100edn.7.2018.11.26.16.18.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 26 Nov 2018 16:18:28 -0800 (PST)
Date: Tue, 27 Nov 2018 00:18:26 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH] mm, hotplug: protect nr_zones with pgdat_resize_lock()
Message-ID: <20181127001826.vek2rkbivoygy6pq@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20181120014822.27968-1-richard.weiyang@gmail.com>
 <20181120073141.GY22247@dhcp22.suse.cz>
 <3ba8d8c524d86af52e4c1fddc2d45734@suse.de>
 <20181121025231.ggk7zgq53nmqsqds@master>
 <20181121071549.GG12932@dhcp22.suse.cz>
 <CADZGycYghU=_vXR759mwFhvV=7KKu3z3h1FyWb4OeEMeOY5isg@mail.gmail.com>
 <20181126081608.GE12455@dhcp22.suse.cz>
 <20181126090654.hgazohtksychaaf3@master>
 <20181126100330.GF12455@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181126100330.GF12455@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: Wei Yang <richard.weiyang@gmail.com>, Oscar Salvador <osalvador@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>

On Mon, Nov 26, 2018 at 11:03:30AM +0100, Michal Hocko wrote:
>On Mon 26-11-18 09:06:54, Wei Yang wrote:
>> On Mon, Nov 26, 2018 at 09:16:08AM +0100, Michal Hocko wrote:
>> >On Mon 26-11-18 10:28:40, Wei Yang wrote:
>> >[...]
>> >> But I get some difficulty to understand this TODO. You want to get rid of
>> >> these lock? While these locks seem necessary to protect those data of
>> >> pgdat/zone. Would you mind sharing more on this statement?
>> >
>> >Why do we need this lock to be irqsave? Is there any caller that uses
>> >the lock from the IRQ context?
>> 
>> I see you put the comment 'irqsave' in code, I thought this is the
>> requirement bringing in by this commit. So this is copyed from somewhere
>> else?
>
>No, the irqsave lock has been there for a long time but it was not clear
>to me whether it is still required. Maybe it never was. I just didn't
>have time to look into that and put a TODO there. The code wouldn't be
>less correct if I kept it.
>

Let me summarize what you expect to do.

Go through all the users of pgdat_resize_lock, if none of them is called
from IRQ context, we could do the following change:

diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index ffd9cd10fcf3..45a5affcab8a 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -272,14 +272,14 @@ static inline bool movable_node_is_enabled(void)
  * pgdat resizing functions
  */
 static inline
-void pgdat_resize_lock(struct pglist_data *pgdat, unsigned long *flags)
+void pgdat_resize_lock(struct pglist_data *pgdat)
 {
-	spin_lock_irqsave(&pgdat->node_size_lock, *flags);
+	spin_lock(&pgdat->node_size_lock);
 }
 static inline
-void pgdat_resize_unlock(struct pglist_data *pgdat, unsigned long *flags)
+void pgdat_resize_unlock(struct pglist_data *pgdat)
 {
-	spin_unlock_irqrestore(&pgdat->node_size_lock, *flags);
+	spin_unlock(&pgdat->node_size_lock);
 }
 static inline
 void pgdat_resize_init(struct pglist_data *pgdat)

>> >From my understanding, we don't access pgdat from interrupt context.
>> 
>> BTW, one more confirmation. One irqsave lock means we can't do something
>> during holding the lock, like sleep. Is my understanding correct?
>
>You cannot sleep in any atomic context. IRQ safe lock only means that
>IRQs are disabled along with the lock. The irqsave variant should be
>taken when an IRQ context itself can take the lock. There is a lot of
>documentation to clarify this e.g. Linux Device Drivers. I would
>recommend to read through that.
>

Thanks.

I took a look at this one which seems to resolve my confusion.

https://www.kernel.org/doc/Documentation/locking/spinlocks.txt

>-- 
>Michal Hocko
>SUSE Labs

-- 
Wei Yang
Help you, Help me
