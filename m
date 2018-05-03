Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 36BCC6B0005
	for <linux-mm@kvack.org>; Thu,  3 May 2018 10:37:41 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id m20-v6so1216206qtm.6
        for <linux-mm@kvack.org>; Thu, 03 May 2018 07:37:41 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id w13si2670731qka.269.2018.05.03.07.37.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 May 2018 07:37:40 -0700 (PDT)
Subject: Re: [PATCH] pkeys: Introduce PKEY_ALLOC_SIGNALINHERIT and change
 signal semantics
References: <20180502132751.05B9F401F3041@oldenburg.str.redhat.com>
 <248faadb-e484-806f-1485-c34a72a9ca0b@intel.com>
 <822a28c9-5405-68c2-11bf-0c282887466d@redhat.com>
 <57459C6F-C8BA-4E2D-99BA-64F35C11FC05@amacapital.net>
 <6286ba0a-7e09-b4ec-e31f-bd091f5940ff@redhat.com>
 <CALCETrVrm6yGiv6_z7RqdeB-324RoeMmjpf1EHsrGOh+iKb7+A@mail.gmail.com>
 <b2df1386-9df9-2db8-0a25-51bf5ff63592@redhat.com>
 <CALCETrW_Dt-HoG4keFJd8DSD=tvyR+bBCFrBDYdym4GQbfng4A@mail.gmail.com>
From: Florian Weimer <fweimer@redhat.com>
Message-ID: <74eec76a-3587-7ff6-fa0b-d8aa78ab28a1@redhat.com>
Date: Thu, 3 May 2018 16:37:37 +0200
MIME-Version: 1.0
In-Reply-To: <CALCETrW_Dt-HoG4keFJd8DSD=tvyR+bBCFrBDYdym4GQbfng4A@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Linux-MM <linux-mm@kvack.org>, Linux API <linux-api@vger.kernel.org>, linux-x86_64@vger.kernel.org, linux-arch <linux-arch@vger.kernel.org>, X86 ML <x86@kernel.org>, linuxram@us.ibm.com

On 05/02/2018 11:23 PM, Andy Lutomirski wrote:
>> The kernel could do*something*, probably along the membarrier system
>> call.  I mean, I could implement a reasonable close approximation in
>> userspace, via the setxid mechanism in glibc (but I really don't want to).
> I beg to differ.
> 
> Thread A:
> old = RDPKRU();
> WRPKRU(old & ~3);
> ...
> WRPKRU(old);
> 
> Thread B:
> pkey_alloc().
> 
> If pkey_alloc() happens while thread A is in the ... part, you lose.  It
> makes no difference what the kernel does.  The problem is that the WRPKRU
> instruction itself is designed incorrectly.

Even that is solvable, as long as the architecture as exact traps: You 
can look at the program counter and patch up the registers accordingly 
if the code is in the critical section.  Of course, this would need 
centralizing PKRU updates in a vDSO or a single (glibc) library 
function.  Certainly not nice and even horrible enough not to do it, but 
I don't think it's actually impossible.

Didn't we discuss this before?

Thanks,
Florian
