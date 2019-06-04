Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 81234C282CE
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 16:48:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2E47223CE8
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 16:48:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2E47223CE8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BD6A06B0270; Tue,  4 Jun 2019 12:48:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B87C76B0271; Tue,  4 Jun 2019 12:48:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A00326B0272; Tue,  4 Jun 2019 12:48:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7BC476B0270
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 12:48:45 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id z8so11183685qti.1
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 09:48:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to;
        bh=QtTKZeDRFR0cOX+vyRaOPg5bwjwpVL4RmGqo5SeclQ8=;
        b=p4KUOvo7Cp0kjeiLL4WWxqIFsVlT9lsdE/LABa6Cdv6lmuyCdYyanX/sQeJOeMmAFo
         Cub8OiL3DXoHebTzJbhj0ir43g4GcBePRql5zwAmUo5KT5sE4S7GjFFMelAfglIZ+5wF
         oGqoHY1jjXIhnbu4XGlsSoEQIZsId85wZ739EasQHCqbqvhIAaoRYk1Qp/20LDGnnqGl
         mePaiLe0g5NKFNQ3heDTxrggOkXtVr9kgN9omUdRbPTSN69qQGufo24if9wrvdVavkAp
         R0yRyLIu718INQ92NBT7QAaCIOcwgs9sB1PEnOplWF92mTJG0qrePjkygK328KMtXLfg
         qqvQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAW2qrCR2ouTE4CT+/uBnoBUb7lKTjGGeBA4YOvNfS2w00YftIBS
	vkdk7ZIzGykiBf9NKWn7b+53AOYYvio7L/RXWR2i2q7FN+1QrniBlzfuJ+RhVM8R5c9xjURV02c
	EfclQunPRha3tN/DcvqhrFA8ai22gE+772PgaTAwRcvCYoJGJvcQ+ecpM6w+uTr0DqQ==
X-Received: by 2002:a37:4a81:: with SMTP id x123mr8831449qka.104.1559666925273;
        Tue, 04 Jun 2019 09:48:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqznITslIIxblRoyz5eyvS/JN8R7NPCC+axoE67GqiXho3fWAdw4zaq/V9o149tvGLfBs5h7
X-Received: by 2002:a37:4a81:: with SMTP id x123mr8831422qka.104.1559666924783;
        Tue, 04 Jun 2019 09:48:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559666924; cv=none;
        d=google.com; s=arc-20160816;
        b=nLdMtmrwiT9rV76gzAcGhywRlTIb1p2XJJESHfJLwi/iWuLDnQ5PO94SgzEcmlNhO8
         ZZmMi5FerDBR/x/Qp7OjkwsidRRaPnR6V7/jTwqS6vOfISvv0sQ/9up1/aP5RbmVipMC
         BD7KG5ho2GBvklOw8w3Taz4+06FS2CXkXBwcSLeH2jkf4AoG+RkmWMycHr+0WI0IJsVt
         QLVq/RdqM5s4IsC9euZN5DJ9JkXHnld148TVkMwATosCSwgctLEywPmYn8FwX9zR1fui
         SHvTf1fwqs9AguM4xxNeDsY13OI8ZEWQq8msKzQt8m7bjR6zqy17+zf4zEfnmt3QVN91
         Bxiw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:mime-version:user-agent:date:message-id:organization
         :autocrypt:openpgp:from:references:cc:to:subject;
        bh=QtTKZeDRFR0cOX+vyRaOPg5bwjwpVL4RmGqo5SeclQ8=;
        b=HRiunURIF0BKqfTFQHoqavizj/qX6KKWABJVuiEqrY4Xue7VosDPgIkqxDCSn+I5TE
         qJRy7X/ootc5f5paexjcjw5pAOpsslzUMz/h05D7zJHWzB4YC7ePGZ98KkBJSgAOU3Rx
         0DXJe+n2cT+PCxpYkIa9yPMCQEQ1TjLPd04TIVwLiberP1q9IcPdfLlsJ8/8zNSI6bnZ
         j10oXFtRuVP3zV2LOcgmYPDZcXkdOaWoKoM4X9FNjX2m2xOR7H7fPYauEc0aQ/FJGdTP
         rqEXKqISmpw+cwkJXO+kqGjQH8vwi7HP5rHczH0e66CojyMxtsBZA9hGCvwTJlnNtfah
         q/nQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z5si2403920qvp.194.2019.06.04.09.48.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Jun 2019 09:48:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id E07753087944;
	Tue,  4 Jun 2019 16:48:35 +0000 (UTC)
Received: from [10.40.205.182] (unknown [10.40.205.182])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 1E296611D6;
	Tue,  4 Jun 2019 16:48:15 +0000 (UTC)
Subject: Re: [QEMU PATCH] KVM: Support for page hinting
To: Alexander Duyck <alexander.duyck@gmail.com>
Cc: kvm list <kvm@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>,
 linux-mm <linux-mm@kvack.org>, Paolo Bonzini <pbonzini@redhat.com>,
 lcapitulino@redhat.com, pagupta@redhat.com, wei.w.wang@intel.com,
 Yang Zhang <yang.zhang.wz@gmail.com>, Rik van Riel <riel@surriel.com>,
 David Hildenbrand <david@redhat.com>, "Michael S. Tsirkin" <mst@redhat.com>,
 dodgen@google.com, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
 dhildenb@redhat.com, Andrea Arcangeli <aarcange@redhat.com>
References: <20190603170306.49099-1-nitesh@redhat.com>
 <20190603170432.1195-1-nitesh@redhat.com>
 <CAKgT0UeRzF24WeVkTN2WW41iKSUpXpZbpD55-g=MBHf814RV+A@mail.gmail.com>
From: Nitesh Narayan Lal <nitesh@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=nitesh@redhat.com; prefer-encrypt=mutual; keydata=
 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
 VujM7c/b4pps
Organization: Red Hat Inc,
Message-ID: <0194ca6a-ec00-2a43-545d-aee6459a7582@redhat.com>
Date: Tue, 4 Jun 2019 12:48:13 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <CAKgT0UeRzF24WeVkTN2WW41iKSUpXpZbpD55-g=MBHf814RV+A@mail.gmail.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="TLcRB331klf72kYiAgAoPavq6ytwUZyUY"
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.45]); Tue, 04 Jun 2019 16:48:36 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--TLcRB331klf72kYiAgAoPavq6ytwUZyUY
Content-Type: multipart/mixed; boundary="4e4kVK3A45X5fOFtNPeg6Nk226eTMC0od";
 protected-headers="v1"
From: Nitesh Narayan Lal <nitesh@redhat.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Cc: kvm list <kvm@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>,
 linux-mm <linux-mm@kvack.org>, Paolo Bonzini <pbonzini@redhat.com>,
 lcapitulino@redhat.com, pagupta@redhat.com, wei.w.wang@intel.com,
 Yang Zhang <yang.zhang.wz@gmail.com>, Rik van Riel <riel@surriel.com>,
 David Hildenbrand <david@redhat.com>, "Michael S. Tsirkin" <mst@redhat.com>,
 dodgen@google.com, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
 dhildenb@redhat.com, Andrea Arcangeli <aarcange@redhat.com>
Message-ID: <0194ca6a-ec00-2a43-545d-aee6459a7582@redhat.com>
Subject: Re: [QEMU PATCH] KVM: Support for page hinting
References: <20190603170306.49099-1-nitesh@redhat.com>
 <20190603170432.1195-1-nitesh@redhat.com>
 <CAKgT0UeRzF24WeVkTN2WW41iKSUpXpZbpD55-g=MBHf814RV+A@mail.gmail.com>
In-Reply-To: <CAKgT0UeRzF24WeVkTN2WW41iKSUpXpZbpD55-g=MBHf814RV+A@mail.gmail.com>

--4e4kVK3A45X5fOFtNPeg6Nk226eTMC0od
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Content-Language: en-US


On 6/4/19 12:41 PM, Alexander Duyck wrote:
> On Mon, Jun 3, 2019 at 10:04 AM Nitesh Narayan Lal <nitesh@redhat.com> =
wrote:
>> Enables QEMU to call madvise on the pages which are reported
>> by the guest kernel.
>>
>> Signed-off-by: Nitesh Narayan Lal <nitesh@redhat.com>
>> ---
>>  hw/virtio/trace-events                        |  1 +
>>  hw/virtio/virtio-balloon.c                    | 85 ++++++++++++++++++=
+
>>  include/hw/virtio/virtio-balloon.h            |  2 +-
>>  include/qemu/osdep.h                          |  7 ++
>>  .../standard-headers/linux/virtio_balloon.h   |  1 +
>>  5 files changed, 95 insertions(+), 1 deletion(-)
> <snip>
>
>> diff --git a/include/qemu/osdep.h b/include/qemu/osdep.h
>> index 840af09cb0..4d632933a9 100644
>> --- a/include/qemu/osdep.h
>> +++ b/include/qemu/osdep.h
>> @@ -360,6 +360,11 @@ void qemu_anon_ram_free(void *ptr, size_t size);
>>  #else
>>  #define QEMU_MADV_REMOVE QEMU_MADV_INVALID
>>  #endif
>> +#ifdef MADV_FREE
>> +#define QEMU_MADV_FREE MADV_FREE
>> +#else
>> +#define QEMU_MADV_FREE QEMU_MADV_INVALID
>> +#endif
> Is there a specific reason for making this default to INVALID instead
> of just using DONTNEED?
No specific reason.
>  I ran into some issues as my host kernel
> didn't have support for MADV_FREE in the exported kernel headers
> apparently so I was getting no effect. It seems like it would be
> better to fall back to doing DONTNEED instead of just disabling the
> functionality all together.
Possibly, I will further look into it.
>>  #elif defined(CONFIG_POSIX_MADVISE)
>>
>> @@ -373,6 +378,7 @@ void qemu_anon_ram_free(void *ptr, size_t size);
>>  #define QEMU_MADV_HUGEPAGE  QEMU_MADV_INVALID
>>  #define QEMU_MADV_NOHUGEPAGE  QEMU_MADV_INVALID
>>  #define QEMU_MADV_REMOVE QEMU_MADV_INVALID
>> +#define QEMU_MADV_FREE QEMU_MADV_INVALID
> Same here. If you already have MADV_DONTNEED you could just use that
> instead of disabling the functionality.
>
>>  #else /* no-op */
>>
>> @@ -386,6 +392,7 @@ void qemu_anon_ram_free(void *ptr, size_t size);
>>  #define QEMU_MADV_HUGEPAGE  QEMU_MADV_INVALID
>>  #define QEMU_MADV_NOHUGEPAGE  QEMU_MADV_INVALID
>>  #define QEMU_MADV_REMOVE QEMU_MADV_INVALID
>> +#define QEMU_MADV_FREE QEMU_MADV_INVALID
>>
>>  #endif
>>
--=20
Regards
Nitesh


--4e4kVK3A45X5fOFtNPeg6Nk226eTMC0od--

--TLcRB331klf72kYiAgAoPavq6ytwUZyUY
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkXcoRVGaqvbHPuAGo4ZA3AYyozkFAlz2oM0ACgkQo4ZA3AYy
ozkA/Q//ZRIMGLMXhxoYzE4ppch83oeD+378YExYsIKrUaWCfG8x6PaEjZ/mfSiF
YmKSq9CHK8MhELTPPwbba/9/SHGtWa0rD3LL1RHR2GO7QtpcF3YbUR74GipuGbNM
WlLicfK0xAupX8iYaTntB9FWO4GOfadQOAfWO5bLT0C2PcYA6ChKQMmVBGDnKtiI
wORJjlYLfW5NQ2Yqe8UjI5+GeqIiDsT32T41vbdV7g4LC1HCQhhsXrSYnq7AgLpj
e7DtZP1KAse3hN7Wdya4QONN4yqDcUgCZHH/H6Eq60hOjE7vIWO5JP8+kDIae/I1
sAzobLZi1SF7ZrwaT9C41jUkKojjnb7/rm/YjAX1W1fgbxQOaTV2j/ipSnguBMC+
jx6KQdS2ybiikGLb9jaT/vxkQHuSMwPU7+9rmAlkd//H3zA966yh84ZSGUku7jeI
I/ONAtGzd5u+CyPg/2wfFKEZHYa7336ts8yIXIUbQisvgt21nfDR6y9V8WZEHLul
aQJeGYrJPHeAaaBFdV0O8JD4nWoct5X7jbnWXIFf6h8FepV5aVjxtGKnH7JyAQmQ
KMx72W2gEqUKGf33iAWh/4IzmpPdefNzFkucKe/KpTMOCHiTvx1qZ9KKBzq5gXUp
E1WPdIoxrWxi7KOtRzYmGZimN0zqo4oAjbCxHG4ogFtWu/nPUIQ=
=4/9C
-----END PGP SIGNATURE-----

--TLcRB331klf72kYiAgAoPavq6ytwUZyUY--

