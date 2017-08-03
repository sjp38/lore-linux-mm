Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id DBEBC6B06A1
	for <linux-mm@kvack.org>; Thu,  3 Aug 2017 08:21:56 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id t18so914416oih.11
        for <linux-mm@kvack.org>; Thu, 03 Aug 2017 05:21:56 -0700 (PDT)
Received: from lhrrgout.huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id y139si21905039oia.5.2017.08.03.05.21.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 03 Aug 2017 05:21:56 -0700 (PDT)
Subject: Re: [RFC] Tagging of vmalloc pages for supporting the pmalloc
 allocator
References: <07063abd-2f5d-20d9-a182-8ae9ead26c3c@huawei.com>
 <20170802170848.GA3240@redhat.com>
 <8e82639c-40db-02ce-096a-d114b0436d3c@huawei.com>
 <20170803114844.GO12521@dhcp22.suse.cz>
From: Igor Stoppa <igor.stoppa@huawei.com>
Message-ID: <c3a250a6-ad4d-d24d-d0bf-4c43c467ebe6@huawei.com>
Date: Thu, 3 Aug 2017 15:20:31 +0300
MIME-Version: 1.0
In-Reply-To: <20170803114844.GO12521@dhcp22.suse.cz>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Jerome Glisse <jglisse@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-security-module@vger.kernel.org, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, Kees Cook <keescook@google.com>

On 03/08/17 14:48, Michal Hocko wrote:
> On Thu 03-08-17 13:11:45, Igor Stoppa wrote:
>> On 02/08/17 20:08, Jerome Glisse wrote:
>>> On Wed, Aug 02, 2017 at 06:14:28PM +0300, Igor Stoppa wrote:

[...]

>>>> from include/linux/mm_types.h:
>>>>
>>>> struct page {
>>>> ...
>>>>   union {
>>>>     unsigned long private;		/* Mapping-private opaque data:
>>>> 				 	 * usually used for buffer_heads
>>>> 					 * if PagePrivate set; used for
>>>> 					 * swp_entry_t if PageSwapCache;
>>>> 					 * indicates order in the buddy
>>>> 					 * system if PG_buddy is set.
>>>> 					 */

[...]

>> If the "Mapping-private" was dropped or somehow connected exclusively to
>> the cases listed in the comment, then I think it would be more clear
>> that the comment needs to be intended as related to mapping in certain
>> cases only.
>> But it is otherwise ok to use the "private" field for whatever purpose
>> it might be suitable, as long as it is not already in use.
> 
> I would recommend adding a new field into the enum...

s/enum/union/ ?

If not, I am not sure what is the enum that you are talking about.

[...]

>> But, to reply more specifically to your advice, yes, I think I could add
>> a flag to vm_struct and then retrieve its value, for the address being
>> processed, by passing through find_vm_area().
> 
> ... and you can store vm_struct pointer to the struct page there 

"there" as in the new field of the union?
btw, what would be a meaningful name, since "private" is already taken?

For simplicity, I'll use, for now, "private2"

> and you> won't need to do the slow find_vm_area. I haven't checked
very closely
> but this should be possible in principle. I guess other callers might
> benefit from this as well.

I am confused about this: if "private2" is a pointer, but when I get an
address, I do not even know if the address represents a valid pmalloc
page, how can i know when it's ok to dereference "private2"?

Since it's just another field in a union, it can actually contain a
value that should be interpreted as some other field, right?

--
thanks, igor

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
