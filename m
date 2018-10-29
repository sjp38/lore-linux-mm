Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id 45C856B037F
	for <linux-mm@kvack.org>; Mon, 29 Oct 2018 11:50:00 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id l92so6755592otc.12
        for <linux-mm@kvack.org>; Mon, 29 Oct 2018 08:50:00 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m12sor9971116otl.31.2018.10.29.08.49.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 29 Oct 2018 08:49:58 -0700 (PDT)
MIME-Version: 1.0
References: <20181009170051.GA40606@tiger-server> <CAPcyv4g99_rJJSn0kWv5YO0Mzj90q1LH1wC3XrjCh1=x6mo7BQ@mail.gmail.com>
 <25092df0-b7b4-d456-8409-9c004cb6e422@linux.intel.com> <20181010095838.GG5873@dhcp22.suse.cz>
 <f97de51c-67dd-99b2-754e-0685cac06699@linux.intel.com> <20181010172451.GK5873@dhcp22.suse.cz>
 <98c35e19-13b9-0913-87d9-b3f1ab738b61@linux.intel.com> <20181010185242.GP5873@dhcp22.suse.cz>
 <20181011085509.GS5873@dhcp22.suse.cz> <6f32f23c-c21c-9d42-7dda-a1d18613cd3c@linux.intel.com>
 <20181017075257.GF18839@dhcp22.suse.cz> <971729e6-bcfe-a386-361b-d662951e69a7@linux.intel.com>
In-Reply-To: <971729e6-bcfe-a386-361b-d662951e69a7@linux.intel.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 29 Oct 2018 08:49:46 -0700
Message-ID: <CAPcyv4gZZcuWFLzRpyJcAxtGEPTDkpwkG3J0Z4Q1u790+7W2Ag@mail.gmail.com>
Subject: Re: [PATCH v5 4/4] mm: Defer ZONE_DEVICE page initialization to the
 point where we init pgmap
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: alexander.h.duyck@linux.intel.com
Cc: Michal Hocko <mhocko@kernel.org>, Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-nvdimm <linux-nvdimm@lists.01.org>, Pasha Tatashin <pavel.tatashin@microsoft.com>, Dave Hansen <dave.hansen@intel.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, rppt@linux.vnet.ibm.com, Ingo Molnar <mingo@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Zhang Yi <yi.z.zhang@linux.intel.com>

On Wed, Oct 17, 2018 at 8:02 AM Alexander Duyck
<alexander.h.duyck@linux.intel.com> wrote:
>
> On 10/17/2018 12:52 AM, Michal Hocko wrote:
> > On Thu 11-10-18 10:38:39, Alexander Duyck wrote:
> >> On 10/11/2018 1:55 AM, Michal Hocko wrote:
> >>> On Wed 10-10-18 20:52:42, Michal Hocko wrote:
> >>> [...]
> >>>> My recollection was that we do clear the reserved bit in
> >>>> move_pfn_range_to_zone and we indeed do in __init_single_page. But then
> >>>> we set the bit back right afterwards. This seems to be the case since
> >>>> d0dc12e86b319 which reorganized the code. I have to study this some more
> >>>> obviously.
> >>>
> >>> so my recollection was wrong and d0dc12e86b319 hasn't really changed
> >>> much because __init_single_page wouldn't zero out the struct page for
> >>> the hotplug contex. A comment in move_pfn_range_to_zone explains that we
> >>> want the reserved bit because pfn walkers already do see the pfn range
> >>> and the page is not fully associated with the zone until it is onlined.
> >>>
> >>> I am thinking that we might be overzealous here. With the full state
> >>> initialized we shouldn't actually care. pfn_to_online_page should return
> >>> NULL regardless of the reserved bit and normal pfn walkers shouldn't
> >>> touch pages they do not recognize and a plain page with ref. count 1
> >>> doesn't tell much to anybody. So I _suspect_ that we can simply drop the
> >>> reserved bit setting here.
> >>
> >> So this has me a bit hesitant to want to just drop the bit entirely. If
> >> nothing else I think I may wan to make that a patch onto itself so that if
> >> we aren't going to set it we just drop it there. That way if it does cause
> >> issues we can bisect it to that patch and pinpoint the cause.
> >
> > Yes a patch on its own make sense for bisectability.
>
> For now I think I am going to back off of this. There is a bunch of
> other changes that need to happen in order for us to make this work. As
> far as I can tell there are several places that are relying on this
> reserved bit.

When David Hildebrand and I looked it was only the hibernation code
that we thought needed changing. We either need to audit the removal
or go back to adding a special case hack for kvm because this is a
blocking issue for them.

What do you see beyond the hibernation change?
