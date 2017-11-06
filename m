Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id 48E826B0069
	for <linux-mm@kvack.org>; Mon,  6 Nov 2017 13:15:26 -0500 (EST)
Received: by mail-vk0-f72.google.com with SMTP id q80so5030853vkf.1
        for <linux-mm@kvack.org>; Mon, 06 Nov 2017 10:15:26 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id p24si4565274uah.369.2017.11.06.10.15.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Nov 2017 10:15:25 -0800 (PST)
Message-ID: <1509992067.4140.1.camel@oracle.com>
Subject: Re: [PATCH] mm, sparse: do not swamp log with huge vmemmap
 allocation failures
From: Khalid Aziz <khalid.aziz@oracle.com>
Date: Mon, 06 Nov 2017 11:14:27 -0700
In-Reply-To: <20171106092228.31098-1-mhocko@kernel.org>
References: <20171106092228.31098-1-mhocko@kernel.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Mon, 2017-11-06 at 10:22 +0100, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
>=20
> While doing a memory hotplug tests under a heavy memory pressure we
> have
> noticed too many page allocation failures when allocating vmemmap
> memmap
> backed by huge page
> ......... deleted .........
> +
> +		if (!warned) {
> +			warn_alloc(gfp_mask, NULL, "vmemmap alloc
> failure: order:%u", order);
> +			warned =3D true;
> +		}
> =C2=A0		return NULL;
> =C2=A0	} else
> =C2=A0		return __earlyonly_bootmem_alloc(node, size, size,

This will warn once and only once after a kernel is booted. This
condition may happen repeatedly over a long period of time with
significant time span between two such events and it can be useful to
know if this is happening repeatedly. There might be better ways to
throttle the rate of warnings, something like warn once and then
suppress warnings for the next 15 minutes (or pick any other time
frame). If this condition happens again later, there will be another
warning.

--
Khalid

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
