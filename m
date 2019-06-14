Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D31A3C31E4B
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 20:43:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5CDBD2084D
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 20:43:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="SWqmPKao"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5CDBD2084D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A29EF6B0006; Fri, 14 Jun 2019 16:43:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9D9C86B0007; Fri, 14 Jun 2019 16:43:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8C97B6B0008; Fri, 14 Jun 2019 16:43:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6D43D6B0006
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 16:43:06 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id g30so3167557qtm.17
        for <linux-mm@kvack.org>; Fri, 14 Jun 2019 13:43:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:subject:from:to:cc
         :date:in-reply-to:references:mime-version:content-transfer-encoding;
        bh=TOfdLcBnSkKFa0etKu8MZcwr2ijJWBkKs1bxmcxDpBY=;
        b=G95aFUQJhE3XzseWkOoWm2jBY52tj24dbc/DAYW1Xex8FtVLqcrMN77zEZvZEtZHGD
         7VoYbEItbs78kukiH54kab0EE4LZU8+GetT/B/Q9nI51+n2vuqP9X46xmjAkp/tCN1hv
         Ucy9+P8sa9wvmHWhGweFTEkXfo4svfu+X0ihwR0hVjH25jOA5793zE8H14szW5tH5P+Z
         REmU5KkYgP+X48HKi2g/gWUoruJEM9PqKPj4ZT/eDc5XHdyeop3bQgHVdewBPK8PVzBu
         9Aal4SlLvuRGxL+1RTnHnuOlUOx5o7GL2Eecittko/AE895F/xV4F2NvIgvKt6S+jP5Z
         g9fw==
X-Gm-Message-State: APjAAAWGSwaoaA81i0UBCOZfhWAWy6YDG9Lou/3Ep2UX3hu1z4kTvO62
	80aOj8DA0DjU4MZ+bFtx++qk1shJgQjH/4RX1LDl/JwrPAbq54aD7Me7J8Z7evVIv+aCBvf2vbl
	MMmudujhzMTPW790mLa3OlXdarkljtEORszX3BGeC/MCd5V0A2AbhMWLRfEhGz8lHEg==
X-Received: by 2002:ac8:3267:: with SMTP id y36mr80660802qta.293.1560544986173;
        Fri, 14 Jun 2019 13:43:06 -0700 (PDT)
X-Received: by 2002:ac8:3267:: with SMTP id y36mr80660754qta.293.1560544985327;
        Fri, 14 Jun 2019 13:43:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560544985; cv=none;
        d=google.com; s=arc-20160816;
        b=DGtWpRvtmV0tArQbCBgTiGe/UPmFIe1iLqWElhGXoVwtHOTuZ0rFd2lB00ZGWzT1Cr
         1wCJbJYv+S/9FDv0oc/3PQc4q15b1KAsNw2N8rtJo7Y6iwhb3MlRadR4TlsRTGNhwxvP
         P4aXs/4aEGYTZKDMx591wt2ZiJjJGQ7/ocYRs1Zaq11jK4VquafzoOJuk5u6dPw5MHJx
         AlbfYtOexV2cPBMcc9f+ObJhwJuPUkjla6eqeIy2naCaxsEhsu+HrO8EepqZrQGrqgXE
         NSt+YIgCHSZSeNJ0djckg/ZGc/D8hPPF3xMhh6Tv0mQevuxI0pEEYJjHgfoQmDM/1tvZ
         mhew==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id:dkim-signature;
        bh=TOfdLcBnSkKFa0etKu8MZcwr2ijJWBkKs1bxmcxDpBY=;
        b=JwuWQ7eNBB+9OZ8j7cxvlMiOk1BFB8MYo8J+XSPkfDMDfBRedbdrT9XBcFqAMV2Av7
         FxbKfriO6VV8u5ddyVivIT3feCLAhczSukLfJVjyI7334IIp24St/QoBbTuUaeuG84eK
         pm2UPtpUqCDQcI5oOY8+g7XWpJx/zPrqp5hsV+qQ6IITEDWXZtxTFmjYW5Es1p8hQ9Ad
         mKqHzN5mHPGUActMfey0sf22VbNXwRiMrNiweUJsEyIi8aH/B95YGXnmu3CgTAQ1e/qo
         COoSRDOoJYyFo0mYNJ1fpLDpF5NEdpHemqodCuEtDqIBJ6nmCQKteOWMoDCRP6teHmcE
         7bzw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=SWqmPKao;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r46sor6204227qtj.12.2019.06.14.13.43.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 14 Jun 2019 13:43:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=SWqmPKao;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=TOfdLcBnSkKFa0etKu8MZcwr2ijJWBkKs1bxmcxDpBY=;
        b=SWqmPKaoD8N4ys6eJDesRML4qgnkieruLHQDsaJRoVoDe7pwP3byPAnIChbS0DQeeh
         /gKDidz47xsO8PVAyAvwJzMUs2DWwVfHFIk4de6zNlhLpnBqZHu3xIrPahMgIkEgrsdG
         msYg9a8jJrE7/3cbOBb/nTuLtBGn+70qHG3hsUMFduXhQDqZOnjwRkAPHoKxX7W+Y5zV
         H3On47vL/D8hx+Efoc8ND5H6CHPa17KL35JV0TxDVQBMoCGgV45+0kB/Q978UB6A3uFd
         kklSDals/I+OpMLvGvcfgqDkUGcdQby91dP8xdiIlslHEzHXphEg1zy101w+XV+ss70d
         nSzQ==
X-Google-Smtp-Source: APXvYqypEz0iVwkHgGws4be35g5UZ1BeYfHQfESVGXNYOOhkliTtpbzW+FcJ+eRQ2oRSpvDbwfrqBg==
X-Received: by 2002:ac8:18f0:: with SMTP id o45mr81653407qtk.273.1560544984932;
        Fri, 14 Jun 2019 13:43:04 -0700 (PDT)
Received: from dhcp-41-57.bos.redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id j62sm1793286qte.89.2019.06.14.13.43.03
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Jun 2019 13:43:04 -0700 (PDT)
Message-ID: <1560544982.5154.24.camel@lca.pw>
Subject: Re: [PATCH -next] mm/hotplug: skip bad PFNs from
 pfn_to_online_page()
From: Qian Cai <cai@lca.pw>
To: Dan Williams <dan.j.williams@intel.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Andrew Morton
 <akpm@linux-foundation.org>, Oscar Salvador <osalvador@suse.de>, Linux MM
 <linux-mm@kvack.org>, Linux Kernel Mailing List
 <linux-kernel@vger.kernel.org>
Date: Fri, 14 Jun 2019 16:43:02 -0400
In-Reply-To: <CAPcyv4i5iUop_H-Ai4q_hn2-3L6aRuovY44tuV50bp1oZj29TQ@mail.gmail.com>
References: <1560366952-10660-1-git-send-email-cai@lca.pw>
	 <CAPcyv4hn0Vz24s5EWKr39roXORtBTevZf7dDutH+jwapgV3oSw@mail.gmail.com>
	 <CAPcyv4iuNYXmF0-EMP8GF5aiPsWF+pOFMYKCnr509WoAQ0VNUA@mail.gmail.com>
	 <1560376072.5154.6.camel@lca.pw> <87lfy4ilvj.fsf@linux.ibm.com>
	 <1560524365.5154.21.camel@lca.pw>
	 <CAPcyv4jAzMzFjSD22VU9Csw+kgGbf8r=XHbdJYzgL_uH_GVEvw@mail.gmail.com>
	 <CAPcyv4hjvBPDYKpp2Gns3-cc2AQ0AVS1nLk-K3fwXeRUvvzQLg@mail.gmail.com>
	 <1560541220.5154.23.camel@lca.pw>
	 <CAPcyv4i5iUop_H-Ai4q_hn2-3L6aRuovY44tuV50bp1oZj29TQ@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-10.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2019-06-14 at 12:48 -0700, Dan Williams wrote:
> On Fri, Jun 14, 2019 at 12:40 PM Qian Cai <cai@lca.pw> wrote:
> > 
> > On Fri, 2019-06-14 at 11:57 -0700, Dan Williams wrote:
> > > On Fri, Jun 14, 2019 at 11:03 AM Dan Williams <dan.j.williams@intel.com>
> > > wrote:
> > > > 
> > > > On Fri, Jun 14, 2019 at 7:59 AM Qian Cai <cai@lca.pw> wrote:
> > > > > 
> > > > > On Fri, 2019-06-14 at 14:28 +0530, Aneesh Kumar K.V wrote:
> > > > > > Qian Cai <cai@lca.pw> writes:
> > > > > > 
> > > > > > 
> > > > > > > 1) offline is busted [1]. It looks like test_pages_in_a_zone()
> > > > > > > missed
> > > > > > > the
> > > > > > > same
> > > > > > > pfn_section_valid() check.
> > > > > > > 
> > > > > > > 2) powerpc booting is generating endless warnings [2]. In
> > > > > > > vmemmap_populated() at
> > > > > > > arch/powerpc/mm/init_64.c, I tried to change PAGES_PER_SECTION to
> > > > > > > PAGES_PER_SUBSECTION, but it alone seems not enough.
> > > > > > > 
> > > > > > 
> > > > > > Can you check with this change on ppc64.  I haven't reviewed this
> > > > > > series
> > > > > > yet.
> > > > > > I did limited testing with change . Before merging this I need to go
> > > > > > through the full series again. The vmemmap poplulate on ppc64 needs
> > > > > > to
> > > > > > handle two translation mode (hash and radix). With respect to vmemap
> > > > > > hash doesn't setup a translation in the linux page table. Hence we
> > > > > > need
> > > > > > to make sure we don't try to setup a mapping for a range which is
> > > > > > arleady convered by an existing mapping.
> > > > > 
> > > > > It works fine.
> > > > 
> > > > Strange... it would only change behavior if valid_section() is true
> > > > when pfn_valid() is not or vice versa. They "should" be identical
> > > > because subsection-size == section-size on PowerPC, at least with the
> > > > current definition of SUBSECTION_SHIFT. I suspect maybe
> > > > free_area_init_nodes() is too late to call subsection_map_init() for
> > > > PowerPC.
> > > 
> > > Can you give the attached incremental patch a try? This will break
> > > support for doing sub-section hot-add in a section that was only
> > > partially populated early at init, but that can be repaired later in
> > > the series. First things first, don't regress.
> > > 
> > > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > > index 874eb22d22e4..520c83aa0fec 100644
> > > --- a/mm/page_alloc.c
> > > +++ b/mm/page_alloc.c
> > > @@ -7286,12 +7286,10 @@ void __init free_area_init_nodes(unsigned long
> > > *max_zone_pfn)
> > > 
> > >         /* Print out the early node map */
> > >         pr_info("Early memory node ranges\n");
> > > -       for_each_mem_pfn_range(i, MAX_NUMNODES, &start_pfn, &end_pfn,
> > > &nid) {
> > > +       for_each_mem_pfn_range(i, MAX_NUMNODES, &start_pfn, &end_pfn,
> > > &nid)
> > >                 pr_info("  node %3d: [mem %#018Lx-%#018Lx]\n", nid,
> > >                         (u64)start_pfn << PAGE_SHIFT,
> > >                         ((u64)end_pfn << PAGE_SHIFT) - 1);
> > > -               subsection_map_init(start_pfn, end_pfn - start_pfn);
> > > -       }
> > > 
> > >         /* Initialise every node */
> > >         mminit_verify_pageflags_layout();
> > > diff --git a/mm/sparse.c b/mm/sparse.c
> > > index 0baa2e55cfdd..bca8e6fa72d2 100644
> > > --- a/mm/sparse.c
> > > +++ b/mm/sparse.c
> > > @@ -533,6 +533,7 @@ static void __init sparse_init_nid(int nid,
> > > unsigned long pnum_begin,
> > >                 }
> > >                 check_usemap_section_nr(nid, usage);
> > >                 sparse_init_one_section(__nr_to_section(pnum), pnum,
> > > map, usage);
> > > +               subsection_map_init(section_nr_to_pfn(pnum),
> > > PAGES_PER_SECTION);
> > >                 usage = (void *) usage + mem_section_usage_size();
> > >         }
> > >         sparse_buffer_fini();
> > 
> > It works fine except it starts to trigger slab debugging errors during boot.
> > Not
> > sure if it is related yet.
> 
> If you want you can give this branch a try if you suspect something
> else in -next is triggering the slab warning.
> 
> https://git.kernel.org/pub/scm/linux/kernel/git/djbw/nvdimm.git/log/?h=subsect
> ion-v9
> 
> It's the original v9 patchset + dependencies backported to v5.2-rc4.
> 
> I otherwise don't see how subsections would effect slab caches.

It works fine there.

