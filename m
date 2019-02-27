Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,FROM_LOCAL_NOVOWEL,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 26908C4360F
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 17:29:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D5208218B0
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 17:29:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ph1yj7zW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D5208218B0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6FEFD8E0009; Wed, 27 Feb 2019 12:29:58 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 688018E0001; Wed, 27 Feb 2019 12:29:58 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 529108E0009; Wed, 27 Feb 2019 12:29:58 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1D51C8E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 12:29:58 -0500 (EST)
Received: by mail-yw1-f70.google.com with SMTP id c74so13697647ywc.9
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 09:29:58 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=dSSmuG4mKdZqfAxPKCJsdtWMhnsZAqHY97PjvphoIqI=;
        b=sLy3Yj0x9FkBKMNiR1GKla12T0az0vd913Owuiip4UmS2NruKSucLyqqQ75LhjZvJr
         +AxFAfalsiv8APTuUlOKOXf7E7DpFA7OGCdTBi6PmQputCVZj0l2pXgBNLUj0aZVWzDw
         LYywacXR0jnuUlOWOVfpiBWZ4dKqmzHFqtxN833d6cQZ6E/rVQRmJIzEwBA66Z34ZgSA
         PNVDIZLrkynqst6/aOcAxwKbbAC+pDBad9OdTlcEmKWOLcHr7Kb/RQ//sjFQc5SgNRXr
         fi5TzHYb/ocUbWzQ5H0VwC7kZxEy2ZDt4Y1Xi4CGfJjhLCAuyi5tD1cVDeZbtw0hm3C9
         1rcA==
X-Gm-Message-State: AHQUAuboJd7xqz3LQYI2N0NCWXqvqTLFGw+3c089+R4J9FvyCpiKBOiO
	DGK41pKQVDh+Gl4dOmPB10w1kTKgERwF9//VUV/eo/GYd5h2jT47n4HrnXJhOdXXkvcznJGpe07
	3Av1BzRYI/vJvHfKG15LjUtJEoIP8zi/fCXS7EXzxx38WbU/2o8Vf8qksaU6HoUdXPSpJAcDSZt
	s9NQpA40Ois6YS6oPp1qMtnjORUYSQCMYoKY6MrPYa1EiLDg/aOeUd5jUy85EkvZfH/pN2BIaH+
	W/I+y62pHCHWcjQE88mjtt3hvWifIDrLJS4dXFWLerwOqi9fjnJtIxlbFv46DnZ7/wwvA4sFNk2
	wxhSa9Zndec9CC6FEO2ruu+Vp4oq0i1Umfe69TBE8o4sFW9Qxoy2j1Oh2uk91hhYlGXOJRYVjCr
	d
X-Received: by 2002:a25:d746:: with SMTP id o67mr3054535ybg.421.1551288597821;
        Wed, 27 Feb 2019 09:29:57 -0800 (PST)
X-Received: by 2002:a25:d746:: with SMTP id o67mr3054491ybg.421.1551288597159;
        Wed, 27 Feb 2019 09:29:57 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551288597; cv=none;
        d=google.com; s=arc-20160816;
        b=Cru3Te9RhHSbn7qg2b9htWxo17BuPDbJubUAbLjc97qzQYa79HifrO+O0+E0kZV8Ie
         P/A1uVdIMae9l3wzdTq3zvkFVCH6GiUFSHxZqMMx/oA+JTLP2gnYnqcBFXgBbbIU9OwV
         Aa4HvNNI87vzqWyTYQ+QM3I2SvqY9AIWgYHfVVEdFTZmL/FjlDqQ8DXy/dRPyV/ryZrb
         ovoRTr0lORv0MDdeIlX2ss9+53szk9ckrksMnSo6rgfx3R8k7hf/h8BtnhVRXJibsPLj
         1pllI1TWd+/bOKmk5aA/FL7m1JLpa45UKAf2ETyx5AenOetJbychBr1O/o/EpjD+eOTa
         UwCw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=dSSmuG4mKdZqfAxPKCJsdtWMhnsZAqHY97PjvphoIqI=;
        b=WP33YW80xlqofnHDga9NCKyRlRRL/NJqRreyD4Tp38yj4mysr9wCXBWN8EiGpT85zF
         GfdZ6a7821uMgtZ3TzBhEUPs53p3Pv3muOjFu5Poii7hn9S5IFSByZFo7UKz78vpJlC9
         r1BI4uSozPxH0r2uuHibqQiNqx7DWOisL38B5NMNM7HBvvPjyeev7GstGqcxy8m06wQe
         /7rIDb9uEz4+Kfc+hP8Gz/AnXJET7WFpalxKFO+D+rvQJshpDaRYG08UOL+eHMX182Wb
         SxXHSw+KF9lAdsVcjQqPejh243rqOSOLjEhqWpoiopJmmB543PBKJnxsojQ9L4Jj/LUk
         kaIA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ph1yj7zW;
       spf=pass (google.com: domain of jcmvbkbc@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jcmvbkbc@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a129sor7488320ybb.21.2019.02.27.09.29.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 27 Feb 2019 09:29:57 -0800 (PST)
Received-SPF: pass (google.com: domain of jcmvbkbc@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ph1yj7zW;
       spf=pass (google.com: domain of jcmvbkbc@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jcmvbkbc@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=dSSmuG4mKdZqfAxPKCJsdtWMhnsZAqHY97PjvphoIqI=;
        b=ph1yj7zWvRmQCYCm4VsH/94vAD9eny0ts8vH/3dkLnUO2LcPhYR3R9a1mDOEu5MlH7
         6GCEDYQDvs9N4oaU49m5RXkJksem6SdA6MZA9zRr1YyYs5wgnW2bS9TCoqpVjQ9CanbJ
         c/ns0vyML3r89aD+pRHb5rFY4DSU/ZIr6TiZ5N2nEyC5hg1A0Y3hW5+G2PxlHM/hh5yp
         mEze0/MOPGnG8xjfyZW73ZWDN3WTwb3HmpfRg5jE8G75K5GhvH9IfQ6OCu+WsuaKInP3
         V2Rdbs0NpfPrkiTZ22zln0qu+dPzqNo2P2qZRLw6Y12uiYgcEBZ6RXokCqHjgmL6aQKM
         B+mg==
X-Google-Smtp-Source: AHgI3IajeGjzc7JjBBbd/HnJnbRx3bFug1NbTzdtCFYI5K+mLSoTjKT583kzUbbV0c0iVxLFQ5xbozrcXnPTOGQt+cU=
X-Received: by 2002:a25:8703:: with SMTP id a3mr3045476ybl.445.1551288596863;
 Wed, 27 Feb 2019 09:29:56 -0800 (PST)
MIME-Version: 1.0
References: <20190227170608.27963-1-steven.price@arm.com> <20190227170608.27963-24-steven.price@arm.com>
In-Reply-To: <20190227170608.27963-24-steven.price@arm.com>
From: Max Filippov <jcmvbkbc@gmail.com>
Date: Wed, 27 Feb 2019 09:29:45 -0800
Message-ID: <CAMo8Bf+W3o+ZfTztNyCJVs1CDshB_=3hhCne6MY6v=PD=GqLUg@mail.gmail.com>
Subject: Re: [PATCH v3 23/34] xtensa: mm: Add p?d_large() definitions
To: Steven Price <steven.price@arm.com>
Cc: linux-mm@kvack.org, Andy Lutomirski <luto@kernel.org>, 
	Ard Biesheuvel <ard.biesheuvel@linaro.org>, Arnd Bergmann <arnd@arndb.de>, 
	Borislav Petkov <bp@alien8.de>, Catalin Marinas <catalin.marinas@arm.com>, 
	Dave Hansen <dave.hansen@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, 
	James Morse <james.morse@arm.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, 
	Will Deacon <will.deacon@arm.com>, "maintainer:X86 ARCHITECTURE..." <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, 
	linux-arm-kernel@lists.infradead.org, LKML <linux-kernel@vger.kernel.org>, 
	Mark Rutland <Mark.Rutland@arm.com>, "Liang, Kan" <kan.liang@linux.intel.com>, 
	Chris Zankel <chris@zankel.net>, linux-xtensa@linux-xtensa.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 27, 2019 at 9:07 AM Steven Price <steven.price@arm.com> wrote:
>
> walk_page_range() is going to be allowed to walk page tables other than
> those of user space. For this it needs to know when it has reached a
> 'leaf' entry in the page tables. This information is provided by the
> p?d_large() functions/macros.
>
> For xtensa, we don't support large pages, so add a stub returning 0.
>
> CC: Chris Zankel <chris@zankel.net>
> CC: Max Filippov <jcmvbkbc@gmail.com>
> CC: linux-xtensa@linux-xtensa.org
> Signed-off-by: Steven Price <steven.price@arm.com>
> ---
>  arch/xtensa/include/asm/pgtable.h | 1 +
>  1 file changed, 1 insertion(+)

Acked-by: Max Filippov <jcmvbkbc@gmail.com>

-- 
Thanks.
-- Max

