Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28smtp01.in.ibm.com (8.13.1/8.13.1) with ESMTP id m4FH26H7014040
	for <linux-mm@kvack.org>; Thu, 15 May 2008 22:32:06 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m4FH1u8X1462502
	for <linux-mm@kvack.org>; Thu, 15 May 2008 22:31:56 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.13.1/8.13.3) with ESMTP id m4FH26SN029691
	for <linux-mm@kvack.org>; Thu, 15 May 2008 22:32:06 +0530
Message-ID: <482C6C70.2060802@linux.vnet.ibm.com>
Date: Thu, 15 May 2008 22:31:36 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [-mm][PATCH 4/4] Add memrlimit controller accounting and control
 (v4)
References: <20080514130904.24440.23486.sendpatchset@localhost.localdomain> <20080514130951.24440.73671.sendpatchset@localhost.localdomain> <20080514132529.GA25653@balbir.in.ibm.com> <6599ad830805141925mf8a13daq7309148153a3c2df@mail.gmail.com> <20080515061727.GC31115@balbir.in.ibm.com> <6599ad830805142355ifeeb0e2w86ccfd96aa27aea6@mail.gmail.com> <20080515070342.GJ31115@balbir.in.ibm.com> <6599ad830805150039u76c9002cg6c873fd71e687a69@mail.gmail.com> <20080515082553.GK31115@balbir.in.ibm.com> <6599ad830805150828i6b61755dk9ce5213607621af7@mail.gmail.com>
In-Reply-To: <6599ad830805150828i6b61755dk9ce5213607621af7@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Menage <menage@google.com>
Cc: linux-mm@kvack.org, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, Pavel Emelianov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Paul Menage wrote:
> On Thu, May 15, 2008 at 1:25 AM, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>>  >
>>  > But the only *new* cases of taking the mmap_sem that this would
>>  > introduce would be:
>>  >
>>  > - on a failed vm limit charge
>>
>>  Why a failed charge? Aren't we talking of moving all charge/uncharge
>>  under mmap_sem?
>>
> 
> Sorry, I worded that wrongly - I meant "cleaning up a successful
> charge after an expansion fails for other reasons"
> 
> I thought that all the charges and most of the uncharges were already
> under mmap_sem, and it would just be a few of the cleanup paths that
> needed to take it.
> 

OK, that's definitely more meaningful. Thanks for clarifying.

>>  > - when a task moves between two cgroups in the memrlimit hierarchy.
>>  >
>>
>>  Yes, this would nest cgroup_mutex and mmap_sem. Not sure if that would
>>  be a bad side-effect.
>>
> 
> I think it's already nested that way - e.g. the cpusets code can call
> various migration functions (which take mmap_sem) while holding
> cgroup_mutex.
> 
>>  Refactor the code to try and use mmap_sem and see what I come up
>>  with. Basically use mmap_sem for all charge/uncharge operations as
>>  well use mmap_sem in read_mode in the move_task() and
>>  mm_owner_changed() callbacks. That should take care of the race
>>  conditions discussed, unless I missed something.
> 
> Sounds good.
> 

Let me get that done and I'll post the next version.

> Thanks,
> 
> Paul


-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
