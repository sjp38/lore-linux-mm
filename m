Return-Path: <SRS0=kLvD=R7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E9492C43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 09:02:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A1AC42082F
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 09:02:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A1AC42082F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5F4C86B0006; Thu, 28 Mar 2019 05:02:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5A5EE6B0007; Thu, 28 Mar 2019 05:02:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4954F6B0008; Thu, 28 Mar 2019 05:02:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id EEBE96B0006
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 05:02:54 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id c40so6517478eda.10
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 02:02:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=koNqQQCrs5fE+MWWeJdz7BK7cm1i2fn0ogeoDcWAm+w=;
        b=Wn+gIMmQuZRhqU6uyd0eIMuqdo69K84GAhyWyYZOuFAxOQ1PFcrw5zx4I0VsurP2xI
         7+WyHEcdSMEtN5bLRC58kXJzfg0KVjqVNR3pAFZa6tpNevZQ89T1qrkPulEWWsPfWE67
         QJO1xfGWJRwt+5pxwy1kI8jI1LE3kC9C2GtQU1nYapUVjL78U3pWd7HY2OklnLBq6J1s
         wvI3XJJidCewbcN7mLBQc+NsQbI3BodVXnGfV6jZ9elhk9D/rCMOmredIzznGyU0Mmw6
         egR3FIDSItA7CmixIks4pYm5rdPkm3WWSlmg3THhR82IJF6Z4CEMM0lIgwVLaVCwd1tK
         d6WQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Gm-Message-State: APjAAAU3pf+PSjnw7r4KoHpAipCpK9vIIBcBn3NVkdc7ptVRHBaEjnNo
	xVctmN7BvYbTcEdYSKMk237cKMD7uMW+gMjRUtHlYZEZOzyOhz8IhsR+gJKjSvxA/Raj4cDNTR5
	fE4AYi3jPdsyrqrbJgtotdknzZH0WkMtakRdiO/NbLR36cB3GlmRcOlY7IBKxuXHYYQ==
X-Received: by 2002:a50:ac44:: with SMTP id w4mr27277629edc.241.1553763774485;
        Thu, 28 Mar 2019 02:02:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzWGDWebhfr3iJMg04/RaQ2COMemKaAiuuVvjx35LvFnyAxb6TjdjVqia4SOM55dIuzw0JK
X-Received: by 2002:a50:ac44:: with SMTP id w4mr27277585edc.241.1553763773776;
        Thu, 28 Mar 2019 02:02:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553763773; cv=none;
        d=google.com; s=arc-20160816;
        b=vkZl3UVZ0Z6UHv8Qk+OHKUiYeQPqxWtkwx0N/9ySN8CIEelvAAUCPiy2wCY/nHdPB2
         GSNfAmjON0Zn+hkOi/yLyJc+d2VhK/alPG26lLBrBDFEh9oyacMJaFHuzyL5H8obZDSn
         IVD8uD4cB1F9BzH+9jlBZot8bt+FH6KfJhw9H3gyP6IYaugBuXEHBkEmb8AUbGjp0u7I
         sE3UBKzgMos2/rjz9+n2aWaROg9QImhqXisAxrpQ2ky8+WGTpJdTziqyKzjr6XNDxatb
         mXUkAf7kAdxsCaEgW1vN1DMQUsB4D6l8ONJaYQMbhVPJvkw5UdbvzDOCweb0DNryFqU9
         7y7g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=koNqQQCrs5fE+MWWeJdz7BK7cm1i2fn0ogeoDcWAm+w=;
        b=0wrMUEAWeDk7WtRdW+myNv80gCAr7pHiMumfBmXsHgSQ/ZEZ7I5YaMLQMm7u1yEYVg
         JBjxsxLG35VpxOhWQX+WWlwjjL5DGQdjegXwSfTDHARcXoEtY4+rya7m/f2mEJjqrzN0
         TkALjhvi7x32KG8f5duhguYyv7STRcqxgi4Lj9MHDyv21RZLu7vt+LQvntQ39PMwbKpB
         k2iZlKkfQqJZ4XOjSwtqdiQNzUAOJtWPG4pwQESKUbX07u2z9/YSVXD5VTAaPLD5F5kj
         mqgiHWTnbKa7WLp9sedUrDioKTIVgK3N21Myc6gN2Ef30zlDzFoRQRA6gZfxZWBIDoKx
         bkJQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d8si4293065ejk.103.2019.03.28.02.02.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Mar 2019 02:02:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 656F5ACE7;
	Thu, 28 Mar 2019 09:02:53 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id 31E691E424A; Thu, 28 Mar 2019 10:02:53 +0100 (CET)
Date: Thu, 28 Mar 2019 10:02:53 +0100
From: Jan Kara <jack@suse.cz>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>,
	Linux MM <linux-mm@kvack.org>,
	Chandan Rajendra <chandan@linux.ibm.com>,
	stable <stable@vger.kernel.org>,
	Dan Williams <dan.j.williams@intel.com>
Subject: Re: [PATCH] mm: Fix modifying of page protection by insert_pfn()
Message-ID: <20190328090253.GC22915@quack2.suse.cz>
References: <20190311084537.16029-1-jack@suse.cz>
 <CAPcyv4gBhTXs3Lf1ESgtaT4JUV8xiwNnM_OQU3-0ENB0hpAPng@mail.gmail.com>
 <20190327173332.GA15475@quack2.suse.cz>
 <20190327141414.ad663db479afa8694ed270c6@linux-foundation.org>
 <bd44db17-b28e-a0ce-03c6-14a90f3a8850@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <bd44db17-b28e-a0ce-03c6-14a90f3a8850@linux.ibm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 28-03-19 08:48:19, Aneesh Kumar K.V wrote:
> On 3/28/19 2:44 AM, Andrew Morton wrote:
> > On Wed, 27 Mar 2019 18:33:32 +0100 Jan Kara <jack@suse.cz> wrote:
> > 
> > > On Mon 11-03-19 10:22:44, Dan Williams wrote:
> > > > On Mon, Mar 11, 2019 at 1:45 AM Jan Kara <jack@suse.cz> wrote:
> > > > > 
> > > > > Aneesh has reported that PPC triggers the following warning when
> > > > > excercising DAX code:
> > > > > 
> > > > > [c00000000007610c] set_pte_at+0x3c/0x190
> > > > > LR [c000000000378628] insert_pfn+0x208/0x280
> > > > > Call Trace:
> > > > > [c0000002125df980] [8000000000000104] 0x8000000000000104 (unreliable)
> > > > > [c0000002125df9c0] [c000000000378488] insert_pfn+0x68/0x280
> > > > > [c0000002125dfa30] [c0000000004a5494] dax_iomap_pte_fault.isra.7+0x734/0xa40
> > > > > [c0000002125dfb50] [c000000000627250] __xfs_filemap_fault+0x280/0x2d0
> > > > > [c0000002125dfbb0] [c000000000373abc] do_wp_page+0x48c/0xa40
> > > > > [c0000002125dfc00] [c000000000379170] __handle_mm_fault+0x8d0/0x1fd0
> > > > > [c0000002125dfd00] [c00000000037a9b0] handle_mm_fault+0x140/0x250
> > > > > [c0000002125dfd40] [c000000000074bb0] __do_page_fault+0x300/0xd60
> > > > > [c0000002125dfe20] [c00000000000acf4] handle_page_fault+0x18
> > > > > 
> > > > > Now that is WARN_ON in set_pte_at which is
> > > > > 
> > > > >          VM_WARN_ON(pte_hw_valid(*ptep) && !pte_protnone(*ptep));
> > > > > 
> > > > > The problem is that on some architectures set_pte_at() cannot cope with
> > > > > a situation where there is already some (different) valid entry present.
> > > > > 
> > > > > Use ptep_set_access_flags() instead to modify the pfn which is built to
> > > > > deal with modifying existing PTE.
> > > > > 
> > > > > CC: stable@vger.kernel.org
> > > > > Fixes: b2770da64254 "mm: add vm_insert_mixed_mkwrite()"
> > > > > Reported-by: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
> > > > > Signed-off-by: Jan Kara <jack@suse.cz>
> > > > 
> > > > Acked-by: Dan Williams <dan.j.williams@intel.com>
> > > > 
> > > > Andrew, can you pick this up?
> > > 
> > > Andrew, ping?
> > 
> > I merged this a couple of weeks ago and it's in the queue for 5.1.
> > 
> 
> I noticed that we need similar change for pmd and pud updates. I will send a
> patch for that.

Yes, it is needed there as well. Thanks for fixing this.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

