Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f52.google.com (mail-yh0-f52.google.com [209.85.213.52])
	by kanga.kvack.org (Postfix) with ESMTP id 25A436B0037
	for <linux-mm@kvack.org>; Wed,  4 Dec 2013 11:46:19 -0500 (EST)
Received: by mail-yh0-f52.google.com with SMTP id i72so11330868yha.25
        for <linux-mm@kvack.org>; Wed, 04 Dec 2013 08:46:18 -0800 (PST)
Received: from bear.ext.ti.com (bear.ext.ti.com. [192.94.94.41])
        by mx.google.com with ESMTPS id s26si27353035yho.114.2013.12.04.08.46.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 04 Dec 2013 08:46:18 -0800 (PST)
Message-ID: <529F5C55.1020707@ti.com>
Date: Wed, 4 Dec 2013 11:46:13 -0500
From: Santosh Shilimkar <santosh.shilimkar@ti.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 08/23] mm/memblock: Add memblock memory allocation
 apis
References: <1386037658-3161-1-git-send-email-santosh.shilimkar@ti.com> <1386037658-3161-9-git-send-email-santosh.shilimkar@ti.com> <20131203232445.GX8277@htj.dyndns.org> <529F5047.50309@ti.com> <20131204160730.GQ3158@htj.dyndns.org>
In-Reply-To: <20131204160730.GQ3158@htj.dyndns.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Yinghai Lu <yinghai@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Grygorii Strashko <grygorii.strashko@ti.com>

On Wednesday 04 December 2013 11:07 AM, Tejun Heo wrote:
> Hello,
> 
> On Wed, Dec 04, 2013 at 10:54:47AM -0500, Santosh Shilimkar wrote:
>> Well as you know there are architectures still using bootmem even after
>> this series. Changing MAX_NUMNODES to NUMA_NO_NODE is too invasive and
>> actually should be done in a separate series. As commented, the best
>> time to do that would be when all remaining architectures moves to
>> memblock.
>>
>> Just to give you perspective, look at the patch end of the email which
>> Grygorrii cooked up. It doesn't cover all the users of MAX_NUMNODES
>> and we are bot even sure whether the change is correct and its
>> impact on the code which we can't even tests. I would really want to
>> avoid touching all the architectures and keep the scope of the series
>> to core code as we aligned initially.
>>
>> May be you have better idea to handle this change so do
>> let us know how to proceed with it. With such a invasive change the
>> $subject series can easily get into circles again :-(
> 
> But we don't have to use MAX_NUMNODES for the new interface, no?  Or
> do you think that it'd be more confusing because it ends up mixing the
> two?  
The issue is memblock code already using MAX_NUMNODES. Please
look at __next_free_mem_range() and __next_free_mem_range_rev().
The new API use the above apis and hence use MAX_NUMNODES. If the
usage of these constant was consistent across bootmem and memblock
then we wouldn't have had the whole confusion.

It kinda really bothers me this patchset is expanding the usage
> of the wrong constant with only very far-out plan to fix that.  All
> archs converting to nobootmem will take a *long* time, that is, if
> that happens at all.  I don't really care about the order of things
> happening but "this is gonna be fixed when everyone moves off
> MAX_NUMNODES" really isn't good enough.
> 
Fair enough though the patchset continue to use the constant
which is already used by few memblock APIs ;-)

If we can fix the __next_free_mem_range() and __next_free_mem_range_rev()
to not use MAX_NUMNODES then we can potentially avoid the wrong
usage of constant.

regards,
Santosh




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
