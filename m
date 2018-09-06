Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9A7ED6B7952
	for <linux-mm@kvack.org>; Thu,  6 Sep 2018 11:13:39 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id q29-v6so3813016edd.0
        for <linux-mm@kvack.org>; Thu, 06 Sep 2018 08:13:39 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m17-v6si4057290edm.387.2018.09.06.08.13.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Sep 2018 08:13:38 -0700 (PDT)
Date: Thu, 6 Sep 2018 17:13:36 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 1/2] mm: Move page struct poisoning to
 CONFIG_DEBUG_VM_PAGE_INIT_POISON
Message-ID: <20180906151336.GD14951@dhcp22.suse.cz>
References: <20180905211041.3286.19083.stgit@localhost.localdomain>
 <20180905211328.3286.71674.stgit@localhost.localdomain>
 <20180906054735.GJ14951@dhcp22.suse.cz>
 <0c1c36f7-f45a-8fe9-dd52-0f60b42064a9@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0c1c36f7-f45a-8fe9-dd52-0f60b42064a9@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Alexander Duyck <alexander.duyck@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, alexander.h.duyck@intel.com, pavel.tatashin@microsoft.com, akpm@linux-foundation.org, mingo@kernel.org, kirill.shutemov@linux.intel.com

On Thu 06-09-18 07:59:03, Dave Hansen wrote:
> On 09/05/2018 10:47 PM, Michal Hocko wrote:
> > why do you have to keep DEBUG_VM enabled for workloads where the boot
> > time matters so much that few seconds matter?
> 
> There are a number of distributions that run with it enabled in the
> default build.  Fedora, for one.  We've basically assumed for a while
> that we have to live with it in production environments.
> 
> So, where does leave us?  I think we either need a _generic_ debug
> option like:
> 
> 	CONFIG_DEBUG_VM_SLOW_AS_HECK
> 
> under which we can put this an other really slow VM debugging.  Or, we
> need some kind of boot-time parameter to trigger the extra checking
> instead of a new CONFIG option.

I strongly suspect nobody will ever enable such a scary looking config
TBH. Besides I am not sure what should go under that config option.
Something that takes few cycles but it is called often or one time stuff
that takes quite a long but less than aggregated overhead of the former?

Just consider this particular case. It basically re-adds an overhead
that has always been there before the struct page init optimization
went it. The poisoning just returns it in a different form to catch
potential left overs. And we would like to have as many people willing
to running in debug mode to test for those paths because they are
basically impossible to review by the code inspection. More importantnly
the major overhead is boot time so my question still stands. Is this
worth a separate config option almost nobody is going to enable?

Enabling DEBUG_VM by Fedora and others serves us a very good testing
coverage and I appreciate that because it has generated some useful bug
reports. Those people are paying quite a lot of overhead in runtime
which can aggregate over time is it so much to ask about one time boot
overhead?

-- 
Michal Hocko
SUSE Labs
