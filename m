Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 14C096B4CC1
	for <linux-mm@kvack.org>; Wed, 29 Aug 2018 13:04:42 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id o18-v6so5099952qtm.11
        for <linux-mm@kvack.org>; Wed, 29 Aug 2018 10:04:42 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id 37-v6si4028208qvb.268.2018.08.29.10.04.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Aug 2018 10:04:40 -0700 (PDT)
Date: Wed, 29 Aug 2018 13:04:35 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [RFC v2 0/2] Do not touch pages in remove_memory path
Message-ID: <20180829170434.GA3784@redhat.com>
References: <20180817154127.28602-1-osalvador@techadventures.net>
 <20180828114709.GA13859@techadventures.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180828114709.GA13859@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oscar Salvador <osalvador@techadventures.net>
Cc: akpm@linux-foundation.org, mhocko@suse.com, dan.j.williams@intel.com, david@redhat.com, jonathan.cameron@huawei.com, Pavel.Tatashin@microsoft.com, yasu.isimatu@gmail.com, logang@deltatee.com, dave.jiang@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oscar Salvador <osalvador@suse.de>

On Tue, Aug 28, 2018 at 01:47:09PM +0200, Oscar Salvador wrote:
> On Fri, Aug 17, 2018 at 05:41:25PM +0200, Oscar Salvador wrote:
> > From: Oscar Salvador <osalvador@suse.de>
> [...]
> > 
> > The main difficulty I faced here was in regard of HMM/devm, as it really handles
> > the hot-add/remove memory particulary, and what is more important,
> > also the resources.
> > 
> > I really scratched my head for ideas about how to handle this case, and
> > after some fails I came up with the idea that we could check for the
> > res->flags.
> > 
> > Memory resources that goes through the "official" memory-hotplug channels
> > have the IORESOURCE_SYSTEM_RAM flag.
> > This flag is made of (IORESOURCE_MEM|IORESOURCE_SYSRAM).
> > 
> > HMM/devm, on the other hand, request and release the resources
> > through devm_request_mem_region/devm_release_mem_region, and 
> > these resources do not contain the IORESOURCE_SYSRAM flag.
> > 
> > So what I ended up doing is to check for IORESOURCE_SYSRAM
> > in release_mem_region_adjustable.
> > If we see that a resource does not have such a flag, we know that
> > we are dealing with a resource coming from HMM/devm, and so,
> > we do not need to do anything as HMM/dev will take care of that part.
> > 
> 
> Jerome/Dan, now that the merge window is closed, and before sending the RFCv3, could you please check
> this and see if you see something that is flagrant wrong? (about devm/HMM)
> 
> If you prefer I can send v3 spliting up even more.
> Maybe this will ease the review.
> 

This looks good to me you can add Reviewed-by: Jerome Glisse <jglisse@redhat.com>
