Return-Path: <SRS0=RIH8=R4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7F1D5C10F03
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 15:42:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3BB99222A3
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 15:42:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3BB99222A3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C88DB6B0003; Mon, 25 Mar 2019 11:42:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C35396B0006; Mon, 25 Mar 2019 11:42:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AFDC96B0007; Mon, 25 Mar 2019 11:42:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8BEAB6B0003
	for <linux-mm@kvack.org>; Mon, 25 Mar 2019 11:42:58 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id d49so10523948qtk.8
        for <linux-mm@kvack.org>; Mon, 25 Mar 2019 08:42:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:references:organization:message-id:date:user-agent
         :mime-version:in-reply-to;
        bh=w81nE+EXYFAjfbSvXnUL/rqhqxOgqQClVPKiDrzhVzw=;
        b=Z0wrE6hs3Ezt6N9TfyLCymedfyYmU0DqSpmCu91YW0XC+AF2uUV7ql7kdBDDzZR5uu
         Hf11QbfX87HMWlPwngDtrGlslpDKo7ZYbkN8EfQQabwYOCHZbZZa/9prtj8LrylAXRtg
         skvMPEwnv/gfbN0MYXqalwdPIxqHv9LtVwpx1r+aPPwrz9IYlJZ8qj0tMfWeVV0RDPmf
         uTM0isW4NsyAcP+Q46l8BQ6WnQv0ke4wYu+3WHDPjcww6J+8IDhEp0mNtLyatsShG7MI
         lS2Udf4UnaQVuP8/RQviOFB774NvPy77bNeFiSl5ZVa44nGnO7QUzCjBDFq7Y9YZAdrd
         nBTA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXYWaMJwAOBQ43Eu099qwtJ0Sp8X4s9xCF93/5FhMIT3KZleJG4
	Xw48q26FXVRjnuYeS7XYqNBO6XyU9LzYR70M5MN+rjVcBbJjZ8zG99WYe/LIX78YfilXcZc+/GK
	xnF5jwQO+gnJvMGh+sLVh6Wq+GcLN/0rZjhkP66ERNBy7X4fEmmVhA92reH890mfViA==
X-Received: by 2002:ac8:268d:: with SMTP id 13mr21481862qto.53.1553528578302;
        Mon, 25 Mar 2019 08:42:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwKsFVEoUwaRjJl8YQOHHguT1sjpgUyzTwNpQQV8j6IyOUBZVQh4kEHgGMPIz/kl736VMC8
X-Received: by 2002:ac8:268d:: with SMTP id 13mr21481802qto.53.1553528577600;
        Mon, 25 Mar 2019 08:42:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553528577; cv=none;
        d=google.com; s=arc-20160816;
        b=kFVC0Ymy6OFa2vhcKxIZAqT9v4CGUGWdyDGFAR4ZXwsRlvrLq9O7bvPd6Q16UIUnsM
         jAOfk5aJkbKOtgpFmJRIXStvRcjpts9MeJD4QB2wAY+OWY9ewnbYfRldDQInK0JXeF5M
         P8SQjI9oCq+MQAwgKTrADu4rjsyjXGsM6x1yOrTgb9FxsPZ+7PobCCA5jlm5a2w2ylz5
         s0DfaFjTizyN5tfs08dTQDCapDwQmdZ00GM5EamD+DbUeIHrQyEjfJAajIiiWdJmfFrt
         iHAxZSwQHbJiW0r213oAZ6n8ZijLv3W3ipPpAMVayY/EZO2EM+PzLlxqX6z4nzfGyxVG
         +pwg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:mime-version:user-agent:date:message-id:organization
         :references:subject:cc:to:from;
        bh=w81nE+EXYFAjfbSvXnUL/rqhqxOgqQClVPKiDrzhVzw=;
        b=Sk6gd1sxxfCecWtogoaNauDLFHf9QT/YrEBGYuGDbTGAhy9ofk492wDkjHHHXmXXSi
         HUDs+R4izSR8qimq3pj+hpLFa+Vfgc2jfLebRKUN3G7v2LBAjwYRJKi+N7+UfAqGGz4b
         VJ12O80SjfTjjn4R3UOdAiZe5s8sR/PPS+J/kucdHVtLKctTRQxSnP0PzutpJtxHn7SK
         PvMBCcKrqRaYUJZw3/DMF9yzZOE/eMCJ2iXzMyosRpwo9+AvsZgYqHOs+/QoqYFlNUxy
         xpP+3piKJgw+Zs/EoJobW4348IsIZj6ES2WbYZZz3T0AbEo3lc/oYWgd5PZpilL27sUE
         RtcA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c41si3336937qta.88.2019.03.25.08.42.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Mar 2019 08:42:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 8E266309E979;
	Mon, 25 Mar 2019 15:42:56 +0000 (UTC)
Received: from [10.18.17.32] (dhcp-17-32.bos.redhat.com [10.18.17.32])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 3D0CE842B6;
	Mon, 25 Mar 2019 15:42:22 +0000 (UTC)
From: Nitesh Narayan Lal <nitesh@redhat.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
 David Hildenbrand <david@redhat.com>, kvm list <kvm@vger.kernel.org>,
 LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
 Paolo Bonzini <pbonzini@redhat.com>, lcapitulino@redhat.com,
 pagupta@redhat.com, wei.w.wang@intel.com,
 Yang Zhang <yang.zhang.wz@gmail.com>, Rik van Riel <riel@surriel.com>,
 dodgen@google.com, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
 dhildenb@redhat.com, Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [RFC][Patch v9 0/6] KVM: Guest Free Page Hinting
References: <20190306130955-mutt-send-email-mst@kernel.org>
 <ce55943e-87b6-c102-9827-2cfd45b7192c@redhat.com>
 <CAKgT0UcGCFNQRZFmp8oMkG+wKzRtwN292vtFWgyLsdyRnO04gQ@mail.gmail.com>
 <ed9f7c2e-a7e3-a990-bcc3-459e4f2b4a44@redhat.com>
 <4bd54f8b-3e9a-3493-40be-668962282431@redhat.com>
 <6d744ed6-9c1c-b29f-aa32-d38387187b74@redhat.com>
 <CAKgT0UcBDKr0ACHQWUCvmm8atxM6wSu7aCRFJkFvfjT_W_femQ@mail.gmail.com>
 <6709bb82-5e99-019d-7de0-3fded385b9ac@redhat.com>
 <6ab9b763-ac90-b3db-3712-79a20c949d5d@redhat.com>
 <99b9fa88-17b1-f2a9-7dd4-7a8f6e790d30@redhat.com>
 <20190325113543-mutt-send-email-mst@kernel.org>
Organization: Red Hat Inc,
Message-ID: <715834ec-71db-c78a-6949-2bdd2e02b262@redhat.com>
Date: Mon, 25 Mar 2019 11:42:11 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190325113543-mutt-send-email-mst@kernel.org>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="Ome6xoXIbCoRvokoosxPpacRPrkLNwvqT"
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.49]); Mon, 25 Mar 2019 15:42:56 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--Ome6xoXIbCoRvokoosxPpacRPrkLNwvqT
Content-Type: multipart/mixed; boundary="wwkf63jV0sTvhnaTwEhX3J79wvQJ7sZzm";
 protected-headers="v1"
From: Nitesh Narayan Lal <nitesh@redhat.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
 David Hildenbrand <david@redhat.com>, kvm list <kvm@vger.kernel.org>,
 LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
 Paolo Bonzini <pbonzini@redhat.com>, lcapitulino@redhat.com,
 pagupta@redhat.com, wei.w.wang@intel.com,
 Yang Zhang <yang.zhang.wz@gmail.com>, Rik van Riel <riel@surriel.com>,
 dodgen@google.com, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
 dhildenb@redhat.com, Andrea Arcangeli <aarcange@redhat.com>
Message-ID: <715834ec-71db-c78a-6949-2bdd2e02b262@redhat.com>
Subject: Re: [RFC][Patch v9 0/6] KVM: Guest Free Page Hinting

--wwkf63jV0sTvhnaTwEhX3J79wvQJ7sZzm
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 3/25/19 11:37 AM, Michael S. Tsirkin wrote:
> On Mon, Mar 25, 2019 at 10:27:46AM -0400, Nitesh Narayan Lal wrote:
>> I performed some experiments to see if the current implementation of
>> hinting breaks THP. I used AnonHugePages to track the THP pages
>> currently in use and memhog as the guest workload.
>> Setup:
>> Host Size: 30GB (No swap)
>> Guest Size: 15GB
>> THP Size: 2MB
>> Process: Guest is installed with different kernels to hint different
>> granularities(MAX_ORDER - 1, MAX_ORDER - 2 and MAX_ORDER - 3). Memhog=C2=
=A0
>> 15G is run multiple times in the same guest to see AnonHugePages usage=

>> in the host.
>>
>> Observation:
>> There is no THP split for order MAX_ORDER - 1 & MAX_ORDER - 2 whereas
>> for hinting granularity MAX_ORDER - 3 THP does split irrespective of
>> MADVISE_FREE or MADVISE_DONTNEED.
>> --=20
>> Regards
>> Nitesh
>>
> This is on x86 right?
Yes.
>  So THP is 2M and MAX_ORDER is 8M.
> MAX_ORDER - 3 =3D=3D> 1M.
> Seems to work out.
>
>
--=20
Regards
Nitesh


--wwkf63jV0sTvhnaTwEhX3J79wvQJ7sZzm--

--Ome6xoXIbCoRvokoosxPpacRPrkLNwvqT
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkXcoRVGaqvbHPuAGo4ZA3AYyozkFAlyY9tMACgkQo4ZA3AYy
ozn4cA//dAdKiNLLqGXpP4udkqrSmrA80bMipkea4/95uNL43eQYeWo/WEgsy0zK
AQNUMfTVH4Rc0eJd3pa8wrwKyfw02wZjbN0lTCUThCPXnSGxwvXX8KsmPNqX3Rxb
QgEmYow7y8H+j7HWIn/4o/YkrXKIDFN3cVLAyEExaCSI8lMjJO78rWtPjSiVrkPS
gbUe+86vYbQgmzYRb83gcjubDJ6kjxE7bRtuVSIUsuJExahAxeHUa8Q4M92MSYYq
V833gFO66mA3u5rbS9gAEQHIJk1KX4E5bje35CG2RUuGdYsEDKjcdejb2DsiAV8t
nsfMBWD8rkwAAbzoVAZBOQ6UoofaMfVti6Hx37UcYpJS/Z/VOB5BPJaZYw57OUgd
XnrKfu8aQmVYqAs/3x/0h76LS9qjUF630fjaa0Pq+2mJOu2ijhMc8JwvfnqnNttw
1v++5frXJ7/5lWxLMSfDKq0THZOeY8R7zuxdPXGcY+dhYYJncdODXtshXk9Zymir
mkLKbEYZfgPLnbb6fAfNwQF+gmsWdEC4a/tpvS9bNWh+hkk+jZhH5uaDqKgxpxSV
y3Tm3tyX733+HP3zb17K5hhauspK2zoXB3gHrDzMqoEtAE+d0VxODNtXQpR5WTm6
AW8PLDJwSd14avoTYLWadMl8bp+9do5ecBS75nxmNnp5gWc0kiA=
=Xk1k
-----END PGP SIGNATURE-----

--Ome6xoXIbCoRvokoosxPpacRPrkLNwvqT--

