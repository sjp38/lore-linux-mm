Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6B3916B000E
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 03:50:50 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id x2-v6so578445pgp.4
        for <linux-mm@kvack.org>; Thu, 26 Jul 2018 00:50:50 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h185-v6si786825pfc.172.2018.07.26.00.50.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jul 2018 00:50:49 -0700 (PDT)
Subject: Re: [Bug 200651] New: cgroups iptables-restor: vmalloc: allocation
 failure
References: <bug-200651-27@https.bugzilla.kernel.org/>
 <20180725125239.b591e4df270145f9064fe2c5@linux-foundation.org>
 <cd474b37-263f-b186-2024-507a9a4e12ae@suse.cz>
 <20180726072622.GS28386@dhcp22.suse.cz>
 <67d5e4ef-c040-6852-ad93-6f2528df0982@suse.cz>
 <20180726074219.GU28386@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <36043c6b-4960-8001-4039-99525dcc3e05@suse.cz>
Date: Thu, 26 Jul 2018 09:50:45 +0200
MIME-Version: 1.0
In-Reply-To: <20180726074219.GU28386@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, gnikolov@icdsoft.com, bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org, netfilter-devel@vger.kernel.org

On 07/26/2018 09:42 AM, Michal Hocko wrote:
> On Thu 26-07-18 09:34:58, Vlastimil Babka wrote:
>> On 07/26/2018 09:26 AM, Michal Hocko wrote:
>>> On Thu 26-07-18 09:18:57, Vlastimil Babka wrote:
>>>> On 07/25/2018 09:52 PM, Andrew Morton wrote:
>>>>> (switched to email.  Please respond via emailed reply-to-all, not via the
>>>>> bugzilla web interface).
>>>>>
>>>>> On Wed, 25 Jul 2018 11:42:57 +0000 bugzilla-daemon@bugzilla.kernel.org wrote:
>>>>>
>>>>>> https://bugzilla.kernel.org/show_bug.cgi?id=200651
>>>>>>
>>>>>>             Bug ID: 200651
>>>>>>            Summary: cgroups iptables-restor: vmalloc: allocation failure
>>>>>
>>>>> Thanks.  Please do note the above request.
>>>>>
>>>>>>            Product: Memory Management
>>>>>>            Version: 2.5
>>>>>>     Kernel Version: 4.14
>>>>>>           Hardware: All
>>>>>>                 OS: Linux
>>>>>>               Tree: Mainline
>>>>>>             Status: NEW
>>>>>>           Severity: normal
>>>>>>           Priority: P1
>>>>>>          Component: Other
>>>>>>           Assignee: akpm@linux-foundation.org
>>>>>>           Reporter: gnikolov@icdsoft.com
>>>>>>         Regression: No
>>>>>>
>>>>>> Created attachment 277505
>>>>>>   --> https://bugzilla.kernel.org/attachment.cgi?id=277505&action=edit
>>>>>> iptables save
>>>>>>
>>>>>> After creating large number of cgroups and under memory pressure, iptables
>>>>>> command fails with following error:
>>>>>>
>>>>>> "iptables-restor: vmalloc: allocation failure, allocated 3047424 of 3465216
>>>>>> bytes, mode:0x14010c0(GFP_KERNEL|__GFP_NORETRY), nodemask=(null)"
>>>>
>>>> This is likely the kvmalloc() in xt_alloc_table_info(). Between 4.13 and
>>>> 4.17 it shouldn't use __GFP_NORETRY, but looks like commit 0537250fdc6c
>>>> ("netfilter: x_tables: make allocation less aggressive") was backported
>>>> to 4.14. Removing __GFP_NORETRY might help here, but bring back other
>>>> issues. Less than 4MB is not that much though, maybe find some "sane"
>>>> limit and use __GFP_NORETRY only above that?
>>>
>>> I have seen the same report via http://lkml.kernel.org/r/df6f501c-8546-1f55-40b1-7e3a8f54d872@icdsoft.com
>>> and the reported confirmed that kvmalloc is not a real culprit
>>> http://lkml.kernel.org/r/d99a9598-808a-6968-4131-c3949b752004@icdsoft.com
>>
>> Hmm but that was revert of eacd86ca3b03 ("net/netfilter/x_tables.c: use
>> kvmalloc() in xt_alloc_table_info()") which was the 4.13 commit that
>> removed __GFP_NORETRY (there's no __GFP_NORETRY under net/netfilter in
>> v4.14). I assume it was reverted on top of vanilla v4.14 as there would
>> be conflict on the stable with 0537250fdc6c backport. So what should be
>> tested to be sure is either vanilla v4.14 without stable backports, or
>> latest v4.14.y with revert of 0537250fdc6c.
> 
> But 0537250fdc6c simply restored the previous NORETRY behavior from
> before eacd86ca3b03. So whatever causes these issues doesn't seem to be
> directly related to the kvmalloc change. Or do I miss what you are
> saying?

I'm saying that although it's not a regression, as you say (the
vmalloc() there was only for a few kernel versions called without
__GFP_NORETRY), it's still possible that removing __GFP_NORETRY will fix
the issue and thus we will rule out other possibilities.
