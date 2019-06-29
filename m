Return-Path: <SRS0=BwCX=U4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 30F63C46478
	for <linux-mm@archiver.kernel.org>; Sat, 29 Jun 2019 14:38:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D3C1321738
	for <linux-mm@archiver.kernel.org>; Sat, 29 Jun 2019 14:38:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="rAKEbOdk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D3C1321738
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=roeck-us.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5C7AC6B0003; Sat, 29 Jun 2019 10:38:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5028A8E0003; Sat, 29 Jun 2019 10:38:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 37D998E0002; Sat, 29 Jun 2019 10:38:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f207.google.com (mail-pg1-f207.google.com [209.85.215.207])
	by kanga.kvack.org (Postfix) with ESMTP id EFE526B0003
	for <linux-mm@kvack.org>; Sat, 29 Jun 2019 10:38:01 -0400 (EDT)
Received: by mail-pg1-f207.google.com with SMTP id k136so4731737pgc.10
        for <linux-mm@kvack.org>; Sat, 29 Jun 2019 07:38:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=q/WnLfKcw4bgj8PTvLZ5KR21ZjQSwCvusHGcEx5GQug=;
        b=e2oqHyInJUVferepHhCFOX5AzJ3oVP557psx/RLU24HtIArhVpF/Ebudi3zr07f2jq
         k7rwOR6rI2d36w308acR28lG4sRGJ2cl5vLtTo6q2U9gAuDo+SupKoqbgGKnkVX4wB8E
         1DL97tt2Pbiz00p0i142rRRrP9R1yjtXS7RChEUYePj5Nmgkc0CBkZG4qPa6hxx3Aj8f
         HvSP6er4LPIfeE0nb36mheqrMS+h8gAjmYpTgMWfHd4NPML4w+0oQKuZuUZsHkK0hWW3
         33JgsjQdPQRBOkNUNPUj3m/eJYXQOOQjxPXiiP9nsD3AosyCMKx6p9jhXRrTVD13BiFZ
         /coQ==
X-Gm-Message-State: APjAAAUorYl595XReDAxJ6j50nx+kbAXgKQ7iX1lH/jjDzqi4gXO493F
	wwLXjs1aPqhDKHoIc1kATqfpYZkjlSHdpneMCIdqE0B64izMzsz27FrhrVxMLlcfERrgvrPx/yI
	k4GOhnv+rVu0zMSoJAxWzWNEk3BXEJC0Uff9PrICvDQC37MWqIfx3AsvnMghs+pM=
X-Received: by 2002:a17:902:bb90:: with SMTP id m16mr17036664pls.54.1561819081465;
        Sat, 29 Jun 2019 07:38:01 -0700 (PDT)
X-Received: by 2002:a17:902:bb90:: with SMTP id m16mr17036591pls.54.1561819080354;
        Sat, 29 Jun 2019 07:38:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561819080; cv=none;
        d=google.com; s=arc-20160816;
        b=MrtMLbrcve9d2mODpwdZn3OUKom62D+VFP+TlM+cz4iQrz39+lGrTbH7GTVp9zST0P
         rxlhtWsmyqMn+WOp1PwDmwEPzbUSpa9DZlN1wnc5r5ch0ELkDIrMcyOjKWAaA7ynavJ2
         RYDguxCC2KBXizAV6pkuIxnNJu0JUSz3LldA5+P/xlX75ACxjb0NPZv0kcelY2ab1s6h
         IUwETOoNFYXdcsJ7DEu0B+KVvttaLswONHhgQsQq9/LNFzncoHdcQsSSMMcdO/aZQ2tz
         +jPe2tcn4NmuPqwkOR9O79W0F72MTmSDuheVkx6lN10J71d+aLDahjEeWWR6nkQITXqb
         pVmg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=q/WnLfKcw4bgj8PTvLZ5KR21ZjQSwCvusHGcEx5GQug=;
        b=r0dclztimDl7CbUqCwZ8TmIGGDftz6qqLQWhC6CxhfXyIKGfushv+bXSkCcWdWS6HD
         JuMmCSK+lcYgmOQ0qSzq4Tx5fE30Z4EmO59QPb5OIUoQj9ReXbuEiya4v4AVgXfx7sF/
         vj+0sgxMaEsUngOng+44GI+ls/VC5zc7iEO5BgoPOBBaNRGLw5DaiaPsn5mrBXjalIQY
         HQai1WAYp4Oa6jurmSYXecO8cioD6SLwyPukUzgZ3mA9CoQ8YwoO0IzBum82YYjZA2dl
         QDDy3ngmABaPwersV2q/zu6YQPZhCbxLmolMt4aWkh2r5+njfE/aVUDx6RwKQ5HRtKag
         x5cA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=rAKEbOdk;
       spf=pass (google.com: domain of groeck7@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=groeck7@gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w61sor6267689plb.47.2019.06.29.07.38.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 29 Jun 2019 07:38:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of groeck7@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=rAKEbOdk;
       spf=pass (google.com: domain of groeck7@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=groeck7@gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=q/WnLfKcw4bgj8PTvLZ5KR21ZjQSwCvusHGcEx5GQug=;
        b=rAKEbOdkIsG5iezdMxJDlnhHWZ6TX+1yWAY5gO2joFYEUztOpvLXUDj3XQpZlcSRoJ
         aaTgDmh+fov31z1ZlU18g1oHJurd3arNA+4lgs0uShQ5RQeyBmkx1f2QbqChgC4FLfyO
         Qk5UQI1ziu9TU+34OQD6H9gTf9WPxKLW13QHN0LpKFWtpMCyd3qzpJZvG0MsEzo35NDL
         DPgWADzayBLvfrpkhm6bKxuLIFRNdMAcB1TdJRevgvj9zL39U9Y+bW4EPa24IIb1EbsJ
         4gnmjPDAGmmRUnCy1ZW5yPoHxFS6XFK3RARTcFC74FrXdeYShwgWWJAqma7HKYx0Ea94
         v/FQ==
X-Google-Smtp-Source: APXvYqz+xA3xb6TeHYv3WmxTaYv+OEXq87pkZgrr1vlf7HTUT1v+Bfg3tjcjqZTIZK8pkcSgrOd/4Q==
X-Received: by 2002:a17:902:d717:: with SMTP id w23mr16712586ply.275.1561819079968;
        Sat, 29 Jun 2019 07:37:59 -0700 (PDT)
Received: from localhost ([2600:1700:e321:62f0:329c:23ff:fee3:9d7c])
        by smtp.gmail.com with ESMTPSA id v28sm4720256pga.65.2019.06.29.07.37.58
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 29 Jun 2019 07:37:59 -0700 (PDT)
Date: Sat, 29 Jun 2019 07:37:57 -0700
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
	linux-kernel@vger.kernel.org, Jason Gunthorpe <jgg@mellanox.com>
Subject: Re: [PATCH 04/16] MIPS: use the generic get_user_pages_fast code
Message-ID: <20190629143757.GA25077@roeck-us.net>
References: <20190625143715.1689-1-hch@lst.de>
 <20190625143715.1689-5-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190625143715.1689-5-hch@lst.de>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, Jun 25, 2019 at 04:37:03PM +0200, Christoph Hellwig wrote:
> The mips code is mostly equivalent to the generic one, minus various
> bugfixes and an arch override for gup_fast_permitted.
> 
> Note that this defines ARCH_HAS_PTE_SPECIAL for mips as mips has
> pte_special and pte_mkspecial implemented and used in the existing
> gup code.  They are no-op stubs, though which makes me a little unsure
> if this is really right thing to do.
> 
> Note that this also adds back a missing cpu_has_dc_aliases check for
> __get_user_pages_fast, which the old code was only doing for
> get_user_pages_fast.  This clearly looks like an oversight, as any
> condition that makes get_user_pages_fast unsafe also applies to
> __get_user_pages_fast.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> Reviewed-by: Jason Gunthorpe <jgg@mellanox.com>

This patch causes all mips images (mips, mips64, mipsel, mipsel64)
to crash when booting in qemu. Unfortunately the patch can not be
reverted easily since there are context changes, causing build failures
after the revert, so I can not verify if this is the only problem.

Crash log (same for all variants):

...
Run /sbin/init as init process
BUG: Bad page map in process mount  pte:00b70401 pmd:8e5dc000
page:80c24880 refcount:1 mapcount:-1 mapping:00000000 index:0x0
flags: 0x1000(reserved)
raw: 00001000 80c24884 80c24884 00000000 00000000 00000000 fffffffe 00000001
page dumped because: bad pte
addr:(ptrval) vm_flags:04044411 anon_vma:(ptrval) mapping:(ptrval) index:0
qemu-system-mips: terminating on signal 15 from pid 13034 (/bin/bash)

Guenter

---
bisect log:

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
# bad: [59f238b3353caf43b118e1bb44010aa1abd56d7f] sh: add the missing pud_page definition
git bisect bad 59f238b3353caf43b118e1bb44010aa1abd56d7f
# bad: [93a184240a74cb0242b9b970f0bc018c4fdf24fd] MIPS: use the generic get_user_pages_fast code
git bisect bad 93a184240a74cb0242b9b970f0bc018c4fdf24fd
# good: [7c6a77cff73127e9495e345a0903d55b1b0fb323] mm: lift the x86_32 PAE version of gup_get_pte to common code
git bisect good 7c6a77cff73127e9495e345a0903d55b1b0fb323
# first bad commit: [93a184240a74cb0242b9b970f0bc018c4fdf24fd] MIPS: use the generic get_user_pages_fast code

