Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id AB38C6B0273
	for <linux-mm@kvack.org>; Thu,  4 Oct 2018 03:48:47 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id u28-v6so7608993qtu.3
        for <linux-mm@kvack.org>; Thu, 04 Oct 2018 00:48:47 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t68-v6si2271589qkc.395.2018.10.04.00.48.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Oct 2018 00:48:46 -0700 (PDT)
Subject: Re: [PATCH RFC] mm/memory_hotplug: Introduce memory block types
References: <20180928150357.12942-1-david@redhat.com>
 <5dba97a5-5a18-5df1-5493-99987679cf3a@linux.intel.com>
 <147d20c7-2a07-2305-9b44-76fdb735173b@redhat.com>
 <05493150-5e4e-30bd-f772-0c6d88240030@linux.intel.com>
From: David Hildenbrand <david@redhat.com>
Message-ID: <746a61c2-ebc7-abff-3bcd-7e307ef449bd@redhat.com>
Date: Thu, 4 Oct 2018 09:48:32 +0200
MIME-Version: 1.0
In-Reply-To: <05493150-5e4e-30bd-f772-0c6d88240030@linux.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>, linux-mm@kvack.org
Cc: xen-devel@lists.xenproject.org, devel@linuxdriverproject.org, linux-acpi@vger.kernel.org, linux-sh@vger.kernel.org, linux-s390@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "K. Y. Srinivasan" <kys@microsoft.com>, Haiyang Zhang <haiyangz@microsoft.com>, Stephen Hemminger <sthemmin@microsoft.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Dan Williams <dan.j.williams@intel.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Nicholas Piggin <npiggin@gmail.com>, =?UTF-8?Q?Jonathan_Neusch=c3=a4fer?= <j.neuschaefer@gmx.net>, Joe Perches <joe@perches.com>, Michael Neuling <mikey@neuling.org>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Balbir Singh <bsingharora@gmail.com>, Rashmica Gupta <rashmica.g@gmail.com>, Pavel Tatashin <pavel.tatashin@microsoft.com>, Rob Herring <robh@kernel.org>, Philippe Ombredanne <pombredanne@nexb.com>, Kate Stewart <kstewart@linuxfoundation.org>, "mike.travis@hpe.com" <mike.travis@hpe.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Oscar Salvador <osalvador@suse.de>, Mathieu Malaterre <malat@debian.org>

On 01/10/2018 18:24, Dave Hansen wrote:
>> How should a policy in user space look like when new memory gets added
>> - on s390x? Not onlining paravirtualized memory is very wrong.
> 
> Because we're going to balloon it away in a moment anyway?

No, rether somebody wanted this VM to have more memory, so it should use
it - basically what HyperV or XEN also do. (in contrast to the concept
of standby memory on s390).

> > We have auto-onlining.  Why isn't that being used on s390?

Do you mean the sys parameter? How would that help?

> 
> 
>> So the type of memory is very important here to have in user space.
>> Relying on checks like "isS390()", "isKVMGuest()" or "isHyperVGuest()"
>> to decide whether to online memory and how to online memory is wrong.
>> Only some specific memory types (which I call "normal") are to be
>> handled by user space.
>>
>> For the other ones, we exactly know what to do:
>> - standby? don't online
> 
> I think you're horribly conflating the software desire for what the stae
> should be and the hardware itself.

Agreed, user space should be able to configure it.

> 
>>> As for the OOM issues, that sounds like something we need to fix by
>>> refusing to do (or delaying) hot-add operations once we consume too much
>>> ZONE_NORMAL from memmap[]s rather than trying to indirectly tell
>>> userspace to hurry thing along.
>>
>> That is a moving target and doing that automatically is basically
>> impossible.
> 
> Nah.  We know how much metadata we've allocated.  We know how much
> ZONE_NORMAL we are eating.  We can *easily* add something to
> add_memory() that just sleeps until the ratio is not out-of-whack.
> 
>> You can add a lot of memory to the movable zone and
>> everything is fine. Suddenly a lot of processes are started - boom.
>> MOVABLE should only every be used if you expect an unplug. And for
>> paravirtualized devices, a "typical" unplug does not exist.
> 
> No, it's more complicated than that.  People use MOVABLE, for instance,
> to allow more consistent huge page allocations.  It's certainly not just
> hot-remove.
> 

As noted in the other thread, that's a good point. We have to allow to
make a decision in user space.

I agree to your initial proposal to distinguish "standby" from
"auto-online". It would allow to have sane defaults in user space.

-- 

Thanks,

David / dhildenb
