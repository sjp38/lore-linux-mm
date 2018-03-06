Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 470D26B0005
	for <linux-mm@kvack.org>; Tue,  6 Mar 2018 08:46:00 -0500 (EST)
Received: by mail-pl0-f71.google.com with SMTP id 62-v6so9860655ply.4
        for <linux-mm@kvack.org>; Tue, 06 Mar 2018 05:46:00 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id e89si12013320pfm.198.2018.03.06.05.45.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Mar 2018 05:45:58 -0800 (PST)
Subject: Re: [PATCH 07/34] x86/entry/32: Restore segments before int registers
References: <1520245563-8444-1-git-send-email-joro@8bytes.org>
 <1520245563-8444-8-git-send-email-joro@8bytes.org>
 <CA+55aFym-18UbD5K3n1Ki=mvpuLqa7E6E=qG0aE-dctzTap_WQ@mail.gmail.com>
 <20180305131231.GR16484@8bytes.org>
 <CA+55aFwn5EkHTfrUFww54CDWovoUornv6rSrao43agbLBQD6-Q@mail.gmail.com>
 <CAMzpN2hscOXJFzm07Hk=2Ttr3wQFSisxP=EZhRMtAU6xSm8zSw@mail.gmail.com>
 <CA+55aFwxiZ9bD2Zu5xV0idz_dDctPvrrWA2r54+NL4aj9oeN8Q@mail.gmail.com>
 <20180305213550.GV16484@8bytes.org>
 <CA+55aFx2dxZmL487CnhV6rWRiqmJwZNAspyPqCD4Hwqxwncs6Q@mail.gmail.com>
 <12c11262-5e0f-2987-0a74-3bde4b66c352@zytor.com>
 <20180306070437.kf3fkevqj6cuxptz@gmail.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <6224cf9e-4c13-58e5-4541-c06074a20191@intel.com>
Date: Tue, 6 Mar 2018 05:45:56 -0800
MIME-Version: 1.0
In-Reply-To: <20180306070437.kf3fkevqj6cuxptz@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Joerg Roedel <joro@8bytes.org>, Brian Gerst <brgerst@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, the arch/x86 maintainers <x86@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Lutomirski <luto@kernel.org>, Josh Poimboeuf <jpoimboe@redhat.com>, =?UTF-8?B?SsO8cmdlbiBHcm/Dnw==?= <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, Joerg Roedel <jroedel@suse.de>

On 03/05/2018 11:04 PM, Ingo Molnar wrote:
> * H. Peter Anvin <hpa@zytor.com> wrote:
>> On NX-enabled hardware NX works with PDE, but the PDPDT in general doesn't
>> have permission bits (it's really more of a set of four CR3s than a page
>> table level.)
> The 4 PDPDT entries are also shadowed in the CPU and are only refreshed
> on CR3 loads, not spontaneously reloaded from memory during TLB walk
> like regular page table entries, right?

Yes.  The SDM even calls them non-architectural "PDPTE Registers" and
talks about them only being loaded at CR3 write time.

~5 years ago we even had a bug directly related to this feature:

> https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git/commit/?id=324cdc3f7e6a752fe0e95fa7b5c9664171a34ded

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
