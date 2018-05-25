Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id C31986B027D
	for <linux-mm@kvack.org>; Thu, 24 May 2018 21:17:06 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id j33-v6so2571008qtc.18
        for <linux-mm@kvack.org>; Thu, 24 May 2018 18:17:06 -0700 (PDT)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id c135-v6si2947830qkg.11.2018.05.24.18.17.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 May 2018 18:17:05 -0700 (PDT)
Date: Thu, 24 May 2018 21:16:57 -0400
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: Re: [PATCH V6 2/2 RESEND] ksm: replace jhash2 with faster hash
Message-ID: <20180525011657.4qxrosmm3xjzo24w@xakep.localdomain>
References: <20180418193220.4603-1-timofey.titovets@synesis.ru>
 <20180418193220.4603-3-timofey.titovets@synesis.ru>
 <20180522202242.otvdunkl75yfhkt4@xakep.localdomain>
 <CAGqmi76gJV=ZDX5=Y3toF2tPiJs8T=PiUJFQg5nq9O5yztx80Q@mail.gmail.com>
 <CAGM2reaZ2YoxFhEDtcXi=hMFoGFi8+SROOn+_SRMwnx3cW15kw@mail.gmail.com>
 <CAGqmi76-qK9q_OTvyqpb-9k_m0CLMt3o860uaN5LL8nBkf5RTg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGqmi76-qK9q_OTvyqpb-9k_m0CLMt3o860uaN5LL8nBkf5RTg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Timofey Titovets <nefelim4ag@gmail.com>
Cc: linux-mm@kvack.org, Sioh Lee <solee@os.korea.ac.kr>, Andrea Arcangeli <aarcange@redhat.com>, kvm@vger.kernel.org

Hi Timofey,

> > Do you have performance numbers of crc32c without acceleration?
> Yes, https://lkml.org/lkml/2017/12/30/222
> 
> The experimental results (the experimental value is the average of the
> measured values)
> crc32c_intel: 1084.10ns
> crc32c (no hardware acceleration): 7012.51ns
> xxhash32: 2227.75ns
> xxhash64: 1413.16ns
> jhash2: 5128.30ns

Excellent, thank you for this data.

> > I understand that losing half of the hash result might be acceptable in
> > this case, but I am not really sure how XOirng one more time can possibly
> > make hash function worse, could you please elaborate?
> 
> IIRC, because of xor are symmetric
> i.e. shift:
> 0b01011010 >> 4 = 0b0101
> and xor:
> 0b0101 ^ 0b1010 = 0b1111
> Xor will decrease randomness/entropy and will lead to hash collisions.

Makes perfect sense. Yes, XORing two random numbers reduces entropy.

> That possible to move decision from lazy load, to ksm_thread,
> that will allow us to start bench and not slowdown boot.
> 
> But for that to works, ksm must start later, after init of crypto.

After studying this dependency some more I agree, it is OK to choose hash
function where it is, but I still disagree that we must measure the
performance at runtime.

> crc32c with no hw, are slower in compare to jhash2 on x86, so i think on
> other arches result will be same.

Agreed.

Below, is your patch updated with my suggested changes.

1. Removes dependency on crc32c, use it only when it is available.
2. Do not spend time measuring the performance, choose only if there is HW
optimized implementation of crc32c is available.
3. Replace the logic with static branches.
4. Fix a couple minor bugs: 
   fastest_hash_setup() and crc32c_available() were marked as __init
   functions. Thus could be unmapped by the time they are run for the
   first time. I think section mismatch would catch those
   Removed dead code:  "desc.flags = 0", and also replaced desc with sash.
   Removed unnecessary local global "static struct shash_desc desc" this
   removes it from data page.
   Fixed few spelling errors, and other minor changes to pass
   ./scripts/checkpatch.pl

The patch is untested, but should work. Please let me know if you agree
with the changes. If so, you can test and resubmit the series.

Thank you,
Pavel

Patch:
==========================================================================
