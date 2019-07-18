Return-Path: <SRS0=TqY8=VP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 179C0C76196
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 09:17:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DC1D22173B
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 09:17:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DC1D22173B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 747FA6B0010; Thu, 18 Jul 2019 05:17:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6F9666B0266; Thu, 18 Jul 2019 05:17:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 60E2B8E0001; Thu, 18 Jul 2019 05:17:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 13FDD6B0010
	for <linux-mm@kvack.org>; Thu, 18 Jul 2019 05:17:49 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id n3so19582083edr.8
        for <linux-mm@kvack.org>; Thu, 18 Jul 2019 02:17:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=ma/PxcgtYZjPX40C5MK0DP9wyJE72ErwGTJH/OQlSaU=;
        b=kHr0lOqp2/b+eNnF9r6j3Cu5paaQm8LK/MbnzkL4ahba88Owh+I4OnfCO6MTnAH08l
         8C7DDvyy/IC5TvjPMdDDsv3jbKpi9jzPuGTkV9TmlONrsmbdVSLTjPfzjRha+v55y1s7
         iSrm6cyw8+x90HonlfhGKOjB1CwgWkLyZHa46FpVzEB2OTzQVxdAnBnq7pxHex8OXLCW
         0mFgqss307of188TfXFJc17D5yzNVqNs9DXjbah2mi4wNXdAq3R36ew80sctgzNIX/HR
         G1paX7BSqP8yMwdYfTweIxsltLBQHa32d1/j0RpGDxfXeH6QDdaprvlGeayqA43sB/Uu
         /unQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jroedel@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=jroedel@suse.de
X-Gm-Message-State: APjAAAU6JFoAqZvS0aww81umaTvGhd1I6b3Kh4uwCWBogj5e0wOiBP/7
	XEWwt/9U+mRtEX9Tgj8kt+JN5AefapT+O5cVszT9Zv5aRgoLJC8Zf2dEtjLsj1+neYghh+W54WH
	WTNnMj5nq6iwjnO/E7oOTNiQ8rjn7pKM/xTHuoCPNwy/1oaz0vsCWHoc0+myQZABEWA==
X-Received: by 2002:a50:b962:: with SMTP id m89mr39973998ede.104.1563441468668;
        Thu, 18 Jul 2019 02:17:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx0meK9C9sJxJy4hnKTYCGK2AKoywZXd1JXagz8tH0UF0a4o8j79nF10gSyyu7F3z8KEgvS
X-Received: by 2002:a50:b962:: with SMTP id m89mr39973946ede.104.1563441467937;
        Thu, 18 Jul 2019 02:17:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563441467; cv=none;
        d=google.com; s=arc-20160816;
        b=RpqMm7WsgiF+/J1ykPYX2kpTLByl5Qnd80pdSkDmkmUvOODmDC5NhrnMMBGwgyMWDT
         SUukwsE8YWwYOmoxGVzKtqUNI1h93cQAP6JndRW/Uiw1ocOy2aQN6tds59HmBP3eFNe5
         Kq59yZsUOz8UudVHBHstFThSzHkNFslFvE6s6Xo1znzRsIl+QSoD/LsPissXd4eZ+iLG
         CHw21pbqBxCbtk078gVeI+WJQpa2YgLAZmL4DbA398CMETjAYr2QrJ4DUK05sFleZ76Z
         VeDLqr+lm4/Yo5XpexT9e18QFXCV7UTkYJT6Ln92+ft09xc+FKs+lkVfr+ZPVD2K3pEM
         P/nw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=ma/PxcgtYZjPX40C5MK0DP9wyJE72ErwGTJH/OQlSaU=;
        b=vr2l1ahZcARYigPGxwUS/vlZQbsNKY6cn6AlcwBmvH0KRFhCoOmTsFRDc8P7XfE2aY
         phaHG7tRZX7qUmmFtMK8HejMYEhLIZ+llV3o42OSY6zJR+tSDvQckUZ9Ic+RI6b0DRD5
         UERuvNe6VMHI6YFW2wwDHncKVmLNOjEMaoEcIkD6i285QsDYMqSlN6BQDwuqSFPM5+GA
         Z6tLUbaLq72iDRosbGW+51VYzYnOPcPp6yTaoy//NzYzU47hEHw6J/85sb8HOI9gR8FZ
         BhcC0WiYnyb/p25U8lIASyTkhk5ZFzJn5Q/D8e5/dOxFOkw4qbugD+2cC2UtVGZF0Jw0
         3YAw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jroedel@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=jroedel@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t10si18445edb.216.2019.07.18.02.17.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jul 2019 02:17:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of jroedel@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jroedel@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=jroedel@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 055D1AF77;
	Thu, 18 Jul 2019 09:17:47 +0000 (UTC)
Date: Thu, 18 Jul 2019 11:17:45 +0200
From: Joerg Roedel <jroedel@suse.de>
To: Andy Lutomirski <luto@kernel.org>
Cc: Joerg Roedel <joro@8bytes.org>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>
Subject: Re: [PATCH 3/3] mm/vmalloc: Sync unmappings in vunmap_page_range()
Message-ID: <20190718091745.GG13091@suse.de>
References: <20190717071439.14261-1-joro@8bytes.org>
 <20190717071439.14261-4-joro@8bytes.org>
 <CALCETrXfCbajLhUixKNaMfFw91gzoQzt__faYLwyBqA3eAbQVA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrXfCbajLhUixKNaMfFw91gzoQzt__faYLwyBqA3eAbQVA@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Andy,

On Wed, Jul 17, 2019 at 02:24:09PM -0700, Andy Lutomirski wrote:
> On Wed, Jul 17, 2019 at 12:14 AM Joerg Roedel <joro@8bytes.org> wrote:
> > diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> > index 4fa8d84599b0..322b11a374fd 100644
> > --- a/mm/vmalloc.c
> > +++ b/mm/vmalloc.c
> > @@ -132,6 +132,8 @@ static void vunmap_page_range(unsigned long addr, unsigned long end)
> >                         continue;
> >                 vunmap_p4d_range(pgd, addr, next);
> >         } while (pgd++, addr = next, addr != end);
> > +
> > +       vmalloc_sync_all();
> >  }
> 
> I'm confused.  Shouldn't the code in _vm_unmap_aliases handle this?
> As it stands, won't your patch hurt performance on x86_64?  If x86_32
> is a special snowflake here, maybe flush_tlb_kernel_range() should
> handle this?

Imo this is the logical place to handle this. The code first unmaps the
area from the init_mm page-table and then syncs that page-table to all
other page-tables in the system, so one place to update the page-tables.

Performance-wise it makes no difference if we put that into
_vm_unmap_aliases(), as that is called in the vmunmap path too. But it
is right that vmunmap/iounmap performance on x86-64 will decrease to
some degree. If that is a problem for some workloads I can also
implement a complete separate code-path which just syncs unmappings and
is only implemented for x86-32 with !SHARED_KERNEL_PMD.

Regards,

	Joerg

