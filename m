Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id E7AB88E0095
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 09:41:16 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id c3so7148245eda.3
        for <linux-mm@kvack.org>; Tue, 11 Dec 2018 06:41:16 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 33sor8435349edr.16.2018.12.11.06.41.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 11 Dec 2018 06:41:15 -0800 (PST)
Date: Tue, 11 Dec 2018 14:41:13 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH] mm, sparse: remove check with
 __highest_present_section_nr in for_each_present_section_nr()
Message-ID: <20181211144113.u7liwlob7kujki7d@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20181211035128.43256-1-richard.weiyang@gmail.com>
 <20181211094441.GD1286@dhcp22.suse.cz>
 <20181211101905.xczl6bndmrqwukni@master>
 <20181211102313.GG1286@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181211102313.GG1286@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: Wei Yang <richard.weiyang@gmail.com>, linux-mm@kvack.org, akpm@linux-foundation.org, osalvador@suse.de

On Tue, Dec 11, 2018 at 11:23:13AM +0100, Michal Hocko wrote:
>On Tue 11-12-18 10:19:05, Wei Yang wrote:
>> On Tue, Dec 11, 2018 at 10:44:41AM +0100, Michal Hocko wrote:
>> >On Tue 11-12-18 11:51:28, Wei Yang wrote:
>> >> A valid present section number is in [0, __highest_present_section_nr].
>> >> And the return value of next_present_section_nr() meets this
>> >> requirement. This means it is not necessary to check it with
>> >> __highest_present_section_nr again in for_each_present_section_nr().
>> >> 
>> >> Since we pass an unsigned long *section_nr* to
>> >> for_each_present_section_nr(), we need to cast it to int before
>> >> comparing.
>> >
>> >Why do we want this patch? Is it an improvement? If yes, it is
>> >performance visible change or does it make the code easier to maintain?
>> >
>> 
>> Michal
>> 
>> I know you concern, maintainance is a very critical part of review.
>> 
>> >To me at least the later seems dubious to be honest because it adds a
>> >non-obvious dependency of the terminal condition to the
>> >next_present_section_nr implementation and that might turn out error
>> >prone.
>> >
>> 
>> While I think the original code is not that clear about the syntax.
>> 
>> When we look at the next_present_section_nr(section_nr), the return
>> value falls into two categories:
>> 
>>   -1   : no more present section after section_nr
>>   other: the next present section number after section_nr
>> 
>> Based on this syntax, the iteration could be simpler to terminate
>> when the return value is less than 0. This is what the patch tries to
>> do.
>> 
>> Maybe I could do more to help the maintainance:
>> 
>>   * add some comment about the return value of next_present_section_nr
>>   * terminate the loop when section_nr == -1
>> 
>> Hope this would help a little.
>
>Well, not really. Nothing of the above seems to matter to callers of the
>code. So I do not see this as a general improvement and as such no
>strong reason to merge it. It is basicly polishing a code without any
>obvious issues.

Er... but I don't see the reason to keep a redundant check in the code.

Even this is an internal function, it would be better to make it clean
and neat. Would you mind sharing your concern about this polishing? If
there is no issue, we would prefer no polishing of the code?

>-- 
>Michal Hocko
>SUSE Labs

-- 
Wei Yang
Help you, Help me
