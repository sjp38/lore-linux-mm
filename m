Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 310466B0006
	for <linux-mm@kvack.org>; Tue, 24 Apr 2018 11:29:09 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id y129so8873498pgb.5
        for <linux-mm@kvack.org>; Tue, 24 Apr 2018 08:29:09 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id p13-v6sor5464229pll.11.2018.04.24.08.29.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 24 Apr 2018 08:29:08 -0700 (PDT)
Subject: Re: [PATCH 7/9] Pmalloc Rare Write: modify selected pools
References: <20180423125458.5338-1-igor.stoppa@huawei.com>
 <20180423125458.5338-8-igor.stoppa@huawei.com>
 <20180424115050.GD26636@bombadil.infradead.org>
 <eb23fbd9-1b9e-8633-b0eb-241b8ad24d95@gmail.com>
 <20180424144404.GF26636@bombadil.infradead.org>
 <b1efb813-3629-518c-4eeb-7d15eb5e7319@gmail.com>
From: Igor Stoppa <igor.stoppa@gmail.com>
Message-ID: <a8ea4455-3be8-153e-0ac4-52ef27a942b4@gmail.com>
Date: Tue, 24 Apr 2018 19:29:05 +0400
MIME-Version: 1.0
In-Reply-To: <b1efb813-3629-518c-4eeb-7d15eb5e7319@gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lazytyped <lazytyped@gmail.com>, Matthew Wilcox <willy@infradead.org>
Cc: keescook@chromium.org, paul@paul-moore.com, sds@tycho.nsa.gov, mhocko@kernel.org, corbet@lwn.net, labbott@redhat.com, linux-cc=david@fromorbit.com, --cc=rppt@linux.vnet.ibm.com, --security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com, Igor Stoppa <igor.stoppa@huawei.com>, Carlos Chinea Perez <carlos.chinea.perez@huawei.com>, Remi Denis Courmont <remi.denis.courmont@huawei.com>



On 24/04/18 19:03, lazytyped wrote:
> 
> 
> On 4/24/18 4:44 PM, Matthew Wilcox wrote:
>> On Tue, Apr 24, 2018 at 02:32:36PM +0200, lazytyped wrote:
>>> On 4/24/18 1:50 PM, Matthew Wilcox wrote:
>>>> struct modifiable_data {
>>>> 	struct immutable_data *d;
>>>> 	...
>>>> };
>>>>
>>>> Then allocate a new pool, change d and destroy the old pool.
>>> With the above, you have just shifted the target of the arbitrary write
>>> from the immutable data itself to the pointer to the immutable data, so
>>> got no security benefit.
>> There's always a pointer to the immutable data.  How do you currently
>> get to the selinux context?  file->f_security.  You can't make 'file'
>> immutable, so file->f_security is the target of the arbitrary write.
>> All you can do is make life harder, and reduce the size of the target.
> 
> So why adding an extra pointer/indirection helps here? It adds attacking
> surface.
>>
>>> The goal of the patch is to reduce the window when stuff is writeable,
>>> so that an arbitrary write is likely to hit the time when data is read-only.
>> Yes, reducing the size of the target in time as well as bytes.  This patch
>> gives attackers a great roadmap (maybe even gadget) to unprotecting
>> a pool.
> 
> I don't think this is relevant to the threat model this patch addresses.
> If the attacker can already execute code, it doesn't matter whether this
> specific piece of code exists or not. In general, if an attacker got to
> the point of using gadgets, you've lost.

Realistically, if the attacker can execute arbitrary code, through 
gadgets, there is nothing preventing a direct attack to the physical 
page, by remapping it, exactly like the patch does.
Or even changing the page table.

Wrt re-utilizing this specific rare_write() function, it would be 
possible to mark it as __always_inline, so that it will be executed only 
with the data and pool it is intended for.

Then, if one has access to a compiler plugin that does CFI, it becomes 
harder to reuse the inlined function.

Inlining should not be too bad, as size overhead.

OTOH, having the pointer always laying around at a specific address, 
allows for easier scanning - and attack - of the data

The remapping to a temporary address should make it harder to figure out 
where to write to.

Again, the whole assumption behind pmalloc is that the attacker can do 
read and writes, maybe limited execution, in the form of function calls.

But if the attacker can execute arbitrary code, all bets are off and the 
system is forfeited.

Really critical data should go into a TEE or similar isolated environment.

> On the contrary, it opens the road to design trusted paths that can
> write to or access data that would generally be read-only or not
> accessible (with, of course, all the complexity, limitations and
> penalties of doing this purely in software on a page sized basis).

I had considered the COW approach, where I would allocate a new page and 
swap it atomically, but it is not supported on ARM.

--

igor
