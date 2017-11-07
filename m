Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id B5350280269
	for <linux-mm@kvack.org>; Tue,  7 Nov 2017 10:55:49 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id r127so2622222itb.4
        for <linux-mm@kvack.org>; Tue, 07 Nov 2017 07:55:49 -0800 (PST)
Received: from resqmta-ch2-02v.sys.comcast.net (resqmta-ch2-02v.sys.comcast.net. [2001:558:fe21:29:69:252:207:34])
        by mx.google.com with ESMTPS id p131si1604448itp.122.2017.11.07.07.55.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Nov 2017 07:55:49 -0800 (PST)
Date: Tue, 7 Nov 2017 09:55:47 -0600 (CST)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH RFC v2 4/4] mm/mempolicy: add nodes_empty check in
 SYSC_migrate_pages
In-Reply-To: <04e4cb50-8cba-58af-1a5e-61e818cffa70@suse.cz>
Message-ID: <alpine.DEB.2.20.1711070948410.19176@nuc-kabylake>
References: <1509099265-30868-1-git-send-email-xieyisheng1@huawei.com> <1509099265-30868-5-git-send-email-xieyisheng1@huawei.com> <dccbeccc-4155-94a8-0e67-b7c28238896d@suse.cz> <bc57f574-92f2-0b69-4717-a1ec7170387c@huawei.com> <d774ecf6-5e7b-e185-85a0-27bf2bcacfb4@suse.cz>
 <alpine.DEB.2.20.1711060926001.9015@nuc-kabylake> <a4f1212f-3903-abbc-772a-1ddee6f7f98b@huawei.com> <alpine.DEB.2.20.1711070851560.18776@nuc-kabylake> <04e4cb50-8cba-58af-1a5e-61e818cffa70@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Yisheng Xie <xieyisheng1@huawei.com>, akpm@linux-foundation.org, mhocko@suse.com, mingo@kernel.org, rientjes@google.com, n-horiguchi@ah.jp.nec.com, salls@cs.ucsb.edu, linux-mm@kvack.org, linux-kernel@vger.kernel.org, tanxiaojun@huawei.com, linux-api@vger.kernel.org, Andi Kleen <ak@linux.intel.com>

On Tue, 7 Nov 2017, Vlastimil Babka wrote:

> > Migrate pages moves the pages of a single process there is no TARGET
> > process.
>
> migrate_pages(2) takes a pid argument
>
> "migrate_pages()  attempts  to  move all pages of the process pid that
> are in memory nodes old_nodes to the memory nodes in new_nodes. "

Ok missed that. Most use cases here are on the current process.

Fundamentally a process can have shared pages outside of the cpuset that
a process is restricted to. Thus I would think that migration to any of
the allowed nodes of the current process that is calling migrate pages
is ok. The caller wants this and the caller has a right to allocate on
these nodes. It would be strange if migrate_pages would allow allocation
outside of the current cpuset.

> > Thus thehe *target* nodes need to be a subset of the current cpu set.

And therefore the above still holds.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
