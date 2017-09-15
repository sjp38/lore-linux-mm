Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9E0A56B0253
	for <linux-mm@kvack.org>; Fri, 15 Sep 2017 17:21:38 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id 97so3508561wrb.1
        for <linux-mm@kvack.org>; Fri, 15 Sep 2017 14:21:38 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id u10si2152417edf.218.2017.09.15.14.21.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Sep 2017 14:21:37 -0700 (PDT)
Subject: Re: [PATCH v8 10/11] arm64/kasan: explicitly zero kasan shadow memory
References: <20170914223517.8242-1-pasha.tatashin@oracle.com>
 <20170914223517.8242-11-pasha.tatashin@oracle.com>
 <20170915011035.GA6936@remoulade>
 <c76f72fc-21ed-62d0-014e-8509c0374f96@oracle.com>
 <20170915203852.GA10749@remoulade>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Message-ID: <bff836ec-3922-1783-6cb4-94d1be92544b@oracle.com>
Date: Fri, 15 Sep 2017 17:20:59 -0400
MIME-Version: 1.0
In-Reply-To: <20170915203852.GA10749@remoulade>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Rutland <mark.rutland@arm.com>
Cc: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, mhocko@kernel.org, ard.biesheuvel@linaro.org, will.deacon@arm.com, catalin.marinas@arm.com, sam@ravnborg.org, mgorman@techsingularity.net, Steven.Sistare@oracle.com, daniel.m.jordan@oracle.com, bob.picco@oracle.com

Hi Mark,

I had this optionA  back upto version 3, where zero flag was passed into 
vmemmap_alloc_block(), but I was asked to remove it, because it required 
too many changes in other places. So, the current approach is cleaner, 
but the idea is that kasan should use its own version of 
vmemmap_populate() for both x86 and ARM, but I think it is outside of 
the scope of this work.

See this comment from Ard Biesheuvel:
https://lkml.org/lkml/2017/8/3/948

"
KASAN uses vmemmap_populate as a convenience: kasan has nothing to do
with vmemmap, but the function already existed and happened to do what
KASAN requires.

Given that that will no longer be the case, it would be far better to
stop using vmemmap_populate altogether, and clone it into a KASAN
specific version (with an appropriate name) with the zeroing folded
into it.
"

If you think I should add these function in this project, than sure I 
can send a new version with kasanmap_populate() functions.

Thank you,
Pasha

On 09/15/2017 04:38 PM, Mark Rutland wrote:
> On Thu, Sep 14, 2017 at 09:30:28PM -0400, Pavel Tatashin wrote:
>> Hi Mark, Thank you for looking at this. We can't do this because page 
>> table is not set until cpu_replace_ttbr1() is called. So, we can't do 
>> memset() on this memory until then. 
> I see. Sorry, I had missed that we were on the temporary tables at 
> this point in time. I'm still not keen on duplicating the iteration. 
> Can we split the vmemmap code so that we have a variant that takes a 
> GFP? That way we could explicitly pass __GFP_ZERO for those cases 
> where we want a zeroed page, and are happy to pay the cost of 
> initialization. Thanks Mark.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
