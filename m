Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EB7C3C31E40
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 15:13:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AA7D02171F
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 15:13:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AA7D02171F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=rowland.harvard.edu
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 45E4E6B0003; Fri,  9 Aug 2019 11:13:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 40FCC6B0006; Fri,  9 Aug 2019 11:13:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3256C6B0007; Fri,  9 Aug 2019 11:13:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 150126B0003
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 11:13:03 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id e22so23381399qtp.9
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 08:13:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:in-reply-to:message-id:mime-version;
        bh=WL4STIijpj1WXzicAtb0qiAPcA/0z0sjaul86FSf/1Y=;
        b=rHn+5JxxGkNcKgDyVF7xpQCm3rJmce9NVOwqOjJ7ZgWCo1bmssfjhR2lGhR2IRPvPq
         boX7YmpGWtlSSZotKbuij0fXT/3MtFZtJ/tW3M8ttxedkYEus+0UStFiZMxmpOfZS/UT
         ip1JuX5FkDi0b1LnXHFd7qAlqi8iPcJEf9d+/hiXqbO9+s63/Op7hixeQfmMgLSBeLwT
         IFzCPS6hfHV2wKBDlu2KBzSX9rilqJxaU6OPDUJuYifJHr/9uFveAVedi36qRRC0ul4Z
         H/hLGPdBliPXIwVCok1XedAORy+b1RAkBUNZc+vTwFNBues3JmEl2tXwvQogKE9l1dnK
         lU3A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of stern+5d4dbffe@rowland.harvard.edu designates 192.131.102.54 as permitted sender) smtp.mailfrom=stern+5d4dbffe@rowland.harvard.edu
X-Gm-Message-State: APjAAAW+dFPKZRaA+kMSDlNEsH1gs0MuZyCfhwaa3COG7XneWLrmyHdX
	IS7wmNSq5vCDY2XFzEkOn3YzYlr8//AS8Bc+AmE7hu8zPtashI+g4gDUFimaN4f9XbjVUsQARyY
	ecqk1bA2R/d37A3w8zREt3kvCa0uXvMBPBm3IDIMQpFjKNxS863Mt5qQvzCsMGshkcw==
X-Received: by 2002:ae9:ea0b:: with SMTP id f11mr19056450qkg.142.1565363582841;
        Fri, 09 Aug 2019 08:13:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy1mH/rwaAnBAzNQEVoRqZyjMXsxsE5l2kPJQ1jJRZC+I+EUkjpQ6utZbKxS9Bov90MbVw9
X-Received: by 2002:ae9:ea0b:: with SMTP id f11mr19056378qkg.142.1565363582089;
        Fri, 09 Aug 2019 08:13:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565363582; cv=none;
        d=google.com; s=arc-20160816;
        b=dkwVxIJiMqB1GSGZY0DegmI1fc+RY3eYEbDx7EPyBvPfBpuNjiL2sEN9RhF362f6GD
         9OY7w1MEzIwxk30vip2+TwH/p8r+fcIGTHRMKssKlbOcD8JXSeKJIkkqGJv7y0m1Duvp
         zfFEusYKJlBQ73kHwvMYXb6M3D7QY+F3UhGupxF/RpNukjQPKbqMezTd2pEo47dwTOzg
         qiOSrZpFXc8LnD4lcq90bjaqVwZydSWv1oksjYw7DJcvspY0/icWC5N9v+FWFnT07JEV
         AXlcp/n/zLWwO0Pjci3JhhQ4WYVcAqmEu93wuHTk03zPG94+B6ZPDO+SXBpUI1harWOC
         yV7Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:in-reply-to:subject:cc:to:from:date;
        bh=WL4STIijpj1WXzicAtb0qiAPcA/0z0sjaul86FSf/1Y=;
        b=KayhmRiC2zNeDI0B5yB49sHuEFeodIRcTYOCPl+CR6HatwyBxg324pTw2Kr8QEu4bm
         OXvGasMO2HbmCSj2nWee0LWC9arxhxmMTEJ7+bVeUXmO1g2QUEsghn4cemfSJSV09wjM
         mzjMvBig/bZ1Gchs721ukHGzVcCsJ84F2K77K1nL/7ZhkL0J4MdHyDKRiWyKHFBjKYj5
         pmRuwo7wIjiUUodcLHreOESU9pyVdLOOyLfWCdKHkyjt1LOa1O8R0z8YHiwV+1uf3Viw
         zR+0xvFS2aEZSil6SIVPsry0AI6nXD9GeLHd+Ttt7K6ZZ+TU4d2HvEWvn1xUU/0j3m4c
         G+XA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of stern+5d4dbffe@rowland.harvard.edu designates 192.131.102.54 as permitted sender) smtp.mailfrom=stern+5d4dbffe@rowland.harvard.edu
Received: from iolanthe.rowland.org (iolanthe.rowland.org. [192.131.102.54])
        by mx.google.com with SMTP id d23si3641501qtk.128.2019.08.09.08.13.01
        for <linux-mm@kvack.org>;
        Fri, 09 Aug 2019 08:13:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of stern+5d4dbffe@rowland.harvard.edu designates 192.131.102.54 as permitted sender) client-ip=192.131.102.54;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of stern+5d4dbffe@rowland.harvard.edu designates 192.131.102.54 as permitted sender) smtp.mailfrom=stern+5d4dbffe@rowland.harvard.edu
Received: (qmail 1813 invoked by uid 2102); 9 Aug 2019 11:13:00 -0400
Received: from localhost (sendmail-bs@127.0.0.1)
  by localhost with SMTP; 9 Aug 2019 11:13:00 -0400
Date: Fri, 9 Aug 2019 11:13:00 -0400 (EDT)
From: Alan Stern <stern@rowland.harvard.edu>
X-X-Sender: stern@iolanthe.rowland.org
To: Greg KH <gregkh@linuxfoundation.org>
cc: Kees Cook <keescook@chromium.org>, 
    syzbot <syzbot+45b2f40f0778cfa7634e@syzkaller.appspotmail.com>, 
    Michael Hund <mhund@ld-didactic.de>,  <akpm@linux-foundation.org>, 
     <andreyknvl@google.com>,  <cai@lca.pw>,  <linux-kernel@vger.kernel.org>, 
     <linux-mm@kvack.org>,  <linux-usb@vger.kernel.org>, 
     <syzkaller-bugs@googlegroups.com>,  <tglx@linutronix.de>
Subject: Re: BUG: bad usercopy in ld_usb_read
In-Reply-To: <20190809085545.GB21320@kroah.com>
Message-ID: <Pine.LNX.4.44L0.1908091100580.1630-100000@iolanthe.rowland.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 9 Aug 2019, Greg KH wrote:

> On Thu, Aug 08, 2019 at 04:06:32PM -0700, Kees Cook wrote:
> > On Thu, Aug 08, 2019 at 02:46:54PM +0200, Greg KH wrote:
> > > On Thu, Aug 08, 2019 at 05:38:06AM -0700, syzbot wrote:
> > > > Hello,
> > > > 
> > > > syzbot found the following crash on:
> > > > 
> > > > HEAD commit:    e96407b4 usb-fuzzer: main usb gadget fuzzer driver
> > > > git tree:       https://github.com/google/kasan.git usb-fuzzer
> > > > console output: https://syzkaller.appspot.com/x/log.txt?x=13aeaece600000
> > > > kernel config:  https://syzkaller.appspot.com/x/.config?x=cfa2c18fb6a8068e
> > > > dashboard link: https://syzkaller.appspot.com/bug?extid=45b2f40f0778cfa7634e
> > > > compiler:       gcc (GCC) 9.0.0 20181231 (experimental)
> > > > 
> > > > Unfortunately, I don't have any reproducer for this crash yet.
> > > > 
> > > > IMPORTANT: if you fix the bug, please add the following tag to the commit:
> > > > Reported-by: syzbot+45b2f40f0778cfa7634e@syzkaller.appspotmail.com
> > > > 
> > > > ldusb 6-1:0.124: Read buffer overflow, -131383996186150 bytes dropped
> > > 
> > > That's a funny number :)
> > > 
> > > Nice overflow found, I see you are now starting to fuzz the char device
> > > nodes of usb drivers...
> > > 
> > > Michael, care to fix this up?
> > 
> > This looks like the length in the read-from-device buffer is unchecked:
> > 
> >         /* actual_buffer contains actual_length + interrupt_in_buffer */
> >         actual_buffer = (size_t *)(dev->ring_buffer + dev->ring_tail * (sizeof(size_t)+dev->interrupt_in_endpoint_size));
> >         bytes_to_read = min(count, *actual_buffer);
> >         if (bytes_to_read < *actual_buffer)
> >                 dev_warn(&dev->intf->dev, "Read buffer overflow, %zd bytes dropped\n",
> >                          *actual_buffer-bytes_to_read);
> > 
> >         /* copy one interrupt_in_buffer from ring_buffer into userspace */
> >         if (copy_to_user(buffer, actual_buffer+1, bytes_to_read)) {
> >                 retval = -EFAULT;
> >                 goto unlock_exit;
> >         }
> > 
> > I assume what's stored at actual_buffer is bogus and needs validation
> > somewhere before it's actually used. (If not here, maybe where ever the
> > write into the buffer originally happens?)
> 
> I think it should be verified here, as that's when it is parsed.  The
> data is written to the buffer in ld_usb_interrupt_in_callback() but it
> does not "know" how to parse it at that location.

I looked at this bug report, and it is very puzzling.

Yes, the value stored in *actual_buffer is written in
ld_usb_interrupt_in_callback(), but the value is simply
urb->actual_length and therefore does not need any validation.  The 
URB's transfer_buffer_length is taken from 
dev->interrupt_in_endpoint_size, which comes from usb_endpoint_maxp() 
and therefore cannot be larger than 2048.

(On the other hand, actual_buffer might not be aligned on a 32-bit 
address.  For x86, of course, this doesn't matter, but it can affect 
other architectures.)

Furthermore, the computation leading to the dev_warn() involves only
size_t types and therefore is carried out entirely using unsigned
arithmetic.  The warning's format string uses %zd instead of %zu;  
that's why the number showed up as negative but doesn't explain why it
looks so funny.

In fact, I don't see why any of the computations here should overflow
or wrap around, or even give rise to a negative value.  If syzbot had a
reproducer we could get more debugging output -- but it doesn't.

Alan Stern

