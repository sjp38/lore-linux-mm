Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 17EFA6B0003
	for <linux-mm@kvack.org>; Wed,  2 May 2018 18:08:30 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id c4so13877385pfg.22
        for <linux-mm@kvack.org>; Wed, 02 May 2018 15:08:30 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id bc11-v6si11761010plb.43.2018.05.02.15.08.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 May 2018 15:08:29 -0700 (PDT)
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
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <a37b7deb-7f5a-3dfa-f360-956cab8a813a@intel.com>
Date: Wed, 2 May 2018 15:08:27 -0700
MIME-Version: 1.0
In-Reply-To: <CALCETrW_Dt-HoG4keFJd8DSD=tvyR+bBCFrBDYdym4GQbfng4A@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>, Florian Weimer <fweimer@redhat.com>
Cc: Linux-MM <linux-mm@kvack.org>, Linux API <linux-api@vger.kernel.org>, linux-x86_64@vger.kernel.org, linux-arch <linux-arch@vger.kernel.org>, X86 ML <x86@kernel.org>, linuxram@us.ibm.com

On 05/02/2018 02:23 PM, Andy Lutomirski wrote:
>> The kernel could do *something*, probably along the membarrier system
>> call.  I mean, I could implement a reasonable close approximation in
>> userspace, via the setxid mechanism in glibc (but I really don't want to).
> 
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

Yes, *if* we define pkey_alloc() to be implicitly changing other
threads' PKRU value.

Let's say we go to the hardware guys and ask for a new instruction to
fix this.  We're going to have to make a pretty good case that this is
either impossible or really hard to do in software.

Surely we have the locking to tell another thread that we want its PKRU
value to change without actively going out and having the kernel poke a
new value in.
