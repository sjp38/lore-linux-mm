Return-Path: <SRS0=NBIx=RK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 491B7C10F03
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 12:23:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D12B620643
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 12:23:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D12B620643
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 395708E0003; Thu,  7 Mar 2019 07:23:58 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 31E1A8E0002; Thu,  7 Mar 2019 07:23:58 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1C08D8E0003; Thu,  7 Mar 2019 07:23:58 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id E00DE8E0002
	for <linux-mm@kvack.org>; Thu,  7 Mar 2019 07:23:57 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id o56so15018321qto.9
        for <linux-mm@kvack.org>; Thu, 07 Mar 2019 04:23:57 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to;
        bh=1uf/x6Sjrr8fEnbi/qi7BEiTDOkMflESMxmwhbKjXOs=;
        b=MLTFEqZb0eI1upipQyhGo/qF05enM4wJsdJFVUWAbDKroTv4jEdB1MUEDLksKpALRv
         0PYYX6exFO1ghmhrhLykA6QEQinj1HsfgRGlmFTg/XMtxVX7Eql71xnT1ptjO/buLyxh
         vSuiAXjeb4uVX1UlrVhy4sUh/aa9R/JLooJKFJJTvoYRdCy/Z/2KImquZXgPcV9qdeFw
         OF5qTk8av93DYkPitsGMrjjeH94O2d4OrcpCkd7eZR7cWCgC9aoi9o4E0FRQTogLGSt9
         e/2hNMHj6liorJLCwkPkru8ShkcJlSHxlcMaY4xMz14G4fIWu7+ELKeAL0KGl0XlR/92
         fvsQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAV4gfTuIz1Fn/RdK45+8786i78NqDyMYPGsU8pQ6SJJksqM0ckT
	rqBfv3sTQqO03GEdLthrVkBUXDJ48tIFdVWSg+mLYVUKztDJnQrjdGahgMFN5HI37WAItgWqAjs
	UKSnkl6N93RhpGPKDfRQ+fnRPRVhShKo5tqAryfBtGMs0e3h5bZ9LX50NK6autgxWUA==
X-Received: by 2002:a0c:9848:: with SMTP id e8mr10527932qvd.80.1551961437568;
        Thu, 07 Mar 2019 04:23:57 -0800 (PST)
X-Google-Smtp-Source: APXvYqztIILSZDFmrSHv3M70GQHRC6rRgqQCeER6vSEsUy3pl+MjsgsFxjAFbQa/XJI2He7poTU6
X-Received: by 2002:a0c:9848:: with SMTP id e8mr10527864qvd.80.1551961436025;
        Thu, 07 Mar 2019 04:23:56 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551961436; cv=none;
        d=google.com; s=arc-20160816;
        b=nSwdej9fsFvJbK6Dk+wmsuou+gszarBDjBe/jxXFQMhgwHDNHxnlsSrqo2X5wP+NsO
         CQNKzRE8Ezs2n0uno9IwQA0XPig4PI6EU26E0sjgI6vhmTEsa6ljIBKbuebO+QrRwIaz
         OSXVGQKfmyTrEQEOyCg+4zNXyHVMxQgYTPwjStPygXGZ0vSEgrc9ZOkar315MFIxsWEg
         b+Rft8Lcs6EtUmAKtxu3pm9sOI3RG/4T3S0T6S4MRyaDjN3F/yCNrrUcip4Rt9HrzmPN
         OdpxMYOXza3v38Yl0ab5z8LmWKW4DeommQxY3N4IhV+cULGDI1fCskJuDcWjTAH64as1
         sxYw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:mime-version:user-agent:date:message-id:organization
         :autocrypt:openpgp:from:references:cc:to:subject;
        bh=1uf/x6Sjrr8fEnbi/qi7BEiTDOkMflESMxmwhbKjXOs=;
        b=h7WQqBl/Mpuy/JS9jNnGp7kc06EN1dtQNJBRbL1yki2tvS2eRwVciBe7J2V/EBzeTd
         NFgGgiuxs7e3Bgp++ut4CuVwAh1NS8s/LeLiJ3ZfmDMatBzB2km7dvZasBAkcJpkPO28
         XoVnfSbtGrEK44OYS1f+7wl+VMgfNRTBlLOQAz2Z7mgGEMi2KDTb8tiJVZ86ENVSpjPR
         tIS7FJZa9H6UeWrz96ZZtkqQW1PcINwKKtkaeZ9M0xDkAnQAYWAn+jgtoHf2gFGqn7xy
         R7PvQAn0ph0oQMnFIKmlkUlys4g+JW8XKqCAplz7kzF79RYHq9v29V/1RpefNS7p01vg
         evJQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i7si2715518qvi.199.2019.03.07.04.23.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Mar 2019 04:23:56 -0800 (PST)
Received-SPF: pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id C21E82D7E7;
	Thu,  7 Mar 2019 12:23:54 +0000 (UTC)
Received: from [10.18.17.32] (dhcp-17-32.bos.redhat.com [10.18.17.32])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id D89905C1A1;
	Thu,  7 Mar 2019 12:23:39 +0000 (UTC)
Subject: Re: [RFC][QEMU Patch] KVM: Enable QEMU to free the pages hinted by
 the guest
To: Alexander Duyck <alexander.duyck@gmail.com>
Cc: yang.zhang.wz@gmail.com, pagupta@redhat.com, kvm@vger.kernel.org,
 riel@surriel.com, david@redhat.com, linux-kernel@vger.kernel.org,
 lcapitulino@redhat.com, linux-mm@kvack.org, wei.w.wang@intel.com,
 aarcange@redhat.com, mst@redhat.com, dhildenb@redhat.com,
 pbonzini@redhat.com, dodgen@google.com, konrad.wilk@oracle.com
References: <CAKgT0Ue=kGB4D2oV1WUmWHiYhrXa64KWBP2ZhLgHNgvWyOng5A@mail.gmail.com>
 <20190307003207.25058.4638.stgit@localhost.localdomain>
From: Nitesh Narayan Lal <nitesh@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=nitesh@redhat.com; prefer-encrypt=mutual; keydata=
 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
 VujM7c/b4pps
Organization: Red Hat Inc,
Message-ID: <29ba32be-57fd-836e-9ed3-5c21c91036b2@redhat.com>
Date: Thu, 7 Mar 2019 07:23:36 -0500
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190307003207.25058.4638.stgit@localhost.localdomain>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="FThXPCLxrgJtkrilTjuJ78EhGOtZOz06z"
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.30]); Thu, 07 Mar 2019 12:23:55 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--FThXPCLxrgJtkrilTjuJ78EhGOtZOz06z
Content-Type: multipart/mixed; boundary="BCydxPgVgrZFj8L93SYvOdPSKRgrc9wHj";
 protected-headers="v1"
From: Nitesh Narayan Lal <nitesh@redhat.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Cc: yang.zhang.wz@gmail.com, pagupta@redhat.com, kvm@vger.kernel.org,
 riel@surriel.com, david@redhat.com, linux-kernel@vger.kernel.org,
 lcapitulino@redhat.com, linux-mm@kvack.org, wei.w.wang@intel.com,
 aarcange@redhat.com, mst@redhat.com, dhildenb@redhat.com,
 pbonzini@redhat.com, dodgen@google.com, konrad.wilk@oracle.com
Message-ID: <29ba32be-57fd-836e-9ed3-5c21c91036b2@redhat.com>
Subject: Re: [RFC][QEMU Patch] KVM: Enable QEMU to free the pages hinted by
 the guest
References: <CAKgT0Ue=kGB4D2oV1WUmWHiYhrXa64KWBP2ZhLgHNgvWyOng5A@mail.gmail.com>
 <20190307003207.25058.4638.stgit@localhost.localdomain>
In-Reply-To: <20190307003207.25058.4638.stgit@localhost.localdomain>

--BCydxPgVgrZFj8L93SYvOdPSKRgrc9wHj
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Content-Language: en-US


On 3/6/19 7:35 PM, Alexander Duyck wrote:
> Here are some changes I made to your patch in order to address the sizi=
ng
> issue I called out. You may want to try testing with this patch applied=
 to
> your QEMU as I am finding it is making a signficant difference. It has =
cut
> the test time for the 32G memhog test I called out earlier in half.
Thanks, I will try this out.
>
> Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> ---
>  hw/virtio/virtio-balloon.c |   28 +++++++++++++++++-----------
>  1 file changed, 17 insertions(+), 11 deletions(-)
>
> diff --git a/hw/virtio/virtio-balloon.c b/hw/virtio/virtio-balloon.c
> index d2cf66ada3c0..3ca6b1c6d511 100644
> --- a/hw/virtio/virtio-balloon.c
> +++ b/hw/virtio/virtio-balloon.c
> @@ -285,7 +285,7 @@ static void balloon_stats_set_poll_interval(Object =
*obj, Visitor *v,
>      balloon_stats_change_timer(s, 0);
>  }
> =20
> -static void *gpa2hva(MemoryRegion **p_mr, hwaddr addr, Error **errp)
> +static void *gpa2hva(MemoryRegion **p_mr, unsigned long *size, hwaddr =
addr, Error **errp)
>  {
>      MemoryRegionSection mrs =3D memory_region_find(get_system_memory()=
,
>                                                   addr, 1);
> @@ -302,6 +302,7 @@ static void *gpa2hva(MemoryRegion **p_mr, hwaddr ad=
dr, Error **errp)
>      }
> =20
>      *p_mr =3D mrs.mr;
> +    *size =3D mrs.mr->size - mrs.offset_within_region;
>      return qemu_map_ram_ptr(mrs.mr->ram_block, mrs.offset_within_regio=
n);
>  }
> =20
> @@ -313,30 +314,35 @@ void page_hinting_request(uint64_t addr, uint32_t=
 len)
>      struct guest_pages *guest_obj;
>      int i =3D 0;
>      void *hvaddr_to_free;
> -    unsigned long pfn, pfn_end;
>      uint64_t gpaddr_to_free;
> -    void * temp_addr =3D gpa2hva(&mr, addr, &local_err);
> +    unsigned long madv_size, size;
> +    void * temp_addr =3D gpa2hva(&mr, &madv_size, addr, &local_err);
> =20
>      if (local_err) {
>          error_report_err(local_err);
>          return;
>      }
> +    if (madv_size < sizeof(*guest_obj)) {
> +	printf("\nBad guest object ptr\n");
> +	return;
> +    }
>      guest_obj =3D temp_addr;
>      while (i < len) {
> -        pfn =3D guest_obj[i].pfn;
> -	pfn_end =3D guest_obj[i].pfn + (1 << guest_obj[i].order) - 1;
> -	trace_virtio_balloon_hinting_request(pfn,(1 << guest_obj[i].order));
> -	while (pfn <=3D pfn_end) {
> -	        gpaddr_to_free =3D pfn << VIRTIO_BALLOON_PFN_SHIFT;
> -	        hvaddr_to_free =3D gpa2hva(&mr, gpaddr_to_free, &local_err);
> +        gpaddr_to_free =3D guest_obj[i].pfn << VIRTIO_BALLOON_PFN_SHIF=
T;
> +	size =3D (1 << VIRTIO_BALLOON_PFN_SHIFT) << guest_obj[i].order;
> +	while (size) {
> +	        hvaddr_to_free =3D gpa2hva(&mr, &madv_size, gpaddr_to_free, &=
local_err);
>  	        if (local_err) {
>  			error_report_err(local_err);
>  		        return;
>  		}
> -		ret =3D qemu_madvise((void *)hvaddr_to_free, 4096, QEMU_MADV_DONTNEE=
D);
> +		if (size < madv_size)
> +			madv_size =3D size;
> +		ret =3D qemu_madvise((void *)hvaddr_to_free, madv_size, QEMU_MADV_DO=
NTNEED);
>  		if (ret =3D=3D -1)
>  		    printf("\n%d:%s Error: Madvise failed with error:%d\n", __LINE__=
, __func__, ret);
> -		pfn++;
> +		gpaddr_to_free +=3D madv_size;
> +		size -=3D madv_size;
>  	}
>  	i++;
>      }
>
--=20
Regards
Nitesh


--BCydxPgVgrZFj8L93SYvOdPSKRgrc9wHj--

--FThXPCLxrgJtkrilTjuJ78EhGOtZOz06z
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkXcoRVGaqvbHPuAGo4ZA3AYyozkFAlyBDUoACgkQo4ZA3AYy
ozkLURAA0HQYweR2tnO1OypmEcI1ba/kqel+S0dN+XssepAOrP1OqSbPOlasY76r
wL+HDA5ASTjRIlSgJR10wb/imstPvzTORihlfHhIyOtVUghFezy1EQr2sjhh+vU1
KQ6XShARtgcHjHIh8+TUc3u5LWiNwfo+OjQCFvjyfkfaitmCr0lws4LzrDmkjblw
XDIQLeNZHNZNa3PEChzOEnbZMgvXycHwMDF+L7JXIH+i8IgpS9foKzflWAOJF68B
yOxmP6Auzkdj6aWP5t96REGV0uX2bfKQmzg/85k/waU43Q9s0qzHtoXbtmA28P3C
/5mC0UTXr44qCMoE/RnVfCkOGCuUKreXR84Uh7FAWyzb08LqkdphEyd07PwLkIym
YxHHzDLxZ51BIU/NWscUq1mYj2j5cQevUwLiRYtt60Xk3lU63gtH4HsQpvNjgQUU
ZQzJj9zj5eKccc1Wh1Y3fZiBVRw6YvVZH3/mLpR6WkeduBOXrWT9PBNMhkClAI0s
mrhQAR2Yz8RWG/IF40Jl28pbGbA2G7fAldNNccDa//Fao+Sv2oe21uEXTeYZS3nD
Gd9VVsgLA/QNli7YaAk6/BDto30ndAm8n3yaSiYrRDce0l1Jp4ZIDaJ8vOI1MuR3
49FYTlh26lDZVyXH+lg3wB8Ht6jwc6aEDqk1CEqUz7bYo7KULlk=
=94t/
-----END PGP SIGNATURE-----

--FThXPCLxrgJtkrilTjuJ78EhGOtZOz06z--

