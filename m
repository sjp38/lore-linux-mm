Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3C6A16B0799
	for <linux-mm@kvack.org>; Thu, 15 Nov 2018 23:41:23 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id y35so7695686edb.5
        for <linux-mm@kvack.org>; Thu, 15 Nov 2018 20:41:23 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n7-v6sor2851066edq.26.2018.11.15.20.41.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 15 Nov 2018 20:41:21 -0800 (PST)
Date: Fri, 16 Nov 2018 04:41:19 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH] mm: use managed_zone() for more exact check in zone
 iteration
Message-ID: <20181116044119.evn42acahfl6fh4r@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20181114235040.36180-1-richard.weiyang@gmail.com>
 <20181115133735.bb0313ec9293c415d08be550@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181115133735.bb0313ec9293c415d08be550@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Wei Yang <richard.weiyang@gmail.com>, mhocko@suse.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Nov 15, 2018 at 01:37:35PM -0800, Andrew Morton wrote:
>On Thu, 15 Nov 2018 07:50:40 +0800 Wei Yang <richard.weiyang@gmail.com> wrote:
>
>> For one zone, there are three digits to describe its space range:
>> 
>>     spanned_pages
>>     present_pages
>>     managed_pages
>> 
>> The detailed meaning is written in include/linux/mmzone.h. This patch
>> concerns about the last two.
>> 
>>     present_pages is physical pages existing within the zone
>>     managed_pages is present pages managed by the buddy system
>> 
>> >From the definition, managed_pages is a more strict condition than
>> present_pages.
>> 
>> There are two functions using zone's present_pages as a boundary:
>> 
>>     populated_zone()
>>     for_each_populated_zone()
>> 
>> By going through the kernel tree, most of their users are willing to
>> access pages managed by the buddy system, which means it is more exact
>> to check zone's managed_pages for a validation.
>> 
>> This patch replaces those checks on present_pages to managed_pages by:
>> 
>>     * change for_each_populated_zone() to for_each_managed_zone()
>>     * convert for_each_populated_zone() to for_each_zone() and check
>>       populated_zone() where is necessary
>>     * change populated_zone() to managed_zone() at proper places
>> 
>> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
>> 
>> ---
>> 
>> Michal, after last mail, I did one more thing to replace
>> populated_zone() with managed_zone() at proper places.
>> 
>> One thing I am not sure is those places in mm/compaction.c. I have
>> chaged them. If not, please let me know.
>> 
>> BTW, I did a boot up test with the patched kernel and looks smooth.
>
>Seems sensible, but a bit scary.  A basic boot test is unlikely to
>expose subtle gremlins.
>

Agree.

>Worse, the situations in which managed_zone() != populated_zone() are
>rare(?), so it will take a long time for problems to be discovered, I
>expect.

Hmm... I created a virtual machine with 4 nodes, which has total 6
populated zones. All of them are different.

This is a little bit out of my expactation.

>
>I'll toss it in there for now, let's see who breaks :(

Thanks.

-- 
Wei Yang
Help you, Help me
