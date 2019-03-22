Return-Path: <SRS0=SIh7=RZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 863E5C10F03
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 22:14:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3720421900
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 22:14:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="gXnr/LKc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3720421900
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C9E886B0005; Fri, 22 Mar 2019 18:14:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C4C7A6B0006; Fri, 22 Mar 2019 18:14:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AEF726B0007; Fri, 22 Mar 2019 18:14:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8D0F66B0005
	for <linux-mm@kvack.org>; Fri, 22 Mar 2019 18:14:38 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id k5so2910329ioh.13
        for <linux-mm@kvack.org>; Fri, 22 Mar 2019 15:14:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=wm2+IDsr0NmRaIQ9GIimbnBiutoAYhXqklaChAdkC0E=;
        b=rGd+eLlmJ2Qn/JY5gZvuGgtQn6KGwrXJ3tVBTdKrz8GAvOfZUq713DqFmFVWPSgA0S
         Rnnr7f77lSvcIDW37p/QxDwRJ7NCRqlvO38EwiFpi6qSfmIGQkecdO1G+sRVpG3NOVA1
         R+Oq85HB2cYp4+E0Nmoeo2fywT2zVdumoSdjWk+PdCrKvgLQFs6IadU8d6BYdKYESpgu
         YT1lFoFPOtfOdvjlb6s7zeOKfNFG/YbDNwbuPcKYiZADryLscUiGwCedfIlTMa7IN/Kt
         Rrfzs2Ldl11L+z8/pebitgVjp4swaDy6VsazpTAmgzM7oUDpz5xcYWpNxgkqlQgaRZE/
         ICcA==
X-Gm-Message-State: APjAAAVL4hUsA0TENIrVStZCXvBSmX3QsOfzvBetQbu7qtVWUEy35lXr
	nCCeU4E9sLbKSWSgoVXjOtKK5MtAJVHbEwDWfQCVPv64FoxUVKBLCeW9ehByUYlZ3wD+b2ev0B/
	oIq7nZtxm/XbSmiFY5xQpvbcOa/JWhTlB1TFZUVeDfKS0YZLuV9hJrUip4SqpH+8=
X-Received: by 2002:a5d:855a:: with SMTP id b26mr9069565ios.151.1553292878391;
        Fri, 22 Mar 2019 15:14:38 -0700 (PDT)
X-Received: by 2002:a5d:855a:: with SMTP id b26mr9069534ios.151.1553292877788;
        Fri, 22 Mar 2019 15:14:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553292877; cv=none;
        d=google.com; s=arc-20160816;
        b=HYRtAl/kPvC4RfRh7+DxqPglVR1NbWZ8zX4Dpb6/b2DWlXnyTym76JMzF6kIWQLBY0
         n4VzfUwTev3ue7KZuHZki+mWWk82DTn+OfR+KfMIZChLLKh47dAtl6TK74n8//rWG4Tu
         lonJiPUn6hM59QrBHRjq+pB+jxaBfuSHH2NTsLelyMxPu4T9shh2fyYLGTxqzE7jLRkK
         9HTtOMAF4nlX0POwF+2hoCek6IAWdvmdIw4Ae3oNWtgwpuOJMPhqQx+oC4tkVKiMZLI1
         6w347uo9WBISeeT+ADu1s5C2WWEkfctVzTrmfFylTjx7S7eXUevOYwh6fy4MDTlOAQp0
         T9NQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=wm2+IDsr0NmRaIQ9GIimbnBiutoAYhXqklaChAdkC0E=;
        b=oos3t1QQVpjhuTunNzl7v2w8saXze5nhyq0sqWhS0SvSdhyyLyMPUUDXOnyt2FKl+j
         gohmqmB6XIg2SpmzBhgi3yaAR0+hYaC6h7EV5XZ97e1XKKINnp4d167AyUU2QYux2KEv
         QSntXt7CHWKpy4URvD2/93eqp/LzPHxLlczkuuad+RY3s3e4XLioiY2doBbOK/F7lfv+
         nvpRSV0QEOsuEoE6EtSDfD5ImXmxX9PGt9iNEkr9AmRrEac3VhTV4IGUUrhJwdHrWQEW
         L0BZ7vZ6ALi7rCaDCV2n9D2zt6IVkj6IoaLiFyphgM8gl09M27/lu6/YxJ4UZpU6gMJf
         cn1A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b="gXnr/LKc";
       spf=pass (google.com: domain of dan.j.williams@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w194sor17533373ita.22.2019.03.22.15.14.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 22 Mar 2019 15:14:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b="gXnr/LKc";
       spf=pass (google.com: domain of dan.j.williams@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=wm2+IDsr0NmRaIQ9GIimbnBiutoAYhXqklaChAdkC0E=;
        b=gXnr/LKcmO3n/AkDnk5tuJJz0sD52kdAC51zKOFpz9IFbfbYifTLF6ymlYbHKb1Fzf
         5IK9kzfgRjlOjG8rPf/pLCcCoxWGCDHkfS90S+LKj3jcXm5xQYa13eJcPAUZ+hXohZjm
         IBPo+8GJ+Rq8y+Q+kI7lVQj+zb+PR7I30rOlJksrdJy/Wp2dqUTjZA9F3vGG+ezwSQtN
         Rd0g5Hf0LyHnnPkTMRnIAwxLFm25gMxn56/wKPSlCPteP5nwXO0eAhs4klJ0MxT6YP2e
         dxwI2R6VEa8rmJFaL4xGk5paDuSdBggXv21lLkD4qtLHBeTsgNPI61yo109FsRi4r0QQ
         8DwA==
X-Google-Smtp-Source: APXvYqwIoaHTQX3ElVQKOchmDlJSSWqTKG84OsYpQvQY0PG83rmTkoixgVtLY+vkXQxXTMX8UIfgiVFJTO08ZCVWvdY=
X-Received: by 2002:a24:411f:: with SMTP id x31mr3120456ita.169.1553292877426;
 Fri, 22 Mar 2019 15:14:37 -0700 (PDT)
MIME-Version: 1.0
References: <20190317183438.2057-1-ira.weiny@intel.com> <20190317183438.2057-6-ira.weiny@intel.com>
In-Reply-To: <20190317183438.2057-6-ira.weiny@intel.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 22 Mar 2019 15:14:26 -0700
Message-ID: <CAA9_cmdQjMekSFU09gLc87-PVx2iHeeh2jC6KeFY1UeadpPh4A@mail.gmail.com>
Subject: Re: [RESEND 5/7] IB/hfi1: Use the new FOLL_LONGTERM flag to get_user_pages_fast()
To: ira.weiny@intel.com
Cc: Andrew Morton <akpm@linux-foundation.org>, John Hubbard <jhubbard@nvidia.com>, 
	Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, 
	Peter Zijlstra <peterz@infradead.org>, Jason Gunthorpe <jgg@ziepe.ca>, 
	Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, 
	"David S. Miller" <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, 
	Heiko Carstens <heiko.carstens@de.ibm.com>, Rich Felker <dalias@libc.org>, 
	Yoshinori Sato <ysato@users.sourceforge.jp>, Thomas Gleixner <tglx@linutronix.de>, 
	Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Ralf Baechle <ralf@linux-mips.org>, 
	James Hogan <jhogan@kernel.org>, linux-mm <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mips@vger.kernel.org, 
	linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, linux-s390 <linux-s390@vger.kernel.org>, 
	Linux-sh <linux-sh@vger.kernel.org>, sparclinux@vger.kernel.org, 
	linux-rdma@vger.kernel.org, "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Mar 17, 2019 at 7:36 PM <ira.weiny@intel.com> wrote:
>
> From: Ira Weiny <ira.weiny@intel.com>
>
> Use the new FOLL_LONGTERM to get_user_pages_fast() to protect against
> FS DAX pages being mapped.
>
> Signed-off-by: Ira Weiny <ira.weiny@intel.com>
> ---
>  drivers/infiniband/hw/hfi1/user_pages.c | 6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/infiniband/hw/hfi1/user_pages.c b/drivers/infiniband/hw/hfi1/user_pages.c
> index 78ccacaf97d0..6a7f9cd5a94e 100644
> --- a/drivers/infiniband/hw/hfi1/user_pages.c
> +++ b/drivers/infiniband/hw/hfi1/user_pages.c
> @@ -104,9 +104,11 @@ int hfi1_acquire_user_pages(struct mm_struct *mm, unsigned long vaddr, size_t np
>                             bool writable, struct page **pages)
>  {
>         int ret;
> +       unsigned int gup_flags = writable ? FOLL_WRITE : 0;

Maybe:

    unsigned int gup_flags = FOLL_LONGTERM | (writable ? FOLL_WRITE : 0);

?

>
> -       ret = get_user_pages_fast(vaddr, npages, writable ? FOLL_WRITE : 0,
> -                                 pages);
> +       gup_flags |= FOLL_LONGTERM;
> +
> +       ret = get_user_pages_fast(vaddr, npages, gup_flags, pages);
>         if (ret < 0)
>                 return ret;
>
> --
> 2.20.1
>

