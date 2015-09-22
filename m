Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f48.google.com (mail-la0-f48.google.com [209.85.215.48])
	by kanga.kvack.org (Postfix) with ESMTP id 64B026B0253
	for <linux-mm@kvack.org>; Tue, 22 Sep 2015 12:47:18 -0400 (EDT)
Received: by lagj9 with SMTP id j9so20260479lag.2
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 09:47:17 -0700 (PDT)
Received: from mail-la0-x22a.google.com (mail-la0-x22a.google.com. [2a00:1450:4010:c03::22a])
        by mx.google.com with ESMTPS id o64si840978lfe.117.2015.09.22.09.47.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Sep 2015 09:47:17 -0700 (PDT)
Received: by lagj9 with SMTP id j9so20260048lag.2
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 09:47:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150915190143.GA18670@node.dhcp.inet.fi>
References: <CAAeHK+z8o96YeRF-fQXmoApOKXa0b9pWsQHDeP=5GC_hMTuoDg@mail.gmail.com>
	<55EC9221.4040603@oracle.com>
	<20150907114048.GA5016@node.dhcp.inet.fi>
	<55F0D5B2.2090205@oracle.com>
	<20150910083605.GB9526@node.dhcp.inet.fi>
	<CAAeHK+xSFfgohB70qQ3cRSahLOHtamCftkEChEgpFpqAjb7Sjg@mail.gmail.com>
	<20150911103959.GA7976@node.dhcp.inet.fi>
	<alpine.LSU.2.11.1509111734480.7660@eggly.anvils>
	<55F8572D.8010409@oracle.com>
	<20150915190143.GA18670@node.dhcp.inet.fi>
Date: Tue, 22 Sep 2015 18:47:16 +0200
Message-ID: <CAAeHK+wABeppPQCsTmUk6cMswJosgkaXkHO5QTFBh=1ZTi+-3w@mail.gmail.com>
Subject: Re: Multiple potential races on vma->vm_flags
From: Andrey Konovalov <andreyknvl@google.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Sasha Levin <sasha.levin@oracle.com>, Hugh Dickins <hughd@google.com>, Oleg Nesterov <oleg@redhat.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>

If anybody comes up with a patch to fix the original issue I easily
can test it, since I'm hitting "BUG: Bad page state" in a second when
fuzzing with KTSAN and Trinity.

On Tue, Sep 15, 2015 at 9:01 PM, Kirill A. Shutemov
<kirill@shutemov.name> wrote:
> On Tue, Sep 15, 2015 at 01:36:45PM -0400, Sasha Levin wrote:
>> On 09/11/2015 09:27 PM, Hugh Dickins wrote:
>> > I'm inclined to echo Vlastimil's comment from earlier in the thread:
>> > sounds like an overkill, unless we find something more serious than this.
>>
>> I've modified my tests to stress the exit path of processes with many vmas,
>
> Could you share the test?
>
>> and hit the following NULL ptr deref (not sure if it's related to the original issue):
>>
>> [1181047.935563] kasan: GPF could be caused by NULL-ptr deref or user memory accessgeneral protection fault: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC KASAN
>> [1181047.937223] Modules linked in:
>> [1181047.937772] CPU: 4 PID: 21912 Comm: trinity-c341 Not tainted 4.3.0-rc1-next-20150914-sasha-00043-geddd763-dirty #2554
>> [1181047.939387] task: ffff8804195c8000 ti: ffff880433f00000 task.ti: ffff880433f00000
>> [1181047.940533] RIP: unmap_vmas (mm/memory.c:1337)
>
> Is it "struct mm_struct *mm = vma->vm_mm;"?
>
> --
>  Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
