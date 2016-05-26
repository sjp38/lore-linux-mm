Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 71D316B0253
	for <linux-mm@kvack.org>; Thu, 26 May 2016 15:21:57 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id o14so33634996qke.3
        for <linux-mm@kvack.org>; Thu, 26 May 2016 12:21:57 -0700 (PDT)
Received: from mail-yw0-x233.google.com (mail-yw0-x233.google.com. [2607:f8b0:4002:c05::233])
        by mx.google.com with ESMTPS id h4si8639046ybb.133.2016.05.26.12.21.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 May 2016 12:21:56 -0700 (PDT)
Received: by mail-yw0-x233.google.com with SMTP id h19so86144256ywc.0
        for <linux-mm@kvack.org>; Thu, 26 May 2016 12:21:56 -0700 (PDT)
Date: Thu, 26 May 2016 15:21:54 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH percpu/for-4.7-fixes 1/2] percpu: fix synchronization
 between chunk->map_extend_work and chunk destruction
Message-ID: <20160526192154.GC23194@mtj.duckdns.org>
References: <20160417172943.GA83672@ast-mbp.thefacebook.com>
 <5742F127.6080000@suse.cz>
 <5742F267.3000309@suse.cz>
 <20160523213501.GA5383@mtj.duckdns.org>
 <57441396.2050607@suse.cz>
 <20160524153029.GA3354@mtj.duckdns.org>
 <20160524190433.GC3354@mtj.duckdns.org>
 <CAADnVQ+GprFZJkvCKHVN1gmBMO6uORimsNZ4tE-jgPPOcZhCfA@mail.gmail.com>
 <20160525154419.GE3354@mtj.duckdns.org>
 <ced75777-583e-9444-c59f-6cdeb468f1bf@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ced75777-583e-9444-c59f-6cdeb468f1bf@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Alexei Starovoitov <ast@kernel.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux.com>, Linux-MM layout <linux-mm@kvack.org>, Marco Grassi <marco.gra@gmail.com>

Hello,

On Thu, May 26, 2016 at 11:19:06AM +0200, Vlastimil Babka wrote:
> >  	if (is_atomic) {
> >  		margin = 3;
> > 
> >  		if (chunk->map_alloc <
> > -		    chunk->map_used + PCPU_ATOMIC_MAP_MARGIN_LOW &&
> > -		    pcpu_async_enabled)
> > -			schedule_work(&chunk->map_extend_work);
> > +		    chunk->map_used + PCPU_ATOMIC_MAP_MARGIN_LOW) {
> > +			if (list_empty(&chunk->map_extend_list)) {

> So why this list_empty condition? Doesn't it deserve a comment then? And

Because doing list_add() twice corrupts the list.  I'm not sure that
deserves a comment.  We can do list_move() instead but that isn't
necessarily better.

> isn't using a list an overkill in that case?

That would require rebalance work to scan all chunks whenever it's
scheduled and if a lot of atomic allocations are taking place, it has
some possibility to become expensive with a lot of chunks.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
