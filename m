Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 004376B5328
	for <linux-mm@kvack.org>; Thu, 29 Nov 2018 10:04:53 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id y35so1233214edb.5
        for <linux-mm@kvack.org>; Thu, 29 Nov 2018 07:04:52 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k20sor1420674ede.22.2018.11.29.07.04.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 29 Nov 2018 07:04:51 -0800 (PST)
Date: Thu, 29 Nov 2018 15:04:49 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH] mm, show_mem: drop pgdat_resize_lock in show_mem()
Message-ID: <20181129150449.desiutez735agyau@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20181128210815.2134-1-richard.weiyang@gmail.com>
 <20181129081703.GN6923@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181129081703.GN6923@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: Wei Yang <richard.weiyang@gmail.com>, akpm@linux-foundation.org, jweiner@fb.com, linux-mm@kvack.org

On Thu, Nov 29, 2018 at 09:17:03AM +0100, Michal Hocko wrote:
>On Thu 29-11-18 05:08:15, Wei Yang wrote:
>> Function show_mem() is used to print system memory status when user
>> requires or fail to allocate memory. Generally, this is a best effort
>> information and not willing to affect core mm subsystem.
>
>I would drop the part after and
>
>> The data protected by pgdat_resize_lock is mostly correct except there is:
>> 
>>    * page struct defer init
>>    * memory hotplug
>
>This is more confusing than helpful. I would just drop it.
>
>The changelog doesn't explain what is done and why. The second one is
>much more important. I would say this
>
>"
>Function show_mem() is used to print system memory status when user
>requires or fail to allocate memory. Generally, this is a best effort
>information so any races with memory hotplug (or very theoretically an
>early initialization) should be toleratable and the worst that could
>happen is to print an imprecise node state.
>
>Drop the resize lock because this is the only place which might hold the

As I mentioned in https://patchwork.kernel.org/patch/10689759/, there is
one place used in __remove_zone(). I don't get your suggestion of this
place. And is __remove_zone() could be called in IRQ context?

>lock from the interrupt context and so all other callers might use a
>simple spinlock. Even though this doesn't solve any real issue it makes
>the code easier to follow and tiny more effective.
>"
>

-- 
Wei Yang
Help you, Help me
