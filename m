Return-Path: <SRS0=Mdb/=TC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A112BC43219
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 05:21:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5DE0D2081C
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 05:21:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5DE0D2081C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=vt.edu
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D95536B0005; Thu,  2 May 2019 01:21:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D1E6D6B0006; Thu,  2 May 2019 01:21:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BBF316B0007; Thu,  2 May 2019 01:21:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9640A6B0005
	for <linux-mm@kvack.org>; Thu,  2 May 2019 01:21:28 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id i124so1301472qkf.14
        for <linux-mm@kvack.org>; Wed, 01 May 2019 22:21:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:sender:from:to
         :cc:subject:in-reply-to:references:mime-version
         :content-transfer-encoding:date:message-id;
        bh=Rx+2vo/TQ6owQB261ooRLIT5wjP1j/4C+RPHBVgcfrM=;
        b=arc669FWhwgN619z7JmxQXdZMWsaHTaXB2d5VtQqnVeONHhjn6gkw6w1LVCbF6ZYQg
         oMWPGaUppCVqkM3sImERyg52JmRw5IMMk1P/ERxeMvZAhuF5s/WnUecRVE4KWQTrTPwa
         pdmwF/pCySeeCzSwFuYPbkZKm84kDMiL6XFm8LUeYrwHirGsI9HRTTmTNkeo4NU3WcJf
         gwlxeBLWrfj7dX4PLM8FxA0Qib3Ny4c/SdK/oZpSHuRztjqQ0TqbukbC2mzpt4Jijlhg
         h2zTt+t7xT736Hpld7mtVMRFXO+gVuS/Q2YpUh0w8FvDM+Hsg9Y5pRIud8Mk1QrHDcrj
         DkLQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of valdis@vt.edu designates 2607:b400:92:8300:0:c6:2117:b0e as permitted sender) smtp.mailfrom=valdis@vt.edu;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=vt.edu
X-Gm-Message-State: APjAAAXvvDctrc8ncCI4c2kJ/NgTXptycJYznUW275spZFMAbkIHN3h2
	WJQNDiOJp6SVBfyKrm2b3lUg2UKTf8d8iH7y0NlDluUhm+jeWr+SnJ+OAdnQI7t2o5fkKgFKMYq
	7ps0qCejMFQne85nWLdLkQWYGdkPsAnCfOPFmZ0jThTQU46U1qrxnqDYiJkZKv8hb5IMxvX66zS
	wdBgZghxvB/0C29aqzXbaKPZaZqip1T1PDtiayNGHxV36rT2tm6aofMhEXwuEHLw==
X-Received: by 2002:a0c:acf8:: with SMTP id n53mr1565035qvc.83.1556774488315;
        Wed, 01 May 2019 22:21:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzvy30TuQtau+rl3vHxhcdXoyfwCpUX3/bAP/9fc6mPtYNmlCsp6fXmVd4rzw76bZvCNwHy
X-Received: by 2002:a0c:acf8:: with SMTP id n53mr1565001qvc.83.1556774487566;
        Wed, 01 May 2019 22:21:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556774487; cv=none;
        d=google.com; s=arc-20160816;
        b=eFILJkLXGEinH/EPVD9M6WoDCanWHcnXUvH108ZCYDTlsWtX6a0l1JwCBi+pShK+Qi
         aWyzAVBTw/DfWuRcbWiHjjswBATbnt1CTHLDAWb/u+7StWDvHCAjfGnkxtT96w92RS4P
         1fOAoemkBMBSygeYJYDUCiIH1062q/f0nNfwh0WZ4eVa58QpRg8pC9b943JhrX9bW7MI
         r7B/wDDhKqwICaX90EIC697C1/TevIqASuPLwV37ERPRpmndQd7CE2FwyMbKBLY7Ts1n
         G9S+2yZfbbkDsGg3Pt4Dcl988UblEVE6RKqNUOAlsYnrHFt9of2d/Ccceka2l2ASC2Z+
         uwXw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:content-transfer-encoding:mime-version:references
         :in-reply-to:subject:cc:to:from:sender;
        bh=Rx+2vo/TQ6owQB261ooRLIT5wjP1j/4C+RPHBVgcfrM=;
        b=NQluHTmwoAxsfBFgVibm5S7RJuhITy4glrStT5bZKHbmdkhFW48PcuGcJa/r7LIaUu
         yQUeOZn3+Mxt4inhSigeqL2dnxjGu4rM/47A3egbWc7+H6EP8WqSuw6s7fSCKPk4nt6V
         vljjSF43cn8wycg+9WTZBBF0WWFELMQXuBA0CwFmIoWrUEkwo9FTOvOSwLIl+jG3P2Bq
         g4uAluXFW1prvgqDP2In0lHMIQJhgjACYJnvuzEHiGVc6rb+zMldu1vMCwuxSXartRE0
         8WQxyWtLmnReqQlP9sylx+AJ2hJwNvXZQ98mUb2d84FxfvtrINL71q7Ib5qt+l9cGYvQ
         njkQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of valdis@vt.edu designates 2607:b400:92:8300:0:c6:2117:b0e as permitted sender) smtp.mailfrom=valdis@vt.edu;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=vt.edu
Received: from omr1.cc.vt.edu (omr1.cc.ipv6.vt.edu. [2607:b400:92:8300:0:c6:2117:b0e])
        by mx.google.com with ESMTPS id x40si1172961qtx.54.2019.05.01.22.21.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 May 2019 22:21:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of valdis@vt.edu designates 2607:b400:92:8300:0:c6:2117:b0e as permitted sender) client-ip=2607:b400:92:8300:0:c6:2117:b0e;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of valdis@vt.edu designates 2607:b400:92:8300:0:c6:2117:b0e as permitted sender) smtp.mailfrom=valdis@vt.edu;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=vt.edu
Received: from mr2.cc.vt.edu (mr2.cc.ipv6.vt.edu [IPv6:2607:b400:92:8400:0:90:e077:bf22])
	by omr1.cc.vt.edu (8.14.4/8.14.4) with ESMTP id x425LRkV007972
	for <linux-mm@kvack.org>; Thu, 2 May 2019 01:21:27 -0400
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by mr2.cc.vt.edu (8.14.7/8.14.7) with ESMTP id x425LMxK012937
	for <linux-mm@kvack.org>; Thu, 2 May 2019 01:21:27 -0400
Received: by mail-qt1-f199.google.com with SMTP id n1so1069064qte.12
        for <linux-mm@kvack.org>; Wed, 01 May 2019 22:21:27 -0700 (PDT)
X-Received: by 2002:a37:a849:: with SMTP id r70mr1429445qke.315.1556774481834;
        Wed, 01 May 2019 22:21:21 -0700 (PDT)
X-Received: by 2002:a37:a849:: with SMTP id r70mr1429435qke.315.1556774481608;
        Wed, 01 May 2019 22:21:21 -0700 (PDT)
Received: from turing-police ([2601:5c0:c001:4341:5952:f06b:5958:9b7c])
        by smtp.gmail.com with ESMTPSA id g206sm20904586qkb.75.2019.05.01.22.21.19
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 01 May 2019 22:21:20 -0700 (PDT)
From: "Valdis Kl=?utf-8?Q?=c4=93?=tnieks" <valdis.kletnieks@vt.edu>
X-Google-Original-From: "Valdis Kl=?utf-8?Q?=c4=93?=tnieks" <Valdis.Kletnieks@vt.edu>
X-Mailer: exmh version 2.9.0 11/07/2018 with nmh-1.7+dev
To: Pankaj Suryawanshi <pankajssuryawanshi@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
        kernelnewbies@kernelnewbies.org, Vlastimil Babka <vbabka@suse.cz>,
        Michal Hocko <mhocko@kernel.org>, minchan@kernel.org
Subject: Re: Page Allocation Failure and Page allocation stalls
In-Reply-To: <CACDBo57s_ZxmxjmRrCSwaqQzzO5r0SadzMhseeb9X0t0mOwJZA@mail.gmail.com>
References: <CACDBo57s_ZxmxjmRrCSwaqQzzO5r0SadzMhseeb9X0t0mOwJZA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1556774478_11736P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Date: Thu, 02 May 2019 01:21:19 -0400
Message-ID: <11029.1556774479@turing-police>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--==_Exmh_1556774478_11736P
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On Thu, 02 May 2019 04:56:05 +0530, Pankaj Suryawanshi said:

> Please help me to decode the error messages and reason for this errors.=


> =5B 3205.818891=5D HwBinder:1894_6: page allocation failure: order:7, m=
ode:0x14040c0(GFP_KERNEL=7C__GFP_COMP), nodemask=3D(null)

Order 7 - so it wants 2**7 contiguous pages.  128 4K pages.

> =5B 3205.967748=5D =5B<802186cc>=5D (__alloc_from_contiguous) from =5B<=
80218854>=5D (cma_allocator_alloc+0x44/0x4c)

And that 3205.nnn tells me the system has been running for almost an hour=
. Going
to be hard finding that much contiguous free memory.

Usually CMA is called right at boot to avoid this problem - why is this
triggering so late?

> =5B =A0671.925663=5D kworker/u8:13: page allocation stalls for 10090ms,=
 order:1, mode:0x15080c0(GFP_KERNEL_ACCOUNT=7C__GFP_ZERO), nodemask=3D(nu=
ll)

That's.... a *really* long stall.

> =5B =A0672.031702=5D =5B<8021e800>=5D (copy_process.part.5) from =5B<80=
2203b0>=5D (_do_fork+0xd0/0x464)
> =5B =A0672.039617=5D =A0r10:00000000 r9:00000000 r8:9d008400 r7:0000000=
0 r6:81216588 r5:9b62f840
> =5B =A0672.047441=5D =A0r4:00808111
> =5B =A0672.049972=5D =5B<802202e0>=5D (_do_fork) from =5B<802207a4>=5D =
(kernel_thread+0x38/0x40)
> =5B =A0672.057281=5D =A0r10:00000000 r9:81422554 r8:9d008400 r7:0000000=
0 r6:9d004500 r5:9b62f840
> =5B =A0672.065105=5D =A0r4:81216588
> =5B =A0672.067642=5D =5B<8022076c>=5D (kernel_thread) from =5B<802399b4=
>=5D (call_usermodehelper_exec_work+0x44/0xe0)

First possibility that comes to mind is that a usermodehelper got launche=
d, and
it then tried to fork with a very large active process image.  Do we have=
 any
clues what was going on?  Did a device get hotplugged?

--==_Exmh_1556774478_11736P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Comment: Exmh version 2.9.0 11/07/2018

iQIVAwUBXMp+TQdmEQWDXROgAQJZqxAAnxreoU88EHeovAeSkoiTH8XPfW74dkjJ
YUtiENuZTAiZBz+nMedbFkKpbNYb0eZWoJ8DMZQKhJ4ausU1uXhFT5NKVOZySX8P
a4vnlAABdw4n2n3weAVGTx/Drvr0wHgrwhZAQRCKDwXmmnRn91RUsX5expYmHRIg
/h6zZU+CLp0fWQZzUEsstUpV3ExUc/+3/5Jd+/0e0gWtCuK0Sbl7iCnb9TrG6xLW
7repzilTRzOYrGg9wSpT+FpmHJUoWfhW8Dn02tT0fflVBOlrs9JeFZituXv2+Zos
7BSoo1QrTYH5l2tQmIqKvkP7DZvwK1tYPcNSzlkISPS6+WcV/pd4YF1E+sPKi1j/
t3k7pUR76UrQ/yGqnqQyzfHZSYjRDdpeA4G3NBymrwUe7kVvGiUeIdGJ43QhHFnp
4jBOcR1gmDMkML9sW17pJgYAT5LLrVEonBIEYkje8niIG4D2KJWVjaUryefON33K
6/GFJGXHpaeT9ZENYEnfjB6viGeMresPs6pky4m1+XgqjZ4DHc6Gpat0gNzEUHid
wez5Zt4HCSgtifjdycsEyg7Bd4fYkXih/5+5MKwo0djvFT/PeervNyV896+quAP3
rswghjdziQRts67CakcgNs2+7HGyBAobpJDmr1Be/aWN6bMndk8m8CxENv2yL95p
ZYh7SZH5Y28=
=GETR
-----END PGP SIGNATURE-----

--==_Exmh_1556774478_11736P--

