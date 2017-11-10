Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 64AF52802A5
	for <linux-mm@kvack.org>; Fri, 10 Nov 2017 17:11:16 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id y128so8753155pfg.5
        for <linux-mm@kvack.org>; Fri, 10 Nov 2017 14:11:16 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id n22si9817428plp.580.2017.11.10.14.11.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Nov 2017 14:11:15 -0800 (PST)
Received: from mail-it0-f51.google.com (mail-it0-f51.google.com [209.85.214.51])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 2EDC521987
	for <linux-mm@kvack.org>; Fri, 10 Nov 2017 22:11:15 +0000 (UTC)
Received: by mail-it0-f51.google.com with SMTP id 72so3325040itl.5
        for <linux-mm@kvack.org>; Fri, 10 Nov 2017 14:11:15 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <101307eb-b924-69ef-13dd-05e63fbaf587@linux.intel.com>
References: <20171110193058.BECA7D88@viggo.jf.intel.com> <20171110193146.5908BE13@viggo.jf.intel.com>
 <CALCETrXrXpTZE2sceBh=eW5kEP79hWc5iY36QKjfy=U4nTirDw@mail.gmail.com> <101307eb-b924-69ef-13dd-05e63fbaf587@linux.intel.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Fri, 10 Nov 2017 14:10:54 -0800
Message-ID: <CALCETrW4w+EEeSzP4J=hETaJ90grBR7Xes-4Dj7ketcvqE-gMw@mail.gmail.com>
Subject: Re: [PATCH 21/30] x86, mm: put mmu-to-h/w ASID translation in one place
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Andy Lutomirski <luto@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, moritz.lipp@iaik.tugraz.at, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, Linus Torvalds <torvalds@linux-foundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, X86 ML <x86@kernel.org>

On Fri, Nov 10, 2017 at 2:09 PM, Dave Hansen
<dave.hansen@linux.intel.com> wrote:
> On 11/10/2017 02:03 PM, Andy Lutomirski wrote:
>>> +static inline u16 kern_asid(u16 asid)
>>> +{
>>> +       VM_WARN_ON_ONCE(asid > MAX_ASID_AVAILABLE);
>>> +       /*
>>> +        * If PCID is on, ASID-aware code paths put the ASID+1 into the PCID
>>> +        * bits.  This serves two purposes.  It prevents a nasty situation in
>>> +        * which PCID-unaware code saves CR3, loads some other value (with PCID
>>> +        * == 0), and then restores CR3, thus corrupting the TLB for ASID 0 if
>>> +        * the saved ASID was nonzero.  It also means that any bugs involving
>>> +        * loading a PCID-enabled CR3 with CR4.PCIDE off will trigger
>>> +        * deterministically.
>>> +        */
>>> +       return asid + 1;
>>> +}
>> This seems really error-prone.  Maybe we should have a pcid_t type and
>> make all the interfaces that want a h/w PCID take pcid_t.
>
> Yeah, totally agree.  I actually had a nasty bug or two around this area
> because of this.
>
> I divided them among hw_asid_t and sw_asid_t.  You can turn a sw_asid_t
> into a kernel hw_asid_t or a user hw_asid_t.  But, it cause too much
> churn across the TLB flushing code so I shelved it for now.
>
> I'd love to come back nd fix this up properly though.

In the long run, I would go with int for the sw asid and pcid_t for
the PCID.  After all, we index arrays with the SW one.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
