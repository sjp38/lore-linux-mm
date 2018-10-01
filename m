Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1C4E86B0006
	for <linux-mm@kvack.org>; Mon,  1 Oct 2018 12:24:44 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id s1-v6so17081567pfm.22
        for <linux-mm@kvack.org>; Mon, 01 Oct 2018 09:24:44 -0700 (PDT)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id z2-v6si12840569pfn.13.2018.10.01.09.24.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Oct 2018 09:24:43 -0700 (PDT)
Subject: Re: [PATCH RFC] mm/memory_hotplug: Introduce memory block types
References: <20180928150357.12942-1-david@redhat.com>
 <5dba97a5-5a18-5df1-5493-99987679cf3a@linux.intel.com>
 <147d20c7-2a07-2305-9b44-76fdb735173b@redhat.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <05493150-5e4e-30bd-f772-0c6d88240030@linux.intel.com>
Date: Mon, 1 Oct 2018 09:24:35 -0700
MIME-Version: 1.0
In-Reply-To: <147d20c7-2a07-2305-9b44-76fdb735173b@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>, linux-mm@kvack.org
Cc: xen-devel@lists.xenproject.org, devel@linuxdriverproject.org, linux-acpi@vger.kernel.org, linux-sh@vger.kernel.org, linux-s390@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "K. Y. Srinivasan" <kys@microsoft.com>, Haiyang Zhang <haiyangz@microsoft.com>, Stephen Hemminger <sthemmin@microsoft.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Dan Williams <dan.j.williams@intel.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Nicholas Piggin <npiggin@gmail.com>, =?UTF-8?Q?Jonathan_Neusch=c3=a4fer?= <j.neuschaefer@gmx.net>, Joe Perches <joe@perches.com>, Michael Neuling <mikey@neuling.org>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Balbir Singh <bsingharora@gmail.com>, Rashmica Gupta <rashmica.g@gmail.com>, Pavel Tatashin <pavel.tatashin@microsoft.com>, Rob Herring <robh@kernel.org>, Philippe Ombredanne <pombredanne@nexb.com>, Kate Stewart <kstewart@linuxfoundation.org>, "mike.travis@hpe.com" <mike.travis@hpe.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Oscar Salvador <osalvador@suse.de>, Mathieu Malaterre <malat@debian.org>

> How should a policy in user space look like when new memory gets added
> - on s390x? Not onlining paravirtualized memory is very wrong.

Because we're going to balloon it away in a moment anyway?

We have auto-onlining.  Why isn't that being used on s390?


> So the type of memory is very important here to have in user space.
> Relying on checks like "isS390()", "isKVMGuest()" or "isHyperVGuest()"
> to decide whether to online memory and how to online memory is wrong.
> Only some specific memory types (which I call "normal") are to be
> handled by user space.
> 
> For the other ones, we exactly know what to do:
> - standby? don't online

I think you're horribly conflating the software desire for what the stae
should be and the hardware itself.

>> As for the OOM issues, that sounds like something we need to fix by
>> refusing to do (or delaying) hot-add operations once we consume too much
>> ZONE_NORMAL from memmap[]s rather than trying to indirectly tell
>> userspace to hurry thing along.
> 
> That is a moving target and doing that automatically is basically
> impossible.

Nah.  We know how much metadata we've allocated.  We know how much
ZONE_NORMAL we are eating.  We can *easily* add something to
add_memory() that just sleeps until the ratio is not out-of-whack.

> You can add a lot of memory to the movable zone and
> everything is fine. Suddenly a lot of processes are started - boom.
> MOVABLE should only every be used if you expect an unplug. And for
> paravirtualized devices, a "typical" unplug does not exist.

No, it's more complicated than that.  People use MOVABLE, for instance,
to allow more consistent huge page allocations.  It's certainly not just
hot-remove.
