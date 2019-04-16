Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3A859C10F14
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 23:17:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D984220868
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 23:17:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D984220868
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 68CEA6B0007; Tue, 16 Apr 2019 19:17:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 63B756B0008; Tue, 16 Apr 2019 19:17:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 502976B000A; Tue, 16 Apr 2019 19:17:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 30DB16B0007
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 19:17:10 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id y64so19334634qka.3
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 16:17:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=hksPwfxfzODxeRhL9dnodHFBASSzXwtuvbEo3QPLHaE=;
        b=hXQ/fbaEa3DiyrGCbrGLlVO1eF5icIfao8BplWB4xYpGLGNu22PjHZmT7zMYD/5i7S
         HB8jilCSRV28pswQu0/UBe90Uq2kkDYR1lUxjQfBBAqkbYXHfDJpCwfT2Snq58iZzDWG
         aIiU7gNEVF0Da4hxyrwUeMY4PageVGnRTt9SRMMAUbiLboTmsvzZTzxlojHqzY33zC/e
         Vkx3y9ilJSkA+xZk2dYXmme0cENm0TkroaWpAAPuUGXj00OHBm+0CovfEXe9y8fy9p4c
         hfc+XSaURqi7pATC6JGyxICPaT079PhWMIQJj3jNXNqwOYaPwtPDqmMu+hn5UkZGmL87
         Oe9g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWv5YhPexOtGOfjej3Kz+ZM4eL5eOfJTCn+0FesydKs2y4udeIV
	Ol5lT/HN6PMI8vcwu9Agq2by7MESjBh7cXxL2XW8y9d/m7bRZ3B6nYZDXaQBth6y1jRMq9hh0W+
	yCAEuazcIWfSRh4lziNJh/TWLvb8WLVoxTLmKfNM0R+94NtucgIjaLmejMxDFtRWaqg==
X-Received: by 2002:ae9:e515:: with SMTP id w21mr568115qkf.200.1555456629881;
        Tue, 16 Apr 2019 16:17:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyVIBpf8kTLXKgABi2PICpaTfojzn1xovrfx8voUOXnKO63UZetSVJri8cxZyoRdiAhkMSG
X-Received: by 2002:ae9:e515:: with SMTP id w21mr568025qkf.200.1555456628668;
        Tue, 16 Apr 2019 16:17:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555456628; cv=none;
        d=google.com; s=arc-20160816;
        b=HtrNwL9O2L0LTJ1+HPWOGqqheS8+l2yVLiN66S+pWhE8r4Z4cpdlBd7oELqspGliE7
         1xD5nKbASXHRCeCdNQQ+1Tm6qP8lyMKlcrW8M0jJvj5WklNkDyQSbdYv70IK0x/VkTSO
         ZGrhUdOk0AuXTGVKEw/nKvAxtDSzObEbJZ2joCk3OvFQphTRdC9YL7qIfxsmbEk6w56b
         PtBqW7iF0TLOPGVHmKqfASlfXCPHR1wmThbNiO0to+HPqwFWp97gYrk7gS3m4uxZdFET
         igT/CRohfGMgp6lJuIg1w48iCT/a7x956mu5Q1o3lubGs5wkXrfQJfbHTzRC1hWwt4cP
         lWZQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=hksPwfxfzODxeRhL9dnodHFBASSzXwtuvbEo3QPLHaE=;
        b=RK+B2ib8PHCwMWkIZdnujIiCuwunSuKPn6asz9dFSaPPCp5LT1JdfYAfDmOLVgJ5/Y
         gINoGL5QYDNYC2weJxdm2cAOT2MY/dKd4Eh9THH6dqEnbc/H1rFjfKpuJlbuPwIoj26z
         gnvfieKJdUMXYPEEwklvVjzd9+7gbRb9rdntLpHc24tmOofTR364i0qzj/3pEs/PfTlN
         qZgQeH/391625XlsfjSxBLFFevEDRdq8QXscNkReE+n3dMecmMrZN2lIZDO1N5Tm1Kz5
         5ItDbwjwtBec00WwdNrhxVDsOUZ2yt9orEJ/gSGQfPo7YhAa7tC5Us2MeqRH90HxjFeS
         HqGA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q16si6942134qtb.313.2019.04.16.16.17.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Apr 2019 16:17:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 218B93199363;
	Tue, 16 Apr 2019 23:17:07 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id AF2FB5C1B5;
	Tue, 16 Apr 2019 23:16:57 +0000 (UTC)
Date: Tue, 16 Apr 2019 19:16:56 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: Boaz Harrosh <openosd@gmail.com>
Cc: Boaz Harrosh <boaz@plexistor.com>,
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
Message-ID: <20190416231655.GB22465@redhat.com>
References: <20190411210834.4105-1-jglisse@redhat.com>
 <2c124cc4-b97e-ee28-2926-305bc6bc74bd@plexistor.com>
 <20190416185922.GA12818@kmo-pixel>
 <CAPcyv4jLrQ6evLAJzsASh=H6Tzx8E1oiF+YR3L2fOpbZYNUWGg@mail.gmail.com>
 <ccac6c5a-7120-0455-88de-ca321b01e825@plexistor.com>
 <20190416195735.GE21526@redhat.com>
 <41e2d7e1-104b-a006-2824-015ca8c76cc8@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <41e2d7e1-104b-a006-2824-015ca8c76cc8@gmail.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.41]); Tue, 16 Apr 2019 23:17:07 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 17, 2019 at 01:09:22AM +0300, Boaz Harrosh wrote:
> On 16/04/19 22:57, Jerome Glisse wrote:
> <>
> > 
> > A very long thread on this:
> > 
> > https://lkml.org/lkml/2018/12/3/1128
> > 
> > especialy all the reply to this first one
> > 
> > There is also:
> > 
> > https://lkml.org/lkml/2019/3/26/1395
> > https://lwn.net/Articles/753027/
> > 
> 
> OK I have re-read this patchset and a little bit of the threads above (not all)
> 
> As I understand the long term plan is to keep two separate ref-counts one
> for GUP-ref and one for the regular page-state/ownership ref.
> Currently looking at page-ref we do not know if we have a GUP currently held.
> With the new plan we can (Still not sure what's the full plan with this new info)
> 
> But if you make it such as the first GUP-ref also takes a page_ref and the
> last GUp-dec also does put_page. Then the all of these becomes a matter of
> matching every call to get_user_pages or iov_iter_get_pages() with a new
> put_user_pages or iov_iter_put_pages().
> 
> Then if much below us an LLD takes a get_page() say an skb below the iscsi
> driver, and so on. We do not care and we keep doing a put_page because we know
> the GUP-ref holds the page for us.
> 
> The current block layer is transparent to any page-ref it does not take any
> nor put_page any. It is only the higher users that have done GUP that take care of that.
> 
> The patterns I see are:
> 
>   iov_iter_get_pages()
> 
> 	IO(sync)
> 
>   for(numpages)
> 	put_page()
> 
> Or
> 
>   iov_iter_get_pages()
> 
> 	IO (async)
> 		->	foo_end_io()
> 				put_page
> 
> (Same with get_user_pages)
> (IO need not be block layer. It can be networking and so on like in NFS or CIFS
>  and so on)

They are also other code that pass around bio_vec and the code that
fill it is disconnected from the code that release the page and they
can mix and match GUP and non GUP AFAICT.

On fs side they are also code that fill either bio or bio_vec and
use some extra mechanism other than bio_end to submit io through
workqueue and then release pages (cifs for instance). Again i believe
they can mix and match GUP and non GUP (i have not spotted something
obvious indicating otherwise).

> 
> The first pattern is easy just add the proper new api for
> it, so for every iov_iter_get_pages() you have an iov_iter_put_pages() and remove
> lots of cooked up for loops. Also the all iov_iter_get_pages_use_gup() just drops.
> (Same at get_user_pages sites use put_user_pages)

Yes this patchset already convert some of this first pattern.

> The second pattern is a bit harder because it is possible that the foo_end_io()
> is currently used for GUP as well as none-GUP cases. this is easy to fix. But the
> even harder case is if the same foo_end_io() call has some pages GUPed and some not
> in the same call.
> 
> staring at this patchset and the call sites I did not see any such places. Do you know
> of any?
> (We can always force such mixed-case users to always GUP-ref the pages and code
>  foo_end_io() to GUP-dec)

I believe direct-io.c is such example thought in that case i believe it
can only be the ZERO_PAGE so this might easily detectable. They are also
lot of fs functions taking an iterator and then using iov_iter_get_pages*()
to fill a bio. AFAICT those functions can be call with pipe iterator or
iovec iterator and probably also with other iterator type. But it is all
common code afterward (the bi_end_io function is the same no matter the
iterator).

Thought that can probably be solve that way:

From:
    foo_bi_end_io(struct bio *bio) {
        ...
        for (i = 0; i < npages; ++i) {
            put_page(pages[i]);
        }
    }

To:
    foo_bi_end_io_common(struct bio *bio) {
        ...
    }

    foo_bi_end_io_normal(struct bio *bio)
        foo_bi_end_io_common(bio);
        for (i = 0; i < npages; ++i) {
            put_page(pages[i]);
        }
    }

    foo_bi_end_io_gup(struct bio *bio)
        foo_bi_end_io_common(bio);
        for (i = 0; i < npages; ++i) {
            put_user_page(pages[i]);
        }
    }

Then when filling in the bio i either pick foo_bi_end_io_normal() or
foo_bi_end_io_gup(). I am assuming that bio with different bi_end_io
function never get merge.

The issue is that some bio_add_page*() call site are disconnected
from where the bio is allocated and initialized (and also where the
bi_end_io function is set). This make it quite hard to ascertain
that GUPed page and non GUP page can not co-exist in same bio.

Also in some cases it is not clear that the same iter is use to
fill the same bio ie it might be possible that some code path fill
the same bio from different iterator (and thus some pages might
be coming from GUP and other not).

It would certainly seems to require more careful review from the
maintainers of such fs. I tend to believe that putting the burden
on the reviewer is a harder sell :)

From quick glance:
   - nilfs segment thing
   - direct-io same bio accumulate pages over multiple call but
     it should always be from same iterator and thus either always
     be from GUP or non GUP. Also the ZERO_PAGE case should be easy
     to catch.
   - fs/nfs/blocklayout/blocklayout.c
   - gfs2 log buffer, that should never be page from GUP but i could
     not ascertain that easily from quick review

This is not extensive, i was just grepping for bio_add_page() and
they are 2 other variant to check and i tended to discard places
where bio is allocated in same function as bio_add_page() but this
might not be a valid assumption either. Some bio might be allocated
and only if there is no default bio already and then set as default
bio which might be use latter on with different iterator.

> 
> So with a very careful coding I think you need not touch the block / scatter-list layers
> nor any LLD drivers. The only code affected is the code around the get_user_pages and friends.
> Changing the API will surface all those.
> (IE. introduce a new API, convert one by one, Remove old API)
> 
> Am I smoking?

No, i thought about it seemed more dangerous and harder to get right
because some code add page in one place and setup bio in another. I
can dig some more on that front but this still leave the non-bio user
of bio_vec and those IIRC also suffer from same disconnect issue.

> 
> BTW: Are you aware of the users of iov_iter_get_pages_alloc() Do they need fixing too?

Yeah and that patchset should address those already, i do not think
i missed any.

Cheers,
Jérôme

