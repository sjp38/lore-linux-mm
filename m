Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B270AC76194
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 06:02:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 82D4020856
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 06:02:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 82D4020856
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 297398E0036; Thu, 25 Jul 2019 02:02:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 247208E0031; Thu, 25 Jul 2019 02:02:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 136108E0036; Thu, 25 Jul 2019 02:02:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id E78228E0031
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 02:02:52 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id x1so41455971qkn.6
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 23:02:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to;
        bh=zOvrC4jRrz0ugoagicTAba2I/X1iVC+b4ZZraA+kmso=;
        b=bxGEUo9InYjicCAcT9UZYwOEMbrNJ7Xf8ykSSVfU0KWiqztZnZzppG6v+jKInFX7U4
         PZqOofy2vycmETZCMIX4Mht8xtzHVTrwY8DhHkR0xxJbvunh/I7inx47y082BY1E+Df8
         RaStS2QHrf2xqQ+QC9L0gTvStsmlXUDYO+bgbCLxrtei/mE7DFxE4kXRJ7EaqhFl03ee
         tT3LhbMn10AdC6gV+RNrmbK72ZAPhXz3GWrnXXhGgO2tEAzgUSueWYJptNhAQRGinPIZ
         IEbZxdLw9RaPBVKKZx3Cmnh9Xn0CLNvXPEv7K0p3r2mrQ4lzFpdhBWmVUyPTLKXTePKy
         39Lw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUYeHYOYmvBqluh1RgvO3yyE7Z4Y8UwwPfbQazo3ak/D+25a4zf
	FAe9GqEyuKEsKLAmaASgQ/TEEeYpuLNhbDwq+Qr4fv50AxMqd9f6Cr1ybu8farcs7qQNK+siyI1
	LAXk/jFdbXEmbASBOMzQ8PDTOVjsDeWiX6krT953Umnhrifh43WoqRZuTRsdF4QF/pw==
X-Received: by 2002:a0c:9e27:: with SMTP id p39mr61993066qve.151.1564034572717;
        Wed, 24 Jul 2019 23:02:52 -0700 (PDT)
X-Received: by 2002:a0c:9e27:: with SMTP id p39mr61993016qve.151.1564034572028;
        Wed, 24 Jul 2019 23:02:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564034572; cv=none;
        d=google.com; s=arc-20160816;
        b=mGNDakIMKyWtGylp1+pNjMAHG8CsQZLcU6e3Y/ae1nTm4g8O+1ilfSZNz0/ir1JDVx
         YqQA1g1uAPnDOysOLh5aLHpes3Ymw8qngF20bsRM9pdEgHAFHPtR7Y7wqVtI4xaN9YWX
         h8qAB+Czpjrx4yuGocBPZYCMP01eeH6q+i/3Gf7wfq7GU9Dv4tZUI/MqpuBnVvtRFBEr
         Iy7PI/uVanSW/6xgg+Q8jS+sjanencRx+4BBTZWBkMV259jjc8pfpmW38vctYX389KD3
         FnDPCwm50su9r+tO5d4OjA/aFgZYbE6DRGlwkp/kezwgUYvwRO/wqnJkEsbxDQ79hgoA
         p1ZA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date;
        bh=zOvrC4jRrz0ugoagicTAba2I/X1iVC+b4ZZraA+kmso=;
        b=LzGfC6uaytFBRNxGTymlMbij9KirHlODSdbbc7+iTV2/oC4X2E5lKXteHVwqjWnD3Z
         dHNp0HEsOe861j57ejpZ+n95uBN/DXeCFCIz9TwQB03UfOWLIusF+vyvIjKRcL3Ild0D
         NQlFdap+h/aMIUqbzjGJqnN3UYY8XTNWOua1pgvMzMNLQPuKoaoAow9yxvSVI7JqDyVW
         eyjd2n+fl9P0PIBLskKx42YYIJbBafItl/qTSPiureOlHhX2Hy9En5u3oS4mW3OrUXec
         nOlH88BGHtxk9DVTDVGgH1h9HEusRAoLk4yZTzn82iv59cmpHuNcACbHUZxJVZt2kY/G
         M+Iw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r1sor27783590qkd.39.2019.07.24.23.02.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 Jul 2019 23:02:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqwbxlaMB/Ups0MK5ym5+FoeShoFD8maMViZfmHscXpKdz4RszQUYRwaBR+eewotyh05tZCO4w==
X-Received: by 2002:a37:aa04:: with SMTP id t4mr57308995qke.359.1564034571775;
        Wed, 24 Jul 2019 23:02:51 -0700 (PDT)
Received: from redhat.com (bzq-79-181-91-42.red.bezeqint.net. [79.181.91.42])
        by smtp.gmail.com with ESMTPSA id i62sm22519634qke.52.2019.07.24.23.02.44
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 24 Jul 2019 23:02:50 -0700 (PDT)
Date: Thu, 25 Jul 2019 02:02:41 -0400
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: syzbot <syzbot+e58112d71f77113ddb7b@syzkaller.appspotmail.com>,
	aarcange@redhat.com, akpm@linux-foundation.org,
	christian@brauner.io, davem@davemloft.net, ebiederm@xmission.com,
	elena.reshetova@intel.com, guro@fb.com, hch@infradead.org,
	james.bottomley@hansenpartnership.com, jasowang@redhat.com,
	jglisse@redhat.com, keescook@chromium.org, ldv@altlinux.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, linux-parisc@vger.kernel.org,
	luto@amacapital.net, mhocko@suse.com, mingo@kernel.org,
	namit@vmware.com, peterz@infradead.org,
	syzkaller-bugs@googlegroups.com, viro@zeniv.linux.org.uk,
	wad@chromium.org
Subject: Re: WARNING in __mmdrop
Message-ID: <20190725015402-mutt-send-email-mst@kernel.org>
References: <0000000000008dd6bb058e006938@google.com>
 <000000000000964b0d058e1a0483@google.com>
 <20190721044615-mutt-send-email-mst@kernel.org>
 <20190722141152.GA13711@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190722141152.GA13711@ziepe.ca>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 22, 2019 at 11:11:52AM -0300, Jason Gunthorpe wrote:
> On Sun, Jul 21, 2019 at 06:02:52AM -0400, Michael S. Tsirkin wrote:
> > On Sat, Jul 20, 2019 at 03:08:00AM -0700, syzbot wrote:
> > > syzbot has bisected this bug to:
> > > 
> > > commit 7f466032dc9e5a61217f22ea34b2df932786bbfc
> > > Author: Jason Wang <jasowang@redhat.com>
> > > Date:   Fri May 24 08:12:18 2019 +0000
> > > 
> > >     vhost: access vq metadata through kernel virtual address
> > > 
> > > bisection log:  https://syzkaller.appspot.com/x/bisect.txt?x=149a8a20600000
> > > start commit:   6d21a41b Add linux-next specific files for 20190718
> > > git tree:       linux-next
> > > final crash:    https://syzkaller.appspot.com/x/report.txt?x=169a8a20600000
> > > console output: https://syzkaller.appspot.com/x/log.txt?x=129a8a20600000
> > > kernel config:  https://syzkaller.appspot.com/x/.config?x=3430a151e1452331
> > > dashboard link: https://syzkaller.appspot.com/bug?extid=e58112d71f77113ddb7b
> > > syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=10139e68600000
> > > 
> > > Reported-by: syzbot+e58112d71f77113ddb7b@syzkaller.appspotmail.com
> > > Fixes: 7f466032dc9e ("vhost: access vq metadata through kernel virtual
> > > address")
> > > 
> > > For information about bisection process see: https://goo.gl/tpsmEJ#bisection
> > 
> > 
> > OK I poked at this for a bit, I see several things that
> > we need to fix, though I'm not yet sure it's the reason for
> > the failures:
> 
> This stuff looks quite similar to the hmm_mirror use model and other
> places in the kernel. I'm still hoping we can share this code a bit more.

Right. I think hmm is something we should look at.

-- 
MST

