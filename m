Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id D531E6B006E
	for <linux-mm@kvack.org>; Wed, 17 Jun 2015 03:19:46 -0400 (EDT)
Received: by wicnd19 with SMTP id nd19so73357291wic.1
        for <linux-mm@kvack.org>; Wed, 17 Jun 2015 00:19:46 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gr2si6074092wjc.163.2015.06.17.00.19.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 17 Jun 2015 00:19:45 -0700 (PDT)
Date: Wed, 17 Jun 2015 09:19:39 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: Possible broken MM code in dell-laptop.c?
Message-ID: <20150617071939.GA25056@dhcp22.suse.cz>
References: <201506141105.07171@pali>
 <20150615211816.GC16138@dhcp22.suse.cz>
 <201506152327.59907@pali>
 <20150616063346.GA24296@dhcp22.suse.cz>
 <20150616071523.GB5863@pali>
 <20150617034334.GB29788@vmdeb7>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150617034334.GB29788@vmdeb7>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Darren Hart <dvhart@infradead.org>
Cc: Pali =?iso-8859-1?Q?Roh=E1r?= <pali.rohar@gmail.com>, Hans de Goede <hdegoede@redhat.com>, Ben Skeggs <bskeggs@redhat.com>, Stuart Hayes <stuart_hayes@dell.com>, Matthew Garrett <mjg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, platform-driver-x86@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 16-06-15 20:43:34, Darren Hart wrote:
[...]
> Michal - thanks for the context.
> 
> I'm surprised by your recommendation to use __free_page() out here in platform
> driver land.
> 
> I'd also prefer that the driver consistently free the same address to avoid
> confusion.
> 
> For these reasons, free_page((unsigned long)buffer) seems like the better
> option.
> 
> Can you elaborate on why you feel __free_page() is a better choice?

Well the allocation uses alloc_page and __free_page is the freeing
counterpart so it is natural to use it if the allocated page is
available. Which is the case here.

Anyway the code can be cleaned up by using __get_free_page for the
allocation, then you do not have to care about the struct page and get
the address right away without an additional code. free_page would be a
natural freeing path.
__get_free_page would be even a better API because it enforces that
the allocation is not from the highmem - which the driver already does
by not using __GFP_HIGHMEM.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
