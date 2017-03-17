Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id C41076B0038
	for <linux-mm@kvack.org>; Fri, 17 Mar 2017 12:38:00 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id a6so44088822lfa.1
        for <linux-mm@kvack.org>; Fri, 17 Mar 2017 09:38:00 -0700 (PDT)
Received: from vps01.wiesinger.com (vps01.wiesinger.com. [46.36.37.179])
        by mx.google.com with ESMTPS id s16si4737827ljd.259.2017.03.17.09.37.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Mar 2017 09:37:58 -0700 (PDT)
Subject: Re: Still OOM problems with 4.9er/4.10er kernels
References: <20170227090236.GA2789@bbox>
 <20170227094448.GF14029@dhcp22.suse.cz> <20170228051723.GD2702@bbox>
 <20170228081223.GA26792@dhcp22.suse.cz> <20170302071721.GA32632@bbox>
 <feebcc24-2863-1bdf-e586-1ac9648b35ba@wiesinger.com>
 <20170316082714.GC30501@dhcp22.suse.cz>
 <20170316084733.GP802@shells.gnugeneration.com>
 <20170316090844.GG30501@dhcp22.suse.cz>
 <20170316092318.GQ802@shells.gnugeneration.com>
 <20170316093931.GH30501@dhcp22.suse.cz>
From: Gerhard Wiesinger <lists@wiesinger.com>
Message-ID: <a65e4b73-5c97-d915-c79e-7df0771db823@wiesinger.com>
Date: Fri, 17 Mar 2017 17:37:48 +0100
MIME-Version: 1.0
In-Reply-To: <20170316093931.GH30501@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, lkml@pengaru.com
Cc: Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>

On 16.03.2017 10:39, Michal Hocko wrote:
> On Thu 16-03-17 02:23:18, lkml@pengaru.com wrote:
>> On Thu, Mar 16, 2017 at 10:08:44AM +0100, Michal Hocko wrote:
>>> On Thu 16-03-17 01:47:33, lkml@pengaru.com wrote:
>>> [...]
>>>> While on the topic of understanding allocation stalls, Philip Freeman recently
>>>> mailed linux-kernel with a similar report, and in his case there are plenty of
>>>> page cache pages.  It was also a GFP_HIGHUSER_MOVABLE 0-order allocation.
>>> care to point me to the report?
>> http://lkml.iu.edu/hypermail/linux/kernel/1703.1/06360.html
> Thanks. It is gone from my lkml mailbox. Could you CC me (and linux-mm) please?
>   
>>>   
>>>> I'm no MM expert, but it appears a bit broken for such a low-order allocation
>>>> to stall on the order of 10 seconds when there's plenty of reclaimable pages,
>>>> in addition to mostly unused and abundant swap space on SSD.
>>> yes this might indeed signal a problem.
>> Well maybe I missed something obvious that a better informed eye will catch.
> Nothing really obvious. There is indeed a lot of anonymous memory to
> swap out. Almost no pages on file LRU lists (active_file:759
> inactive_file:749) but 158783 total pagecache pages so we have to have a
> lot of pages in the swap cache. I would probably have to see more data
> to make a full picture.
>

Why does the kernel prefer to swapin/out and not use

a.) the free memory?

b.) the buffer/cache?

There is ~100M memory available but kernel swaps all the time ...

Any ideas?

Kernel: 4.9.14-200.fc25.x86_64

top - 17:33:43 up 28 min,  3 users,  load average: 3.58, 1.67, 0.89
Tasks: 145 total,   4 running, 141 sleeping,   0 stopped,   0 zombie
%Cpu(s): 19.1 us, 56.2 sy,  0.0 ni,  4.3 id, 13.4 wa, 2.0 hi,  0.3 si,  
4.7 st
KiB Mem :   230076 total,    61508 free,   123472 used,    45096 buff/cache

procs -----------memory---------- ---swap-- -----io---- -system-- 
------cpu-----
  r  b   swpd   free   buff  cache   si   so    bi    bo in   cs us sy 
id wa st
  3  5 303916  60372    328  43864 27828  200 41420   236 6984 11138 11 
47  6 23 14
  5  4 292852  52904    756  58584 19600  448 48780   540 8088 10528 18 
61  1  7 13
  3  3 288792  49052   1152  65924 4856  576  9824  1100 4324 5720  7 
18  2 64  8
  2  2 283676  54160    716  67604 6332  344 31740   964 3879 5055 12 34 
10 37  7
  3  3 286852  66712    216  53136 28064 4832 56532  4920 9175 12625 10 
55 12 14 10
  2  0 299680  62428    196  53316 36312 13164 54728 13212 16820 25283  
7 56 18 12  7
  1  1 300756  63220    624  58160 17944 1260 24528  1304 5804 9302  3 
22 38 34  3

Thnx.


Ciao,

Gerhard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
