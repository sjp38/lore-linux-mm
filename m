Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f172.google.com (mail-yw0-f172.google.com [209.85.161.172])
	by kanga.kvack.org (Postfix) with ESMTP id CE5486B0005
	for <linux-mm@kvack.org>; Tue,  8 Mar 2016 05:48:27 -0500 (EST)
Received: by mail-yw0-f172.google.com with SMTP id g3so8343066ywa.3
        for <linux-mm@kvack.org>; Tue, 08 Mar 2016 02:48:27 -0800 (PST)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id 82si733578yba.150.2016.03.08.02.48.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 08 Mar 2016 02:48:27 -0800 (PST)
Message-ID: <56DEAD3D.5090706@huawei.com>
Date: Tue, 8 Mar 2016 18:45:17 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: Suspicious error for CMA stress test
References: <56D79284.3030009@redhat.com> <CAAmzW4PUwoVF+F-BpOZUHhH6YHp_Z8VkiUjdBq85vK6AWVkyPg@mail.gmail.com> <56D832BD.5080305@huawei.com> <20160304020232.GA12036@js1304-P5Q-DELUXE> <20160304043232.GC12036@js1304-P5Q-DELUXE> <56D92595.60709@huawei.com> <20160304063807.GA13317@js1304-P5Q-DELUXE> <56D93ABE.9070406@huawei.com> <20160307043442.GB24602@js1304-P5Q-DELUXE> <56DD7B20.1020508@suse.cz> <20160308074816.GA31471@js1304-P5Q-DELUXE>
In-Reply-To: <20160308074816.GA31471@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Hanjun Guo <guohanjun@huawei.com>, Laura Abbott <labbott@redhat.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Laura Abbott <lauraa@codeaurora.org>, Catalin Marinas <Catalin.Marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Arnd Bergmann <arnd@arndb.de>, "thunder.leizhen@huawei.com" <thunder.leizhen@huawei.com>, dingtinahong <dingtianhong@huawei.com>, chenjie6@huawei.com, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 2016/3/8 15:48, Joonsoo Kim wrote:

> On Mon, Mar 07, 2016 at 01:59:12PM +0100, Vlastimil Babka wrote:
>> On 03/07/2016 05:34 AM, Joonsoo Kim wrote:
>>> On Fri, Mar 04, 2016 at 03:35:26PM +0800, Hanjun Guo wrote:
>>>>> Sad to hear that.
>>>>>
>>>>> Could you tell me your system's MAX_ORDER and pageblock_order?
>>>>>
>>>>
>>>> MAX_ORDER is 11, pageblock_order is 9, thanks for your help!
>>
>> I thought that CMA regions/operations (and isolation IIRC?) were
>> supposed to be MAX_ORDER aligned exactly to prevent needing these
>> extra checks for buddy merging. So what's wrong?
> 
> CMA isolates MAX_ORDER aligned blocks, but, during the process,
> partialy isolated block exists. If MAX_ORDER is 11 and
> pageblock_order is 9, two pageblocks make up MAX_ORDER
> aligned block and I can think following scenario because pageblock
> (un)isolation would be done one by one.
> 
> (each character means one pageblock. 'C', 'I' means MIGRATE_CMA,
> MIGRATE_ISOLATE, respectively.
> 

Hi Joonsoo,

> CC -> IC -> II (Isolation)

> II -> CI -> CC (Un-isolation)
> 
> If some pages are freed at this intermediate state such as IC or CI,
> that page could be merged to the other page that is resident on
> different type of pageblock and it will cause wrong freepage count.
> 

Isolation will appear when do cma alloc, so there are two following threads.

C(free)C(used) -> start_isolate_page_range -> I(free)C(used) -> I(free)I(someone free it) -> undo_isolate_page_range -> C(free)C(free)
so free cma is 2M -> 0M -> 0M -> 4M, the increased 2M was freed by someone.
C(used)C(free) -> start_isolate_page_range -> C(used)I(free) -> C(someone free it)C(free) -> undo_isolate_page_range -> C(free)C(free)
so free cma is 2M -> 0M -> 4M -> 4M, the increased 2M was freed by someone.

so these two cases are no problem, right?

Thanks,
Xishi Qiu

> If we don't release zone lock during whole isolation process, there
> would be no problem and CMA can use that implementation. But,
> isolation is used by another feature and I guess it cannot use that
> kind of implementation.
> 
> Thanks.
> 
> 
> .
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
