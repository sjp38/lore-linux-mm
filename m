Return-Path: <SRS0=GtRI=VJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 05970C742D1
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 16:45:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B0A032080A
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 16:45:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=amacapital-net.20150623.gappssmtp.com header.i=@amacapital-net.20150623.gappssmtp.com header.b="y+5Jhhgm"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B0A032080A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=amacapital.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4948E8E015E; Fri, 12 Jul 2019 12:45:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 444C18E0003; Fri, 12 Jul 2019 12:45:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 30D248E015E; Fri, 12 Jul 2019 12:45:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 075C08E0003
	for <linux-mm@kvack.org>; Fri, 12 Jul 2019 12:45:11 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id e103so4865233ote.2
        for <linux-mm@kvack.org>; Fri, 12 Jul 2019 09:45:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=6LnAzjOasKxUwXGzTNC0/064h+/s+kUgeRd8GGr+dNc=;
        b=ff8dv8IIS+c9JYJkW3XJxeV80mt20mC2/RIVslm05TPZvLRIpMwKGyXr+VYWY360lH
         DDJ6dyCimm9xo+W4+km1RApmLsFvtjTGixXtOFihgaUqLZS2oNyQXwofDivxtJtiWiAA
         Ut8+oLxMjaaIVqNEXrsm/5OADCrdVsNeM9EPSSlAIRJBz6yP6+VhCexWvRiUjFSr8szC
         5qdzhHA4jT9Bwl1QDQJrCWc4icg7bYgs+1uK0Jrb6e6NwpFWdxCT8aT+AvB2qSVDwp7q
         1LJouyRViTQczV1gMo6wgdvC6cbm+/2GTGakaN2CRDlfJXNp0uklUTKM6XrabpfrjBut
         X8UA==
X-Gm-Message-State: APjAAAW82MY3ncQw5jaYlc0WBX/Gw/90G1Vop92fm+rtd/jh5m+2pF8Q
	QLNAOtY6qLQsVzHGMr4T279uRREokjawHWQ+YjiDhxuVCI/m50CgnGoT9WkisSjelJ3syllW3L8
	8sW1Sfc/PCWv6d3m2YQMk2gbyVoy4r37MUVAZ50GQgmmx5+TleYQv9JT2kUbuMwjbaQ==
X-Received: by 2002:a9d:6195:: with SMTP id g21mr9544257otk.103.1562949910589;
        Fri, 12 Jul 2019 09:45:10 -0700 (PDT)
X-Received: by 2002:a9d:6195:: with SMTP id g21mr9544220otk.103.1562949909864;
        Fri, 12 Jul 2019 09:45:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562949909; cv=none;
        d=google.com; s=arc-20160816;
        b=O7JacjOYXu9yRRJl40lNg1vXhiaTP7bW8kJnx1H3hb/daI8GpFr2MvsaQiQbQdM1uF
         GTjxeGSvQqd9nC7kbTjLxQFF4Rx+EwKkyL/6nayyNOxttPx/oqDiBbMEuzf87EXohlc5
         HGK/6OMvH2dDZY34Hgm94BYPJSxscX4TUOb/Rjldb1B4wlUD9xnyGKJ+b+CdCFjWAL/F
         kHlztiwFsFb8/UJd2/UIf/oJq7iIui5opvhvPjfYuIjdu6L6I3FdF21mCDmh04Ia0ZpC
         ho+8IaVs8+4LFoAR8bRHhV0q71Rd6ucr1BYGii3sOE49ViqrHiyQTKHl5Z3NhYVg1+W0
         zz9g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=6LnAzjOasKxUwXGzTNC0/064h+/s+kUgeRd8GGr+dNc=;
        b=qcGd9Pl7kDBFgZSm3QaPszUf8HYDnNvM5s5lyaVJRIVs6IoaZAGH7cB6bN6WTYOwJ6
         /h4I2KRaseya+fwUKYRwTqYPSg+U6x5JTZDWLkOQXdTHDitUQbvizilrc9K24HQlEsgl
         0QvVI0nHnWgKlriarVS1Xz8UEtz1wg/KjErBSjXWh5A1RhSEcSV4BpyopVhpsGIStjGE
         XJArb9NWE9DTMF3SLivnvS0mGXlMFWZOGpMT5dG2ZIpYN2h8hXh18YRwuGqkfmiN3MNQ
         eeCG58gC336J6dyoJT/AH4zMa5nB3tZEJxGZW4W54ETg8GjOeR8dcCuwU+a9pp1ffCmV
         3qSw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amacapital-net.20150623.gappssmtp.com header.s=20150623 header.b=y+5Jhhgm;
       spf=pass (google.com: domain of luto@amacapital.net designates 209.85.220.65 as permitted sender) smtp.mailfrom=luto@amacapital.net
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r64sor4619486oih.55.2019.07.12.09.45.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 12 Jul 2019 09:45:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of luto@amacapital.net designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amacapital-net.20150623.gappssmtp.com header.s=20150623 header.b=y+5Jhhgm;
       spf=pass (google.com: domain of luto@amacapital.net designates 209.85.220.65 as permitted sender) smtp.mailfrom=luto@amacapital.net
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=amacapital-net.20150623.gappssmtp.com; s=20150623;
        h=mime-version:subject:from:in-reply-to:date:cc
         :content-transfer-encoding:message-id:references:to;
        bh=6LnAzjOasKxUwXGzTNC0/064h+/s+kUgeRd8GGr+dNc=;
        b=y+5JhhgmNMeM1wyuwj/XzOeYCh3l6ziC7Q771WlrgOuxNGzdruLij0Bd0bIoG5jM3d
         Db3yFOQe9oJ72rqInCLv5IT5U/tzZ44PeQK0oBMW4m+IauKOslZy7IC+GgteBJcQrXLS
         w3h9o5dlT/8wb9rL46HzQKkWKfxY+n/JIPNZ9G2FZIINBpDbDTRFNRtcHxKDRJVpwEqH
         nipdZSzIaSUQBX0DYu19v+AM+C3QxQZUmy1qXgyaytK38F3Sv+yUnmfjmLiB7/oZYGXu
         73n0iYnMYyaID7e2Y6q3kyCjzXOYqsuihAlcYX+2cpr0DFcDvSj1C1ys/nJkkUVByenh
         Fn4g==
X-Google-Smtp-Source: APXvYqz43gvQBuChWBqcRDiu2PX0SnPMLctG+UPHeFtjNbnJ7Bi0dOA9Iyg8NVe3bAqg2MsnU8zG+w==
X-Received: by 2002:aca:cfd0:: with SMTP id f199mr6026297oig.50.1562949909275;
        Fri, 12 Jul 2019 09:45:09 -0700 (PDT)
Received: from ?IPv6:2600:100e:b03e:b:3dba:7fb8:8988:ae37? ([2600:100e:b03e:b:3dba:7fb8:8988:ae37])
        by smtp.gmail.com with ESMTPSA id l5sm3141381otf.53.2019.07.12.09.45.08
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Jul 2019 09:45:08 -0700 (PDT)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (1.0)
Subject: Re: [RFC v2 00/27] Kernel Address Space Isolation
From: Andy Lutomirski <luto@amacapital.net>
X-Mailer: iPhone Mail (16F203)
In-Reply-To: <3ca70237-bf8e-57d9-bed5-bc2329d17177@oracle.com>
Date: Fri, 12 Jul 2019 10:45:06 -0600
Cc: Thomas Gleixner <tglx@linutronix.de>,
 Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>,
 pbonzini@redhat.com, rkrcmar@redhat.com, mingo@redhat.com, bp@alien8.de,
 hpa@zytor.com, dave.hansen@linux.intel.com, luto@kernel.org,
 kvm@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, konrad.wilk@oracle.com,
 jan.setjeeilers@oracle.com, liran.alon@oracle.com, jwadams@google.com,
 graf@amazon.de, rppt@linux.vnet.ibm.com, Paul Turner <pjt@google.com>
Content-Transfer-Encoding: quoted-printable
Message-Id: <7FDF08CB-A429-441B-872D-FAE7293858F5@amacapital.net>
References: <1562855138-19507-1-git-send-email-alexandre.chartre@oracle.com> <5cab2a0e-1034-8748-fcbe-a17cf4fa2cd4@intel.com> <alpine.DEB.2.21.1907120911160.11639@nanos.tec.linutronix.de> <61d5851e-a8bf-e25c-e673-b71c8b83042c@oracle.com> <20190712125059.GP3419@hirez.programming.kicks-ass.net> <alpine.DEB.2.21.1907121459180.1788@nanos.tec.linutronix.de> <3ca70237-bf8e-57d9-bed5-bc2329d17177@oracle.com>
To: Alexandre Chartre <alexandre.chartre@oracle.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Jul 12, 2019, at 10:37 AM, Alexandre Chartre <alexandre.chartre@oracle.=
com> wrote:
>=20
>=20
>=20
>> On 7/12/19 5:16 PM, Thomas Gleixner wrote:
>>> On Fri, 12 Jul 2019, Peter Zijlstra wrote:
>>>> On Fri, Jul 12, 2019 at 01:56:44PM +0200, Alexandre Chartre wrote:
>>>>=20
>>>> I think that's precisely what makes ASI and PTI different and independe=
nt.
>>>> PTI is just about switching between userland and kernel page-tables, wh=
ile
>>>> ASI is about switching page-table inside the kernel. You can have ASI w=
ithout
>>>> having PTI. You can also use ASI for kernel threads so for code that wo=
n't
>>>> be triggered from userland and so which won't involve PTI.
>>>=20
>>> PTI is not mapping         kernel space to avoid             speculation=
 crap (meltdown).
>>> ASI is not mapping part of kernel space to avoid (different) speculation=
 crap (MDS).
>>>=20
>>> See how very similar they are?
>>>=20
>>> Furthermore, to recover SMT for userspace (under MDS) we not only need
>>> core-scheduling but core-scheduling per address space. And ASI was
>>> specifically designed to help mitigate the trainwreck just described.
>>>=20
>>> By explicitly exposing (hopefully harmless) part of the kernel to MDS,
>>> we reduce the part that needs core-scheduling and thus reduce the rate
>>> the SMT siblngs need to sync up/schedule.
>>>=20
>>> But looking at it that way, it makes no sense to retain 3 address
>>> spaces, namely:
>>>=20
>>>   user / kernel exposed / kernel private.
>>>=20
>>> Specifically, it makes no sense to expose part of the kernel through MDS=

>>> but not through Meltdow. Therefore we can merge the user and kernel
>>> exposed address spaces.
>>>=20
>>> And then we've fully replaced PTI.
>>>=20
>>> So no, they're not orthogonal.
>> Right. If we decide to expose more parts of the kernel mappings then that=
's
>> just adding more stuff to the existing user (PTI) map mechanics.
>=20
> If we expose more parts of the kernel mapping by adding them to the existi=
ng
> user (PTI) map, then we only control the mapping of kernel sensitive data b=
ut
> we don't control user mapping (with ASI, we exclude all user mappings).
>=20
> How would you control the mapping of userland sensitive data and exclude t=
hem
> from the user map?

As I see it, if we think part of the kernel is okay to leak to VM guests, th=
en it should think it=E2=80=99s okay to leak to userspace and versa. At the e=
nd of the day, this may just have to come down to an administrator=E2=80=99s=
 choice of how careful the mitigations need to be.

> Would you have the application explicitly identify sensitive
> data (like Andy suggested with a /dev/xpfo device)?

That=E2=80=99s not really the intent of my suggestion. I was suggesting that=
 maybe we don=E2=80=99t need ASI at all if we allow VMs to exclude their mem=
ory from the kernel mapping entirely.  Heck, in a setup like this, we can ma=
ybe even get away with turning PTI off under very, very controlled circumsta=
nces.  I=E2=80=99m not quite sure what to do about the kernel random pools, t=
hough.=

