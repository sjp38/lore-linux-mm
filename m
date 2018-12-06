Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id EAB406B7756
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 20:26:07 -0500 (EST)
Received: by mail-ot1-f69.google.com with SMTP id q16so10320714otf.5
        for <linux-mm@kvack.org>; Wed, 05 Dec 2018 17:26:07 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z24sor12962676otj.26.2018.12.05.17.26.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 05 Dec 2018 17:26:06 -0800 (PST)
MIME-Version: 1.0
References: <cover.1543903910.git.alison.schofield@intel.com>
 <CALCETrUqqQiHR_LJoKB2JE6hCZ-e7LiFprEhmo-qoegDZJ9uYQ@mail.gmail.com>
 <c610138f-32dd-a24c-dc52-4e0006a21409@intel.com> <CALCETrU34U3berTaEQbvNt0rfCdsjwj+xDb8x7bgAMFHEo=eUw@mail.gmail.com>
In-Reply-To: <CALCETrU34U3berTaEQbvNt0rfCdsjwj+xDb8x7bgAMFHEo=eUw@mail.gmail.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 5 Dec 2018 17:25:55 -0800
Message-ID: <CAPcyv4gg5ymssw75q9k8NwwPrstDUrqmCEeU_VNU=rKEM7izGg@mail.gmail.com>
Subject: Re: [RFC v2 00/13] Multi-Key Total Memory Encryption API (MKTME)
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Dave Hansen <dave.hansen@intel.com>, "Schofield, Alison" <alison.schofield@intel.com>, Matthew Wilcox <willy@infradead.org>, David Howells <dhowells@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, James Morris <jmorris@namei.org>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Borislav Petkov <bp@alien8.de>, Peter Zijlstra <peterz@infradead.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "Huang, Kai" <kai.huang@intel.com>, "Nakajima, Jun" <jun.nakajima@intel.com>, Jarkko Sakkinen <jarkko.sakkinen@intel.com>, keyrings@vger.kernel.org, linux-security-module@vger.kernel.org, Linux MM <linux-mm@kvack.org>, X86 ML <x86@kernel.org>

[ only responding to the pmem side of things... ]

On Wed, Dec 5, 2018 at 5:09 PM Andy Lutomirski <luto@kernel.org> wrote:
>
> On Wed, Dec 5, 2018 at 3:49 PM Dave Hansen <dave.hansen@intel.com> wrote:
[..]
> > We also haven't settled on the file-backed properties.  For file-backed,
> > my hope was that you could do:
> >
> >         ptr = mmap(fd, size, prot);
> >         printf("ciphertext: %x\n", *ptr);
> >         mprotect_encrypt(ptr, len, prot, keyid);
> >         printf("plaintext: %x\n", *ptr);
>
> Why would you ever want the plaintext?  Also, how does this work on a
> normal fs, where relocation of the file would cause the ciphertext to
> get lost?  It really seems to be that it should look more like
> dm-crypt where you encrypt a filesystem.  Maybe you'd just configure
> the pmem device to be encrypted before you mount it, or you'd get a
> new pmem-mktme device node instead.  This would also avoid some nasty
> multiple-copies-of-the-direct-map issue, since you'd only ever have
> one of them mapped.

Yes, this is really the only way it can work. Otherwise you need to
teach the filesystem that "these blocks can't move without the key
because encryption", and have an fs-feature flag to say "you can't
mount this legacy / encryption unaware filesystem from an older kernel
because we're not sure you'll move something and break the
encryption".

So pmem namespaces (volumes) would be encrypted providing something
similar to dm-crypt, although we're looking at following the lead of
the fscrypt key management scheme.
