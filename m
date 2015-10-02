Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f44.google.com (mail-qg0-f44.google.com [209.85.192.44])
	by kanga.kvack.org (Postfix) with ESMTP id EB46382FA6
	for <linux-mm@kvack.org>; Fri,  2 Oct 2015 16:53:17 -0400 (EDT)
Received: by qgev79 with SMTP id v79so105243190qge.0
        for <linux-mm@kvack.org>; Fri, 02 Oct 2015 13:53:17 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id j16si11959844qge.10.2015.10.02.13.53.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Oct 2015 13:53:17 -0700 (PDT)
Date: Fri, 2 Oct 2015 13:53:15 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: optimize PageHighMem() check
Message-Id: <20151002135315.7ae22edce0bf54e38f69b1b0@linux-foundation.org>
In-Reply-To: <560E2F29.5070807@synopsys.com>
References: <1443513260-14598-1-git-send-email-vgupta@synopsys.com>
	<20151001162528.32c5338efdff2bdea838befd@linux-foundation.org>
	<560E2F29.5070807@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vineet Gupta <vgupta@synopsys.com>
Cc: linux-mm@kvack.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@suse.cz>, Jennifer Herbert <jennifer.herbert@citrix.com>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, linux-kernel@vger.kernel.org

On Fri, 2 Oct 2015 12:45:53 +0530 Vineet Gupta <vgupta@synopsys.com> wrote:

> On Friday 02 October 2015 04:55 AM, Andrew Morton wrote:
> > On Tue, 29 Sep 2015 13:24:20 +0530 Vineet Gupta <Vineet.Gupta1@synopsys.com> wrote:
> > 
> >> > This came up when implementing HIHGMEM/PAE40 for ARC.
> >> > The kmap() / kmap_atomic() generated code seemed needlessly bloated due
> >> > to the way PageHighMem() macro is implemented.
> >> > It derives the exact zone for page and then does pointer subtraction
> >> > with first zone to infer the zone_type.
> >> > The pointer arithmatic in turn generates the code bloat.
> >> > 
> >> > PageHighMem(page)
> >> >   is_highmem(page_zone(page))
> >> >      zone_off = (char *)zone - (char *)zone->zone_pgdat->node_zones
> >> > 
> >> > Instead use is_highmem_idx() to work on zone_type available in page flags
> >> > 
> >> >    ----- Before -----
> >> > 80756348:	mov_s      r13,r0
> >> > 8075634a:	ld_s       r2,[r13,0]
> >> > 8075634c:	lsr_s      r2,r2,30
> >> > 8075634e:	mpy        r2,r2,0x2a4
> >> > 80756352:	add_s      r2,r2,0x80aef880
> >> > 80756358:	ld_s       r3,[r2,28]
> >> > 8075635a:	sub_s      r2,r2,r3
> >> > 8075635c:	breq       r2,0x2a4,80756378 <kmap+0x48>
> >> > 80756364:	breq       r2,0x548,80756378 <kmap+0x48>
> >> > 
> >> >    ----- After  -----
> >> > 80756330:	mov_s      r13,r0
> >> > 80756332:	ld_s       r2,[r13,0]
> >> > 80756334:	lsr_s      r2,r2,30
> >> > 80756336:	sub_s      r2,r2,1
> >> > 80756338:	brlo       r2,2,80756348 <kmap+0x30>
> >> > 
> >> > For x86 defconfig build (32 bit only) it saves around 900 bytes.
> >> > For ARC defconfig with HIGHMEM, it saved around 2K bytes.
> >> > 
> >> >    ---->8-------
> >> > ./scripts/bloat-o-meter x86/vmlinux-defconfig-pre x86/vmlinux-defconfig-post
> >> > add/remove: 0/0 grow/shrink: 0/36 up/down: 0/-934 (-934)
> >> > function                                     old     new   delta
> >> > saveable_page                                162     154      -8
> >> > saveable_highmem_page                        154     146      -8
> >> > skb_gro_reset_offset                         147     131     -16
> >> > ...
> >> > ...
> >> > __change_page_attr_set_clr                  1715    1678     -37
> >> > setup_data_read                              434     394     -40
> >> > mon_bin_event                               1967    1927     -40
> >> > swsusp_save                                 1148    1105     -43
> >> > _set_pages_array                             549     493     -56
> >> >    ---->8-------
> >> > 
> >> > e.g. For ARC kmap()
> >> > 
> > is_highmem() is deranged.  Can't we use a bit in zone->flags or
> > something?
> 
> It won't be "a" bit since zone_type is an enum.

Yes it will!

static inline int is_highmem(struct zone *zone)
{
	return test_bit(ZONE_HIGHMEM, &zone->flags);
}

> ...
>
> However this patch still is independent of that since we have struct page as
> starting point and zone_type is available from there directly w/o monkeying around
> with any zone structs.

yup.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
