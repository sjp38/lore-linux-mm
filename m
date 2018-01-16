Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 620426B0038
	for <linux-mm@kvack.org>; Tue, 16 Jan 2018 08:24:54 -0500 (EST)
Received: by mail-qt0-f199.google.com with SMTP id b26so12101674qtb.18
        for <linux-mm@kvack.org>; Tue, 16 Jan 2018 05:24:54 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id v25si2200233qkv.286.2018.01.16.05.24.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jan 2018 05:24:53 -0800 (PST)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w0GDOS3p087399
	for <linux-mm@kvack.org>; Tue, 16 Jan 2018 08:24:52 -0500
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2fhfb68gx5-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 16 Jan 2018 08:24:51 -0500
Received: from localhost
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Tue, 16 Jan 2018 13:24:49 -0000
Subject: Re: [PATCH v6 18/24] mm: Try spin lock in speculative path
References: <1515777968-867-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1515777968-867-19-git-send-email-ldufour@linux.vnet.ibm.com>
 <20180112181840.GA7590@bombadil.infradead.org>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Date: Tue, 16 Jan 2018 14:24:39 +0100
MIME-Version: 1.0
In-Reply-To: <20180112181840.GA7590@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <fd55ce33-2d7d-2613-7483-b6e2764e8865@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, sergey.senozhatsky.work@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

On 12/01/2018 19:18, Matthew Wilcox wrote:
> On Fri, Jan 12, 2018 at 06:26:02PM +0100, Laurent Dufour wrote:
>> There is a deadlock when a CPU is doing a speculative page fault and
>> another one is calling do_unmap().
>>
>> The deadlock occurred because the speculative path try to spinlock the
>> pte while the interrupt are disabled. When the other CPU in the
>> unmap's path has locked the pte then is waiting for all the CPU to
>> invalidate the TLB. As the CPU doing the speculative fault have the
>> interrupt disable it can't invalidate the TLB, and can't get the lock.
>>
>> Since we are in a speculative path, we can race with other mm action.
>> So let assume that the lock may not get acquired and fail the
>> speculative page fault.
> 
> It seems like you introduced this bug in the previous patch, and now
> you're fixing it in this patch?  Why not merge the two?

You're right this is a fix from the previous patch. Initially my idea was
to keep the original Peter's patch as is, but sounds that this is not a
good idea.
I'll merge it in the previous one.

Thanks,
Laurent.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
