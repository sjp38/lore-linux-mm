Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2C0376B02F4
	for <linux-mm@kvack.org>; Wed,  9 Aug 2017 03:28:52 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id v102so7734133wrb.2
        for <linux-mm@kvack.org>; Wed, 09 Aug 2017 00:28:52 -0700 (PDT)
Received: from lhrrgout.huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id k103si2759013wrc.534.2017.08.09.00.28.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 09 Aug 2017 00:28:50 -0700 (PDT)
Subject: Re: [RFC] Tagging of vmalloc pages for supporting the pmalloc
 allocator
References: <20170803144746.GA9501@redhat.com>
 <ab4809cd-0efc-a79d-6852-4bd2349a2b3f@huawei.com>
 <20170803151550.GX12521@dhcp22.suse.cz>
 <abe0c086-8c5a-d6fb-63c4-bf75528d0ec5@huawei.com>
 <20170804081240.GF26029@dhcp22.suse.cz>
 <7733852a-67c9-17a3-4031-cb08520b9ad2@huawei.com>
 <20170807133107.GA16616@redhat.com>
 <555dc453-3028-199a-881a-3ddeb41e4d6d@huawei.com>
 <20170807191235.GE16616@redhat.com>
 <c06fdd1a-fb18-8e17-b4fb-ea73ccd93f90@huawei.com>
 <20170808231535.GA20840@redhat.com>
From: Igor Stoppa <igor.stoppa@huawei.com>
Message-ID: <b83b980d-8adb-52ea-9b62-af33aff8f898@huawei.com>
Date: Wed, 9 Aug 2017 10:27:32 +0300
MIME-Version: 1.0
In-Reply-To: <20170808231535.GA20840@redhat.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-security-module@vger.kernel.org, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, Kees Cook <keescook@google.com>



On 09/08/17 02:15, Jerome Glisse wrote:
> On Tue, Aug 08, 2017 at 03:59:36PM +0300, Igor Stoppa wrote:

[...]

>> I am tempted to add
>>
>> #define VM_PMALLOC		0x00000100

[...]

> VM_PMALLOC sounds fine to me also adding a comment there pointing to
> pmalloc documentation would be a good thing to do. The above are flags
> that are use only inside vmalloc context and so there is no issue
> here of conflicting with other potential user.

ok, will do

>>
>> Unless it's acceptable to check the private field in the page struct.
>> It would bear the pmalloc magic number.
> 
> I thought you wanted to do:
>   check struct page mapping field
>   check vmap->flags for VM_PMALLOC
> 
> bool is_pmalloc(unsigned long addr)
> {
>     struct page *page;
>     struct vm_struct *vm_struct;
> 
>     if (!is_vmalloc_addr(addr))
>         return false;
>     page = vmalloc_to_page(addr);
>     if (!page)
>         return false;
>     if (page->mapping != pmalloc_magic_key)

page->private  ?
I thought mapping would not work in the cases you mentioned?

>         return false;
> 
>     vm_struct = find_vm_area(addr);
>     if (!vm_struct)
>         return false;
> 
>     return vm_struct->flags & VM_PMALLOC;
> }
> 
> Did you change your plan ?

No, the code I have is almost 1:1 what you wrote.
Apart from mapping <=> private

In my previous mail I referred to page->private.

Maybe I was not very clear in what I wrote, but I'm almost 100% aligned
with your snippet.

>> I'm thinking to use a pointer to one of pmalloc data items, as signature.
> 
> What ever is easier for you. Note that dereferencing such pointer before
> asserting this is really a pmalloc page would be hazardous.

Yes, it's not even needed in this scenario.
It was just a way to ensure that it would be a value that cannot be come
out accidentally as pointer value, since it is already taken.

--
igor

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
