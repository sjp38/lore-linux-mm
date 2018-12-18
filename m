Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id C8B6E8E0001
	for <linux-mm@kvack.org>; Tue, 18 Dec 2018 07:33:52 -0500 (EST)
Received: by mail-wm1-f71.google.com with SMTP id b186so851684wmc.8
        for <linux-mm@kvack.org>; Tue, 18 Dec 2018 04:33:52 -0800 (PST)
Received: from pandora.armlinux.org.uk (pandora.armlinux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id k203si1464111wmb.33.2018.12.18.04.33.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Dec 2018 04:33:51 -0800 (PST)
Date: Tue, 18 Dec 2018 12:33:19 +0000
From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: [PATCH v4 4/9] drm/rockchip/rockchip_drm_gem.c: Convert to use
 vm_insert_range
Message-ID: <20181218123318.GN26090@n2100.armlinux.org.uk>
References: <20181217202334.GA11758@jordon-HP-15-Notebook-PC>
 <20181218095709.GJ26090@n2100.armlinux.org.uk>
 <CAFqt6zaVU-Fme6fErieBfBKwAm9xHUa7cXTOfqzwUJR__0JysQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAFqt6zaVU-Fme6fErieBfBKwAm9xHUa7cXTOfqzwUJR__0JysQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Souptick Joarder <jrdr.linux@gmail.com>
Cc: Michal Hocko <mhocko@suse.com>, Heiko Stuebner <heiko@sntech.de>, linux-rockchip@lists.infradead.org, airlied@linux.ie, hjc@rock-chips.com, Matthew Wilcox <willy@infradead.org>, linux-kernel@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, dri-devel@lists.freedesktop.org, Andrew Morton <akpm@linux-foundation.org>, linux-arm-kernel@lists.infradead.org

On Tue, Dec 18, 2018 at 05:36:04PM +0530, Souptick Joarder wrote:
> On Tue, Dec 18, 2018 at 3:27 PM Russell King - ARM Linux
> <linux@armlinux.org.uk> wrote:
> > This looks like a change in behaviour.
> >
> > If user_count is zero, and offset is zero, then we pass into
> > vm_insert_range() a page_count of zero, and vm_insert_range() does
> > nothing and returns zero.
> >
> > However, as we can see from the above code, the original behaviour
> > was to return -ENXIO in that case.
> 
> I think these checks are not necessary. I am not sure if we get into mmap
> handlers of driver with user_count = 0.

I'm not sure either, I'm just pointing out the change of behaviour.

> > The other thing that I'm wondering is that if (eg) count is 8 (the
> > object is 8 pages), offset is 2, and the user requests mapping 6
> > pages (user_count = 6), then we call vm_insert_range() with a
> > pages of rk_obj->pages + 2, and a pages_count of 6 - 2 = 4. So we
> > end up inserting four pages.
> 
> Considering the scenario, user_count will remain 8 (user_count =
> vma_pages(vma) ). ? No ?
> Then we call vm_insert_range() with a pages of rk_obj->pages + 2, and
> a pages_count
> of 8 - 2 = 6. So we end up inserting 6 pages.
> 
> Please correct me if I am wrong.

vma_pages(vma) is the number of pages that the user requested, it is
the difference between vma->vm_end and vma->vm_start in pages.  As I
said above, "the user requests mapping 6 pages", so vma_pages() will
be 6, and so user_count will also be 6.  You are passing
user_count - offset into vm_insert_range(), which will be 6 - 2 = 4
in my example.  This is two pages short of what the user requested.

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line in suburbia: sync at 12.1Mbps down 622kbps up
According to speedtest.net: 11.9Mbps down 500kbps up
