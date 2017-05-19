Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 251552803C1
	for <linux-mm@kvack.org>; Fri, 19 May 2017 06:53:13 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id 139so14364486wmf.5
        for <linux-mm@kvack.org>; Fri, 19 May 2017 03:53:13 -0700 (PDT)
Received: from lhrrgout.huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id b30si2559744wrd.184.2017.05.19.03.53.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 19 May 2017 03:53:11 -0700 (PDT)
Subject: Re: RFC v2: post-init-read-only protection for data allocated
 dynamically
References: <9200d87d-33b6-2c70-0095-e974a30639fd@huawei.com>
 <a445774f-a307-25aa-d44e-c523a7a42da6@redhat.com>
 <0b55343e-4305-a9f1-2b17-51c3c734aea6@huawei.com>
 <20170510080542.GF31466@dhcp22.suse.cz>
 <885311a2-5b9f-4402-0a71-5a3be7870aa0@huawei.com>
 <20170510114319.GK31466@dhcp22.suse.cz>
 <1a8cc1f4-0b72-34ea-43ad-5ece22a8d5cf@huawei.com>
 <b780ac13-4fc3-ac07-f0c0-7a6cc8dae694@intel.com>
From: Igor Stoppa <igor.stoppa@huawei.com>
Message-ID: <c04713b0-5e87-41f2-a3df-1b8f75e44bdc@huawei.com>
Date: Fri, 19 May 2017 13:51:33 +0300
MIME-Version: 1.0
In-Reply-To: <b780ac13-4fc3-ac07-f0c0-7a6cc8dae694@intel.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, Michal Hocko <mhocko@kernel.org>, Laura Abbott <labbott@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>

Hello,

On 10/05/17 18:45, Dave Hansen wrote:
> On 05/10/2017 08:19 AM, Igor Stoppa wrote:
>> So I'd like to play a little what-if scenario:
>> what if I was to support exclusively virtual memory and convert to it
>> everything that might need sealing?
> 
> Because of the issues related to fracturing large pages, you might have
> had to go this route eventually anyway.  Changing the kernel linear map
> isn't nice.
> 
> FWIW, you could test this scheme by just converting all the users to
> vmalloc() and seeing what breaks.  They'd all end up rounding up all
> their allocations to PAGE_SIZE, but that'd be fine for testing.

Apologies for the long hiatus, it took me some time to figure out
a solution that could somehow address all the comments I got till this
point.

It's here [1], I preferred to start one new thread, since the proposal
has in practice changed significantly, even if in spirit it's still the
same.

It should also take care of the potential waste of space you mentioned
wrt the round up to PAGE_SIZE.

> Could you point out 5 or 10 places in the kernel that you want to convert?

Right now I can only repeat what I said initially:
- the linked list used to implement LSM hooks
- SE linux structures used to implement the policy DB, it should be
  about 5 data types

Next week, I'll address the 2 cases I listed, then I'll look for more,
but I think it should not be difficult to find customers for this.

BTW, I forgot to mention that I tested the code against both SLAB and
SLUB and it seems to work fine.

So far I've used QEMU x86-64 as test environment.

--
igor


[1] https://marc.info/?l=linux-mm&m=149519044015956&w=2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
