Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f198.google.com (mail-lb0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6743D6B007E
	for <linux-mm@kvack.org>; Thu, 26 May 2016 05:48:45 -0400 (EDT)
Received: by mail-lb0-f198.google.com with SMTP id q17so36589620lbn.3
        for <linux-mm@kvack.org>; Thu, 26 May 2016 02:48:45 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y76si3534208wmd.22.2016.05.26.02.48.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 26 May 2016 02:48:43 -0700 (PDT)
Subject: Re: [PATCH percpu/for-4.7-fixes 2/2] percpu: fix synchronization
 between synchronous map extension and chunk destruction
References: <5713C0AD.3020102@oracle.com>
 <20160417172943.GA83672@ast-mbp.thefacebook.com> <5742F127.6080000@suse.cz>
 <5742F267.3000309@suse.cz> <20160523213501.GA5383@mtj.duckdns.org>
 <57441396.2050607@suse.cz> <20160524153029.GA3354@mtj.duckdns.org>
 <20160524190433.GC3354@mtj.duckdns.org>
 <CAADnVQ+GprFZJkvCKHVN1gmBMO6uORimsNZ4tE-jgPPOcZhCfA@mail.gmail.com>
 <20160525154525.GF3354@mtj.duckdns.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <0613d173-2ff1-a904-9611-0c6fc254f45e@suse.cz>
Date: Thu, 26 May 2016 11:48:41 +0200
MIME-Version: 1.0
In-Reply-To: <20160525154525.GF3354@mtj.duckdns.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Alexei Starovoitov <alexei.starovoitov@gmail.com>
Cc: Sasha Levin <sasha.levin@oracle.com>, Alexei Starovoitov <ast@kernel.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux.com>, Linux-MM layout <linux-mm@kvack.org>, Marco Grassi <marco.gra@gmail.com>, kernel-team@fb.com

On 05/25/2016 05:45 PM, Tejun Heo wrote:
> For non-atomic allocations, pcpu_alloc() can try to extend the area
> map synchronously after dropping pcpu_lock; however, the extension
> wasn't synchronized against chunk destruction and the chunk might get
> freed while extension is in progress.
>
> This patch fixes the bug by putting most of non-atomic allocations
> under pcpu_alloc_mutex to synchronize against pcpu_balance_work which
> is responsible for async chunk management including destruction.
>
> Signed-off-by: Tejun Heo <tj@kernel.org>
> Reported-and-tested-by: Alexei Starovoitov <alexei.starovoitov@gmail.com>
> Reported-by: Vlastimil Babka <vbabka@suse.cz>
> Reported-by: Sasha Levin <sasha.levin@oracle.com>
> Cc: stable@vger.kernel.org # v3.18+
> Fixes: 1a4d76076cda ("percpu: implement asynchronous chunk population")

Didn't spot any problems this time.

Thanks

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
