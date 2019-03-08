Return-Path: <SRS0=92PK=RL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CAFF0C10F09
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 19:10:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7B4EB206DF
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 19:10:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7B4EB206DF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 139E88E0003; Fri,  8 Mar 2019 14:10:43 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 113188E0002; Fri,  8 Mar 2019 14:10:43 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 001568E0003; Fri,  8 Mar 2019 14:10:42 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id CD9948E0002
	for <linux-mm@kvack.org>; Fri,  8 Mar 2019 14:10:42 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id i3so19437129qtc.7
        for <linux-mm@kvack.org>; Fri, 08 Mar 2019 11:10:42 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to;
        bh=FMBr24ynMW9XPu7VBssYQrMAzHMlm70SAIn8+HmMO90=;
        b=p3VELv89tgTMqepm3PKK3m8ulFRSAqwP6jtkNyI6p54fcmShzv0shgC6f6G/k78hUc
         8iR6M070pq8ZM1XJhXeBkBHEdat1YkeQ2N3js2w/+qUoxYNJXOQbOjfYYHsNw3K72L8t
         i9HuEc/IeYw0cnxOLQeB4+TlFSjNlygUoQ/gkWIY9/bEFIth0C/ovyYyAmuW1sWvqZ7p
         Lo0j5n3+v5n+4prx6E0vXnPTkb9MAV0eDIBR7/eVmrtIqE+kIJIHdvwZ3uT8nWHfkXrG
         KpjeJxZGpYMt+xHt5M4B8iFv6Qch0rexXFkArtwTIhCj6P4XDdWvz5cGy1Lrj+vOHQke
         9IPg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVMehI+AH25wu9IohWKsUUOw9pWw5AkFIqbeAJDLH5+vkFZhYGS
	D+H/tkRjtsvR2Odpv1LDNXbSyW+PTnRwuALEWhpixNgznFcSmMjoKLOYsoTbuIEBxOQX7xyyHWA
	GUKiCGyVRYnSP2sK23UO/tS9ppeZIB954SHTsHxY5skVCTdbYpG1co/kwAjHeDz2tZA==
X-Received: by 2002:a37:657:: with SMTP id 84mr14551515qkg.86.1552072242572;
        Fri, 08 Mar 2019 11:10:42 -0800 (PST)
X-Google-Smtp-Source: APXvYqwYYPctBL/jBuQJ4o+5RhPSRFf6D3eOgfYviSMB2Q9yxiztqeP3s23LOHR5WbL2XLPm7moT
X-Received: by 2002:a37:657:: with SMTP id 84mr14551465qkg.86.1552072241502;
        Fri, 08 Mar 2019 11:10:41 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1552072241; cv=none;
        d=google.com; s=arc-20160816;
        b=nr0cYzkdwFC9RhQlszvUkxmKACuOtAwh6Fn8U85wugluqiKNaITmwnklXk4WlkZz75
         Ts3qixg3jkTw2xBg/3rQYlXRZuxo29qLHc30gnPcPXaTOYyqu2qxTpHqTf8MVp3yRCv9
         xI4jzQtb7M7OifajZIbK8CyonDLloBJSdSzoULxf/Qr42n3anmYseIuiH6hzx9f04XHL
         PwLKBRaHPs+6h5YlANjm40ybTx5ZSMKdpoNuf6pt/4HiyaG1TOgPAqxx3LV6Ywhbgw0N
         JyMDQiACWri2+8jOBAscVYcwUTus+14U+FIM0kVopfDVN9yZ/DgCo9/nSh3a70Bahpvx
         7B2A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:mime-version:user-agent:date:message-id:organization
         :autocrypt:openpgp:from:references:cc:to:subject;
        bh=FMBr24ynMW9XPu7VBssYQrMAzHMlm70SAIn8+HmMO90=;
        b=nv/L8rRgOVKdO4da702QRfEu5kgfySGqMlYoIlyu+UCZsNHcYfOk25aMLGBEIyC6ot
         BQJijDzwgRg+Kr/cZ34D6dF0uNGb0kaJZLy8gqa7B+gXtvmeLA4/ALhp7Wlt2jt+7/4F
         eeJGpd6cCkdm4NgncUeDWW0ihZ7NGGQWj0UTHihL+LWFuiE9pczt9X43kF8hFoBU+nnY
         EJ5JXXAPkXlremQV29O9WG+EhGFn2bBvoU2hZMxl873Y/gUaoJ5VYmx9mYL7yoZW1gJC
         grOTmYFgYb3H8XWPgMuPL0UDzopcDX4j9e2wyitXHfHXZL6Nhc5v7Lh0K8JcUaEcHLQc
         aqMg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o35si616807qvf.8.2019.03.08.11.10.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Mar 2019 11:10:41 -0800 (PST)
Received-SPF: pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 9E056C04D29A;
	Fri,  8 Mar 2019 19:10:40 +0000 (UTC)
Received: from [10.40.205.251] (unknown [10.40.205.251])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 33CCE1001DD4;
	Fri,  8 Mar 2019 19:10:23 +0000 (UTC)
Subject: Re: [RFC][Patch v9 2/6] KVM: Enables the kernel to isolate guest free
 pages
To: Alexander Duyck <alexander.duyck@gmail.com>,
 "Michael S. Tsirkin" <mst@redhat.com>
Cc: David Hildenbrand <david@redhat.com>, kvm list <kvm@vger.kernel.org>,
 LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
 Paolo Bonzini <pbonzini@redhat.com>, lcapitulino@redhat.com,
 pagupta@redhat.com, wei.w.wang@intel.com,
 Yang Zhang <yang.zhang.wz@gmail.com>, Rik van Riel <riel@surriel.com>,
 dodgen@google.com, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
 dhildenb@redhat.com, Andrea Arcangeli <aarcange@redhat.com>
References: <20190306155048.12868-1-nitesh@redhat.com>
 <20190306155048.12868-3-nitesh@redhat.com>
 <CAKgT0UdDohCXZY3q9qhQsHw-2vKp_CAgvf2dd2e6U6KLsAkVng@mail.gmail.com>
 <2d9ae889-a9b9-7969-4455-ff36944f388b@redhat.com>
 <22e4b1cd-38a5-6642-8cbe-d68e4fcbb0b7@redhat.com>
 <CAKgT0UcAqGX26pcQLzFUevHsLu-CtiyOYe15uG3bkhGZ5BJKAg@mail.gmail.com>
 <78b604be-2129-a716-a7a6-f5b382c9fb9c@redhat.com>
 <CAKgT0Uc_z9Vi+JhQcJYX+J9c4J56RRSkzzegbb2=9xO-NY3dgw@mail.gmail.com>
 <20190307212845-mutt-send-email-mst@kernel.org>
 <CAKgT0Ucu3EMsYBfdKtEiprrn-VBZy3Y+0HdEp5b4PO2SQgGsRw@mail.gmail.com>
From: Nitesh Narayan Lal <nitesh@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=nitesh@redhat.com; prefer-encrypt=mutual; keydata=
 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
 VujM7c/b4pps
Organization: Red Hat Inc,
Message-ID: <17d2afa6-556e-ec73-40dc-beac536b3f20@redhat.com>
Date: Fri, 8 Mar 2019 14:10:20 -0500
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <CAKgT0Ucu3EMsYBfdKtEiprrn-VBZy3Y+0HdEp5b4PO2SQgGsRw@mail.gmail.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="xD6yFrm8IWkNhOHZM6MlHlwxr5wIiR1nl"
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.31]); Fri, 08 Mar 2019 19:10:40 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--xD6yFrm8IWkNhOHZM6MlHlwxr5wIiR1nl
Content-Type: multipart/mixed; boundary="dufyYFqOkdVSep0QbzK5h22WftvV2Qan2";
 protected-headers="v1"
From: Nitesh Narayan Lal <nitesh@redhat.com>
To: Alexander Duyck <alexander.duyck@gmail.com>,
 "Michael S. Tsirkin" <mst@redhat.com>
Cc: David Hildenbrand <david@redhat.com>, kvm list <kvm@vger.kernel.org>,
 LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
 Paolo Bonzini <pbonzini@redhat.com>, lcapitulino@redhat.com,
 pagupta@redhat.com, wei.w.wang@intel.com,
 Yang Zhang <yang.zhang.wz@gmail.com>, Rik van Riel <riel@surriel.com>,
 dodgen@google.com, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
 dhildenb@redhat.com, Andrea Arcangeli <aarcange@redhat.com>
Message-ID: <17d2afa6-556e-ec73-40dc-beac536b3f20@redhat.com>
Subject: Re: [RFC][Patch v9 2/6] KVM: Enables the kernel to isolate guest free
 pages
References: <20190306155048.12868-1-nitesh@redhat.com>
 <20190306155048.12868-3-nitesh@redhat.com>
 <CAKgT0UdDohCXZY3q9qhQsHw-2vKp_CAgvf2dd2e6U6KLsAkVng@mail.gmail.com>
 <2d9ae889-a9b9-7969-4455-ff36944f388b@redhat.com>
 <22e4b1cd-38a5-6642-8cbe-d68e4fcbb0b7@redhat.com>
 <CAKgT0UcAqGX26pcQLzFUevHsLu-CtiyOYe15uG3bkhGZ5BJKAg@mail.gmail.com>
 <78b604be-2129-a716-a7a6-f5b382c9fb9c@redhat.com>
 <CAKgT0Uc_z9Vi+JhQcJYX+J9c4J56RRSkzzegbb2=9xO-NY3dgw@mail.gmail.com>
 <20190307212845-mutt-send-email-mst@kernel.org>
 <CAKgT0Ucu3EMsYBfdKtEiprrn-VBZy3Y+0HdEp5b4PO2SQgGsRw@mail.gmail.com>
In-Reply-To: <CAKgT0Ucu3EMsYBfdKtEiprrn-VBZy3Y+0HdEp5b4PO2SQgGsRw@mail.gmail.com>

--dufyYFqOkdVSep0QbzK5h22WftvV2Qan2
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Content-Language: en-US


On 3/8/19 1:06 PM, Alexander Duyck wrote:
> On Thu, Mar 7, 2019 at 6:32 PM Michael S. Tsirkin <mst@redhat.com> wrot=
e:
>> On Thu, Mar 07, 2019 at 02:35:53PM -0800, Alexander Duyck wrote:
>>> The only other thing I still want to try and see if I can do is to ad=
d
>>> a jiffies value to the page private data in the case of the buddy
>>> pages.
>> Actually there's one extra thing I think we should do, and that is mak=
e
>> sure we do not leave less than X% off the free memory at a time.
>> This way chances of triggering an OOM are lower.
> If nothing else we could probably look at doing a watermark of some
> sort so we have to have X amount of memory free but not hinted before
> we will start providing the hints. It would just be a matter of
> tracking how much memory we have hinted on versus the amount of memory
> that has been pulled from that pool.
This is to avoid false OOM in the guest?
>  It is another reason why we
> probably want a bit in the buddy pages somewhere to indicate if a page
> has been hinted or not as we can then use that to determine if we have
> to account for it in the statistics.

The one benefit which I can see of having an explicit bit is that it
will help us to have a single hook away from the hot path within buddy
merging code (just like your arch_merge_page) and still avoid duplicate
hints while releasing pages.

I still have to check PG_idle and PG_young which you mentioned but I
don't think we can reuse any existing bits.

If we really want to have something like a watermark, then can't we use
zone->free_pages before isolating to see how many free pages are there
and put a threshold on it? (__isolate_free_page() does a similar thing
but it does that on per request basis).

>
>>> With that we could track the age of the page so it becomes
>>> easier to only target pages that are truly going cold rather than
>>> trying to grab pages that were added to the freelist recently.
>> I like that but I have a vague memory of discussing this with Rik van
>> Riel and him saying it's actually better to take away recently used
>> ones. Can't see why would that be but maybe I remember wrong. Rik - am=
 I
>> just confused?
> It is probably to cut down on the need for disk writes in the case of
> swap. If that is the case it ends up being a trade off.
>
> The sooner we hint the less likely it is that we will need to write a
> given page to disk. However the sooner we hint, the more likely it is
> we will need to trigger a page fault and pull back in a zero page to
> populate the last page we were working on. The sweet spot will be that
> period of time that is somewhere in between so we don't trigger
> unnecessary page faults and we don't need to perform additional swap
> reads/writes.
--=20
Regards
Nitesh


--dufyYFqOkdVSep0QbzK5h22WftvV2Qan2--

--xD6yFrm8IWkNhOHZM6MlHlwxr5wIiR1nl
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkXcoRVGaqvbHPuAGo4ZA3AYyozkFAlyCvhwACgkQo4ZA3AYy
ozklHg//U4m8Ze127fvPDuSxHHYFcioTxdYLp2hdRLjhbWE4Oe+dBBHYmh53nkzq
wWcMhfbDNBDBf1wYcPLEK+i1Hrf0GXyzAFd0XO0W8tOcv4AQi+q7KtZR9ieMaLyo
sqxAlflvm+Vn6o89L+6mLW/l/xh/83J6GJjwETBvogCX/z84wx+AaZ4Iq5aV561P
h7OpQJdyywMMRE8PRvh3kYGppGqLZ5kDtCbbC4QVOjXM8Hzu40MqJzrqU2rndPHo
qOv4cIIBLxmS4nX288aRKSBr9Y6HDs1KnUv8gjwSA6yW0wd5SnZE4CrR4ERNmXc0
KqNABQdpyZI1lEoao8Cf6yGnrPKUmV7Md7NwldWYOiE7/2Oy8AlDJG6xWywU+nHV
mgumckUeZiOd7gr8ZLX1W+GlVafa4Sxj8s87rLgaAeC5uyvAAIHA4XzNa3NkdJnW
J3bjvxr9DlWKVJoq4n6NUG918u8FH+kdBLmHChJwwB2SN5crCYuMxeEhESGY0jGi
7UzUgF8e3gEHWcnZ4MZ3xsUyxBcFAyhzh5jHmCYqINe10sdZN4ebRqdONFebRS5v
MXhRko7axTD7BW1goaaLEwEp7FY7xhNRg1JNeJUfsuWNCl2YnJiR7aobHF93jXjR
3fDCjQ5FQGdkQzkrLwIls+ycXbZ9kktcaOxEvPoU59l2XLbPSLY=
=Rc9w
-----END PGP SIGNATURE-----

--xD6yFrm8IWkNhOHZM6MlHlwxr5wIiR1nl--

