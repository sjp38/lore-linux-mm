Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id A19B56B0008
	for <linux-mm@kvack.org>; Wed, 23 May 2018 10:24:48 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id i127-v6so3012830ita.5
        for <linux-mm@kvack.org>; Wed, 23 May 2018 07:24:48 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id m186-v6si2169510itd.73.2018.05.23.07.24.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 May 2018 07:24:46 -0700 (PDT)
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w4NEKtk0045161
	for <linux-mm@kvack.org>; Wed, 23 May 2018 14:24:45 GMT
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by userp2120.oracle.com with ESMTP id 2j4nh7m87n-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Wed, 23 May 2018 14:24:44 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id w4NEOhjI003469
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Wed, 23 May 2018 14:24:43 GMT
Received: from abhmp0012.oracle.com (abhmp0012.oracle.com [141.146.116.18])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id w4NEOhpH007059
	for <linux-mm@kvack.org>; Wed, 23 May 2018 14:24:43 GMT
Received: by mail-ot0-f177.google.com with SMTP id i5-v6so25429805otf.1
        for <linux-mm@kvack.org>; Wed, 23 May 2018 07:24:43 -0700 (PDT)
MIME-Version: 1.0
References: <20180418193220.4603-1-timofey.titovets@synesis.ru>
 <20180418193220.4603-3-timofey.titovets@synesis.ru> <20180522202242.otvdunkl75yfhkt4@xakep.localdomain>
 <CAGqmi76gJV=ZDX5=Y3toF2tPiJs8T=PiUJFQg5nq9O5yztx80Q@mail.gmail.com>
In-Reply-To: <CAGqmi76gJV=ZDX5=Y3toF2tPiJs8T=PiUJFQg5nq9O5yztx80Q@mail.gmail.com>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Wed, 23 May 2018 10:24:06 -0400
Message-ID: <CAGM2reaZ2YoxFhEDtcXi=hMFoGFi8+SROOn+_SRMwnx3cW15kw@mail.gmail.com>
Subject: Re: [PATCH V6 2/2 RESEND] ksm: replace jhash2 with faster hash
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: nefelim4ag@gmail.com
Cc: Linux Memory Management List <linux-mm@kvack.org>, solee@os.korea.ac.kr, aarcange@redhat.com, kvm@vger.kernel.org

Hi Timofey,

> crc32c will always be available, because of Kconfig.
> But if crc32c doesn't have HW acceleration, it will be slower.

> For talk about range of HW, i must have that HW,
> so i can't say that *all* supported HW, have crc32c with acceleration.

How about always defaulting to crc32c when HW acceleration is present
without doing timings?
Do you have performance numbers of crc32c without acceleration?

> > You are loosing half of 64-bit word in xxh64 case? Is this acceptable?
May
> > be do one more xor: in 64-bit case in xxhash() do: (v >> 32) | (u32)v ?

> AFAIK, that lead to make hash function worse.
> Even, in ksm hash used only for check if page has changed since last scan,
> so that doesn't matter really (IMHO).

I understand that losing half of the hash result might be acceptable in
this case, but I am not really sure how XOirng one more time can possibly
make hash function worse, could you please elaborate?

> > choice_fastest_hash() does not belong to fasthash(). We are loosing leaf
> > function optimizations if you keep it in this hot-path. Also,
fastest_hash
> > should really be a static branch in order to avoid extra load and
> conditional
> > branch.

> I don't think what that will give any noticeable performance benefit.
> In compare to hash computation and memcmp in RB.

You are right, it is small compared to hash and memcmp, but still I think
it makes sense to use static branch, after all the value will never change
during runtime after the first time it is set.


> In theory, that can be replaced with self written jump table, to *avoid*
> run time overhead.
> AFAIK at 5 entries, gcc convert switch to jump table itself.

> > I think, crc32c should simply be used when it is available, and use
xxhash
> > otherwise, the decision should be made in ksm_init()

> I already said, in above conversation, why i think do that at ksm_init()
is
> a bad idea.

It really feels wrong to keep  choice_fastest_hash() in fasthash(), it is
done only once and really belongs to the init function, like ksm_init(). As
I understand, you think it is a bad idea to keep it in ksm_init() because
it slows down boot by 0.25s, which I agree with your is substantial. But, I
really do not think that we should spend those 0.25s at all deciding what
hash function is optimal, and instead default to one or another during boot
based on hardware we are booting on. If crc32c without hw acceleration is
no worse than jhash2, maybe we should simply switch to  crc32c?

Thank you,
Pavel
