Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ABA9DC282DA
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 02:04:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 57D9420651
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 02:04:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 57D9420651
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C76AE6B0277; Tue, 16 Apr 2019 22:04:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C26B76B0278; Tue, 16 Apr 2019 22:04:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A9FC06B0279; Tue, 16 Apr 2019 22:04:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7EEEA6B0277
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 22:04:01 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id g17so21084855qte.17
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 19:04:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=BJDWYPBACUP7ZqqWghFGBkad5yL7pl8eeYAFKzOkGVI=;
        b=mniKZHBZaqe4MVMRLQXxhhuckfAHtidrLt+fdA5fY7T1yyzqbaqfhd9onjtsPPU2AK
         52HnTWxJUZbmbkXgI7+clEvNfDjpb3DHgbU8C9OHohaAA9GCMNx1DuOX/DE/2xESOgNh
         GIK8MJHGdN1q3kbuQ3JgEsOqlHsDvRro7+XrPDGXzLZ/BAPvF9VsQe1PWHoLnGDUSWa3
         YaEIDd2b5G7gmimeIH8kLDSHQfTAznnc6wA1s8X45FPdalDLd+cWR7jQdwCsvXBSHUth
         n/zZy0bD2gw26fpkTzCeyG6/GPoAeiM9Dp+epVkZUeA8Tif9+GUrGQM/ioocrxok+rLd
         czzg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUa8ijiPr2veJwwms0WVOEkVyDso+msUjVnY9suELSGk8/RLGeh
	buOsjZNi4eNQZwqTmapAReLMCapxbeGSEF3GNDhFM4HbS2vdeU5JQTmOlHp4xpDS2hWyAI+Zg1X
	titbAGSC1HrirXbriFJqZOLx4KqO6y95B/acgIbH8QWw1VyGkA3WrtmjiWSBua2gjvA==
X-Received: by 2002:a37:4a12:: with SMTP id x18mr63192534qka.184.1555466641196;
        Tue, 16 Apr 2019 19:04:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxyUaiigfuAJ1P7Z4oDqUgaKdP4XzYerYGttIOXtKewr2DuIgiIVCSwj5bW7q9XjOzrFAXG
X-Received: by 2002:a37:4a12:: with SMTP id x18mr63192478qka.184.1555466639799;
        Tue, 16 Apr 2019 19:03:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555466639; cv=none;
        d=google.com; s=arc-20160816;
        b=f9H/PbFclAwWH6l1sv9y4Z2CuOx3IYb175slbRMPmJ15hRn4pBqnrTrxqZKN7ki/WV
         u5sOW9PIR7agD5SDDyoLt5EdJIBroc2WhN5jsZetf9KISYR9PlwT2mf6itCkr03OWH8l
         uH/BDR//mKRykNPc4RiEVuBACNf7HzB7v56aOwhGRoNaX4eQ3Dc9jUpWYqJTvg0oWeZd
         bnD6uowTFyxwJAFYymwr7N1w6PISFNLP41wVPgN/ayuIDVaHLa1cHacDZPkGmFyTC2Wv
         M5nV7WvRnaOuQc446iqyKy8MUDhHjfqUlqQbtI7jn+Y1E2yF4C8QopE9y7FX7v3KEFyQ
         ydew==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=BJDWYPBACUP7ZqqWghFGBkad5yL7pl8eeYAFKzOkGVI=;
        b=Xzx78cF3Me9OIdEkBt1y7EBO+l+NFUdNBmtzPJgd1LKWnapOvVdxSwhtjyLb2+O+a7
         ZSXxUVmsGVSSKHCcp+fYcl5oa+MT3Kc6IEq4VCgBfGn145p3hWqPMwv0wWm5gOW++fAI
         btCAbBu5MF1JhlACss/24wvhSGaMa+w3TC4EiTWrU0H2iycmUjQYmqi8boxG3zyNx4YP
         FIIzUzSs7SdRt4IzE/WFl2jCRwzNOinmj77bqD9LUL/WN8npkKZsrWjTHrrs5Kexmg8M
         LhOawt4H3MUx1tn6nQCxaV88jDd1WspJCC7epbxMoQC113jminp5m8TzO4Rh8aSyid84
         VUAw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g6si7188619qke.211.2019.04.16.19.03.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Apr 2019 19:03:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 6B92C3DE10;
	Wed, 17 Apr 2019 02:03:58 +0000 (UTC)
Received: from redhat.com (ovpn-120-132.rdu2.redhat.com [10.10.120.132])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 2AC405C205;
	Wed, 17 Apr 2019 02:03:48 +0000 (UTC)
Date: Tue, 16 Apr 2019 22:03:46 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: Boaz Harrosh <boaz@plexistor.com>
Cc: Boaz Harrosh <openosd@gmail.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Kent Overstreet <kent.overstreet@gmail.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	linux-block@vger.kernel.org, Linux MM <linux-mm@kvack.org>,
	John Hubbard <jhubbard@nvidia.com>, Jan Kara <jack@suse.cz>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Johannes Thumshirn <jthumshirn@suse.de>,
	Christoph Hellwig <hch@lst.de>, Jens Axboe <axboe@kernel.dk>,
	Ming Lei <ming.lei@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>,
	Matthew Wilcox <willy@infradead.org>,
	Steve French <sfrench@samba.org>, linux-cifs@vger.kernel.org,
	Yan Zheng <zyan@redhat.com>, Sage Weil <sage@redhat.com>,
	Ilya Dryomov <idryomov@gmail.com>, Alex Elder <elder@kernel.org>,
	ceph-devel@vger.kernel.org, Eric Van Hensbergen <ericvh@gmail.com>,
	Latchesar Ionkov <lucho@ionkov.net>,
	Mike Marshall <hubcap@omnibond.com>,
	Martin Brandenburg <martin@omnibond.com>,
	Dominique Martinet <asmadeus@codewreck.org>,
	v9fs-developer@lists.sourceforge.net, Coly Li <colyli@suse.de>,
	linux-bcache@vger.kernel.org,
	Ernesto =?iso-8859-1?Q?A=2E_Fern=E1ndez?= <ernesto.mnd.fernandez@gmail.com>
Subject: Re: [PATCH v1 00/15] Keep track of GUPed pages in fs and block
Message-ID: <20190417020345.GB3330@redhat.com>
References: <20190411210834.4105-1-jglisse@redhat.com>
 <2c124cc4-b97e-ee28-2926-305bc6bc74bd@plexistor.com>
 <20190416185922.GA12818@kmo-pixel>
 <CAPcyv4jLrQ6evLAJzsASh=H6Tzx8E1oiF+YR3L2fOpbZYNUWGg@mail.gmail.com>
 <ccac6c5a-7120-0455-88de-ca321b01e825@plexistor.com>
 <20190416195735.GE21526@redhat.com>
 <41e2d7e1-104b-a006-2824-015ca8c76cc8@gmail.com>
 <20190416231655.GB22465@redhat.com>
 <fa00a2ff-3664-3165-7af8-9d9c53238245@plexistor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <fa00a2ff-3664-3165-7af8-9d9c53238245@plexistor.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.29]); Wed, 17 Apr 2019 02:03:59 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 17, 2019 at 04:11:03AM +0300, Boaz Harrosh wrote:
> On 17/04/19 02:16, Jerome Glisse wrote:
> > On Wed, Apr 17, 2019 at 01:09:22AM +0300, Boaz Harrosh wrote:
> >> On 16/04/19 22:57, Jerome Glisse wrote:
> >> <>
> >>>
> >>> A very long thread on this:
> >>>
> >>> https://lkml.org/lkml/2018/12/3/1128
> >>>
> >>> especialy all the reply to this first one
> >>>
> >>> There is also:
> >>>
> >>> https://lkml.org/lkml/2019/3/26/1395
> >>> https://lwn.net/Articles/753027/
> >>>
> >>
> >> OK I have re-read this patchset and a little bit of the threads above (not all)
> >>
> >> As I understand the long term plan is to keep two separate ref-counts one
> >> for GUP-ref and one for the regular page-state/ownership ref.
> >> Currently looking at page-ref we do not know if we have a GUP currently held.
> >> With the new plan we can (Still not sure what's the full plan with this new info)
> >>
> >> But if you make it such as the first GUP-ref also takes a page_ref and the
> >> last GUp-dec also does put_page. Then the all of these becomes a matter of
> >> matching every call to get_user_pages or iov_iter_get_pages() with a new
> >> put_user_pages or iov_iter_put_pages().
> >>
> >> Then if much below us an LLD takes a get_page() say an skb below the iscsi
> >> driver, and so on. We do not care and we keep doing a put_page because we know
> >> the GUP-ref holds the page for us.
> >>
> >> The current block layer is transparent to any page-ref it does not take any
> >> nor put_page any. It is only the higher users that have done GUP that take care of that.
> >>
> >> The patterns I see are:
> >>
> >>   iov_iter_get_pages()
> >>
> >> 	IO(sync)
> >>
> >>   for(numpages)
> >> 	put_page()
> >>
> >> Or
> >>
> >>   iov_iter_get_pages()
> >>
> >> 	IO (async)
> >> 		->	foo_end_io()
> >> 				put_page
> >>
> >> (Same with get_user_pages)
> >> (IO need not be block layer. It can be networking and so on like in NFS or CIFS
> >>  and so on)
> > 
> > They are also other code that pass around bio_vec and the code that
> > fill it is disconnected from the code that release the page and they
> > can mix and match GUP and non GUP AFAICT.
> > 
> > On fs side they are also code that fill either bio or bio_vec and
> > use some extra mechanism other than bio_end to submit io through
> > workqueue and then release pages (cifs for instance). Again i believe
> > they can mix and match GUP and non GUP (i have not spotted something
> > obvious indicating otherwise).
> > 
> 
> But what I meant is why do we care at all? block layer does not inc page nor put
> page in any of bio or bio_vec. It is agnostic to the page-refs.
> 
> Users register an end_io and know if pages are getted or not.
> So the balanced put is up to the user.
> 
> >>
> >> The first pattern is easy just add the proper new api for
> >> it, so for every iov_iter_get_pages() you have an iov_iter_put_pages() and remove
> >> lots of cooked up for loops. Also the all iov_iter_get_pages_use_gup() just drops.
> >> (Same at get_user_pages sites use put_user_pages)
> > 
> > Yes this patchset already convert some of this first pattern.
> > 
> 
> Right!
> 
> >> The second pattern is a bit harder because it is possible that the foo_end_io()
> >> is currently used for GUP as well as none-GUP cases. this is easy to fix. But the
> >> even harder case is if the same foo_end_io() call has some pages GUPed and some not
> >> in the same call.
> >>
> >> staring at this patchset and the call sites I did not see any such places. Do you know
> >> of any?
> >> (We can always force such mixed-case users to always GUP-ref the pages and code
> >>  foo_end_io() to GUP-dec)
> > 
> > I believe direct-io.c is such example thought in that case i believe it
> > can only be the ZERO_PAGE so this might easily detectable. They are also
> > lot of fs functions taking an iterator and then using iov_iter_get_pages*()
> > to fill a bio. AFAICT those functions can be call with pipe iterator or
> > iovec iterator and probably also with other iterator type. But it is all
> > common code afterward (the bi_end_io function is the same no matter the
> > iterator).
> > 
> > Thought that can probably be solve that way:
> > 
> > From:
> >     foo_bi_end_io(struct bio *bio) {
> >         ...
> >         for (i = 0; i < npages; ++i) {
> >             put_page(pages[i]);
> >         }
> >     }
> > 
> > To:
> >     foo_bi_end_io_common(struct bio *bio) {
> >         ...
> >     }
> > 
> >     foo_bi_end_io_normal(struct bio *bio)
> >         foo_bi_end_io_common(bio);
> >         for (i = 0; i < npages; ++i) {
> >             put_page(pages[i]);
> >         }
> >     }
> > 
> >     foo_bi_end_io_gup(struct bio *bio)
> >         foo_bi_end_io_common(bio);
> >         for (i = 0; i < npages; ++i) {
> >             put_user_page(pages[i]);
> >         }
> >     }
> > 
> 
> Yes or when foo_bi_end_io_common is more complicated, then just make it
> 
>      foo_bi_end_io_common(struct bio *bio, bool gup) {
>          ...
>      }
> 
>      foo_bi_end_io_normal(struct bio *bio)
> 	foo_bi_end_io_common(bio, false);
>      }
>  
>      foo_bi_end_io_gup(struct bio *bio)
> 	foo_bi_end_io_common(bio, true);
>      }
> 
> Less risky coding of code we do not know?

Yes whatever is more appropriate for eahc end_io func.

> 
> > Then when filling in the bio i either pick foo_bi_end_io_normal() or
> > foo_bi_end_io_gup(). I am assuming that bio with different bi_end_io
> > function never get merge.
> > 
> 
> Exactly
> 
> > The issue is that some bio_add_page*() call site are disconnected
> > from where the bio is allocated and initialized (and also where the
> > bi_end_io function is set). This make it quite hard to ascertain
> > that GUPed page and non GUP page can not co-exist in same bio.
> > 
> 
> Two questions if they always do a put_page at end IO. Who takes a page_ref
> in the not GUP case? page-cache? VFS? a mechanical get_page?

It depends, some get page to page-cache (find_get_page), other just
get_page on a page that is coming from unknown origin (ie it is not
clear from within the function where the page is coming from), other
allocate a page and transfer the page reference to the bio ie the
page will get free once the bio end function is call through as it
call call put_page on page within the bio.

So there is not one simple story here. Hence why it looks harder to
me (still likely do-able).

> > Also in some cases it is not clear that the same iter is use to
> > fill the same bio ie it might be possible that some code path fill
> > the same bio from different iterator (and thus some pages might
> > be coming from GUP and other not).
> > 
> 
> This one is hard to believe for me. 
> one iter may produce multiple iter_get_pages() and many more bios.
> But the opposite?
> 
> I know, never say never. Do you know of a specific example?
> I would like to stare at it.

No i do not know of any such example but reading through a lot of code
i could not convince myself of that fact. I agree with your feeling on
the matter i just don't have proof. I can spend more time digging all
code path and ascertaining thing but this will inevitably be a snapshot
in time and something that people might break in the future.

> 
> > It would certainly seems to require more careful review from the
> > maintainers of such fs. I tend to believe that putting the burden
> > on the reviewer is a harder sell :)
> > 
> 
> I think a couple carefully put WARN_ONs in the PUT path can
> detect any leakage of refs. And help debug these cases.

Yes we do plan on catching things like underflow (easy one to catch)
or put_page that bring the refcount just below the bias value ... and
in anycase the only harm that can come of this should be memory leak.

So i believe that even if we miss some weird corner case we should be
able to catch it eventualy and nothing harmful should ever happen,
famous last word i will regret when i get burnt at the stake for missing
that one case ;)

> 
> > From quick glance:
> >    - nilfs segment thing
> >    - direct-io same bio accumulate pages over multiple call but
> >      it should always be from same iterator and thus either always
> >      be from GUP or non GUP. Also the ZERO_PAGE case should be easy
> >      to catch.
> 
> Yes. Or we can always take a GUP-ref on the ZERO_PAGE as well
> 
> >    - fs/nfs/blocklayout/blocklayout.c
> 
> This one is an example of "please do not touch" if you look at the code
> it currently does not do any put page at all. Though yes it does bio_add_page.
> 
> The pages are GETed and PUTed in nfs/direct.c and reference are balanced there.
> 
> this is the trivial case of for every iov_iter_get_pages[_alloc]() there is
> a new defined iov_iter_put_pages[_alloc]()
> 
> So this is an example of extra not needed code changes in your approach
> 
> >    - gfs2 log buffer, that should never be page from GUP but i could
> >      not ascertain that easily from quick review
> 
> 	Same as NFS maybe? didn't look.
> 
> > 
> > This is not extensive, i was just grepping for bio_add_page() and
> > they are 2 other variant to check and i tended to discard places
> > where bio is allocated in same function as bio_add_page() but this
> > might not be a valid assumption either. Some bio might be allocated
> > and only if there is no default bio already and then set as default
> > bio which might be use latter on with different iterator.
> > 
> 
> I think we do not care at all about any of the bio_add_page() or bio_alloc
> places. All we care about is the call to iov_iter_get_pages* and where in the
> code these puts are balanced.
> 
> If we need to split the endio case at those sights then we can do as above.
> Or in the worse case when pages are really mixed. Always take a GUP  ref also
> on the not GUP case. 
> (I would like to see where this happens)
> 
> >>
> >> So with a very careful coding I think you need not touch the block / scatter-list layers
> >> nor any LLD drivers. The only code affected is the code around the get_user_pages and friends.
> >> Changing the API will surface all those.
> >> (IE. introduce a new API, convert one by one, Remove old API)
> >>
> >> Am I smoking?
> > 
> > No, i thought about it seemed more dangerous and harder to get right
> > because some code add page in one place and setup bio in another. I
> > can dig some more on that front but this still leave the non-bio user
> > of bio_vec and those IIRC also suffer from same disconnect issue.
> > 
> 
> Again I should not care about bio_vec. I only need to trace the balancing of the
> ref taken in GUP call sight. Let me help you in those places it is not obvious to
> you.
> 
> >>
> >> BTW: Are you aware of the users of iov_iter_get_pages_alloc() Do they need fixing too?
> > 
> > Yeah and that patchset should address those already, i do not think
> > i missed any.
> > 
> 
> I could not find a patch for nfs/direct.c where a put_page is called
> to balance the iov_iter_get_pages_alloc(). Which takes care of for example of
> the blocklayout.c pages state
> 
> So I think the deep Audit needs to be for iov_iter_get_pages and get_user_pages
> and the balancing of that. And the all of bio_alloc and bio_add_page should stay
> agnostic to any pege-refs taking/putting

Will try to get started on that and see if i hit any roadblock. I will
report once i get my feet wet, or at least before i drown ;)

Cheers,
Jérôme

