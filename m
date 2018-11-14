Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id A8DE86B000D
	for <linux-mm@kvack.org>; Wed, 14 Nov 2018 05:35:32 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id l131so10325101pga.2
        for <linux-mm@kvack.org>; Wed, 14 Nov 2018 02:35:32 -0800 (PST)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id c19-v6si23032547pfb.81.2018.11.14.02.35.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Nov 2018 02:35:31 -0800 (PST)
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.2 \(3445.102.3\))
Subject: Re: [PATCH] mm/usercopy: Use memory range to be accessed for
 wraparound check
From: William Kucharski <william.kucharski@oracle.com>
In-Reply-To: <1542156686-12253-1-git-send-email-isaacm@codeaurora.org>
Date: Wed, 14 Nov 2018 03:35:25 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <FFE931C2-DE41-4AD8-866B-FD37C1493590@oracle.com>
References: <1542156686-12253-1-git-send-email-isaacm@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Isaac J. Manjarres" <isaacm@codeaurora.org>
Cc: Kees Cook <keescook@chromium.org>, crecklin@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, psodagud@codeaurora.org, tsoni@codeaurora.org, stable@vger.kernel.org



> On Nov 13, 2018, at 5:51 PM, Isaac J. Manjarres =
<isaacm@codeaurora.org> wrote:
>=20
> diff --git a/mm/usercopy.c b/mm/usercopy.c
> index 852eb4e..0293645 100644
> --- a/mm/usercopy.c
> +++ b/mm/usercopy.c
> @@ -151,7 +151,7 @@ static inline void check_bogus_address(const =
unsigned long ptr, unsigned long n,
> 				       bool to_user)
> {
> 	/* Reject if object wraps past end of memory. */
> -	if (ptr + n < ptr)
> +	if (ptr + (n - 1) < ptr)
> 		usercopy_abort("wrapped address", NULL, to_user, 0, ptr =
+ n);

I'm being paranoid, but is it possible this routine could ever be passed =
"n" set to zero?

If so, it will erroneously abort indicating a wrapped address as (n - 1) =
wraps to ULONG_MAX.

Easily fixed via:

	if ((n !=3D 0) && (ptr + (n - 1) < ptr))

William Kucharski=
