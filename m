Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 13C216B02B4
	for <linux-mm@kvack.org>; Tue,  8 Aug 2017 09:01:02 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id g71so4444771wmg.13
        for <linux-mm@kvack.org>; Tue, 08 Aug 2017 06:01:02 -0700 (PDT)
Received: from lhrrgout.huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id i31si1113367wri.344.2017.08.08.06.01.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 08 Aug 2017 06:01:00 -0700 (PDT)
Subject: Re: [RFC] Tagging of vmalloc pages for supporting the pmalloc
 allocator
References: <c3a250a6-ad4d-d24d-d0bf-4c43c467ebe6@huawei.com>
 <20170803135549.GW12521@dhcp22.suse.cz> <20170803144746.GA9501@redhat.com>
 <ab4809cd-0efc-a79d-6852-4bd2349a2b3f@huawei.com>
 <20170803151550.GX12521@dhcp22.suse.cz>
 <abe0c086-8c5a-d6fb-63c4-bf75528d0ec5@huawei.com>
 <20170804081240.GF26029@dhcp22.suse.cz>
 <7733852a-67c9-17a3-4031-cb08520b9ad2@huawei.com>
 <20170807133107.GA16616@redhat.com>
 <555dc453-3028-199a-881a-3ddeb41e4d6d@huawei.com>
 <20170807191235.GE16616@redhat.com>
From: Igor Stoppa <igor.stoppa@huawei.com>
Message-ID: <c06fdd1a-fb18-8e17-b4fb-ea73ccd93f90@huawei.com>
Date: Tue, 8 Aug 2017 15:59:36 +0300
MIME-Version: 1.0
In-Reply-To: <20170807191235.GE16616@redhat.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-security-module@vger.kernel.org, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, Kees Cook <keescook@google.com>

On 07/08/17 22:12, Jerome Glisse wrote:
> On Mon, Aug 07, 2017 at 05:13:00PM +0300, Igor Stoppa wrote:

[...]

>> I have an updated version of the old proposal:
>>
>> * put a magic number in the private field, during initialization of
>> pmalloc pages
>>
>> * during hardened usercopy verification, when I have to assess if a page
>> is of pmalloc type, compare the private field against the magic number
>>
>> * if and only if the private field matches the magic number, then invoke
>> find_vm_area(), so that the slowness affects only a possibly limited
>> amount of false positives.
> 
> This all sounds good to me.

ok, I still have one doubt wrt defining the flag.
Where should I do it?

vmalloc.h has the following:

/* bits in flags of vmalloc's vm_struct below */
#define VM_IOREMAP		0x00000001	/* ioremap() and friends
						*/
#define VM_ALLOC		0x00000002	/* vmalloc() */
#define VM_MAP			0x00000004	/* vmap()ed pages */
#define VM_USERMAP		0x00000008	/* suitable for
						   remap_vmalloc_range
						*/
#define VM_UNINITIALIZED	0x00000020	/* vm_struct is not
						   fully initialized */
#define VM_NO_GUARD		0x00000040      /* don't add guard page
						*/
#define VM_KASAN		0x00000080      /* has allocated kasan
						shadow memory */
/* bits [20..32] reserved for arch specific ioremap internals */



I am tempted to add

#define VM_PMALLOC		0x00000100

But would it be acceptable, to mention pmalloc into vmalloc?

Should I name it VM_PRIVATE bit, instead?

Using VM_PRIVATE would avoid contaminating vmalloc with something that
depends on it (like VM_PMALLOC would do).

But using VM_PRIVATE will likely add tracking issues, if someone else
wants to use the same bit and it's not clear who is the user, if any.

Unless it's acceptable to check the private field in the page struct.
It would bear the pmalloc magic number.

I'm thinking to use a pointer to one of pmalloc data items, as signature.


--
igor

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
