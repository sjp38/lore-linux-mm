Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6F1E06B0006
	for <linux-mm@kvack.org>; Wed, 25 Apr 2018 16:58:43 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id f19so16687175pfn.6
        for <linux-mm@kvack.org>; Wed, 25 Apr 2018 13:58:43 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x5sor3951709pgr.56.2018.04.25.13.58.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 25 Apr 2018 13:58:42 -0700 (PDT)
Subject: Re: [PATCH 7/9] Pmalloc Rare Write: modify selected pools
References: <20180423125458.5338-1-igor.stoppa@huawei.com>
 <20180423125458.5338-8-igor.stoppa@huawei.com>
 <20180424115050.GD26636@bombadil.infradead.org>
 <eb23fbd9-1b9e-8633-b0eb-241b8ad24d95@gmail.com>
 <20180424144404.GF26636@bombadil.infradead.org>
From: Igor Stoppa <igor.stoppa@gmail.com>
Message-ID: <6a28fa46-a6b4-2803-0f15-8c278811ec2f@gmail.com>
Date: Thu, 26 Apr 2018 00:58:39 +0400
MIME-Version: 1.0
In-Reply-To: <20180424144404.GF26636@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, lazytyped <lazytyped@gmail.com>, dave.hansen@linux.intel.com
Cc: keescook@chromium.org, paul@paul-moore.com, sds@tycho.nsa.gov, mhocko@kernel.org, corbet@lwn.net, labbott@redhat.com, david@fromorbit.com, rppt@linux.vnet.ibm.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com, Igor Stoppa <igor.stoppa@huawei.com>, Carlos Chinea Perez <carlos.chinea.perez@huawei.com>, Remi Denis Courmont <remi.denis.courmont@huawei.com>



On 24/04/18 18:44, Matthew Wilcox wrote:
> On Tue, Apr 24, 2018 at 02:32:36PM +0200, lazytyped wrote:
>> On 4/24/18 1:50 PM, Matthew Wilcox wrote:
>>> struct modifiable_data {
>>> 	struct immutable_data *d;
>>> 	...
>>> };
>>>
>>> Then allocate a new pool, change d and destroy the old pool.
>>
>> With the above, you have just shifted the target of the arbitrary write
>> from the immutable data itself to the pointer to the immutable data, so
>> got no security benefit.
> 
> There's always a pointer to the immutable data.  How do you currently
> get to the selinux context?  file->f_security.  You can't make 'file'
> immutable, so file->f_security is the target of the arbitrary write.
> All you can do is make life harder, and reduce the size of the target.

In the patch that shows how to secure the selinux initialized state,
there is a static _ro_after_init handle (the 'file' in your example), 
which is immutable, after init has completed.
It is as immutable as any const data that is not optimized away.

That is what the code uses to refer to the pmalloc data.

Since the reference is static, I expect the code will use it through 
some offset, which will be in the code segment, which is also read-only, 
as much as the rest.

Where is the writable pointer in this scenario?


>> The goal of the patch is to reduce the window when stuff is writeable,
>> so that an arbitrary write is likely to hit the time when data is read-only.
> 
> Yes, reducing the size of the target in time as well as bytes.  This patch
> gives attackers a great roadmap (maybe even gadget) to unprotecting
> a pool.

Gadgets can be removed by inlining the function calls.

Dave Hansen suggested I could do COW and replace the old page with the 
new one. I could implement that, if it is preferable, although I think 
it would be less efficient, for small writes, but it would not leave the 
current page mapped as writable, so there is certainly value in it.

---
igor
