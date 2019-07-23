Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 64726C76188
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 05:02:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 22EB22239E
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 05:02:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 22EB22239E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A21936B0005; Tue, 23 Jul 2019 01:02:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9D1A48E0003; Tue, 23 Jul 2019 01:02:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8C2FC8E0001; Tue, 23 Jul 2019 01:02:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 429626B0005
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 01:02:46 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id f9so20180876wrq.14
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 22:02:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to;
        bh=JYPoJkQN+XK2UvnSjwNQRenJIQ2ixkhyrsqP4Uhz9H8=;
        b=Op4rj2OnPeG5SjnrAmNEQmMJeFBhihKM6iuXl93nosseiA2tq4+zbUlkzeymXQW2De
         WXPkU4ekHg6+xd7Wlx7sEdi92Y41rZEyODWJNG7GmKU1fvQ1ylh3LqG++gtZZrOTCtPH
         BsLRiFc39ojCnu4ne84dEaZCFIAqD+Fn7oF0wOvUsYVsPA++PKshFirJIjx70Wtpgvhl
         AJ0qBVcbqYVum80n44dNDdvkCtAExLuFm2NNTDQqMYhuZE3MQKxHldIoHY4bQkn3kHdN
         3iT43TYoH+VBPh3PuboiW1/KTwrt7mPbncH6hgw4ylaOoLTJAT7KuzGgCoaPF3ep3ayW
         ElHg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWsSGSiI/D9a6tiSqyD5rYcKNm0wq05JCBIpJE6uMyAsxtm6Lrt
	lzFdkD4mSlJD9lnVXZeW8p3x0QopK6YB/jHXFYDtxG/X3E+1KRtLDaX7hLA0CyhENeCClHFLPtK
	K+UbGjvqVBi8XXUZiWEOULnJ1GGquNdAGT2Kn6XU6s1lQC+iw9W5Tpc8vywzIzzuSLA==
X-Received: by 2002:a1c:6454:: with SMTP id y81mr41507689wmb.105.1563858165783;
        Mon, 22 Jul 2019 22:02:45 -0700 (PDT)
X-Received: by 2002:a1c:6454:: with SMTP id y81mr41507649wmb.105.1563858164968;
        Mon, 22 Jul 2019 22:02:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563858164; cv=none;
        d=google.com; s=arc-20160816;
        b=vqaKvuBgirM9yEWik/xgiJPzZaorSdfv+JHvXQmnRTF3THPdPZcJm2cwWnvU86RP0a
         f4s1A7T/95/dkahp36i5IIJ8O+WF247xn/A7F37xI6TYDDVSqI2vkF1MI62Q9puzrBnk
         XJbSmE77KAAmxArKoXjDhq34MKvgZRNYrsPTimkeLVcCtaz5vHIIkSU6FC+ISPCNYM/R
         FX9gAWwkZLCQMtijUPsUqRxUmpUDQg572qz+voeS5Hd7DDrHvJzQABfqRXuS97VBzp9H
         3ivN4Ii5QzFG1n7C+nwC+IGUUBIuCuwpNbvKbig13nGBp5walLZ3dnTp1LgQxyE+V1GL
         n9rw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-transfer-encoding:content-disposition
         :mime-version:references:message-id:subject:cc:to:from:date;
        bh=JYPoJkQN+XK2UvnSjwNQRenJIQ2ixkhyrsqP4Uhz9H8=;
        b=j3mTOFqf9RmE0cBRGZnEI0rdHC7xunT/A3fDIKSTU7DZeaf+PlX/Fmcuglk5ycel2I
         QoIQLDMedSndmmgftkI4IbdY96edcLCMgpQng6jzOAzdN4a1LiTUnCWPDV/Mw1kYOgzR
         TseZsaUWSNDLaI06rg/IlHNDScmHpqhuYr3D7yKLG3Yr+qeC/kIeI0ld44ATUiJx+c19
         3TaqIGmwMe601/WhRHZB5tXmxBXXIQatEaoHIioRQESKHNSb+bkUPFRGlO4byGZhPxlZ
         Qvwrjmq0XrzzfMk3FtzefG3taOvum/wSJXgYF2BZY5h7dkeMwsmEFjy2AinojsSoOF7g
         3hiw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i5sor30062605wrv.4.2019.07.22.22.02.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 22 Jul 2019 22:02:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqyEMTuVBH8zniGTqgl57BX2DcyhG+Wl2kks7XclSYkMvxpBTbWB4yptqSSR2n2cmwFVsaFFzw==
X-Received: by 2002:a5d:67cd:: with SMTP id n13mr4657765wrw.138.1563858164654;
        Mon, 22 Jul 2019 22:02:44 -0700 (PDT)
Received: from redhat.com (bzq-79-181-91-42.red.bezeqint.net. [79.181.91.42])
        by smtp.gmail.com with ESMTPSA id j10sm70533109wrd.26.2019.07.22.22.02.41
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 22 Jul 2019 22:02:43 -0700 (PDT)
Date: Tue, 23 Jul 2019 01:02:39 -0400
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Jason Wang <jasowang@redhat.com>
Cc: syzbot <syzbot+e58112d71f77113ddb7b@syzkaller.appspotmail.com>,
	aarcange@redhat.com, akpm@linux-foundation.org,
	christian@brauner.io, davem@davemloft.net, ebiederm@xmission.com,
	elena.reshetova@intel.com, guro@fb.com, hch@infradead.org,
	james.bottomley@hansenpartnership.com, jglisse@redhat.com,
	keescook@chromium.org, ldv@altlinux.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, linux-parisc@vger.kernel.org,
	luto@amacapital.net, mhocko@suse.com, mingo@kernel.org,
	namit@vmware.com, peterz@infradead.org,
	syzkaller-bugs@googlegroups.com, viro@zeniv.linux.org.uk,
	wad@chromium.org
Subject: Re: WARNING in __mmdrop
Message-ID: <20190723010156-mutt-send-email-mst@kernel.org>
References: <0000000000008dd6bb058e006938@google.com>
 <000000000000964b0d058e1a0483@google.com>
 <20190721044615-mutt-send-email-mst@kernel.org>
 <75c43998-3a1c-676f-99ff-3d04663c3fcc@redhat.com>
 <20190722035657-mutt-send-email-mst@kernel.org>
 <cfcd330d-5f4a-835a-69f7-c342d5d0d52d@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <cfcd330d-5f4a-835a-69f7-c342d5d0d52d@redhat.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 23, 2019 at 11:55:28AM +0800, Jason Wang wrote:
> 
> On 2019/7/22 下午4:02, Michael S. Tsirkin wrote:
> > On Mon, Jul 22, 2019 at 01:21:59PM +0800, Jason Wang wrote:
> > > On 2019/7/21 下午6:02, Michael S. Tsirkin wrote:
> > > > On Sat, Jul 20, 2019 at 03:08:00AM -0700, syzbot wrote:
> > > > > syzbot has bisected this bug to:
> > > > > 
> > > > > commit 7f466032dc9e5a61217f22ea34b2df932786bbfc
> > > > > Author: Jason Wang <jasowang@redhat.com>
> > > > > Date:   Fri May 24 08:12:18 2019 +0000
> > > > > 
> > > > >       vhost: access vq metadata through kernel virtual address
> > > > > 
> > > > > bisection log:  https://syzkaller.appspot.com/x/bisect.txt?x=149a8a20600000
> > > > > start commit:   6d21a41b Add linux-next specific files for 20190718
> > > > > git tree:       linux-next
> > > > > final crash:    https://syzkaller.appspot.com/x/report.txt?x=169a8a20600000
> > > > > console output: https://syzkaller.appspot.com/x/log.txt?x=129a8a20600000
> > > > > kernel config:  https://syzkaller.appspot.com/x/.config?x=3430a151e1452331
> > > > > dashboard link: https://syzkaller.appspot.com/bug?extid=e58112d71f77113ddb7b
> > > > > syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=10139e68600000
> > > > > 
> > > > > Reported-by: syzbot+e58112d71f77113ddb7b@syzkaller.appspotmail.com
> > > > > Fixes: 7f466032dc9e ("vhost: access vq metadata through kernel virtual
> > > > > address")
> > > > > 
> > > > > For information about bisection process see: https://goo.gl/tpsmEJ#bisection
> > > > OK I poked at this for a bit, I see several things that
> > > > we need to fix, though I'm not yet sure it's the reason for
> > > > the failures:
> > > > 
> > > > 
> > > > 1. mmu_notifier_register shouldn't be called from vhost_vring_set_num_addr
> > > >      That's just a bad hack,
> > > 
> > > This is used to avoid holding lock when checking whether the addresses are
> > > overlapped. Otherwise we need to take spinlock for each invalidation request
> > > even if it was the va range that is not interested for us. This will be very
> > > slow e.g during guest boot.
> > KVM seems to do exactly that.
> > I tried and guest does not seem to boot any slower.
> > Do you observe any slowdown?
> 
> 
> Yes I do.
> 
> 
> > 
> > Now I took a hard look at the uaddr hackery it really makes
> > me nervious. So I think for this release we want something
> > safe, and optimizations on top. As an alternative revert the
> > optimization and try again for next merge window.
> 
> 
> Will post a series of fixes, let me know if you're ok with that.
> 
> Thanks

I'd prefer you to take a hard look at the patch I posted
which makes code cleaner, and ad optimizations on top.
But other ways could be ok too.

> 
> > 
> > 

