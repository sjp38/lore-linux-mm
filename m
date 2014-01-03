Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 512B36B0035
	for <linux-mm@kvack.org>; Fri,  3 Jan 2014 00:28:36 -0500 (EST)
Received: by mail-pd0-f169.google.com with SMTP id v10so15014337pde.28
        for <linux-mm@kvack.org>; Thu, 02 Jan 2014 21:28:35 -0800 (PST)
Received: from e23smtp06.au.ibm.com (e23smtp06.au.ibm.com. [202.81.31.148])
        by mx.google.com with ESMTPS id tr4si44504021pab.295.2014.01.02.21.28.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 02 Jan 2014 21:28:35 -0800 (PST)
Received: from /spool/local
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Fri, 3 Jan 2014 15:28:29 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 237252BB0055
	for <linux-mm@kvack.org>; Fri,  3 Jan 2014 16:28:26 +1100 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s035SDnt3670512
	for <linux-mm@kvack.org>; Fri, 3 Jan 2014 16:28:13 +1100
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s035SP8M022512
	for <linux-mm@kvack.org>; Fri, 3 Jan 2014 16:28:25 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH -V2] powerpc: thp: Fix crash on mremap
In-Reply-To: <1388665786.4373.48.camel@pasglop>
References: <1388654266-5195-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20140102094124.04D76E0090@blue.fi.intel.com> <87zjneodtw.fsf@linux.vnet.ibm.com> <1388665786.4373.48.camel@pasglop>
Date: Fri, 03 Jan 2014 10:58:14 +0530
Message-ID: <87wqihocr5.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, paulus@samba.org, aarcange@redhat.com, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

Benjamin Herrenschmidt <benh@kernel.crashing.org> writes:

> On Thu, 2014-01-02 at 16:22 +0530, Aneesh Kumar K.V wrote:
>> > Just use config option directly:
>> >
>> >       if (new_ptl != old_ptl ||
>> >               IS_ENABLED(CONFIG_ARCH_THP_MOVE_PMD_ALWAYS_WITHDRAW))
>> 
>> 
>> I didn't like that. I found the earlier one easier for reading.
>> If you and others strongly feel about this, I can redo the patch.
>> Please let me know
>
> Yes, use IS_ENABLED, no need to have two indirections of #define's
>
> Another option is to have
>
> 	if (pmd_move_must_withdraw(new,old)) {
> 	}
>
> With in a generic header:
>
> #ifndef pmd_move_must_withdraw
> static inline bool pmd_move_must_withdraw(spinlock_t *new_ptl, ...)
> {
> 	return new_ptl != old_ptl;
> }
> #endif
>
> And in powerpc:
>
> static inline bool pmd_move_must_withdraw(spinlock_t *new_ptl, ...)
> {
> 	return true;
> }
> #define pmd_move_must_withdraw pmd_move_must_withdraw

This is better i guess. It is also in-line with rest of transparent
hugepage functions. I will do this.

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
