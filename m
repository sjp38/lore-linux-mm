Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 3CC63900014
	for <linux-mm@kvack.org>; Tue, 11 Nov 2014 09:47:32 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id rd3so10821744pab.0
        for <linux-mm@kvack.org>; Tue, 11 Nov 2014 06:47:32 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id tz1si20278294pab.54.2014.11.11.06.47.30
        for <linux-mm@kvack.org>;
        Tue, 11 Nov 2014 06:47:30 -0800 (PST)
Message-ID: <54621FDF.8090304@intel.com>
Date: Tue, 11 Nov 2014 22:40:31 +0800
From: Xiaokang <xiaokang.qin@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH] proc/smaps: add proportional size of anonymous page
References: <1415349088-24078-1-git-send-email-xiaokang.qin@intel.com> <545D3AFB.1080308@intel.com> <6212C327DC2094488C1AAAD903AF062B01BCE1E6@SHSMSX104.ccr.corp.intel.com> <5460EFC9.7060906@intel.com>
In-Reply-To: <5460EFC9.7060906@intel.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "Yin, Fengwei" <fengwei.yin@intel.com>

On 11/11/2014 01:03 AM, Dave Hansen wrote:
> On 11/10/2014 12:48 AM, Qin, Xiaokang wrote:
>> For some case especially under Android, anonymous page sharing is common, for example:
>> 70323000-70e41000 rw-p 00000000 fd:00 120004                             /data/dalvik-cache/x86/system@framework@boot.art
>> Size:              11384 kB
>> Rss:                8840 kB
>> Pss:                 927 kB
>> Shared_Clean:       5720 kB
>> Shared_Dirty:       2492 kB
>> Private_Clean:        16 kB
>> Private_Dirty:       612 kB
>> Referenced:         7896 kB
>> Anonymous:          3104 kB
>> PropAnonymous:       697 kB
>
> Please don't top post.
>
>> The only Anonymous here is confusing to me. What I really want to
>> know is how many anonymous page is there in Pss. After exposing
>> PropAnonymous, we could know 697/927 is anonymous in Pss.
>> I suppose the Pss - PropAnonymous = Proportional Page cache size for
>> file based memory and we want to break down the page cache into
>> process level, how much page cache each process consumes.
>
> Ahh, so you're talking about the anonymous pages that result from
> copy-on-write copies of private file mappings?  That wasn't very clear
> from the description at all.

Yes, sorry for the unclear description.

>
> I'll agree that this definitely provides a bit of data that we didn't
> have before, albeit a fairly obscure one.
>
> But, what's the goal of this patch?  Why are you doing this?  Was there
> some application whose behavior you were not able to explain before, but
> can after this patch?

Under Android, when user switches the application the previous 
application will not exit but switch to background so that next time 
this application could be resumed to foreground very quickly.
So there may be many applications running at background and Android 
introduces lowmemory killer to kill processes to free memory according 
to oom_adj when memory is short. Some processes with high value of 
oom_adj will be killed first like the background running non-critical 
application. The memory used by these processes could be treated as 
"free" because it could be freed by killing. Hence under Android the 
"free" RAM is composed of: 1) memory using by non-critical application 
that could be killed easily, 2) page cache, 3) physical free page. We 
are using sum of Pss in smaps to measure the process consumed memory for 
1) and get the info for 2) 3) from /proc/meminfo. Then we have the 
problem that file based memory will be double accounted in 1) and 2). To 
mitigate the double accounting issue here, we need to know the double 
accounting part - proportional page cache size, and do the deduction.

If the goal is providing a "Proportional Page
> cache size", why do that in an indirect way?  Have you explored doing
> the same measurement with /proc/$pid/pagemap?  Is it possible with that
> interface?
>
I checked the flags in /proc/kpageflags but have no idea about what 
flags should be used to identify the pagecache. It will be appreciated 
if you could provide some advice.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
