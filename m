Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 11C07C7618B
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 16:12:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CBEEB2067D
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 16:12:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CBEEB2067D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=surriel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4D3F28E0005; Mon, 29 Jul 2019 12:12:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 484448E0002; Mon, 29 Jul 2019 12:12:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 373488E0005; Mon, 29 Jul 2019 12:12:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f71.google.com (mail-vs1-f71.google.com [209.85.217.71])
	by kanga.kvack.org (Postfix) with ESMTP id 116B08E0002
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 12:12:17 -0400 (EDT)
Received: by mail-vs1-f71.google.com with SMTP id w23so16038652vsj.22
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 09:12:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:user-agent
         :mime-version:sender;
        bh=ET062bAhzNWRI58qfHtA6mS2Udce+1GpDMIXdqEBJ0c=;
        b=ufCOSKufdU38xpx/HWQX7hc2WCwihueowPp9EEXPv3msX1yh+l6J673Z463yyPdiDc
         4UzABd86ZT3SuZmNYNM5oYjsqtemYKfNl7W5medAweZhLpVOaQmdWVy/LIMDvB6NK/XI
         ivy1o6VbRqQtiDkcOWtXPbUpnT89MuYb9j0dkadxE62ombUoWWUX502dmW4jR3SW+qpy
         kXKHza0M7cDReU8Is9vG/8b21nBNhn6lEL2kLIIuP7PiSaf3iVhJxQ9//SD9E2YMAeuR
         kOpy8dfyQip8kVTJTEWInp8eQv6plfGi+0+AIEAAXK8K2sB9wz5al8mWAn74FPTQTwv6
         ooEA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) smtp.mailfrom=riel@shelob.surriel.com
X-Gm-Message-State: APjAAAWEQZe8hiABADJyZyIk7BT8bLrD884MJ8+SS504CdBAq+eoba5c
	Ao0cOu/US2kHSA78dNeQnaSnEtQFMHzjSd6bpB8rWa8tVi8ZpG4IED6l/YY0hd516XGIFYgngjB
	/jwpXTSHoc7KZZrbJjFuDMdxl6LhrxscutTW2OOU8F+sDLBVwuOB87op1JCVLYG/lhg==
X-Received: by 2002:a1f:5285:: with SMTP id g127mr41822368vkb.83.1564416736732;
        Mon, 29 Jul 2019 09:12:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy8tXuiMJNDXYG73BWHXXb/cemyEngDWlibEP9C3t8HlQFeGcrhj+QxV5BQKIdOBv0n0x5f
X-Received: by 2002:a1f:5285:: with SMTP id g127mr41822313vkb.83.1564416736060;
        Mon, 29 Jul 2019 09:12:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564416736; cv=none;
        d=google.com; s=arc-20160816;
        b=rMQ5r7JaEbuo/1fqghMF0JizlbJE5l8nBbslzr2vM6yKnG+NavozVRSl5qka4zZlRZ
         Vg4sskf2E6c7VakohcWcaq4U0IMTcQ7vwMw7fITKI7hKKZK7iT3Opr/lo2jyPsxThQxy
         wo5F/Th7cEUlYaUgd8ykm+AwRxg5X2g+MRxsAX/Mzs4YjXXnwjX28hVm3Q3gOePKELit
         QtZxOggUIeCPPcx/O5PCAq5b2/cWY7jeM3D8FZgJ6Cttahgs5folmJZzhgUDGcyUupMj
         OtoWpszkjxzN2jDrqP4xHfbNiv9hsMs/v+7w1vT96hb7wlE/RqJ++TIEX7l0X2DuTBMm
         CQHQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=sender:mime-version:user-agent:references:in-reply-to:date:cc:to
         :from:subject:message-id;
        bh=ET062bAhzNWRI58qfHtA6mS2Udce+1GpDMIXdqEBJ0c=;
        b=nI1uOQo5ga6wgeVoAjz5ynxJkGzHj2brmTmp7sWgST1E2DThgobljKbS7awLcHaRRW
         LgIjbG1BlJNg7nAg+V2ORTlmRXbG238G4EKt2UK+wiZBlXuPa8wAyexYJFvON7ue5MKR
         aJA5VFBM3aruBKdti6gEC9YKl62mBYs4yh71U2fU4O3fKCahS3G//J2uNave5QrUiM8b
         OM9zV7ymLZtCyNtGEyhSP6x0aRGMEu0yrhsMXAOHJXmkJsTskiNMN3YOLdRDXkhFQrMt
         BF5+1Z670lhQl6kVtrd2TPmcKmoj1YD/oPF6zdtEKyls5g5kP2g931G9zqJCIZ2qvtrp
         V4QQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) smtp.mailfrom=riel@shelob.surriel.com
Received: from shelob.surriel.com (shelob.surriel.com. [96.67.55.147])
        by mx.google.com with ESMTPS id h2si11781341uah.151.2019.07.29.09.12.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Jul 2019 09:12:16 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) client-ip=96.67.55.147;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) smtp.mailfrom=riel@shelob.surriel.com
Received: from imladris.surriel.com ([96.67.55.152])
	by shelob.surriel.com with esmtpsa (TLSv1.2:ECDHE-RSA-AES256-GCM-SHA384:256)
	(Exim 4.92)
	(envelope-from <riel@shelob.surriel.com>)
	id 1hs8Fz-0006V1-0a; Mon, 29 Jul 2019 12:12:15 -0400
Message-ID: <89d6acc3cc5d72f750f1a77164043dbfd6e599e8.camel@surriel.com>
Subject: Re: [PATCH v2] sched/core: Don't use dying mm as active_mm of
 kthreads
From: Rik van Riel <riel@surriel.com>
To: Waiman Long <longman@redhat.com>, Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, 
	linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Phil Auld
	 <pauld@redhat.com>, Andy Lutomirski <luto@kernel.org>
Date: Mon, 29 Jul 2019 12:12:14 -0400
In-Reply-To: <c2dfc884-b3e1-6fb3-b05f-2b1f299853f4@redhat.com>
References: <20190727171047.31610-1-longman@redhat.com>
	 <20190729085235.GT31381@hirez.programming.kicks-ass.net>
	 <4cd17c3a-428c-37a0-b3a2-04e6195a61d5@redhat.com>
	 <20190729150338.GF31398@hirez.programming.kicks-ass.net>
	 <c2dfc884-b3e1-6fb3-b05f-2b1f299853f4@redhat.com>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-NYJpmwoU3yRhflJJvggv"
User-Agent: Evolution 3.30.5 (3.30.5-1.fc29) 
MIME-Version: 1.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--=-NYJpmwoU3yRhflJJvggv
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2019-07-29 at 11:37 -0400, Waiman Long wrote:
> On 7/29/19 11:03 AM, Peter Zijlstra wrote:
> > On Mon, Jul 29, 2019 at 10:51:51AM -0400, Waiman Long wrote:
> > > On 7/29/19 4:52 AM, Peter Zijlstra wrote:
> > > > On Sat, Jul 27, 2019 at 01:10:47PM -0400, Waiman Long wrote:
> > > > > It was found that a dying mm_struct where the owning task has
> > > > > exited
> > > > > can stay on as active_mm of kernel threads as long as no
> > > > > other user
> > > > > tasks run on those CPUs that use it as active_mm. This
> > > > > prolongs the
> > > > > life time of dying mm holding up memory and other resources
> > > > > like swap
> > > > > space that cannot be freed.
> > > > Sure, but this has been so 'forever', why is it a problem now?
> > > I ran into this probem when running a test program that keeps on
> > > allocating and touch memory and it eventually fails as the swap
> > > space is
> > > full. After the failure, I could not rerun the test program again
> > > because the swap space remained full. I finally track it down to
> > > the
> > > fact that the mm stayed on as active_mm of kernel threads. I have
> > > to
> > > make sure that all the idle cpus get a user task to run to bump
> > > the
> > > dying mm off the active_mm of those cpus, but this is just a
> > > workaround,
> > > not a solution to this problem.
> > The 'sad' part is that x86 already switches to init_mm on idle and
> > we
> > only keep the active_mm around for 'stupid'.
> >=20
> > Rik and Andy were working on getting that 'fixed' a while ago, not
> > sure
> > where that went.
>=20
> Good, perhaps the right thing to do is for the idle->kernel case to
> keep
> init_mm as the active_mm instead of reuse whatever left behind the
> last
> time around.

Absolutely not. That creates heavy cache line
contention on the mm_cpumask as we switch the
mm out and back in after an idle period.

The cache line contention on the mm_cpumask
alone can take up as much as a percent of
CPU time on a very busy system with a large
multi-threaded application, multiple sockets,
and lots of context switches.

--=20
All Rights Reversed.

--=-NYJpmwoU3yRhflJJvggv
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQEzBAABCAAdFiEEKR73pCCtJ5Xj3yADznnekoTE3oMFAl0/Gt4ACgkQznnekoTE
3oPxTwf6A73hLtRIBY6LdUGw0KUtoo25HQmixj3omA4ignFK7hQlCkOAyWbrXkTk
y10fXLM0Vhue5pUEQIlYtmp5wGUwlX6ixPkp7OK4uG5Bt4qWxo30zf6LgotkvJ/x
6AefBk+FZquAoe5P/8OjLcLJRlf/+9RuVJ/7KAYr1CBUh2g02lJIRs66BOWTzwzs
YmzXD6kN8SLnlI5rQJrYPKtcwS3I0PFW9GSU/wJe2jEq4vk/hVrHuLze1a20vEHg
RMBGsWVnAWlU6ZPXK23lUOVmtnIR4w2iNNBGMCOBnQTCFrUHij++rc6R9VfpLCgq
DfUJTi4ganXvQctAwKQ+LdLqX6+xPg==
=Zn9I
-----END PGP SIGNATURE-----

--=-NYJpmwoU3yRhflJJvggv--

