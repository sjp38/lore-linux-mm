Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 23F1D6B0038
	for <linux-mm@kvack.org>; Thu, 28 Sep 2017 11:49:15 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id o77so1977248qke.1
        for <linux-mm@kvack.org>; Thu, 28 Sep 2017 08:49:15 -0700 (PDT)
Received: from rcdn-iport-4.cisco.com (rcdn-iport-4.cisco.com. [173.37.86.75])
        by mx.google.com with ESMTPS id u129si1726137qkc.368.2017.09.28.08.49.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Sep 2017 08:49:13 -0700 (PDT)
Subject: Re: Detecting page cache trashing state
References: <150543458765.3781.10192373650821598320@takondra-t460s>
 <20170915143619.2ifgex2jxck2xt5u@dhcp22.suse.cz>
 <150549651001.4512.15084374619358055097@takondra-t460s>
 <20170918163434.GA11236@cmpxchg.org>
From: "Ruslan Ruslichenko -X (rruslich - GLOBALLOGIC INC at Cisco)"
 <rruslich@cisco.com>
Message-ID: <acbf4417-4ded-fa03-7b8d-34dc0803027c@cisco.com>
Date: Thu, 28 Sep 2017 18:49:07 +0300
MIME-Version: 1.0
In-Reply-To: <20170918163434.GA11236@cmpxchg.org>
Content-Type: multipart/mixed;
 boundary="------------9B27BB3AED4106EF45BCD875"
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Taras Kondratiuk <takondra@cisco.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, xe-linux-external@cisco.com, linux-kernel@vger.kernel.org

This is a multi-part message in MIME format.
--------------9B27BB3AED4106EF45BCD875
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit

Hi Johannes,

Hopefully I was able to rebase the patch on top v4.9.26 (latest 
supported version by us right now)
and test a bit.
The overall idea definitely looks promising, although I have one 
question on usage.
Will it be able to account the time which processes spend on handling 
major page faults
(including fs and iowait time) of refaulting page?

As we have one big application which code space occupies big amount of 
place in page cache,
when the system under heavy memory usage will reclaim some of it, the 
application will
start constantly thrashing. Since it code is placed on squashfs it 
spends whole CPU time
decompressing the pages and seem memdelay counters are not detecting 
this situation.
Here are some counters to indicate this:

19:02:44        CPU     %user     %nice   %system   %iowait %steal     %idle
19:02:45        all      0.00      0.00    100.00      0.00 0.00      0.00

19:02:44     pgpgin/s pgpgout/s   fault/s  majflt/s  pgfree/s pgscank/s 
pgscand/s pgsteal/s    %vmeff
19:02:45     15284.00      0.00    428.00    352.00  19990.00 0.00      
0.00  15802.00      0.00

And as nobody actively allocating memory anymore looks like memdelay 
counters are not
actively incremented:

[:~]$ cat /proc/memdelay
268035776
6.13 5.43 3.58
1.90 1.89 1.26

Just in case, I have attached the v4.9.26 rebased patched.

Also attached the patch with our current solution. In current 
implementation it will mostly
fit to squashfs only thrashing situation as in general case iowait time 
would be major part of
page fault handling thus it need to be accounted too.

Thanks,
Ruslan

On 09/18/2017 07:34 PM, Johannes Weiner wrote:
> Hi Taras,
>
> On Fri, Sep 15, 2017 at 10:28:30AM -0700, Taras Kondratiuk wrote:
>> Quoting Michal Hocko (2017-09-15 07:36:19)
>>> On Thu 14-09-17 17:16:27, Taras Kondratiuk wrote:
>>>> Has somebody faced similar issue? How are you solving it?
>>> Yes this is a pain point for a _long_ time. And we still do not have a
>>> good answer upstream. Johannes has been playing in this area [1].
>>> The main problem is that our OOM detection logic is based on the ability
>>> to reclaim memory to allocate new memory. And that is pretty much true
>>> for the pagecache when you are trashing. So we do not know that
>>> basically whole time is spent refaulting the memory back and forth.
>>> We do have some refault stats for the page cache but that is not
>>> integrated to the oom detection logic because this is really a
>>> non-trivial problem to solve without triggering early oom killer
>>> invocations.
>>>
>>> [1] http://lkml.kernel.org/r/20170727153010.23347-1-hannes@cmpxchg.org
>> Thanks Michal. memdelay looks promising. We will check it.
> Great, I'm obviously interested in more users of it :) Please find
> attached the latest version of the patch series based on v4.13.
>
> It needs a bit more refactoring in the scheduler bits before
> resubmission, but it already contains a couple of fixes and
> improvements since the first version I sent out.
>
> Let me know if you need help rebasing to a different kernel version.


--------------9B27BB3AED4106EF45BCD875
Content-Type: text/x-patch;
 name="0002-mm-sched-memdelay-memory-health-interface-for-system.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename*0="0002-mm-sched-memdelay-memory-health-interface-for-system.pa";
 filename*1="tch"


--------------9B27BB3AED4106EF45BCD875--
