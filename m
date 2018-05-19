Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 336306B06B7
	for <linux-mm@kvack.org>; Fri, 18 May 2018 21:50:54 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id l85-v6so5682560pfb.18
        for <linux-mm@kvack.org>; Fri, 18 May 2018 18:50:54 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 62-v6si8251253pld.133.2018.05.18.18.50.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 May 2018 18:50:52 -0700 (PDT)
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 33B922085B
	for <linux-mm@kvack.org>; Sat, 19 May 2018 01:50:52 +0000 (UTC)
Received: by mail-wm0-f46.google.com with SMTP id f6-v6so16825023wmc.4
        for <linux-mm@kvack.org>; Fri, 18 May 2018 18:50:52 -0700 (PDT)
MIME-Version: 1.0
References: <53828769-23c4-b2e3-cf59-239936819c3e@redhat.com> <20180519011947.GJ5479@ram.oc3035372033.ibm.com>
In-Reply-To: <20180519011947.GJ5479@ram.oc3035372033.ibm.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Fri, 18 May 2018 18:50:39 -0700
Message-ID: <CALCETrWMP9kTmAFCR0WHR3YP93gLSzgxhfnb0ma_0q=PCuSdQA@mail.gmail.com>
Subject: Re: pkeys on POWER: Access rights not reset on execve
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxram@us.ibm.com
Cc: Florian Weimer <fweimer@redhat.com>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, Linux-MM <linux-mm@kvack.org>, Dave Hansen <dave.hansen@intel.com>

On Fri, May 18, 2018 at 6:19 PM Ram Pai <linuxram@us.ibm.com> wrote:

> However the fundamental issue is still the same, as mentioned in the
> other thread.

> "Should the permissions on a key be allowed to be changed, if the key
> is not allocated in the first place?".

> my answer is NO. Lets debate :)

As a preface, here's my two-minute attempt to understand POWER's behavior:
there are two registers, AMR and UAMR.  AMR contains both kernel-relevant
state and user-relevant state.  UAMR specifies which bits of AMR are
available for user code to directly access.  AMR bits outside UAMR are read
as zero and are unaffected by writes.  I'm assuming that the kernel
reserves some subset of AMR bits in advance to correspond to allocatable
pkeys.

Here's my question: given that disallowed AMR bits are read-as-zero, there
can always be a thread that is in the middle of a sequence like:

unsigned long old = amr;
amr |= whatever;
...  <- thread is here
amr = old;

Now another thread calls pkey_alloc(), so UAMR is asynchronously changed,
and the thread will write zero to the relevant AMR bits.  If I understand
correctly, this means that the decision to mask off unallocated keys via
UAMR effectively forces the initial value of newly-allocated keys in other
threads in the allocating process to be zero, whatever zero means.  (I
didn't get far enough in the POWER docs to figure out what zero means.)  So
I don't think you're doing anyone any favors by making UAMR dynamic.

IOW both x86 and POWER screwed up the ISA.
