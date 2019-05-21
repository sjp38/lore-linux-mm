Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 13E13C04AAF
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 17:44:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B9F2821019
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 17:44:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B9F2821019
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2D7376B0007; Tue, 21 May 2019 13:44:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 269D36B0008; Tue, 21 May 2019 13:44:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 129546B000A; Tue, 21 May 2019 13:44:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f70.google.com (mail-lf1-f70.google.com [209.85.167.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9D9456B0007
	for <linux-mm@kvack.org>; Tue, 21 May 2019 13:44:39 -0400 (EDT)
Received: by mail-lf1-f70.google.com with SMTP id z63so1074858lfa.16
        for <linux-mm@kvack.org>; Tue, 21 May 2019 10:44:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=uDRLCmMMsoE1LLeU0VpJwUNcYe5xjaLDJsx1VofbglI=;
        b=mAuZikGjdkF6VqdPzUhVqRSM8foGt0nHQlSmJqyY4PUPUJChhCxD6oYui6rkkS/QX/
         IMgBe4izt/bZadjv2bliQHq9dAzYZvakD6Uug0G3MCFBkPdYe5QJrW41fbLWPox7Kje/
         wzLlwReSgWwVFpZlA9/Os6AnbL2pYR4pVZWamoaMOrPsH91DjG+zvgLal5X7TQGpzNLL
         mdOK+NnuXX00uvcFmd3YR4NtlL4SP6yY6MXSllRUU2H5jMrKtWhGv5MKoyhxC1gYv32C
         Lub1fMlTqKfMPLWLVxEaXn6Co5oCJrkI50BhCUY+X1kf9JdRG3eE8lOCsGxlKpStaa18
         eiuw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: APjAAAXnkd5Spw698CpCvydFUU49W+MAWKtqaJz8hyiRjJNXb6YsCO62
	Uhf/Ei11wWmecz76j6MjudIeT7V3F4DKT4yVYQ6a96EqJYTJIgozTaliwAtxezqsKuDKopzuASt
	OuSnIRrn72gIZJJkLtI2sPesSGlXmuI+KKWzfgAqnJZ5SrSvMZ7OoLBnDEmnVb16wVA==
X-Received: by 2002:ac2:4989:: with SMTP id f9mr41896355lfl.12.1558460679000;
        Tue, 21 May 2019 10:44:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz3Z9AMzfw0U818CGfI80jTwMwuFNY+GS/s1HSEYMKyVUljZQgVzosDsGPNjbC3iidf3j/B
X-Received: by 2002:ac2:4989:: with SMTP id f9mr41896304lfl.12.1558460677733;
        Tue, 21 May 2019 10:44:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558460677; cv=none;
        d=google.com; s=arc-20160816;
        b=EBudHjmRUp1AVvICb9flCaOAm7Ci2mBB3mfIj+V7U70yHpa/E7qJy0FZJJw5hCenUe
         SPJw4K1nxY/N0W1v9g9nJQG0DFpkO0s+lmQfcgQtNKGJs7eyifPbJPWZZL8YUCItvITN
         ZmSbdShQgqae9M34+nZ5UbybQHPrrj3Rn1fqFrmz/vW2j4vXQTcsv1GLhsaFPKwU48Je
         bcqGspJ8Kqsh73G3E96rjNJiYmLZoXfjqSSymYhUntLX/9P2b8FX/j4hGy+agXVycxBC
         JRnVaPODOenaG62Edv9EjQKdtA3TgD19NG95wjxPzrVA/YZAfiRt1G70ZROJjCAEuetN
         F2Ig==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=uDRLCmMMsoE1LLeU0VpJwUNcYe5xjaLDJsx1VofbglI=;
        b=TpN8/6TY0oKjCyeycK5HkbqqTRvNp8RD89fJMggh/HGV40mSmWwBHwfulMeSCIbjnI
         TYIlYX3CZ+AsdRmnCcTaaowYTh1+yr7ytUT+ToI2k0GSL71CY1EPK+ezRtmRsh6TH0rX
         +K7CFg1Bs95JXeXIOfD6jIBcTIk4n7fvMwvkrhCpB3FjhM74SWXqCy1ulfjBND3q5ZKX
         CaKHN3A+PgUiOExBYxo4lrpRxqKbJT4+uQH288uN6E9HHNwPlgl6mmzYZQXrE7pMcimV
         pra52VZ7Pqvjo3LounalUl8L30aUPOGeAzmJl7ptvIX9hc4M1+wWf16KUaKm6DwtVC1K
         AEnw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id q81si17081669lje.182.2019.05.21.10.44.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 May 2019 10:44:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.169]
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <ktkhai@virtuozzo.com>)
	id 1hT8oP-0007uj-PS; Tue, 21 May 2019 20:44:29 +0300
Subject: Re: [PATCH v2 0/7] mm: process_vm_mmap() -- syscall for duplication a
 process mapping
To: Andy Lutomirski <luto@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
 Dan Williams <dan.j.williams@intel.com>, Michal Hocko <mhocko@suse.com>,
 Keith Busch <keith.busch@intel.com>,
 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
 alexander.h.duyck@linux.intel.com, Weiny Ira <ira.weiny@intel.com>,
 Andrey Konovalov <andreyknvl@google.com>, arunks@codeaurora.org,
 Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@linux.com>,
 Rik van Riel <riel@surriel.com>, Kees Cook <keescook@chromium.org>,
 Johannes Weiner <hannes@cmpxchg.org>, Nicholas Piggin <npiggin@gmail.com>,
 Mathieu Desnoyers <mathieu.desnoyers@efficios.com>,
 Shakeel Butt <shakeelb@google.com>, Roman Gushchin <guro@fb.com>,
 Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>,
 Jerome Glisse <jglisse@redhat.com>, Mel Gorman
 <mgorman@techsingularity.net>, daniel.m.jordan@oracle.com,
 Jann Horn <jannh@google.com>, Adam Borowski <kilobyte@angband.pl>,
 Linux API <linux-api@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>,
 Linux-MM <linux-mm@kvack.org>
References: <155836064844.2441.10911127801797083064.stgit@localhost.localdomain>
 <CALCETrU221N6uPmdaj4bRDDsf+Oc5tEfPERuyV24wsYKHn+spA@mail.gmail.com>
 <9638a51c-4295-924f-1852-1783c7f3e82d@virtuozzo.com>
 <CALCETrUMDTGRtLFocw6vnN___7rkb6r82ULehs0=yQO5PZL8MA@mail.gmail.com>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <67d1321e-ffd6-24a3-407f-cd26c82e46b8@virtuozzo.com>
Date: Tue, 21 May 2019 20:44:28 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <CALCETrUMDTGRtLFocw6vnN___7rkb6r82ULehs0=yQO5PZL8MA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 21.05.2019 19:43, Andy Lutomirski wrote:
> On Tue, May 21, 2019 at 8:52 AM Kirill Tkhai <ktkhai@virtuozzo.com> wrote:
>>
>> On 21.05.2019 17:43, Andy Lutomirski wrote:
>>> On Mon, May 20, 2019 at 7:01 AM Kirill Tkhai <ktkhai@virtuozzo.com> wrote:
>>>>
>>>
>>>> [Summary]
>>>>
>>>> New syscall, which allows to clone a remote process VMA
>>>> into local process VM. The remote process's page table
>>>> entries related to the VMA are cloned into local process's
>>>> page table (in any desired address, which makes this different
>>>> from that happens during fork()). Huge pages are handled
>>>> appropriately.
>>>>
>>>> This allows to improve performance in significant way like
>>>> it's shows in the example below.
>>>>
>>>> [Description]
>>>>
>>>> This patchset adds a new syscall, which makes possible
>>>> to clone a VMA from a process to current process.
>>>> The syscall supplements the functionality provided
>>>> by process_vm_writev() and process_vm_readv() syscalls,
>>>> and it may be useful in many situation.
>>>>
>>>> For example, it allows to make a zero copy of data,
>>>> when process_vm_writev() was previously used:
>>>>
>>>>         struct iovec local_iov, remote_iov;
>>>>         void *buf;
>>>>
>>>>         buf = mmap(NULL, n * PAGE_SIZE, PROT_READ|PROT_WRITE,
>>>>                    MAP_PRIVATE|MAP_ANONYMOUS, ...);
>>>>         recv(sock, buf, n * PAGE_SIZE, 0);
>>>>
>>>>         local_iov->iov_base = buf;
>>>>         local_iov->iov_len = n * PAGE_SIZE;
>>>>         remove_iov = ...;
>>>>
>>>>         process_vm_writev(pid, &local_iov, 1, &remote_iov, 1 0);
>>>>         munmap(buf, n * PAGE_SIZE);
>>>>
>>>>         (Note, that above completely ignores error handling)
>>>>
>>>> There are several problems with process_vm_writev() in this example:
>>>>
>>>> 1)it causes pagefault on remote process memory, and it forces
>>>>   allocation of a new page (if was not preallocated);
>>>
>>> I don't see how your new syscall helps.  You're writing to remote
>>> memory.  If that memory wasn't allocated, it's going to get allocated
>>> regardless of whether you use a write-like interface or an mmap-like
>>> interface.
>>
>> No, the talk is not about just another interface for copying memory.
>> The talk is about borrowing of remote task's VMA and corresponding
>> page table's content. Syscall allows to copy part of page table
>> with preallocated pages from remote to local process. See here:
>>
>> [task1]                                                        [task2]
>>
>> buf = mmap(NULL, n * PAGE_SIZE, PROT_READ|PROT_WRITE,
>>            MAP_PRIVATE|MAP_ANONYMOUS, ...);
>>
>> <task1 populates buf>
>>
>>                                                                buf = process_vm_mmap(pid_of_task1, addr, n * PAGE_SIZE, ...);
>> munmap(buf);
>>
>>
>> process_vm_mmap() copies PTEs related to memory of buf in task1 to task2
>> just like in the way we do during fork syscall.
> 
> If I understand this correctly, your intended use is to have one task
> allocate memory and fill it, have the other task clone the VMA, and
> have the first task free the VMA?  If so, that wasn't at all obvious
> from your original email.

Yes, exactly this. Sorry for confusing in initial description, it's not intentionally.

> Why don't you use splice() instead?

I just don't see a possibility of anonymous memory may be moved from
one process to another via splice(). Maybe you may explain your idea
more detailed?

> splice() the data to the remote
> task and have the remove task read() it?  All these VMA games will
> result in a lot of flushes, which is bad for performance.  Or,
> depending on your exact constraints, you could map a memfd in both
> tasks instead, which has the same flushing issues but at least has a
> sensible API.

memfd() is file-backed mapping, and it is not suitable for that.
In case of a process had anonymous mapping before the migration,
it wants the mapping remains the same after the migration. So,
if we use memfd(), we have to copy the memory from memfd mapping
to its real anonymous mapping target, which has the same problems
as process_vm_writev().

>>
>> There is no copying of buf memory content, unless COW happens. This is
>> the principal difference to process_vm_writev(), which just allocates
>> pages in remote VM.
>>
>>> Keep in mind that, on x86, just the hardware part of a
>>> page fault is very slow -- populating the memory with a syscall
>>> instead of a fault may well be faster.
>>
>> It is not as slow, as disk IO has. Just compare, what happens in case of anonymous
>> pages related to buf of task1 are swapped:
>>
>> 1)process_vm_writev() reads them back into memory;
>>
>> 2)process_vm_mmap() just copies swap PTEs from task1 page table
>>   to task2 page table.
>>
>> Also, for faster page faults one may use huge pages for the mappings.
>> But really, it's funny to think about page faults, when there are
>> disk IO problems I shown.
> 
> What are you doing that is causing *disk* IO in any of this?  I
> suspect your real problem is that you are using far too large of a
> buffer. See below.

Imagine, we are migrating a container, which consists of 9 GB of pages,
and we have 8GB RAM on destination node. Before the migration, we had
some of pages in RAM and some of pages in swap.

Source node sends pages to destination node. And there are limitations,
which do not allow to start creation of process tree on the destination
node, before all memory is received.

Pages are received by some page server task on destination. After all pages
are received, we create process tree and populate container tasks mappings.

When we're populating tasks mapping, we have to copy memory from page server
to a target task. In case of the pages were swapped from page server's
address space, we have to read synchronously them from swap. This introduces
big latency, and big IO I talked.

> 
>>
>>>>
>>>> 2)amount of memory for this example is doubled in a moment --
>>>>   n pages in current and n pages in remote tasks are occupied
>>>>   at the same time;
>>>
>>> This seems disingenuous.  If you're writing p pages total in chunks of
>>> n pages, you will use a total of p pages if you use mmap and p+n if
>>> you use write.
>>
>> I didn't understand this sentence because of many ifs, sorry. Could you
>> please explain your thought once again?
> 
> You seem to have a function that tries to populate p pages of memory
> with data received from a socket.  It looks like you're doing
> something like this:
> 
> void copy_p_pages(size_t p)
> {
>   size_t n = some_value(p);
>   char *buf = malloc(n * PAGE_SIZE);
>   for (int i = 0; i < p; i += n*PAGE_SIZE) {
>     read(fd, buf, n*PAGE_SIZE);  /* check return value, etc */
>     process_vm_writev(write n*PAGE_SIZE bytes to remote process);
>   }
>   free(buf);
> }
> 
> If you have a *constant* n (i.e. some_value(p) is just a number like
> 16)), then you aren't doubling memory usage.  If you have
> some_value(p) return p, then you are indeed doubling memory usage.  So
> don't do that!
> If buf is getting swapped out, you are very likely doing something
> wrong.  If you're using a 100MB buffer or a 10GB, then I'm not
> surprised you have problems.  Try something reasonable like 128kB. For
> extra fun, you could mlock() that buf, but if you're thrashing on
> access to a 128kB working set, you will probably also get your *code*
> swapped out, in which case you pretty much lose.

The thing is we can't use small buffer. We have to receive all the restored
tasks pages on the destination node, before we start the process tree
creation like I wrote above. All the anonymous memory is mapped into
page server's MM, so it becomes swapped before container's process
tree starts to create.
 
>>> For example, if the remote VMA is MAP_ANONYMOUS, do you get
>>> a CoW copy of it? I assume you don't since the whole point is to
>>> write to remote memory
>>
>> But, no, there *is* COW semantic. We do not copy memory. We copy
>> page table content. This is just the same we have on fork(), when
>> children duplicates parent's VMA and related page table subset,
>> and parent's PTEs lose _PAGE_RW flag.
> 
> Then you need to document this very carefully, because other people
> will use your syscall in different ways than you use it.

Ok, I'll do.

> And, if you are doing CoW like this, then your syscall is basically
> only useful for your really weird use case in which you're using it to
> import an already-populated VMA.  Maybe this is a reasonable feature
> to add to the kernel, but it needs a benchmark against a reasonable
> alternative.

Do you mean comparison with process_vm_writev/readv() or something like
this?

>>
>> There is all copy_page_range() code reused for that. Please, see [3/7]
>> for the details.
> 
> You can't as users of a syscall to read the nitty gritty mm code to
> figure out what the syscall does from a user's perspective.

Yeah, sure :)
 
>>> But there are plenty of other questions.
>>> What happens if the remote VMA is a gate area or other special mapping
>>> (vDSO, vvar area, etc)?  What if the remote memory comes from a driver
>>> that wasn't expecting the mapping to get magically copied to a
>>> different process?
>>
>> In case of someone wants to duplicate such the mappings, we may consider
>> that, and extend the interface in the future for VMA types, which are
>> safe for that.
> 
> Do you mean that the code you sent rejects this case?  If so, please
> document it.  In any case, I looked at the code, and it seems to be
> trying to handle MAP_SHARED and MAP_ANONYMOUS.  I don't see where it
> would reject copying a vDSO.

I prohibit all the VMAs, which contain on of flags: VM_HUGETLB|VM_DONTEXPAND|VM_PFNMAP|VM_IO.
I'll check carefully, whether it's enough for vDSO.

Thanks,
Kirill

