Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4680F6B0038
	for <linux-mm@kvack.org>; Fri,  5 May 2017 06:43:46 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id g67so298247wrd.0
        for <linux-mm@kvack.org>; Fri, 05 May 2017 03:43:46 -0700 (PDT)
Received: from lhrrgout.huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id q78si1983481wme.139.2017.05.05.03.43.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 05 May 2017 03:43:44 -0700 (PDT)
Subject: Re: RFC v2: post-init-read-only protection for data allocated
 dynamically
References: <9200d87d-33b6-2c70-0095-e974a30639fd@huawei.com>
 <a445774f-a307-25aa-d44e-c523a7a42da6@redhat.com>
From: Igor Stoppa <igor.stoppa@huawei.com>
Message-ID: <0b55343e-4305-a9f1-2b17-51c3c734aea6@huawei.com>
Date: Fri, 5 May 2017 13:42:27 +0300
MIME-Version: 1.0
In-Reply-To: <a445774f-a307-25aa-d44e-c523a7a42da6@redhat.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>, Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>

On 04/05/17 19:49, Laura Abbott wrote:
> [adding kernel-hardening since I think there would be interest]

thank you, I overlooked this


> BPF takes the approach of calling set_memory_ro to mark regions as
> read only. I'm certainly over simplifying but it sounds like this
> is mostly a mechanism to have this happen mostly automatically.
> Can you provide any more details about tradeoffs of the two approaches?

I am not sure I understand the question ...
For what I can understand, the bpf is marking as read only something
that spans across various pages, which is fine.
The payload to be protected is already organized in such pages.

But in the case I have in mind, I have various, heterogeneous chunks of
data, coming from various subsystems, not necessarily page aligned.
And, even if they were page aligned, most likely they would be far
smaller than a page, even a 4k page.

The first problem I see, is how to compact them into pages, ensuring
that no rwdata manages to infiltrate the range.

The actual mechanism for marking pages as read only is not relevant at
this point, if I understand your question correctly, since set_memory_ro
is walking the pages it receives as parameter.

> arm and arm64 have the added complexity of using larger
> page sizes on the linear map so dynamic mapping/unmapping generally
> doesn't work. 

Do you mean that a page could be 16MB and therefore it would not be
possible to get a smaller chunk?

> arm64 supports DEBUG_PAGEALLOC by mapping with only
> pages but this is generally only wanted as a debug mechanism.
> I don't know if you've given this any thought at all.

Since the beginning I have thought about this feature as an opt-in
feature. I am aware that it can have drawbacks, but I think it would be
valuable as debugging tool even where it's not feasible to keep it
always-on.

OTOH on certain systems it can be sufficiently appealing to be kept on,
even if it eats up some more memory.

If this doesn't answer your question, could you please detail it more?

---
thanks, igor

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
