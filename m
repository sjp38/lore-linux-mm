Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 24BFF6B0253
	for <linux-mm@kvack.org>; Fri, 27 Oct 2017 16:30:19 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id k31so5407252qta.22
        for <linux-mm@kvack.org>; Fri, 27 Oct 2017 13:30:19 -0700 (PDT)
Received: from rcdn-iport-3.cisco.com (rcdn-iport-3.cisco.com. [173.37.86.74])
        by mx.google.com with ESMTPS id c16si4017360qkj.104.2017.10.27.13.30.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Oct 2017 13:30:18 -0700 (PDT)
Subject: Re: Detecting page cache trashing state
References: <150543458765.3781.10192373650821598320@takondra-t460s>
 <20170915143619.2ifgex2jxck2xt5u@dhcp22.suse.cz>
 <150549651001.4512.15084374619358055097@takondra-t460s>
 <20170918163434.GA11236@cmpxchg.org>
 <acbf4417-4ded-fa03-7b8d-34dc0803027c@cisco.com>
 <CAOaiJ-=jA-PKYFngt+4W-fJOUo-NxkvJguRDXjiDnKJ+9_00pw@mail.gmail.com>
From: "Ruslan Ruslichenko -X (rruslich - GLOBALLOGIC INC at Cisco)"
 <rruslich@cisco.com>
Message-ID: <fa511270-71cf-c0fe-2c78-82c8e15f49b8@cisco.com>
Date: Fri, 27 Oct 2017 23:29:55 +0300
MIME-Version: 1.0
In-Reply-To: <CAOaiJ-=jA-PKYFngt+4W-fJOUo-NxkvJguRDXjiDnKJ+9_00pw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: vinayak menon <vinayakm.list@gmail.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Taras Kondratiuk <takondra@cisco.com>, Michal Hocko <mhocko@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, xe-linux-external@cisco.com, linux-kernel@vger.kernel.org

On 10/26/2017 06:53 AM, vinayak menon wrote:
> On Thu, Sep 28, 2017 at 9:19 PM, Ruslan Ruslichenko -X (rruslich -
> GLOBALLOGIC INC at Cisco) <rruslich@cisco.com> wrote:
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
>>
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
>>
>> Just in case, I have attached the v4.9.26 rebased patched.
>>
> Looks like this 4.9 version does not contain the accounting in lock_page.

In v4.9 there is no wait_on_page_bit_common(), thus accounting moved to
wait_on_page_bit(_killable|_killable_timeout).
Related functionality around lock_page_or_retry() seem to be mostly the 
same in v4.9.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
