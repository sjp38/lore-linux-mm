Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f182.google.com (mail-yk0-f182.google.com [209.85.160.182])
	by kanga.kvack.org (Postfix) with ESMTP id 829A86B0044
	for <linux-mm@kvack.org>; Tue, 29 Apr 2014 15:44:28 -0400 (EDT)
Received: by mail-yk0-f182.google.com with SMTP id 142so619876ykq.41
        for <linux-mm@kvack.org>; Tue, 29 Apr 2014 12:44:28 -0700 (PDT)
Received: from fujitsu24.fnanic.fujitsu.com (fujitsu24.fnanic.fujitsu.com. [192.240.6.14])
        by mx.google.com with ESMTPS id w44si3464980yhn.201.2014.04.29.12.44.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 29 Apr 2014 12:44:27 -0700 (PDT)
From: Motohiro Kosaki <Motohiro.Kosaki@us.fujitsu.com>
Date: Tue, 29 Apr 2014 12:43:54 -0700
Subject: RE: [PATCH] mm,writeback: fix divide by zero in pos_ratio_polynom
Message-ID: <6B2BA408B38BA1478B473C31C3D2074E31D4C5C3BB@SV-EXCHANGE1.Corp.FC.LOCAL>
References: <20140429151910.53f740ef@annuminas.surriel.com>
In-Reply-To: <20140429151910.53f740ef@annuminas.surriel.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "sandeen@redhat.com" <sandeen@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "jweiner@redhat.com" <jweiner@redhat.com>, Motohiro Kosaki JP <kosaki.motohiro@jp.fujitsu.com>, "mhocko@suse.cz" <mhocko@suse.cz>, "fengguang.wu@intel.com" <fengguang.wu@intel.com>, "mpatlasov@parallels.com" <mpatlasov@parallels.com>



> -----Original Message-----
> From: Rik van Riel [mailto:riel@redhat.com]
> Sent: Tuesday, April 29, 2014 3:19 PM
> To: linux-kernel@vger.kernel.org
> Cc: linux-mm@kvack.org; sandeen@redhat.com; akpm@linux-foundation.org; jw=
einer@redhat.com; Motohiro Kosaki JP;
> mhocko@suse.cz; fengguang.wu@intel.com; mpatlasov@parallels.com
> Subject: [PATCH] mm,writeback: fix divide by zero in pos_ratio_polynom
>=20
> It is possible for "limit - setpoint + 1" to equal zero, leading to a div=
ide by zero error. Blindly adding 1 to "limit - setpoint" is not working,
> so we need to actually test the divisor before calling div64.
>=20
> Signed-off-by: Rik van Riel <riel@redhat.com>
> Cc: stable@vger.kernel.org

Fairly obvious fix.

Acked-by: KOSAKI Motohiro <Kosaki.motohiro@jp.fujitsu.com>


> ---
>  mm/page-writeback.c | 7 ++++++-
>  1 file changed, 6 insertions(+), 1 deletion(-)
>=20
> diff --git a/mm/page-writeback.c b/mm/page-writeback.c index ef41349..268=
2516 100644
> --- a/mm/page-writeback.c
> +++ b/mm/page-writeback.c
> @@ -597,11 +597,16 @@ static inline long long pos_ratio_polynom(unsigned =
long setpoint,
>  					  unsigned long dirty,
>  					  unsigned long limit)
>  {
> +	unsigned int divisor;
>  	long long pos_ratio;
>  	long x;
>=20
> +	divisor =3D limit - setpoint;
> +	if (!divisor)
> +		divisor =3D 1;
> +
>  	x =3D div_s64(((s64)setpoint - (s64)dirty) << RATELIMIT_CALC_SHIFT,
> -		    limit - setpoint + 1);
> +		    divisor);
>  	pos_ratio =3D x;
>  	pos_ratio =3D pos_ratio * x >> RATELIMIT_CALC_SHIFT;
>  	pos_ratio =3D pos_ratio * x >> RATELIMIT_CALC_SHIFT;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
