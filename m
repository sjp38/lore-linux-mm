Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4FFCE6B0276
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 04:31:35 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id s18-v6so508955edr.15
        for <linux-mm@kvack.org>; Thu, 26 Jul 2018 01:31:35 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w30-v6si1055162eda.448.2018.07.26.01.31.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jul 2018 01:31:33 -0700 (PDT)
Subject: Re: [Bug 200651] New: cgroups iptables-restor: vmalloc: allocation
 failure
References: <bug-200651-27@https.bugzilla.kernel.org/>
 <20180725125239.b591e4df270145f9064fe2c5@linux-foundation.org>
 <cd474b37-263f-b186-2024-507a9a4e12ae@suse.cz>
 <20180726072622.GS28386@dhcp22.suse.cz>
 <67d5e4ef-c040-6852-ad93-6f2528df0982@suse.cz>
 <20180726074219.GU28386@dhcp22.suse.cz>
 <36043c6b-4960-8001-4039-99525dcc3e05@suse.cz>
 <20180726080301.GW28386@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <ed7090ad-5004-3133-3faf-607d2a9fa90a@suse.cz>
Date: Thu, 26 Jul 2018 10:31:32 +0200
MIME-Version: 1.0
In-Reply-To: <20180726080301.GW28386@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, gnikolov@icdsoft.com, bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org, netfilter-devel@vger.kernel.org

On 07/26/2018 10:03 AM, Michal Hocko wrote:
> On Thu 26-07-18 09:50:45, Vlastimil Babka wrote:
>> On 07/26/2018 09:42 AM, Michal Hocko wrote:
>>> On Thu 26-07-18 09:34:58, Vlastimil Babka wrote:
>>>> On 07/26/2018 09:26 AM, Michal Hocko wrote:
>>>>> On Thu 26-07-18 09:18:57, Vlastimil Babka wrote:
>>>>>> On 07/25/2018 09:52 PM, Andrew Morton wrote:
>>>>>>
>>>>>> This is likely the kvmalloc() in xt_alloc_table_info(). Between 4.13 and
>>>>>> 4.17 it shouldn't use __GFP_NORETRY, but looks like commit 0537250fdc6c
>>>>>> ("netfilter: x_tables: make allocation less aggressive") was backported
>>>>>> to 4.14. Removing __GFP_NORETRY might help here, but bring back other
>>>>>> issues. Less than 4MB is not that much though, maybe find some "sane"
>>>>>> limit and use __GFP_NORETRY only above that?
>>>>>
>>>>> I have seen the same report via http://lkml.kernel.org/r/df6f501c-8546-1f55-40b1-7e3a8f54d872@icdsoft.com
>>>>> and the reported confirmed that kvmalloc is not a real culprit
>>>>> http://lkml.kernel.org/r/d99a9598-808a-6968-4131-c3949b752004@icdsoft.com
>>>>
>>>> Hmm but that was revert of eacd86ca3b03 ("net/netfilter/x_tables.c: use
>>>> kvmalloc() in xt_alloc_table_info()") which was the 4.13 commit that
>>>> removed __GFP_NORETRY (there's no __GFP_NORETRY under net/netfilter in
>>>> v4.14). I assume it was reverted on top of vanilla v4.14 as there would
>>>> be conflict on the stable with 0537250fdc6c backport. So what should be
>>>> tested to be sure is either vanilla v4.14 without stable backports, or
>>>> latest v4.14.y with revert of 0537250fdc6c.
>>>
>>> But 0537250fdc6c simply restored the previous NORETRY behavior from
>>> before eacd86ca3b03. So whatever causes these issues doesn't seem to be
>>> directly related to the kvmalloc change. Or do I miss what you are
>>> saying?
>>
>> I'm saying that although it's not a regression, as you say (the
>> vmalloc() there was only for a few kernel versions called without
>> __GFP_NORETRY), it's still possible that removing __GFP_NORETRY will fix
>> the issue and thus we will rule out other possibilities.
> 
> http://lkml.kernel.org/r/d99a9598-808a-6968-4131-c3949b752004@icdsoft.com
> claims that reverting eacd86ca3b03 didn't really help.

Of course not. eacd86ca3b03 *removed* __GFP_NORETRY, so the revert
reintroduced it. I tried to explain it in the quoted part above starting
with "Hmm but that was revert of eacd86ca3b03 ...". What I'm saying is
that eacd86ca3b03 might have actually *fixed* (or rather prevented) this
alloc failure, if there was not 0537250fdc6c and its 4.14 stable
backport (the kernel bugzilla report says 4.14, I'm assuming new enough
stable to contain 0537250fdc6c as the failure message contains
__GFP_NORETRY).

The mail you reference also says "seems that old version is masking
errors", which confirms that we are indeed looking at the right
vmalloc(), because eacd86ca3b03 also removed __GFP_NOWARN there (and
thus the revert reintroduced it).
