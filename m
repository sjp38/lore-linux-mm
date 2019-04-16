Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6E8D5C10F13
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 16:54:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2AA582064A
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 16:54:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="XiH4TXKw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2AA582064A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B2DE06B000E; Tue, 16 Apr 2019 12:54:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AB5956B0010; Tue, 16 Apr 2019 12:54:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 956156B0266; Tue, 16 Apr 2019 12:54:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id 63C846B000E
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 12:54:34 -0400 (EDT)
Received: by mail-oi1-f199.google.com with SMTP id t66so10294454oie.3
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 09:54:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=RmInYsyxg8h8urKtwZH3h+zL0n8LmC+ntY2NSp6Dtek=;
        b=ulfcpzTjv+Mbg5uxWNha88+huwVEyy0JLBKBRESYCWeS2YsLBVqADc2OzXGc0AhcAn
         QxUNBWQaj0Yj+4HWuvlSv4oVBCSDwf6M17LPO0cQOoCoNcrqmo1UhdTB6KOXph6S4JJA
         CH5d92ekAWZl6ZRrKMJzjpAN8nDR6T7dy0nsy0TtQ0No3pFZx9+W4xSBcOz/YviYWKYZ
         eddHpXnVdJnOIE0Yvuo9ruNKzEyCvvApsOA4fRNAHLmbGXNZiei0Gsl7rqx4kC+7GKTk
         yuuV0dIA5YCSwnaFmbze3+8tPamcntxvmcuhnv0QVY8GtQILZTl1VeGYzhFwVY40Y9K2
         x05Q==
X-Gm-Message-State: APjAAAVnEROzxMrjVjCUjV2zoUPVrCPAqtR9wDZOAGtuviyDrhNqE1xQ
	9Gdb14Q8h6K7Q4D02Jo0LwqClBPttg4JJvlPDQ2K2jD6Lfi2o5a3/nCJ6ZMpWVqIaNYI1A+j+n+
	/wyJb1LZy0kK2zJD4+dXQaA9t1S+JJ4UEh4USKX+ajZ9wQ6v2TI6s+9kpX0ufUKQ/oA==
X-Received: by 2002:aca:305:: with SMTP id 5mr22352924oid.117.1555433673843;
        Tue, 16 Apr 2019 09:54:33 -0700 (PDT)
X-Received: by 2002:aca:305:: with SMTP id 5mr22352889oid.117.1555433673129;
        Tue, 16 Apr 2019 09:54:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555433673; cv=none;
        d=google.com; s=arc-20160816;
        b=aubhXnFlRCGE52PuvkFie40AbUCt+FnkggpjSJZdjHWSc94Oz27rI7R58x+E+ixIik
         VycwMUyR1eyqgnw/5HxkoDbxrAnlrc4KM3KdR43a9iNKKI4YnROm56TOJs4GpSUSc97a
         Y9C6R5fGBy0wEIloALtY5UkCrQkYt0NqIkpRB6doTS+4LoIaQLxiUFrFwB9j21ZEsHQC
         dK5pJKO2XsqRtsrbPZi0CVUWmwIdtw6b4sStWUEXwe6kEfHltJStrWviKwZaJMZ/z5BW
         bTrz+XnOq57o8uWtaV9J5Ypi93vIxjmx/29l4/sEnwTeGAnik0YwsEk3akLJC6rL6oFX
         rwGA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=RmInYsyxg8h8urKtwZH3h+zL0n8LmC+ntY2NSp6Dtek=;
        b=J+szY2NiNnpVjk4S9xQ1XObkuF/4W/z+3QgKdCtpESKPxMW8tnubgHlAodh+zxFJOy
         xBZSij8fEhq8ExXVpUKyAD0Qw2hvOBAf/glZS1Nu9l/CD/8xW3CaoSCSbpOVe+LecfAO
         b+pxvMTuufpp11uf3WuqhQcq2oUgq66eXbOpUQWGa83nYj/WILrAF9s1jhTGb3tjhkmI
         9sppSY9FhZaELdiXRJvDQ7VJMrKd8RCqQxIDWsw6hh/ou2n10LhGbuEKmHYKSZWKavFz
         VpQtfkvLKNJonfzUbMQLNmSl1a7dnF3rIvVpoNcBy5+6aAN4luJBmENu6ZUmowomRz1b
         fePg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=XiH4TXKw;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r26sor29704805otp.74.2019.04.16.09.54.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 16 Apr 2019 09:54:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=XiH4TXKw;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=RmInYsyxg8h8urKtwZH3h+zL0n8LmC+ntY2NSp6Dtek=;
        b=XiH4TXKweOK5bQggdBSYG9PkGQsUrb38HXopZ3q1Zl7LpL8Vz9Am56vHXzLor2YfKP
         d14NNntOBV+VeVjSAyF7hbvZnd4oyIfVP1AJMrea5qkoZ8uzRMhlT9UsIHy8OAGMevnY
         jSG5bngwU/T99ckfh8BuBGBROqMO9DxVs1mUCejwOsI8x65k1rEoGTy54jsdt+Hpw7zs
         sB/e+fJqf5dOb/NwXIlj2HpsMGHv02xjxrh0Hm839/S3kkAoTI7a6P5EQ2CdGLlSY9pT
         h0KWnNIOm1/qHRUjHlO2gB0Phh6JAIJf29DfB2+tDk/pgc3Cy1/uYLZbTaGeLhruGElW
         GSdw==
X-Google-Smtp-Source: APXvYqzWeVXyo4E/ADEgG/n8nh9jCa0D7rEf+XyIlDFgyh9V4nSnJF66u+zrGNhC1DjMnV5te459OBss3QYmtr670ew=
X-Received: by 2002:a9d:5c86:: with SMTP id a6mr49835114oti.118.1555433672859;
 Tue, 16 Apr 2019 09:54:32 -0700 (PDT)
MIME-Version: 1.0
References: <20190411210834.4105-1-jglisse@redhat.com> <20190411210834.4105-11-jglisse@redhat.com>
 <20190415145952.GE13684@quack2.suse.cz> <20190415152433.GB3436@redhat.com> <20190416164658.GB17148@quack2.suse.cz>
In-Reply-To: <20190416164658.GB17148@quack2.suse.cz>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 16 Apr 2019 09:54:21 -0700
Message-ID: <CAPcyv4iKVEty4MHt+fi3Mt5qp526vVOD1Xji=wXep_KLTZ0E8A@mail.gmail.com>
Subject: Re: [PATCH v1 10/15] block: add gup flag to bio_add_page()/bio_add_pc_page()/__bio_add_page()
To: Jan Kara <jack@suse.cz>
Cc: Jerome Glisse <jglisse@redhat.com>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, 
	linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-block@vger.kernel.org, 
	Linux MM <linux-mm@kvack.org>, John Hubbard <jhubbard@nvidia.com>, 
	Alexander Viro <viro@zeniv.linux.org.uk>, Johannes Thumshirn <jthumshirn@suse.de>, 
	Christoph Hellwig <hch@lst.de>, Jens Axboe <axboe@kernel.dk>, Ming Lei <ming.lei@redhat.com>, 
	Dave Chinner <david@fromorbit.com>, Jason Gunthorpe <jgg@ziepe.ca>, Matthew Wilcox <willy@infradead.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 16, 2019 at 9:47 AM Jan Kara <jack@suse.cz> wrote:
>
> On Mon 15-04-19 11:24:33, Jerome Glisse wrote:
> > On Mon, Apr 15, 2019 at 04:59:52PM +0200, Jan Kara wrote:
> > > Hi Jerome!
> > >
> > > On Thu 11-04-19 17:08:29, jglisse@redhat.com wrote:
> > > > From: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> > > >
> > > > We want to keep track of how we got a reference on page added to bi=
o_vec
> > > > ie wether the page was reference through GUP (get_user_page*) or no=
t. So
> > > > add a flag to bio_add_page()/bio_add_pc_page()/__bio_add_page() to =
that
> > > > effect.
> > >
> > > Thanks for writing this patch set! Looking through patches like this =
one,
> > > I'm a bit concerned. With so many bio_add_page() callers it's difficu=
lt to
> > > get things right and not regress in the future. I'm wondering whether=
 the
> > > things won't be less error-prone if we required that all page referen=
ce
> > > from bio are gup-like (not necessarily taken by GUP, if creator of th=
e bio
> > > gets to struct page he needs via some other means (e.g. page cache lo=
okup),
> > > he could just use get_gup_pin() helper we'd provide).  After all, a p=
age
> > > reference in bio means that the page is pinned for the duration of IO=
 and
> > > can be DMAed to/from so it even makes some sense to track the referen=
ce
> > > like that. Then bio_put() would just unconditionally do put_user_page=
() and
> > > we won't have to propagate the information in the bio.
> > >
> > > Do you think this would be workable and easier?
> >
> > It might be workable but i am not sure it is any simpler. bio_add_page*=
()
> > does not take page reference it is up to the caller to take the proper
> > page reference so the complexity would be push there (just in a differe=
nt
> > place) so i don't think it would be any simpler. This means that we wou=
ld
> > have to update more code than this patchset does.
>
> I agree that the amount of work in this patch set is about the same
> (although you don't have to pass the information about reference type in
> the biovec so you save the complexities there). But for the future the
> rule that "bio references must be gup-pins" is IMO easier to grasp for
> developers and you can reasonably assert it in bio_add_page().
>
> > This present patch is just a coccinelle semantic patch and even if it
> > is scary to see that many call site, they are not that many that need
> > to worry about the GUP parameter and they all are in patch 11, 12, 13
> > and 14.
> >
> > So i believe this patchset is simpler than converting everyone to take
> > a GUP like page reference. Also doing so means we loose the information
> > about GUP kind of defeat the purpose. So i believe it would be better
> > to limit special reference to GUP only pages.
>
> So what's the difference whether the page reference has been acquired via
> GUP or via some other means? I don't think that really matters. If say
> infiniband introduced new ioctl() that takes file descriptor, offset, and
> length and just takes pages from page cache and attaches them to their RD=
MA
> scatter-gather lists, then they'd need to use 'pin' references anyway...
>
> Then why do we work on differentiating between GUP pins and other page
> references?  Because it matters what the reference is going to be used fo=
r
> and what is it's lifetime. And generally GUP references are used to do IO
> to/from page and may even be controlled by userspace so that's why we nee=
d
> to make them different. But in principle the 'gup-pin' reference is not a=
bout
> the fact that the reference has been obtained from GUP but about the fact
> that it is used to do IO. Hence I think that the rule "bio references mus=
t
> be gup-pins" makes some sense.

+1 to this idea. I don't see the need to preserve the concept that
some biovecs carry non-GUP pages.

