Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4776A6B025F
	for <linux-mm@kvack.org>; Thu, 26 May 2016 16:48:57 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id e3so41908682wme.3
        for <linux-mm@kvack.org>; Thu, 26 May 2016 13:48:57 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gk7si20773118wjb.5.2016.05.26.13.48.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 26 May 2016 13:48:56 -0700 (PDT)
Subject: Re: [PATCH percpu/for-4.7-fixes 1/2] percpu: fix synchronization
 between chunk->map_extend_work and chunk destruction
References: <20160417172943.GA83672@ast-mbp.thefacebook.com>
 <5742F127.6080000@suse.cz> <5742F267.3000309@suse.cz>
 <20160523213501.GA5383@mtj.duckdns.org> <57441396.2050607@suse.cz>
 <20160524153029.GA3354@mtj.duckdns.org>
 <20160524190433.GC3354@mtj.duckdns.org>
 <CAADnVQ+GprFZJkvCKHVN1gmBMO6uORimsNZ4tE-jgPPOcZhCfA@mail.gmail.com>
 <20160525154419.GE3354@mtj.duckdns.org>
 <ced75777-583e-9444-c59f-6cdeb468f1bf@suse.cz>
 <20160526192154.GC23194@mtj.duckdns.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <63b00b52-6e1f-0c9d-365b-075b821f6487@suse.cz>
Date: Thu, 26 May 2016 22:48:54 +0200
MIME-Version: 1.0
In-Reply-To: <20160526192154.GC23194@mtj.duckdns.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Alexei Starovoitov <ast@kernel.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux.com>, Linux-MM layout <linux-mm@kvack.org>, Marco Grassi <marco.gra@gmail.com>

On 26.5.2016 21:21, Tejun Heo wrote:
> Hello,
> 
> On Thu, May 26, 2016 at 11:19:06AM +0200, Vlastimil Babka wrote:
>>>  	if (is_atomic) {
>>>  		margin = 3;
>>>
>>>  		if (chunk->map_alloc <
>>> -		    chunk->map_used + PCPU_ATOMIC_MAP_MARGIN_LOW &&
>>> -		    pcpu_async_enabled)
>>> -			schedule_work(&chunk->map_extend_work);
>>> +		    chunk->map_used + PCPU_ATOMIC_MAP_MARGIN_LOW) {
>>> +			if (list_empty(&chunk->map_extend_list)) {
> 
>> So why this list_empty condition? Doesn't it deserve a comment then? And
> 
> Because doing list_add() twice corrupts the list.  I'm not sure that
> deserves a comment.  We can do list_move() instead but that isn't
> necessarily better.

Ugh, right, somehow I thought it was testing &pcpu_map_extend_chunks.
My second question was based on the assumption that the list can have only one
item. Sorry about the noise.

>> isn't using a list an overkill in that case?
> 
> That would require rebalance work to scan all chunks whenever it's
> scheduled and if a lot of atomic allocations are taking place, it has
> some possibility to become expensive with a lot of chunks.
> 
> Thanks.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
