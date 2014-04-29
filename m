Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id E3EBD6B003A
	for <linux-mm@kvack.org>; Tue, 29 Apr 2014 04:03:02 -0400 (EDT)
Received: by mail-pd0-f182.google.com with SMTP id v10so2403398pde.13
        for <linux-mm@kvack.org>; Tue, 29 Apr 2014 01:03:02 -0700 (PDT)
Received: from e28smtp04.in.ibm.com (e28smtp04.in.ibm.com. [122.248.162.4])
        by mx.google.com with ESMTPS id ps1si12128829pbc.293.2014.04.29.01.03.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 29 Apr 2014 01:03:02 -0700 (PDT)
Received: from /spool/local
	by e28smtp04.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Tue, 29 Apr 2014 13:32:55 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 2F3903940048
	for <linux-mm@kvack.org>; Tue, 29 Apr 2014 13:32:52 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s3T82k3H2752918
	for <linux-mm@kvack.org>; Tue, 29 Apr 2014 13:32:46 +0530
Received: from d28av04.in.ibm.com (localhost [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s3T82p8N009875
	for <linux-mm@kvack.org>; Tue, 29 Apr 2014 13:32:51 +0530
Message-ID: <535F5C7F.3000608@linux.vnet.ibm.com>
Date: Tue, 29 Apr 2014 13:32:07 +0530
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [BUG] kernel BUG at mm/vmacache.c:85!
References: <535EA976.1080402@linux.vnet.ibm.com> <CA+55aFxgW0fS=6xJsKP-WiOUw=aiCEvydj+pc+zDF8Pvn4v+Jw@mail.gmail.com> <CA+55aFzXAnTzfNL-bfUFnu15=4Z9HNigoo-XyjmwRvAWX_xz0A@mail.gmail.com> <1398724754.25549.35.camel@buesod1.americas.hpqcorp.net>
In-Reply-To: <1398724754.25549.35.camel@buesod1.americas.hpqcorp.net>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Hugh Dickins <hughd@google.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>

On 04/29/2014 04:09 AM, Davidlohr Bueso wrote:
> Adding Oleg.
> 
> On Mon, 2014-04-28 at 14:55 -0700, Linus Torvalds wrote:
>> On Mon, Apr 28, 2014 at 2:20 PM, Linus Torvalds
>> <torvalds@linux-foundation.org> wrote:
>>>
>>> That said, the bug does seem to be that some path doesn't invalidate
>>> the vmacache sufficiently, or something inserts a vmacache entry into
>>> the current process when looking up a remote process or whatever.
>>> Davidlohr, ideas?
>>
>> Maybe we missed some use_mm() call. That will change the current mm
>> without flushing the vma cache. The code considers kernel threads to
>> be bad targets for vma caching for this reason (and perhaps others),
>> but maybe we missed something.
>>
>> I wonder if we should just invalidate the vma cache in use_mm(), and
>> remote the "kernel tasks are special" check.
>>
>> Srivatsa, are you doing something peculiar on that system that would
>> trigger this? I see some kdump failures in the log, anything else?
> 
> Is this perhaps a KVM guest? fwiw I see CONFIG_KVM_ASYNC_PF=y which is a
> user of use_mm().
> 

No, this is just running baremetal on x86. I copied the kernel config
of a distro kernel and reused it.

Regards,
Srivatsa S. Bhat

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
