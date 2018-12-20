Return-Path: <SRS0=PcJq=O5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 43561C43444
	for <linux-mm@archiver.kernel.org>; Thu, 20 Dec 2018 16:49:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F01B320869
	for <linux-mm@archiver.kernel.org>; Thu, 20 Dec 2018 16:49:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F01B320869
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 92F548E0002; Thu, 20 Dec 2018 11:49:19 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8DDCA8E0001; Thu, 20 Dec 2018 11:49:19 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7A80C8E0002; Thu, 20 Dec 2018 11:49:19 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5216F8E0001
	for <linux-mm@kvack.org>; Thu, 20 Dec 2018 11:49:19 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id c71so2362491qke.18
        for <linux-mm@kvack.org>; Thu, 20 Dec 2018 08:49:19 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=fzWGDwJfAV4I2qmOqBf0GtqT1AXDRemVup93wgXFWvA=;
        b=HYROI2V4oiH/EQvh1zb9OGiWbxnctpEOdX0yZ6iTf9CwBx8/hxXWAZTJojch3Obsva
         AsJ5GdTTs6DqGdNkcE9s5zpcsKCk/TJ9rRlwdOxoJ8OqYJbAs20wLpXGGc9QQQ9tVbGO
         EvoNhc00pfmGe9rYVBiaQKYM671hk70qnH4Pq7WXvZ4XhATZNCxNpBkQ96sUL47o0rbG
         sQz5/HVWgnRMx39hyjxqojCWOw/YTb1bhQgqgqwdlBAK+VoQcEIqLnmpXoxE5ySGNRfz
         QVXOBE1rK/9cAO+D2D5Ht0rDlSOO8Mr9MysBEXGKEGsmCuLP8BVTPETjxXHV/aRlaZYI
         bFSQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AA+aEWaEijOKPW4UcXs4TwT6JxyGTFcVpakzejPNfe8KRC/+h62Y7Nra
	8+FptOWg9qwYnM7Ummcao8zLAQggM2w/Z9buYhEOKaVw/dBGetraIVN2o3AiUs9ANOwwCqhs8IW
	Hw9Sggus/pag/WWiCVcFnWaacAYyM+TuCf8RfaNvWS0S3KcNsuqhiUXro5GZe8QnOKA==
X-Received: by 2002:a37:90c3:: with SMTP id s186mr25114416qkd.339.1545324559021;
        Thu, 20 Dec 2018 08:49:19 -0800 (PST)
X-Google-Smtp-Source: AFSGD/VsOP8oPMR5lBb/Os2nesZZvzWBMWWYnML+umZDDSzdgbggDZQhKCOKnyK7eNsu9IBkQLNW
X-Received: by 2002:a37:90c3:: with SMTP id s186mr25114357qkd.339.1545324558145;
        Thu, 20 Dec 2018 08:49:18 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1545324558; cv=none;
        d=google.com; s=arc-20160816;
        b=FFddGxSD3wbkGULUt6ODiLLs5RrRgWbarMSIjFXaxP6yz2gxeTlytUhVSa8jB7HOBf
         zXLt2Uc+6DWSebTKOg/XzUDsZCVHeDY03HeNpTASvC4KTfpUsrta+vzR76WV7j4gjLhd
         vGccfogleVClvT+dGd1XnHBkouvZXzO/XZiAu6AtVzbGMtcFDDFaXk9ip8AtILO2c8/u
         KCW3sga7mG/iACBPp5GKguDjk2Pj66pWfIcUxDhIQLQPrUlbA/o2tCFXqIWyxcLhl2la
         FTAsnG88Tybgo2DrjTfwoYUrcACU2bHp7PbR7VY1aDgaC6Zlk7ujYsAuuZhdTEH0NARS
         lpLQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=fzWGDwJfAV4I2qmOqBf0GtqT1AXDRemVup93wgXFWvA=;
        b=jo/F1WQrhlp7USy/zjrknMp+oHWJyDHlOpiMD9JfDSER+lgvhTSVsFfZtHPEGPg8UM
         JNTouJrkeblZjaoZzdkWMBpF16reC5SATZPcDMt4r1Myq+VVGFyV8/hkLe7/UND/AM9b
         LO0AaJvlYghCdSWT026fOVwKXFybmCEKooVlS2z+Asf9xDrWcWBryV1mI10l6tE9NtIU
         ax9AHbOf6SSd66uZUZiETMENfhMZ+AztRQtEYVaNcR4SKngw5tcmasfreTbKWerlaKFF
         Bkj0tbQOe9i/yJxs2DySewJ0JSS0X0gN5XavzejfSkMt66tB1wBobWc25P/Ic62Hb070
         ZE/A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x92si2158109qte.108.2018.12.20.08.49.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Dec 2018 08:49:18 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 77475AB409;
	Thu, 20 Dec 2018 16:49:16 +0000 (UTC)
Received: from redhat.com (ovpn-123-95.rdu2.redhat.com [10.10.123.95])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 27E771055006;
	Thu, 20 Dec 2018 16:49:14 +0000 (UTC)
Date: Thu, 20 Dec 2018 11:49:12 -0500
From: Jerome Glisse <jglisse@redhat.com>
To: Jan Kara <jack@suse.cz>
Cc: John Hubbard <jhubbard@nvidia.com>,
	Matthew Wilcox <willy@infradead.org>,
	Dave Chinner <david@fromorbit.com>,
	Dan Williams <dan.j.williams@intel.com>,
	John Hubbard <john.hubbard@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux MM <linux-mm@kvack.org>, tom@talpey.com,
	Al Viro <viro@zeniv.linux.org.uk>, benve@cisco.com,
	Christoph Hellwig <hch@infradead.org>,
	Christopher Lameter <cl@linux.com>,
	"Dalessandro, Dennis" <dennis.dalessandro@intel.com>,
	Doug Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>,
	Michal Hocko <mhocko@kernel.org>, mike.marciniszyn@intel.com,
	rcampbell@nvidia.com,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>
Subject: Re: [PATCH 1/2] mm: introduce put_user_page*(), placeholder versions
Message-ID: <20181220164912.GB3963@redhat.com>
References: <20181212150319.GA3432@redhat.com>
 <20181212214641.GB29416@dastard>
 <20181214154321.GF8896@quack2.suse.cz>
 <20181216215819.GC10644@dastard>
 <20181217181148.GA3341@redhat.com>
 <20181217183443.GO10600@bombadil.infradead.org>
 <20181218093017.GB18032@quack2.suse.cz>
 <9f43d124-2386-7bfd-d90b-4d0417f51ccd@nvidia.com>
 <20181219020723.GD4347@redhat.com>
 <20181219110856.GA18345@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20181219110856.GA18345@quack2.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.28]); Thu, 20 Dec 2018 16:49:17 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20181220164912.DXg9bQ5ADTPQKY01Ou8oJRBhmWj4K-VDlF9-aqScDUE@z>

On Wed, Dec 19, 2018 at 12:08:56PM +0100, Jan Kara wrote:
> On Tue 18-12-18 21:07:24, Jerome Glisse wrote:
> > On Tue, Dec 18, 2018 at 03:29:34PM -0800, John Hubbard wrote:
> > > OK, so let's take another look at Jerome's _mapcount idea all by itself (using
> > > *only* the tracking pinned pages aspect), given that it is the lightest weight
> > > solution for that.  
> > > 
> > > So as I understand it, this would use page->_mapcount to store both the real
> > > mapcount, and the dma pinned count (simply added together), but only do so for
> > > file-backed (non-anonymous) pages:
> > > 
> > > 
> > > __get_user_pages()
> > > {
> > > 	...
> > > 	get_page(page);
> > > 
> > > 	if (!PageAnon)
> > > 		atomic_inc(page->_mapcount);
> > > 	...
> > > }
> > > 
> > > put_user_page(struct page *page)
> > > {
> > > 	...
> > > 	if (!PageAnon)
> > > 		atomic_dec(&page->_mapcount);
> > > 
> > > 	put_page(page);
> > > 	...
> > > }
> > > 
> > > ...and then in the various consumers of the DMA pinned count, we use page_mapped(page)
> > > to see if any mapcount remains, and if so, we treat it as DMA pinned. Is that what you 
> > > had in mind?
> > 
> > Mostly, with the extra two observations:
> >     [1] We only need to know the pin count when a write back kicks in
> >     [2] We need to protect GUP code with wait_for_write_back() in case
> >         GUP is racing with a write back that might not the see the
> >         elevated mapcount in time.
> > 
> > So for [2]
> > 
> > __get_user_pages()
> > {
> >     get_page(page);
> > 
> >     if (!PageAnon) {
> >         atomic_inc(page->_mapcount);
> > +       if (PageWriteback(page)) {
> > +           // Assume we are racing and curent write back will not see
> > +           // the elevated mapcount so wait for current write back and
> > +           // force page fault
> > +           wait_on_page_writeback(page);
> > +           // force slow path that will fault again
> > +       }
> >     }
> > }
> 
> This is not needed AFAICT. __get_user_pages() gets page reference (and it
> should also increment page->_mapcount) under PTE lock. So at that point we
> are sure we have writeable PTE nobody can change. So page_mkclean() has to
> block on PTE lock to make PTE read-only and only after going through all
> PTEs like this, it can check page->_mapcount. So the PTE lock provides
> enough synchronization.

This is needed, file back page can be map in any number of page table
and thus no PTE lock gonna protect anything in the end. More over with
GUP fast we really have to assume there is no lock that force ordering.

In fact in the above snipet that mapcount should not happen if there
is an on going write back.


> > For [1] only needing pin count during write back turns page_mkclean into
> > the perfect spot to check for that so:
> > 
> > int page_mkclean(struct page *page)
> > {
> >     int cleaned = 0;
> > +   int real_mapcount = 0;
> >     struct address_space *mapping;
> >     struct rmap_walk_control rwc = {
> >         .arg = (void *)&cleaned,
> >         .rmap_one = page_mkclean_one,
> >         .invalid_vma = invalid_mkclean_vma,
> > +       .mapcount = &real_mapcount,
> >     };
> > 
> >     BUG_ON(!PageLocked(page));
> > 
> >     if (!page_mapped(page))
> >         return 0;
> > 
> >     mapping = page_mapping(page);
> >     if (!mapping)
> >         return 0;
> > 
> >     // rmap_walk need to change to count mapping and return value
> >     // in .mapcount easy one
> >     rmap_walk(page, &rwc);
> > 
> >     // Big fat comment to explain what is going on
> > +   if ((page_mapcount(page) - real_mapcount) > 0) {
> > +       SetPageDMAPined(page);
> > +   } else {
> > +       ClearPageDMAPined(page);
> > +   }
> 
> This is the detail I'm not sure about: Why cannot rmap_walk_file() race
> with e.g. zap_pte_range() which decrements page->_mapcount and thus the
> check we do in page_mkclean() is wrong?

Ok so i thought about this here is what we have:
    mp1 = page_mapcount(page);
    // let name rc1 the number of real count at mp1 time (this is
    // an ideal value that we can not get)

    rmap_walk(page, &rwc);
    // at this point let's name frc the number of real map count
    // found by rmap_walk

    mp2 = page_mapcount(page);
    // let name rc2 the number of real count at mp2 time (this is
    // an ideal value that we can not get)


So we have
    rc1 >= frc >= rc2
    pc1 = mp1 - rc1     // pin count at mp1 time
    pc2 = mp2 - rc2     // pin count at mp2 time

So we have:
    mp1 - rc1 <= mp1 - frc
    mp2 - rc2 >= mp2 - frc

From the above:
    mp1 - frc <  0 impossible value mapcount can only go down so
                   frc <= mp1
    mp1 - frc == 0 -> the page is not pin
U1  mp1 - frc >  0 -> the page might be pin

U2  mp2 - frc <= 0 -> the page might be pin
    mp2 - frc >  0 -> the page is pin

They are two unknowns [U1] and [U2]:
    [U1]    a zap raced before rmap_walk() could account the zaped
            mapping (frc < rc1)
    [U2]    a zap raced after rmap_walk() accounted the zaped
            mapping (frc > rc2)

In both cases we can detect the race but we can not ascertain if page
is pin or not.

So we can do 2 things here:
    - try to recount the real mapping (it is bound to end as no
      new mapping can be added and thus mapcount can only go down)
    - assume false positive and uselessly bounce page that would
      not need bouncing if we were not unlucky

We could mitigate this with a flag GUP unconditionaly set it and page
mkclean clears it when mp1 - frc == 0 this way we never bounce page
that were never GUPed but we might keep bouncing a page that was GUPed
once in its lifetime until there is not race for it in page_mkclean.

I will ponder a bit more and see if i can get an idea on how to close
that race ie either close U1 or close U2.


> >     // Maybe we want to leverage the int nature of return value so that
> >     // we can express more than cleaned/truncated and express cleaned/
> >     // truncated/pinned for benefit of caller and that way we do not
> >     // even need one bit as page flags above.
> > 
> >     return cleaned;
> > }
> > 
> > You do not want to change page_mapped() i do not see a need for that.
> > 
> > Then the whole discussion between Jan and Dave seems to indicate that
> > the bounce mechanism will need to be in the fs layer and that we can
> > not reuse the bio bounce mechanism. This means that more work is needed
> > at the fs level for that (so that fs do not freak on bounce page).
> > 
> > Note that they are few gotcha where we need to preserve the pin count
> > ie mostly in truncate code path that can remove page from page cache
> > and overwrite the mapcount in the process, this would need to be fixed
> > to not overwrite mapcount so that put_user_page does not set the map
> > count to an invalid value turning the page into a bad state that will
> > at one point trigger kernel BUG_ON();
> >
> > I am not saying block truncate, i am saying make sure it does not
> > erase pin count and keep truncating happily. The how to handle truncate
> > is a per existing GUP user discussion to see what they want to do for
> > that.
> > 
> > Obviously a bit deeper analysis of all spot that use mapcount is needed
> > to check that we are not breaking anything but from the top of my head
> > i can not think of anything bad (migrate will abort and other things will
> > assume the page is mapped even it is only in hardware page table, ...).
> 
> Hum, grepping for page_mapped() and page_mapcount(), this is actually going
> to be non-trivial to get right AFAICT.

No that's not that scary a good chunk of all those are for anonymous
memory and many are obvious (like migrate, ksm, ...).

Cheers,
Jérôme

