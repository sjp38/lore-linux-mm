Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id B34B76B025F
	for <linux-mm@kvack.org>; Mon,  7 Aug 2017 10:14:10 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id i187so1138663wma.15
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 07:14:10 -0700 (PDT)
Received: from lhrrgout.huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id u107si8545488wrc.554.2017.08.07.07.14.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 07 Aug 2017 07:14:09 -0700 (PDT)
Subject: Re: [RFC] Tagging of vmalloc pages for supporting the pmalloc
 allocator
References: <8e82639c-40db-02ce-096a-d114b0436d3c@huawei.com>
 <20170803114844.GO12521@dhcp22.suse.cz>
 <c3a250a6-ad4d-d24d-d0bf-4c43c467ebe6@huawei.com>
 <20170803135549.GW12521@dhcp22.suse.cz> <20170803144746.GA9501@redhat.com>
 <ab4809cd-0efc-a79d-6852-4bd2349a2b3f@huawei.com>
 <20170803151550.GX12521@dhcp22.suse.cz>
 <abe0c086-8c5a-d6fb-63c4-bf75528d0ec5@huawei.com>
 <20170804081240.GF26029@dhcp22.suse.cz>
 <7733852a-67c9-17a3-4031-cb08520b9ad2@huawei.com>
 <20170807133107.GA16616@redhat.com>
From: Igor Stoppa <igor.stoppa@huawei.com>
Message-ID: <555dc453-3028-199a-881a-3ddeb41e4d6d@huawei.com>
Date: Mon, 7 Aug 2017 17:13:00 +0300
MIME-Version: 1.0
In-Reply-To: <20170807133107.GA16616@redhat.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-security-module@vger.kernel.org, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, Kees Cook <keescook@google.com>



On 07/08/17 16:31, Jerome Glisse wrote:
> On Mon, Aug 07, 2017 at 02:26:21PM +0300, Igor Stoppa wrote:

[...]

>> I'll add a vm_area field as you advised.
>>
>> Is this something I could send as standalone patch?
> 
> Note that vmalloc() is not the only thing that use vmalloc address
> space. There is also vmap() and i know one set of drivers that use
> vmap() and also use the mapping field of struct page namely GPU
> drivers.

Ah, yes, you mentioned this.

> So like i said previously i would store a flag inside vm_struct to
> know if page you are looking at are pmalloc or not.

And I was planning to follow your advice, using one of the flags.
But ...

> Again do you
> need to store something per page ? Would storing it per vm_struct
> not be enough ?

... there was this further comment, about speeding up the access to
vm_area, which seemed good from performance perspective.

---8<--------------8<--------------8<--------------8<--------------8<---
On 03/08/17 14:48, Michal Hocko wrote:
> On Thu 03-08-17 13:11:45, Igor Stoppa wrote:

[...]

>> But, to reply more specifically to your advice, yes, I think I could
>> add a flag to vm_struct and then retrieve its value, for the address
>> being processed, by passing through find_vm_area().
>
> ... and you can store vm_struct pointer to the struct page there and
> you won't need to do the slow find_vm_area. I haven't checked very
> closely but this should be possible in principle. I guess other
> callers might benefit from this as well.
---8<--------------8<--------------8<--------------8<--------------8<---

I do not strictly need to modify the page struct, but it seems it might
harm performance, if it is added on the path of hardened usercopy.

I have an updated version of the old proposal:

* put a magic number in the private field, during initialization of
pmalloc pages

* during hardened usercopy verification, when I have to assess if a page
is of pmalloc type, compare the private field against the magic number

* if and only if the private field matches the magic number, then invoke
find_vm_area(), so that the slowness affects only a possibly limited
amount of false positives.


--
igor

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
