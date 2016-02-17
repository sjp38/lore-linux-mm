Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f172.google.com (mail-yw0-f172.google.com [209.85.161.172])
	by kanga.kvack.org (Postfix) with ESMTP id 838216B0005
	for <linux-mm@kvack.org>; Tue, 16 Feb 2016 19:38:57 -0500 (EST)
Received: by mail-yw0-f172.google.com with SMTP id g127so990024ywf.2
        for <linux-mm@kvack.org>; Tue, 16 Feb 2016 16:38:57 -0800 (PST)
Received: from mail-yw0-x22f.google.com (mail-yw0-x22f.google.com. [2607:f8b0:4002:c05::22f])
        by mx.google.com with ESMTPS id q138si15504145ywg.336.2016.02.16.16.38.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Feb 2016 16:38:56 -0800 (PST)
Received: by mail-yw0-x22f.google.com with SMTP id h129so1010149ywb.1
        for <linux-mm@kvack.org>; Tue, 16 Feb 2016 16:38:56 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.11.1602121247530.9500@eggly.anvils>
References: <bug-112301-27@https.bugzilla.kernel.org/>
	<20160211133026.96452d486f8029084c4129b7@linux-foundation.org>
	<alpine.LSU.2.11.1602121247530.9500@eggly.anvils>
Date: Tue, 16 Feb 2016 16:38:56 -0800
Message-ID: <CAPcyv4g0-F0=M9284d4FjUOqSgeLsgSmkRirWoO8qK4cc26s8w@mail.gmail.com>
Subject: Re: [Bug 112301] New: [bisected] NULL pointer dereference when
 starting a kvm based VM
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, harn-solo@gmx.de, bugzilla-daemon@bugzilla.kernel.org, Linux MM <linux-mm@kvack.org>, ebru.akagunduz@gmail.com, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>

On Fri, Feb 12, 2016 at 1:10 PM, Hugh Dickins <hughd@google.com> wrote:
> On Thu, 11 Feb 2016, Andrew Morton wrote:
>>
>> (switched to email.  Please respond via emailed reply-to-all, not via the
>> bugzilla web interface).
>>
>> On Thu, 11 Feb 2016 07:09:04 +0000 bugzilla-daemon@bugzilla.kernel.org wrote:
>>
>> > https://bugzilla.kernel.org/show_bug.cgi?id=112301
>> >
>> >             Bug ID: 112301
>> >            Summary: [bisected] NULL pointer dereference when starting a
>> >                     kvm based VM
>> >            Product: Memory Management
>> >            Version: 2.5
>> >     Kernel Version: 4.5-rcX
>> >           Hardware: All
>> >                 OS: Linux
>> >               Tree: Mainline
>> >             Status: NEW
>> >           Severity: normal
>> >           Priority: P1
>> >          Component: Other
>> >           Assignee: akpm@linux-foundation.org
>> >           Reporter: harn-solo@gmx.de
>> >         Regression: No
>> >
>> > Created attachment 203451
>> >   --> https://bugzilla.kernel.org/attachment.cgi?id=203451&action=edit
>> > Call Trace of a NULL pointer dereference at gup_pte_range
>> >
>> > Starting a qemu-kvm based VM configured to use hughpages I'm getting the
>> > following NULL pointer dereference, see attached dmesg section.
>> >
>> > The issue was introduced with commit 7d2eba0557c18f7522b98befed98799990dd4fdb
>> > Author: Ebru Akagunduz <ebru.akagunduz@gmail.com>
>> > Date:   Thu Jan 14 15:22:19 2016 -0800
>> >     mm: add tracepoint for scanning pages
>>
>> Thanks for the detailed report.  Can you please verify that your tree
>> has 629d9d1cafbd49cb374 ("mm: avoid uninitialized variable in
>> tracepoint")?
>>
>> vfio_pin_pages() doesn't seem to be doing anything crazy.  Hugh, Ebru:
>> could you please take a look?
>
> I very much doubt that the uninitialized variable in collapse_huge_page()
> had anything to do with the crash in gup_pte_range().  Far more likely
> is that the bisection hit a point in between the introduction of that
> uninitialized variable and its subsequent fix, the test crashed, and
> the bisector didn't notice that it was crashing for a different reason.
>
> Comparing the "Code:" of the gup_pte_range() crash with disassembly of
> gup_pte_range() here, it looks as if it's crashing in pte_page().  And,
> yes, that pte_page() looks broken in 4.5-rc: please try this patch.
>
> [PATCH] mm, x86: fix pte_page() crash in gup_pte_range()
>
> Commit 3565fce3a659 ("mm, x86: get_user_pages() for dax mappings")
> has moved up the pte_page(pte) in x86's fast gup_pte_range(), for no
> discernible reason: put it back where it belongs, after the pte_flags
> check and the pfn_valid cross-check.
>
> That may be the cause of the NULL pointer dereference in gup_pte_range(),
> seen when vfio called vaddr_get_pfn() when starting a qemu-kvm based VM.
>
> Reported-by: Michael Long <Harn-Solo@gmx.de>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Signed-off-by: Hugh Dickins <hughd@google.com>

Acked-by: Dan Williams <dan.j.williams@intel.com>

That must have been a merge/rebase error on my part when forward
porting the patch to a new -mm baseline because the pte_devmap() check
is done before we know that the pfn actually has a corresponding
struct page.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
