Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f178.google.com (mail-ig0-f178.google.com [209.85.213.178])
	by kanga.kvack.org (Postfix) with ESMTP id B4B4B6B0005
	for <linux-mm@kvack.org>; Tue,  8 Mar 2016 02:47:36 -0500 (EST)
Received: by mail-ig0-f178.google.com with SMTP id vs8so42604122igb.1
        for <linux-mm@kvack.org>; Mon, 07 Mar 2016 23:47:36 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id t103si2980786ioe.52.2016.03.07.23.47.35
        for <linux-mm@kvack.org>;
        Mon, 07 Mar 2016 23:47:35 -0800 (PST)
Date: Tue, 8 Mar 2016 16:48:16 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: Suspicious error for CMA stress test
Message-ID: <20160308074816.GA31471@js1304-P5Q-DELUXE>
References: <56D79284.3030009@redhat.com>
 <CAAmzW4PUwoVF+F-BpOZUHhH6YHp_Z8VkiUjdBq85vK6AWVkyPg@mail.gmail.com>
 <56D832BD.5080305@huawei.com>
 <20160304020232.GA12036@js1304-P5Q-DELUXE>
 <20160304043232.GC12036@js1304-P5Q-DELUXE>
 <56D92595.60709@huawei.com>
 <20160304063807.GA13317@js1304-P5Q-DELUXE>
 <56D93ABE.9070406@huawei.com>
 <20160307043442.GB24602@js1304-P5Q-DELUXE>
 <56DD7B20.1020508@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56DD7B20.1020508@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Hanjun Guo <guohanjun@huawei.com>, Laura Abbott <labbott@redhat.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Laura Abbott <lauraa@codeaurora.org>, qiuxishi <qiuxishi@huawei.com>, Catalin Marinas <Catalin.Marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Arnd Bergmann <arnd@arndb.de>, "thunder.leizhen@huawei.com" <thunder.leizhen@huawei.com>, dingtinahong <dingtianhong@huawei.com>, chenjie6@huawei.com, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Mon, Mar 07, 2016 at 01:59:12PM +0100, Vlastimil Babka wrote:
> On 03/07/2016 05:34 AM, Joonsoo Kim wrote:
> >On Fri, Mar 04, 2016 at 03:35:26PM +0800, Hanjun Guo wrote:
> >>>Sad to hear that.
> >>>
> >>>Could you tell me your system's MAX_ORDER and pageblock_order?
> >>>
> >>
> >>MAX_ORDER is 11, pageblock_order is 9, thanks for your help!
> 
> I thought that CMA regions/operations (and isolation IIRC?) were
> supposed to be MAX_ORDER aligned exactly to prevent needing these
> extra checks for buddy merging. So what's wrong?

CMA isolates MAX_ORDER aligned blocks, but, during the process,
partialy isolated block exists. If MAX_ORDER is 11 and
pageblock_order is 9, two pageblocks make up MAX_ORDER
aligned block and I can think following scenario because pageblock
(un)isolation would be done one by one.

(each character means one pageblock. 'C', 'I' means MIGRATE_CMA,
MIGRATE_ISOLATE, respectively.

CC -> IC -> II (Isolation)
II -> CI -> CC (Un-isolation)

If some pages are freed at this intermediate state such as IC or CI,
that page could be merged to the other page that is resident on
different type of pageblock and it will cause wrong freepage count.

If we don't release zone lock during whole isolation process, there
would be no problem and CMA can use that implementation. But,
isolation is used by another feature and I guess it cannot use that
kind of implementation.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
