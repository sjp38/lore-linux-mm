Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8558CC10F14
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 01:11:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 22E7521773
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 01:11:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=plexistor-com.20150623.gappssmtp.com header.i=@plexistor-com.20150623.gappssmtp.com header.b="e5hIV8J8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 22E7521773
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=plexistor.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A533D6B0275; Tue, 16 Apr 2019 21:11:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A0E1D6B0276; Tue, 16 Apr 2019 21:11:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8A7596B0277; Tue, 16 Apr 2019 21:11:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 337926B0275
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 21:11:10 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id y7so20732324wrq.4
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 18:11:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:references:cc:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding;
        bh=BGUP3v1zeMiCF94PUwnDgJ0bSIrTJQdlCH/q5Y6P10g=;
        b=TNtugoUsAUwEvmar+Mt39Ill7abuzGfsEv1q2dlCRA/nncGebaynB9B5h0rJkwKsXP
         Lh3P6gyetIuY/Khk2OoaZ91x9EZu4ylb7Is2T8M+IP8OlBX1+4QPB04S4AYoxyanLfIy
         9CnvfhVEDpbhrBwhi+n0UPy92awwZEx1/NEuuqLFk48lwTgmB49n0VhmWHGeOjmh7K+n
         VEMTuUYpOncggYeXMR86PJIUfDmKF+BsXrlHxVoHML1swY9qmBrS+h1gtbH/KTxQNCLv
         IXwSdSzueNkDtw7Ey0Iaxe+tDaDDKIjW/ljhU4uYobTbVHz/mq2CNDo5w3q7qGiQnUIX
         Dnrw==
X-Gm-Message-State: APjAAAXAfMNxdZclyl3yURus7+2a3djju3iTKOdpU/Gf0NPZ7vaMGOyE
	W9+ucPi6bF4Ue9LO2m16O4rKHfFq8pNXX2cfu6I4k/UGl7zPVGJwd273l+YaVU4BGHgNSVN/eoC
	wXcQR0X9MIZSxcAIpJhYm/wfEahKMSoXGWR+vUc4qft0dCbO27tDGvez8gXC4In9WCw==
X-Received: by 2002:a7b:c4d5:: with SMTP id g21mr27901314wmk.133.1555463469543;
        Tue, 16 Apr 2019 18:11:09 -0700 (PDT)
X-Received: by 2002:a7b:c4d5:: with SMTP id g21mr27901276wmk.133.1555463468299;
        Tue, 16 Apr 2019 18:11:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555463468; cv=none;
        d=google.com; s=arc-20160816;
        b=TtmsKsIRoWCVWvu5fOLkaQkGIETET+svPAF7rXJFgT1LwrVQ2ZTdjgxJjRoYkFyka/
         yf/IaPjoeg7dwHqm1sUQt6RYDiXyrKqhjnR5uNjGB6PogmFiNhAGXHUVkhddfY4MHpyw
         lNyNYWdg2CnWqBxZ8CAmBqGTFUOQpx62+JpvAJixMXWWQkgiCDJO4EjmzaWgW5g+evfc
         xCZ+coimAzWRBnAkjMzGyeP0fInN3tA9RzGTG1mVtMYqvWTEjDF4mCEvvATbHJ2fcrSx
         qiRBhKzuKnuU2yF1N27n6Co+xsHBJ1hF3ceD//hSvNY8QVDU60ETPh0johhetufDyjTu
         dcoA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:in-reply-to:mime-version:user-agent:date
         :message-id:from:cc:references:to:subject:dkim-signature;
        bh=BGUP3v1zeMiCF94PUwnDgJ0bSIrTJQdlCH/q5Y6P10g=;
        b=InWtxuP2O40AICUbeaNpnIve6NnRjZfsxQlQxr4EnUYogTdyMTnIjmqSuEq1qIXxmb
         6CfTmti7BDVYXvtasi0rO2bS6Cb9nmm3Mrz78VleEY4c/Fy7ZQcmkp01WCb8fTJcGjlF
         ZP+eX1johZ7IqJ0Pw82l3YWkXwJCdF8RhTVPoG83jQ33cZHSdU0p5WV2toK1CF/OrGu9
         7rZfe02/KgUiCnUHi0tcAC17K+ELca9sM1aU4LZxVrueBNb2n+IzZ+NHMapDbFQG/KdU
         yPM/8BVr+8VrkNRU10cB02pyq6wyaZkVbcvlOx8PqgsxJVbw5kuPRasX67W/D585gpHU
         LqBw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@plexistor-com.20150623.gappssmtp.com header.s=20150623 header.b=e5hIV8J8;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of boaz@plexistor.com) smtp.mailfrom=boaz@plexistor.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x2sor664316wmh.7.2019.04.16.18.11.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 16 Apr 2019 18:11:08 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of boaz@plexistor.com) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@plexistor-com.20150623.gappssmtp.com header.s=20150623 header.b=e5hIV8J8;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of boaz@plexistor.com) smtp.mailfrom=boaz@plexistor.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=plexistor-com.20150623.gappssmtp.com; s=20150623;
        h=subject:to:references:cc:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-transfer-encoding;
        bh=BGUP3v1zeMiCF94PUwnDgJ0bSIrTJQdlCH/q5Y6P10g=;
        b=e5hIV8J8H2iq3G4hYujgaXiojPzufccjpwbYTDccLw483JPZF063ZFH6MFzICOn34F
         em6MiVdU81dKQyWaHpqhrEvbAm7Nb2UuNk8vFAqvbGWjJltXNzx4aHdAw1KrwYKphxn6
         8HJLhg4XGACPKQewvhjno3ioXVVAgMQAvkQpuH26EIcRXIvUo6LyAyMHoDx/Alb4G/ha
         /TXvnrhR8AtzQxjs1VMaN+KISn68KEJy9pVkzfZZeklUm45wyasoE3NgNO/scyOgm4ne
         37gL1oJFYYjDEl+9F0l6grzQxrDUVPLQnwneeoPT4+88dFIahO0X13T4VgINzjD0a08/
         psmg==
X-Google-Smtp-Source: APXvYqwr/G8I1kJey3GHf9Qlf2VTdnt0uGb+koJQNlCehCfFGl9Mi+uv+B3+vs9ay1a5nT8n69N0bA==
X-Received: by 2002:a1c:be0e:: with SMTP id o14mr28791456wmf.118.1555463467784;
        Tue, 16 Apr 2019 18:11:07 -0700 (PDT)
Received: from [10.0.0.5] (bzq-84-110-213-170.static-ip.bezeqint.net. [84.110.213.170])
        by smtp.googlemail.com with ESMTPSA id a4sm1713721wmf.45.2019.04.16.18.11.04
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Apr 2019 18:11:07 -0700 (PDT)
Subject: Re: [PATCH v1 00/15] Keep track of GUPed pages in fs and block
To: Jerome Glisse <jglisse@redhat.com>, Boaz Harrosh <openosd@gmail.com>
References: <20190411210834.4105-1-jglisse@redhat.com>
 <2c124cc4-b97e-ee28-2926-305bc6bc74bd@plexistor.com>
 <20190416185922.GA12818@kmo-pixel>
 <CAPcyv4jLrQ6evLAJzsASh=H6Tzx8E1oiF+YR3L2fOpbZYNUWGg@mail.gmail.com>
 <ccac6c5a-7120-0455-88de-ca321b01e825@plexistor.com>
 <20190416195735.GE21526@redhat.com>
 <41e2d7e1-104b-a006-2824-015ca8c76cc8@gmail.com>
 <20190416231655.GB22465@redhat.com>
Cc: Dan Williams <dan.j.williams@intel.com>,
 Kent Overstreet <kent.overstreet@gmail.com>,
 Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
 linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-block@vger.kernel.org,
 Linux MM <linux-mm@kvack.org>, John Hubbard <jhubbard@nvidia.com>,
 Jan Kara <jack@suse.cz>, Alexander Viro <viro@zeniv.linux.org.uk>,
 Johannes Thumshirn <jthumshirn@suse.de>, Christoph Hellwig <hch@lst.de>,
 Jens Axboe <axboe@kernel.dk>, Ming Lei <ming.lei@redhat.com>,
 Jason Gunthorpe <jgg@ziepe.ca>, Matthew Wilcox <willy@infradead.org>,
 Steve French <sfrench@samba.org>, linux-cifs@vger.kernel.org,
 Yan Zheng <zyan@redhat.com>, Sage Weil <sage@redhat.com>,
 Ilya Dryomov <idryomov@gmail.com>, Alex Elder <elder@kernel.org>,
 ceph-devel@vger.kernel.org, Eric Van Hensbergen <ericvh@gmail.com>,
 Latchesar Ionkov <lucho@ionkov.net>, Mike Marshall <hubcap@omnibond.com>,
 Martin Brandenburg <martin@omnibond.com>,
 Dominique Martinet <asmadeus@codewreck.org>,
 v9fs-developer@lists.sourceforge.net, Coly Li <colyli@suse.de>,
 linux-bcache@vger.kernel.org,
 =?UTF-8?Q?Ernesto_A._Fern=c3=a1ndez?= <ernesto.mnd.fernandez@gmail.com>
From: Boaz Harrosh <boaz@plexistor.com>
Message-ID: <fa00a2ff-3664-3165-7af8-9d9c53238245@plexistor.com>
Date: Wed, 17 Apr 2019 04:11:03 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:45.0) Gecko/20100101
 Thunderbird/45.4.0
MIME-Version: 1.0
In-Reply-To: <20190416231655.GB22465@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 17/04/19 02:16, Jerome Glisse wrote:
> On Wed, Apr 17, 2019 at 01:09:22AM +0300, Boaz Harrosh wrote:
>> On 16/04/19 22:57, Jerome Glisse wrote:
>> <>
>>>
>>> A very long thread on this:
>>>
>>> https://lkml.org/lkml/2018/12/3/1128
>>>
>>> especialy all the reply to this first one
>>>
>>> There is also:
>>>
>>> https://lkml.org/lkml/2019/3/26/1395
>>> https://lwn.net/Articles/753027/
>>>
>>
>> OK I have re-read this patchset and a little bit of the threads above (not all)
>>
>> As I understand the long term plan is to keep two separate ref-counts one
>> for GUP-ref and one for the regular page-state/ownership ref.
>> Currently looking at page-ref we do not know if we have a GUP currently held.
>> With the new plan we can (Still not sure what's the full plan with this new info)
>>
>> But if you make it such as the first GUP-ref also takes a page_ref and the
>> last GUp-dec also does put_page. Then the all of these becomes a matter of
>> matching every call to get_user_pages or iov_iter_get_pages() with a new
>> put_user_pages or iov_iter_put_pages().
>>
>> Then if much below us an LLD takes a get_page() say an skb below the iscsi
>> driver, and so on. We do not care and we keep doing a put_page because we know
>> the GUP-ref holds the page for us.
>>
>> The current block layer is transparent to any page-ref it does not take any
>> nor put_page any. It is only the higher users that have done GUP that take care of that.
>>
>> The patterns I see are:
>>
>>   iov_iter_get_pages()
>>
>> 	IO(sync)
>>
>>   for(numpages)
>> 	put_page()
>>
>> Or
>>
>>   iov_iter_get_pages()
>>
>> 	IO (async)
>> 		->	foo_end_io()
>> 				put_page
>>
>> (Same with get_user_pages)
>> (IO need not be block layer. It can be networking and so on like in NFS or CIFS
>>  and so on)
> 
> They are also other code that pass around bio_vec and the code that
> fill it is disconnected from the code that release the page and they
> can mix and match GUP and non GUP AFAICT.
> 
> On fs side they are also code that fill either bio or bio_vec and
> use some extra mechanism other than bio_end to submit io through
> workqueue and then release pages (cifs for instance). Again i believe
> they can mix and match GUP and non GUP (i have not spotted something
> obvious indicating otherwise).
> 

But what I meant is why do we care at all? block layer does not inc page nor put
page in any of bio or bio_vec. It is agnostic to the page-refs.

Users register an end_io and know if pages are getted or not.
So the balanced put is up to the user.

>>
>> The first pattern is easy just add the proper new api for
>> it, so for every iov_iter_get_pages() you have an iov_iter_put_pages() and remove
>> lots of cooked up for loops. Also the all iov_iter_get_pages_use_gup() just drops.
>> (Same at get_user_pages sites use put_user_pages)
> 
> Yes this patchset already convert some of this first pattern.
> 

Right!

>> The second pattern is a bit harder because it is possible that the foo_end_io()
>> is currently used for GUP as well as none-GUP cases. this is easy to fix. But the
>> even harder case is if the same foo_end_io() call has some pages GUPed and some not
>> in the same call.
>>
>> staring at this patchset and the call sites I did not see any such places. Do you know
>> of any?
>> (We can always force such mixed-case users to always GUP-ref the pages and code
>>  foo_end_io() to GUP-dec)
> 
> I believe direct-io.c is such example thought in that case i believe it
> can only be the ZERO_PAGE so this might easily detectable. They are also
> lot of fs functions taking an iterator and then using iov_iter_get_pages*()
> to fill a bio. AFAICT those functions can be call with pipe iterator or
> iovec iterator and probably also with other iterator type. But it is all
> common code afterward (the bi_end_io function is the same no matter the
> iterator).
> 
> Thought that can probably be solve that way:
> 
> From:
>     foo_bi_end_io(struct bio *bio) {
>         ...
>         for (i = 0; i < npages; ++i) {
>             put_page(pages[i]);
>         }
>     }
> 
> To:
>     foo_bi_end_io_common(struct bio *bio) {
>         ...
>     }
> 
>     foo_bi_end_io_normal(struct bio *bio)
>         foo_bi_end_io_common(bio);
>         for (i = 0; i < npages; ++i) {
>             put_page(pages[i]);
>         }
>     }
> 
>     foo_bi_end_io_gup(struct bio *bio)
>         foo_bi_end_io_common(bio);
>         for (i = 0; i < npages; ++i) {
>             put_user_page(pages[i]);
>         }
>     }
> 

Yes or when foo_bi_end_io_common is more complicated, then just make it

     foo_bi_end_io_common(struct bio *bio, bool gup) {
         ...
     }

     foo_bi_end_io_normal(struct bio *bio)
	foo_bi_end_io_common(bio, false);
     }
 
     foo_bi_end_io_gup(struct bio *bio)
	foo_bi_end_io_common(bio, true);
     }

Less risky coding of code we do not know?

> Then when filling in the bio i either pick foo_bi_end_io_normal() or
> foo_bi_end_io_gup(). I am assuming that bio with different bi_end_io
> function never get merge.
> 

Exactly

> The issue is that some bio_add_page*() call site are disconnected
> from where the bio is allocated and initialized (and also where the
> bi_end_io function is set). This make it quite hard to ascertain
> that GUPed page and non GUP page can not co-exist in same bio.
> 

Two questions if they always do a put_page at end IO. Who takes a page_ref
in the not GUP case? page-cache? VFS? a mechanical get_page?

> Also in some cases it is not clear that the same iter is use to
> fill the same bio ie it might be possible that some code path fill
> the same bio from different iterator (and thus some pages might
> be coming from GUP and other not).
> 

This one is hard to believe for me. 
one iter may produce multiple iter_get_pages() and many more bios.
But the opposite?

I know, never say never. Do you know of a specific example?
I would like to stare at it.

> It would certainly seems to require more careful review from the
> maintainers of such fs. I tend to believe that putting the burden
> on the reviewer is a harder sell :)
> 

I think a couple carefully put WARN_ONs in the PUT path can
detect any leakage of refs. And help debug these cases.

> From quick glance:
>    - nilfs segment thing
>    - direct-io same bio accumulate pages over multiple call but
>      it should always be from same iterator and thus either always
>      be from GUP or non GUP. Also the ZERO_PAGE case should be easy
>      to catch.

Yes. Or we can always take a GUP-ref on the ZERO_PAGE as well

>    - fs/nfs/blocklayout/blocklayout.c

This one is an example of "please do not touch" if you look at the code
it currently does not do any put page at all. Though yes it does bio_add_page.

The pages are GETed and PUTed in nfs/direct.c and reference are balanced there.

this is the trivial case of for every iov_iter_get_pages[_alloc]() there is
a new defined iov_iter_put_pages[_alloc]()

So this is an example of extra not needed code changes in your approach

>    - gfs2 log buffer, that should never be page from GUP but i could
>      not ascertain that easily from quick review

	Same as NFS maybe? didn't look.

> 
> This is not extensive, i was just grepping for bio_add_page() and
> they are 2 other variant to check and i tended to discard places
> where bio is allocated in same function as bio_add_page() but this
> might not be a valid assumption either. Some bio might be allocated
> and only if there is no default bio already and then set as default
> bio which might be use latter on with different iterator.
> 

I think we do not care at all about any of the bio_add_page() or bio_alloc
places. All we care about is the call to iov_iter_get_pages* and where in the
code these puts are balanced.

If we need to split the endio case at those sights then we can do as above.
Or in the worse case when pages are really mixed. Always take a GUP  ref also
on the not GUP case. 
(I would like to see where this happens)

>>
>> So with a very careful coding I think you need not touch the block / scatter-list layers
>> nor any LLD drivers. The only code affected is the code around the get_user_pages and friends.
>> Changing the API will surface all those.
>> (IE. introduce a new API, convert one by one, Remove old API)
>>
>> Am I smoking?
> 
> No, i thought about it seemed more dangerous and harder to get right
> because some code add page in one place and setup bio in another. I
> can dig some more on that front but this still leave the non-bio user
> of bio_vec and those IIRC also suffer from same disconnect issue.
> 

Again I should not care about bio_vec. I only need to trace the balancing of the
ref taken in GUP call sight. Let me help you in those places it is not obvious to
you.

>>
>> BTW: Are you aware of the users of iov_iter_get_pages_alloc() Do they need fixing too?
> 
> Yeah and that patchset should address those already, i do not think
> i missed any.
> 

I could not find a patch for nfs/direct.c where a put_page is called
to balance the iov_iter_get_pages_alloc(). Which takes care of for example of
the blocklayout.c pages state

So I think the deep Audit needs to be for iov_iter_get_pages and get_user_pages
and the balancing of that. And the all of bio_alloc and bio_add_page should stay
agnostic to any pege-refs taking/putting

> Cheers,
> Jérôme
> 

Lets talk in LSF, see things hands on

Thanks
Boaz

