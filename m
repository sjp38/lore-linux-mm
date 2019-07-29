Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 50A4EC7618B
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 15:28:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 21DAC206E0
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 15:28:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 21DAC206E0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=surriel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BD2AB8E0007; Mon, 29 Jul 2019 11:28:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B83548E0002; Mon, 29 Jul 2019 11:28:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A72108E0007; Mon, 29 Jul 2019 11:28:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 857178E0002
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 11:28:11 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id m25so55240507qtn.18
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 08:28:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:user-agent
         :mime-version:sender;
        bh=vT1cQ+Hl3NYLrgTUPQFc5EZDaiEwePxgzVn3tKv4DH4=;
        b=qC5yry6nWysOg+LCiRHb3xTQzJf2sD/vD9iq7AnTqdY9xU94Ujgcv9dKdW+cmZ2rQ3
         jM7keZzV2EuEAJQxje7q5Iwu0/XcJceo8i3a1Xpu8LuELBoGaBbmX7ZDHMVML0Ntnl+5
         YyhR/CXBbDYw+wjn/OulV6UVwPoTaCEpKPq4BrrKqO01Tllxq49H2jFwcpsgQ2WAXc5a
         1mn5WXnNXNIGGxu65Fuestv3VcdR8mELfSHYsWAhie2pdEZkyp4lLUQJhO5VNBZbbhpB
         ojtg9l2RAb8cUFp30M7TzsHfaaFp4yNvGixfVeVRkNXJ4wA/iXzqct4/u072hTBu6aSX
         EqLA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) smtp.mailfrom=riel@shelob.surriel.com
X-Gm-Message-State: APjAAAXCbMDP3GWowJzhr26RcmTg5abZZNtidpAKS6Bmy2kj3DsPXjd4
	w83QPDCXYR90bqwlnBGw5rxihYiB0027cYkTwDLChMYWl3pjIVhK3yQ377CGfGFYyI3F4bt2wpi
	87Y9QuJj20eqVR+qnDvTuFfV1Ed07WrWrkG/Hu88mCdYmi8SL3Fw+ulkoeGLXIIMqRA==
X-Received: by 2002:ac8:32e8:: with SMTP id a37mr79088863qtb.231.1564414091329;
        Mon, 29 Jul 2019 08:28:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxsPncsTrqMouFXBkNBqXkxf2bWka+5+vmiQnqfq4LU7IQcuptd1+cMu+jcg0qhyQW9jIyb
X-Received: by 2002:ac8:32e8:: with SMTP id a37mr79088835qtb.231.1564414090798;
        Mon, 29 Jul 2019 08:28:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564414090; cv=none;
        d=google.com; s=arc-20160816;
        b=Fw+f++c++D+oigr8zkOXcPA3JDoYyeV81i/lDM/mQdBPeL0rbh0b75eZZCf+sk6jB8
         atHjmCBpg9/+/88vqapu8sH/hjy505Wk8J+rTJzZboUEmktd2UYBb87y/W3SZQpj6YKt
         Z+x2Iw5PXOSjfbo4OB35nIFVYXBG+HCRh6RnYW70vY9yeW9AsRHtPvfrOFJsMqFnC2ag
         VGrjQk8QzuIUSTm5M2//HIzT+FcFAhWesfswAQG370T7ytE4vY8QR8tA9zx8wSZtMpxM
         LnzYyFpns8VlKOnGlIooyH9TVdZOD+NpZUZTJ6aEXXgNyQbizQ7xXBqqFHn20osH44UA
         11bA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=sender:mime-version:user-agent:references:in-reply-to:date:cc:to
         :from:subject:message-id;
        bh=vT1cQ+Hl3NYLrgTUPQFc5EZDaiEwePxgzVn3tKv4DH4=;
        b=c+OopXUC3HmWQBkvB1cu/7egWTQiTDQsjUAqTaZt/Zk7KObKbWf6zCVakaefcHqQgD
         dh/yKAsSp38FgtZbFwaXiBUSv54bH7PhzWiDnVV5z+x4w1bnPCxuOpeyGpdFzZoinGPp
         b5C+ma1BWErBiiRfJ945PFAjQpvL98lQS4GLXy6kqVIgayqb3wpEd1ERLIPG7m6Jl+kZ
         n+hLQRhgQZBhzL+4S1j9oUGvr87N0tsu0MGrQMDzKYFzHkamct6wGF+BYwIwydSP7xNx
         r7bCyDKjnRdDM4lxONgnXqCj0EWD/OOv1bLlZ1Q8NRqMk+c7Z2LaPMqxCHhbcwIvQwod
         DnFA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) smtp.mailfrom=riel@shelob.surriel.com
Received: from shelob.surriel.com (shelob.surriel.com. [96.67.55.147])
        by mx.google.com with ESMTPS id n19si12688531vsm.403.2019.07.29.08.28.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Jul 2019 08:28:09 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) client-ip=96.67.55.147;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) smtp.mailfrom=riel@shelob.surriel.com
Received: from imladris.surriel.com ([96.67.55.152])
	by shelob.surriel.com with esmtpsa (TLSv1.2:ECDHE-RSA-AES256-GCM-SHA384:256)
	(Exim 4.92)
	(envelope-from <riel@shelob.surriel.com>)
	id 1hs7ZE-0005xz-Kd; Mon, 29 Jul 2019 11:28:04 -0400
Message-ID: <25cd74fcee33dfd0b9604a8d1612187734037394.camel@surriel.com>
Subject: Re: [PATCH v2] sched/core: Don't use dying mm as active_mm of
 kthreads
From: Rik van Riel <riel@surriel.com>
To: Peter Zijlstra <peterz@infradead.org>, Waiman Long <longman@redhat.com>
Cc: Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, 
	linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Phil Auld
	 <pauld@redhat.com>, Andy Lutomirski <luto@kernel.org>
Date: Mon, 29 Jul 2019 11:28:04 -0400
In-Reply-To: <20190729150338.GF31398@hirez.programming.kicks-ass.net>
References: <20190727171047.31610-1-longman@redhat.com>
	 <20190729085235.GT31381@hirez.programming.kicks-ass.net>
	 <4cd17c3a-428c-37a0-b3a2-04e6195a61d5@redhat.com>
	 <20190729150338.GF31398@hirez.programming.kicks-ass.net>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-jTygDaFHWv+tndg9/HZy"
User-Agent: Evolution 3.30.5 (3.30.5-1.fc29) 
MIME-Version: 1.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--=-jTygDaFHWv+tndg9/HZy
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2019-07-29 at 17:03 +0200, Peter Zijlstra wrote:

> The 'sad' part is that x86 already switches to init_mm on idle and we
> only keep the active_mm around for 'stupid'.

Wait, where do we do that?

> Rik and Andy were working on getting that 'fixed' a while ago, not
> sure
> where that went.

My lazy TLB stuff got merged last year.=20

Did we miss a spot somewhere, where the code still
quietly switches to init_mm for no good reason?

--=20
All Rights Reversed.

--=-jTygDaFHWv+tndg9/HZy
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQEzBAABCAAdFiEEKR73pCCtJ5Xj3yADznnekoTE3oMFAl0/EIQACgkQznnekoTE
3oNL6QgAgxNj1HjPixQ3mbrfqWGtqw7ZBZ2IXL0ePQFLsl1DEQ/YB4zOW+SCHO8a
Wc0T5JdqAvzr7GJQ/BXcAp2hXHFZcW9ATbjDGF6tEDO5+vCU304aE3Xe8eIL+7ZW
nqM8VXsC5djsV+72u9jDTdBwbNtuYcpKC025j6PBs/nhyPj+JJb2SGNPZRhQCvQI
em+AvZZVNVSRl9sJHCgaVWXQTHf0oNj3eMMO7jI0dbBTaoWbfNLX3Gasi/heGsq6
Z7vb5GY+Gu5x5AFZCr7P/NBYGmUwXPt7qMP6kaOkH0BiAAJzzCPrLgf7E896J7W0
PdEk6eriZBRp1EcBaBN7UMt6zqcsUw==
=tfva
-----END PGP SIGNATURE-----

--=-jTygDaFHWv+tndg9/HZy--

