From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: PROBLEM-PERSISTS: dmesg spam: alloc_contig_range: [XX, YY) PFNs busy
Date: Thu, 01 Dec 2016 02:39:35 +0100
Message-ID: <xa1td1hcwhpk.fsf@mina86.com>
References: <robbat2-20161129T223723-754929513Z@orbis-terrarum.net> <20161130092239.GD18437@dhcp22.suse.cz> <xa1ty4012k0f.fsf@mina86.com> <20161130132848.GG18432@dhcp22.suse.cz> <robbat2-20161130T195244-998539995Z@orbis-terrarum.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <robbat2-20161130T195244-998539995Z@orbis-terrarum.net>
Sender: linux-kernel-owner@vger.kernel.org
To: Michal Hocko <mhocko@kernel.org>
Cc: "Robin H. Johnson" <robbat2@orbis-terrarum.net>, linux-kernel@vger.kernel.org, robbat2@gentoo.org, linux-mm@kvack.org
List-Id: linux-mm.kvack.org

On Wed, Nov 30 2016, Robin H. Johnson wrote:
> (I'm going to respond directly to this email with the stack trace.)
>
> On Wed, Nov 30, 2016 at 02:28:49PM +0100, Michal Hocko wrote:
>> > On the other hand, if this didn=E2=80=99t happen and now happens all t=
he time,
>> > this indicates a regression in CMA=E2=80=99s capability to allocate pa=
ges so
>> > just rate limiting the output would hide the potential actual issue.
>>=20
>> Or there might be just a much larger demand on those large blocks, no?
>> But seriously, dumping those message again and again into the low (see
>> the 2.5_GB_/h to the log is just insane. So there really should be some
>> throttling.
>>=20
>> Does the following help you Robin. At least to not get swamped by those
>> message.
> Here's what I whipped up based on that, to ensure that dump_stack got
> rate-limited at the same pass as PFNs-busy. It dropped the dmesg spew to
> ~25MB/hour (and is suppressing ~43 entries/second right now).
>
> commit 6ad4037e18ec2199f8755274d8a745a9904241a1
> Author: Robin H. Johnson <robbat2@gentoo.org>
> Date:   Wed Nov 30 10:32:57 2016 -0800
>
>     mm: ratelimit & trace PFNs busy.
>=20=20=20=20=20
>     Signed-off-by: Robin H. Johnson <robbat2@gentoo.org>

Acked-by: Michal Nazarewicz <mina86@mina86.com>

> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 6de9440e3ae2..3c28ec3d18f8 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -7289,8 +7289,15 @@ int alloc_contig_range(unsigned long start, unsign=
ed long end,
>=20=20
>  	/* Make sure the range is really isolated. */
>  	if (test_pages_isolated(outer_start, end, false)) {
> -		pr_info("%s: [%lx, %lx) PFNs busy\n",
> -			__func__, outer_start, end);
> +		static DEFINE_RATELIMIT_STATE(ratelimit_pfn_busy,
> +					DEFAULT_RATELIMIT_INTERVAL,
> +					DEFAULT_RATELIMIT_BURST);
> +		if (__ratelimit(&ratelimit_pfn_busy)) {
> +			pr_info("%s: [%lx, %lx) PFNs busy\n",
> +				__func__, outer_start, end);

I=E2=80=99m thinking out loud here, but maybe it would be useful to include
a count of how many times this message has been suppressed?

> +			dump_stack();

Perhaps do it only if CMA_DEBUG?

+			if (IS_ENABLED(CONFIG_CMA_DEBUG))
+				dump_stack();

> +		}
> +
>  		ret =3D -EBUSY;
>  		goto done;
>  	}
>
> --=20
> Robin Hugh Johnson
> Gentoo Linux: Dev, Infra Lead, Foundation Trustee & Treasurer
> E-Mail   : robbat2@gentoo.org
> GnuPG FP : 11ACBA4F 4778E3F6 E4EDF38E B27B944E 34884E85
> GnuPG FP : 7D0B3CEB E9B85B1F 825BCECF EE05E6F6 A48F6136

--=20
Best regards
=E3=83=9F=E3=83=8F=E3=82=A6 =E2=80=9C=F0=9D=93=B6=F0=9D=93=B2=F0=9D=93=B7=
=F0=9D=93=AA86=E2=80=9D =E3=83=8A=E3=82=B6=E3=83=AC=E3=83=B4=E3=82=A4=E3=83=
=84
=C2=ABIf at first you don=E2=80=99t succeed, give up skydiving=C2=BB
