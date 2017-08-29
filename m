Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id B23776B025F
	for <linux-mm@kvack.org>; Tue, 29 Aug 2017 12:05:58 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id p67so11172906qkd.8
        for <linux-mm@kvack.org>; Tue, 29 Aug 2017 09:05:58 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q19si3173659qtb.252.2017.08.29.09.05.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Aug 2017 09:05:57 -0700 (PDT)
Date: Tue, 29 Aug 2017 18:05:53 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] mm/ksm : Checksum calculation function change (jhash2 ->
 crc32)
Message-ID: <20170829160553.GC21615@redhat.com>
References: <1501589255-9389-1-git-send-email-solee@os.korea.ac.kr>
 <20170801200550.GB24406@redhat.com>
 <bf406908-bf93-83dd-54e6-d2e3e5881db6@os.korea.ac.kr>
 <20170803132350.GI21775@redhat.com>
 <df5c8e04-280b-c0eb-2820-eff2dce67582@os.korea.ac.kr>
 <20170824191453.GE7241@redhat.com>
 <cb640b63-a9f3-c083-6453-43006a59b477@os.korea.ac.kr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cb640b63-a9f3-c083-6453-43006a59b477@os.korea.ac.kr>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sioh Lee <solee@os.korea.ac.kr>
Cc: akpm@linux-foundation.org, mingo@kernel.org, zhongjiang@huawei.com, minchan@kernel.org, arvind.yadav.cs@gmail.com, imbrenda@linux.vnet.ibm.com, kirill.shutemov@linux.intel.com, linux-mm@kvack.org, hxy@os.korea.ac.kr, oslab@os.korea.ac.kr

Hello,

On Tue, Aug 29, 2017 at 03:35:34PM +0900, sioh Lee wrote:
> Hello,
> Thank you for the reply and for being supportive.
> First of all, I made a mistake in that I typed crc32 incorrectly. All the experiments were done using crc32c-intel, not crc32 (PCLMULQDQ).

So the fuzzy search in __crypto_alg_lookup gave you crc32c-intel
because you didn't enable crc32 PCLMULQDQ in the kernel config?

>From source it looks like an explicit load of crc32c-intel would work
too, instead of checking the priority. We can load in order
crc32c-intel, crc32-pclmul and fallback in "crc32c" which must be then
forced enabled in the kernel config.

> Second, the reason for (priority < 200) is because the priority of crc32c-intel is 200 so that if the priority is less than 200, jhash2 is used.
> Also, I have a question about implementation. Do you want to exclude jhash2 from ksm and go only with crc32 ? Could you please give me guidance about it?

Yes, the idea about excluding jhash2 from KSM is that if one almost
certain crc32c hash collision once every 200k modifications to the
page truly isn't a concern with sse4.2, it's still not a concern if
crc32 is implemented in C, but still faster than jhash2.

I don't like the behavior of the hash to change depending on hw or
kernel config, as that decreases the testing and it would generate
different behavior depending on kernel config or arch. I don't like
non reproducible bugs or to fragment testing across the userbase
depending on kernel config or arch. If crc32 creates problems with
hash collisions, it's better everyone is testing it so we find out
sooner than later.

The arch code can choose which of the crc32* variants to use, but it
shouldn't change the hash to something completely different. It's more
robust if the default hash algorithm is the same (only with minor
variations allowed like crc32c vs crc32 vs crc32be).

> Then, I will implement it and send you a new patch.
> Once again, thank you so much for your reply.

Thanks!
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
