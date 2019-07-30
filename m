Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5C917C433FF
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 14:22:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 10C5C205C9
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 14:22:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="pm7OTx+n"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 10C5C205C9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=invisiblethingslab.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A16348E0007; Tue, 30 Jul 2019 10:22:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 979708E0001; Tue, 30 Jul 2019 10:22:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 83F2B8E0007; Tue, 30 Jul 2019 10:22:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5BCB28E0001
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 10:22:49 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id x1so55098294qkn.6
        for <linux-mm@kvack.org>; Tue, 30 Jul 2019 07:22:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=fHTTpR5eU19q6OgWJxRIcPsJ3iR77p64plMkqad3uH0=;
        b=RrTP3H1qeUeN/gEA+dyUkk092Pmdjjiwj01hLizQ/ltj2N2FD73aQmxgd3Qg1xOb9b
         NgwVdYqoHPI2WZ5BBu2R9FHpKyeAKpc5m4aNbgXd7x5iA2gBhhknIh8sKf/uTWNpSHN4
         wQZO7mLFneu0UosWL0fwG6lKr9LqomBo0a6J8/GrrMWVfWxPp5aCa6MwzNdN6HCmxrwF
         bXNuM1y2r/uz+9Qbuurq28Ro5aSnb1IEFvk09nmOksW4HAYJHoc32j9uifTUX1frc/3Y
         eNoACzaKfSLNMxn3tuNL1tczqTfsGbGIqTfO45JwKDES2LF9thRUt5Gsr3rwkzpT2hMX
         p3mw==
X-Gm-Message-State: APjAAAViXua/fnuLM+3gtDkAsPt8zTcWfWlOWmWvvK3/U+8s6/sI0qjL
	D5/95voTMLy6x1AQrtTyXUJoB1yu6+UzyJvLtbL72Igjo9Ngg41bRkBKwOKnvQU/9M7aymFPDaT
	NrjBi+dSE04GZq87vNWUbzIqaJq8e6jYhmOp0riYySQmnmC0fURUNV2yZLE5H/9A=
X-Received: by 2002:ac8:2d69:: with SMTP id o38mr80592095qta.169.1564496569065;
        Tue, 30 Jul 2019 07:22:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzdeJNgjz7CHJmBFIcCIzbS0uAp/gHwC5ecrRNCbb6ewA0bBJ8huzdKOk7E9vw61WLou3hR
X-Received: by 2002:ac8:2d69:: with SMTP id o38mr80592046qta.169.1564496568362;
        Tue, 30 Jul 2019 07:22:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564496568; cv=none;
        d=google.com; s=arc-20160816;
        b=xd/3qqKlEo56YI+/JWwbEXUIFPsNsZVRxSj5zOb0RKvUzzBRS90lhMgaePOM0vM+AC
         PpgALQ7KgOQFoDWawr043PqbcxH4fjcRuggjDWrfBv+s0kbJc3D/yZUX2Yi39MzlLExZ
         rRL4JoOi2Yy9BRB6B4cZOtBkwCYFkNfBOsi9uNFb62tHQgqLVcK8ANd55csSEYpY6Ilf
         3YBcTg80S0lH+njmY9AIc+Giexlt54xRbluKAOSs0SutWH56mcJ6Mi0V3GnVL51TdK2J
         bOuunX2nSMxnuXWWDUbj6d13TSM8jPhtvv4xOSCZWvj1kYgpdePmlVlBCI7fZ0JSNaWX
         6PBw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=fHTTpR5eU19q6OgWJxRIcPsJ3iR77p64plMkqad3uH0=;
        b=xfzJZbJVSMa0khoPaDfhcpQ9gZSlOuyK3Ttc4ZHXo4NYl4a+JDd7Z3SUfi808EBW/9
         COrQ8SQAipalEnxr9iJaRSebjP1NZyTVXfpPKc1L60PqVQ2PUrnDnavrr4Zo88dotVo8
         8r+WexLT4y9JH7Nnq4l22SNimRbcxLhjkmqHqkD+ZOxM9CG7eZNQj6pJglL0EZK2Ay96
         OTswQ2Bs6wO4hGUHuv5ekbnsS7ib2B8GQnym0aOUIJAL5pD0qftQNIzlbIs80V1S8XqX
         ajU4ONNlaLqmTThBpsoHD0VzvnJu5ybAgYia7RHtb+aZZFS6RhmMH3yc7/01MG3ZaUS3
         GROw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm3 header.b=pm7OTx+n;
       spf=neutral (google.com: 66.111.4.229 is neither permitted nor denied by best guess record for domain of marmarek@invisiblethingslab.com) smtp.mailfrom=marmarek@invisiblethingslab.com
Received: from new3-smtp.messagingengine.com (new3-smtp.messagingengine.com. [66.111.4.229])
        by mx.google.com with ESMTPS id q57si11429515qvh.52.2019.07.30.07.22.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jul 2019 07:22:48 -0700 (PDT)
Received-SPF: neutral (google.com: 66.111.4.229 is neither permitted nor denied by best guess record for domain of marmarek@invisiblethingslab.com) client-ip=66.111.4.229;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm3 header.b=pm7OTx+n;
       spf=neutral (google.com: 66.111.4.229 is neither permitted nor denied by best guess record for domain of marmarek@invisiblethingslab.com) smtp.mailfrom=marmarek@invisiblethingslab.com
Received: from compute7.internal (compute7.nyi.internal [10.202.2.47])
	by mailnew.nyi.internal (Postfix) with ESMTP id ED8CF19A2;
	Tue, 30 Jul 2019 10:22:47 -0400 (EDT)
Received: from mailfrontend2 ([10.202.2.163])
  by compute7.internal (MEProxy); Tue, 30 Jul 2019 10:22:47 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-type:date:from:in-reply-to
	:message-id:mime-version:references:subject:to:x-me-proxy
	:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=fm3; bh=fHTTpR
	5eU19q6OgWJxRIcPsJ3iR77p64plMkqad3uH0=; b=pm7OTx+n/GaE8dZOc5zi5a
	ad6rQFY+y8fPwZqi2QfKRceF0pKBLSzhvSdxAtbkmft7zYKlY74yHff+kigpI3HL
	ld3UX/PA3VB9lrmCXP/LGnNKJik8+95pwgxpHy6UdzIHjbH2ICz/4Tnw5YLJcw8S
	qM/XQdN5JFRb1d9DFd2dImO6svqYSDMbkJI2Zh7brPynrHVx4j0XH9sOhjsyVnZd
	mwuVkGEdyyvehJmunRGFj2OatWwg/aQLccMwinlwFTx8qjxJVMfbCE0eHHle/yog
	L32zh/ZhhgMuLOsXze0IEK6gcZm81sDRUm4XZZBtntyvs7h7NKNnwITRz+77bedw
	==
X-ME-Sender: <xms:t1JAXXwM3HS4PyKr0NRtCcZALD8EeD3zslS2JF1QxsBpPkOwcz8ieA>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduvddrleefgdejgecutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
    uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenuc
    fjughrpeffhffvuffkfhggtggujggfsehgtderredtreejnecuhfhrohhmpeforghrvghk
    ucforghrtgiihihkohifshhkihdqifpkrhgvtghkihcuoehmrghrmhgrrhgvkhesihhnvh
    hishhisghlvghthhhinhhgshhlrggsrdgtohhmqeenucfkphepledurdeihedrfeegrdef
    feenucfrrghrrghmpehmrghilhhfrhhomhepmhgrrhhmrghrvghksehinhhvihhsihgslh
    gvthhhihhnghhslhgrsgdrtghomhenucevlhhushhtvghrufhiiigvpedt
X-ME-Proxy: <xmx:t1JAXZUYhtF53dQFeMSl_-UM5eRPDp8_uoFvEoy4dTVFEmOOJd60yg>
    <xmx:t1JAXROxZANG-6bduAieIIUAVIguz5PjEN7URpx2J3w6EeAXbe3Lqg>
    <xmx:t1JAXTBy4y5dd1QQmh592u1hiUTpHXMO52fo35qpQzA8tyAbsTW_pg>
    <xmx:t1JAXVo6zco2qIgDDXNvgQ-O4Ixsl3bFZaWMDnWaOpHA6sNaYBD6rg>
Received: from mail-itl (ip5b412221.dynamic.kabel-deutschland.de [91.65.34.33])
	by mail.messagingengine.com (Postfix) with ESMTPA id BA32C380083;
	Tue, 30 Jul 2019 10:22:45 -0400 (EDT)
Date: Tue, 30 Jul 2019 16:22:33 +0200
From: Marek =?utf-8?Q?Marczykowski-G=C3=B3recki?= <marmarek@invisiblethingslab.com>
To: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Cc: Souptick Joarder <jrdr.linux@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Matthew Wilcox <willy@infradead.org>,
	Michal Hocko <mhocko@suse.com>, Juergen Gross <jgross@suse.com>,
	Russell King - ARM Linux <linux@armlinux.org.uk>,
	robin.murphy@arm.com, xen-devel@lists.xenproject.org,
	linux-kernel@vger.kernel.org, Linux-MM <linux-mm@kvack.org>
Subject: Re: [Xen-devel] [PATCH v4 8/9] xen/gntdev.c: Convert to use
 vm_map_pages()
Message-ID: <20190730142233.GR1250@mail-itl>
References: <20190215024830.GA26477@jordon-HP-15-Notebook-PC>
 <20190728180611.GA20589@mail-itl>
 <CAFqt6zaMDnpB-RuapQAyYAub1t7oSdHH_pTD=f5k-s327ZvqMA@mail.gmail.com>
 <CAFqt6zY+07JBxAVfMqb+X78mXwFOj2VBh0nbR2tGnQOP9RrNkQ@mail.gmail.com>
 <20190729133642.GQ1250@mail-itl>
 <CAFqt6zZN+6r6wYJY+f15JAjj8dY+o30w_+EWH9Vy2kUXCKSBog@mail.gmail.com>
 <bf02becc-9db0-bb78-8efc-9e25cc115237@oracle.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="6T5LqlUZTKFAO7Wr"
Content-Disposition: inline
In-Reply-To: <bf02becc-9db0-bb78-8efc-9e25cc115237@oracle.com>
User-Agent: Mutt/1.12+29 (a621eaed) (2019-06-14)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--6T5LqlUZTKFAO7Wr
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Jul 30, 2019 at 10:05:42AM -0400, Boris Ostrovsky wrote:
> On 7/30/19 2:03 AM, Souptick Joarder wrote:
> > On Mon, Jul 29, 2019 at 7:06 PM Marek Marczykowski-G=C3=B3recki
> > <marmarek@invisiblethingslab.com> wrote:
> >> On Mon, Jul 29, 2019 at 02:02:54PM +0530, Souptick Joarder wrote:
> >>> On Mon, Jul 29, 2019 at 1:35 PM Souptick Joarder <jrdr.linux@gmail.co=
m> wrote:
> >>>> On Sun, Jul 28, 2019 at 11:36 PM Marek Marczykowski-G=C3=B3recki
> >>>> <marmarek@invisiblethingslab.com> wrote:
> >>>>> On Fri, Feb 15, 2019 at 08:18:31AM +0530, Souptick Joarder wrote:
> >>>>>> Convert to use vm_map_pages() to map range of kernel
> >>>>>> memory to user vma.
> >>>>>>
> >>>>>> map->count is passed to vm_map_pages() and internal API
> >>>>>> verify map->count against count ( count =3D vma_pages(vma))
> >>>>>> for page array boundary overrun condition.
> >>>>> This commit breaks gntdev driver. If vma->vm_pgoff > 0, vm_map_pages
> >>>>> will:
> >>>>>  - use map->pages starting at vma->vm_pgoff instead of 0
> >>>> The actual code ignores vma->vm_pgoff > 0 scenario and mapped
> >>>> the entire map->pages[i]. Why the entire map->pages[i] needs to be m=
apped
> >>>> if vma->vm_pgoff > 0 (in original code) ?
> >> vma->vm_pgoff is used as index passed to gntdev_find_map_index. It's
> >> basically (ab)using this parameter for "which grant reference to map".
> >>
> >>>> are you referring to set vma->vm_pgoff =3D 0 irrespective of value p=
assed
> >>>> from user space ? If yes, using vm_map_pages_zero() is an alternate
> >>>> option.
> >> Yes, that should work.
> > I prefer to use vm_map_pages_zero() to resolve both the issues. Alterna=
tively
> > the patch can be reverted as you suggested. Let me know you opinion and=
 wait
> > for feedback from others.
> >
> > Boris, would you like to give any feedback ?
>=20
> vm_map_pages_zero() looks good to me. Marek, does it work for you?

Yes, replacing vm_map_pages() with vm_map_pages_zero() fixes the
problem for me.

--=20
Best Regards,
Marek Marczykowski-G=C3=B3recki
Invisible Things Lab
A: Because it messes up the order in which people normally read text.
Q: Why is top-posting such a bad thing?

--6T5LqlUZTKFAO7Wr
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCAAdFiEEhrpukzGPukRmQqkK24/THMrX1ywFAl1AUqoACgkQ24/THMrX
1yzE7wf+N9QQUHFQ1i6sZ/XXRhZyzc5rbN03s4QBCSZdeeSjZUJcvNMlunt0kdUG
2Ae1a5mlpnQerTvB3AhzRagzFp2H/mKQF76AconPqpvMiXJtvItwINuoP9TgLNtr
YSv4SDWGnsTVAQftHbzPUISP90Tm4W0mQWekUDQ8/o1/fufNSmU8dp0w4yYSYmJ7
jXDI/vFp323YqSGWsU/KlApuPzXoEEKfFR+7sghCCzZEWRe+LJgOgPQatokQXBBR
lhVCniRlUPeV64r9Ke0Ex0FgHJstrMn/3amyNhFeJKCZQ6d0TkFJdHsi+S6BYk6k
XxTdAiFe4G7DLklUiiiNMLS6tk++FA==
=OGWv
-----END PGP SIGNATURE-----

--6T5LqlUZTKFAO7Wr--

