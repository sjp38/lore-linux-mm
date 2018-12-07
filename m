Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6375B8E0004
	for <linux-mm@kvack.org>; Fri,  7 Dec 2018 18:53:31 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id b17so4662813pfc.11
        for <linux-mm@kvack.org>; Fri, 07 Dec 2018 15:53:31 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id m38si4019960pgl.125.2018.12.07.15.53.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Dec 2018 15:53:30 -0800 (PST)
Received: from mail-wm1-f45.google.com (mail-wm1-f45.google.com [209.85.128.45])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id C074C2146D
	for <linux-mm@kvack.org>; Fri,  7 Dec 2018 23:53:29 +0000 (UTC)
Received: by mail-wm1-f45.google.com with SMTP id q26so5999148wmf.5
        for <linux-mm@kvack.org>; Fri, 07 Dec 2018 15:53:29 -0800 (PST)
MIME-Version: 1.0
References: <cover.1543903910.git.alison.schofield@intel.com>
 <CALCETrUqqQiHR_LJoKB2JE6hCZ-e7LiFprEhmo-qoegDZJ9uYQ@mail.gmail.com>
 <c610138f-32dd-a24c-dc52-4e0006a21409@intel.com> <CALCETrU34U3berTaEQbvNt0rfCdsjwj+xDb8x7bgAMFHEo=eUw@mail.gmail.com>
 <1544147742.28511.18.camel@intel.com>
In-Reply-To: <1544147742.28511.18.camel@intel.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Fri, 7 Dec 2018 15:53:16 -0800
Message-ID: <CALCETrWHqE-H1jTJY-ApuuLt5cyZ3N1UdgH+szgYm+7mUMZ2pg@mail.gmail.com>
Subject: Re: [RFC v2 00/13] Multi-Key Total Memory Encryption API (MKTME)
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kai.huang@intel.com
Cc: Andrew Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, James Morris <jmorris@namei.org>, Peter Zijlstra <peterz@infradead.org>, keyrings@vger.kernel.org, Matthew Wilcox <willy@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Linux-MM <linux-mm@kvack.org>, David Howells <dhowells@redhat.com>, LSM List <linux-security-module@vger.kernel.org>, Dan Williams <dan.j.williams@intel.com>, X86 ML <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, "Sakkinen, Jarkko" <jarkko.sakkinen@intel.com>, Borislav Petkov <bp@alien8.de>, Alison Schofield <alison.schofield@intel.com>, Jun Nakajima <jun.nakajima@intel.com>

> On Dec 6, 2018, at 5:55 PM, Huang, Kai <kai.huang@intel.com> wrote:
>
>
>>
>> TME itself provides a ton of protection -- you can't just barge into
>> the datacenter, refrigerate the DIMMs, walk away with them, and read
>> off everyone's data.
>>
>> Am I missing something?
>
> I think we can make such assumption in most cases, but I think it's bette=
r that we don't make any
> assumption at all. For example, the admin of data center (or anyone) who =
has physical access to
> servers may do something malicious. I am not expert but there should be o=
ther physical attack
> methods besides coldboot attack, if the malicious employee can get physic=
al access to server w/o
> being detected.
>
>>
>>>
>>> But, I think what you're implying is that the security properties of
>>> user-supplied keys can only be *worse* than using CPU-generated keys
>>> (assuming the CPU does a good job generating it).  So, why bother
>>> allowing user-specified keys in the first place?
>>
>> That too :)
>
> I think one usage of user-specified key is for NVDIMM, since CPU key will=
 be gone after machine
> reboot, therefore if NVDIMM is encrypted by CPU key we are not able to re=
trieve it once
> shutdown/reboot, etc.
>
> There are some other use cases that already require tenant to send key to=
 CSP. For example, the VM
> image can be provided by tenant and encrypted by tenant's own key, and te=
nant needs to send key to
> CSP when asking CSP to run that encrypted image.


I can imagine a few reasons why one would want to encrypt one=E2=80=99s ima=
ge.
For example, the CSP could issue a public key and state, or even
attest, that the key is wrapped and locked to particular PCRs of their
TPM or otherwise protected by an enclave that verifies that the key is
only used to decrypt the image for the benefit of a hypervisor.

I don=E2=80=99t see what MKTME has to do with this.  The only remotely
plausible way I can see to use MKTME for this is to have the
hypervisor load a TPM (or other enclave) protected key into an MKTME
user key slot and to load customer-provided ciphertext into the
corresponding physical memory (using an MKTME no-encrypt slot).  But
this has three major problems.  First, it's effectively just a fancy
way to avoid one AES pass over the data.  Second, sensible scheme for
this type of VM image protection would use *authenticated* encryption
or at least verify a signature, which MKTME can't do.  The third
problem is the real show-stopper, though: this scheme requires that
the ciphertext go into predetermined physical addresses, which would
be a giant mess.
