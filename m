Return-Path: <SRS0=BwCX=U4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7FB10C5B57A
	for <linux-mm@archiver.kernel.org>; Sat, 29 Jun 2019 15:15:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3AA67216FD
	for <linux-mm@archiver.kernel.org>; Sat, 29 Jun 2019 15:15:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="NroLZ76O"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3AA67216FD
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=roeck-us.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C3B6E6B0003; Sat, 29 Jun 2019 11:15:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BEA318E0003; Sat, 29 Jun 2019 11:15:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ADA0C8E0002; Sat, 29 Jun 2019 11:15:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f206.google.com (mail-pf1-f206.google.com [209.85.210.206])
	by kanga.kvack.org (Postfix) with ESMTP id 768836B0003
	for <linux-mm@kvack.org>; Sat, 29 Jun 2019 11:15:39 -0400 (EDT)
Received: by mail-pf1-f206.google.com with SMTP id g21so5708692pfb.13
        for <linux-mm@kvack.org>; Sat, 29 Jun 2019 08:15:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=GttoCpwXZ0YnEgD480v+8xB8TagEdr3d83SlTOyEyRY=;
        b=d63SVOKePVzLMETQ0vIjahLXIRuCr8DqD8A0to98RXvJXhm2XKVrDUEZZSnBycKODC
         2cO9C2Uyq02B7sugTEaneZ/d0BZfDm2X0WEsvIQsacjeNhJtPIWsCYl2/Zx6tJC3fKMt
         Xmwk14MHBpukLnF6j2DfnbkgX1FFW96S0lps8twfdcWakDNdCwlcpSOywEYng0tmWSUp
         8ipeSEmV2hVC4aHUTyOf8o+uakYFDZPUx89p6zmHSaG8GsIvC4IqZbuCd3Xq6PRYVCzW
         1izX4hH+p0wYWcnvXorwawfBmcvgX++gkbEMKS2ZLmqLVpAGhewcvKgC5j+ZVPVrivEC
         OqeA==
X-Gm-Message-State: APjAAAWRg/QdncZ5uuM57i4GE65cN7QQX82AnzH8TTufM+wB3iCmyndh
	dKPht7LAy4o4s29TJ3Nr9JivtcVBv40prX6OAiN1BeXFTcpdRyOnemwGfAhck8oQNJh703pex2W
	W0xG7PJXQ0pps2+iut/fT5BikKeX7ucHcCpIHVspnXgUboE7wacxUglmAnMMeMN4=
X-Received: by 2002:a63:d53:: with SMTP id 19mr15414169pgn.453.1561821338969;
        Sat, 29 Jun 2019 08:15:38 -0700 (PDT)
X-Received: by 2002:a63:d53:: with SMTP id 19mr15414075pgn.453.1561821337716;
        Sat, 29 Jun 2019 08:15:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561821337; cv=none;
        d=google.com; s=arc-20160816;
        b=b+zEpLJWhH06pla1tNWo+MgPPtcUNgMe3xM3N7fwwCBlWJTYJB6WolUje2bU++j+KX
         oKzeaAZrml/B52IESHgHqaof5r7HaiODTBjfcY6QpXsfBN93YRVeuYYW5H36iMPprOtO
         bEwdAV2DxOiVAA8dQv00L+FdW/QDRn9SREBTv7TOYxAGKjZ53IB0RgwWd19BcnB48TTI
         M5t8SM/BZd56LTkXeuudSX90CQEPKxUEXc4Gb3Fn1knr0iB1on0V3ryxs01MJovgIp1I
         qPhAAjo8sObSWoLgOPEIdI+Jz6j6EDEKAGLBaNTcBwL3Ajt+FQfsgF+eHOo6a0Wdsgx6
         FIng==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=GttoCpwXZ0YnEgD480v+8xB8TagEdr3d83SlTOyEyRY=;
        b=B7Edcw7OAi+IY2INOTNwPeONUtyc59DbjyGX2fa5Kd5KJs8r4wzdmT5Pr5YQArvukb
         KDbag/9rvXO9034XF19jQyHNIiCHtvzn1/gj9vIuTrIaY6OGrUMH5za/cTsWvdvShHcf
         8R3OsY8N9MXXOx/caplGGSJePfrocCmXs0WLRMiJ6mh/yMM33r5ij2zS9jn7RTjwiWHU
         DQyjSQlqRnsQBb1DZxYcp1HwR4ZazgIv6S03sAUJQnknz5tNcsMgSTaQq/WsQXUY/k0V
         2JL5DW+Uvl3o5CL9ltncN6HeJJqAmFLA1qRJJpvKx8iK6//zf/qDt9+BPOUGfml90ZQJ
         Z0bg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=NroLZ76O;
       spf=pass (google.com: domain of groeck7@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=groeck7@gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a21sor2436364pgh.0.2019.06.29.08.15.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 29 Jun 2019 08:15:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of groeck7@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=NroLZ76O;
       spf=pass (google.com: domain of groeck7@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=groeck7@gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=GttoCpwXZ0YnEgD480v+8xB8TagEdr3d83SlTOyEyRY=;
        b=NroLZ76Oo2crKQBJo8fp4wAzbrnPDUyi6puDLTX4qr11cTGH0bOeLepMhvdQwo020B
         6pSoWWR3kH9ARotFu1VoLKq6TSkJTxnPuTI+vnkbouCiYTmlB0siA0LLLwkSWELVY4CK
         B+AHB27xD0ZZtvlZYod6I2Kb2OBLCXiVyLpVClEMHQnK9lP8gLwCCqFYFsjv0bK9djvg
         Ip/SsNDsbNHaOhOd02uWeVmcEQMegCbYeZeUFqCm22rmEQRnUUfF69IsdbjxePKKKYqS
         xiuv7ChyahFmSIJuO7fdh+Iu669GD3DcuLWeVzI495UDhi+Douu8YoWlFVimf0oV7mWe
         xUDw==
X-Google-Smtp-Source: APXvYqyVpBWX0MYstsM24PSiU2G6Tv937ge94evRwlPCysvJPgEe57082Y4skMOs3eYeU4vWifx+4w==
X-Received: by 2002:a63:4e58:: with SMTP id o24mr14663917pgl.366.1561821337246;
        Sat, 29 Jun 2019 08:15:37 -0700 (PDT)
Received: from localhost ([2600:1700:e321:62f0:329c:23ff:fee3:9d7c])
        by smtp.gmail.com with ESMTPSA id 85sm8120381pfv.130.2019.06.29.08.15.36
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 29 Jun 2019 08:15:36 -0700 (PDT)
Date: Sat, 29 Jun 2019 08:15:35 -0700
From: Guenter Roeck <linux@roeck-us.net>
To: Christoph Hellwig <hch@lst.de>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Paul Burton <paul.burton@mips.com>, James Hogan <jhogan@kernel.org>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	Rich Felker <dalias@libc.org>,
	"David S. Miller" <davem@davemloft.net>,
	Nicholas Piggin <npiggin@gmail.com>,
	Khalid Aziz <khalid.aziz@oracle.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	Michael Ellerman <mpe@ellerman.id.au>, linux-mips@vger.kernel.org,
	linux-sh@vger.kernel.org, sparclinux@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH 06/16] sh: use the generic get_user_pages_fast code
Message-ID: <20190629151535.GA18067@roeck-us.net>
References: <20190625143715.1689-1-hch@lst.de>
 <20190625143715.1689-7-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190625143715.1689-7-hch@lst.de>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 25, 2019 at 04:37:05PM +0200, Christoph Hellwig wrote:
> The sh code is mostly equivalent to the generic one, minus various
> bugfixes and two arch overrides that this patch adds to pgtable.h.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>

sh:defconfig no longer builds with this patch applied.

mm/gup.c: In function 'gup_huge_pud':
arch/sh/include/asm/pgtable-3level.h:40:36: error:
	implicit declaration of function 'pud_pfn'; did you mean 'pte_pfn'? 

Bisect log attached.

Guenter

---
# bad: [48568d8c7f479ec45b9c3d02b4b1895f3ef61a03] Add linux-next specific files for 20190628
# good: [4b972a01a7da614b4796475f933094751a295a2f] Linux 5.2-rc6
git bisect start 'HEAD' 'v5.2-rc6'
# good: [89a77c9176fe88f68c3bf7bd255cfea6797258d4] Merge remote-tracking branch 'crypto/master'
git bisect good 89a77c9176fe88f68c3bf7bd255cfea6797258d4
# good: [2cedca636ad73ed838bd636685b245404e490c73] Merge remote-tracking branch 'security/next-testing'
git bisect good 2cedca636ad73ed838bd636685b245404e490c73
# good: [ea260819fdc2f8a64e6c87f3ad80ecc5e4015921] Merge remote-tracking branch 'char-misc/char-misc-next'
git bisect good ea260819fdc2f8a64e6c87f3ad80ecc5e4015921
# good: [aca42ca2a32eacf804ac56a33526f049debc8ec0] Merge remote-tracking branch 'rpmsg/for-next'
git bisect good aca42ca2a32eacf804ac56a33526f049debc8ec0
# good: [f4cd0c7f3c07876f7173b5306e974644c6eec141] Merge remote-tracking branch 'pidfd/for-next'
git bisect good f4cd0c7f3c07876f7173b5306e974644c6eec141
# bad: [09c57a8ab1fc3474b4a620247a0f9e3ac61c4cfe] mm/sparsemem: support sub-section hotplug
git bisect bad 09c57a8ab1fc3474b4a620247a0f9e3ac61c4cfe
# good: [aaffcf10880c363870413c5cdee5dfb6a923e9ae] mm: memcontrol: dump memory.stat during cgroup OOM
git bisect good aaffcf10880c363870413c5cdee5dfb6a923e9ae
# bad: [81d90bb2d2784258ed7c0762ecf34d4665198bad] um: switch to generic version of pte allocation
git bisect bad 81d90bb2d2784258ed7c0762ecf34d4665198bad
# bad: [dadae650472841f004882a2409aa844e37809c60] sparc64-add-the-missing-pgd_page-definition-fix
git bisect bad dadae650472841f004882a2409aa844e37809c60
# good: [d1edd06c6ac8c8c49345ff34de1c72ee571f3f7b] mm: memcg/slab: stop setting page->mem_cgroup pointer for slab pages
git bisect good d1edd06c6ac8c8c49345ff34de1c72ee571f3f7b
# good: [b1ceaacca9e63794bd3f574c928e7e6aca01bce7] mm: simplify gup_fast_permitted
git bisect good b1ceaacca9e63794bd3f574c928e7e6aca01bce7
# good: [59f238b3353caf43b118e1bb44010aa1abd56d7f] sh: add the missing pud_page definition
git bisect good 59f238b3353caf43b118e1bb44010aa1abd56d7f
# bad: [51bbf54b3f26a85217db720f4e5b01a6c4d3f010] sparc64: add the missing pgd_page definition
git bisect bad 51bbf54b3f26a85217db720f4e5b01a6c4d3f010
# bad: [be748d6e72113580af7e37ad68a0047659e60189] sh: use the generic get_user_pages_fast code
git bisect bad be748d6e72113580af7e37ad68a0047659e60189
# first bad commit: [be748d6e72113580af7e37ad68a0047659e60189] sh: use the generic get_user_pages_fast code

