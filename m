Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9A3FF6B0253
	for <linux-mm@kvack.org>; Fri, 27 Oct 2017 16:19:32 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id l194so5720233qke.22
        for <linux-mm@kvack.org>; Fri, 27 Oct 2017 13:19:32 -0700 (PDT)
Received: from rcdn-iport-6.cisco.com (rcdn-iport-6.cisco.com. [173.37.86.77])
        by mx.google.com with ESMTPS id x40si7354826qtj.258.2017.10.27.13.19.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Oct 2017 13:19:31 -0700 (PDT)
Subject: Re: Detecting page cache trashing state
References: <150543458765.3781.10192373650821598320@takondra-t460s>
 <20170915143619.2ifgex2jxck2xt5u@dhcp22.suse.cz>
 <150549651001.4512.15084374619358055097@takondra-t460s>
 <20170918163434.GA11236@cmpxchg.org>
 <acbf4417-4ded-fa03-7b8d-34dc0803027c@cisco.com>
 <20171025175424.GA14039@cmpxchg.org>
From: "Ruslan Ruslichenko -X (rruslich - GLOBALLOGIC INC at Cisco)"
 <rruslich@cisco.com>
Message-ID: <d7bc14d7-5ae4-f16d-da38-2bc36d9deae8@cisco.com>
Date: Fri, 27 Oct 2017 23:19:02 +0300
MIME-Version: 1.0
In-Reply-To: <20171025175424.GA14039@cmpxchg.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Taras Kondratiuk <takondra@cisco.com>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, xe-linux-external@cisco.com, linux-kernel@vger.kernel.org

Hi Johannes,

On 10/25/2017 08:54 PM, Johannes Weiner wrote:
> Hi Ruslan,
>
> sorry about the delayed response, I missed the new activity in this
> older thread.
>
> On Thu, Sep 28, 2017 at 06:49:07PM +0300, Ruslan Ruslichenko -X (rruslich - GLOBALLOGIC INC at Cisco) wrote:
>> Hi Johannes,
>>
>> Hopefully I was able to rebase the patch on top v4.9.26 (latest supported
>> version by us right now)
>> and test a bit.
>> The overall idea definitely looks promising, although I have one question on
>> usage.
>> Will it be able to account the time which processes spend on handling major
>> page faults
>> (including fs and iowait time) of refaulting page?
> That's the main thing it should measure! :)
>
> The lock_page() and wait_on_page_locked() calls are where iowaits
> happen on a cache miss. If those are refaults, they'll be counted.
>
>> As we have one big application which code space occupies big amount of place
>> in page cache,
>> when the system under heavy memory usage will reclaim some of it, the
>> application will
>> start constantly thrashing. Since it code is placed on squashfs it spends
>> whole CPU time
>> decompressing the pages and seem memdelay counters are not detecting this
>> situation.
>> Here are some counters to indicate this:
>>
>> 19:02:44        CPU     %user     %nice   %system   %iowait %steal     %idle
>> 19:02:45        all      0.00      0.00    100.00      0.00 0.00      0.00
>>
>> 19:02:44     pgpgin/s pgpgout/s   fault/s  majflt/s  pgfree/s pgscank/s
>> pgscand/s pgsteal/s    %vmeff
>> 19:02:45     15284.00      0.00    428.00    352.00  19990.00 0.00      0.00
>> 15802.00      0.00
>>
>> And as nobody actively allocating memory anymore looks like memdelay
>> counters are not
>> actively incremented:
>>
>> [:~]$ cat /proc/memdelay
>> 268035776
>> 6.13 5.43 3.58
>> 1.90 1.89 1.26
> How does it correlate with /proc/vmstat::workingset_activate during
> that time? It only counts thrashing time of refaults it can actively
> detect.
The workingset counters are growing quite actively too. Here are
some numbers per second:

workingset_refault   8201
workingset_activate   389
workingset_restore   187
workingset_nodereclaim   313

> Btw, how many CPUs does this system have? There is a bug in this
> version on how idle time is aggregated across multiple CPUs. The error
> compounds with the number of CPUs in the system.
The system has 2 CPU cores.
> I'm attaching 3 bugfixes that go on top of what you have. There might
> be some conflicts, but they should be minor variable naming issues.
>
I will test with your patches and get back to you.

Thanks,
Ruslan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
