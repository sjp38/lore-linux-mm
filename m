Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f53.google.com (mail-la0-f53.google.com [209.85.215.53])
	by kanga.kvack.org (Postfix) with ESMTP id 8CF706B0038
	for <linux-mm@kvack.org>; Wed, 18 Mar 2015 11:08:09 -0400 (EDT)
Received: by lamx15 with SMTP id x15so38591446lam.3
        for <linux-mm@kvack.org>; Wed, 18 Mar 2015 08:08:08 -0700 (PDT)
Received: from mail-la0-x236.google.com (mail-la0-x236.google.com. [2a00:1450:4010:c03::236])
        by mx.google.com with ESMTPS id o3si13099910lbh.93.2015.03.18.08.08.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Mar 2015 08:08:07 -0700 (PDT)
Received: by lamx15 with SMTP id x15so38590444lam.3
        for <linux-mm@kvack.org>; Wed, 18 Mar 2015 08:08:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <550987AD.8020409@intel.com>
References: <20150318083040.7838.76933.stgit@zurg>
	<550987AD.8020409@intel.com>
Date: Wed, 18 Mar 2015 18:08:06 +0300
Message-ID: <CALYGNiPPgaKb6_Pyo1SZ8sjgSbgC0yXFfZ2OwUN5=mSdTypcAA@mail.gmail.com>
Subject: Re: [PATCH RFC] mm: protect suid binaries against rowhammer with
 copy-on-read mappings
From: Konstantin Khlebnikov <koct9i@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>

On Wed, Mar 18, 2015 at 5:11 PM, Dave Hansen <dave.hansen@intel.com> wrote:
> On 03/18/2015 01:30 AM, Konstantin Khlebnikov wrote:
>> +             /*
>> +              * Read-only SUID/SGID binares are mapped as copy-on-read
>> +              * this protects them against exploiting with Rowhammer.
>> +              */
>> +             if (!(file->f_mode & FMODE_WRITE) &&
>> +                 ((inode->i_mode & S_ISUID) || ((inode->i_mode & S_ISGID) &&
>> +                         (inode->i_mode & S_IXGRP)))) {
>> +                     vm_flags &= ~(VM_SHARED | VM_MAYSHARE);
>> +                     vm_flags |= VM_COR;
>> +             }
>
> I think we probably need to come to _some_ sort of understanding in the
> kernel of how much we are willing to do to thwart these kinds of
> attacks.  I suspect it's a very deep rabbit hole.
>
> For this particular case, I don't see how this would be effective.  The
> existing exploit which you reference attacks PTE pages which are
> unmapped in to the user address space.  I'm confused how avoiding
> mapping a page in to an attacker's process can keep it from being exploited.
>
> Right now, there's a relatively small number of pages that will get
> COW'd for a SUID binary.  This greatly increases the number which could
> allow spraying of these (valuable) copy-on-read pages.

Yeah, on second thought that copy-on-read gives the same security
level as hiding pfns from userspace. Sorry for the noise.

It seems the only option is memory zoning: kernel should allocate all
normal memory for userspace from isolated area which is kept far far
away from important data.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
