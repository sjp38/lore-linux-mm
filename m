Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id AB27C6B0003
	for <linux-mm@kvack.org>; Mon, 21 May 2018 07:29:15 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id t24-v6so13996655qtn.7
        for <linux-mm@kvack.org>; Mon, 21 May 2018 04:29:15 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id b131-v6si6389257qkg.106.2018.05.21.04.29.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 May 2018 04:29:14 -0700 (PDT)
Subject: Re: pkeys on POWER: Access rights not reset on execve
References: <53828769-23c4-b2e3-cf59-239936819c3e@redhat.com>
 <20180519011947.GJ5479@ram.oc3035372033.ibm.com>
 <CALCETrWMP9kTmAFCR0WHR3YP93gLSzgxhfnb0ma_0q=PCuSdQA@mail.gmail.com>
 <20180519202747.GK5479@ram.oc3035372033.ibm.com>
 <CALCETrVz9otkOQAxVkz6HtuMwjAeY6mMuLgFK_o0M0kbkUznwg@mail.gmail.com>
 <20180520060425.GL5479@ram.oc3035372033.ibm.com>
 <CALCETrVvQkphypn10A_rkX35DNqi29MJcXYRpRiCFNm02VYz2g@mail.gmail.com>
 <20180520191115.GM5479@ram.oc3035372033.ibm.com>
From: Florian Weimer <fweimer@redhat.com>
Message-ID: <aae1952c-886b-cfc8-e98b-fa3be5fab0fa@redhat.com>
Date: Mon, 21 May 2018 13:29:11 +0200
MIME-Version: 1.0
In-Reply-To: <20180520191115.GM5479@ram.oc3035372033.ibm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>, Andy Lutomirski <luto@kernel.org>
Cc: linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, Linux-MM <linux-mm@kvack.org>, Dave Hansen <dave.hansen@intel.com>

On 05/20/2018 09:11 PM, Ram Pai wrote:
> Florian,
> 
> 	Does the following patch fix the problem for you?  Just like x86
> 	I am enabling all keys in the UAMOR register during
> 	initialization itself. Hence any key created by any thread at
> 	any time, will get activated on all threads. So any thread
> 	can change the permission on that key. Smoke tested it
> 	with your test program.

I think this goes in the right direction, but the AMR value after fork 
is still strange:

AMR (PID 34912): 0x0000000000000000
AMR after fork (PID 34913): 0x0000000000000000
AMR (PID 34913): 0x0000000000000000
Allocated key in subprocess (PID 34913): 2
Allocated key (PID 34912): 2
Setting AMR: 0xffffffffffffffff
New AMR value (PID 34912): 0x0fffffffffffffff
About to call execl (PID 34912) ...
AMR (PID 34912): 0x0fffffffffffffff
AMR after fork (PID 34914): 0x0000000000000003
AMR (PID 34914): 0x0000000000000003
Allocated key in subprocess (PID 34914): 2
Allocated key (PID 34912): 2
Setting AMR: 0xffffffffffffffff
New AMR value (PID 34912): 0x0fffffffffffffff

I mean this line:

AMR after fork (PID 34914): 0x0000000000000003

Shouldn't it be the same as in the parent process?

Thanks,
Florian
