Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f172.google.com (mail-we0-f172.google.com [74.125.82.172])
	by kanga.kvack.org (Postfix) with ESMTP id D2AC16B0031
	for <linux-mm@kvack.org>; Sat, 14 Jun 2014 08:05:25 -0400 (EDT)
Received: by mail-we0-f172.google.com with SMTP id u57so3887215wes.31
        for <linux-mm@kvack.org>; Sat, 14 Jun 2014 05:05:25 -0700 (PDT)
Received: from mail-we0-x22b.google.com (mail-we0-x22b.google.com [2a00:1450:400c:c03::22b])
        by mx.google.com with ESMTPS id j15si10748253wjn.21.2014.06.14.05.05.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 14 Jun 2014 05:05:24 -0700 (PDT)
Received: by mail-we0-f171.google.com with SMTP id q58so3879188wes.16
        for <linux-mm@kvack.org>; Sat, 14 Jun 2014 05:05:23 -0700 (PDT)
Subject: Re: kmemleak: Unable to handle kernel paging request
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.2\))
Content-Type: text/plain; charset=windows-1252
From: Catalin Marinas <catalin.marinas@arm.com>
In-Reply-To: <1402695853.20360.17.camel@pasglop>
Date: Sat, 14 Jun 2014 13:05:18 +0100
Content-Transfer-Encoding: quoted-printable
Message-Id: <D9560F26-D206-4423-ACA4-31342A73B5F9@arm.com>
References: <CAOJe8K3fy3XFxDdVc3y1hiMAqUCPmkUhECU7j5TT=E=gxwBqHg@mail.gmail.com> <20140611173851.GA5556@MacBook-Pro.local> <CAOJe8K1TgTDX5=LdE9r6c0ami7TRa7zr0hL_uu6YpiWrsePAgQ@mail.gmail.com> <B01EB0A1-992B-49F4-93AE-71E4BA707795@arm.com> <CAOJe8K3LDhhPWbtdaWt23mY+2vnw5p05+eyk2D8fovOxC10cgA@mail.gmail.com> <CAOJe8K2WaJUP9_buwgKw89fxGe56mGP1Mn8rDUO9W48KZzmybA@mail.gmail.com> <20140612143916.GB8970@arm.com> <CAOJe8K3zN+fFWumKaGx3Tmv5JRZu10_FZ6R3Tjjc+nc-KVB0hg@mail.gmail.com> <20140613085640.GA21018@arm.com> <1402695853.20360.17.camel@pasglop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Denis Kirjanov <kda@linux-powerpc.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, Paul Mackerras <paulus@samba.org>

On 13 Jun 2014, at 22:44, Benjamin Herrenschmidt =
<benh@kernel.crashing.org> wrote:
> On Fri, 2014-06-13 at 09:56 +0100, Catalin Marinas wrote:
>=20
>> OK, so that's the DART table allocated via alloc_dart_table(). Is
>> dart_tablebase removed from the kernel linear mapping after =
allocation?
>=20
> Yes.
>=20
>> If that's the case, we need to tell kmemleak to ignore this block =
(see
>> patch below, untested). But I still can't explain how commit
>> d4c54919ed863020 causes this issue.
>>=20
>> (also cc'ing the powerpc list and maintainers)
>=20
> We remove the DART from the linear mapping because it has to be mapped
> non-cachable and having it in the linear mapping would cause cache
> paradoxes. We also can't just change the caching attributes in the
> linear mapping because we use 16M pages for it and 970 CPUs don't
> support cache-inhibited 16M pages :-( And due to the MMU segmentation
> model, we also can't mix & match page sizes in that area.
>=20
> So we just unmap it, and ioremap it elsewhere.

OK, thanks for the explanation. So the kmemleak annotation makes sense.

Would you please take the I patch earlier (I guess with Denis=92 tested-
by). I can send it separately if more convenient.

Thanks,

Catalin=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
