Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f170.google.com (mail-we0-f170.google.com [74.125.82.170])
	by kanga.kvack.org (Postfix) with ESMTP id 2E8B46B0032
	for <linux-mm@kvack.org>; Thu, 15 Jan 2015 14:51:24 -0500 (EST)
Received: by mail-we0-f170.google.com with SMTP id w61so16719725wes.1
        for <linux-mm@kvack.org>; Thu, 15 Jan 2015 11:51:23 -0800 (PST)
Received: from e06smtp17.uk.ibm.com (e06smtp17.uk.ibm.com. [195.75.94.113])
        by mx.google.com with ESMTPS id z2si197972wib.91.2015.01.15.11.51.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 15 Jan 2015 11:51:23 -0800 (PST)
Received: from /spool/local
	by e06smtp17.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <borntraeger@de.ibm.com>;
	Thu, 15 Jan 2015 19:51:22 -0000
Received: from b06cxnps3075.portsmouth.uk.ibm.com (d06relay10.portsmouth.uk.ibm.com [9.149.109.195])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id 964F817D8056
	for <linux-mm@kvack.org>; Thu, 15 Jan 2015 19:51:59 +0000 (GMT)
Received: from d06av10.portsmouth.uk.ibm.com (d06av10.portsmouth.uk.ibm.com [9.149.37.251])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t0FJpK8h52297808
	for <linux-mm@kvack.org>; Thu, 15 Jan 2015 19:51:20 GMT
Received: from d06av10.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av10.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t0FJpKZY027976
	for <linux-mm@kvack.org>; Thu, 15 Jan 2015 12:51:20 -0700
Message-ID: <54B81A37.80109@de.ibm.com>
Date: Thu, 15 Jan 2015 20:51:19 +0100
From: Christian Borntraeger <borntraeger@de.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/8] x86/spinlock: Leftover conversion ACCESS_ONCE->READ_ONCE
References: <1421312314-72330-1-git-send-email-borntraeger@de.ibm.com> <1421312314-72330-5-git-send-email-borntraeger@de.ibm.com> <20150115193839.GA28727@redhat.com>
In-Reply-To: <20150115193839.GA28727@redhat.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, kvm@vger.kernel.org, kvm-ppc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, x86@kernel.org, xen-devel@lists.xenproject.org, linux-mm@kvack.org

Am 15.01.2015 um 20:38 schrieb Oleg Nesterov:
> On 01/15, Christian Borntraeger wrote:
>>
>> --- a/arch/x86/include/asm/spinlock.h
>> +++ b/arch/x86/include/asm/spinlock.h
>> @@ -186,7 +186,7 @@ static inline void arch_spin_unlock_wait(arch_spinlock_t *lock)
>>  	__ticket_t head = ACCESS_ONCE(lock->tickets.head);
>>  
>>  	for (;;) {
>> -		struct __raw_tickets tmp = ACCESS_ONCE(lock->tickets);
>> +		struct __raw_tickets tmp = READ_ONCE(lock->tickets);
> 
> Agreed, but what about another ACCESS_ONCE() above?
> 
> Oleg.
> 

tickets.head is a scalar type, so ACCESS_ONCE does work fine with gcc 4.6/4.7.
My goal was to convert all accesses on non-scalar types as until 
"kernel: tighten rules for ACCESS ONCE" is merged because anything else would be
a Whac-a-mole like adventure (I learned that during the last round in next: all
conversions in this series fix up changes made during this merge window)

We probably going to do a bigger bunch of bulk conversion later on when 
"kernel: tighten rules for ACCESS ONCE" prevents new problems.

Makes sense?

Christian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
