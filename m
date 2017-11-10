Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id D1BB92802A5
	for <linux-mm@kvack.org>; Fri, 10 Nov 2017 17:09:07 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id k190so8813211pga.10
        for <linux-mm@kvack.org>; Fri, 10 Nov 2017 14:09:07 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id 100si9894202pld.634.2017.11.10.14.09.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Nov 2017 14:09:06 -0800 (PST)
Subject: Re: [PATCH 21/30] x86, mm: put mmu-to-h/w ASID translation in one
 place
References: <20171110193058.BECA7D88@viggo.jf.intel.com>
 <20171110193146.5908BE13@viggo.jf.intel.com>
 <CALCETrXrXpTZE2sceBh=eW5kEP79hWc5iY36QKjfy=U4nTirDw@mail.gmail.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <101307eb-b924-69ef-13dd-05e63fbaf587@linux.intel.com>
Date: Fri, 10 Nov 2017 14:09:06 -0800
MIME-Version: 1.0
In-Reply-To: <CALCETrXrXpTZE2sceBh=eW5kEP79hWc5iY36QKjfy=U4nTirDw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, moritz.lipp@iaik.tugraz.at, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, Linus Torvalds <torvalds@linux-foundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, X86 ML <x86@kernel.org>

On 11/10/2017 02:03 PM, Andy Lutomirski wrote:
>> +static inline u16 kern_asid(u16 asid)
>> +{
>> +       VM_WARN_ON_ONCE(asid > MAX_ASID_AVAILABLE);
>> +       /*
>> +        * If PCID is on, ASID-aware code paths put the ASID+1 into the PCID
>> +        * bits.  This serves two purposes.  It prevents a nasty situation in
>> +        * which PCID-unaware code saves CR3, loads some other value (with PCID
>> +        * == 0), and then restores CR3, thus corrupting the TLB for ASID 0 if
>> +        * the saved ASID was nonzero.  It also means that any bugs involving
>> +        * loading a PCID-enabled CR3 with CR4.PCIDE off will trigger
>> +        * deterministically.
>> +        */
>> +       return asid + 1;
>> +}
> This seems really error-prone.  Maybe we should have a pcid_t type and
> make all the interfaces that want a h/w PCID take pcid_t.

Yeah, totally agree.  I actually had a nasty bug or two around this area
because of this.

I divided them among hw_asid_t and sw_asid_t.  You can turn a sw_asid_t
into a kernel hw_asid_t or a user hw_asid_t.  But, it cause too much
churn across the TLB flushing code so I shelved it for now.

I'd love to come back nd fix this up properly though.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
