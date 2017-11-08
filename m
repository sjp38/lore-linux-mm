Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id B7EBB4403DC
	for <linux-mm@kvack.org>; Tue,  7 Nov 2017 20:49:34 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id 189so4161261iow.14
        for <linux-mm@kvack.org>; Tue, 07 Nov 2017 17:49:34 -0800 (PST)
Received: from szxga04-in.huawei.com (szxga04-in.huawei.com. [45.249.212.190])
        by mx.google.com with ESMTPS id 72si2534900itg.141.2017.11.07.17.49.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 07 Nov 2017 17:49:33 -0800 (PST)
Subject: Re: [PATCH RFC v2 4/4] mm/mempolicy: add nodes_empty check in
 SYSC_migrate_pages
References: <1509099265-30868-1-git-send-email-xieyisheng1@huawei.com>
 <1509099265-30868-5-git-send-email-xieyisheng1@huawei.com>
 <dccbeccc-4155-94a8-0e67-b7c28238896d@suse.cz>
 <bc57f574-92f2-0b69-4717-a1ec7170387c@huawei.com>
 <d774ecf6-5e7b-e185-85a0-27bf2bcacfb4@suse.cz>
 <alpine.DEB.2.20.1711060926001.9015@nuc-kabylake>
 <a4f1212f-3903-abbc-772a-1ddee6f7f98b@huawei.com>
 <alpine.DEB.2.20.1711070851560.18776@nuc-kabylake>
 <04e4cb50-8cba-58af-1a5e-61e818cffa70@suse.cz>
 <alpine.DEB.2.20.1711070948410.19176@nuc-kabylake>
From: Yisheng Xie <xieyisheng1@huawei.com>
Message-ID: <4b08f1e9-5449-6ea2-e7da-65fe5f678683@huawei.com>
Date: Wed, 8 Nov 2017 09:38:36 +0800
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1711070948410.19176@nuc-kabylake>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>, Vlastimil Babka <vbabka@suse.cz>
Cc: akpm@linux-foundation.org, mhocko@suse.com, mingo@kernel.org, rientjes@google.com, n-horiguchi@ah.jp.nec.com, salls@cs.ucsb.edu, linux-mm@kvack.org, linux-kernel@vger.kernel.org, tanxiaojun@huawei.com, linux-api@vger.kernel.org, Andi Kleen <ak@linux.intel.com>

Hi Christopher,

On 2017/11/7 23:55, Christopher Lameter wrote:
> On Tue, 7 Nov 2017, Vlastimil Babka wrote:
> 
>>> Migrate pages moves the pages of a single process there is no TARGET
>>> process.
>>
>> migrate_pages(2) takes a pid argument
>>
>> "migrate_pages()  attempts  to  move all pages of the process pid that
>> are in memory nodes old_nodes to the memory nodes in new_nodes. "
> 
> Ok missed that. Most use cases here are on the current process.

Yeah, so most case current process is the same as target process.
But maybe I still miss someting, see below:

> 
> Fundamentally a process can have shared pages outside of the cpuset that
> a process is restricted to. Thus I would think that migration to any of
> the allowed nodes of the current process that is calling migrate pages
> is ok. The caller wants this and the caller has a right to allocate on
> these nodes. It would be strange if migrate_pages would allow allocation
> outside of the current cpuset.
> 
>>> Thus thehe *target* nodes need to be a subset of the current cpu set.
> 
> And therefore the above still holds.

Another case is current process is *not* the same as target process, and
when current process try to migrate pages of target process from old_nodes
to new_nodes, the new_nodes should be a subset of target process cpuset.
CAP_SYS_NICE will insure that current process have the privilege, and will
not overwrite the restriction of target process cpuset.

However, for the current cpuset restriction, as manpage says :
  EINVAL... Or, _none_ of the node IDs specified by new_nodes are
  on-line and allowed by the process's current cpuset context, or none of
  the specified nodes contain memory.

So for current cpuset restriction, an intersection check should be enough
instead of subset? And it will also make sure migrate_pages will not
allocate pages outside of the current cpuset.

> 
> .
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
