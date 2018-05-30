Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id E91176B0003
	for <linux-mm@kvack.org>; Tue, 29 May 2018 23:40:50 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id l204-v6so423965lfg.12
        for <linux-mm@kvack.org>; Tue, 29 May 2018 20:40:50 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h17-v6sor7859620ljg.113.2018.05.29.20.40.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 29 May 2018 20:40:49 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180529173445.GD15148@bombadil.infradead.org>
References: <20180529143126.GA19698@jordon-HP-15-Notebook-PC>
 <20180529145055.GA15148@bombadil.infradead.org> <CAFqt6zaxt=wXjvKV0qA+OwU1iUyoBdW2cJSLFqXupVWRpKdqEA@mail.gmail.com>
 <20180529173445.GD15148@bombadil.infradead.org>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Wed, 30 May 2018 09:10:47 +0530
Message-ID: <CAFqt6zZCX7Ai2w9dV3OvUn=V4Z02H=+FBirjHT3QSU1Fuz+uLQ@mail.gmail.com>
Subject: Re: [PATCH] mm: Change return type to vm_fault_t
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, zi.yan@cs.rutgers.edu, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, Greg KH <gregkh@linuxfoundation.org>, Mark Rutland <mark.rutland@arm.com>, riel@redhat.com, pasha.tatashin@oracle.com, jschoenh@amazon.de, Kate Stewart <kstewart@linuxfoundation.org>, David Rientjes <rientjes@google.com>, tglx@linutronix.de, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, yang.s@alibaba-inc.com, Minchan Kim <minchan@kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-kernel@vger.kernel.org, Linux-MM <linux-mm@kvack.org>

On Tue, May 29, 2018 at 11:04 PM, Matthew Wilcox <willy@infradead.org> wrote:
> On Tue, May 29, 2018 at 09:25:05PM +0530, Souptick Joarder wrote:
>> On Tue, May 29, 2018 at 8:20 PM, Matthew Wilcox <willy@infradead.org> wrote:
>> > On Tue, May 29, 2018 at 08:01:26PM +0530, Souptick Joarder wrote:
>> >> Use new return type vm_fault_t for fault handler. For
>> >> now, this is just documenting that the function returns
>> >> a VM_FAULT value rather than an errno. Once all instances
>> >> are converted, vm_fault_t will become a distinct type.
>> >
>> > I don't believe you've checked this with sparse.
>> >
>> >> @@ -802,7 +802,8 @@ int fixup_user_fault(struct task_struct *tsk, struct mm_struct *mm,
>> >>                    bool *unlocked)
>> >>  {
>> >>       struct vm_area_struct *vma;
>> >> -     int ret, major = 0;
>> >> +     int major = 0;
>> >> +     vm_fault_t ret;
>> >>
>> >>       if (unlocked)
>> >>               fault_flags |= FAULT_FLAG_ALLOW_RETRY;
>> >
>> > ...
>> >         major |= ret & VM_FAULT_MAJOR;
>> >
>> > That should be throwing a warning.
>>
>> Sorry, but I verified again and didn't see similar warnings.
>>
>> steps followed -
>>
>> apply the patch
>> make c=2 -j4 ( build for x86_64)
>> looking for warnings in files because of this patch.
>>
>> The only error I am seeing "error: undefined identifier '__COUNTER__' "
>> which is pointing to BUG(). There are few warnings but those are not
>> related to this patch.
>>
>> In my test tree the final patch to create new vm_fault_t type is
>> already applied.
>>
>> Do you want me to verify in some other way ?
>
> I see:
>
> mm/gup.c:817:15: warning: invalid assignment: |=
> mm/gup.c:817:15:    left side has type int
> mm/gup.c:817:15:    right side has type restricted vm_fault_t
>
> are you building with 'c=2' or 'C=2'?

Building with C=2.
Do I need to enable any separate FLAG ?
