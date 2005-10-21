Message-ID: <435883B2.2090400@jp.fujitsu.com>
Date: Fri, 21 Oct 2005 14:59:14 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/4] Swap migration V3: Overview
References: <20051020225935.19761.57434.sendpatchset@schroedinger.engr.sgi.com> <20051020160638.58b4d08d.akpm@osdl.org>
In-Reply-To: <20051020160638.58b4d08d.akpm@osdl.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Christoph Lameter <clameter@sgi.com>, kravetz@us.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, magnus.damm@gmail.com, marcelo.tosatti@cyclades.com
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> Christoph Lameter <clameter@sgi.com> wrote:
> 
>>Page migration is also useful for other purposes:
>>
>> 1. Memory hotplug. Migrating processes off a memory node that is going
>>    to be disconnected.
>>
>> 2. Remapping of bad pages. These could be detected through soft ECC errors
>>    and other mechanisms.
> 
> 
> It's only useful for these things if it works with close-to-100% reliability.
> 
> And there are are all sorts of things which will prevent that - mlock,
> ongoing direct-io, hugepages, whatever.
> 
In lhms tree, current status is below: (If I'm wrong, plz fix)
==
For mlock, direct page migration will work fine. try_to_unmap_one()
in -mhp tree has an argument *force* and ignore VM_LOCKED, it's for this.

For direct-io, we have to wait for completion.
The end of I/O is not notified and memory_migrate() is just polling pages.

For hugepages, we'll need hugepage demand paging and more work, I think.
==

When a process migrates to other nodes by hand, it can cooperate with migration
subsystem. So we don't have to be afraid of some special using of memory, in many case.
I think Christoph's approach will work fine.

When it comes to memory-hotplug, arbitrary processes are affected.
It's more difficult.

We should focus on 'process migraion on demand', in this thread.

-- Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
