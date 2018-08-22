Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 428036B2360
	for <linux-mm@kvack.org>; Wed, 22 Aug 2018 04:19:05 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id l45-v6so1159158wre.4
        for <linux-mm@kvack.org>; Wed, 22 Aug 2018 01:19:05 -0700 (PDT)
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id u2-v6si875971wrp.39.2018.08.22.01.19.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Aug 2018 01:19:03 -0700 (PDT)
Subject: Re: Odd SIGSEGV issue introduced by commit 6b31d5955cb29 ("mm, oom:
 fix potential data corruption when oom_reaper races with writer")
References: <7767bdf4-a034-ecb9-1ac8-4fa87f335818@c-s.fr>
 <871sasmddc.fsf@concordia.ellerman.id.au>
 <20180821175049.GA5905@ram.oc3035372033.ibm.com>
From: Christophe LEROY <christophe.leroy@c-s.fr>
Message-ID: <633145ae-162c-9e03-6e8d-7442cbc8356c@c-s.fr>
Date: Wed, 22 Aug 2018 10:19:02 +0200
MIME-Version: 1.0
In-Reply-To: <20180821175049.GA5905@ram.oc3035372033.ibm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: fr
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, linux-mm <linux-mm@kvack.org>



Le 21/08/2018 A  19:50, Ram Pai a A(C)critA :
> On Tue, Aug 21, 2018 at 04:40:15PM +1000, Michael Ellerman wrote:
>> Christophe LEROY <christophe.leroy@c-s.fr> writes:
>> ...
>>>
>>> And I bisected its disappearance with commit 99cd1302327a2 ("powerpc:
>>> Deliver SEGV signal on pkey violation")
>>
>> Whoa that's weird.
>>
>>> Looking at those two commits, especially the one which makes it
>>> dissapear, I'm quite sceptic. Any idea on what could be the cause and/or
>>> how to investigate further ?
>>
>> Are you sure it's not some corruption that just happens to be masked by
>> that commit? I can't see anything in that commit that could explain that
>> change in behaviour.
>>
>> The only real change is if you're hitting DSISR_KEYFAULT isn't it?
> 
> even with the 'commit 99cd1302327a2', a SEGV signal should get generated;
> which should kill the process. Unless the process handles SEGV signals
> with SEGV_PKUERR differently.

No, the sigsegv are not handled differently. And the trace shown it is 
SEGV_MAPERR which is generated.

> 
> The other surprising thing is, why is DSISR_KEYFAULT getting generated
> in the first place?  Are keys somehow getting programmed into the HPTE?

Can't be that, because DSISR_KEYFAULT is filtered out when applying 
DSISR_SRR1_MATCH_32S mask.

> 
> Feels like some random corruption.

In a way yes, except that it is always at the same instruction (in 
ld.so) and always because the accessed address is 0x67xxxxxx instead of 
0x77xxxxxx
I also tested with TASK_SIZE set to 0xa0000000 instead of 0x80000000, 
and I get same failure with bad address being 0x87xxxxxx instead of 
0x97xxxxxx

Christophe

> 
> Is this behavior seen with power8 or power9?
> 
> RP
> 
