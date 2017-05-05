Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2F8E26B0038
	for <linux-mm@kvack.org>; Fri,  5 May 2017 04:55:35 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id 44so4750481wry.5
        for <linux-mm@kvack.org>; Fri, 05 May 2017 01:55:35 -0700 (PDT)
Received: from lhrrgout.huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id e203si1978908wmd.109.2017.05.05.01.55.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 05 May 2017 01:55:33 -0700 (PDT)
Subject: Re: RFC v2: post-init-read-only protection for data allocated
 dynamically
References: <9200d87d-33b6-2c70-0095-e974a30639fd@huawei.com>
 <70a9d4db-f374-de45-413b-65b74c59edcb@intel.com>
 <b7bb1884-3125-5c98-f1fe-53b974454ce2@huawei.com>
 <210752b7-1cbf-2ac3-9f9a-62536dfd24d8@intel.com>
From: Igor Stoppa <igor.stoppa@huawei.com>
Message-ID: <9d8054dc-97de-2836-7706-2e5e738e2902@huawei.com>
Date: Fri, 5 May 2017 11:53:22 +0300
MIME-Version: 1.0
In-Reply-To: <210752b7-1cbf-2ac3-9f9a-62536dfd24d8@intel.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 04/05/17 17:30, Dave Hansen wrote:
> On 05/04/2017 01:17 AM, Igor Stoppa wrote:
>> Or, let me put it differently: my goal is to not fracture more pages
>> than needed.
>> It will probably require some profiling to figure out what is the
>> ballpark of the memory footprint.
> 
> This is easy to say, but hard to do.  What if someone loads a different
> set of LSMs, or uses a very different configuration?  How could this
> possibly work generally without vastly over-reserving in most cases?

I am probably making some implicit assumptions.
Let me try to make them explicit and let's see if they survive public
scrutiny, and btw while writing it, I see that it probably won't :-S

Observations
------------

* The memory that might need sealing is less or equal to the total
  r/w memory - whatever that might be.

* In practice only a subset of the r/w memory will qualify for sealing.

* The over-reserving might be abysmal, in terms of percentage of
  actually used memory, but it might not affect too much the system, in
  absolute terms.

* On my machine (Ubuntu 16.10 64bit):

  ~$ dmesg |grep Memory
  [    0.000000] Memory: 32662956K/33474640K available (8848K kernel
  code, 1441K rwdata, 3828K rodata, 1552K init, 1296K bss, 811684K
  reserved, 0K cma-reserved)

* This is the memory at boot, I am not sure what would be the right way
to get the same info at runtime.


Speculations
------------

* after loading enough modules, the rwdata is 2-3 times larger

* the amount of rwdata that can be converted to rodata is 50%;
  this is purely a working assumption I am making, as I have no
  measurement yet and needs to be revised.

* on a system like mine, it would mean 2-3 MB


Conclusions
-----------

* 2-3 MB with possibly 50% of utilization might be an acceptable
compromise for a distro - as user I probably wouldn't mind too much.

* if someone is not happy with the distro defaults, every major distro
provides means to reconfigure and rebuild its kernel (the expectation is
that the only distro users who are not happy are those who would
probably reconfigure the kernel anyway, like a data center)

* non distro-users, like mobile, embedded, IoT, etc would do
optimizations and tweaking also without this feature mandating it.

--

In my defense, I can only say that my idea for this feature was to make
it as opt-in, where if one chooses to enable it, it is known upfront
what it will entail.
Now we are talking about distros, with the feature enabled by default.

TBH I am not sure there even is a truly generic solution, because we are
talking about dynamically allocated data, where the amount is not known
upfront (if it was, probably the data would be static).


I have the impression that it's a situation like:
- efficient memory occupation
- no need for profiling
- non fragmented pages

Choose 2 of them.


Of course, there might be a better way, but I haven't found it yet,
other than the usual way out: make it a command line option and let the
unhappy user modify the command line that the bootloader passes to the
kernel.

[...]

> I'm starting with the assumption that a new zone isn't feasible. :)

I really have no bias: I have a problem and I am trying to solve it.
I think the improvement could be useful also for others.

If the problem can be solved in a better way than what I proposed, it is
still good for me.

---
igor

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
