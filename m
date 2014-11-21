Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id EBD906B0070
	for <linux-mm@kvack.org>; Fri, 21 Nov 2014 05:32:46 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id kq14so4622957pab.20
        for <linux-mm@kvack.org>; Fri, 21 Nov 2014 02:32:45 -0800 (PST)
Received: from mail-pa0-x233.google.com (mail-pa0-x233.google.com. [2607:f8b0:400e:c03::233])
        by mx.google.com with ESMTPS id ac9si7211980pbd.232.2014.11.21.02.32.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 21 Nov 2014 02:32:45 -0800 (PST)
Received: by mail-pa0-f51.google.com with SMTP id ey11so4646170pad.10
        for <linux-mm@kvack.org>; Fri, 21 Nov 2014 02:32:44 -0800 (PST)
Date: Fri, 21 Nov 2014 19:32:32 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC PATCH] mm/zsmalloc: remove unnecessary check
Message-ID: <20141121103232.GA31540@blaptop>
References: <1416489716-9967-1-git-send-email-opensource.ganesh@gmail.com>
 <20141121035442.GB10123@bbox>
 <CADAEsF975+a6Y5dcEu1B2OscQ5JaxD+ZQ1jnFOJ115BXgMqULA@mail.gmail.com>
 <20141121064849.GA17181@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141121064849.GA17181@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ganesh Mahendran <opensource.ganesh@gmail.com>
Cc: Nitin Gupta <ngupta@vflare.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Fri, Nov 21, 2014 at 06:48:49AM +0000, Minchan Kim wrote:
> On Fri, Nov 21, 2014 at 01:33:26PM +0800, Ganesh Mahendran wrote:
> > Hello
> > 
> > 2014-11-21 11:54 GMT+08:00 Minchan Kim <minchan@kernel.org>:
> > > On Thu, Nov 20, 2014 at 09:21:56PM +0800, Mahendran Ganesh wrote:
> > >> ZS_SIZE_CLASSES is calc by:
> > >>   ((ZS_MAX_ALLOC_SIZE - ZS_MIN_ALLOC_SIZE) / ZS_SIZE_CLASS_DELTA + 1)
> > >>
> > >> So when i is in [0, ZS_SIZE_CLASSES - 1), the size:
> > >>   size = ZS_MIN_ALLOC_SIZE + i * ZS_SIZE_CLASS_DELTA
> > >> will not be greater than ZS_MAX_ALLOC_SIZE
> > >>
> > >> This patch removes the unnecessary check.
> > >
> > > It depends on ZS_MIN_ALLOC_SIZE.
> > > For example, we would change min to 8 but MAX is still 4096.
> > > ZS_SIZE_CLASSES is (4096 - 8) / 16 + 1 = 256 so 8 + 255 * 16 = 4088,
> > > which exceeds the max.
> > Here, 4088 is less than MAX(4096).
> > 
> > ZS_SIZE_CLASSES = (MAX - MIN) / Delta + 1
> > So, I think the value of
> >     MIN + (ZS_SIZE_CLASSES - 1) * Delta =
> >     MIN + ((MAX - MIN) / Delta) * Delta =
> >     MAX
> > will not exceed the MAX
> 
> You're right. It was complext math for me.
> I should go back to elementary school.
> 
> Thanks!
> 
> Acked-by: Minchan Kim <minchan@kernel.org>

I catch a nasty cold but above my poor math makes me think more.
ZS_SIZE_CLASSES is broken. In above my example, current code cannot
allocate 4096 size class so we should correct ZS_SIZE_CLASSES
at first.

zs_size_classes = zs_max - zs_min / delta + 1;
if ((zs_max - zs_min) % delta)
	zs_size_classes += 1;

Then, we need to code piece you removed.
As well, we need to fix below.

- area->vm_buf = (char *)__get_free_page(GFP_KERNEL);
+ area->vm_buf = kmalloc(ZS_MAX_ALLOC_SIZE);

Hope I am sane in this time :(

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
