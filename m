Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2CF9D6B0498
	for <linux-mm@kvack.org>; Thu, 17 May 2018 06:09:40 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id t24-v6so3382056qtn.7
        for <linux-mm@kvack.org>; Thu, 17 May 2018 03:09:40 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id r47-v6si3937355qtb.46.2018.05.17.03.09.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 May 2018 03:09:39 -0700 (PDT)
Subject: Re: [PATCH] pkeys: Introduce PKEY_ALLOC_SIGNALINHERIT and change
 signal semantics
References: <CALCETrVrm6yGiv6_z7RqdeB-324RoeMmjpf1EHsrGOh+iKb7+A@mail.gmail.com>
 <b2df1386-9df9-2db8-0a25-51bf5ff63592@redhat.com>
 <CALCETrW_Dt-HoG4keFJd8DSD=tvyR+bBCFrBDYdym4GQbfng4A@mail.gmail.com>
 <20180503021058.GA5670@ram.oc3035372033.ibm.com>
 <CALCETrXRQF08exQVZqtTLOKbC8Ywq5x4EYH_1D7r5v9bdOSwbg@mail.gmail.com>
 <927c8325-4c98-d7af-b921-6aafcf8fe992@redhat.com>
 <CALCETrX46wR_MDW=m9SVm=ejQmPAmD3+2oC3iapf75bPhnEAWQ@mail.gmail.com>
 <314e1a48-db94-9b37-8793-a95a2082c9e2@redhat.com>
 <20180516203534.GA5479@ram.oc3035372033.ibm.com>
 <CALCETrVQs=ix-w9_MLJWikzmBG-e2Fzg61TrZLNVv5R3XFOs=g@mail.gmail.com>
 <20180516210745.GC5479@ram.oc3035372033.ibm.com>
From: Florian Weimer <fweimer@redhat.com>
Message-ID: <1a46685f-1ca7-d215-455c-c75254959684@redhat.com>
Date: Thu, 17 May 2018 12:09:36 +0200
MIME-Version: 1.0
In-Reply-To: <20180516210745.GC5479@ram.oc3035372033.ibm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>, Andy Lutomirski <luto@kernel.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Linux-MM <linux-mm@kvack.org>, Linux API <linux-api@vger.kernel.org>, linux-x86_64@vger.kernel.org, linux-arch <linux-arch@vger.kernel.org>, X86 ML <x86@kernel.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>

On 05/16/2018 11:07 PM, Ram Pai wrote:

> what would change the key-permission-values enforced in signal-handler
> context?  Or can it never be changed, ones set through sys_pkey_alloc()?

The access rights can only be set by pkey_alloc and are unchanged after 
that (so we do not have to discuss whether the signal handler access 
rights are per-thread or not).

> I suppose key-permission-values change done in non-signal-handler context,
> will not apply to those in signal-handler context.

Correct, that is the plan.

> Can the signal handler change the key-permission-values from the
> signal-handler context?

Yes, changes are possible.  The access rights given to pkey_alloc only 
specify the initial access rights when the signal handler is entered.

We need to decide if we should restore it on exit from the signal 
handler.  There is also the matter of siglongjmp, which currently does 
not restore the current thread's access rights.  In general, this might 
be difficult to implement because of the limited space in jmp_buf.

Thanks,
Florian
