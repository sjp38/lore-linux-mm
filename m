Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 99AA96B00B9
	for <linux-mm@kvack.org>; Tue, 11 Nov 2014 10:23:12 -0500 (EST)
Received: by mail-pd0-f179.google.com with SMTP id g10so10332195pdj.10
        for <linux-mm@kvack.org>; Tue, 11 Nov 2014 07:23:12 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id f4si14211469pdc.126.2014.11.11.07.23.10
        for <linux-mm@kvack.org>;
        Tue, 11 Nov 2014 07:23:11 -0800 (PST)
Message-ID: <546229D2.6080202@intel.com>
Date: Tue, 11 Nov 2014 07:22:58 -0800
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH] proc/smaps: add proportional size of anonymous page
References: <1415349088-24078-1-git-send-email-xiaokang.qin@intel.com> <545D3AFB.1080308@intel.com> <6212C327DC2094488C1AAAD903AF062B01BCE1E6@SHSMSX104.ccr.corp.intel.com> <5460EFC9.7060906@intel.com> <54621FDF.8090304@intel.com>
In-Reply-To: <54621FDF.8090304@intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xiaokang <xiaokang.qin@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "Yin, Fengwei" <fengwei.yin@intel.com>

On 11/11/2014 06:40 AM, Xiaokang wrote:
> On 11/11/2014 01:03 AM, Dave Hansen wrote:
>> I'll agree that this definitely provides a bit of data that we didn't
>> have before, albeit a fairly obscure one.
>>
>> But, what's the goal of this patch?  Why are you doing this?  Was there
>> some application whose behavior you were not able to explain before, but
>> can after this patch?
> 
> Under Android, when user switches the application the previous
> application will not exit but switch to background so that next time
> this application could be resumed to foreground very quickly.
> So there may be many applications running at background and Android
> introduces lowmemory killer to kill processes to free memory according
> to oom_adj when memory is short. Some processes with high value of
> oom_adj will be killed first like the background running non-critical
> application. The memory used by these processes could be treated as
> "free" because it could be freed by killing. Hence under Android the
> "free" RAM is composed of: 1) memory using by non-critical application
> that could be killed easily, 2) page cache, 3) physical free page. We
> are using sum of Pss in smaps to measure the process consumed memory for
> 1) and get the info for 2) 3) from /proc/meminfo. Then we have the
> problem that file based memory will be double accounted in 1) and 2). To
> mitigate the double accounting issue here, we need to know the double
> accounting part - proportional page cache size, and do the deduction.

I see what you're trying to do, but I'm not convinced your approach is
effective.  Here's why:

The end goal is to say, for a given process, "If I kill $PID, I get back
X kB of memory."  You get back nothing for page cache, so you want to
subtract it out of the measurement.  You want to account for Anonymous
memory which you *do* get back, but you unfortunately *ALSO* get nothing
back for a shared anonymous page when you kill a single process.  You
need to kill *all* of the things sharing it.  If one of the things
sharing it is one of those critical applications, then you really can't
free it no matter how many non-critical apps you kill.

Let's also see some data.  How much of the memory on a system is
consumed by these pages?  How imprecise *is* the current method and how
much more precise does this make the Android OOM kills?

I think there also needs to be some level of root-cause analysis done
here.  These pages can only happen when you do:

	1. mmap(/some/file, MAP_PRIVATE);
	2. write to mmap()
	3. fork()
	4. run forever in child and never write again, and never exec()

Maybe the zygote thingy needs to be more aggressive about unmapping
things a child would never use.  Or, maybe it needs to set MADV_DONTFORK
on some things.

> If the goal is providing a "Proportional Page
>> cache size", why do that in an indirect way?  Have you explored doing
>> the same measurement with /proc/$pid/pagemap?  Is it possible with that
>> interface?
>>
> I checked the flags in /proc/kpageflags but have no idea about what
> flags should be used to identify the pagecache. It will be appreciated
> if you could provide some advice.

See Documentation/vm/pagemap.txt

If it is !ANON the it is page cache.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
