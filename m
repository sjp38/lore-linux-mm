Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 942186B003A
	for <linux-mm@kvack.org>; Tue, 29 Apr 2014 04:00:40 -0400 (EDT)
Received: by mail-pd0-f178.google.com with SMTP id fp1so4520052pdb.23
        for <linux-mm@kvack.org>; Tue, 29 Apr 2014 01:00:40 -0700 (PDT)
Received: from e28smtp08.in.ibm.com (e28smtp08.in.ibm.com. [122.248.162.8])
        by mx.google.com with ESMTPS id hp1si12118801pad.98.2014.04.29.01.00.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 29 Apr 2014 01:00:39 -0700 (PDT)
Received: from /spool/local
	by e28smtp08.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Tue, 29 Apr 2014 13:30:34 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 0ECC3E0053
	for <linux-mm@kvack.org>; Tue, 29 Apr 2014 13:30:50 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s3T80QqZ60948720
	for <linux-mm@kvack.org>; Tue, 29 Apr 2014 13:30:26 +0530
Received: from d28av04.in.ibm.com (localhost [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s3T80U9f027235
	for <linux-mm@kvack.org>; Tue, 29 Apr 2014 13:30:30 +0530
Message-ID: <535F5BF1.6020405@linux.vnet.ibm.com>
Date: Tue, 29 Apr 2014 13:29:45 +0530
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [BUG] kernel BUG at mm/vmacache.c:85!
References: <535EA976.1080402@linux.vnet.ibm.com> <CA+55aFxgW0fS=6xJsKP-WiOUw=aiCEvydj+pc+zDF8Pvn4v+Jw@mail.gmail.com> <CA+55aFzXAnTzfNL-bfUFnu15=4Z9HNigoo-XyjmwRvAWX_xz0A@mail.gmail.com>
In-Reply-To: <CA+55aFzXAnTzfNL-bfUFnu15=4Z9HNigoo-XyjmwRvAWX_xz0A@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Davidlohr Bueso <davidlohr@hp.com>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Hugh Dickins <hughd@google.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>

On 04/29/2014 03:25 AM, Linus Torvalds wrote:
> On Mon, Apr 28, 2014 at 2:20 PM, Linus Torvalds
> <torvalds@linux-foundation.org> wrote:
>>
>> That said, the bug does seem to be that some path doesn't invalidate
>> the vmacache sufficiently, or something inserts a vmacache entry into
>> the current process when looking up a remote process or whatever.
>> Davidlohr, ideas?
> 
> Maybe we missed some use_mm() call. That will change the current mm
> without flushing the vma cache. The code considers kernel threads to
> be bad targets for vma caching for this reason (and perhaps others),
> but maybe we missed something.
> 
> I wonder if we should just invalidate the vma cache in use_mm(), and
> remote the "kernel tasks are special" check.
> 
> Srivatsa, are you doing something peculiar on that system that would
> trigger this? I see some kdump failures in the log, anything else?
> 

No, it was just plain booting. The machine is simply configured with
kdump, that's all. I'm surprised that so many processes got segfaults
during boot. Looks like an mm bug in the kernel.

Regards,
Srivatsa S. Bhat

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
