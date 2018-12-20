Return-Path: <SRS0=PcJq=O5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 894B0C43387
	for <linux-mm@archiver.kernel.org>; Thu, 20 Dec 2018 16:57:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3330020815
	for <linux-mm@archiver.kernel.org>; Thu, 20 Dec 2018 16:57:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="BF+jxDWa"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3330020815
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B25F08E0003; Thu, 20 Dec 2018 11:57:34 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AD44D8E0001; Thu, 20 Dec 2018 11:57:34 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9C37F8E0003; Thu, 20 Dec 2018 11:57:34 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6D3B78E0001
	for <linux-mm@kvack.org>; Thu, 20 Dec 2018 11:57:34 -0500 (EST)
Received: by mail-oi1-f197.google.com with SMTP id n196so1730487oig.15
        for <linux-mm@kvack.org>; Thu, 20 Dec 2018 08:57:34 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=DYRCP9UN9luBBsvCXHDTrjPXPPJREpwyogy2A14Q3wo=;
        b=b7JddZx4dFjRgoLFeAVJe1eJvchDbU7PUUTnqVKfW/eLxyksd/SIiyTVccxiorzeuH
         Z1zKt/RsfTg5diMNH6FKJbALKaUTyfTSHLFx6AwgbmDVrdJLlnBd7fadWDiTrpuZu9bD
         foo8g+Aos+TVAAKuvCZhddjRYkQXXJ/QK3IYlmA3V0Nu2APY2Smi+vxkaiGAx098rzl8
         Pmho015hazWrTSnaxGu84AV2QE5Aa+BrAKtAda7sB40agTW6GXXZkJGYkAPNS3Noh3ik
         XgbFRT43bqHoR1TjlopEL0u2cZIS68qKXGGPTDppHphevjiDLdNoNTVLywiemJcj2dBB
         i5TA==
X-Gm-Message-State: AA+aEWZqh6O+L4qtjNx5X23GR4WCyDXJHpPzevJ0TF79sMaVSc4/C6xf
	o/xRWA/Hi6jji1rqcWZKTK6/mEFqgDbIN3qzsiuq69vII2r30MFfI2uoIVG00sB/u9rT5rrNvLI
	xv9+aNy1xAhcq77xsQKCdyHEq6e9KnsPSjiTDn9nibZOS/tzOCa2msSN5CWoQtUmi+XE91YvZ9Z
	CjWBSC6Fy+pBJXTvsegRkR96biszF0sEKvOFM8hXuivY9Jgb+x7vW/k99wa4azjbPlzC0lW0unY
	1ossyjOViTPmzGrUMD5CUFFpmY+4s9TANY1ZSpVbsYuJl5bmeBbzG4wiYkyhFwWO6OGUqthQEe+
	aRXgGKJMdIr3td1ymxoCOmuR6f0jTkWbVMI4YjaknSxinBWpflThlPwYeq49P+Ye1zDmhIv7Y8w
	k
X-Received: by 2002:aca:2807:: with SMTP id 7mr2937562oix.7.1545325054128;
        Thu, 20 Dec 2018 08:57:34 -0800 (PST)
X-Received: by 2002:aca:2807:: with SMTP id 7mr2937532oix.7.1545325053427;
        Thu, 20 Dec 2018 08:57:33 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1545325053; cv=none;
        d=google.com; s=arc-20160816;
        b=nR4wQWif+70hwW1gmZbueICOQZ6H6GQz7yNzilJkXRmcNNteQz/4aRGp+Y8Q44+Cww
         vt00sTLNFc7UwAznQf3WiC0bliNL5KdahpCH+buRej1RZ24ssPeQMg8X6Ois+WKUD1Z5
         GHktXtO3aueTkaJb8GVP0jXB/wtoWiFMNBg5bNms9shFXK0nMNwU+7wsO8OStq4masHG
         WhrAJYtS0DZDniQDjQjA4Z+2r4KWaFt+MgSt2rQ8wExXPdMAqDPlZGjLOHDLVEfug2Iq
         yqmIGo/Cyms8BbtjZioB5KbzYg2EjaiM9KESa8rXyV1cKdgqqJzdqfb+NpoZdFVXm5UF
         Y8lg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=DYRCP9UN9luBBsvCXHDTrjPXPPJREpwyogy2A14Q3wo=;
        b=VvzyxuQVuvtHWzKb/HRclGxDKM1KQ+q9xbZN2I9yzFTWB0NJuzBxLmUjJkKCCv8ZCY
         ypNKk/Tw4ohu2pXibtv7HgioSGB7cQY8ywAS59rQGepwqKrzr6M7rKnV+ABEWltHwci5
         VzHOTJGmRGgphCS+t7VogJ4L5JO8tlC2W50yBQ8D3Xm4lxH+NP9xTj11oM2FNKdjWEcT
         3JbLbviy/lmK3ovS/XHn6bS+uEo9gCAd/ECIy04FO8ri+1pPMPR6tEsvzlitRT0KjccA
         XQYtro869h+i2+6QP3ca40SzxvtNs0kgtsZYwjTwCR48ALPYYLXphIKXajjCyQpi2GeG
         mpQw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=BF+jxDWa;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h38sor14116683oth.102.2018.12.20.08.57.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 20 Dec 2018 08:57:33 -0800 (PST)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=BF+jxDWa;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=DYRCP9UN9luBBsvCXHDTrjPXPPJREpwyogy2A14Q3wo=;
        b=BF+jxDWaMphjdbIE5m6BbKM9lClqGRJRTGaKWB+fCVLJe/SZocmVMCJD9ohNMiKav/
         fKjZMPDcyFwY4po1ZMBzgMblTjmN+TPwnUxY2SdRGpvulfuWnU1i+PCPMtABqCWwoJDM
         hywlsMQbC3hdF49+lKUceJFYCBs5t4l9jhhNJGv2IsCgfEQjTPskI0P3ilo/dLoijyEV
         d7vLnDReV2sow+LkSc1wsys6szTsQO/mDObZaf33ul6um9Y1CG/XbO4WSQ/KJat2nrfX
         6GLtiSiO75c0SNylDl/mgdoprBeTZ6XoSMOxeBzmQuQLqzlhwGobIar+ZH3uHOPSC5W3
         +qIA==
X-Google-Smtp-Source: AFSGD/WCi156/s0upT+G+UTmXWfUxt4iIsjfeMe4jWUZi3yb6/MuVgIfvwzU8+4eUgIMppvOx9oFlGJzJjhJevVoKeQ=
X-Received: by 2002:a9d:6a50:: with SMTP id h16mr17529610otn.95.1545325053044;
 Thu, 20 Dec 2018 08:57:33 -0800 (PST)
MIME-Version: 1.0
References: <20181212214641.GB29416@dastard> <20181214154321.GF8896@quack2.suse.cz>
 <20181216215819.GC10644@dastard> <20181217181148.GA3341@redhat.com>
 <20181217183443.GO10600@bombadil.infradead.org> <20181218093017.GB18032@quack2.suse.cz>
 <9f43d124-2386-7bfd-d90b-4d0417f51ccd@nvidia.com> <20181219020723.GD4347@redhat.com>
 <20181219110856.GA18345@quack2.suse.cz> <8e98d553-7675-8fa1-3a60-4211fc836ed9@nvidia.com>
 <20181220165030.GC3963@redhat.com>
In-Reply-To: <20181220165030.GC3963@redhat.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 20 Dec 2018 08:57:22 -0800
Message-ID:
 <CAPcyv4iDdOGh6wCug9sZsrPdby1Sv1jG5aRUA5PjL0dDW7eNNA@mail.gmail.com>
Subject: Re: [PATCH 1/2] mm: introduce put_user_page*(), placeholder versions
To: Jerome Glisse <jglisse@redhat.com>
Cc: John Hubbard <jhubbard@nvidia.com>, Jan Kara <jack@suse.cz>, 
	Matthew Wilcox <willy@infradead.org>, Dave Chinner <david@fromorbit.com>, 
	John Hubbard <john.hubbard@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Linux MM <linux-mm@kvack.org>, tom@talpey.com, Al Viro <viro@zeniv.linux.org.uk>, 
	benve@cisco.com, Christoph Hellwig <hch@infradead.org>, Christopher Lameter <cl@linux.com>, 
	"Dalessandro, Dennis" <dennis.dalessandro@intel.com>, Doug Ledford <dledford@redhat.com>, 
	Jason Gunthorpe <jgg@ziepe.ca>, Michal Hocko <mhocko@kernel.org>, 
	Mike Marciniszyn <mike.marciniszyn@intel.com>, rcampbell@nvidia.com, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, 
	linux-fsdevel <linux-fsdevel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20181220165722.R7s1ZEHkRgtHm4tYzpnt9VY1h5NMG3h_b0g817THktk@z>

On Thu, Dec 20, 2018 at 8:50 AM Jerome Glisse <jglisse@redhat.com> wrote:
>
> On Thu, Dec 20, 2018 at 02:54:49AM -0800, John Hubbard wrote:
> > On 12/19/18 3:08 AM, Jan Kara wrote:
> > > On Tue 18-12-18 21:07:24, Jerome Glisse wrote:
> > >> On Tue, Dec 18, 2018 at 03:29:34PM -0800, John Hubbard wrote:
> > >>> OK, so let's take another look at Jerome's _mapcount idea all by itself (using
> > >>> *only* the tracking pinned pages aspect), given that it is the lightest weight
> > >>> solution for that.
> > >>>
> > >>> So as I understand it, this would use page->_mapcount to store both the real
> > >>> mapcount, and the dma pinned count (simply added together), but only do so for
> > >>> file-backed (non-anonymous) pages:
> > >>>
> > >>>
> > >>> __get_user_pages()
> > >>> {
> > >>>   ...
> > >>>   get_page(page);
> > >>>
> > >>>   if (!PageAnon)
> > >>>           atomic_inc(page->_mapcount);
> > >>>   ...
> > >>> }
> > >>>
> > >>> put_user_page(struct page *page)
> > >>> {
> > >>>   ...
> > >>>   if (!PageAnon)
> > >>>           atomic_dec(&page->_mapcount);
> > >>>
> > >>>   put_page(page);
> > >>>   ...
> > >>> }
> > >>>
> > >>> ...and then in the various consumers of the DMA pinned count, we use page_mapped(page)
> > >>> to see if any mapcount remains, and if so, we treat it as DMA pinned. Is that what you
> > >>> had in mind?
> > >>
> > >> Mostly, with the extra two observations:
> > >>     [1] We only need to know the pin count when a write back kicks in
> > >>     [2] We need to protect GUP code with wait_for_write_back() in case
> > >>         GUP is racing with a write back that might not the see the
> > >>         elevated mapcount in time.
> > >>
> > >> So for [2]
> > >>
> > >> __get_user_pages()
> > >> {
> > >>     get_page(page);
> > >>
> > >>     if (!PageAnon) {
> > >>         atomic_inc(page->_mapcount);
> > >> +       if (PageWriteback(page)) {
> > >> +           // Assume we are racing and curent write back will not see
> > >> +           // the elevated mapcount so wait for current write back and
> > >> +           // force page fault
> > >> +           wait_on_page_writeback(page);
> > >> +           // force slow path that will fault again
> > >> +       }
> > >>     }
> > >> }
> > >
> > > This is not needed AFAICT. __get_user_pages() gets page reference (and it
> > > should also increment page->_mapcount) under PTE lock. So at that point we
> > > are sure we have writeable PTE nobody can change. So page_mkclean() has to
> > > block on PTE lock to make PTE read-only and only after going through all
> > > PTEs like this, it can check page->_mapcount. So the PTE lock provides
> > > enough synchronization.
> > >
> > >> For [1] only needing pin count during write back turns page_mkclean into
> > >> the perfect spot to check for that so:
> > >>
> > >> int page_mkclean(struct page *page)
> > >> {
> > >>     int cleaned = 0;
> > >> +   int real_mapcount = 0;
> > >>     struct address_space *mapping;
> > >>     struct rmap_walk_control rwc = {
> > >>         .arg = (void *)&cleaned,
> > >>         .rmap_one = page_mkclean_one,
> > >>         .invalid_vma = invalid_mkclean_vma,
> > >> +       .mapcount = &real_mapcount,
> > >>     };
> > >>
> > >>     BUG_ON(!PageLocked(page));
> > >>
> > >>     if (!page_mapped(page))
> > >>         return 0;
> > >>
> > >>     mapping = page_mapping(page);
> > >>     if (!mapping)
> > >>         return 0;
> > >>
> > >>     // rmap_walk need to change to count mapping and return value
> > >>     // in .mapcount easy one
> > >>     rmap_walk(page, &rwc);
> > >>
> > >>     // Big fat comment to explain what is going on
> > >> +   if ((page_mapcount(page) - real_mapcount) > 0) {
> > >> +       SetPageDMAPined(page);
> > >> +   } else {
> > >> +       ClearPageDMAPined(page);
> > >> +   }
> > >
> > > This is the detail I'm not sure about: Why cannot rmap_walk_file() race
> > > with e.g. zap_pte_range() which decrements page->_mapcount and thus the
> > > check we do in page_mkclean() is wrong?
> >
> > Right. This looks like a dead end, after all. We can't lock a whole chunk
> > of "all these are mapped, hold still while we count you" pages. It's not
> > designed to allow that at all.
> >
> > IMHO, we are now back to something like dynamic_page, which provides an
> > independent dma pinned count.
>
> I will keep looking because allocating a structure for every GUP is
> insane to me they are user out there that are GUPin GigaBytes of data

This is not the common case.

> and it gonna waste tons of memory just to fix crappy hardware.

This is the common case.

Please refrain from the hyperbolic assessments.

